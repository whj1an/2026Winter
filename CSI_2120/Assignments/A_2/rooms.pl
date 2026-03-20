room(room101).
room(room202).
room(auditorium).
day(monday).
day(tuesday).
day(wednesday).
day(thursday).
day(friday).
work_hours(8,18). % events cannot start before, or end after
% event(event_name, day, start_hour, end_hour, room_name)
event(meeting1, monday, 9, 11, room101).
event(meeting2, monday, 14, 17, room101).
event(workshop, monday, 8, 17, room202).
event(cleanup, monday, 8, 18, auditorium).
event(conference, tuesday, 14, 16, room101).
event(board, tuesday, 9, 12, room202).
event(activity, tuesday, 10, 17, auditorium).

% q1 busy_room
busy_room(Day, Start, End, Room) :-
    event(_, Day, ES, EE, Room),
    ES < End,
    EE > Start.

% Free room = avaliable room
free_room(Day, Start, End, Room) :-
    room(Room),
    day(Day),
    \+ busy_room(Day, Start, End, Room).

% hours occupied ( room, day ,hours)
hours_occupied(Room, Day, Hours) :-
    day(Day),
    findall(H, (event(_, Day, S, E, Room), H is E - S), Hs),
    sumlist(Hs, Hours).

% hours occupied in a whole week
hours_occupied(Room, Hours) :-
    room(Room),
    findall(H, (event(_, _, S, E, Room), H is E - S), Hs),
    sumlist(Hs, Hours).