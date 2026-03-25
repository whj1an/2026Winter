### CSI 2101 – Discrete Structures  
### Lecture 1 Notes – Propositions, Quantifiers, and Satisfiability

> These notes summarize `26L01.pdf` and add extra examples.  
> 说明：下面主要用英语记笔记，每个知识点后会用中文做详细讲解，帮助理解。

---

### 1. Motivating Example – Proving Optimality

**Car relocation story**

- Fred runs a rental car company with offices in 5 cities on a line: Alphaville (A), Beantown (B), Catcity (C), Dogburg (D), Elmoland (E).
- At the end of the week he has a certain **stock** of cars in each city, and he needs to satisfy **requests** for early next week.
- Moving a car from one town to an adjacent town costs \$100 (gas + driver). Moving 2 hops costs \$200, etc.
- Fred proposes a plan to move cars between cities. We can sketch:
  - Current stock in each city
  - Required cars in each city
  - Arrows showing how many cars move between which cities and how many hops

We can **improve** Fred’s initial plan by “uncrossing” some of the arrows so total cost goes down from \$1400 to \$1200.  
But then a natural question arises:

> How do we know that \$1200 is really the **minimum possible** cost?

**Idea for the proof**

- Look at the line of cities from A to E.
- At A: there are 3 cars, but only 2 are needed, so **at least 1** car must leave A no matter what plan we use → cost at least \$100 on the edge between A and B.
- At A + B together: there are 4 cars available but 6 are needed → at least 2 cars must **enter** from C or beyond → cost at least \$200 on the edge between B and C.
- Continuing this kind of reasoning, we can show **lower bounds** on how much must be spent on each road segment (A–B, B–C, C–D, D–E).
- Summing these lower bounds gives total cost **at least \$1200**, so no plan can be cheaper than \$1200.

So we have:

- Fred’s improved plan costs \$1200 (an **upper bound**).
- Logical reasoning about necessary movements gives a **lower bound** of \$1200.
- Therefore \$1200 is **optimal**.

（中文讲解：  
这个租车例子用来说明“证明”的核心思想：不仅要找到一个可行方案（比如 1200 美元），还要证明“任何方案都不可能比它更便宜”。老师通过对每一段公路必须经过的最少车辆数进行推理，得出每一条边的最低费用，再把这些最低费用加起来，得到一个全局下界 1200 美元。  
一旦你找到一个方案恰好达到这个下界，就能证明它是**最优解**。这是离散数学和算法中经常出现的思路：用逻辑推理给出“下界/上界”，从而证明最优性。）

---

### 2. What Is a Proof?

**Proof (informal idea)**

- A **proof** is a sequence of **clear logical deductions** that start from known truths (axioms, definitions, already proven results) and end at the statement we want to show.
- In the car example, the statement is:

> “No matter how Fred moves cars, he must spend **at least \$1200**.”

- The reasoning about cars leaving/entering networks of cities gives a step-by-step logical argument, which convinces us—and Fred—that this statement is true.

（中文讲解：  
证明并不是“我感觉这是对的”，而是“从已知事实，通过一步一步严格的逻辑推理，推出结论”。  
车的例子就是一个证明：我们先分析每一段路的必须费用（这些是逻辑推理的中间步骤），最后推出“总费用必须 ≥ 1200”，再结合我们已经找到一个 1200 的方案，得到“1200 是最优”。  
在本课程里，证明能力非常关键：不仅要算对，还要能说明**为什么一定对**。）

---

### 3. Propositions and Logical Operators

#### 3.1 Propositions

- A **proposition** is a statement that is either **true** or **false** (no ambiguity).
  - Example (true): `1 + 1 = 2`
  - Example (false): `1 + 1 = 3`

Logic’s job: determine whether a proposition is **true or false** with certainty.

（中文讲解：  
命题就是“要么真，要么假”的陈述句，没有“可能”、“大概”这种不确定性。比如“1+1=2”显然为真，“1+1=3”显然为假。这一章里我们会用符号和规则，把命题的真假研究得非常系统。）

#### 3.2 Axiomatic method

- For simple propositions, truth may be **self-evident**.
- For harder ones, we use the **axiomatic method**:
  - Start with basic propositions that are “obviously true” → **axioms**.
  - Apply **logical rules** to deduce truth values of more complex propositions.

（中文讲解：  
“公理化方法”就是：先选一批大家都同意的“显然为真”的命题作为公理，然后通过逻辑规则推出其他命题的真假。计算机科学中许多系统（比如程序语言、形式化验证）都依赖这种思想。）

#### 3.3 Logical operators and truth tables

We can build **new propositions** from old ones using logical operators.

Let `P`, `Q` be propositions. Common operators:

- **not** (`¬P` or `not P`)
- **and** (`P ∧ Q` or `P and Q`)
- **or** (`P ∨ Q` or `P or Q`)
- **xor** (exclusive or)
- **iff** (“if and only if”)

**Negation (not)**

Truth table:

- If `P` is true (`T`), then `not P` is false (`F`).
- If `P` is false (`F`), then `not P` is true (`T`).

| P | not P |
|---|-------|
| T | F     |
| F | T     |

（中文讲解：  
`not` 就是否定，和日常语言一致：“不是 P”。只有当 P 为真时，`not P` 为假；当 P 为假时，`not P` 为真。）

**Conjunction (and)**

- `P and Q` is **true** only when **both** `P` and `Q` are true.

| P | Q | P and Q |
|---|---|---------|
| T | T | T       |
| T | F | F       |
| F | T | F       |
| F | F | F       |

（中文讲解：  
`P and Q` 表示“P 且 Q”，只有两者都为真时才为真，其余情况都为假。）

**Inclusive disjunction (or)**

- In mathematics, `P or Q` is **inclusive**:
  - true if **at least one** of `P`, `Q` is true.

| P | Q | P or Q |
|---|---|--------|
| T | T | T      |
| T | F | T      |
| F | T | T      |
| F | F | F      |

Note: This is different from common English like “beer or wine” (often **exclusive**).

（中文讲解：  
数学里的 `or` 是**包含性或**：只要有一个真就整体为真，两个都真也算真。  
这和日常语言的“你可以点啤酒或者红酒（只能选一个）”不同，日常里往往指“互斥或”。）

**Exclusive or (xor)**

- `P xor Q` means exactly one of `P`, `Q` is true (but not both).

| P | Q | P xor Q |
|---|---|---------|
| T | T | F       |
| T | F | T       |
| F | T | T       |
| F | F | F       |

（中文讲解：  
`xor` 是“异或/互斥或”，只在“恰好一个为真”时为真。这更接近日常生活里“要么 A，要么 B，但不能都有”的说法。）

**Logical equivalence (iff)**

- `P iff Q` means “P if and only if Q” → they always have the **same truth value**.

| P | Q | P iff Q |
|---|---|---------|
| T | T | T       |
| T | F | F       |
| F | T | F       |
| F | F | T       |

We say `P` and `Q` are **logically equivalent** if `P iff Q` is always true.

（中文讲解：  
`P iff Q` 表示“P 当且仅当 Q”，意思是：P 和 Q 始终同真同假。证明两个命题等价，经常就是证明 `P iff Q` 为真。）

