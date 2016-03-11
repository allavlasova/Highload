-module(hw_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).
-define(PORT, 8080).
%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    %case hw_sup:start_link(?PORT) of
    case hw_sup:start_link(?PORT) of
		{ok, Pid} ->
			{ok, Pid};
		Error ->
			Error
	end.

stop(_State) ->
    ok.
