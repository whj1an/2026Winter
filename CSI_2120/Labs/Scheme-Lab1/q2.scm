#lang scheme
(
    define (absDiff lst1 lst2)
        (cond
            [(and (null? lst1) (null? lst2)) '()]
            [(null? lst1)
                (cons (abs (car lst2)) (absDiff '() (cdr lst2)))
            ]
            [
                (null? lst2) 
                (cons (abs (car lst1)) (absDiff (cdr lst1) '()))
            ]
            [else
                (cons (abs (- (car lst1) (car lst2)))
                    (absDiff (cdr lst1) (cdr lst2)))
            ]
        )
)