**Expressing xor using and/or/not**

- Every compound proposition can be expressed using just `and`, `or`, `not`.
- Example:
  - `P xor Q` is logically equivalent to `((not P) and Q) or (P and (not Q))`.

（中文讲解：  
即使有很多种逻辑算子（xor, iff 等），其实理论上只需要 `and/or/not` 就够了，其他都能用它们组合表示。比如 `xor` 就是“(P 为假且 Q 为真) 或 (P 为真且 Q 为假)”。这对构造逻辑电路和证明等价式非常重要。）

**Extra practice example**

1. Let `P`: “It is raining.”, `Q`: “I have an umbrella.”  
   - Write the proposition “It is not raining or I have an umbrella” using operators.  
   - Answer: `not P or Q`.
2. Decide whether `not (P and Q)` is logically equivalent to `(not P) or (not Q)`.  
   - Hint: This is one of **De Morgan’s laws**.

（中文讲解练习提示：  
第 1 小题关键是把自然语言准确翻成符号。  
第 2 小题可以通过真值表验证四种可能情况，体会德摩根律的作用，这是后面推理时很常用的等价变换。）

---

### 4. Predicates and Quantifiers

#### 4.1 Predicates

- A **predicate** is like a proposition but with one or more **free variables**.
  - Example: “n is even” is a predicate about integers, with free variable `n`.
    - True for `n = 2`, false for `n = 3`.
  - Example: `n = 2 × m` is a predicate with two free variables `n`, `m`.

We can imagine a **table of truth values** for predicates:

- For “n is even”: each integer gets `T` or `F`.  
- For `n = 2 × m`: we have a 2D table indexed by `n` and `m`.

（中文讲解：  
命题里没有变量，一说就是整体真或假；谓词里带有变量，比如“n 是偶数”。只有给定具体的 n 值，这个陈述才变成一个命题（真或假）。你可以想象一个无限的真值表，每个 n 对应一格 T/F。  
两个变量的谓词（如 `n = 2 × m`）就像二维表：行是 n，列是 m，每个格子写真或假。）

#### 4.2 Turning predicates into propositions: quantifiers

We get **propositions** from predicates by applying **quantifiers**.

- **Universal quantifier**: “for all” – symbol `∀`.
  - Example: `For all n, n is even` → proposition (actually false).
- **Existential quantifier**: “there exists” – symbol `∃`.
  - Example: `There exists an n such that n is even` → true (e.g., `n = 2`).

Example rewrite:

- “10 is even” can be written as:
  - `There exists an m such that 10 = 2 × m` → true because `m = 5`.
- “For all numbers n, n is even”:
  - `For all n there exists an m such that n = 2 × m` → false.

（中文讲解：  
量词就是“把带变量的谓词变成完整命题”的工具。  
`∀`（for all）表示“对所有…都成立”；`∃`（there exists）表示“至少存在一个…使得成立”。  
比如“所有整数都是偶数”是假的，因为只要找到一个反例（如 n=1）就能推翻。  
而“存在一个整数是偶数”则是真的，因为 2 就是一个例子。）

#### 4.3 Order of quantifiers matters

Consider the predicate `n = 2 × m`. Compare:

1. `For all n there exists an m such that n = 2 × m` → asks: “Is every row in the table containing some `T`?” → **false**.
2. `For all m there exists an n such that n = 2 × m` → asks: “Does every column contain some `T`?” → **true** (take `n = 2m`).
3. `There exists an n such that for all m, n = 2 × m` → asks: “Is there a row full of `T`s?” → **false**.

So changing variable names and especially the **order of quantifiers** dramatically changes the meaning.

（中文讲解：  
量词顺序非常敏感：`∀n ∃m` 和 `∃m ∀n` 意义完全不同。  
可以结合表格来记忆：  
- `∀n ∃m`：每一行都要有一个 T。  
- `∃m ∀n`：要有一列全是 T。  
在写数学命题时，量词顺序错一个，就会变成完全不同甚至错误的陈述，这是考试中常见坑点。）

---

### 5. The Implies Operator (→)

The **implies** operator (`P → Q`) captures “If P then Q”.

Truth table:

| P | Q | P → Q |
|---|---|-------|
| T | T | T     |
| T | F | F     |
| F | T | T     |
| F | F | T     |

Key observation:

- When `P` is **false**, `P → Q` is always **true**, regardless of `Q`.
  - Example: `1 + 1 = 3 → 1 + 1 = 2` is true.
  - Example: `1 + 1 = 3 → 1 + 1 = 4` is also true.

Intuition: A **false premise** can “promise” anything; the implication is not violated.

（中文讲解：  
很多同学第一次看到“前件为假就整体为真”会觉得很反直觉。  
可以这样理解：命题“如果 P 则 Q”是一个“承诺”：只要 P 发生，我就保证 Q 发生。如果 P 根本没发生，那么这个承诺没有被违背——无论 Q 怎样，不能算你说谎，因此视为真。  
在形式逻辑和程序规范中，这个定义非常重要。）

**Using → with predicates**

Example proposition:

1. Informal: “Every even number is the sum of two odd numbers.”
2. Let `n` be an integer. Then formally:
   - `For every n, (n is even) → (n is the sum of two odd numbers).`
3. Expand with definitions:
   - `For every n, (∃m: n = 2 × m) → (∃a, b: n = a + b and ∃c: a = 2 × c + 1 and ∃d: b = 2 × d + 1).`

These three formulations are logically equivalent but at **different levels of detail**.

（中文讲解：  
这三个版本表达的是同一个命题：  
1）自然语言最简洁，适合讨论和提问。  
2）用蕴含和谓词表示，适合做案例分析和逻辑推理。  
3）展开所有定义，虽然最精确，但可读性差，多用于形式化验证工具中。  
在学习中，要练习在脑中自由切换这几种层次：既能说人话，也能写符号表达。）

**Extra practice example**

Let `P(n)`: “n is even”, `Q(n)`: “n is a multiple of 4”.  

- Write “Every multiple of 4 is even” as a quantified implication.  
  - Answer: `For all n, Q(n) → P(n)`.
- Is the converse true: “Every even number is a multiple of 4”? Explain.

（中文讲解练习提示：  
第一个命题用“若 n 是 4 的倍数，则 n 是偶数”即可。  
反命题是假的，只要给出反例即可，比如 n=2 是偶数却不是 4 的倍数。用蕴含时，一定注意**方向**代表的是哪种包含关系。）

---

### 6. Translating English to Quantified Logic

We consider a group of people (Alice, Bob, Charlie, ...).  
Predicate `F(x, y)`: “x and y are friends.”

We use:

- `∃` for “there exists”
- `∀` for “for all”

**Example 1 – “Alice has friends.”**

- Formal: `∃x: F(Alice, x).`
- Meaning: There exists someone who is Alice’s friend.

（中文讲解：  
“有朋友” → “存在某个人使得他和 Alice 是朋友”。注意这里不要求知道是谁，只要“至少有一个”就行。）

**Example 2 – “Alice is a friend of a friend of Bob.”**

- At least one person is **both** a friend of Alice and a friend of Bob.
- Formal: `∃x: F(Alice, x) and F(Bob, x).`

