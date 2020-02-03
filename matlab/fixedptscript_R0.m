clear all
clc

%%Cart Pendulum System Parameters%
M = 4.676;      % Mass(kg) of the cart ( 2.03+2.646= 4.676)
m=0.098;        % mass(kg) of the pendulum (0.098)
l=0.285;        % length(m) of the pendulum (0.285)
g=9.80665;      % accceleration due to gravity (m/s^2)
kf=0.08;        % friction
Ts=10e-3;       % Sampling Time ( 10ms)
f = 100;        % Samplig frequency ( 100Hz)
x0=[0;0;0;0];   % Initial condition of the system
%Linear Model 
A = [ 0 -(M+m)*g/(M*l) 0 0 ; 1 0 0 0 ; 0 m*g/M 0 0 ; 0 0 1 0 ];
B = [-1/(M*l); 0; 1/M ;0 ];
C = eye(4);
D = [0; 0; 0; 0];
% State_feedabck using Ackerman's Formula %
S = [ B (A*B) ((A^2)*B) ((A^3)*B) ]; % controllability Matrix
R=rank(S);
Sinv = inv(S); % Inverse of controllability Matrix
qt = Sinv(4,1:4); % last row of inverse of controllability matrix
%alpha = poly([(-3) (-3) (-3) (-3)]); % the desired pole placement 
alpha = poly([(-4) (-4) (-4) (-4)]); % the desired pole placement
%alpha = poly([(-1) (-1) (-1) (-1)]); % the desired pole placement
Palpha=((alpha(5)*eye(4))+(alpha(4)*A)+(alpha(3)*(A^2))+(alpha(2)*(A^3))+(A^4));% Characteristic polynomial
k =(qt*Palpha); % Ackerman formula; state feeposition2dback gain vector
p=1/([0 0 0 1]*(((B*k)-A)^-1)*B); % preamplifier
%p=15;
kadp = k - p*C(4,1:4); % k_corrected
%% Adding an Integrator %
A1=[A [0;0;0;0] ; -C(4,1:4)  0];
B1= [B ; 0];
C1= [0 0 0 1 0];
D1=[0; 0; 0; 0; 0];
S1 = [B1 (A1*B1) ((A1^2)*B1) ((A1^3)*B1) ((A1^4)*B1)];%controllability Matrix
R1=rank(S1);
S1inv = inv(S1); % Inverse of controllability Matrix
qt1 = S1inv(5,1:5); % last row of inverse of controllability matrix
%alpha1 = poly([(-3) (-3) (-3) (-3) (-3)]); % the desired polynomial
alpha1 = poly([(-4) (-4) (-4) (-4) (-4)]); % the desired polynomial
Palpha1 = ((alpha1(6)*eye(5)) + (alpha1(5)*A1) + (alpha1(4)*(A1^2))+(alpha1(3)*(A1^3)) + (alpha1(2)*(A1^4)) + (A1^5));
k1 = (qt1*Palpha1);% Ackerman formula ;
ki = -k1(5); % the fifth element is the integeral gain
Ctk=[0 0 0 1];
kt_pi= k1(1:4)-p*Ctk; % Kt_Pi adaption due to output feedback

%% Discrete_Time_model %
sys=ss(A1,B1,C1,0);
sysd=c2d(sys,Ts);
[Ad,Bd,Cd,Dd]=ssdata(sysd);
% statefeedback vector
Spi_d=[Bd Ad*Bd Ad^2*Bd Ad^3*Bd Ad^4*Bd ];
Sinv_d=inv(Spi_d);
qpi_d = Sinv_d(5,1:5);
%sys_pi=tf(1,poly([-3,-3,-3,-3,-3])); % desired polynomial
%sys_pi=tf(1,poly([-2,-2,-2,-2,-2]));
sys_pi=tf(1,poly([-4,-4,-4,-4,-4]));
%sys_pi=tf(1,poly([-1,-1,-1,-1,-1]));
desys_pi=c2d(sys_pi,Ts);  %converting tf to discrete
[num_disc, den_disc]= tfdata(desys_pi,'v');
%controller statefeedback gain calculation
kt_d=qpi_d*( den_disc(6)*eye(5)+ den_disc(5)*Ad+den_disc(4)*Ad^2+den_disc(3)*Ad^3+den_disc(2)*Ad^4+Ad^5);

ki_d=-kt_d(5)*Ts;   % the fifth element is the integeral gain
%ki_d=0.2;
kt_dg=kt_d(1:4)-p*Ctk; % Kt_dg adaption due to output feedback

%% Fixed Point model without sensor constants %%

% State feedback gain
KD_f = kt_d(1:4)-p*Ctk
% Proportional Gain
KP_f = p 
% Discrete Integrator Gain
KI_f = ki_d

% fractional bits
KD_f_SHIFT = 8
KP_f_SHIFT = 9
KI_f_SHIFT = 14

  limit = 1;                % for integrator  
  %LIMIT = 2047 ;            % for controller output , PI and statefeedback

 LIMIT_INT = round(limit * 2^KI_f_SHIFT);
 LIMIT_OUT = round(limit * 2^KP_f_SHIFT);
 LIMIT_KD_OUT = round(limit * 2^KD_f_SHIFT);

