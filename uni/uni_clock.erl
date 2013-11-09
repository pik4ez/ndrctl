-module(uni_clock).

-behaviour(gen_server).

init(_Args) ->
	{ok, nil}.

handle_call(_Message, _From, State) ->
	{noreply, State}.

handle_cast(_Message, State) ->
	{noreply, State}.

handle_cast(_Message, State) ->
	{noreply, State}.

terminate(_Reason, State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}
