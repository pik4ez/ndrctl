%% @author Stanislav Seletskiy <s.seletskiy@gmail.com>
%% @doc Encapsulated Object (maybe with modules).
-module(uni_obj_capsule).
-created('Date: 09/11/2013').
-created_by('Stanislav Seletskiy <s.seletskiy@gmail.com>').

-behaviour(supervisor).

-export([
    start_link/2,
    init/1
]).

start_link(Module, Args) ->
    {ok, Pid} = supervisor:start_link(?MODULE, []),
    supervisor:start_child(Pid, [Pid, Module, Args]),
    {ok, Pid}.

init(_Args) ->
    {ok, {{simple_one_for_one, 5, 60}, [
        {undefined,
            {uni_obj, start_link, []},
            permanent,
            brutal_kill,
            worker,
            [uni_obj]}
    ]}}.
