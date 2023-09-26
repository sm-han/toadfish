% Driver for Optimization
% Author: Sang Min Han
% Last modified: 2023/09/12
%

close all force; clear; clc;
global maxIter kRatio dRatio ampRatio

maxIter= 1e3;
kRatio= 0.5;
dRatio= 1; % dRatios= [2,1,1/2];
ampRatio= 1;

d= date;

% x0= [k2, d2, amp2]
x0= [7.5e5, 1.4e3, 7.5e3];

tol= 1e-3;

diary([d '.txt']);
fprintf('k1:k2\t d1:d2\t amp1:amp2\n');
fprintf('%.1f\t %.1f\t %.1f\n', kRatio, dRatio, ampRatio);

[x, mse, exitflag, output]= fminsearch(@(x) optimize(x), x0, ...
    optimset('Display', 'iter', 'FunValCheck', 'on', 'MaxFunEvals', ...
    Inf, 'MaxIter', maxIter, 'TolFun', tol, 'TolX', tol));

diary;
save([pwd sprintf('/%s.mat', d)], '-v7.3');

disp('Finished');

