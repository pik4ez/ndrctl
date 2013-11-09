%% @author Stanislav Seletskiy <s.seletskiy@gmail.com>
%% @doc Abstract Object.
-module(uni_obj).
-created('Date: 09/11/2013').
-created_by('Stanislav Seletskiy <s.seletskiy@gmail.com>').

-behaviour(gen_server).

-export([
    start_link/4,
    behaviour_info/1
]).

-export([
    init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3
]).

-record(state, {
    id,
    cpl,
    mod,
    mst %% module state
}).

behaviour_info(callbacks) ->
    [
        {init, 3},
        {compute, 3}].

start_link(Id, Capsule, Module, Args) ->
    gen_server:start_link(?MODULE, [Id, Capsule, Module, Args], []).

%% @hidden
init([Id, Capsule, Module, Args]) ->
    uni_clock:join(self()),
	{ok, Mst} = Module:init(Id, Capsule, Args),
    {ok, #state{
        id  = Id,
        cpl = Capsule,
        mod = Module,
		mst = Mst
    }}.

%% @hidden
handle_call(_Message, _From, State) ->
    {noreply, State}.

%% @hidden
handle_cast(_Message, State) ->
    {noreply, State}.

%% @hidden
handle_info({tick, Tick}, State) ->
    Module = State#state.mod,
    NewModState = Module:compute(State#state.id, Tick, State#state.mst),
    {noreply, State#state{mst = NewModState}};
handle_info(_Info, State) ->
    {noreply, State}.

%% @hidden
terminate(_Reason, _State) ->
    ok.

%% @hidden
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
