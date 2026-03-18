event(meeting, monday, am).
event(conference, monday, pm).
event(workshop, monday, allday).
event(party, friday, pm).
event(exam, friday, am).
event(cleaning, friday, allday).
event(training, tuesday, am)

% overlapping time slots
overlaps(allday, _).
overlaps(_, allday).

% same time
overlaps(am, am).
overlaps(pm, pm).

conflict(E1, E2) :-
    E1 \= E2,
    event(E1, Day, Time1),
    event(E2, Day, Time2),
    overlaps(Time1, Time2).