（中文讲解：  
“Alice 是 Bob 的朋友的朋友” → 存在某人 x，x 是 Alice 的朋友，同时 x 也是 Bob 的朋友。  
这里没有要求 Alice 和 Bob 直接是朋友，只通过一个中间人连接。）

**Example 3 – “Alice and Bob have the same friends.”**

- Anyone who is a friend of Alice is a friend of Bob, and vice versa.
- Formal: `∀x: F(Alice, x) iff F(Bob, x).`

（中文讲解：  
这句话的精确含义是：“对任意一个人 x，他是 Alice 的朋友当且仅当他是 Bob 的朋友。”  
用 `iff` 表示“两边要么都真，要么都假”，刚好对应“朋友集合相同”的概念。）

**Example 4 – “Everyone has a friend.” vs “Someone is everyone’s friend.”**

- “Everyone has a friend”: `∀x ∃y: F(x, y).`
- “Someone in the group is everyone’s friend”: `∃y ∀x: F(x, y).`

（中文讲解：  
`∀x ∃y`：每个人至少有一个朋友，但这个朋友可以因人而异。  
`∃y ∀x`：存在一个“超级社交牛人” y，他是所有人的朋友。量词位置一换，语义差很多。）

**Example 5 – “Alice has no friends.” and “Alice has exactly one friend.”**

- “Alice has no friends”:
  - `not ∃x: F(Alice, x).`
- “Alice has exactly one friend”:
  - Part 1: “At least one friend”: `∃x: F(Alice, x).`
  - Part 2: “At most one friend”:  
    `∀x, y: (F(Alice, x) and F(Alice, y)) → x = y.`
  - Combine:
    - `(∃x: F(Alice, x)) and (∀x, y: (F(Alice, x) and F(Alice, y)) → x = y).`

（中文讲解：  
“正好一个”通常拆成“至少一个”+“至多一个”。  
“至少一个”对应存在量词；  
“至多一个”对应“任意两个如果都是她的朋友，那这两个人其实是同一人”。  
考试题中“exactly one / exactly two”等说法都可以用这种套路来翻译。）

**Remark about notation**

- In textbooks and papers, people **rarely** write out fully formal logic for everything; they prefer clear English.
- However, you must be able to **translate** back and forth to formal notation when needed.

（中文讲解：  
写数学作业或论文时，一般用清晰、精确的英文句子，而不是到处写 `∀, ∃`。但你必须在心里知道，如果要形式化，可以怎么写。这个能力有助于你避免歧义和误解。）

---

### 7. Quantifier Logic – Negation and Instantiation

#### 7.1 Quantifiers and negation

Rule (one variable):

- `not (For every x, P(x))` is equivalent to `There exists an x such that not P(x)`.
- Symbolically: `not (∀x P(x))` ≡ `∃x not P(x)`.

Example:

- “Not every number is greater than 2”  
  ≡ “There exists a number that is not greater than 2.”

For **two quantifiers**:

- Negating a quantified statement **switches** quantifiers and negates the predicate:
  - `not (∀x ∃y: P(x, y))` ≡ `∃x ∀y: not P(x, y)`.

Natural-language examples with a predicate `P(p, t)` meaning “person p is pleased at time t”:

- “You can please some of the people all of the time”  
  - `∃p ∀t: P(p, t).`
  - Negation: `∀p ∃t: not P(p, t)` → “Every person has a time when they are not pleased.”
- “You can please all of the people some of the time”  
  - `∀p ∃t: P(p, t).`
  - Negation: `∃p ∀t: not P(p, t)` → “There is a person who can never be pleased.”
- “You cannot please all the people all the time”  
  - `not ∀p ∀t: P(p, t)` ≡ `∃p ∃t: not P(p, t)`  
  - “At some point, someone is not pleased.”

（中文讲解：  
否定带量词的命题时，有一个重要规则：  
**否定会翻转量词，并且对谓词加 not**。  
例：`not (∀x P(x))` ↔ `∃x not P(x)`；`not (∃x P(x))` ↔ `∀x not P(x)`。  
对于两个量词，就按顺序逐个翻转：`not (∀x ∃y P(x, y))` ↔ `∃x ∀y not P(x, y)`。  
掌握这个规则能帮助你正确写出“某说法的否定”，在证明或反证法中非常关键。）

#### 7.2 Universal instantiation (a reasoning principle)

- If `There exists an x such that for all y, P(x, y)` is true, then `For all y there exists an x such that P(x, y)` is also true.

Example:

- True proposition about the uOttawa schedule:
  - “There is a day of the week when there are no classes.”  
    - `∃d ∀c: class c does not meet on day d.` (e.g., Sunday)
  - From this we can deduce:
    - `∀c ∃d: class c does not meet on day d.`  
    - “For every class, there is a day when it does not meet.”

But the **converse** is not valid:

- “Every class meets on some day” (`∀c ∃d: class c meets on day d`) is true.
- But “There exists a day when every class meets” (`∃d ∀c: class c meets on day d`) is false.

（中文讲解：  
“存在一个 x 对所有 y 成立” ⇒ “对每个 y，都存在一个（也许同一个）x 成立”，这是一个安全的推理规则。  
直观上：如果有一个特别好的 d，使得对所有课程 c 都满足某性质，那么当然对每一门课单独看时，也能找到这样一个 d（就是那个特别好的 d）。  
但反过来不成立：每门课各自都有一个不上课的日子，并不意味着存在一个单独的日子让所有课都不上。）

**Extra practice example**

Try to negate and simplify:

1. `∀x ∃y: P(x, y)`  
2. `∃x ∀y: P(x, y)`

（中文讲解练习提示：  
1）用规则：`not (∀x ∃y P)` → `∃x ∀y not P`。  
2）用规则：`not (∃x ∀y P)` → `∀x ∃y not P`。  
写完后再翻译回自然语言，检查是否有歧义。）

---

### 8. Reasoning About Quantified Propositions

Consider again:

1. “Every even number is the sum of two odd numbers.”

Strategy:

- Identify quantifier: “every even number” → universal quantification.
- Try some examples:
  - `2 = 1 + 1` (both odd) → works.
  - `4 = 3 + 1` (both odd) → works.
  - `0 = 1 + (-1)` (both odd) → works.
- These examples suggest the statement **might be true**, but examples alone are **not enough** to prove it.

We need a **pattern**:

- Any even number `n` can be written as `n = 2k`.
- Then `n = (n - 1) + 1`.  
  - Since `n` is even, `n - 1` is odd.  
  - `1` is odd.  
  - So `n` is sum of two odd numbers → a proof.

Counterexample style:

2. “For every nonnegative number n, n² + n + 41 is prime.”

- Try examples:
  - `n = 0` → `41` (prime)
  - `n = 1` → `43` (prime)
  - `n = 2` → `47` (prime)
  - `n = 10` → `151` (prime)
- But this proposition is actually **false**:
  - For `n = 41`, `41² + 41 + 41` is divisible by 41 → not prime.

So:

- Checking examples is **useful**, but cannot guarantee truth for universally quantified statements.
- If you find **one counterexample**, you can disprove a universal statement.

