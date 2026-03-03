Assignment 1 – CSI 2132 Databases I  
Relational Algebra and Relational Calculus  

## 1. 作业要求汇总（根据 `assignment_1_2026.pdf`）

- **Exercise 1 (15%)**：在给定模式  
  - `Store (storeid, sname, employee_number, city)`  
  - `Product (pid, pname, price)`  
  - `Supply (storeid, pid)`  
  上，用关系代数表达以下查询：  
  - **1.A (3%)**：找到员工少于 100 人或位于城市 'Ottawa' 的商店的 `storeid`。  
  - **1.B (4%)**：找到供应商品名为 'pencil' 的产品的商店的 `sname`。  
  - **1.C (8%)**：找到所有商店的 `sname` 和城市，这些商店供应的所有产品都包含由 `storeid = '0808'` 的商店所供应的全部产品。  

- **Exercise 2 (30%)**：在给定模式  
  - `Employee(eid, cid, salary, managerid)`  
  - `Company(cid, companyname, location)`  
  - `Shares(eid, cid, sharenum)`  
  上，用关系代数表达以下查询：  
  - **2.A (6%)**：找到那些在公司名为 'Google' 工作，且在公司名为 'Facebook' 中拥有超过 500 股股份的员工 `eid`。  
  - **2.B (6%)**：找到所有员工的 `eid`，这些员工的经理在员工所在公司拥有股份。  
  - **2.C (9%)**：找到拥有至少 3 家不同公司股份的员工 `eid`（不允许使用聚合）。  
  - **2.D (9%)**：找到在数据库中所有公司都拥有股份的员工 `eid`（不允许使用聚合）。  

- **Exercise 3 (30%)**：在给定模式  
  - `Supplier(supplier-id, name, city)`  
  - `Store(store-id, sname, city)`  
  - `Product(barcode, pname, price, itsshoes, itsabag, color, supplier-id)`  
  - `Has_stock(store-id, barcode, quantity)`  
  上，用关系代数表达以下查询：  
  - **3.A (9%)**：找到拥有至少 2 种不同黑色包设计的商店名称 `sname`（不使用聚合）。  
  - **3.B (7%)**：找到商店名为 'LaFollie' 中，所有鞋类产品的 `price`。  
  - **3.C (7%)**：找到供应超过 5 个不同条形码产品的供应商名称 `name`（可以使用聚合）。  
  - **3.D (7%)**：找到同时由 `store-id = '1'` 和 `store-id = '2'` 售卖的产品条形码 `barcode`（不能使用交集算子）。  

- **Exercise 4 (25%)**：在与 Exercise 3 相同的模式上，用元组关系演算（tuple relational calculus）表达以下查询：  
  - **4.A (3%)**：找到价格高于 40 的产品（整行元组）。  
  - **4.B (5%)**：找到所有价格高于 40 的产品的条形码 `barcode`。  
  - **4.C (7%)**：找到在 `store-id = '1'` 中销售但在 `store-id = '2'` 中不销售的产品条形码 `barcode`。  
  - **4.D (10%)**：找到在城市为 'Ottawa' 的所有商店中都被销售的产品条形码 `barcode`。  

下面给出完整解答（关系代数与元组关系演算表达式）。  

---

## 2. Exercise 1 – Relational Algebra 解答

**给定模式**：  
- `Store (storeid, sname, employee_number, city)`  
- `Product (pid, pname, price)`  
- `Supply (storeid, pid)`  

### 1.A （3%）

**要求**：找到员工少于 100 人或位于城市 'Ottawa' 的商店的 `storeid`。  

**关系代数表达式**：  
\[
\pi_{\text{storeid}}\bigl(
  \sigma_{\text{employee\_number} < 100 \;\lor\; \text{city} = 'Ottawa'}(\text{Store})
\bigr)
\]

### 1.B （4%）

**要求**：找到供应商品名为 'pencil' 的产品的商店名称 `sname`。  

**关系代数表达式**：  
\[
\pi_{\text{sname}}\bigl(
  \text{Store} \bowtie_{\text{Store.storeid} = \text{Supply.storeid}}
  (\text{Supply} \bowtie_{\text{Supply.pid} = \text{Product.pid}}
    \sigma_{\text{pname} = 'pencil'}(\text{Product})
  )
\bigr)
\]

### 1.C （8%）

**要求**：找到所有商店的名称 `sname` 和所在城市 `city`，这些商店供应的所有产品都包含由 `storeid = '0808'` 的商店所供应的全部产品。  

