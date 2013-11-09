%% @author Stanislav Seletskiy <s.seletskiy@gmail.com>
%% @doc Encapsulated Object (maybe with modules).
-module(uni_capsule).
-created('Date: 09/11/2013').
-created_by('Stanislav Seletskiy <s.seletskiy@gmail.com>').

-behaviour(supervisor).

-export([
    start_link/3,
    add_child/4,
    init/1
]).

start_link(Id, Module, Args) ->
    {ok, Pid} = supervisor:start_link(?MODULE, []),
    add_child(Pid, Id, Module, Args),
    {ok, Pid}.

add_child(Pid, Id, Module, Args) ->
    supervisor:start_child(Pid, [Id, Pid, Module, Args]).

init(_Args) ->
    {ok, {{simple_one_for_one, 5, 60}, [
        {undefined,
            {uni_obj, start_link, []},
            permanent,
            brutal_kill,
            worker,
            [uni_obj]}
    ]}}.
