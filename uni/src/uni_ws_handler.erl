-module(uni_ws_handler).

-behaviour(cowboy_websocket_handler).

-export([
	init/3,
	websocket_init/3,
	websocket_handle/3,
	websocket_info/3,
	websocket_terminate/3
]).

-record(state, {
	collector = []
}).

init({tcp, http}, _Req, _Opts) ->
	pg2:join(ws_handlers, self()),
	{upgrade, protocol, cowboy_websocket}.

websocket_init(tcp, Req, _Opts) ->
	{ok, Req, #state{}}.

websocket_handle(_InFrame, Req, State) ->
	{ok, Req, State}.

websocket_info({slice, {_, _, Row}}, Req, State) ->
	{ok, Req, State#state{
		collector = State#state.collector++[Row]}};
websocket_info(send, Req, State) ->
	{reply, {text, jsonx:encode(
		 State#state.collector)}, Req, #state{}}.

websocket_terminate(_Reason, _Req, _State) ->
	ok.
