-module(uni_ws_handler).

-behaviour(cowboy_websocket_handler).

-export([
	init/3,
	websocket_init/3,
	websocket_handle/3,
	websocket_info/3,
	websocket_terminate/3
]).

init({tcp, http}, _Req, _Opts) ->
	pg2:join(ws_handlers, self()),
	{upgrade, protocol, cowboy_websocket}.

websocket_init(tcp, Req, _Opts) ->
	{ok, Req, undefined_state}.

websocket_handle(_InFrame, Req, State) ->
	{ok, Req, State}.

websocket_info({data, Data}, Req, State) ->
	{reply, {text, io_lib:format("~p", [Data])}, Req, State}.

websocket_terminate(_Reason, _Req, _State) ->
	ok.