（中文讲解：  
对“∀n P(n)”这类命题：  
- 想证明它为真：通常要找到一个**通用模式**或**一般证明**，不能只靠有限个例子。  
- 想证明它为假：只需要找到**一个反例**。  
Goldbach 猜想就是一个著名例子：我们已经用计算机检查到非常大的上界，但始终没有严谨证明或反例，所以它仍然是一个开放问题。）

**Goldbach’s Conjecture (open problem)**

- “Every even number greater than 2 is the sum of two primes.”
- Checked by computers up to \(4 \times 10^{18}\), but still unknown in general.

（中文讲解：  
Goldbach 猜想告诉我们：有些关于量词的命题可能极其困难，几十上百年都没人能证明或推翻。离散数学课程不会要求你解决这些难题，但会训练你掌握基本方法。）

---

### 9. Satisfiability and Tautologies (Optional*)

(*Starred in slides: interesting but not exam-critical.)

#### 9.1 Truth tables and scalability

- For a formula built from `n` atomic propositions, the full truth table has \(2^n\) rows.
  - `n = 20` → over 1 million rows.
  - `n = 100` → astronomically large.
- Brute-force truth tables quickly become infeasible.

（中文讲解：  
真值表适合处理 2–3 个变量的小公式，但一旦变量数很多（比如 20、100），`2^n` 行几乎不可能完全枚举。这时我们需要更聪明的算法。）

#### 9.2 Example: checking whether a formula is a tautology

Formula:

- \(\varphi = (P and Q) or (P and R and S) or (Q and S) or (P and S)\).
- We want to know if \(\varphi\) is a **tautology** (always true).

One approach:

- Consider `not ϕ` instead:
  - `not ϕ = (P or Q) and (P or R or S) and (Q or S) and (P or S)` (using De Morgan’s laws).
- If **no assignment** makes `not ϕ` true, then `ϕ` is a tautology.
- If we can find **one satisfying assignment** for `not ϕ`, then `ϕ` is **not** a tautology.

In the slides:

- They analyze cases (`P` true or false, etc.).
- They eventually find an assignment `P = F, Q = T, R = T, S = T` that satisfies `not ϕ`.
- So `ϕ` is **not** a tautology.

（中文讲解：  
判断“是不是永真式”可以转化为“它的否定有没有可满足赋值”。  
如果 `not ϕ` 永远为假（不可满足），那 `ϕ` 就是永真式；  
如果能找到让 `not ϕ` 为真的赋值，那 `ϕ` 就不是永真式。  
这种“从真值表转向可满足性”的视角，在后续算法和逻辑推理非常常见。）

#### 9.3 The SAT (satisfiability) problem

- **Satisfiability problem (SAT)**: Given a propositional formula, find a **satisfying assignment** if one exists, or report “unsatisfiable”.
- SAT is fundamental in many areas of CS:
  - Machine learning
  - Optimization
  - Cryptography
  - Formal verification, etc.
- Real-world formulas may have **thousands or millions** of variables.
- Brute-force is impossible; we use smarter algorithms like **DPLL** and its descendants (e.g., modern SAT solvers).

（中文讲解：  
SAT 问题表面看只是“给你一个逻辑公式，问能不能给变量赋真值让它成立”，但它在很多领域都是核心问题。  
现代 SAT 求解器能处理上百万变量的实例，用在硬件验证、软件验证、规划、排课、密码分析等场景。  
这也是离散数学和逻辑在工程实践中的一个很重要的应用。）

#### 9.4 Eight queens puzzle as SAT

Problem:

- Place 8 queens on a chessboard so that no two attack each other.
- A queen attacks along its row, column, and diagonals.

Encoding as SAT:

- Introduce 64 atomic propositions: `Pa1, ..., Ph8`, one per square.
  - `Pij` means “there is a queen on square (i, j)”.
- Constraints:
  - `ψ_row`: At least one square in each row is occupied.
  - `ψ_col`: At least one square in each column is occupied.
  - `ψ_attack`: If two squares share a row, column, or diagonal, they cannot both have queens.
- Combine:
  - `ψ = ψ_row and ψ_col and ψ_attack`.
- Run a SAT solver on `ψ` → it finds a satisfying assignment → gives a valid configuration of 8 queens.

The slides also show a solution for a 16×16 board using the same idea.

（中文讲解：  
这部分展示了如何把一个经典的“八皇后”棋盘问题转化为 SAT：  
1）为每个格子设一个布尔变量，表示是否放皇后；  
2）用逻辑公式表达“每行至少一皇后”、“每列至少一皇后”、“任意两皇后不互相攻击”；  
3）把这些公式 AND 起来，交给 SAT 求解器。  
求解器给出的可满足赋值就对应一个合法的棋盘布局。  
这说明：很多看似“组合搜索”的难题，都可以统一转化为逻辑可满足问题来求解。）

---

### 10. Summary of Key Concepts (L01)

- **Proofs**: rigorous logical arguments showing that a statement must be true (e.g., the car relocation example).
- **Propositions**: statements with a definite truth value; combined using **and**, **or**, **not**, **xor**, **iff** with truth tables.
- **Predicates and quantifiers**: use `∀` and `∃` to describe properties over domains; order of quantifiers is crucial.
- **Implication (→)**: captures “if … then …”, true whenever the premise is false or both premise and conclusion are true.
- **Translating English ↔ logic**: practice expressing natural statements (friendships, schedules, numbers) using predicates and quantifiers.
- **Negating quantified formulas**: flip quantifiers and negate the predicate (De Morgan-style rules for quantifiers).
- **Reasoning with quantifiers**: examples help build intuition, but proofs (or counterexamples) are needed for certainty.
- **Satisfiability (SAT)**: finding assignments to make formulas true; central in computer science with powerful solver technology.

（中文总评：  
这一讲的核心，是从“动机例子”引出“证明”的重要性，然后系统地搭建逻辑语言：命题、逻辑算子、谓词、量词和蕴含，告诉你如何用精确的逻辑表达复杂的数学和计算机科学问题。最后，通过可满足性和八皇后例子，让你看到这些抽象概念在实际算法和工具中的应用。建议你多做真值表、量词翻译和否定练习，尽快熟悉这些符号和规则。） 

---

### Lecture 2 – Proofs and Proof Strategies

> Here we focus on what a **proof（证明）** is, common **axioms（公理）**, and several standard **proof techniques（证明方法）** like **case analysis（分类讨论）**, **contrapositive（逆否命题）**, **equivalence proofs（等价证明）**, and **proof by contradiction（反证法）**.

---

#### 1. What is a proof?

- In mathematics, a proposition is accepted as true only if there is a **proof**.  
- A **proof** is:
  - A sequence of **logical deductions（逻辑推演）** from **axioms（公理，默认真命题）** and previously proved theorems,
  - Ending in the proposition we want to prove.
- Mathematicians agree on what counts as a valid proof; economists or lawyers may disagree on arguments, but mathematicians rely on strict logic.

（中文讲解：  
这一节强调“只要没证明，就不能当作真的数学事实来用”。证明必须从被认可的公理/已知定理出发，通过形式化的推理步骤，最终得到要证明的命题。关键点是：证明是可检查的，只要训练足够，每个数学家都可以检查别人给的证明是否正确。）

