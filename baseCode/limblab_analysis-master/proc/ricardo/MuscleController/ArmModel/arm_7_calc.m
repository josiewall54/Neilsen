function [Q1, U1, KE, PE] = arm_7_calc(Q, U, Torq_pas, T, integ_params, arm_params, DOF, passive_damp, constraint_forces)
% Integrates forward using arm model.
% Based off arm_7_sub.c by Dan Moran
% 1. Inputs: Joint angles (Q-rad) = 1x7
%            Joint angular velocities (U-rad/s) = 1x7
%            Passive joint torques (Torq_pas) = 1x7
%            Current time (T) = scalar
%            Integration parameters (integ_params) = structure
%            Arm Parameters (arm_params) = structure that defines the
%               parameters of the arm whether it is human or monkey.
%            Degrees of Freedom = 7 for this arm model.
%            Passive Dampening Toggle = 0/1
%            Constraint Forces Toggle = 0/1
%
% 2. Calculates the angles and angular velocities generated by the torque
%     inputs and initial conditions.
% 3. Outputs the new joint angles and angular velocities.
%
% Created by Sherwin Chan
% Date: 2/19/2004
% Revision history: 
%   5/12/2004 SSC
%       -included odefun1 as a subfunction in this file
%   12/14/2004 SSC
%       -added passive damping of the arm as a variable.
%   2/25/2005 SSC
%       -Experimenting with adding in constraint forces to keep the arm withing
%        the workspace.  These constraint forces must be compensated for in the
%        inverse model.
%   10/25/2005 SSC
%       -Turned constraint forces off to debug the calc_avg_jt_for_task routine.

if nargin < 8
    passive_damp = 0;
    constraint_forces = 0;
end

% Assigns starting conditions
Temp(1:7) = Q';
Temp(8:14) = U';

% [COEF, RHS] = arm_zees(arm_params, Q, U, DOF);

% Integrate one time step forward
OPTIONS = odeset('RelTol', integ_params.Relerr, 'AbsTol', integ_params.Abserr);
Time = [T T+integ_params.Integstp];

[t,y] = ode45(@odefun1, Time, Temp, OPTIONS, arm_params, Torq_pas, DOF, passive_damp, constraint_forces);

% Resets variables after integration step
Q1 = [y(end, 1:7)];
U1 = [y(end, 8:14)];

[COEF, RHS, KE, PE] = arm_zees(arm_params, Q1, U1, Torq_pas, DOF);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NextStep = odefun1(Time, InitCond, arm_params, Torq_pas, DOF, passive_damp, constraint_force_on)
% Sets up differential equations used in differential equations solver (ODE45).
% 
% 1. Inputs: Initial conditions -> Joint angles (InitCond(1:7)) = 7x1 (rad)
%            Initial conditions -> Joint angular velocities (InitCond(8:14)) = 7x1 (rad/s)
%            Arm Parameters (arm_params) = structure that defines the
%               parameters of the arm whether it is human or monkey.
%            Degrees of Freedom (DOF) = 7 in the arm.
%            Passive Dampening Toggle = 0/1
%            Constraint Forces Toggle = 0/1
%
% 2. Calculates the angular velocity and the angular acceleration based on
%       the differential equations for the arm supplied by AutoLev.
%
% 3. Outputs: Final conditions -> Joint angular velocities (NextStep(1:7)) = 7x1
%             Final conditions -> Joint angular accelerations (NextStep(8:14)) = 7x1
%
% Created by Sherwin Chan
% Date: 2/24/2004
% Last modified :
%   4/2/2004 SSC
%       -Removed passive damping of the arm in this version.
%   12/14/2004 SSC
%       -Added passive damping of the arm as a variable.
%   2/25/2005 SSC
%       -Experimenting with adding in constraint forces to keep the arm withing
%        the workspace.  These constraint forces must be compensated for in the
%        inverse model.
%   
%

% Process the input variables, default is set to no passive dampening and
% include constraint forces to prevent arm from assuming wierd positions.
if nargin == 5
    passive_damp = 0;
    constraint_force_on = 1;
elseif nargin == 6
    constraint_force_on = 0;
end

Q = InitCond(1:7)';
U = InitCond(8:14)';
% Qdot = U;

if passive_damp
    % This passive dampening is required in the test model for the arm for
    % some reason...  still needs to be explored whether this is neccessary
    % for the database processing.
    Torq_pas = Torq_pas - (0.1 .* U);
end

if constraint_force_on
    constraint_forces = calc_constraint_forces(Q);
    Torq_pas = Torq_pas + constraint_forces;
end

[COEF, RHS, KE, PE] = arm_zees(arm_params, Q, U, Torq_pas, DOF);

Temp1 = COEF\RHS;
% Temp1 = inv(COEF)*RHS;
% Udot = Temp1'

NextStep(1:7,1) = U';
NextStep(8:14,1) = Temp1;