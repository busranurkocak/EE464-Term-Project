Pout = 100; %W, Ouput Power
Vin_min = 220; %V, Minimum Input Voltage
Dmax = 0.5; % (ton/(ton+toff)), Maximum Duty Cycle
f = 100; %kHz, Switching Frequency
Vout = 12; %V, Output Voltage
n = 0.9; %Efficiency
Pin = Pout/n;


Ipk = (2*Pout)/(Vin_min*Dmax); %A, Peak Current
Lpri = ((Vin_min)*Dmax)/(Ipk*f); %mH, Primary Inductance

LI2 = Lpri*(Ipk^2);

L1000 = 92;
Npri = 1000*sqrt(Lpri/L1000);

Vd = 1; %V
Nsec = ((Vout-Vd)*(1-Dmax)*Npri)/(Vin_min*Dmax);

Iave = Pin/Vin_min; % Average input current
Isec = Iave*(Npri/Nsec);

% Cable Selection -> AWG 26
% D = 0.40386e-3; %m
R = 133.8568; %Ohms/km
Imax = 0.361; %A, maximum current cable can carry

% Number of 26 awg cable to be used
Spri = ceil(Iave/Imax); 
Ssec = ceil(Isec/Imax);

% ?
u0 = pi*4e-7;
ucore = 90;
le = 6.56; %cm, the path length in cm
H = (Npri*Ipk)/le;
B = ucore*u0*H;

% E core window area calculation
E = 25.2e-3; %m
F = 9.32e-3;
D = 9.6e-3;
Awindow = ((E-F)/2)*(2*D); %m^2

Acopper = 0.129e-6; %m^2
Kcu = (Acopper*((Spri*Npri)+(Ssec*Nsec)))/(83.3e-6);