---

#### 2. Example: Theorem about friends and strangers

**Definitions**

- Two people are **friends** if they know each other and have a friendship relation.  
- Two people are **strangers** if they are **not** friends.  
- A **group of friends**: every two people in the group are friends.  
- A **group of strangers**: every two people in the group are strangers.

**Theorem 1 (Ramsey-type statement)**  
Any group of 6 people contains either:

- A group of 3 mutual friends, or  
- A group of 3 mutual strangers.

Proof idea: **case analysis（分类讨论）** on one distinguished person Alice.

- Fix one person, call them **Alice**.  
- Among the remaining 5 people:
  - Some are friends of Alice,
  - Some are strangers to Alice.
- Pigeonhole reasoning: at least one of these two groups has size ≥ 3.

Case 1 – Alice has at least 3 friends.  
- Let this set of friends be `F`.  
- Subcase 1.1: Two people in `F` are friends → together with Alice, they form 3 mutual friends.  
- Subcase 1.2: No two people in `F` are friends → any 3 people in `F` are 3 mutual strangers.

Case 2 – Alice has at least 3 strangers.  
- Let this set be `S`.  
- Subcase 2.1: Two people in `S` are strangers to each other → with Alice, they form 3 mutual strangers.  
- Subcase 2.2: No two people in `S` are strangers → any 3 in `S` are 3 mutual friends.

Because one of the two main cases must hold, and in each case one of the subcases gives the desired configuration, the theorem is proved.

（中文讲解：  
这是一个典型的“拉姆齐”风格命题：规模一旦足够大，就必然出现某种结构（这里是“3 个人互相认识”或“3 个人互相不认识”）。证明方法是**选一个人 Alice，把其他人分成‘朋友组’和‘陌生人组’**，利用抽屉原理得出至少有一组人数 ≥ 3，然后在这一组里再分类讨论。这个例子非常好地展示了**case analysis（分类讨论）**的结构：  
1）划分所有可能情况 C1、C2；  
2）证明“C1 或 C2 一定发生”；  
3）在每个情形里分别推出命题 P；  
4）因此 P 在所有情况下都成立。）

**Axioms implicitly used**

- Axiom 1: Friendship is symmetric（对称） – if `x` is friend with `y`, then `y` is also friend with `x`.  
- Axiom 2: If a group including Alice has 6 people, there are exactly 5 people other than Alice.

（中文补充：  
这里老师强调，我们在证明中总是隐式使用很多“常识”，比如“有 6 个人，其中 1 个叫 Alice，那剩下就是 5 个”等；这些都可以视为公理或之前学过的命题。）

---

#### 3. Case analysis as a deduction rule

Formal rule for **case analysis**:

- Suppose we have propositions `C1`, `C2`, and `P`.  
- If we know:
  - `C1 or C2` (the cases cover all possibilities),  
  - `C1 → P`,  
  - `C2 → P`,  
  - Then we may conclude `P`.

This can be justified by a **truth table（真值表）**: in every row where `C1 or C2` is true, at least one case forces `P` to be true.

（中文讲解：  
很多证明其实都在使用“若在所有可能情况中命题都成立，则命题整体成立”这一逻辑规则。把它用符号写出，就是：  
`(C1 或 C2) 且 (C1→P) 且 (C2→P) ⟹ P`。  
老师让你画真值表，只是想让你相信这个推理规则本身是“sound（可靠）”的，不会从真的前提推出假的结论。）

**Lemma（引理）**

- A **lemma（引理）** is a proposition proved mainly as a tool for proving another theorem.  
- In the slides, the statement “In every group of six people including Alice, Alice is friends with at least three or stranger to at least three” is packaged as **Lemma 2**.

（中文讲解：  
定理（theorem）通常是我们真正关心的主结果；而引理（lemma）是过程中用到的中间结果。写证明时，把复杂问题拆成多个 lemma，再组合起来，是非常常见的结构化写法。）

---

#### 4. Direct proofs with definitions (even/odd)

**Theorem 3** – The sum of two even integers is even.

- Formal statement:  
  - `For all integers m, n, if m is even and n is even, then m + n is even.`
- Definition: **even integer（偶整数）** = number of the form `2k` for some integer `k`.
- Proof pattern:
  1. Assume `m` and `n` are even → `m = 2a`, `n = 2b`.  
  2. Then `m + n = 2a + 2b = 2(a + b)` → also of the form `2×(integer)` → even.

（中文讲解：  
这是“直接证明（direct proof）”的典型模式：  
1）先把“m,n 是偶数”翻译成“m=2a, n=2b”；  
2）做代数运算；  
3）最后再翻译回“结果是偶数”。  
几乎所有关于“偶数/奇数、整除、倍数”的题，都可以通过“把定义写出来”来做。）

**Theorem 4** – The product of two odd integers is odd.

- Definition: **odd integer（奇整数）** = number of the form `2k + 1`.  
- Assume `m = 2a + 1`, `n = 2b + 1`, then:
  - `mn = (2a + 1)(2b + 1) = 2(2ab + a + b) + 1` → odd.

（中文讲解：  
和上一个定理完全平行，只是把“2k”换成“2k+1”。熟悉这两个例子后，你会发现很多考试题都是这两种证明模板的变形。）

**Theorem 5** – If `n` is odd, then `n²` is of the form `8k + 1`.

- Start with `n = 2t + 1`.  
- Compute:
  - `n² = (2t + 1)² = 4t² + 4t + 1 = 4t(t + 1) + 1`.  
- Need to show `4t(t + 1)` is a multiple of 8 → show `t(t + 1)` is even.  
- Factorization trick:
  - `t(t + 1)` → product of two **consecutive integers（相邻整数）** → one must be even → product even.

（中文讲解：  
这个例子展示了“scratch work（草稿推理）”的重要性：  
一开始直接看 `4t²+4t+1` 很难想到是 `8k+1`，于是进行变形、因式分解，最后抓到关键结构 `t(t+1)`——连续整数乘积必为偶数。  
考场上也要学会先在草稿纸上尝试整理，再把最干净的版本写进正式证明。）

---

#### 5. Proof patterns

##### 5.1 Contrapositive（逆否命题）

- For implication `P → Q`, the **contrapositive（逆否命题）** is `not Q → not P`.  
- They are **logically equivalent（逻辑等价）**.

**Theorem 7** – Assume `r ≥ 0`. If `r` is irrational（无理数）, then `√r` is irrational.

- Direct approach (“assume `r` irrational”) is hard to use.  
- Instead, prove the **contrapositive**:
  - If `√r` is rational（有理数）, then `r` is rational.
- Proof: Let `√r = n/d` with integers `n, d`. Then `r = n²/d²`, so `r` is rational.

（中文讲解：  
有些命题用原命题很难下手，因为“假设 r 是无理数”信息太“负面”，不好利用；而逆否命题“假设 √r 是有理数”就可以直接把 √r 写成分数，然后平方得到 r 的有理性。  
经验规则：如果从 P 很难推出 Q，可以试试从“非 Q”推出“非 P”。）

**Lemma 2 revisited with contrapositive**