设  
\[
R(\text{storeid}, \text{pid}) = \text{Supply}
\]
\[
P(\text{pid}) = \pi_{\text{pid}}(\sigma_{\text{storeid} = '0808'}(\text{Supply}))
\]

则“供应至少包含 `P` 所有产品的商店”的 `storeid` 可用商除表示为：  
\[
T(\text{storeid}) = R \div P
\]

完整表达式（使用除法定义形式）：  
\[
T = \pi_{\text{storeid}}(R)
  - \pi_{\text{storeid}}\Bigl(
      (\pi_{\text{storeid}}(R) \times P - R)
    \Bigr)
\]

最终结果为这些商店的 `sname` 和 `city`：  
\[
\pi_{\text{sname}, \text{city}}\bigl(
  \text{Store} \bowtie_{\text{Store.storeid} = T.\text{storeid}} T
\bigr)
\]

---

## 3. Exercise 2 – Relational Algebra 解答

**给定模式**：  
- `Employee(eid, cid, salary, managerid)`  
- `Company(cid, companyname, location)`  
- `Shares(eid, cid, sharenum)`  

### 2.A （6%）

**要求**：找到那些在公司名为 'Google' 工作，且在公司名为 'Facebook' 中拥有超过 500 股股份的员工 `eid`。  

设  
\[
E = \text{Employee}, \quad C = \text{Company}, \quad S = \text{Shares}
\]

**在 Google 工作的员工**：  
\[
E_G = \sigma_{\text{companyname} = 'Google'}(E \bowtie_{E.\text{cid} = C.\text{cid}} C)
\]

**在 Facebook 拥有超过 500 股的员工**：  
\[
E_F = \pi_{E.\text{eid}}\bigl(
  \sigma_{\text{companyname} = 'Facebook' \land \text{sharenum} > 500}
  (S \bowtie_{S.\text{cid} = C.\text{cid}} C)
\bigr)
\]

**同时满足两条件的员工 `eid`**：  
\[
\pi_{E_G.\text{eid}}\bigl(
  E_G \bowtie_{E_G.\text{eid} = E_F.\text{eid}} E_F
\bigr)
\]

可简写成一个表达式：  
\[
\pi_{E.\text{eid}}\Bigl(
  \sigma_{\substack{
    C_1.\text{companyname} = 'Google' \\
    \land\ C_2.\text{companyname} = 'Facebook' \\
    \land\ S.\text{sharenum} > 500
  }}
  \bigl(
    E \bowtie_{E.\text{cid} = C_1.\text{cid}} \rho_{C_1}(C)
      \bowtie_{E.\text{eid} = S.\text{eid}}
      (S \bowtie_{S.\text{cid} = C_2.\text{cid}} \rho_{C_2}(C))
  \bigr)
\Bigr)
\]

### 2.B （6%）

**要求**：找到所有员工的 `eid`，这些员工的经理在员工所在公司拥有股份。  

设  
\[
E_1 = \rho_{E_1}(\text{Employee}),\quad
E_2 = \rho_{E_2}(\text{Employee}),\quad
S = \text{Shares}
\]

约束条件：  
- `E1.managerid = E2.eid`（E2 是 E1 的经理）  
- `E2.eid = S.eid`（经理在某公司有股份）  
- `E1.cid = S.cid`（该公司就是 E1 工作的公司）  

**关系代数表达式**：  
\[
\pi_{E_1.\text{eid}}\bigl(
  \sigma_{E_1.\text{managerid} = E_2.\text{eid}
        \land E_2.\text{eid} = S.\text{eid}
        \land E_1.\text{cid} = S.\text{cid}}
  (E_1 \times E_2 \times S)
\bigr)
\]

### 2.C （9%）

**要求**：找到拥有至少 3 家不同公司股份的员工 `eid`（不允许使用聚合）。  

思路：对 `Shares` 做三次重命名，自连接，要求同一员工在三条记录中对应不同的公司 `cid`。  

设  
\[
S_1 = \rho_{S_1}(\text{Shares}),\quad
S_2 = \rho_{S_2}(\text{Shares}),\quad
S_3 = \rho_{S_3}(\text{Shares})
\]

条件：  
- \(S_1.\text{eid} = S_2.\text{eid} = S_3.\text{eid}\)  
- \(S_1.\text{cid} \neq S_2.\text{cid}\), \(S_1.\text{cid} \neq S_3.\text{cid}\), \(S_2.\text{cid} \neq S_3.\text{cid}\)  

