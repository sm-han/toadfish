% Driver for Isosurface
% Author: Sang Min Han
% Last modified: 2023/09/12
%

close all force; clear; clc;
global maxIter kRatio dRatio ampRatio

maxIter= 1e3;
kRatio= 1/2;
dRatio= 1; % dRatios= [2,1,1/2];
ampRatio= 1;

d= date;

% xi= [k2, d2, amp2]
xi= [0, 0, 0];

tol= 1e-3;
n= 20;

k2= zeros(n, 1);
d2= zeros(n, 1);
amp2= zeros(n, 1);

delta_k2= 5e4;
delta_d2= 5e1;
delta_amp2= 5e2;
for k= 1:n
    k2(k)= xi(1) + (k-1)*delta_k2;
    d2(k)= xi(2) + (k-1)*delta_d2;
    amp2(k)= xi(3) + (k-1)*delta_amp2;
end

diary([d '_iso.txt']);
fprintf('k1:k2\t d1:d2\t amp1:amp2\n');
fprintf('%.1f\t %.1f\t %.1f\n', kRatio, dRatio, ampRatio);
fprintf('calculating...\n')
fprintf('progress: k2\t d2\t amp2\t fval\n');

fval= zeros(n, n, n);
i= 0;
for a= 1:n
    for b= 1:n
        for c= 1:n
            x0= [xi(1) + (a-1)*delta_k2, ...
                xi(2) + (b-1)*delta_d2, ...
                xi(3) + (c-1)*delta_amp2];
            i= i+1;
            mse= optimize(x0);
            fprintf('%i/%i: %f\t %f\t %f\t %f\n', ...
                i, n^3, x0(1), x0(2), x0(3), mse);
            fval(a,b,c)= mse;
        end
    end
end
diary;
save([pwd sprintf('/%s_iso.mat', d)], '-v7.3');

disp('Finished');

