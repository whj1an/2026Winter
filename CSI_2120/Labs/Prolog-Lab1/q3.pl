% Generation 1
parent(george, alice).
parent(george, brian).
parent(george, claire).
parent(helen, alice).
parent(helen, brian).
parent(helen, claire).

% Generation 2
parent(alice, david).
parent(alice, emma).
parent(brian, frank).
parent(brian, grace).
parent(claire, henry).
parent(claire, isabelle).

% Generation 3
parent(david, jack).
parent(david, julia).
parent(frank, kevin).
parent(frank, karen).
parent(henry, liam).
parent(henry, lily).

% Predicates
% Brothers & Sisters: Same parents, and not same one
sibling(S1, S2) :-
    parent(P, S1),
    parent(P, S2),
    S1 \= S2.

% Grandparents: parent over parents
grandparent(GP, GC) :-
    parent(GP, P),
    parent(P, GC).

% Parents siblings, out-self
cousin(C1, C2) :-
    parent(P1, C1),
    parent(P2, C2),
    sibling(P1, P2),
    \+ sibling(C1, C2).

second_cousin(C1, C2) :-
    parent(P1, C1),
    parent(P2, C2),
    cousin(P2, P1),
    \+ sibling(C1, C2).
