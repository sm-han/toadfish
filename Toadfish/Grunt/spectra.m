% Generate Spectra
% Author: Sang Min Han
% Last modified: 2023/09/22
%

function spectra( x )
% spectra generates the summary figures including the waveforms and the
% power spectral densities of the observed and generated calls
%
%   x = [k2 d2 amp2]
%

global k1 d1 amp1 amp_tendon k13
global k2 d2 amp2 k23
global muscle_force1 muscle_force2
global saw Fs % muscle waveform
global kRatio dRatio ampRatio

kRatio= 0.5;
dRatio= 1;
ampRatio= 1;

k2= x(1); % 8e5 % tuned to 142 Hz
k23= 0.1; % spring cubic term coeff
k1= kRatio*k2; % 4e5 % tuned to 100 Hz
k13= 0.1; % spring cubic term coeff
d2= x(2);
d1= dRatio*d2; % 200
amp2= x(3);
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

muscle_force1= amp1.*saw.*((tspan < ramp_up_time).*...
    amp1/ramp_up_time.*tspan + (tspan >= ramp_up_time).*...
    (amp1 - amp1/ramp_down_time.*(tspan - ramp_up_time)));
muscle_force2= amp2.*saw.*((tspan < ramp_up_time).*...
    amp2/ramp_up_time.*tspan + (tspan >= ramp_up_time).*...
    (amp2 - amp2/ramp_down_time.*(tspan - ramp_up_time)));

% [ TOUT, YOUT ] = ODE45( ODEFUN, TSPAN, X0 )
[t, ts]= ode45('osc', tspan, [1.0, 0, 1.9, 0]);
y= ts(:,3)-mean(ts(:,3)) - (ts(:,1)-mean(ts(:,1)));

%% generate figure

close all force;
ftSize= 14; % font size

f= figure; clf;
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0, 1, 1]);

subplot(4,1,1); %%%%
hold on;
% plot(t, ts(:,3)-mean(ts(:,3)), 'LineWidth', 1.5);
% plot(t, ts(:,1)-mean(ts(:,1)), 'r', 'LineWidth', 1.5);
plot(t*1e3, y, 'k', 'LineWidth', 1.5);
set(gca, 'FontSize', ftSize);
xlabel('Time (ms)', 'Interpreter', 'LaTeX', 'FontSize', ftSize);
xlim([0.01 299.99]);
ylabel('Amplitude', 'Interpreter', 'LaTeX', 'FontSize', ftSize);
title('Generated Grunt Waveform', ...
    'Interpreter', 'LaTeX', 'FontSize', ftSize+2);

[Pxx, W]= pwelch(y, [], [], [], Fs);
Pxx= 20*log10(Pxx);
[yFish, FsFish, PxxFish, WFish]= psde(...
    'tank8, grunt 8.45.27, 5.21.wav', Fs);
PxxFish= 20*log10(PxxFish);

% frequency limits in kHz
UL= 3;

subplot(4,1,2); %%%%
plot(W./1e3, Pxx, 'k', 'LineWidth', 1.5);
set(gca, 'xlim', [0 UL], 'FontSize', ftSize);
xlabel('Frequency (kHz)', 'Interpreter', 'LaTeX', 'FontSize', ftSize);
ylabel('Power (dB)', 'Interpreter', 'LaTeX', 'FontSize', ftSize);
title('Generated Grunt Welch Power Spectral Density Estimate', ...
    'Interpreter', 'LaTeX', 'FontSize', ftSize+2);

subplot(4,1,3); %%%%
plot(WFish./1e3, PxxFish, 'LineWidth', 1.5);
set(gca, 'xlim', [0 UL], 'FontSize', ftSize);
xlabel('Frequency (kHz)', 'Interpreter', 'LaTeX', 'FontSize', ftSize);
ylabel('Power (dB)', 'Interpreter', 'LaTeX', 'FontSize', ftSize);
title('Observed Welch Power Spectral Density Estimate', ...
    'Interpreter', 'LaTeX', 'FontSize', ftSize+2);

subplot(4,1,4); %%%%
spectrogram(y, 256, [], [], Fs, 'yaxis');
clim([-150 0]);
colormap('turbo');
colorbar('off');
set(gca, 'ylim', [0 UL], 'FontSize', ftSize);
xlabel('Time (ms)', 'Interpreter', 'LaTeX', 'FontSize', ftSize);
ylabel('Frequency (kHz)', 'Interpreter', 'LaTeX', 'FontSize', ftSize);
title('Generated Grunt Spectrogram', ...
    'Interpreter', 'LaTeX', 'FontSize', ftSize+2);

shg;

% save figure
savefig(f, 'spectra.fig');

y_max= max(max(y), max(-y));
y_normalized= y./y_max;
audiowrite('generated_grunt.wav', y_normalized, Fs);
soundsc(y_normalized, Fs)

waitforbuttonpress;
yFish_max= max(max(yFish), max(-yFish));
yFish_normalized= yFish./yFish_max;
soundsc(yFish_normalized, FsFish);

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

