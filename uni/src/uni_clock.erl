-module(uni_clock).

-behaviour(gen_server).

-export([
    join/1
]).

-export([
    start_link/1,
    init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3
]).

-record(state, {
    freq :: integer(),
    tick :: integer()
}).

join(Pid) ->
    pg2:join(tickers, Pid).

start_link(Freq) ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [Freq], []).

%% @hidden
init([Freq]) ->
    pg2:create(tickers),
    erlang:send_interval(Freq, tick),
    {ok, #state{freq = Freq, tick = 0}}.

%% @hidden
handle_call(_Message, _From, State) ->
    {noreply, State}.

%% @hidden
handle_cast(_Message, State) ->
    {noreply, State}.

%% @hidden
handle_info(tick, State) ->
    tick_all(pg2:get_members(), State#state.tick),
    {noreply, State#state{tick = State#state.tick + 1}};

handle_info(_Info, State) ->
    {noreply, State}.

%% @hidden
terminate(_Reason, _State) ->
    ok.

%% @hidden
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

tick_all([], _) ->
    ok;

tick_all([Member | Tail], Tick) ->
    Member ! {tick, Tick},
    tick_all(Tail, Tick).
