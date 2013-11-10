%% @author Stanislav Seletskiy <s.seletskiy@gmail.com>
%% @doc Abstract Object.
-module(uni_obj).
-created('Date: 09/11/2013').
-created_by('Stanislav Seletskiy <s.seletskiy@gmail.com>').

-behaviour(gen_server).

-export([
    start_link/4,
    send_sensor/3,
    send_neigh/3,
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
    capsule,
    cb_name,
    cb_state,
    msg_buf = [],
    birth = -1
}).

behaviour_info(callbacks) ->
    [
        {init, 3},
        {intercom, 3},
        {boot, 3},
        {compute, 3}].

send_neigh(Tick, Pid, Msg) ->
    gen_server:cast(Pid, {ticked_send, Tick, neigh, Msg}).

send_sensor(Tick, Pid, Msg) ->
    gen_server:cast(Pid, {ticked_send, Tick, sensor, Msg}).

start_link(Id, Capsule, Module, Args) ->
    gen_server:start_link(?MODULE, [Id, Capsule, Module, Args], []).

%% @hidden
init([Id, Capsule, Module, Args]) ->
    uni_clock:join(self()),
	{ok, Mst} = Module:init(Id, Capsule, Args),
    {ok, #state{
        id  = Id,
        capsule = Capsule,
        cb_name = Module,
		cb_state = Mst
    }}.

%% @hidden
handle_call(_Message, _From, State) ->
    {noreply, State}.

%% @hidden
handle_cast(A = {ticked_send, _Tick, _Target, _Msg}, State) ->
    {noreply, State#state{msg_buf = [A | State#state.msg_buf]}};
handle_cast(_Message, State) ->
    {noreply, State}.

%% @hidden
handle_info({tick, Tick}, State) ->
    Module = State#state.cb_name,
    State2 = case State#state.birth of
        -1 ->
            CbState2 = Module:boot(State#state.id, State#state.capsule, State#state.cb_state),
            State#state{cb_state = CbState2, birth = Tick};
        _ ->
            State
    end,
    CbState3 = Module:compute(State2#state.id, Tick, State2#state.cb_state),
    send_buffered_msgs(lists:reverse(State2#state.msg_buf), Tick),
    {noreply, State2#state{cb_state = CbState3, msg_buf = []}};
handle_info({intercom, Msg}, State) ->
    Module = State#state.cb_name,
    ModState = Module:intercom(State#state.id, Msg, State#state.cb_state),
    {noreply, State#state{cb_state = ModState}};
handle_info(_Info, State) ->
    {noreply, State}.

%% @hidden
terminate(_Reason, _State) ->
    ok.

%% @hidden
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

send_buffered_msgs([], _) ->
    ok;
send_buffered_msgs([{ticked_send, Tick, Type, Msg} | T], CurrTick)
        when Tick =:= CurrTick - 1 ->
    case Type of
        sensor ->
            % write to sensor
            ok;
        neigh ->
            self() ! {intercom, Msg}
    end,
    send_buffered_msgs(T, CurrTick);
send_buffered_msgs([C | T], CurrTick) ->
    send_buffered_msgs(T, CurrTick).
    
