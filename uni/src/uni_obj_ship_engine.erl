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

-record(state, {
    ship_pid,
    ship_id,
    circuit
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
    case BinData of
        nil ->
            ok;
        Something ->
            {ok, [DX, DY], []} = io_lib:fread("~f ~f", binary_to_list(Something)),
            uni_obj:send_neigh(Tick, State#state.ship_pid, {veloc, {DX, DY}})
    end,
    State.
