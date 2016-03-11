-module(hw_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).
-define(PORT, 8080).
-define(CPUS, 1).
%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    %case hw_sup:start_link(?PORT) of
    %io:format("Args: ~p\n", [_StartArgs]),
    case ?CPUS > 0 of
        true ->
            erlang:system_flag(schedulers_online, ?CPUS);
        false ->
            ok
    end,
    case hw_sup:start_link(?PORT) of
		{ok, Pid} ->
			{ok, Pid};
		Error ->
			Error
	end.

stop(_State) ->
    ok.
