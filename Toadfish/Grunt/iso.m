% Plot Isosurfaces
% Author: Sang Min Han
% Last modified: 2023/09/22
%

close all force; clear; clc;

load('12-Sep-2023_iso');

% parameters
ftSize= 14; % font size
trans= 1.0; % transparency

fprintf('k1:k2= %2.1f\nd1:d2= %2.1f\namp1:amp2= %2.1f\n', ...
    kRatio, dRatio, ampRatio);

f= figure; clf;
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0, 1, 1]);
hold on;

p1= patch(isosurface(fval, 100), 'FaceColor', 'red', ...
    'EdgeColor', 'none');
alpha(p1, trans/2);
p2= patch(isosurface(fval, 110), 'FaceColor', 'yellow', ...
    'EdgeColor', 'none');
alpha(p2, trans/4);
p3= patch(isosurface(fval, 120), 'FaceColor', 'green', ...
    'EdgeColor', 'none');
alpha(p3, trans/6);
p4= patch(isosurface(fval, 130), 'FaceColor', 'cyan', ...
    'EdgeColor', 'none');
alpha(p4, trans/8);
p5= patch(isosurface(fval, 140), 'FaceColor', 'blue', ...
    'EdgeColor', 'none');
alpha(p5, trans/10);

% lighting control
lighting phong;
light('position', [ 1, 1, 1]);
light('position', [-1,-1,-1]);
light('position', [-1, 1,-1]);
light('position', [ 1,-1,-1]);

view(3); daspect([1,1,1]);
rotate3d on;
box on;

% axes/image control
axis([1 length(k2) 1 length(d2) 1 length(amp2)]);
set(gca,'FontSize', ftSize, ...
    'XTickLabel', k2./1e4, 'XTick', 1:length(k2), ...
    'YTickLabel', d2./1e2, 'YTick', 1:length(d2), ...
    'ZTickLabel', amp2./1e3, 'ZTick', 1:length(amp2));
xlabel('Spring Constant (AU$\times10^4$)', 'Interpreter', 'LaTeX', ...
    'FontSize', ftSize + 2, 'FontWeight', 'bold');
ylabel('Damping Term (AU$\times10^2$)', 'Interpreter', 'LaTeX', ...
    'FontSize', ftSize + 2, 'FontWeight', 'bold');
zlabel('Muscle Amplitude (AU$\times10^3$)', 'Interpreter', 'LaTeX', ...
    'FontSize', ftSize + 2, 'FontWeight', 'bold');
title('Grunt Isosurfaces', 'Interpreter', 'LaTeX', ...
    'FontSize', ftSize + 8, 'FontWeight', 'bold');
axis tight;

hold off;
shg;

% save figure
savefig(f, 'iso.fig');

