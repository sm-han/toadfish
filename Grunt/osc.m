% Model Optimization
% Author: Sang Min Han
% Last modified: 2023/09/06
%

function [ xdot ] = osc( t, x )
% osc is the system of differential equations describing the model dynamics
%
%   t is the time vector
%   x = [pos1 vel1 pos2 vel2]
%

global k1 d1 amp_tendon k13
global k2 d2 k23
global muscle_force1 muscle_force2
global Fs % muscle waveform

rest_pos1= 1.0;
rest_pos2= 1.9; % 1.5

% 100 Hz, peak toward leading edge
% optional ramped force
tindex= fix(t*Fs) + 1;

% tendon length/force
tendon_len= x(3) - x(1);
if tendon_len > 0
    tendon_force= amp_tendon*(tendon_len^7)/(1 + tendon_len^7);
else
    tendon_force= 0;
end

% if tendon_len > 1
%     tendon_force= amp_tendon*(tendon_len - 1)^7;
% else
%     tendon_force= 0;
% end

% linear + cubic spring
spring_force1= k1*((x(1)-rest_pos1) + k13*(x(1)-rest_pos1)^3);
spring_force2= k2*((x(3)-rest_pos2) + k23*(x(3)-rest_pos2)^3);

xdot(1)= x(2);
xdot(2)= -spring_force1 - d1*x(2) - muscle_force1(tindex) + tendon_force;
% -muscle_force1
xdot(3)= x(4);
xdot(4)= -spring_force2 - d2*x(4) + muscle_force2(tindex) - tendon_force;

xdot= [xdot(1); xdot(2); xdot(3); xdot(4)];

end

