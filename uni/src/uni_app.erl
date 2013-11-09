-module(uni_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_Type, _Args) ->
	application:start(ranch),
	application:start(crypto),
	application:start(cowlib),
	application:start(cowboy),
	uni_sup:start_link().

stop(_State) ->
	cowboy:stop_listener(),
	ok.
