-module(uni_out).

-behaviour(gen_server).

-export([
    start_link/0
]).

-export([
    init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3
]).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

%% @hidden
init(_Args) ->
    {ok, nil}.

%% @hidden
handle_call(_Message, _From, State) ->
    {noreply, State}.

%% @hidden
handle_cast(_Message, State) ->
    {noreply, State}.

%% @hidden
handle_info({tick, Tick}, _State) ->
	send_all(ets:match(uni_store, {'$1', Tick, '$2'}, 20)).

send_all('$end_of_table') ->
	ok;
send_all({[], Continuation}) ->
	send_all(ets:match(Continuation));
send_all({[R|T], Continuation}) ->
	pg2:send(ws_handlers, {data, R}),
	send_all({T, Continuation}).

%% @hidden
terminate(_Reason, _State) ->
    ok.

%% @hidden
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
