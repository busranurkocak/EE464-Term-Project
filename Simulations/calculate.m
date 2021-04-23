%% ideal calculation of flyback
%% parameters
Vs = 220;   %source voltage
Vo = 12;    %output voltage
L1 = 2e-3;   %input part inductance
L2 = 1e-3;  %output part inductance
fs = 50000; %switching frequency
Co = 100e-6;  %output capacitance
Po = 100;   %output power

%% calculation for CCM
Ts = 1 / fs; 
Nturn = L1 / L2;
Rload = ((Vo)^2)/Po ;
D = (Vo/Vs)*Nturn ;
deltaI1 = (Vs*D)/(L1*fs);
Ioavg = Po / Vo ;
Isavg = Po / Vs ;
I1avg = Isavg / D ;
I1min = I1avg - (deltaI1 / 2);
I1max = I1avg + (deltaI1 / 2);
Vswitch = Vs + Nturn*Vo;
deltaVo = (Ioavg *D) / (Co*fs);
Vo_p_p = 100*(deltaVo/Vo);
Vo_min = Vo - deltaVo/2;
Vo_max = Vo + deltaVo/2;

%     if((I1avg - deltaI / 2) <= 0)
%         operationMode = 'DCM';
fprintf('Output Voltage Peak-to-Peak Ripple: %f' , Vo_p_p );


figure(1)
hold on
title('Lm current')
plot([0 D 1 1+D 2], [I1min I1max I1min I1max I1min])

figure(2)
hold on
title('Source current')
plot([0 D D+1e-5 1 1+1e-5 1+D 1+D+1e-5 2], [I1min I1max 0 0 I1min I1max 0 0])

figure(3)
hold on
title('Mosfet Voltage')
plot([0 D D+1e-5 1 1+1e-5 1+D 1+D+1e-5 2], [0 0 Vswitch Vswitch 0 0 Vswitch Vswitch])

figure(4)
hold on
title('output voltage')
plot([0 D 1 1+D 2], [Vo_max Vo_min Vo_max Vo_min Vo_max])
