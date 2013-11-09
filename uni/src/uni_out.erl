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
	uni_clock:join(self()),
    {ok, nil}.

%% @hidden
handle_call(_Message, _From, State) ->
    {noreply, State}.

%% @hidden
handle_cast(_Message, State) ->
    {noreply, State}.

%% @hidden
handle_info({tick, _Tick}, State) ->
	send_all(ets:match_object(uni_state, {'$1', '_', '$2'}, 20)),
	{noreply, State}.

send_all('$end_of_table') ->
	send_all_ws(pg2:get_members(ws_handlers), send);
send_all({[], Continuation}) ->
	send_all(ets:match_object(Continuation));
send_all({[R|T], Continuation}) ->
	send_all_ws(pg2:get_members(ws_handlers), {slice, R}),
	send_all({T, Continuation}).

send_all_ws([], _) ->
	ok;
send_all_ws([Member | Tail], Data) ->
	Member ! Data,
	send_all_ws(Tail, Data).

%% @hidden
terminate(_Reason, _State) ->
    ok.

%% @hidden
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
