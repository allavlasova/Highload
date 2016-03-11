-module(hw_server).
-define(SERVER, ?MODULE). 
-define(TCP_OPTIONS, [binary, {packet,http}, {active, false},{reuseaddr, true}]).
%% API.
-export ([listen/1, accept/2]).


listen(Port) ->
    case gen_tcp:listen(Port, ?TCP_OPTIONS) of
        {ok, LSocket} ->	
            {ok, LSocket};
        {error, Reason} ->
            {error, Reason}
    end.

accept(LSocket, Server) ->
    case gen_tcp:accept(LSocket) of
        {ok, S} ->
        	%Мы используем gen_server:cast 
        	%для передачи асинхронных сообщений в главный процесс. 
        	%Когда главный процесс получает сообщение «соединение установлено» 
        	%он создает нового «слушателя».
            gen_server:cast(Server, accepted),
            {ok, S};
        {error, Reason} ->
            {error, Reason}
    end.




