
%% Parameters

f = 100e3;
D_max = 0.2;
D_w = 0.1; %Dwell time duty ratio
V_in_max = 400;
V_in_min = 220; %V
V_out = 12;
P_out_load = 100;
V_d = 1;
C_out = 470e-6; % output capacitance
C_out_ESR = 15e-3 ; % capacitor ESR resistance
n = 0.9; % efficiency
Ku = 0.29; % Window Utilization
B_m = 0.25; % Operating flux density
Aw_26 = 0.00128; %Bare area of AWG26
Wa = 2*8.6*(21.9-9.4)*(10^(-2));
alfa = 1; %Regulation
AL = 1696e-9; %nH/T^2


%%
%Material specifications considering 3C90 as selected material type
B_max = 0.25;
W_tcu = 47.3; %gr, Copper Weight
W_tfe = 57; %gr, Core Weight, (2*mass of core half)
MLT= 8.1; %cm, Mean length turn
MPL = 7.75; %cm, effective length or Magnetic path lenght
Ac = 1.49; %cm^2, Iron Area
Window_Area = 1.643; %cm'2, Window Area
WaAc = Window_Area*Ac; %cm^4 Area Product
At = 60.9; %cm^2, Surface Area
G = 2.860; %cm, Winding Length
mu_m = 2500; % Core permeability


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
t_on_max = T*D_max;
%Step 3-4-5: Calculate the total secondary load power
I_out = P_out_load/(V_out);
P_out = P_out_load + V_d*I_out ;
%Step 6: Calculate the maximum input current
I_in_max = (P_out)/(V_in_min*n);
%Step 7: Calculate the primary peak current
I_p_peak = (2*P_out*T)/(n*V_in_min*t_on_max);
        %t_on_max ?
%Step 8: Calculate the primary rms current
I_p_rms = I_p_peak*sqrt(t_on_max/(3*T));
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
Kg = (Energy^2)/(Ke*alfa);
%Step 15: Select an EFD core comparable in core geometry, Kg

%Step 16: Calculate the current density, J, using a window utilization, 
    % Ku is the amount of copper that appears in the window area of the
J = (2*Energy*(10^4))/(B_max*WaAc*Ku);
%Step 17: Calculate the primary wire area
A_pw = I_p_rms/J;
%Step 18: Calculate the required number of primart strands
    %S_np = A_pw/#26(bare area)
S_np = ceil(A_pw/Aw_26);
%Step 19: Calculate the number of primary turns, Np. Half of the available
%window is primary. Using the number of strands, S_np, and the area of #26
    %W_ap = Wa/2;
    %N_p = ceil((Ku*W_ap)/(3*Aw_26));
    N_p = sqrt(L_m/AL);
%Step 20: Calculate the required gap
lg = ((0.4*pi*(N_p^2)*Ac*(10^(-8)))/L_m)-((MPL)/(mu_m));
%Step 21: Calculate the equivalent gap in mils
mils = lg*393.7;
%Step 22: Calculate the fringing flux factor
F = 1+((lg/(sqrt(Ac)))*(log((2*G)/lg)));
%Step 23: Calculate the new number of turns, N_np, by inserting the
%fringing flux, F
N_np = ceil(sqrt((lg*L_m)/(0.4*pi*Ac*F*(10^(-8)))));
%Step 24: Calculate the peak flux density, B_pk
B_pk = (0.4*pi*N_np*F*I_p_peak*(10^(-4)))/(lg+(MPL/mu_m));
%Step 25: Calculate the primary resistance per cm
R_pcm = 1345/S_np;
%Step 26: Calculate the primary winding resistance, R_p
R_p = MLT*N_np*R_pcm*(10^(-6));
%Step 27: Calculate the primary copper loss, P_p
P_p = (I_p_rms^2)*R_p;
%Step 28: Calculate the secondary turns, N_s1
N_s = round((N_np*(V_out-V_d)*(1-D_max-D_w))/(V_in_min*D_max));
%Step 29: Calculate the secondary peak current, I_s1_peak
I_s_peak = (2*I_out)/(1-D_max-D_w);
%Step 30: Calculate the secondary rms current
I_s_rms = (I_s_peak)*sqrt((1-D_max-D_w)/3);
%Step 31: Calculate the secondary wire area, A_sw1
A_sw = I_s_rms/J; %cm^2
%Step 32: Calculate the required number of secondary strands, S_ns1
S_ns = ceil(A_sw/Aw_26);
%Step 33: Calculate the S1 secondary
S1 = 1345/S_ns;
%Step 34: Calculate winding resistance, R_s1
R_s = MLT*N_s*S1*(10^(-6));
%Step 35: Calculate the secondary copper loss, P_s1
P_s = (I_s_rms^2)*R_s;
%Step 36-43: Skipped
%Step 44: Calculate the window utilization, Ku
Turns_p = N_p*S_np;
Turns_s = N_s*S_ns;
Nt = Turns_p+Turns_s; % Total number of turns with AWG #26
Ku_final = (Nt*Aw)/Window_Area;
%Step 45: Calculate the total copper loss, P_cu
P_cu = P_p+P_s;
%Step 46: Calculate the regulation, alfa, for this design
alfa_final = (P_cu/P_out)*100;
%Step 47: Calculate the ac flux density, B_ac
B_ac = (0.4*pi*N_np*F*(I_p_peak/2)*(10^(-4)))/(lg+(MPL/mu_m));
%Step 48: Calculate the watts per kilogram, WK
WK = 4.855*(10^(-5))*(f^(1.63))*(B_ac^(2.62));
%Step 49: Calculate the core loss, P_fe
P_fe = WK*W_tfe*(10^(-3));
%Step 50: Calculate the total loss, P_total_loss
P_total_loss = P_fe+P_cu;
%Step 51: Calculate the watt density
Watt_density = P_total_loss/At;
%Step 52: Calculate the temperature rise, Tr
Tr = 450*(Watt_density^(0.826));


















% *When operating at high frequencies, the engineer has to review the window utilization factor, Ku. When
% using a small bobbin ferrite, the ratio of the bobbin winding area to the core window area is only about 0.6.
% Operating at 100kHz and having to use a #26 wire, because of the skin effect, the ratio of the bare copper
% area is 0.78. Therefore, the overall window utilization, Ku, is reduced. The core geometries, Kg, in Chapter
% 3 have been calculated with a window utilization, Ku, of 0.4. To return the design back to the norm, the
% core geometry, Kg is to be multiplied by 1.35, and then, the current density, J, is calculated, using a window
% utilization factor of 0.29. See Chapter 4.
