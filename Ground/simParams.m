water_level = 0;
initRobHeight = 0.2;

%%%%%%% motors parameters %%%%%%%
speed = 9.5;   % rotation speed in rad/s
duty_factor = .5;
switch_angle = 0;

V_H = speed/(2*duty_factor);
V_L = speed/(2*(1 - duty_factor));

pulse_df = duty_factor*100;
pulse_amplitude = V_H - V_L;
pulse_period = 2*pi/speed;
median_speed = (V_H + V_L)/2 - pulse_amplitude/2;

phase_delay = switch_angle/V_L;
tau = 2*pi/speed/200;

motor_mass = 0.010;
motor_radius = 0.01342;
motor_length = 0.03663;

Ix = 1/12*motor_mass*(3*motor_radius^2 + motor_length^2);
Iy = Ix;
Iz = motor_mass*motor_radius^2/2;

motor_inertia = diag([Ix,Iy,Iz]);

%%%%%% frame parameters %%%%%%%%%%%%%%%%%%
frame_width  = 0.125; 
frame_length = 0.25;
frame_height = 0.02;

frame_CA = [0 0 0];
frame_CG = [0,0,0];
frame_FR = [ frame_length/2 0  frame_width/2 ];
frame_FL = [ frame_length/2 0 -frame_width/2 ];
frame_HR = [-frame_length/2 0  frame_width/2 ];
frame_HL = [-frame_length/2 0 -frame_width/2 ];

frame_mass = 0.060;
Ix = 1/12*frame_mass*( frame_width^2 +  frame_height^2 );
Iy = 1/12*frame_mass*( frame_width^2 +  frame_length^2 );
Iz = 1/12*frame_mass*( frame_length^2 + frame_height^2 );

frame_inertia = diag([Ix,Iy,Iz]);

L6 = 0.17325;    % this is distance between front and hind motors

frame_motor_FR = frame_FR;
frame_motor_FL = frame_FL;
frame_motor_HR = frame_motor_FR - [L6 0 0];
frame_motor_HL = frame_motor_FL - [L6 0 0];
frame_motor_Tail = (frame_HR + frame_HL)/2;


%%%%%%%  passive joint parameters %%%%%%

L1 = .0615;   %distance between each motor and its passive joint

frame_passive_FR = frame_motor_FR - [L1 0 0];
frame_passive_FL = frame_motor_FL - [L1 0 0];
frame_passive_HR = frame_motor_HR - [L1 0 0];
frame_passive_HL = frame_motor_HL - [L1 0 0];


%%%%% leg parameters %%%%%%%%%%%%%
CF_density = 1790;
cross_area = 6.8e-6;

L2 = 0.0218;
L3 = 0.0748;
L4 = 0.0468;
L5 = 0.0624;


L2_CS1 = [0 0 0];     % using adjoining
L2_CG  = [0 L2/2 0];
L2_CS2 = [0 L2 0];


L2_mass = CF_density*cross_area*L2;
I = 1/12*L2_mass*L2^2;
L2_inertia = diag([I 0 I]);

%%%%%% calculations %%%%%%

alpha =  2*L1*L4;
beta  = -2*L2*L4;
gamma = L1^2 + L4^2 + L2^2 - L3^2;

delta = atan2(beta, alpha);
theta4 = delta + acos(-gamma/(norm([alpha,beta])));
theta3  = atan2( L4*sin(theta4)-L2 , L1+L4*cos(theta4) );

%%%%%%% L4 %%%%%%


L4_CS1 = [0 0 0];       %using adjoining
L4_CS2 = [0 L4 0];
L4_CG = L4_CS2./2;

L4_ori = [0 0 pi/2-theta4];

L4_mass = CF_density*cross_area*L4;
I = 1/12*L4_mass*L4^2;
L4_inertia = diag([I 0 I]);

%%%%%% L3 %%%%%%

L3_CS1 = [0 0 0];       %using adjoining
L3_CS2 = [-L3 0 0];
L3_CS3 = [L5 0 0];

L3_CG = (L3_CS2 + L3_CS3)./2;

L3_ori = [0 0 -theta3];

L3_mass = CF_density*cross_area*L3;
I = 1/12*L3_mass*L3^2;
L3_inertia = diag([I 0 I]);

%%%%%%%% Tail Parameters %%%%%%%

tail_angle = 0 * pi/180;
L_tail = .2;
Tail_CS1 = [0 0 0];     % using adjoining
Tail_CG  = [0 L_tail/2 0];
Tail_CS2 = [0 L_tail 0];

Tail_mass = CF_density*cross_area*L_tail;
I = 1/12*Tail_mass*L_tail^2;
Tail_inertia = diag([I 0 I]);

%%%%%%% Ground Foot Parameters %%%%%%%

footWidth = .035;
footLength = .04;
footThickness = .001;
footMassDensity = 1140;
footMass = footWidth * footLength * footThickness * footMassDensity;

PRBM_gamma = 0.85;

k_PRBM = .5;
b_PRBM = 2e-5;

%%%%%%%Ground Contact Model %%%%%%
k_gy = 8e4; %[N/m]  vertical ground interaction stiffness
v_gy_max = 0.03; %[m/s] maximum vertical ground relaxation speed
k_gx = 8e3; %[N/m] horizontal ground interaction stiffness
v_gx_max = 0.03; %[m/s] maximum horizontal ground relaxation speed
mu_stick = 0.9; %stiction coefficient
mu_slide = 0.8; % sliding coefficient
vLimit = 0.01; %[m/s] % slip-stic transition velocity

%%%L1%%%
Foot_L1 = footLength*(1 - PRBM_gamma);
Foot_L1_mass = footMass*(1 - PRBM_gamma);

I1_l = (1/12) * Foot_L1_mass*(footWidth^2 + footThickness^2);
I1_w = (1/12) * Foot_L1_mass*(Foot_L1^2 + footThickness^2);
I1_t = (1/12) * Foot_L1_mass*(Foot_L1^2 + footWidth^2);

Foot_L1_CS1 = [0 0 0];
Foot_L1_CS2 = [Foot_L1 0 0];
Foot_L1_CG = Foot_L1_CS2/2;

Foot_L1_inertia = diag([I1_l I1_w I1_t]);

%%%L2%%%
Foot_L2_mass = footMass*PRBM_gamma;
Foot_L2 = footLength* PRBM_gamma;

I2_l = (1/12) * Foot_L2_mass*(footWidth^2 + footThickness^2);
I2_w = (1/12) * Foot_L2_mass*(Foot_L2^2 + footThickness^2);
I2_t = (1/12) * Foot_L2_mass*(Foot_L2^2 + footWidth^2);

Foot_L2_CS1 = [0 0 0];
Foot_L2_CS2 = [Foot_L2 0  0];
Foot_L2_CG = Foot_L2_CS2/2;

Foot_L2_inertia = diag([I2_l I2_w I2_t]);

%%%%%
totalMass = frame_mass + 4*(motor_mass + L2_mass + L3_mass + L4_mass + footMass) + motor_mass + Tail_mass;
