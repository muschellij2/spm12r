function graph_snr;
%shows simple plot of sine waves with noise
sampleRate = 200; % samples per second
dt = 1/sampleRate; % time per sample
sampleDuration = 1.0; % seconds
x = (0:dt:sampleDuration-dt)';     % seconds
goodSignal = 0.70;
poorSignal = 0.25;
goodVersusPoor = goodSignal/poorSignal;
noise = 0.2; %amplitude of noise, SNR e.g. 0.1 means noise 10% amplitude of signal
clipMinMax = [-1 1];
myAxis = [0 sampleDuration (-1-(noise)) (1+(noise))];
%% Sine wave:
freq = 4;  % frequency in hertz
signal = cos(2*pi*freq*x); %if you have DSPtoolbox you could use "modulate"
n = (rand(length(x),1)-0.5)*noise; %-0.5 to make noise -0.5..0.5
%init plots
figure;
set(gcf,'color','w');
%graph 1: standard SNR
y = (signal*goodSignal)+n;
subplot(2,2,1)
sub_draw(x,y,myAxis,clipMinMax, 'good signal/noise');
%graph 2: amplified standard SNR
y = ((signal*goodSignal)+n)*goodVersusPoor;
subplot(2,2,2)
sub_draw(x,y,myAxis,clipMinMax, 'amplified good signal/noise');
%graph 3: low SNR
subplot(2,2,3);
y = (signal *poorSignal)+n;
sub_draw(x,y,myAxis,clipMinMax, 'poor signal/noise');
%graph 2: amplified low SNR
subplot(2,2,4)
y = ((signal *poorSignal)+n)*goodVersusPoor;
sub_draw(x,y,myAxis,clipMinMax, 'amplified poor signal/noise');


function sub_draw(x,y, a, yclip, t);
%x : horizontal values
%y : vertical values
%a : [0 1 -2 2] shows horzintonal range 0..1, vertical range -2..2
%yclip : [-1 1] will clip y values to range -1..1 
%t : title
y(y<yclip(1)) = yclip(1); %clip values more than max
y(y>yclip(2)) = yclip(2); %clip values more than min

plot(x,y);
xlabel('time (in seconds)');
title(t);
axis(a);
%end; %function sub_draw