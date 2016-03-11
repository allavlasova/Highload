-module (hw).
-define(SERVER, ?MODULE). 
-behaviour (gen_server).
%сокет который будет принимать запросы на новый процессы
%стандартные функции gen_server
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).


-export ([start_link/1]).

-record (state, {port, 
	socket,
	 acceptors,
	 open_reqs}).

start_link(Port) ->
	State = #state{port = Port},
    gen_server:start_link({local, ?SERVER}, ?MODULE, State, []).

init(State = #state{port=Port}) ->
	{ok, Socket} = hw_server:listen(Port),
	%выделяем сет под акцепторы
	Acceptors = ets:new(acceptors, [private, set]),
	StartAcc  = fun() ->
        Pid = hw_http:start(self(), Socket),
        ets:insert(Acceptors, {Pid})
    end,
    [StartAcc() || _ <- lists:seq(1, 20)], %minaccept
    {ok, #state{socket = Socket,
                acceptors = Acceptors,
                open_reqs = 0}}.

start_add_acceptor(State) ->
    Pid = hw_http:start(self(), State#state.socket),
    ets:insert(State#state.acceptors, {Pid}),
    State#state{open_reqs = State#state.open_reqs + 1}.


handle_cast(accepted, State) ->
    {noreply, start_add_acceptor(State)};

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_call(stop, _From, State) ->
    {stop, normal, ok, State}.
handle_info(_Msg, Library) -> {noreply, Library}.
terminate(_Reason, _Library) -> ok.
code_change(_OldVersion, Library, _Extra) -> {ok, Library}.
