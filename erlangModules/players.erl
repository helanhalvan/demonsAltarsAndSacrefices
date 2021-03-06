%% @author David
%% @doc @todo Add description to players.


-module(players).
-behavior(supervisor).
%% ====================================================================
%% API functions
%% ====================================================================
-export([start/1,init/1]).

%starts all players in a game using data from options
start(Options)->
	io:write({players_starting}),
	{ok,Pid}=supervisor:start_link(?MODULE, na),
	Judge={judge,{judge,start,[]},permanent,brutal_kill,supervisor,dynamic},
	{ok, JP}=supervisor:start_child(Pid,Judge),
	[{resoureHolder,Holder},{spawnPos,PosList}]=option:get(Options,[{resoureHolder,required},{spawnPos,{default,
							[{pos,{2,2}},
							 {pos,{9,9}},
							 {pos,{2,9}},
							 {pos,{9,2}}]
							}}]),

	[{playerParams,Popts}]=option:get(Options, [{playerParams,{default,[{[{color,{0,0,255}},{controls,	[{up,$W},{down,$S},{left,$A},{right,$D},{{cast,1},$1},{{cast,2},$2},{{cast,3},$3},{{cast,4},$4}]
																		}]},
																		{[{color,{255,0,0}},{controls,	[{up,$I},{down,$K},{left,$J},{right,$L},{{cast,1},$7},{{cast,2},$8},{{cast,3},$9},{{cast,4},$0}]}]}]
															  			}}]),
	startPlayers(Holder,Popts,Pid,PosList,JP),
	io:write({players_done}),
	{ok,Pid}.

%% ====================================================================
%% Internal functions
%% ====================================================================
startPlayers(_,[],_,_,Judge)->ok,judge:done(Judge);
startPlayers(_,_,_,[],_)->io:write({out_of_spawn_pos});
startPlayers(Holder,[{Opts}|T1],Pid,[Pos|T2],Judge)->
	Name=erlang:make_ref(),
	Options=lists:flatten([Opts|[{resHolder,Holder},{name,Name},Pos]]),
	Player={Name,{player,start,[Options]},permanent,brutal_kill,supervisor,dynamic},
	{ok,PPid}=supervisor:start_child(Pid,Player),
	judge:newPlayer(Judge,PPid),
	startPlayers(Holder,T1,Pid,T2).
init(_args)->
	%currently there is no reason to try to restart after a component fails
	RestartPlan={one_for_all, 0, 120},
	Children=[],
	{ok,{RestartPlan,Children}}.