- Statement:  
  - “In every group of six people including Alice, Alice is friends with at least 3 or stranger to at least 3.”
- Proof by contrapositive:  
  - Assume Alice is friends with at most 2 and stranger to at most 2 → total people ≤ 1 + 2 + 2 = 5 → contradicts “group has 6 people”.

（中文讲解：  
这里利用“至多 2 个朋友、至多 2 个陌生人”推出“总人数 ≤ 5”，从而否定“有 6 个人”的前提。因此原命题成立。  
这显示了反证法和逆否命题技术在计数问题中的常见用法。）

##### 5.2 Proving equivalences（等价证明）

- To prove `P iff Q`, often best to prove **two implications**:
  - `P → Q` and `Q → P`.

**Theorem 8** – For every integer `n`, `n²` is even iff `n` is even.

- Direction 1: If `n` is even → `n = 2k` → `n² = 4k² = 2(2k²)` → even.  
- Direction 2: If `n²` is even → prove contrapositive: if `n` is odd then `n²` is odd  
  - This is exactly Theorem 5’s style.

（中文讲解：  
“当且仅当”命题非常重要：  
1）先证明“若 n 是偶数，则 n² 是偶数”；  
2）再证明“若 n² 是偶数，则 n 是偶数”（通常用逆否命题或反证法）。  
这在数论、算法正确性证明中随处可见。）

##### 5.3 Proof by contradiction（反证法）

- Strategy:
  1. To prove `P`, assume `not P`.  
  2. From `not P`, deduce an impossible statement `F` (比如 1 < 0, 或“同一数既奇又偶”).  
  3. Conclude that the assumption `not P` must be false → `P` true.

**Theorem 9** – `√2` is irrational.

- Assume, for contradiction（为反证起见）, that `√2` is rational: `√2 = n/d` in lowest terms.  
- Square both sides: `2 = n²/d²` → `n² = 2d²`.  
- So `n²` even → `n` even → `n²` multiple of 4 → `2d²` multiple of 4 → `d²` even → `d` even.  
- Thus both `n` and `d` are even → they have a common factor 2, contradicting “in lowest terms”.

（中文讲解：  
经典反证法例子：  
1）用“有理数 = 最简分数”的假设建立代数关系；  
2）用之前证明好的 Theorem 8（n² 偶 ⇒ n 偶）；  
3）推出“n,d 都是偶数”，与“最简分数”矛盾。  
老师也提醒：反证法在逻辑上没问题，但容易在中途混淆“在假设情境下成立”的结论，所以一般当作其它方法都不方便时的“最后手段”。）

---

#### 6. More examples: tables, saddles, sorting

**Saddle（鞍点） in a table**

- Consider a rectangular table of **distinct numbers（互不相同的数）**.  
- A number is a **saddle（saddle point，行最小且列最大的元素）** if:
  - It is the **largest** in its column, and  
  - The **smallest** in its row.

**Theorem 10** – Every table with distinct numbers has at most one saddle.

- Proof by contradiction:
  - Assume there are two saddles `x` and `y`.  
  - Analyze three cases: same row, same column, different row & column.  
  - Each leads to a contradiction with “all numbers are distinct”.

（中文讲解：  
这类题在竞赛和离散课中很多：先给一个看似“图形/数组”的概念（如 saddle），再让你证明“最多一个”“至少一个”等结构性质。  
方法通常是**假设有两个**，再通过行列或坐标比较推出一连串不可能的不等式。）

**Theorem 11** – Sorting rows then columns keeps rows sorted.

- Start from a table with **sorted rows（每行从小到大）**.  
- Sort the **columns（每列从上到下排序）**.  
- Claim: after this, the rows are **still sorted**.
- Proof uses a lemma about two columns `x-column` and `y-column`:
  - If in each row `xi < yi`, then the `k`-th smallest in the x-column is < the `k`-th smallest in the y-column.

（中文讲解：  
这说明“先按行排，再按列排”不会破坏行的有序性（在所有元素 distinct 的前提下）。  
证明技巧是把大问题拆成“任意相邻两列”的局部比较，再通过一个引理保证排序后仍然保序。这个思路在算法设计中也很常见：先局部分析列，再推广到整个矩阵。）

---

#### 7. Truth and proof, models and completeness（选读）

这里是更理论的一部分，重点词汇如下，建议理解概念即可：

- **Model（模型）**: a “world” where our axioms hold; e.g., integers with usual `+`, or `Z₂ = {0,1}` with special addition.  
- If a proposition can be **false in some model** where all axioms are true, then it **cannot** be proved from those axioms.  
- Example: Axioms A1–A4 about `+` are true in both integers and `Z₂`.  
  - Proposition (P): `∀x: x + x = 0 → x = 0` is true in integers but **false** in `Z₂` (because `1 + 1 = 0` but `1 ≠ 0`).  
  - So (P) is **not provable** from A1–A4 alone.

（中文讲解：  
“模型”思想：公理只是约束一个“可能的世界”，但同一组公理可能有多个不同的模型。要想从公理推导命题 P，至少要保证 P 在**所有模型**中都为真，否则无法证明。  
所以如果你能找到一个模型，既满足公理又让 P 为假，就等于证明 P **不可由这些公理推出**。）

**Completeness（完备性）**

- Rough idea: If `P` is true in **every model** of axioms `A`, then `P` is **provable from A** (using some fixed logical system, e.g., Hilbert system).
- **Soundness（可靠性）**: If `P` is provable from `A`, then `P` is true in every model of `A`.

（中文讲解：  
“sound（可靠）”：“推得出的都是对的”；  
“complete（完备）”：“所有对的都能推得出”。  
一个好的逻辑系统要既可靠又尽量完备。）

**Hilbert system（希尔伯特证明系统）** and **Modus Ponens（肯定前件规则）**

- Uses a set of logical axioms + one main rule:
  - From `P` and `P → Q`, infer `Q`.  
- In principle, every standard proof can be rewritten in this formal style, though not convenient for humans.

**Automated theorem proving（自动定理证明）**

- Idea: Systematically generate all theorems from axioms using rules like Modus Ponens until you see either `X` or `not X`.  
- Theoretically possible (for some arithmetic), but often **too slow** and impractical, and connected to deep results like **Gödel’s incompleteness theorem（哥德尔不完备定理）** and **Turing’s theorem（图灵停机定理）**.

（中文总结：  
这一大块是“数理逻辑史”的快速导览：  
1）介绍“模型”来说明某些真命题在给定公理下可能无法证明；  
2）解释“完备性定理”：如果在所有模型中都真，就能用形式系统证明出来；  
3）进一步指出，由于哥德尔和图灵的工作，我们知道：对足够丰富的系统（涉及加法和乘法的整数），不可能既完全自动化证明所有真命题，又保持健全和可计算性。  
对本课作业和考试，你主要需要感知这些术语的含义，细节只要有概念就好。）

---

### Lecture 3 – Induction, Strong Induction, Invariants, Concurrency

> This lecture introduces **induction（数学归纳法）**, its stronger form **strong induction（强归纳）**, and applications to **tilings（铺砌）**, **number theory（数论）**, **state machines（状态机）**, and **concurrency（并发）**.

