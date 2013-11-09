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

init(_Id, _Capsule, _Args) ->
    {ok, nil}.

compute(Id, Tick, State) ->
    uni_store:save(Tick, Id, "My Custom Data"),
    NewState = State,
    NewState.
