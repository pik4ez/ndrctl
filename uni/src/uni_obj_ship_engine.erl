%% @author Stanislav Seletskiy <s.seletskiy@gmail.com>
%% @doc Object Module Extension.
-module(uni_obj_ship_engine).
-created('Date: 09/11/2013').
-created_by('Stanislav Seletskiy <s.seletskiy@gmail.com>').

-export([
    init/3,
    compute/3,
    boot/3
]).

-record(nozzle, {
	cur = 0,
	set = 0
}).

-record(state, {
    ship_pid,
    ship_id,
    circuit,
	left = #nozzle{
		cur = 0,
		set = 0
	},
	center = #nozzle{
		cur = 0,
		set = 0
	},
	right = #nozzle{
		cur = 0,
		set = 0
	},
	power = 0.001
}).

init(_Id, _Capsule, [ShipPid, ShipId | _Args]) ->
    {ok, #state{
        ship_pid = ShipPid,
        ship_id = ShipId
    }}.

boot(Id, _Capsule, State) ->
    {ok, Circuit} = uni_circuit:register_module(State#state.ship_id, Id,
        [is_sensor, is_affector]),
    State#state{circuit = Circuit}.

compute(_Id, Tick, State) ->
    {ok, BinData} = uni_circuit:poll_module(State#state.circuit),
    State2 = case BinData of
        nil ->
			State;
        Something ->
			{ok, [L, C, R], []} = io_lib:fread("~f ~f ~f", binary_to_list(Something)),
			State#state{left = #nozzle{cur = L}, center = #nozzle{cur = C}, right = #nozzle{cur = R}}
    end,
	Vx = State2#state.right#nozzle.cur - State2#state.left#nozzle.cur,
	Vy = State2#state.center#nozzle.cur,
	Vl = math:sqrt(Vx*Vx + Vy*Vy),
	{Dx, Dy} = case abs(Vl) of
		M when M < 0.000000001 ->
			{0, 0};
		_ ->
			{Vx / Vl * State#state.power, Vy / Vl * State#state.power}
	end,
	uni_obj:send_neigh(Tick, State#state.ship_pid, {accel, {Dx, Dy}}),
    State2.
