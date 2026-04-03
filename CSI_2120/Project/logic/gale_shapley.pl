% CSI_2120 - part 3: logic programming
% Student Name: Haojian Wang
% Student Number: 300411829

:- consult('rp4000.pl').

% rankInProgram(+ResidentID, +ProgramID, -Rank)
% Finds the 1-based rank of a resident in a program's ROL.
% fails if the resident is not in the program's ROL.
rankInProgram(ResidentID, ProgramID, Rank) :-
    program(ProgramID, _, _, ROL),
    nth1(Rank, ROL, ResidentID).

% leastPreferren(+ProgramID, +ResidentList, -WorstID, -WorstRank)
% Finds the least preferred resident (Highest rank index)
% in ResidentList according to ProgramID's ROL.
% Base Case: single resident in list.
% Recursive case: compare head with result of the rest
leastPreferred(ProgramID, [R], R, Rank) :-
    rankInProgram(R, ProgramID, Rank).
leastPreferred(ProgramID, [R|Rest], Worst, WorstRank) :-
    leastPreferred(ProgramID, Rest, W2, Rank2),
    rankInProgram(R, ProgramID, Rank1),
    ( Rank1 > Rank2
    -> Worst = R, WorstRank = Rank1
    ; Worst = W2, WorstRank = Rank2
    ).

% matched(+ResidentID, -ProgramID, +MatchSet)
% Succeeds if ResidentID is in any match entry.
% cut prevents searching further once found.
matched(ResidentID, ProgramID, [match(ProgramID, Residents)|_]) :-
    member(ResidentID, Residents), !.
matched(ResidentID, ProgramID, [_|Rest]) :-
    matched(ResidentID, ProgramID, Rest).

% updateMatch(+ProgramID, +NewResidents, +Ms, -NewMs)
% replaces the resident list of ProgramID in the match set.
% Produces a new match set NewMs with the updated entry.
updateMatch(ProgramID, NewResidents, [match(ProgramID, _) | Rest], [match(ProgramID, NewResidents) | Rest]) :- !.
updateMatch(ProgramID, NewResidents, [M|Rest], [M|NewRest]) :-
    updateMatch(ProgramID, NewResidents, Rest, NewRest).

% case 1: Program still has open positions.
tryMatch(ResidentID, ProgramID, Ms, NewMs) :- 
  rankInProgram(ResidentID, ProgramID, _),
  member(match(ProgramID, matched), Ms),
  program(ProgramID, _, Quota, _),
  length(Matched, N),
  N < Quota, !,
  updateMatch(ProgramID, [ResidentID|Matched], Ms, NewMs).

%case 2: Program is full - displace least preferred if new resident is batter.
tryMatch(ResidentID, ProgramID, Ms, NewMs) :-
  rankInProgram(ResidentID, ProgramID, NewRank),
  member(match(ProgramID, Matched), Ms),
  program(ProgramID, _, Quota, _),
  length(Matched, Quota),
  leastPreferred(ProgramID, Matched, Worst, WorstRank),
  NewRank < WorstRank, !,
  delete(Matched, Worst, Matched1),
  updateMatch(ProgramID, [ResidentID|Matched1], Ms, NewMs).

% ofeerToPrograms(+ResidentID, +ProgramList, +Ms, -NewMs)
% Tries each program in ProgramList in order until one accepts.
% if no program accepts, Ms is returned unchanged
offerToPrograms(_, [], Ms, Ms) :- !.

offerToPrograms(ResidentID, [P|_],Ms, NewMs) :-
    tryMatch(ResidentID, P , Ms, NewMs), !.

offerToPrograms(ResidentID, [_|Rest], Ms, NewMs) :-
    offerToPrograms(ResidentID, Rest, Ms, NewMs).

% offer(+ResidentID, +Ms, -NewMs)
% top-level offer: tries to match ResidentID to a program
% if already matched -> returns Ms unchanged imm.
offer(ResidentID, Ms, Ms) :-
    matched(ResidentID, _, Ms), !.

offer(ResidentID, Ms, NewMs) :-
    resident(ResidentID, _, ROL),
    offerToPrograms(ResidentID, ROL, Ms, NewMs).


% offerAll(+ResidentList, +Ms, -NewMs)
% calls offer/3 for every resident in ResidentList in sequence
% each call passes the updated Ms to the next.
offerAll([], Ms, Ms).
offerAll([R|Rest], Ms, NewMs) :-
    offer(R, Ms, Ms1),
    offerAll(Rest, Ms1, NewMs).

% loop(+Ms, -FinalMs)
% repeatedly calls offerAll until the match set stops changing.
% Termination condition: Ms == NewMs (no resident was moved)
loop(Ms, FinalMs) :-
    findall(R, resident(R,_,_), Residents),
    offerAll(Residents, Ms, NewMs),
    ( Ms == NewMs
    -> FinalMs = NewMs
    ; loop(NewMs, FinalMs)
    ).

% output part
% Given by Project Description from LECTURE CSI 2120
% writeMatchInfo(+ResidentID, +ProgramID)
writeMatchInfo(ResidentID, ProgramID) :-
    resident(ResidentID, name(FN,LN), _),
    program(ProgramID, TT, _, _), write(LN), write(','),
    write(FN), write(','), write(ResidentID), write(','),
    write(ProgramID), write(','), writeln(TT).

% displayMatched(+MatchSet)
% prints all matched residents, ground by program
displayMatched([]).
displayMatched([match(P, Rs)|Rest]) :-
    forall(member(R, Rs), writeMatchInfo(R, P)),
    displayMatched(Rest).

% displayUnmatched(+MatchSet)
displayUnmatched(Ms) :-
    findall(R, resident(R,_,_), AllResidents),
    forall(
        member(R, AllResidents),
        ( matched(R, _, Ms)
        -> true
        ; resident(R, name(FN, LN), _),
            write(LN), write(','),
            write(FN), write(','),
            write(R), write(','),
            write('XXX'), write(','),
            writeln('Not_Matched')
        )
    ).

% sumList(+List, -Sum)
% sums a list of integers, used to total available positions
sumList([], 0).
sumList([H|T], Sum) :-
    sumList(T, Rest),
    Sum is Rest + H.

% countUnmatched(+MatchSet, -Count)
% counts residents not present in any match entry.
countUnmatched(Ms, Count) :-
    findall(R, (resident(R,_,_), \+ matched(R,_,Ms)), List),
    length(List, Count).

% countAvailable(+MatchSet, -Count)
% counts total remaining open positions arcoss all programs
countAvailable(Ms, Count) :-
    findall(N, (member(match(P, Rs), Ms), program(P, _, Quota, _), length(Rs, Filled), N is Quota - Filled), Ns),
    sumList(Ns, Count).

% gale_shapley/0
% top-level predicate; entry point for the entire algorithm.
% 1. Build initial empty match set.
% 2. run loop until stable.
% 3. display results.
gale_shapley :-
    findall(match(P,[]), program(P,_,_,_), Ms0),
    loop(Ms0, FinalMs),
    displayMatched(FinalMs),
    displayUnmatched(FinalMs),
    countUnmatched(FinalMs, UnmatchedCount),
    countAvailable(FinalMs, AvailableCount),
    write('Number of unmatched residents: '), writeln(UnmatchedCount),
    write('Number of positions available: '), writeln(AvailableCount).

