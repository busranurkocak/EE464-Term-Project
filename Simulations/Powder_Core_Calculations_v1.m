Pout = 100; %W, Ouput Power
Vin_min = 220; %V, Minimum Input Voltage
Dmax = 0.5; % (ton/(ton+toff)), Maximum Duty Cycle
f = 100; %kHz, Switching Frequency
Vout = 12; %V, Output Voltage
n_eff = 0.9; %Efficiency
Pin = Pout/n_eff;

Ipk = (2*Pout)/(Vin_min*Dmax); %A, Peak Current
Lpri = ((Vin_min)*Dmax)/(Ipk*f); %mH, Primary Inductance

LI2 = Lpri*(Ipk^2);
L1000 = 92;
Npri = 1000*sqrt(Lpri/L1000);

Vd = 1; %V, Diode voltage drop
Nsec = ceil(((Vout+Vd)*(1-Dmax)*Npri)/(Vin_min*Dmax));

Iave = Pin/Vin_min; % Average input current
Isec = Iave*(Npri/Nsec);

% Cable Selection -> AWG 26
% D = 0.40386e-3; %m
R = 0.1338568; %Ohms/m
Imax = 0.361; %A, maximum current cable can carry

% Number of 26 awg cable to be used
Spri = ceil(Iave/Imax); 
Ssec = ceil(Isec/Imax);

% ?
u0 = pi*4e-7;
ucore = 90;
le = 6.56; %cm, the path length in cm
Ae = 0.601; %cm^2
H = (Npri*Iave)/le;
B = ucore*u0*H;
Bdc = ucore*((0.4*pi*Npri*Iave)/(le))*1e-4;

% E core window area calculation
E = 25.2e-3; %m
F = 9.32e-3;
D = 9.6e-3;
Awindow = ((E-F)/2)*(2*D); %m^2

Acopper = 0.129e-6; %m^2
Kcu = (Acopper*((Spri*Npri)+(Ssec*Nsec)))/(83.3e-6);

%Core Loss
k = 0.000614;
m = 1.460;
n = 2;
PL = k*((f*1e3)^m)*(B^n);
Pfe = PL*le*Ae;

%Copper Loss
MLT = 2*pi*((F/2)+((E-F)/4)); %m
Rpri = (Npri*MLT*R)/(Spri);
Rsec = (Nsec*MLT*R)/(Ssec);
Pcu = ((Iave^2)*Rpri)+((Isec^2)*Rsec);
