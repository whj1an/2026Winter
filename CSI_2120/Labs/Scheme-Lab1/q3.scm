#lang scheme
(
    define (longest-string lst)

    (
        define (helper remaining current-longest)
            (cond
                [(null? remaining)
                current-longest]

                [(> (string-length (car remaining))
                    (string-length current-longest))
                    (helper (cdr remaining) (car remaining)
            )]

            [
                else
                (helper (cdr remaining) current-longest)
            ]
            )
    )
    (helper (cdr lst) (car lst))
)