-module(uni_store).

-behaviour(gen_server).

-export([
    start_link/0
]).

-export([
    load/1,
    save/3
]).

-export([
    init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3
]).

load(ObjId) ->
    case ets:match_object(uni_state, {ObjId, '$1', '$2'}) of
        [Result] ->
            Result;
        [] ->
            nil
    end.

save(Tick, ObjId, ObjState) ->
    gen_server:cast(?MODULE, {save, Tick, ObjId, ObjState}).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

%% @hidden
init(_Args) ->
    ets:new(uni_state, [named_table, protected]),
    {ok, nil}.

%% @hidden
handle_call(_Message, _From, State) ->
    {noreply, State}.

%% @hidden
handle_cast({save, Tick, ObjId, ObjState}, State) ->
    ets:insert(uni_state, {ObjId, Tick, ObjState}),
    {noreply, State};
handle_cast(_Message, State) ->
    {noreply, State}.

%% @hidden
handle_info(_Info, State) ->
    {noreply, State}.

%% @hidden
terminate(_Reason, _State) ->
    ok.

%% @hidden
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
