%% @author Stanislav Seletskiy <s.seletskiy@gmail.com>
%% @doc FUSE MADNESS!
-module(uni_circuit).
-created('Date: 10/11/2013').
-created_by('Stanislav Seletskiy <s.seletskiy@gmail.com>').

-export([
    connect/0,
    register_ship/1,
    register_module/3,
    poll_module/1
]).

-define(CIRCUIT, 'circuit@v.hack.s').

connect() ->
    net_kernel:connect_node(?CIRCUIT).

register_ship(ShipId) ->
    erlang:display(rpc:call(?CIRCUIT, relay, register_fs, [ShipId], 5000)).

register_module(ShipId, ModId, Tags) ->
    rpc:call(?CIRCUIT, relay, register_device, [ShipId, ModId, Tags], 5000).

poll_module(Id) ->
    gen_server:call({Id, ?CIRCUIT}, req, 5000).
