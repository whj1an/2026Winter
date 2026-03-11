flight(ottawa, toronto, 10:30, 11:30).
%     出发地， 目的地， 出发时间， 到达时间
%     on time(Time, Departure, Arrival, Req)
%     time-to-minutes(H:M, total)
time_to_minutes(H:M, Total) :-
  Total is H * 60 + M.

on_time(Time, Departure, Arrival, Req) :-
  flight(Departure, Arrival, FlightTie, _),
  time_to_minutes(Time, T),
  time_to_minutes(FlightTie, F),
  T + Req =< F.
