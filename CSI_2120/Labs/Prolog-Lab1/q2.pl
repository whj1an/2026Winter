:- dynamic memo/3.

combinaisons(0, _, 1) :- !.
combinaisons(N, N, 1) :- !.

combinaisons(K, N, Result) :-
    memo(K,N,Result), !.

combinaisons(K, N, Result) :-
    K > 0,
    K < N,
    K1 is K - 1,
    N1 is N - 1,
    combinaisons(K1, N1, R1),
    combinaisons(K, N1, R2),
    Result is R1 + R2,
    assert(memo(K, N, Result)).
