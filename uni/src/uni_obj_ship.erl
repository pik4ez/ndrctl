%% @author Stanislav Seletskiy <s.seletskiy@gmail.com>
%% @doc Ship Object.
-module(uni_obj_ship).
-created('Date: 09/11/2013').
-created_by('Stanislav Seletskiy <s.seletskiy@gmail.com>').

-behaviour(uni_obj).

-export([
    init/3,
    compute/3
]).

-record(state, {
	x = 0,
	y = 0,
	a = 0
}).

init(_Id, _Capsule, _Args) ->
    {ok,  #state{}}.

compute(Id, Tick, State) ->
	X = State#state.x,
	Y = State#state.y,
	A = State#state.a,
	Data = [{position, [
		{x, round(100 * math:sin(X / 100))},
		{y, round(100 * math:cos(Y / 100))}
	]}, {angle, A}, {type, ship}],
    uni_store:save(Tick, Id, Data),
    State#state{x = X + 1, y = Y + 1, a = (A + 1) rem 360}.
