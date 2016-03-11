-module(hw_sup).

-behaviour(supervisor).

%% API
-export([start_link/1]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, [Port]}, permanent, 5000, Type, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================
%Супервизор отвечает за запуск, остановку и мониторинг своих дочерних процессов. 
%Основная задача супервизора состоит в том,
%что он должен поддерживать свои дочерние процессы 
%в рабочем состоянии, перезапуская их по мере необходимости.

start_link(Port) ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, [Port]).

start_link() ->
  {ok, Port} = application:get_env(edns, port),
  start_link(Port).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([Port]) ->
    {ok, { {one_for_one, 5, 100}, [?CHILD(hw, worker)]}}.

