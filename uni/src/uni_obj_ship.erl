%% @author Stanislav Seletskiy <s.seletskiy@gmail.com>
%% @doc Ship Object.
-module(uni_obj_ship).
-created('Date: 09/11/2013').
-created_by('Stanislav Seletskiy <s.seletskiy@gmail.com>').

-behaviour(uni_obj).

-export([
    init/1,
    compute/2
]).

init([_Capsule | _Args]) ->
    {ok, nil}.

compute(Tick, State) ->
    NewState = State,
    NewState.
