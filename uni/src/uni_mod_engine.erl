%% @author Stanislav Seletskiy <s.seletskiy@gmail.com>
%% @doc Object Module Extension.
-module(uni_mod_engine).
-created('Date: 09/11/2013').
-created_by('Stanislav Seletskiy <s.seletskiy@gmail.com>').

init(_Id, _Capsule, _Args) ->
    {ok, nil}.

compute(Id, Tick, State) ->
    uni_store:save(Tick, Id, "My Custom Data"),
    NewState = State,
    NewState.
