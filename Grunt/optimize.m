% Model Optimization
% Author: Sang Min Han
% Last modified: 2023/09/12
%

function [ mse ] = optimize( x0 )
% optimize is the model optimization function that is called by fminsearch
%
%   x0 is the initial guess
%

% parameter search:
% k1 = 0.5*k2; k13 = k23; d1 = d2; amp1 = amp2;

% Is the waveform reasonable for one bladder compared to post-op fish
% -- spike, wave; does TSTOOL yield periodicity
% Is the amplitude reasonable
% -- amp scale: 1 is length of connection between bladders
% Is two bladder waveform complex
% -- bursty or harmonically complex or TSTOOL chaotic

global k1 d1 amp1 amp_tendon k13
global k2 d2 amp2 k23
global muscle_force1 muscle_force2
global saw Fs % muscle waveform
global kRatio dRatio ampRatio

% amp range: 1e3 to 1e4
% damping range 50-500
% k1=k2=4e5 or k1= 4e5; k2= 8e5;

% Actual swim bladders are about 0.88:1.29 in size
% For a free bubble, Fo is proportional to 1/R
% so tune one bladder 88 Hz and the other to 129 Hz

k2= x0(1); % 8e5 % tuned to 142 Hz
k23= 0.1; % spring cubic term coeff
k1= kRatio*k2; % 4e5 % tuned to 100 Hz
k13= 0.1; % spring cubic term coeff
d2= x0(2);
d1= dRatio*d2; % 200
amp2= x0(3);
amp1= ampRatio*amp2; % 2.9e3;
amp_tendon= 10e6;
Fs= 10000;

ramp_up_time= 0.15;
ramp_down_time= 0.15;
tspan= 0:1/Fs:(ramp_up_time + ramp_down_time);

% make a realistic sawtooth fundamental 150
saw= 0.5*(1 + sawtooth(2*pi*tspan*150, 0.2));
[b, a]= butter(2, 1000/(Fs/2)); % 250 looks good
saw= filter(b, a, saw);
[b, a]= butter(2,25/(Fs/2),'high');
saw= filter(b, a, saw);
saw= saw - min(saw(end - 1000:end));

% plot(tspan, saw)
% return

muscle_force1= amp1.*saw.*((tspan < ramp_up_time).*...
    amp1/ramp_up_time.*tspan + (tspan >= ramp_up_time).*...
    (amp1 - amp1/ramp_down_time.*(tspan - ramp_up_time)));
muscle_force2= amp2.*saw.*((tspan < ramp_up_time).*...
    amp2/ramp_up_time.*tspan + (tspan >= ramp_up_time).*...
    (amp2 - amp2/ramp_down_time.*(tspan - ramp_up_time)));

% [ TOUT, YOUT ] = ODE45( ODEFUN, TSPAN, X0 )
[~, x]= ode45('osc', tspan, [1.0, 0, 1.9, 0]);
% [b, a]= butter(2,3000/(Fs/2));
y= x(:,3)-mean(x(:,3)) - (x(:,1)-mean(x(:,1)));
[Pxx, ~]= pwelch(y, [], [], [], Fs);
% Pxx= 20*log10(Pxx/max(abs(Pxx))); % normalized and in dB
Pxx= 20*log10(Pxx);
avgPxx= mean(Pxx);

[~, ~, PxxFish, ~]= psde('tank8, grunt 8.45.27, 5.21.wav', Fs);
% PxxFish= 20*log10(PxxFish/(max(abs(PxxFish)))); % normalized and in dB
PxxFish= 20*log10(PxxFish);
avgPxxFish= mean(PxxFish);

offset= avgPxx - avgPxxFish;
Pxx= Pxx - offset;
N= length(Pxx);

mse= sum((Pxx - PxxFish).^2)./N;

end

function [ y, Fs, Pxx, W ] = psde( fname, Fs )
% psde generates the power spectral density estimate of a .wav file
%
%   fname is the name of the .wav file
%   Fs is the sampling frequency
%      hoot: bw.7.27-1.22-1.23.08(filtered2)-singlehoot.wav
%      grunt: tank8, grunt 8.45.27, 5.21.wav
%

[y, fs]= audioread(fname);
y= resample(y, Fs, fs);

% low-pass filter for grunts to eliminate high-frequency component
[b, a]= butter(10, 1000/(Fs/2), 'low');
y= filter(b, a, y);

y= y(11000:14000); % isolate grunt sound

[Pxx, W]= pwelch(y, [], [], [], Fs);

% figure; clf;
% plot(W, 20*log10(Pxx));
% set(gca, 'xlim', [0 2500], 'ylim', [-200 0]);
%
% maxY= max(max(y), max(-y));
% scY= y/maxY;
% soundsc(scY, Fs);

end

