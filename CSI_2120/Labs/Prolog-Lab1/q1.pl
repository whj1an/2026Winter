flight(montreal, chicoutimi, 15:30, 16:15).
flight(montreal, sherbrooke, 17:10, 17:50).
flight(montreal, sudbury, 16:40, 18:45).
flight(northbay, kenora, 13:10, 14:40).
flight(ottawa, montreal, 12:20, 13:10).
flight(ottawa, northbay, 11:25, 12:20).
flight(ottawa, thunderbay, 19:00, 20:30).
flight(ottawa, toronto, 10:30, 11:30).
flight(sherbrooke, baiecomeau, 18:40, 20:05).
flight(sudbury, kenora, 20:15, 21:55).
flight(thunderbay, kenora, 20:00, 21:55).
flight(toronto, london, 13:15, 14:05).
flight(toronto, montreal, 12:45, 14:40).
flight(windsor, toronto, 8:50, 10:10).


flight(ottawa, toronto, 10:30, 11:30).

%     time-to-minutes(H:M, total)
time_to_minutes(H:M, Total) :-
  Total is H * 60 + M.

on_time(Time, Departure, Arrival, Req) :-
  flight(Departure, Arrival, FlightTie, _),
  time_to_minutes(Time, T),
  time_to_minutes(FlightTie, F),
  T + Req =< F.
