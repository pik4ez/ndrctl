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
    accel = {0, 0},
	speed = {0, 0},
	noozles = {0, 0 ,0},
    modules = []
}).

init(_Id, _Capsule, Args) ->
    {ok,  #state{modules = Args}}.

boot(Id, Capsule, State) ->
    uni_circuit:register_ship(Id),
    start_modules(Id, State#state.modules, Capsule),
    State.

intercom(_Id, {accel, Accel}, State) ->
    State#state{accel = Accel}.

compute(Id, Tick, State) ->
    {DX, DY} = State#state.accel,
	{VX, VY} = State#state.speed,
	X = State#state.x + VX,
	Y = State#state.y + VY,
	A = State#state.a + DX * 1000,
	DX2 = math:cos(A * math:pi() / 180) * 0 - math:sin(A * math:pi() / 180) * DY,
	DY2 = math:sin(A * math:pi() / 180) * 0 + math:cos(A * math:pi() / 180) * DY,
	Data = [{position, [
		{x, X},
		{y, Y}
	]},
	{angle, A},
	{type, ship}],
    uni_store:save(Tick, Id, Data),
	S = {VX + DX2, VY + DY2},
    State#state{x = X, y = Y, speed = S, a = A}.

start_modules(_Id, [], _) ->
    ok;
start_modules(Id, [{ModId, ErlMod, ErlArgs} | T], Capsule) ->
    uni_capsule:add_child(Capsule, ModId, ErlMod,
    [self(), Id | ErlArgs]),
    start_modules(Id, T, Capsule).
