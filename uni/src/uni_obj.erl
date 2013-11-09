%% @author Stanislav Seletskiy <s.seletskiy@gmail.com>
%% @doc Abstract Object.
-module(uni_obj).
-created('Date: 09/11/2013').
-created_by('Stanislav Seletskiy <s.seletskiy@gmail.com>').

-behaviour(gen_server).

-export([
    start_link/2,
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
    cpl,
    mod,
    mst %% module state
}).

behaviour_info(callbacks) ->
    [
        {init, 1},
        {compute, 2}].

start_link(Module, Args) ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [
        Module, Args], []).

%% @hidden
init(MFA = [Capsule, Module, Args]) ->
    uni_clock:join(self()),
    {ok, #state{
        cpl = Capsule,
        mod = Module,
        mst = Module:init([Capsule] ++ Args)
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
    NewModState = Module:compute(Tick, State#state.mst),
    {noreply, State#state{mst = NewModState}};
handle_info(_Info, State) ->
    {noreply, State}.

%% @hidden
terminate(_Reason, _State) ->
    ok.

%% @hidden
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