---

#### 1. Basic induction

**Goal form**: Prove statements of the form `For all n ≥ 1, P(n)`.

**Induction proof method（归纳法模板）**

1. **Base case（基例）**: Prove `P(1)` (or `P(n₀)` for some starting integer).  
2. **Inductive step（归纳步）**:  
   - Assume `P(n)` holds for some arbitrary `n` (inductive hypothesis（归纳假设）).  
   - Prove `P(n + 1)` under that assumption.  
3. Conclude `P(n)` holds for all positive integers `n`.

（中文讲解：  
数学归纳法的逻辑结构是：  
1）先把“第一个台阶”站稳；  
2）再证明“能从第 n 阶迈到第 n+1 阶”；  
3）于是你从 1 一路可以走到任意 n。  
关键是：在归纳步中，你可以把 `P(n)` 当成“已经证明的事实”来使用。）

**Example – Sum of first n integers**

- Claim: For every `n ≥ 1`,  
  - `1 + 2 + ··· + n = n(n + 1)/2`.  
- Let `S(n)` denote the sum of first `n` integers.
- Base case `n = 1`: `S(1) = 1`, RHS = `1(1 + 1)/2 = 1`.  
- Inductive step:
  - Assume `S(n) = n(n + 1)/2`.  
  - Then `S(n + 1) = S(n) + (n + 1)`  
    `= n(n + 1)/2 + (n + 1)`  
    `= (n(n + 1) + 2(n + 1))/2`  
    `= (n + 1)(n + 2)/2`.  
  - So `S(n + 1)` has the desired form.

（中文讲解：  
这是归纳法最经典例子。你要熟到几乎可以闭眼写出：  
1）设 S(n) 为前 n 项和；  
2）假设 S(n) 已知；  
3）把 S(n+1) 写成 S(n)+(n+1)，再代入假设。  
考试经常会要求你“按归纳法写出完整证明”，注意写清 base case 和归纳假设。）

**Example – Factorial vs. power**

- **Factorial（阶乘）**: `n! = 1·2·…·n`.  
- Theorem 2: For every integer `n ≥ 4`, `n! > 2^n`.  
- Base case `n = 4`: `4! = 24 > 16 = 2^4`.  
- Inductive step:
  - Assume `n! > 2^n` for some `n ≥ 4`.  
  - Then `(n + 1)! = n!(n + 1) > 2^n (n + 1)`.  
  - Since `n + 1 ≥ 5 > 2`, we have `2^n (n + 1) > 2^n · 2 = 2^{n + 1}`.  
  - So `(n + 1)! > 2^{n + 1}`.

（中文讲解：  
这里老师还展示了一个常见技巧：**从目标反推中间不等式**。  
在归纳步中，要证明 `(n+1)! > 2^{n+1}`，先写 `(n+1)! = n!(n+1)`，代入归纳假设得到 `> 2^n(n+1)`，再去比较 `2^n(n+1)` 与 `2^{n+1}` 的大小。  
这种“倒着思考再正着写”的方式在不等式归纳证明中很常用。）

**Example – `n³ − n` is a multiple of 6**

- Theorem 3: For every positive integer `n`, `n³ − n` is divisible by 6.  
- Induction:
  - Base case `n = 1`: `1³ − 1 = 0`, multiple of 6.  
  - Inductive step:
    - Assume `n³ − n` is multiple of 6.  
    - Compute `(n + 1)³ − (n + 1) = (n³ − n) + 3(n² + n)`.  
    - `n³ − n` is multiple of 6 by hypothesis.  
    - Previously we proved `n² + n` is even → `3(n² + n)` is a multiple of 6.  
    - Sum of multiples of 6 is a multiple of 6 → done.

（中文讲解：  
关键是把 `(n+1)³-(n+1)` 拆成“旧表达式 + 额外部分”，让旧表达式正好是归纳假设里出现的 `n³-n`。这是处理多项式归纳时的常用套路：  
**先展开，再人为加减一个归纳假设中的形式**，使之出现。）

---

#### 2. Strengthening the hypothesis – tiling problems

**L-shaped tile（L 形小板）** on `2^n × 2^n` grids.

Theorem 4: For every `n`, a `2^n × 2^n` grid with the **central square（中心方格）** removed can be tiled with L-shaped tiles (each covering 3 squares).

- Direct induction on this statement gets stuck: when splitting the big board into four quadrants, only one quadrant is missing the “right” central square; others are wrong shapes.

**Idea**: Prove a **stronger theorem（更强的命题）**:

- Theorem 5: For every `n`, a `2^n × 2^n` grid with **any one square removed** can be tiled with L-shaped tiles.
- Now in the inductive step:
  - Divide the big grid into four quadrants `G1, G2, G3, G4`.  
  - Temporarily remove three center squares (one from each of the other quadrants).  
  - Each quadrant becomes a `2^n × 2^n` grid with exactly one square removed → fits the inductive hypothesis.  
  - Tile each quadrant, then cover the 3 temporarily removed squares with one L-shaped tile.

（中文讲解：  
这一段很重要的思想是：**有时为了让归纳法能工作，需要把命题先“加强”**。  
原命题只允许“删中心方格”，没法在子问题中保持同样的结构；  
改成“任意删一个方格都能铺”，反而更适合作为归纳假设，让四个子棋盘都满足条件。  
这叫做“strengthening the induction hypothesis（加强归纳假设）”，在算法循环不变式、数据结构证明中非常常见。）

The slides also show a second, more geometric proof of Theorem 4 that “blows up” each square to 4 smaller squares, but核心思路类似：构造法 + 归纳。

---

#### 3. A false proof by induction – debugging induction

“Theorem”: In every nonempty set of horses, all horses are of the same colour.

- “Proof” uses induction on the number of horses `n`.  
- Base case `n = 1` is trivially true.  
- Inductive step claims: from “any set of `n` horses is monochromatic（同色）” deduce “any set of `n + 1` horses is monochromatic”.
- The flaw occurs at `n = 1`:
  - For `n = 1`, the set `{h1, h2}` has size 2.  
  - The argument uses overlapping subsets `{h1}` and `{h2}` and tries to “glue” them, which fails because they **do not overlap**.

（中文讲解：  
这个经典例子告诉你：  
1）写出形式上的“归纳模板”不代表证明就一定正确；  
2）必须检查归纳步在所有 n（尤其是最小的 n）上都合法；  
3）调试（debug）归纳证明的好办法：找出第一个失败的 n，专门在那个地方检查哪一步推理不再成立。  
考试时如果你用到了类似“取前 n 个元素”和“取后 n 个元素并重叠”的技巧，要特别注意 `n=1` 的边界情况。）

---

#### 4. Strong induction（强归纳）

**Strong induction proof method**

- Base case: prove `P(1)` (or a range up to some `n₀`).  
- Inductive step: assume **all** `P(1), P(2), …, P(n)` are true and prove `P(n + 1)`.

Logical equivalence: strong induction and ordinary induction prove the same class of statements, but strong induction is often **more convenient（更方便）**.

**Example – 3-dollar and 5-dollar stamps**

