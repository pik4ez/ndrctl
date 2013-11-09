-module(uni_out_sup).

-behaviour(supervisor).

-export([
	start_link/0,
	init/1
]).

start_link() ->
	supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init(_Args) ->
	Routes = cowboy_router:compile([
		{'_',  [
			{"/v1/universe", uni_ws_handler, []}
		]}]),
	{ok, {{one_for_one, 5, 60}, [
		{out,
			{uni_out, start_link, []},
			permanent,
			5000,
			supervisor,
			[out]},
		ranch:child_spec(out_ws_pool, 2,
			ranch_tcp, [{port, 8080}],
			cowboy_protocol, [{env, [{dispatch, Routes}]}])
	]}}.
