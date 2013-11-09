%% @author Stanislav Seletskiy <s.seletskiy@gmail.com>
%% @doc Ship Object.
-module(uni_obj_ship).
-created('Date: 09/11/2013').
-created_by('Stanislav Seletskiy <s.seletskiy@gmail.com>').

-behaviour(uni_obj).

-export([
    init/3,
    boot/3,
    intercom/3,
    compute/3
]).

-record(state, {
	x = 0,
	y = 0,
	a = 0,
    veloc = {0, 0},
    modules = []
}).

init(_Id, _Capsule, Args) ->
    {ok,  #state{modules = Args}}.

boot(Id, Capsule, State) ->
    uni_circuit:register_ship(Id),
    start_modules(Id, State#state.modules, Capsule),
    State.

intercom(_Id, {veloc, Veloc}, State) ->
    State#state{veloc = Veloc}.

compute(Id, Tick, State) ->
    {DX, DY} = State#state.veloc,
	X = State#state.x + DX,
	Y = State#state.y + DY,
	A = State#state.a,
	Data = [{position, [
		{x, X},
		{y, Y}
	]}, {angle, A}, {type, ship}],
    uni_store:save(Tick, Id, Data),
    State#state{x = X, y = Y}.

start_modules(_Id, [], _) ->
    ok;
start_modules(Id, [{ModId, ErlMod, ErlArgs} | T], Capsule) ->
    uni_capsule:add_child(Capsule, ModId, ErlMod,
    [self(), Id | ErlArgs]),
    start_modules(Id, T, Capsule).