**关系代数表达式**：  
\[
\pi_{S_1.\text{eid}}\bigl(
  \sigma_{S_1.\text{eid} = S_2.\text{eid}
        \land S_1.\text{eid} = S_3.\text{eid}
        \land S_1.\text{cid} \neq S_2.\text{cid}
        \land S_1.\text{cid} \neq S_3.\text{cid}
        \land S_2.\text{cid} \neq S_3.\text{cid}}
  (S_1 \times S_2 \times S_3)
\bigr)
\]

### 2.D （9%）

**要求**：找到在数据库中所有公司都拥有股份的员工 `eid`（不允许使用聚合）。  

设  
\[
R(\text{eid}, \text{cid}) = \pi_{\text{eid}, \text{cid}}(\text{Shares}),\quad
C(\text{cid}) = \pi_{\text{cid}}(\text{Company})
\]

我们需要所有在 \(R\) 中，对每个公司 \(C\) 都有至少一条股份记录的员工 `eid`，即：  
\[
\pi_{\text{eid}}(R \div C)
\]

若展开除法定义：  
\[
T = \pi_{\text{eid}}(R)
  - \pi_{\text{eid}}\Bigl(
      (\pi_{\text{eid}}(R) \times C - R)
    \Bigr)
\]

结果为：  
\[
\pi_{\text{eid}}(T)
\]

---

## 4. Exercise 3 – Relational Algebra 解答

**给定模式**：  
- `Supplier(supplier-id, name, city)`  
- `Store(store-id, sname, city)`  
- `Product(barcode, pname, price, itsshoes, itsabag, color, supplier-id)`  
- `Has_stock(store-id, barcode, quantity)`  

### 3.A （9%）

**要求**：找到拥有至少 2 种不同黑色包设计的商店名称 `sname`（不使用聚合）。  

思路：用两份 `Product` 和两份 `Has_stock` 的自连接，约束为同一商店、不同条形码、都是黑色包。  

设  
\[
P_1 = \rho_{P_1}(\text{Product}),\quad
P_2 = \rho_{P_2}(\text{Product})
\]
\[
H_1 = \rho_{H_1}(\text{Has\_stock}),\quad
H_2 = \rho_{H_2}(\text{Has\_stock})
\]

条件：  
- 同一商店：\(H_1.\text{store-id} = H_2.\text{store-id}\)  
- 不同产品：\(H_1.\text{barcode} \neq H_2.\text{barcode}\)  
- 连接到产品：\(H_1.\text{barcode} = P_1.\text{barcode}\), \(H_2.\text{barcode} = P_2.\text{barcode}\)  
- 都是包且为黑色：  
  - \(P_1.\text{itsabag} = 'yes' \land P_1.\text{color} = 'black'\)  
  - \(P_2.\text{itsabag} = 'yes' \land P_2.\text{color} = 'black'\)  

**关系代数表达式**：  
\[
\pi_{\text{sname}}\Bigl(
  \sigma_{\substack{
    P_1.\text{itsabag} = 'yes' \land P_1.\text{color} = 'black' \\
    \land\ P_2.\text{itsabag} = 'yes' \land P_2.\text{color} = 'black' \\
    \land\ H_1.\text{store-id} = H_2.\text{store-id} \\
    \land\ H_1.\text{barcode} = P_1.\text{barcode} \\
    \land\ H_2.\text{barcode} = P_2.\text{barcode} \\
    \land\ H_1.\text{barcode} \neq H_2.\text{barcode}
  }}
  \bigl(
    \text{Store} \bowtie_{\text{Store.store-id} = H_1.\text{store-id}}
    (H_1 \times H_2 \times P_1 \times P_2)
  \bigr)
\Bigr)
\]

### 3.B （7%）

**要求**：找到商店名为 'LaFollie' 中，所有鞋类产品的价格 `price`。  

**关系代数表达式**：  
\[
\pi_{\text{price}}\bigl(
  \sigma_{\text{sname} = 'LaFollie' \land \text{itsshoes} = 'yes'}
  (\text{Store}
    \bowtie_{\text{Store.store-id} = \text{Has\_stock.store-id}} \text{Has\_stock}
    \bowtie_{\text{Has\_stock.barcode} = \text{Product.barcode}} \text{Product})
\bigr)
\]

### 3.C （7%）

**要求**：找到供应超过 5 个不同条形码产品的供应商名称 `name`（可以使用聚合）。  

使用带聚合的关系代数（\(\gamma\) 运算符）：  

