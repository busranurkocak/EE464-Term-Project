f = 100e3;
D_max = 0.5;
D_w = 0.1; %Dwell time duty ratio ?????????????????????????
V_in_min = 220; %V
V_out = 12;
V_d = 1;
n = 0.9; % efficiency
B_max = 0.5; %change according to the material you have chosen
Ku = 0.29;
Ap = 0.59;
Aw_26 = 0.00128; %Bare area of AWG26
Wa = 2*8.6*(21.9-9.4)*(10^(-2));

%Skin depth in centimeters
    %mu = 4*pi*(10^(-7)); %H/m permeability
    %sigma = 1/(1.69*(10^(-8)));  %conductivity of copper at 10GHz
    %e = sqrt(1/(pi*f*mu*sigma))
e = 6.62/sqrt(f);
%Wire diameter
D = 2*e;
%Bare wire area
Aw = (pi*(D^2))/4;

%Step 1: Calculate the total period
T = 1/f;
%Step 2: Calculate the maximum transistor on time, t_on
t_on = T*D_max;
%Step 3-4-5: Calculate the total secondary load power
P_out = 100; %W
I_out = P_out/V_out;
%Step 6: Calculate the maximum in put current
I_in_max = (P_out)/(V_in_min*n);
%Step 7: Calculate the primary peak current
I_p_peak = (2*P_out*T)/(n*V_in_min*t_on);
        %t_on_max ?
%Step 8: Calculate the primary rms current
I_p_rms = I_p_peak*sqrt(t_on/(3*T));
%Step 9: Calculate the maximum input power
P_in = P_out/n;
%Step 10: Calculate the equivalent input resistance
R_in_eq = (V_in_min^2)/(P_in);
%Step 11: Calculate the required primary inductance
L_m = (R_in_eq*T*(D_max^2))/2;
%Step 12: Calculate the energy-handling capability in watt-seconds
Energy = (L_m*(I_p_peak^2))/2;
%Step 13: Calculate the electrical conditions
Ke = 0.145*P_out*(B_max^2)*(10^(-4));
%Step 14: Calculate the core geometry. See the design specification, 
%window utilization factor, Ku ? 
alfa = 1;
Kg = (Energy^2)/(Ke*alfa); % What is alfa ?
%Step 15: Select an EFD core comparable in core geometry, Kg

%Step 16: Calculate the current density, J, using a window utilization, 
    %Ku = 0.29
    % Ku is the amount of copper that appears in the window area of the
    % transformer or inductor
    %Ap = Area product = WaAc factor
    %Wa = Window area
    %Ac = Iron area
    WaAc = 0.59; %cm^4 for 0_43009EC Ferrite Core
J = (2*Energy*(10^4))/(B_max*Ap*Ku);
%Step 17: Calculate the primary wire area
A_pw = I_p_rms/J;
%Step 18: Calculate the required number of primart strands
    %S_np = A_pw/#26(bare area)
S_np = ceil(A_pw/Aw_26);
%Step 19: Calculate the number of primary turns, Np. Half of the available
%window is primary. Using the number of strands, S_np, and the area of #26
W_ap = Wa/2;
N_p = ceil((Ku*W_ap)/(3*Aw_26));
%Step 20: Calculate the required gap
    Ac = WaAc/Wa;
    MPL = 6.19; %cm, effective length or Magnetic path lenght
lg = ((0.4*pi*(N_p^2)*Ac*(10^(-8)))/L_m)-((MPL)/(5900));
%Step 21: Calculate the equivalent gap in mils
mils = lg*393.7;
%Step 22: Calculate the fringing flux factor
    G = 3.76; %cm, Winding Length
F = 1+((lg/(sqrt(Ac)))*(log((2*G)/lg)));
%Step 23: Calculate the new number of turns, N_np, by inserting the
%fringing flux, F
N_np = ceil(sqrt((lg*L_m)/(0.4*pi*Ac*F*(10^(-8)))));
%Step 24: Calculate the peak flux density, B_pk
%------------------Tam anlayamad?m---------------------
    mu_m = 1760; %Change when you choose the material type
B_pk = (0.4*pi*N_np*F*I_p_peak*(10^(-4)))/(lg+(MPL/mu_m));
%Step 25: Calculate the primary resistance per cm
R_pcm = 1345/3;
%Step 26: Calculate the primary winding resistance, R_p
    MLT= 5.01; %cm, Mean length turn
R_p = MLT*N_np*R_pcm*(10^(-6));
%Step 27: Calculate the primary copper loss, P_p
P_p = (I_p_rms^2)*R_p;
%Step 28: Calculate the secondary turns, N_s1
N_s1 = round((N_np*(V_out+V_d)*(1-D_max-D_w))/(V_in_min*D_max));
%Step 29: Calculate the secondary peak current, I_s1_peak
I_s1_peak = (2*I_out)/(1-D_max-D_w);
%Step 30: Calculate the secondary rms current
I_s1_rms = (I_s1_peak)*sqrt((1-D_max*D_w)/3);
%Step 31: Calculate the secondary wire area, A_sw1
A_sw1 = I_s1_rms/J; %cm^2
%Step 32: Calculate the required number of secondary strands, S_ns1
S_ns1 = ceil(A_sw1/Aw_26);
%Step 33: Calculate the S1 secondary
S1 = 1345/S_ns1;
%Step 34: Calculate winding resistance, R_s1
R_s1 = MLT*N_s1*S1*(10^(-6));
%Step 35: Calculate the secondary copper loss, P_s1
P_s1 = (I_s1_rms^2)*R_s1;
%Step 36: Calculate the secondary turns, N_s2
N_s2 = ceil((N_np*(V_out+V_d)*(1-D_max*D_w))/(V_in_min*D_max));
%Step 37: Calculate the secondary peak current, I_s2_peak
I_s2_peak = (2*I_out)/(1-D_max*D_w);
%Step 38: Calculate the secondary rms current, I_s2_rms
I_s2_rms = I_s2_peak*sqrt((1-D_max*D_w)/3);
%Step 39: Calculate the secondary wire area, A_sw2
A_sw2 = I_s2_rms/J;
%Step 40: Calculate the required number of secondary strands, S_ns2
S_ns2 = ceil(A_sw2/Aw_26);

























% *When operating at high frequencies, the engineer has to review the window utilization factor, Ku. When
% using a small bobbin ferrite, the ratio of the bobbin winding area to the core window area is only about 0.6.
% Operating at 100kHz and having to use a #26 wire, because of the skin effect, the ratio of the bare copper
% area is 0.78. Therefore, the overall window utilization, Ku, is reduced. The core geometries, Kg, in Chapter
% 3 have been calculated with a window utilization, Ku, of 0.4. To return the design back to the norm, the
% core geometry, Kg is to be multiplied by 1.35, and then, the current density, J, is calculated, using a window
% utilization factor of 0.29. See Chapter 4.