- We can make postage of amounts `3a + 5b` with `a, b ≥ 0`.  
- Claim: Any integer `n ≥ 8` can be written as `3a + 5b`.
- Proof by strong induction:
  - Check small base cases (e.g., 8, 9, 10).  
  - For `n + 1 ≥ 11`, note that `n + 1 − 3 ≥ 8`, so `n + 1 − 3` can be written as `3a + 5b`.  
  - Then `n + 1 = 3(a + 1) + 5b`.

（中文讲解：  
这里“强”的地方在于：在证明 `P(n+1)` 时，可以自由使用 `P(8)…P(n)` 所有结论，而不是只用 `P(n)`。  
特别是在处理“用若干硬币/邮票拼成金额”的问题时，这种形式非常自然，因为你关心的是“比当前金额小一点的所有情况都已经会做了”。）

**Example – Fibonacci representations**

- Fibonacci numbers `F₁ = 1, F₂ = 2, F_{n+1} = F_n + F_{n-1}`.  
- Theorem 7: Every positive integer is a sum of **distinct（互不相同的）** Fibonacci numbers.
- Strategy:
  - For each `m`, pick the largest Fibonacci `F_n ≤ m`.  
  - Show `m − F_n < F_n`, so by strong induction you can represent `m − F_n` as a sum of distinct Fibonacci numbers smaller than `F_n`.  
  - Concatenate `F_n` with that representation.

（中文讲解：  
这个定理实际上就是著名的“Zeckendorf 表示”：任何正整数都可以唯一写成若干不相邻的 Fibonacci 数之和。  
课堂上先不证明唯一性，只证明存在性，但你已经能看到强归纳对这种“选一个最大部件，再递归处理剩余”的问题非常自然。）

**Example – Unstacking boxes, cost `(n² − n)/2`**

- Game: start with a stack of `n` boxes.  
- Move: split one stack into sizes `a` and `b` → pay `a·b`.  
- Claim: Any strategy to split into single boxes costs exactly `(n² − n)/2`.
- Strong induction:
  - For a first split `n = a + b`, cost = `ab + cost(a) + cost(b)`.  
  - Using inductive hypothesis: `cost(a) = (a² − a)/2`, `cost(b) = (b² − b)/2`.  
  - Algebra simplifies to `(n² − n)/2`, independent of the splitting strategy.

（中文讲解：  
这类题在竞赛中也很常见：表面是“策略优化”，实则证明“所有策略代价一样”，于是根本不用找“最优策略”。  
证明时强归纳允许你假设“较小规模的所有拆分方式其代价都等于公式”，再把大问题拆成两个子问题。）

---

#### 5. State machines and invariants

**State machine（状态机）**

- Describes systems evolving in discrete steps.  
- Components:
  - A set of **states（状态）**.  
  - A **transition relation（迁移关系）** `q → r`.  
  - A **start state（初始状态）`.

**Invariant（不变量）**

- A predicate on states that remains **true for all reachable states（所有可达状态）**.  
- To prove an invariant:
  1. Show it holds in the start state (base case).  
  2. Show that if it holds at time `n`, it also holds after any allowed transition to time `n + 1` (inductive step).

**Robot example**

- Robot moves on integer grid `(x, y)` in diagonal steps:  
  - Each move: change `x` by ±1 and `y` by ±1.  
  - Start at `(0, 0)`.  
- Claim: At time `n`, `x + y` is always **even**.  
- Induction:
  - Base: `0 + 0` even.  
  - Step: check 4 possible moves; each changes `x + y` by `-2`, `0`, or `+2`, so parity（奇偶性） stays the same.
- As `(1, 0)` has odd sum, it is unreachable.

（中文讲解：  
不变量方法是软件验证、算法正确性证明的核心技术之一。  
这里的“不变量”是“x+y 的奇偶性不变”。通过检查所有可能的步长变化，证明“如果当前为偶数，则下一步仍为偶数”，于是 `(1,0)` 这样的状态绝不可能出现。）

**8-puzzle example – inversions（逆序数）**

- Tiles numbered 1–8 with one empty square.  
- Define “appears before” and **inversion（逆序对）**: a pair `{a, b}` with `a > b` where `a` appears before `b`.  
- Show: the number of inversions is always **odd**.  
- Initial configuration: exactly one inversion `{8, 7}` → odd.  
- Each move either keeps the inversion count or changes it by an even number (±2).  
- Final configuration has 0 inversions (even), so it is unreachable from the initial configuration.

（中文讲解：  
这是一个经典“不变量证明无法到达某状态”的例子。  
构造一个巧妙的不变量：逆序对个数的奇偶性。初始状态为奇数，目标状态为偶数；  
然后证明每一步操作只会让逆序数加减 0 或 2（总之不改变奇偶性），于是目标状态永远不可达。  
要点：不变量只要在目标状态不成立，就能证明“不可达”；但**反过来**，不变量成立并不能保证“可达”。）

---

#### 6. Concurrency and mutual exclusion（选读）

关键术语：

- **Concurrency（并发）**: multiple programs running “in parallel” with shared resources.  
- **Critical section（临界区）**: code that accesses shared resources and must not run concurrently with others.  
- **Mutual exclusion（互斥）**: at most one thread/process in the critical section at a time.  
- **Deadlock（死锁）**: all threads wait forever, no progress.  
- **Starvation-freeness（无饥饿性）**: if a thread keeps asking to enter the critical section, it will eventually succeed.

The slides describe:

- Simple attempts at mutual exclusion using shared booleans `Awants`, `Bwants` and a `turn` variable.  
- Modelling their executions as **state machines**, and analyzing reachability of “both in critical section” and “deadlock” states.  
- Finally, **Peterson’s algorithm（Peterson 互斥算法）** which:
  - Ensures mutual exclusion,  
  - Is starvation-free under certain fairness assumptions.

（中文讲解：  
这一部分把你在操作系统/并发编程课会学到的问题提前用离散数学的形式展示：  
1）把并发程序抽象成状态机；  
2）用不变量和逻辑推理证明“不会同时进入临界区”（互斥）；  
3）进一步讨论“是否可能一直饿死某个进程”（饥饿/死锁）。  
重点是理解：逻辑工具（不变量、归纳）不仅可以用来证明数论命题，也可以证明并发程序的正确性。）

---

### Short Review – L02 & L03 Key Takeaways

- **L02**: Deep dive into **what proofs are**, how to use **case analysis**, **direct proofs**, **contrapositive**, **equivalences**, and **contradiction**, plus the ideas of **models**, **soundness**, and **completeness**.  
- **L03**: Systematic use of **induction and strong induction** with many examples (sums, inequalities, divisibility, tilings, Fibonacci, unstacking), introduction to **state machines, invariants**, and a glimpse of **concurrent program verification**.  
- Vocabulary like **lemma（引理）**, **axiom（公理）**, **contrapositive（逆否命题）**, **invariant（不变量）**, **state machine（状态机）**, **mutual exclusion（互斥）**, **deadlock（死锁）** is central;在阅读英文教材时，可以对照这里的中英文注释理解。  
- 练习方向：多写完整的归纳证明、多用不变量思考简单“小游戏”和算法、尝试把自然语言题目正式翻译成“对所有/存在”形式的逻辑命题并证明。

