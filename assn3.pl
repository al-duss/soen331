%% =======================================
%%             FACTS
%% =======================================

%% =========STATES=============== 

%% Overall

state('dormant').
state('init').
state('idle').
state('error_diagnosis').
state('safe_shutdown').
state('monitoring').

%% init

state('boot_hw').
state('senchk').
state('tchk').
state('psichk').
state('ready').

%% monitor

state('monidle').
state('regulate_environment').
state('lockdown').

%% lockdown

state('prep_purge').
state('alt_temp').
state('alt_psi').
state('risk_assess').
state('safe_status').

%% error_diagnosis

state('error_rev').
state('applicable_rescue').
state('reset_module_data').


%% =========initial states========

initial_state('dormant').
initial_state('boot_hw').
initial_state('error_rev').
initial_state('monidle').
initial_state('prep_purge').

%% =========Superstates==========

%% init

superstate('init', 'boot_hw').
superstate('init', 'senchk').
superstate('init', 'tchk').
superstate('init', 'psichk').
superstate('init', 'ready').

%% monitor

superstate(monitor, monidle).
superstate(monitor, lockdown).
superstate(monitor, regulate_environment).

%% lockdown

superstate(lockdown, 'prep purge').
superstate(lockdown, 'alt_temp').
superstate(lockdown, 'alt_psi').
superstate(lockdown, 'risk_assess').
superstate(lockdown, 'safe_status').


%% ===transition(initial_state, final_state, event, guard, action).===

%% overall

transition(dormant, init, start, null, 'retry:=0').
transition(init, idle, 'init_ok', null, null).
transition(init, 'error_diagnosis', 'idle_rescue', null, null).
transition(idle, monitoring, 'begin_monitoring', null, null).
transition(idle, 'error_diagnosis', 'idle_crash', null, 'idle_err_msg').
transition(monitoring, 'error_diagnosis', 'monitor_crash', null, 'moni_err_msg').
transition('error_diagnosis', idle, 'idle_rescue', null, null).
transition('error_diagnosis', monitoring, 'moni_rescue', null, null).
transition('error_diagnosis', init, 'retry_init', 'retry < 3', 'retry++').
transition('error_diagnosis', 'safe_shutdown', shutdown, 'retry >= 3', null).
transition('safe_shutdown', dormant, sleep, null, null).
transition(dormant, exit, kill, null, null).
transition(monitoring, exit, kill, inLockdown, null).

%% init

transition('boot_hw', senchk, 'hw_ok', 'load hardware modules', null).
transition(senchk, tchk, 'sen_ok', 'sensors are ok', null).
transition(tchk, psichk, 't_ok', 'temperature sensors are ok', null).
transition(psichk, ready, 'psi_ok', 'pressure sensors are ok', null).
transition(ready, exit, null, null,null).

%% monitor

transition(monidle, lockdown, 'contagion_alert', 'after(1000ms); hasContagion', 'FACILITY_ERR_MSG ; inLockdown = true').
transition(monidle, 'regulate_environment', 'no_contagion', 'after(1000ms); !hasContagion', null).
transition('regulate_environment', monidle, 'after(100ms)', null, null).
transition(lockdown, lockdown, null, 'inLockdown', null).
transition(lockdown, monidle, 'purge_succ', '!hasContagion', 'inLockdown = false'). 

%% lockdown

transition('prep_vpurge', 'alt_psi', 'initiate_purge', null, 'lock_doors').
transition('prep_vpurge', 'alt_temp', 'initiate_purge', null, 'lock_doors').
transition('alt_psi', 'risk_assess', 'psicyc_comp', null, null).
transition('alt_temp', 'risk_assess', 'tcyc_comp', null, null).
transition('risk_assess', 'safe_status', null, 'risk < 0.01', 'unlock_doors').
transition('risk_assess', 'prep_vpurge', null, 'risk >= 0.01', null).
transition('safe_status', exit, null, null,null).

%% error_diagnosis

transition('error_rcv', 'applicable_rescue', null, 'err_protocol_def', null).
transition('error_rcv', 'reset_module_data', null, '!err_protocol_def', 'reset kernel module data').
transition('reset_module_data', exit, 'reset_to_stable', null, null).
transition('applicable_rescue', exit, 'apply_protocol_rescue', null, null).

%% =======================================
%%             RULES
%% =======================================

%% Same as state_is_reflexive???
is_loop(Event,Guard):- transition(A, A, Event, Guard, _), Event\=='null', Guard\=='null'.

all_loops(Set):- findall([Event, Guard], is_loop(Event, Guard), lst), list_to_set(lst, Set).

%% Same as is_link???
is_edge(Event, Guard):- transition(_,_, Event, Guard, _).

size(Length):- aggregate_all(Count, transition(_,_,_,_,_), Length).

%% same as is_edge???
is_link(Event, Guard):- transition(_,_, Event, Guard, _).

all_superstates(Set):- findall(Initial, superstate(Initial, _), List), list_to_set(List, Set).

ancestor(Ancestor, Descendant):- transition(Ancestor, Descendant, _, _, _).

inheritss_transitions(State,List):-findall([State, Final], (transition(State, Final, _, _, _)), Lst), list_to_set(Lst, List).

all_states(Set):- findall(Current, state(Current), List), list_to_set(List, Set).

all_init_states(Set):- findall(Current, initial_state(Current), List), list_to_set(List, Set).

%% Not so sure..
get_starting_state(State):- superstate(State, Ret), initial_state(Ret), write(Ret).

%%same as is_loop???
state_is_reflexive(State):- transition(State, State, _, _, _).

%% graph_is_reflexive()

get_guards(Ret) :- findall(Guard, transition(_, _, _, Guard, _), List), list_to_set(List, Ret).

get_events(Ret) :- findall(Event, transition(_, _, Event, _, _), List), list_to_set(List, Ret).

get_actions(Ret) :- findall(Action, transition(_, _, _, _, Action), List), list_to_set(List, Ret).

get_only_guarded(Ret) :- findall([Start, Final], (transition(Start, Final, _, Guard, _), Guard\=='null'), List), list_to_set(List, Ret).

legal_events(State, L):- findall([Event, Guard], (transition(State, _, Event, Guard, _), Guard\=='null', Event\=='null'), List), list_to_set(List, L).


