先把供应商与产品连接，然后按供应商分组，对不同 `barcode` 计数：  
\[
R = \text{Supplier} \bowtie_{\text{Supplier.supplier-id} = \text{Product.supplier-id}} \text{Product}
\]
\[
G = \gamma_{\text{supplier-id}, \text{name}, \text{city};\ \text{COUNT}(\text{barcode}) \rightarrow \text{prodcount}}(R)
\]

筛选 `prodcount > 5`，再投影出供应商名称：  
\[
\pi_{\text{name}}\bigl(
  \sigma_{\text{prodcount} > 5}(G)
\bigr)
\]

### 3.D （7%）

**要求**：找到同时由 `store-id = '1'` 和 `store-id = '2'` 售卖的产品条形码 `barcode`（不能使用交集算子）。  

思路：通过对 `Has_stock` 做两次重命名并在 `barcode` 上连接来模拟交集。  

设  
\[
H_1 = \rho_{H_1}(\text{Has\_stock}),\quad
H_2 = \rho_{H_2}(\text{Has\_stock})
\]

**关系代数表达式**：  
\[
\pi_{H_1.\text{barcode}}\bigl(
  \sigma_{H_1.\text{store-id} = '1'
        \land H_2.\text{store-id} = '2'
        \land H_1.\text{barcode} = H_2.\text{barcode}}
  (H_1 \times H_2)
\bigr)
\]

---

## 5. Exercise 4 – Tuple Relational Calculus 解答

**给定模式**：  
- `Supplier(supplier-id, name, city)`  
- `Store(store-id, sname, city)`  
- `Product(barcode, pname, price, itsshoes, itsabag, color, supplier-id)`  
- `Has_stock(store-id, barcode, quantity)`  

下面使用元组关系演算（tuple relational calculus），记 `Product(p)` 表示元组 `p` 属于关系 `Product`，类似地 `Store(s)`、`Has_stock(h)` 等。  

### 4.A （3%）

**要求**：找到价格高于 40 的产品（整个产品元组）。  

**TRC 表达式**：  
\[
\{\, p \mid \text{Product}(p) \land p.\text{price} > 40 \,\}
\]

### 4.B （5%）

**要求**：找到所有价格高于 40 的产品的条形码 `barcode`。  

**TRC 表达式**：  
\[
\{\, b \mid \exists p\ (\text{Product}(p) \land p.\text{price} > 40 \land b = p.\text{barcode}) \,\}
\]

### 4.C （7%）

**要求**：找到在 `store-id = '1'` 中销售但在 `store-id = '2'` 中不销售的产品条形码 `barcode`。  

可以只基于 `Has_stock` 来写：  

**TRC 表达式**：  
\[
\{\, b \mid
  \exists h_1\ (\text{Has\_stock}(h_1)
          \land h_1.\text{store-id} = '1'
          \land b = h_1.\text{barcode}
          \land \neg\exists h_2\ (\text{Has\_stock}(h_2)
                           \land h_2.\text{store-id} = '2'
                           \land h_2.\text{barcode} = h_1.\text{barcode}))
\,\}
\]

### 4.D （10%）

**要求**：找到在城市为 'Ottawa' 的所有商店中都被销售的产品条形码 `barcode`。  

**TRC 表达式**：  
\[
\{\, b \mid
  \exists p\bigl(
    \text{Product}(p) \land b = p.\text{barcode}
    \land
    \forall s\bigl(
      \text{Store}(s) \land s.\text{city} = 'Ottawa'
      \rightarrow
      \exists h\bigl(
        \text{Has\_stock}(h)
        \land h.\text{store-id} = s.\text{store-id}
        \land h.\text{barcode} = p.\text{barcode}
      \bigr)
    \bigr)
  \bigr)
\,\}
\]

---

## 6. 使用 RelaX 工具的小提示

根据 `RELAX.pdf`：  
- 网站：`https://dbis-uibk.github.io/relax/calc/local/uibk/local/0`  
- 在页面中：  
  - 进入 **Group Editor**，将提供的 `query.txt` 内容全部粘贴进去；  
  - 点击 **Preview**，再点击 **use group in editor**；  
  - 确认当前数据库模式已变为 `Store, Product, Supply`；  
  - 之后在 “Relational Algebra” 标签页中输入本文件中给出的关系代数表达式（需要按网站支持的具体符号作适当语法转换，例如将选择记作 `sigma_{...}` 等）。  

你可以把本文件作为作业解题参考，同时根据授课老师在 CSI 2132 课程大纲中的符号约定，对符号（例如选择、投影、连接、除法的写法）做格式上的微调。

