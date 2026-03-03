Assignment 1 – CSI 2132 
Relational Algebra and Relational Calculus  

## Exercise 1

Given:  
- Store(storeid, sname, employee_number, city)  
- Product(pid, pname, price)  
- Supply(storeid, pid)  

### A

Result: storeid of stores with fewer than 100 employees or in city 'Ottawa'.  

Relational algebra:  
\[
\pi_{\text{storeid}}\bigl(
  \sigma_{\text{employee\_number} < 100 \;\lor\; \text{city} = 'Ottawa'}(\text{Store})
\bigr)
\]

### B

Result: sname of stores that supply the product with pname 'pencil'.  

Relational algebra:  
\[
\pi_{\text{sname}}\bigl(
  \text{Store} \bowtie_{\text{Store.storeid} = \text{Supply.storeid}}
  (\text{Supply} \bowtie_{\text{Supply.pid} = \text{Product.pid}}
    \sigma_{\text{pname} = 'pencil'}(\text{Product})
  )
\bigr)
\]

### C

Result: sname and city of stores that supply all products supplied by the store with storeid '0808'.  

Let  
\[
R(\text{storeid}, \text{pid}) = \text{Supply}
\]
\[
P(\text{pid}) = \pi_{\text{pid}}(\sigma_{\text{storeid} = '0808'}(\text{Supply}))
\]

Expanded:  
\[
T = \pi_{\text{storeid}}(R)
  - \pi_{\text{storeid}}\bigl(
      (\pi_{\text{storeid}}(R) \times P - R)
    \bigr)
\]

Final result:  
\[
\pi_{\text{sname}, \text{city}}\bigl(
  \text{Store} \bowtie_{\text{Store.storeid} = T.\text{storeid}} T
\bigr)
\]

## Exercise 2

Given:  
- Employee(eid, cid, salary, managerid)  
- Company(cid, companyname, location)  
- Shares(eid, cid, sharenum)  

### A

Result: eid of employees who work for company 'Google' and have more than 500 shares in company 'Facebook'.  

Relational algebra (short form with renaming):  
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

### B

Result: eid of employees whose manager owns shares in the company where the employee works.  

Let  
\[
E_1 = \rho_{E_1}(\text{Employee}),\quad
E_2 = \rho_{E_2}(\text{Employee}),\quad
S = \text{Shares}
\]

Relational algebra:  
\[
\pi_{E_1.\text{eid}}\bigl(
  \sigma_{E_1.\text{managerid} = E_2.\text{eid}
        \land E_2.\text{eid} = S.\text{eid}
        \land E_1.\text{cid} = S.\text{cid}}
  (E_1 \times E_2 \times S)
\bigr)
\]

### C

Result: eid of employees who own shares in at least 3 different companies (no aggregation).  

Let  
\[
S_1 = \rho_{S_1}(\text{Shares}),\quad
S_2 = \rho_{S_2}(\text{Shares}),\quad
S_3 = \rho_{S_3}(\text{Shares})
\]

Relational algebra:  
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

### D

Result: eid of employees who have shares in all companies in the database (no aggregation).  

Let  
\[
R(\text{eid}, \text{cid}) = \pi_{\text{eid}, \text{cid}}(\text{Shares}),\quad
C(\text{cid}) = \pi_{\text{cid}}(\text{Company})
\]

Relational algebra using division:  
\[
\pi_{\text{eid}}(R \div C)
\]

Expanded:  
\[
T = \pi_{\text{eid}}(R)
  - \pi_{\text{eid}}\bigl(
      (\pi_{\text{eid}}(R) \times C - R)
    \bigr)
\]
\[
\pi_{\text{eid}}(T)
\]

## Exercise 3

Given:  
- Supplier(supplier-id, name, city)  
- Store(store-id, sname, city)  
- Product(barcode, pname, price, itsshoes, itsabag, color, supplier-id)  
- Has_stock(store-id, barcode, quantity)  

### A

Result: sname of stores that have at least two different black bag designs in stock (no aggregation).  

Let  
\[
P_1 = \rho_{P_1}(\text{Product}),\quad
P_2 = \rho_{P_2}(\text{Product})
\]
\[
H_1 = \rho_{H_1}(\text{Has\_stock}),\quad
H_2 = \rho_{H_2}(\text{Has\_stock})
\]

Relational algebra:  
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

### B

Result: prices of all products that are shoes in the store named 'LaFollie'.  

Relational algebra:  
\[
\pi_{\text{price}}\bigl(
  \sigma_{\text{sname} = 'LaFollie' \land \text{itsshoes} = 'yes'}
  (\text{Store}
    \bowtie_{\text{Store.store-id} = \text{Has\_stock.store-id}} \text{Has\_stock}
    \bowtie_{\text{Has\_stock.barcode} = \text{Product.barcode}} \text{Product})
\bigr)
\]

### C

Result: name of suppliers that supply more than 5 products with different barcodes (aggregation allowed).  

Let  
\[
R = \text{Supplier} \bowtie_{\text{Supplier.supplier-id} = \text{Product.supplier-id}} \text{Product}
\]
\[
G = \gamma_{\text{supplier-id}, \text{name}, \text{city};\ \text{COUNT}(\text{barcode}) \rightarrow \text{prodcount}}(R)
\]

Relational algebra:  
\[
\pi_{\text{name}}\bigl(
  \sigma_{\text{prodcount} > 5}(G)
\bigr)
\]

### D

Result: barcode of products that are sold both by store-id '1' and store-id '2' (no intersection operator).  

Let  
\[
H_1 = \rho_{H_1}(\text{Has\_stock}),\quad
H_2 = \rho_{H_2}(\text{Has\_stock})
\]

Relational algebra:  
\[
\pi_{H_1.\text{barcode}}\bigl(
  \sigma_{H_1.\text{store-id} = '1'
        \land H_2.\text{store-id} = '2'
        \land H_1.\text{barcode} = H_2.\text{barcode}}
  (H_1 \times H_2)
\bigr)
\]

## Exercise 4

Given:  
- Supplier(supplier-id, name, city)  
- Store(store-id, sname, city)  
- Product(barcode, pname, price, itsshoes, itsabag, color, supplier-id)  
- Has_stock(store-id, barcode, quantity)  

We use tuple relational calculus. Product(p) means tuple p is in relation Product, and similar for Store(s), Has_stock(h).  

### A

Result: all product tuples with price greater than 40.  

Tuple relational calculus:  
\[
\{\, p \mid \text{Product}(p) \land p.\text{price} > 40 \,\}
\]

### B

Result: barcode of all products with price greater than 40.  

Tuple relational calculus:  
\[
\{\, b \mid \exists p\ (\text{Product}(p) \land p.\text{price} > 40 \land b = p.\text{barcode}) \,\}
\]

### C

Result: barcode of products sold in store-id '1' but not in store-id '2'.  

Tuple relational calculus:  
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

### D

Result: barcode of products that are sold in all stores in city 'Ottawa'.  

Tuple relational calculus:  
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

## References

- Course notes and slides of CSI 2132 – Databases I, University of Ottawa.  
- Standard database textbook on relational algebra and calculus (for example, "Database System Concepts").  
- RelaX – Relational Algebra Calculator website for testing relational algebra expressions.  

