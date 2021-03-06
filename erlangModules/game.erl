%% @author David
%% @doc @todo Add description to game.


-module(game).
-behaviour(supervisor).
%% ====================================================================
%% API functions
%% ====================================================================
-export([start/1,start/0,init/1]).
start()->start([]).
start(Options)->
	{ok,GM}=supervisor:start_link(game, na),
	
	%keeps track of game resources like eventhandlers, boards etc
	GameResourceMonitor={resmon,{keyValueStore,start,[]},permanent,brutal_kill,worker,dynamic},
	{ok,ResHoldPid}=supervisor:start_child(GM,GameResourceMonitor),
	
	%extract options from start list
	[{board,Bopts},{player,Popts}]=option:get(Options,[{board,{default,[]}},{player,{default,[]}}]),
	
	%add start paramters for children
	Bopts2=[{eventReciver,ResHoldPid}|Bopts],
	Popts2=[{resoureHolder,ResHoldPid},Popts],
	
	%A board holds all shared information all players can access, also creates an eventhandler as a side effect.
	Board={board,{board,start,[Bopts2]},permanent,brutal_kill,supervisor,dynamic},
	{ok,_Bpid}=supervisor:start_child(GM,Board),

	%Players monitors all players, and determines the winner
	Players={players,{players,start,[Popts2]},permanent,brutal_kill,supervisor,dynamic},
	{ok,_}=supervisor:start_child(GM,Players),
	
	{ok,GM}.
%% ====================================================================
%% Internal functions
%% ====================================================================
init(_args)->
	%currently there is no reason to try to restart after a component fails
	RestartPlan={one_for_all, 0, 120},
	Children=[],
	{ok,{RestartPlan,Children}}.