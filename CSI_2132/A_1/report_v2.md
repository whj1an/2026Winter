Assignment 1 – CSI 2132 

Student Name:

Student Number:

Relational Algebra and Relational Calculus  

## Exercise 1

Schema used in this exercise:  
- Store(storeid, sname, employee_number, city)  
- Product(pid, pname, price)  
- Supply(storeid, pid)  

### A

We want the ids of the stores that either have fewer than 100 employees or are located in the city 'Ottawa'.  

Relational algebra expression:  
\[
\pi_{\text{storeid}}\bigl(
  \sigma_{\text{employee\_number} < 100 \;\lor\; \text{city} = 'Ottawa'}(\text{Store})
\bigr)
\]

### B

Here we look for the names of stores that offer the product whose name is 'pencil'.  

Relational algebra expression:  
\[
\pi_{\text{sname}}\bigl(
  \text{Store} \bowtie_{\text{Store.storeid} = \text{Supply.storeid}}
  (\text{Supply} \bowtie_{\text{Supply.pid} = \text{Product.pid}}
    \sigma_{\text{pname} = 'pencil'}(\text{Product})
  )
\bigr)
\]

### C

In this part we need the names and cities of all stores that carry every product that is also supplied by the store with id '0808'.  

Let  
\[
R(\text{storeid}, \text{pid}) = \text{Supply}
\]
\[
P(\text{pid}) = \pi_{\text{pid}}(\sigma_{\text{storeid} = '0808'}(\text{Supply}))
\]

We use division to describe the condition:  
\[
T(\text{storeid}) = R \div P
\]

An equivalent expanded form is:  
\[
T = \pi_{\text{storeid}}(R)
  - \pi_{\text{storeid}}\bigl(
      (\pi_{\text{storeid}}(R) \times P - R)
    \bigr)
\]

The final projection on store name and city is:  
\[
\pi_{\text{sname}, \text{city}}\bigl(
  \text{Store} \bowtie_{\text{Store.storeid} = T.\text{storeid}} T
\bigr)
\]

## Exercise 2

Schema for this exercise:  
- Employee(eid, cid, salary, managerid)  
- Company(cid, companyname, location)  
- Shares(eid, cid, sharenum)  

### A

We select the eids of employees who work for the company called 'Google' and at the same time hold more than 500 shares in the company called 'Facebook'.  

Relational algebra (with renamed copies of Company):  
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

Here we need the eids of those employees whose manager owns shares in the same company where the employee is employed.  

Let  
\[
E_1 = \rho_{E_1}(\text{Employee}),\quad
E_2 = \rho_{E_2}(\text{Employee}),\quad
S = \text{Shares}
\]

Relational algebra expression:  
\[
\pi_{E_1.\text{eid}}\bigl(
  \sigma_{E_1.\text{managerid} = E_2.\text{eid}
        \land E_2.\text{eid} = S.\text{eid}
        \land E_1.\text{cid} = S.\text{cid}}
  (E_1 \times E_2 \times S)
\bigr)
\]

### C

In this question we are interested in employee ids for which the employee holds shares in at least three different companies, and we must do this without aggregation.  

Let three renamed copies of Shares be  
\[
S_1 = \rho_{S_1}(\text{Shares}),\quad
S_2 = \rho_{S_2}(\text{Shares}),\quad
S_3 = \rho_{S_3}(\text{Shares})
\]

Relational algebra expression:  
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

Now we want the eids of those employees who have shares in every company that appears in the database, again without using aggregation.  

Define  
\[
R(\text{eid}, \text{cid}) = \pi_{\text{eid}, \text{cid}}(\text{Shares}),\quad
C(\text{cid}) = \pi_{\text{cid}}(\text{Company})
\]

Using the division operator we can express the result as:  
\[
\pi_{\text{eid}}(R \div C)
\]

An equivalent form that expands the division is:  
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

Schemas here are:  
- Supplier(supplier-id, name, city)  
- Store(store-id, sname, city)  
- Product(barcode, pname, price, itsshoes, itsabag, color, supplier-id)  
- Has_stock(store-id, barcode, quantity)  

### A

We look for the names of stores that have at least two distinct black bag products in stock, and we solve it without using aggregation.  

Let  
\[
P_1 = \rho_{P_1}(\text{Product}),\quad
P_2 = \rho_{P_2}(\text{Product})
\]
\[
H_1 = \rho_{H_1}(\text{Has\_stock}),\quad
H_2 = \rho_{H_2}(\text{Has\_stock})
\]

Relational algebra expression:  
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

Here we need the prices of all products that are shoes in the store whose name is 'LaFollie'.  

Relational algebra expression:  
\[
\pi_{\text{price}}\bigl(
  \sigma_{\text{sname} = 'LaFollie' \land \text{itsshoes} = 'yes'}
  (\text{Store}
    \bowtie_{\text{Store.store-id} = \text{Has\_stock.store-id}} \text{Has\_stock}
    \bowtie_{\text{Has\_stock.barcode} = \text{Product.barcode}} \text{Product})
\bigr)
\]

### C

This question asks for the supplier names where each such supplier provides more than five products with different barcodes, and here we are allowed to use aggregation.  

Let  
\[
R = \text{Supplier} \bowtie_{\text{Supplier.supplier-id} = \text{Product.supplier-id}} \text{Product}
\]
\[
G = \gamma_{\text{supplier-id}, \text{name}, \text{city};\ \text{COUNT}(\text{barcode}) \rightarrow \text{prodcount}}(R)
\]

Relational algebra expression for the final result:  
\[
\pi_{\text{name}}\bigl(
  \sigma_{\text{prodcount} > 5}(G)
\bigr)
\]

### D

Finally in this exercise we are looking for barcodes of products that appear in both store 1 and store 2, and we must not use the intersection operator directly.  

Let  
\[
H_1 = \rho_{H_1}(\text{Has\_stock}),\quad
H_2 = \rho_{H_2}(\text{Has\_stock})
\]

Relational algebra expression:  
\[
\pi_{H_1.\text{barcode}}\bigl(
  \sigma_{H_1.\text{store-id} = '1'
        \land H_2.\text{store-id} = '2'
        \land H_1.\text{barcode} = H_2.\text{barcode}}
  (H_1 \times H_2)
\bigr)
\]

## Exercise 4

The schema here is the same as in Exercise 3:  
- Supplier(supplier-id, name, city)  
- Store(store-id, sname, city)  
- Product(barcode, pname, price, itsshoes, itsabag, color, supplier-id)  
- Has_stock(store-id, barcode, quantity)  

We write the answers in tuple relational calculus. When we say Product(p) we mean that tuple p belongs to the relation Product, and similarly for Store(s) and Has_stock(h).  

### A

We describe the set of all product tuples whose price is greater than 40.  

Tuple relational calculus:  
\[
\{\, p \mid \text{Product}(p) \land p.\text{price} > 40 \,\}
\]

### B

Now we only keep the barcodes of the products from the previous condition (price greater than 40).  

Tuple relational calculus:  
\[
\{\, b \mid \exists p\ (\text{Product}(p) \land p.\text{price} > 40 \land b = p.\text{barcode}) \,\}
\]

### C

Here we want the barcodes of products that are sold in store 1 but not in store 2.  

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

Last, we specify the barcodes of products that are sold in every store whose city is 'Ottawa'.  

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

