%% @author Stanislav Seletskiy <s.seletskiy@gmail.com>
%% @doc Object supervisor.
-module(uni_obj_sup).
-created('Date: 09/11/2013').
-created_by('Stanislav Seletskiy <s.seletskiy@gmail.com>').

-behaviour(supervisor).

-export([
    start_link/0,
    init/1
]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init(_Args) ->
    {ok, {{one_for_one, 5, 60}, [
        {test_ship_1,
            {uni_obj_ship, start_link, []},
            permanent,
            brutal_kill,
            worker,
            [uni_obj_ship]}
    ]}}.