fprintf('-----// CP_CONTROLLER FIXED POINT //------\n');

fprintf('#define KD_f_SHIFT %2d  \n', KD_f_SHIFT)
fprintf('KD_f_FIX { %10d, %10d, %10d, %d } // int 16.%d \n', round(KD_f(1)*2^KD_f_SHIFT),round(KD_f(2)*2^KD_f_SHIFT),round(KD_f(3)*2^KD_f_SHIFT),round(KD_f(4)*2^KD_f_SHIFT),KD_f_SHIFT)

fprintf('#define KP_f_SHIFT  %2d  \n', KP_f_SHIFT)
fprintf('#define KI_SHIFT  %2d  \n', KI_f_SHIFT)

fprintf('#define KP_f_FIX %d   // int 16.%2d\n',round(KP_f * 2^KP_f_SHIFT) , KP_f_SHIFT);
fprintf('#define KI_f_FIX %d   // int 16.%2d\n',round(KI_f * 2^KI_f_SHIFT) ,KI_f_SHIFT);

fprintf('#define LIMIT_INT  %10d // int 16.14\n', LIMIT_INT);   % refer to the fix point model for the meaning of limits
fprintf('#define LIMIT_OUT  %10d // int 16.11\n', LIMIT_OUT);
fprintf('#define LIMIT_KD_OUT  %10d // int 32.9\n', LIMIT_KD_OUT);

fprintf('----- cut above ------\n');

disp('That`s all.')





%% The sensor constants 
T_i = 40950;              % to convert DAC_values to Torque (1Nm = T_const DAC counts)   
F_i = 22.0532;            % to convert DAC_values to voltage(1N = 'F_const'DAC counts)
%F_i = 30;
F_0 = 1;

x_i_A = 57238;              % displacement of cart (1m = 'Disp_const' counts)
x_i = 28619;                % Overflow for x_i_A value in int_16,so x_i=x_i_A/2;
x_0 = 1;  

vel_i = x_i*Ts           % velocity of cart per 10ms (Unit: m/10ms)

alpha_i = 4095;           % angular_displacment of pendulum (2*pi = 'Angle_const' counts)
alpha_0 = (2*pi);

omega_i = alpha_i*Ts ;     % angular_velocity per 10ms (Unit: rad/10ms)

kd_i = [omega_i 0 0 0 ; 0 (alpha_i/alpha_0) 0 0 ; 0 0 vel_i 0 ; 0 0 0 (x_i/x_0)];  % to get the integer values 

%% Accounting for Sensor conversion factor in Gain values
% State feedback gain
KD = [(F_i/omega_i) (F_i*alpha_0/alpha_i) F_i/vel_i  F_i/x_i].*(kt_dg)
% Proportional Gain
KP_D = (x_0/x_i)* p *(F_i/F_0)  
% Discrete Integrator Gain
KI_D = (x_0/x_i)* ki_d *(F_i/F_0)
% %% Limiters (Actual Limiters from test stand)
%limit = 1;            % integrator_limit  
%   limit_pi_out = 2047;      % for PI controller output 
%   limit_pos = 2086 ;        % for (PI + statefeedback) controller output 
%   limit_neg = -2009 ;       % for (PI + statefeedback) controller output 

KD_SHIFT = 12;
KP_SHIFT = 15;
KI_SHIFT = 15;
Phyval=F_0/F_i;
KD_F= KD*kd_i;

  limit = 1;                % for integrator  
  LIMIT = 2047 ;            % for controller output , PI and statefeedback

 LIMIT_INT = round(limit * 2^KI_SHIFT);
 LIMIT_OUT = round(LIMIT * 2^KP_SHIFT);
 LIMIT_KD_OUT = round(LIMIT * 2^KD_SHIFT);

fprintf('-----// CP_CONTROLLER //------\n');

fprintf('#define KD_SHIFT  %2d  \n', KD_SHIFT)
fprintf('KD_FIX  { %10d, %10d, %10d, %d } // int 16.%d \n', round(KD(1)*2^KD_SHIFT),round(KD(2)*2^KD_SHIFT),round(KD(3)*2^KD_SHIFT),round(KD(4)*2^KD_SHIFT),KD_SHIFT)

fprintf('#define KP_SHIFT  %2d  \n', KP_SHIFT)
fprintf('#define KI_SHIFT  %2d  \n', KI_SHIFT)

fprintf('#define KP_FIX %d   // int 16.%2d\n',round(KP_D * 2^KP_SHIFT) , KP_SHIFT);
fprintf('#define KI_FIX %d   // int 16.%2d\n',round(KI_D * 2^KI_SHIFT) ,KI_SHIFT);

fprintf('#define LIMIT_INT  %10d // int 32.15\n', LIMIT_INT);   % refer to the fix point model for the meaning of limits
fprintf('#define LIMIT_OUT  %10d // int 32.15\n', LIMIT_OUT);
fprintf('#define LIMIT_KD_OUT  %10d // int 32.12\n', LIMIT_KD_OUT);

fprintf('----- cut above ------\n');

disp('That`s all.')