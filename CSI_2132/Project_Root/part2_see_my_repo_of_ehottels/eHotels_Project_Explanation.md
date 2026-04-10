# CSI2132 eHotels Project — 完整讲解文档

> **课程**: CSI2132 Databases I — University of Ottawa  
> **学生**: Haojian Wang, Xinran Xie  
> **内容**: 从需求分析到 Web 应用的全过程讲解，结合课程 Lecture 知识点

---

## 目录

1. [项目背景与需求分析](#1-项目背景与需求分析)
2. [第一阶段：数据规划（1st Deliverable）](#2-第一阶段数据规划)
   - 2.1 ER 模型基础知识
   - 2.2 识别实体与属性
   - 2.3 识别关系与基数
   - 2.4 弱实体与特殊设计决策
   - 2.5 ER → 关系模式转换
3. [完整性约束](#3-完整性约束)
   - 3.1 主键约束
   - 3.2 参照完整性（外键）
   - 3.3 域与属性约束
   - 3.4 用户自定义约束
4. [第二阶段：数据库实现（2nd Deliverable）](#4-第二阶段数据库实现)
   - 4.1 DDL 实现 (schema.sql)
   - 4.2 数据填充 (populate.sql)
   - 4.3 SQL 查询 (queries.sql)
   - 4.4 触发器 (triggers.sql)
   - 4.5 索引 (indexes.sql)
   - 4.6 视图 (views.sql)
5. [Web 应用架构](#5-web-应用架构)
6. [知识点总结](#6-知识点总结)

---

## 1. 项目背景与需求分析

### 项目描述

五个知名酒店链（Marriott、Hilton、Holiday Inn、Best Western、Motel 6）希望联合开发一个系统，让顾客可以实时查看房间可用性并进行预订。

### 从需求中提取关键信息

在数据库设计的第一步，需要从文字描述中识别出：

| 需要存储什么？ | 对应的数据库概念 |
|--------------|--------------|
| 酒店链的地址、邮箱、电话 | 实体 + 多值属性 |
| 酒店的房间数、地址 | 实体 |
| 房间的价格、容量、设施 | 实体 + 多值属性 |
| 顾客的姓名、ID 类型 | 实体 |
| 员工的姓名、SSN | 实体 |
| 预订和租赁的历史 | 关系 + 归档需求 |

> **课程知识点（Lecture 7 — ER Model）**：  
> 数据库设计的第一阶段是"需求分析"，目标是完整描述用户的数据需求。  
> 设计分为两个阶段：  
> - **逻辑设计 (Logical Design)**：决定数据库的 Schema（用什么关系、属性怎么分配）  
> - **物理设计 (Physical Design)**：决定数据库在磁盘上的存储布局（索引、文件结构）

---

## 2. 第一阶段：数据规划

### 2.1 ER 模型基础知识

#### 什么是 ER 模型？

ER（Entity-Relationship）模型是数据库设计的核心工具，用图形化方式描述数据的逻辑结构。

> **课程定义（Lecture 7, Slide 7.7）**：  
> "ER 数据模型通过允许指定代表数据库整体逻辑结构的企业模式来促进数据库设计。"

ER 模型由三个基本概念组成：

```
1. 实体集 (Entity Sets)     — 用矩形表示
2. 关系集 (Relationship Sets) — 用菱形表示  
3. 属性   (Attributes)       — 列在实体矩形内
```

#### 属性的类型

| 类型 | 说明 | 本项目例子 |
|------|------|-----------|
| 简单属性 | 不可分割的单一值 | `price`, `full_name` |
| 复合属性 | 可以拆分为子属性 | `address` (street, city, province) |
| 多值属性 | 一个实体可以有多个值 | `{email}`, `{phone}`, `{amenity}` |
| 派生属性 | 可以从其他属性计算得出 | `num_hotels`（可从 HOTEL 计数） |

**多值属性的处理**：  
在 ER 图中用双椭圆表示，转换为关系模式时需要单独建表：

```sql
-- 多值属性 {email} 单独建表
CREATE TABLE CHAIN_EMAIL (
    chain_id  INTEGER REFERENCES HOTEL_CHAIN(chain_id),
    email     VARCHAR(100),
    PRIMARY KEY (chain_id, email)
);
```

---

### 2.2 识别实体与属性

根据需求描述，我们识别出以下实体集：

#### HOTEL_CHAIN（酒店链）
```
HotelChain(chain_id, chain_name, central_office_address, category, num_hotels, {email}, {phone})
```
- `chain_id`：主键（PK），自增整数
- `category`：1-5 星级，域约束 `BETWEEN 1 AND 5`
- `{email}`, `{phone}`：多值属性，单独建表

#### HOTEL（酒店）
```
Hotel(hotel_id, chain_id, address, area, num_rooms, {email}, {phone})
```
- `chain_id`：外键 → HOTEL_CHAIN（参照完整性）
- `area`：城市/区域，用于 View 1 的查询

#### ROOM（房间）
```
Room(room_id, hotel_id, price, capacity, view_type, extendable, problems_or_damages, {amenity})
```
- `capacity`：域约束，只能是 `single/double/triple/quad/suite`
- `problems_or_damages`：NULL 表示无损坏

#### CUSTOMER（顾客）
```
Customer(customer_id, full_name, address, id_type, id_value, registration_date)
```
- `id_type`：域约束 `IN ('SSN', 'SIN', 'DRIVER_LICENSE')`
- `(id_type, id_value)`：唯一约束，防止重复注册

#### EMPLOYEE（员工）
```
Employee(employee_id, hotel_id, full_name, address, ssn_sin)
```
- `ssn_sin`：唯一约束，每个员工的社会保险号唯一

#### ROLE（角色）& BOOKING（预订）& RENTING（租赁）
```
Role(role_id, role_name)
Booking(booking_id, customer_id, room_id, start_date, end_date, created_at)
Renting(renting_id, customer_id, room_id, employee_id, booking_id, start_date, end_date, checkin_time)
```

---

### 2.3 识别关系与基数

> **课程知识点（Lecture 7, Slide 7.16-7.20）**：  
> 基数约束（Mapping Cardinality）表示一个实体可以通过关系集与多少个另一实体相关联：
> - **一对一 (1:1)**：用有向线（→）表示
> - **一对多 (1:N)**：一端有向线，多端无向线
> - **多对多 (M:N)**：两端都是无向线

本项目的关系与基数：

| 关系 | 实体1 | 实体2 | 基数 | 说明 |
|------|-------|-------|------|------|
| belongs_to | HOTEL | HOTEL_CHAIN | N:1 | 多个酒店属于一个链 |
| has_room | ROOM | HOTEL | N:1 | 多个房间属于一个酒店 |
| works_at | EMPLOYEE | HOTEL | N:1 | 多个员工在一个酒店 |
| manages | HOTEL_MANAGER | HOTEL↔EMPLOYEE | 1:1 | 每个酒店有且只有一个经理 |
| has_role | EMPLOYEE_ROLE | EMPLOYEE↔ROLE | M:N | 员工可以有多个角色 |
| makes | BOOKING | CUSTOMER↔ROOM | M:N | 顾客可以预订多个房间 |
| converts_to | RENTING | BOOKING | 1:0..1 | 一个预订最多转换为一个租赁 |

#### 关系基数的 SQL 实现

**1:1 关系**（每个酒店只有一个经理）：
```sql
CREATE TABLE HOTEL_MANAGER (
    hotel_id    INTEGER PRIMARY KEY,      -- hotel_id 是 PK，保证每个酒店只有一条记录
    employee_id INTEGER UNIQUE,           -- UNIQUE 保证一个员工只能管理一个酒店
    FOREIGN KEY (hotel_id) REFERENCES HOTEL(hotel_id),
    FOREIGN KEY (employee_id) REFERENCES EMPLOYEE(employee_id)
);
```

**M:N 关系**（员工可以有多个角色）：
```sql
CREATE TABLE EMPLOYEE_ROLE (
    employee_id INTEGER REFERENCES EMPLOYEE(employee_id),
    role_id     INTEGER REFERENCES ROLE(role_id),
    PRIMARY KEY (employee_id, role_id)    -- 复合主键防止重复
);
```

---

### 2.4 弱实体与特殊设计决策

#### 归档设计（Archive Tables）

项目要求：即使顾客或房间被删除，历史预订/租赁记录仍需保存。

这是一个典型的**数据保留（Data Retention）**问题。解决方案是使用**快照（Snapshot）**：

```sql
CREATE TABLE BOOKING_ARCHIVE (
    booking_id          INTEGER PRIMARY KEY,
    customer_snapshot   TEXT NOT NULL,   -- JSON 格式存储顾客信息快照
    room_snapshot       TEXT NOT NULL,   -- JSON 格式存储房间信息快照
    hotel_snapshot      TEXT NOT NULL,
    start_date          DATE NOT NULL,
    end_date            DATE NOT NULL,
    archived_at         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

**为什么用 JSON 快照而不是外键？**  
因为外键要求被引用的记录必须存在（参照完整性）。如果顾客被删除，`customer_id` 外键就失效了。用 JSON 快照保存了删除时刻的完整信息，独立于原始数据存在。

#### 预订 → 租赁的转换设计

```sql
CREATE TABLE RENTING (
    renting_id  SERIAL PRIMARY KEY,
    booking_id  INTEGER UNIQUE NULL   -- NULL = walk-in，UNIQUE = 一个预订最多一个租赁
        REFERENCES BOOKING(booking_id) ON DELETE SET NULL,
    ...
);
```

- `booking_id = NULL`：walk-in 直接租赁（没有预订）
- `booking_id UNIQUE`：保证每个预订最多只转换为一个租赁（用户自定义约束 #3）

---

### 2.5 ER → 关系模式转换

> **课程知识点（Lecture 3, Slide 2.43）**：  
> "实体集和关系集可以统一表示为关系模式，代表数据库的内容。符合 ER 图的数据库可以用一组关系模式来表示。"

**转换规则**：

| ER 元素 | 转换为关系模式的规则 |
|---------|-------------------|
| 强实体集 | 每个实体集 → 一张表，属性 → 列，主键保留 |
| 弱实体集 | 表 + 所有者实体的主键作为外键 |
| 1:N 关系 | 将"1"端的主键作为外键放入"N"端的表 |
| M:N 关系 | 创建独立的关联表，包含两边的主键 |
| 多值属性 | 创建独立的表，原实体主键 + 属性值 = 复合主键 |
| 1:1 关系 | 将任意一方的主键放入另一方作为外键（本项目选择独立表） |

**本项目的完整关系模式**：

```
HOTEL_CHAIN(chain_id PK, chain_name, central_office_address, category, num_hotels)
CHAIN_EMAIL(chain_id PK FK→HOTEL_CHAIN, email PK)
CHAIN_PHONE(chain_id PK FK→HOTEL_CHAIN, phone PK)
HOTEL(hotel_id PK, chain_id FK→HOTEL_CHAIN, address, area, num_rooms)
HOTEL_EMAIL(hotel_id PK FK→HOTEL, email PK)
HOTEL_PHONE(hotel_id PK FK→HOTEL, phone PK)
ROOM(room_id PK, hotel_id FK→HOTEL, price, capacity, view_type, extendable, problems_or_damages)
ROOM_AMENITY(room_id PK FK→ROOM, amenity PK)
CUSTOMER(customer_id PK, full_name, address, id_type, id_value, registration_date)
EMPLOYEE(employee_id PK, hotel_id FK→HOTEL, full_name, address, ssn_sin)
ROLE(role_id PK, role_name)
EMPLOYEE_ROLE(employee_id PK FK→EMPLOYEE, role_id PK FK→ROLE)
HOTEL_MANAGER(hotel_id PK FK→HOTEL, employee_id UNIQUE FK→EMPLOYEE)
BOOKING(booking_id PK, customer_id FK→CUSTOMER, room_id FK→ROOM, start_date, end_date, created_at)
RENTING(renting_id PK, customer_id FK→CUSTOMER, room_id FK→ROOM, employee_id FK→EMPLOYEE, booking_id UNIQUE NULL FK→BOOKING, start_date, end_date, checkin_time)
BOOKING_ARCHIVE(booking_id PK, customer_snapshot, room_snapshot, hotel_snapshot, start_date, end_date, archived_at)
RENTING_ARCHIVE(renting_id PK, customer_snapshot, room_snapshot, hotel_snapshot, employee_snapshot, start_date, end_date, archived_at)
```

---

## 3. 完整性约束

> **课程知识点（Lecture 3, Slide 2.35）**：  
> 结构约束分为两类：
> 1. **固有约束（Inherent）**：键约束、参照完整性
> 2. **显式约束（Explicit）**：域约束、属性约束、用户自定义约束

### 3.1 主键约束（Primary Key）

主键保证实体完整性：每个元组都可以被唯一标识，且不为 NULL。

```sql
-- 简单主键（单属性）
CREATE TABLE HOTEL_CHAIN (
    chain_id SERIAL PRIMARY KEY,   -- SERIAL = 自动递增整数
    ...
);

-- 复合主键（多属性）
CREATE TABLE EMPLOYEE_ROLE (
    employee_id INTEGER,
    role_id     INTEGER,
    PRIMARY KEY (employee_id, role_id)   -- 两个属性合在一起唯一
);
```

> **课程知识点（Lecture 3, Slide 2.37）**：  
> "关系模式 R 中的主键 PK 在关系 r(R) 的元组中不能有 NULL 值：`t[PK] ≠ NULL`"

### 3.2 参照完整性（外键约束）

外键保证引用的实体确实存在，防止"悬空引用"。

```sql
-- 基本外键
hotel_id INTEGER NOT NULL
    REFERENCES HOTEL(hotel_id)
    ON DELETE CASCADE    -- 酒店删除时，其所有房间也自动删除
```

**ON DELETE 的三种策略**：

| 策略 | 说明 | 本项目使用场景 |
|------|------|--------------|
| `CASCADE` | 父记录删除时，子记录也删除 | HOTEL → ROOM（房间必须属于酒店） |
| `SET NULL` | 父记录删除时，外键设为 NULL | RENTING.booking_id（预订删除后租赁仍保留） |
| `RESTRICT` | 有子记录时禁止删除父记录 | HOTEL_MANAGER.employee_id（不能删除经理） |

**本项目所有外键**：

```sql
FK(HOTEL.chain_id)          → HOTEL_CHAIN.chain_id    ON DELETE CASCADE
FK(ROOM.hotel_id)           → HOTEL.hotel_id           ON DELETE CASCADE
FK(EMPLOYEE.hotel_id)       → HOTEL.hotel_id           ON DELETE CASCADE
FK(BOOKING.customer_id)     → CUSTOMER.customer_id     ON DELETE CASCADE
FK(BOOKING.room_id)         → ROOM.room_id             ON DELETE CASCADE
FK(RENTING.customer_id)     → CUSTOMER.customer_id     ON DELETE CASCADE
FK(RENTING.room_id)         → ROOM.room_id             ON DELETE CASCADE
FK(RENTING.employee_id)     → EMPLOYEE.employee_id     ON DELETE RESTRICT
FK(RENTING.booking_id)      → BOOKING.booking_id       ON DELETE SET NULL
FK(EMPLOYEE_ROLE.employee_id) → EMPLOYEE.employee_id  ON DELETE CASCADE
FK(EMPLOYEE_ROLE.role_id)   → ROLE.role_id             ON DELETE CASCADE
```

### 3.3 域与属性约束

使用 `CHECK` 约束限制属性值的合法范围：

```sql
-- 星级只能是 1-5
category INTEGER NOT NULL
    CHECK (category BETWEEN 1 AND 5)

-- 价格必须为正数
price NUMERIC(10,2) NOT NULL
    CHECK (price > 0)

-- 容量只能是固定几个值
capacity VARCHAR(20) NOT NULL
    CHECK (capacity IN ('single', 'double', 'triple', 'quad', 'suite'))

-- 视野类型
view_type VARCHAR(20) NOT NULL DEFAULT 'none'
    CHECK (view_type IN ('sea', 'mountain', 'city', 'none'))

-- 日期顺序
CHECK (start_date < end_date)

-- ID 类型
id_type VARCHAR(20) NOT NULL
    CHECK (id_type IN ('SSN', 'SIN', 'DRIVER_LICENSE'))
```

### 3.4 用户自定义约束

这是本项目最有挑战性的部分，涉及跨元组的业务规则。

#### 约束1：每个酒店必须有且只有一个经理

通过 `HOTEL_MANAGER` 表的结构来实现：
- `hotel_id` 是主键 → 保证每个酒店最多一条记录（at most one）
- 触发器保证每个酒店至少有一条记录（at least one）

```sql
CREATE TABLE HOTEL_MANAGER (
    hotel_id    INTEGER PRIMARY KEY,   -- at most one per hotel
    employee_id INTEGER UNIQUE,        -- one employee can manage at most one hotel
    ...
);
```

#### 约束2：同一房间不能有重叠预订

这是日期区间重叠问题。两个区间 [s1, e1] 和 [s2, e2] 重叠的条件是：
`s1 < e2 AND e1 > s2`

用触发器实现（见 4.4 节）。

#### 约束3：一个预订最多转换为一个租赁

用 `UNIQUE` 约束实现：

```sql
booking_id INTEGER UNIQUE NULL   -- UNIQUE 保证最多一个 RENTING 引用同一个 BOOKING
```

---

## 4. 第二阶段：数据库实现

### 4.1 DDL 实现 (schema.sql)

DDL（Data Definition Language）是用来定义数据库结构的 SQL 语句。

> **课程知识点（Lecture 5, Slide 3.6）**：  
> SQL 关系使用 `CREATE TABLE` 命令定义：
> ```sql
> CREATE TABLE r (A1 D1, A2 D2, ..., An Dn,
>                 integrity-constraint1, ..., integrity-constraintk)
> ```

**完整的 HOTEL_CHAIN 表创建示例**：

```sql
CREATE TABLE HOTEL_CHAIN (
    chain_id                SERIAL          PRIMARY KEY,
    chain_name              VARCHAR(100)    NOT NULL,
    central_office_address  VARCHAR(255)    NOT NULL,
    category                INTEGER         NOT NULL
                                            CHECK (category BETWEEN 1 AND 5),
    num_hotels              INTEGER         NOT NULL DEFAULT 0
                                            CHECK (num_hotels >= 0)
);
```

**数据类型选择**：

| 类型 | 说明 | 使用场景 |
|------|------|---------|
| `SERIAL` | 自动递增整数 | 主键 ID |
| `INTEGER` | 32 位整数 | 外键、计数 |
| `VARCHAR(n)` | 可变长度字符串，最多 n 字符 | 名字、地址 |
| `TEXT` | 无限长度字符串 | JSON 快照 |
| `NUMERIC(10,2)` | 精确小数，10位总精度，2位小数 | 价格 |
| `BOOLEAN` | 布尔值 | `extendable` |
| `DATE` | 日期（无时间） | `start_date`, `end_date` |
| `TIMESTAMP` | 日期 + 时间 | `created_at`, `checkin_time` |

**DROP TABLE 的顺序**：

必须按照外键依赖的**逆序**删除表（先删依赖方，再删被依赖方）：

```sql
-- 先删引用其他表的表
DROP TABLE IF EXISTS RENTING_ARCHIVE;
DROP TABLE IF EXISTS BOOKING_ARCHIVE;
DROP TABLE IF EXISTS RENTING;
DROP TABLE IF EXISTS BOOKING;
-- ...
-- 最后删被引用的表
DROP TABLE IF EXISTS HOTEL_CHAIN;
```

---

### 4.2 数据填充 (populate.sql)

数据填充使用 `INSERT INTO` 语句：

```sql
-- 基本插入语法
INSERT INTO HOTEL_CHAIN (chain_name, central_office_address, category, num_hotels)
VALUES ('Marriott International', '7750 Wisconsin Ave, Bethesda, MD', 5, 8);

-- 批量插入（多行）
INSERT INTO HOTEL (chain_id, address, area, num_rooms) VALUES
  (1, '541 Lexington Ave, New York, NY', 'New York', 8),
  (1, '1285 Avenue of Americas, New York, NY', 'New York', 8),
  (1, '900 W Georgia St, Vancouver, BC', 'Vancouver', 8);
```

**本项目数据规模**：

| 表 | 行数 | 说明 |
|----|------|------|
| HOTEL_CHAIN | 5 | 5 个酒店链，1-5 星级 |
| HOTEL | 40 | 每个链 8 家酒店，覆盖 14+ 城市 |
| ROOM | 200 | 每家酒店 5 间，5 种不同容量 |
| CUSTOMER | 10 | 测试顾客数据 |
| EMPLOYEE | 45 | 每家酒店至少 1 个员工 |
| BOOKING | 10 | 测试预订记录 |
| RENTING | 5 | 4 个从预订转换 + 1 个 walk-in |

---

### 4.3 SQL 查询 (queries.sql)

#### 基本查询结构

> **课程知识点（Lecture 5, Slide 3.11）**：
> ```sql
> SELECT A1, A2, ..., An
> FROM   r1, r2, ..., rm
> WHERE  P
> ```
> - `Ai`：要查询的属性（列）
> - `ri`：关系（表）
> - `P`：谓词（条件）

#### 查询1：房间可用性搜索（使用 NOT EXISTS 嵌套子查询）

```sql
SELECT R.room_id, R.price, R.capacity, H.area, HC.chain_name
FROM ROOM R
JOIN HOTEL H        ON R.hotel_id = H.hotel_id
JOIN HOTEL_CHAIN HC ON H.chain_id = HC.chain_id
WHERE H.area = 'New York'
  AND R.problems_or_damages IS NULL
  -- 嵌套子查询：不存在重叠的预订
  AND NOT EXISTS (
        SELECT 1 FROM BOOKING B
        WHERE B.room_id    = R.room_id
          AND B.start_date < '2026-05-07'   -- 预订开始 < 查询结束
          AND B.end_date   > '2026-05-01'   -- 预订结束 > 查询开始
  )
  AND NOT EXISTS (
        SELECT 1 FROM RENTING RT
        WHERE RT.room_id    = R.room_id
          AND RT.start_date < '2026-05-07'
          AND RT.end_date   > '2026-05-01'
  );
```

> **课程知识点（Lecture 5, Slide 3.38-3.39）**：  
> SQL 提供嵌套子查询机制。子查询是嵌套在另一个查询中的 `SELECT-FROM-WHERE` 表达式。  
> `NOT EXISTS` 测试子查询结果是否为空——如果为空（不存在重叠预订），条件为真。

**日期重叠判断逻辑**：

```
区间1: [start1, end1]
区间2: [start2, end2]

重叠条件: start1 < end2 AND end1 > start2

理解方式:
- 不重叠 = 区间1在区间2之前 OR 区间1在区间2之后
- 区间1在区间2之前: end1 <= start2
- 区间1在区间2之后: start1 >= end2
- 取反（重叠）: NOT(end1 <= start2 OR start1 >= end2)
              = end1 > start2 AND start1 < end2
```

#### 查询2：聚合查询（GROUP BY + HAVING）

```sql
-- 每个酒店链在每个城市的房间统计
SELECT
    HC.chain_name,
    H.area,
    COUNT(R.room_id)    AS total_rooms,
    AVG(R.price)        AS avg_price,
    MIN(R.price)        AS min_price,
    MAX(R.price)        AS max_price
FROM ROOM R
JOIN HOTEL H        ON R.hotel_id = H.hotel_id
JOIN HOTEL_CHAIN HC ON H.chain_id = HC.chain_id
GROUP BY HC.chain_name, H.area   -- 按链和城市分组
HAVING COUNT(R.room_id) > 2;     -- 只显示有超过2间房的组合
```

> **课程知识点（Lecture 5, Slide 3.35）**：  
> 在 `SELECT` 子句中，聚合函数之外的属性必须出现在 `GROUP BY` 列表中。  
> `HAVING` 子句对分组后的结果进行过滤（类似 `WHERE` 但作用于组）。

**聚合函数总览**：

| 函数 | 说明 | 例子 |
|------|------|------|
| `COUNT(*)` | 统计行数 | `COUNT(*) AS total` |
| `COUNT(attr)` | 统计非 NULL 值的行数 | `COUNT(booking_id)` |
| `SUM(attr)` | 求和 | `SUM(price)` |
| `AVG(attr)` | 求平均值 | `AVG(price)` |
| `MIN(attr)` | 求最小值 | `MIN(price)` |
| `MAX(attr)` | 求最大值 | `MAX(price)` |

#### 查询3：嵌套查询（IN / NOT IN）

```sql
-- 找出有预订但从未实际入住的顾客
SELECT C.customer_id, C.full_name
FROM CUSTOMER C
WHERE C.customer_id IN (
    SELECT DISTINCT customer_id FROM BOOKING   -- 有预订的顾客
)
AND C.customer_id NOT IN (
    SELECT DISTINCT customer_id FROM RENTING   -- 没有租赁的顾客
);
```

#### 查询4：FROM 子句中的子查询（派生表）

```sql
-- 找出平均价格高于全体平均的酒店
SELECT H.hotel_id, H.area, HC.chain_name, AVG(R.price) AS avg_booked_price
FROM BOOKING B
JOIN ROOM  R  ON B.room_id  = R.room_id
JOIN HOTEL H  ON R.hotel_id = H.hotel_id
JOIN HOTEL_CHAIN HC ON H.chain_id = HC.chain_id
GROUP BY H.hotel_id, H.area, HC.chain_name
HAVING AVG(R.price) > (
    SELECT AVG(price) FROM ROOM   -- 标量子查询：返回单个值
);
```

> **课程知识点（Lecture 5, Slide 3.52）**：  
> SQL 允许在 `FROM` 子句中使用子查询表达式（派生表）：
> ```sql
> SELECT dept_name, avg_salary
> FROM (SELECT dept_name, AVG(salary) AS avg_salary
>       FROM instructor
>       GROUP BY dept_name)
> WHERE avg_salary > 42000;
> ```

---

### 4.4 触发器 (triggers.sql)

> **课程知识点（Lecture 10, Additional Material）**：  
> 触发器的通用格式：
> ```sql
> CREATE TRIGGER <name>
> BEFORE | AFTER | INSTEAD OF <event>
> [REFERENCING clause]
> [FOR EACH ROW]
> [WHEN <condition>]
> <action>
> ```
> 其中 `<event>` 可以是：`INSERT ON R`, `DELETE ON R`, `UPDATE OF A ON R`

#### 触发器1：防止重复预订（核心业务规则）

```sql
-- 触发器函数
CREATE OR REPLACE FUNCTION check_no_overlapping_booking()
RETURNS TRIGGER AS $$
BEGIN
    -- 检查是否与现有预订重叠
    IF EXISTS (
        SELECT 1 FROM BOOKING
        WHERE room_id    = NEW.room_id           -- 同一房间
          AND booking_id <> COALESCE(NEW.booking_id, -1)  -- 不是自己（UPDATE 时）
          AND start_date  < NEW.end_date         -- 现有预订开始 < 新预订结束
          AND end_date    > NEW.start_date        -- 现有预订结束 > 新预订开始
    ) THEN
        RAISE EXCEPTION 'Room % is already booked between % and %.',
            NEW.room_id, NEW.start_date, NEW.end_date;
    END IF;

    -- 同样检查租赁
    IF EXISTS (
        SELECT 1 FROM RENTING
        WHERE room_id    = NEW.room_id
          AND start_date  < NEW.end_date
          AND end_date    > NEW.start_date
    ) THEN
        RAISE EXCEPTION 'Room % is already rented between % and %.',
            NEW.room_id, NEW.start_date, NEW.end_date;
    END IF;

    RETURN NEW;  -- 允许操作继续
END;
$$ LANGUAGE plpgsql;

-- 将函数绑定到触发器
CREATE TRIGGER trg_no_double_booking
BEFORE INSERT OR UPDATE ON BOOKING   -- 在插入或更新之前触发
FOR EACH ROW                         -- 每行执行一次
EXECUTE FUNCTION check_no_overlapping_booking();
```

**触发器执行流程**：
```
用户执行 INSERT INTO BOOKING ...
    ↓
触发器 trg_no_double_booking 启动（BEFORE INSERT）
    ↓
check_no_overlapping_booking() 函数执行
    ↓
检查是否有重叠预订
    ↓ 有重叠           ↓ 无重叠
RAISE EXCEPTION     RETURN NEW
（事务回滚）        （允许 INSERT 继续）
```

#### 触发器2：预订删除时自动归档

```sql
CREATE OR REPLACE FUNCTION archive_deleted_booking()
RETURNS TRIGGER AS $$
DECLARE
    v_customer_snap TEXT;
    v_room_snap     TEXT;
    v_hotel_snap    TEXT;
BEGIN
    -- 捕获顾客信息快照（删除前的状态）
    SELECT INTO v_customer_snap
        json_build_object(
            'customer_id', C.customer_id,
            'full_name',   C.full_name,
            'id_type',     C.id_type,
            'id_value',    C.id_value
        )::TEXT
    FROM CUSTOMER C WHERE C.customer_id = OLD.customer_id;

    -- 捕获房间和酒店快照
    SELECT INTO v_room_snap, v_hotel_snap
        json_build_object('room_id', R.room_id, 'price', R.price, ...)::TEXT,
        json_build_object('hotel_id', H.hotel_id, 'area', H.area, ...)::TEXT
    FROM ROOM R
    JOIN HOTEL H ON R.hotel_id = H.hotel_id
    WHERE R.room_id = OLD.room_id;

    -- 写入归档表
    INSERT INTO BOOKING_ARCHIVE (booking_id, customer_snapshot, ...)
    VALUES (OLD.booking_id, v_customer_snap, ...);

    RETURN OLD;  -- AFTER DELETE 触发器，返回 OLD
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_archive_booking
AFTER DELETE ON BOOKING    -- 在删除之后触发（此时数据已删除）
FOR EACH ROW
EXECUTE FUNCTION archive_deleted_booking();
```

**NEW 和 OLD 的区别**：

| 变量 | 说明 | 适用操作 |
|------|------|---------|
| `NEW` | 新插入或更新后的行 | INSERT, UPDATE |
| `OLD` | 被删除或更新前的行 | DELETE, UPDATE |

#### 触发器3&4：自动同步计数器

```sql
-- 当房间增减时，自动更新酒店的 num_rooms
CREATE OR REPLACE FUNCTION sync_hotel_num_rooms()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE HOTEL SET num_rooms = num_rooms + 1
        WHERE hotel_id = NEW.hotel_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE HOTEL SET num_rooms = num_rooms - 1
        WHERE hotel_id = OLD.hotel_id;
    END IF;
    RETURN NULL;   -- AFTER 触发器的返回值被忽略
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_sync_num_rooms
AFTER INSERT OR DELETE ON ROOM
FOR EACH ROW
EXECUTE FUNCTION sync_hotel_num_rooms();
```

---

### 4.5 索引 (indexes.sql)

> **课程知识点（Lecture 9, Slide 11.2）**：  
> "索引机制用于加速对所需数据的访问，类似于图书馆的目录。  
> 搜索键（Search Key）是用来在文件中查找记录的属性或属性集。"

#### 为什么需要索引？

没有索引时，查询需要**全表扫描（Sequential Scan）**：
```
查询: SELECT * FROM BOOKING WHERE room_id = 5
→ 读取 BOOKING 表的每一行，检查 room_id 是否等于 5
→ 如果有 100万 条记录，需要读取 100万 次
```

有索引时，查询使用 **B+ 树查找**：
```
查询: SELECT * FROM BOOKING WHERE room_id = 5
→ 在 B+ 树中查找 room_id = 5 的叶节点
→ 直接定位到记录，只需 log(N) 次操作
→ 100万 条记录只需约 20 次比较
```

#### B+ 树索引原理

> **课程知识点（Lecture 9, Slide 11.57-11.60）**：  
> B+ 树的优点：
> - 自动重组，不需要周期性文件重组
> - 插入和删除的时间代价小
> - 所有路径从根到叶等长，查询稳定

```
B+ 树结构示例（以 room_id 为搜索键）：

                    [20 | 40]
                   /    |    \
            [5|10|15] [25|30|35] [45|50|55]
                ↓         ↓          ↓
            实际记录    实际记录    实际记录
```

#### SQL 创建索引

```sql
-- 语法（Lecture 9, Slide 11.156）
CREATE INDEX <index-name> ON <relation>(<attributes>);

-- 本项目的索引
-- 索引1：按城市搜索酒店（最常用的查询条件）
CREATE INDEX idx_hotel_area
ON HOTEL (area);

-- 索引2：预订日期范围查询（触发器和可用性检查使用）
CREATE INDEX idx_booking_room_dates
ON BOOKING (room_id, start_date, end_date);

-- 索引3：租赁日期范围查询
CREATE INDEX idx_renting_room_dates
ON RENTING (room_id, start_date, end_date);

-- 索引4：房间多条件搜索
CREATE INDEX idx_room_hotel_capacity_price
ON ROOM (hotel_id, capacity, price);

-- 索引5：按酒店查找员工
CREATE INDEX idx_employee_hotel
ON EMPLOYEE (hotel_id);
```

#### 主索引 vs 辅助索引

> **课程知识点（Lecture 9, Slide 11.4）**：
> - **主索引（Primary Index）**：搜索键指定文件的顺序排列方式，也叫聚簇索引
> - **辅助索引（Secondary Index）**：搜索键指定与文件顺序不同的顺序，也叫非聚簇索引

本项目的索引都是**辅助索引**（表已按 PK 排序，索引建在其他属性上）。辅助索引必须是**密集索引（Dense Index）**——每个搜索键值都有对应的索引记录。

#### 索引的代价权衡

```
优点：
✓ 大幅加速 SELECT 查询
✓ 对频繁过滤、JOIN、ORDER BY 的列效果最好

代价：
✗ 每次 INSERT/UPDATE/DELETE 都需要更新索引
✗ 占用额外磁盘空间
✗ 对写多读少的表可能得不偿失
```

---

### 4.6 视图 (views.sql)

> **课程知识点（Lecture 4/6, Slide 6.87）**：  
> "视图是一个虚拟关系，对用户可见，但实际上并不存在于数据库中。  
> 视图的定义意味着创建并维护了一个表达式，在执行时替换使用它的查询。"

```sql
-- 视图定义语法
CREATE VIEW v AS <query expression>
```

#### View 1：每个区域的可用房间数

```sql
CREATE OR REPLACE VIEW view_available_rooms_per_area AS
SELECT
    H.area,
    COUNT(R.room_id)    AS available_rooms,
    MIN(R.price)        AS min_price,
    MAX(R.price)        AS max_price,
    AVG(R.price)        AS avg_price
FROM ROOM R
JOIN HOTEL H ON R.hotel_id = H.hotel_id
WHERE
    R.problems_or_damages IS NULL          -- 无损坏
    AND NOT EXISTS (                        -- 今天没有预订
        SELECT 1 FROM BOOKING B
        WHERE B.room_id = R.room_id
          AND B.start_date <= CURRENT_DATE
          AND B.end_date   >= CURRENT_DATE
    )
    AND NOT EXISTS (                        -- 今天没有租赁
        SELECT 1 FROM RENTING RT
        WHERE RT.room_id = R.room_id
          AND RT.start_date <= CURRENT_DATE
          AND RT.end_date   >= CURRENT_DATE
    )
GROUP BY H.area
ORDER BY available_rooms DESC;
```

**使用视图**：
```sql
-- 使用视图就像使用普通表一样
SELECT * FROM view_available_rooms_per_area;
SELECT * FROM view_available_rooms_per_area WHERE area = 'New York';
```

#### View 2：指定酒店的房型容量汇总

```sql
CREATE OR REPLACE VIEW view_hotel_room_capacity AS
SELECT
    H.hotel_id,
    H.address           AS hotel_address,
    H.area,
    HC.chain_name,
    HC.category         AS hotel_stars,
    R.capacity,
    COUNT(R.room_id)    AS num_rooms_of_capacity,
    AVG(R.price)        AS avg_price_for_capacity
FROM ROOM R
JOIN HOTEL H        ON R.hotel_id = H.hotel_id
JOIN HOTEL_CHAIN HC ON H.chain_id = HC.chain_id
GROUP BY H.hotel_id, H.address, H.area, HC.chain_name, HC.category, R.capacity
ORDER BY H.hotel_id, R.capacity;

-- 查询特定酒店的房型分布
SELECT * FROM view_hotel_room_capacity WHERE hotel_id = 1;
```

**视图 vs 实际表的区别**：

| 特征 | 视图（View） | 实际表（Table） |
|------|------------|----------------|
| 数据存储 | 不存储数据，存储查询定义 | 存储实际数据 |
| 更新 | 复杂（有限制） | 直接更新 |
| 性能 | 每次查询都执行底层查询 | 直接访问数据 |
| 用途 | 简化复杂查询、安全控制 | 存储持久数据 |

---

## 5. Web 应用架构

### 技术栈

```
前端：Next.js 14 (React 18) + Tailwind CSS
后端：Next.js API Routes (Node.js)
数据库：PostgreSQL 16
驱动：pg (node-postgres)
```

### 系统架构图

```
浏览器（用户界面）
        ↕ HTTP 请求
Next.js API Routes（后端）
        ↕ SQL 查询
PostgreSQL（数据库）
```

### 用户角色与功能

#### 顾客（Customer）视图

```
/search          → 搜索可用房间（按区域、日期、容量、价格、星级）
/customer/bookings → 查看我的预订，可以取消
```

搜索逻辑（API 代码）：
```javascript
// pages/api/rooms/available.js
const result = await query(`
    SELECT R.room_id, R.price, R.capacity, H.area, HC.chain_name
    FROM ROOM R
    JOIN HOTEL H        ON R.hotel_id = H.hotel_id
    JOIN HOTEL_CHAIN HC ON H.chain_id = HC.chain_id
    WHERE H.area = $1                    -- 参数化查询，防止 SQL 注入
      AND R.capacity = $2
      AND R.price <= $3
      AND NOT EXISTS (...)               -- 可用性检查
`, [area, capacity, maxPrice]);
```

#### 员工（Employee）视图

```
/employee/bookings  → 查看所有待处理预订，点击 Check In 转换为租赁
/employee/rentings  → 查看当前租赁，记录付款
/employee/customers → 顾客完整 CRUD（增删改查）
```

**Check In 流程**（预订 → 租赁）：
```javascript
// 点击 Check In 按钮
POST /api/rentings
{
    customer_id: 1,
    room_id: 5,
    employee_id: 2,
    booking_id: 3,      // 从哪个预订转换
    start_date: "2026-04-10",
    end_date: "2026-04-15"
}

// SQL 执行
INSERT INTO RENTING (customer_id, room_id, employee_id, booking_id, start_date, end_date)
VALUES ($1, $2, $3, $4, $5, $6)
```

### API 设计（RESTful）

| HTTP 方法 | 路径 | 说明 |
|-----------|------|------|
| GET | `/api/rooms/available` | 搜索可用房间 |
| GET | `/api/bookings` | 获取预订列表 |
| POST | `/api/bookings` | 创建预订（触发防重叠触发器） |
| DELETE | `/api/bookings/:id` | 取消预订（触发归档触发器） |
| GET | `/api/rentings` | 获取租赁列表 |
| POST | `/api/rentings` | 创建租赁（walk-in 或从预订转换） |
| GET | `/api/customers` | 获取顾客列表 |
| POST | `/api/customers` | 新增顾客 |
| PUT | `/api/customers/:id` | 修改顾客信息 |
| DELETE | `/api/customers/:id` | 删除顾客 |
| GET | `/api/views/available-per-area` | 查询 View 1 |
| GET | `/api/views/hotel-capacity` | 查询 View 2 |

---

## 6. 知识点总结

### 本项目涉及的所有课程知识点

| 知识点 | 对应 Lecture | 在项目中的体现 |
|--------|------------|--------------|
| 实体集与属性 | Lecture 7 (ER) | 7 个主要实体：HotelChain, Hotel, Room... |
| 多值属性 | Lecture 7 (ER) | {email}, {phone}, {amenity} → 独立表 |
| 关系集与基数 | Lecture 7 (ER) | 1:N (Hotel-Room), M:N (Employee-Role) |
| 弱实体集 | Lecture 7 (ER) | Room 不能独立于 Hotel 存在 |
| ER → 关系模式转换 | Lecture 3 | 17 张表的完整模式设计 |
| 主键约束 | Lecture 3 | 所有表的 PRIMARY KEY 定义 |
| 参照完整性（外键） | Lecture 3 | CASCADE/SET NULL/RESTRICT |
| 域和属性约束 | Lecture 5 (SQL) | CHECK (category BETWEEN 1 AND 5) |
| CREATE TABLE | Lecture 5 (SQL) | schema.sql 中所有 DDL |
| INSERT/UPDATE/DELETE | Lecture 5 (SQL) | populate.sql + 应用层 API |
| SELECT + JOIN | Lecture 5 (SQL) | queries.sql 中所有查询 |
| 聚合（GROUP BY/HAVING） | Lecture 5 (SQL) | Query 2, 4 |
| 嵌套子查询 | Lecture 5 (SQL) | NOT EXISTS, IN/NOT IN, 标量子查询 |
| 触发器 (TRIGGER) | Lecture 10 | 5 个触发器：归档、防重复、计数同步 |
| 视图 (VIEW) | Lecture 4/6 | 4 个视图，其中 2 个是必须的 |
| 索引 (INDEX) | Lecture 9 | 5 个 B+ 树索引 |
| B+ 树原理 | Lecture 9 | 所有索引底层结构 |
| 主索引 vs 辅助索引 | Lecture 9 | 项目中均为辅助（非聚簇）索引 |

### SQL 语句速查

```sql
-- DDL（数据定义）
CREATE TABLE t (col1 type CONSTRAINTS, ...);
DROP TABLE IF EXISTS t;
ALTER TABLE t ADD COLUMN col type;

-- DML（数据操作）
INSERT INTO t (col1, col2) VALUES (v1, v2);
UPDATE t SET col1 = v1 WHERE condition;
DELETE FROM t WHERE condition;

-- DQL（数据查询）
SELECT col1, AGG(col2)
FROM t1 JOIN t2 ON t1.id = t2.fk
WHERE condition
GROUP BY col1
HAVING AGG(col2) > value
ORDER BY col1 DESC
LIMIT n;

-- 约束
PRIMARY KEY (col)
FOREIGN KEY (col) REFERENCES other_table(col) ON DELETE CASCADE
CHECK (condition)
NOT NULL
UNIQUE
DEFAULT value

-- 触发器（PostgreSQL）
CREATE OR REPLACE FUNCTION fn() RETURNS TRIGGER AS $$
BEGIN
    -- NEW = 新行, OLD = 旧行
    -- TG_OP = 'INSERT' | 'UPDATE' | 'DELETE'
    RETURN NEW;  -- 或 RETURN OLD（DELETE 时）
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER t AFTER INSERT ON table
FOR EACH ROW EXECUTE FUNCTION fn();

-- 视图
CREATE VIEW v AS SELECT ...;
SELECT * FROM v;

-- 索引
CREATE INDEX idx ON table (col1, col2);
DROP INDEX idx;
```

---

> **文档结束**  
> 本文档涵盖了 CSI2132 eHotels 项目从需求分析、ER 设计、关系模式设计、SQL 实现到 Web 应用的完整过程，并结合课程 Lecture 2/3/5/7/9/10 的核心知识点进行了深入讲解。
