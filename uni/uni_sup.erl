-module(uni_sup).

-behaviour(supervisor).

-export([
	start_link/0,
	init/1
]).

start_link() ->
	supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init(_Args) ->
	{ok, {{one_for_one, 5, 60}, [
		{output,
			{uni_output, start_link, []},
			permanent,
			brutal_kill,
			worker,
			[output]},
		{store,
			{uni_store, start_link, []},
			permanent,
			1000,
			worker,
			[store]},
		{clock,
			{uni_clock, start_link, []},
			permanent,
			brutal_kill,
			worker,
			[clock]},
		{obj_sup,
			{uni_obj_sup, start_link, []},
			permanent,
			brutal_kill,
			worker,
			[obj_sup]}
	]}}.
