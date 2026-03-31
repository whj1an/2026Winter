#lang scheme

; positive and zero to 1, negative to -1
(define (sign-list lst)
    (if (null? lst)
        '()
        (cons
            (if (< (car lst) 0)
                -1
                1)
            (sign-list (cdr lst)))))