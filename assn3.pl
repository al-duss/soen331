%% =========RULES================

%% =========STATES=============== 

%% Overall

state(dormant).
state(init).
state(idle).
state('error_diagnosis').
state('safe_shutdown').
state(monitoring).

%% init

state('boot_hw').
state(senchk).
state(tchk).
state(psichk).
state(ready).

%% monitor

state(monidle).
state('regulate_environment').
state(lockdown).

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

initial_state(dormant).
initial_state('boot_hw').
initial_state('error_rev').
initial_state(monidle).
initial_state('prep_purge').

%% =========Superstates==========

%% init

superstate(init, 'boot_hw').
superstate(init, senchk).
superstate(init, tchk).
superstate(init, psichk).
superstate(init, ready).

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


%% ===transition(initial_state, final_state, guard, event, action).===




