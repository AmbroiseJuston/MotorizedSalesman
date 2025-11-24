clc;clear
r = 1.5

start_x = 0;
start_y = 0;
v_o = 0;
city1_x = 1;
city1_y = 2;
city2_x = 2;
city2_y = 2;
N = 11 % number of points

function fitness = fun(x, r)
    % x(1) = theta(0), 
    % x(2) = lambda_x(0), 
    % x(3) = lambda_y(0), 
    % x(4) = lambda_v(0),
    % x(5) = t1, 
    % x(6) = lambda_x(t1+), 
    % x(7) = lambda_y(t1+), 
    % x(8) = t2

    [~, S1] = ode45(@(t, s) ODEs(t, s, r), [0, x(5)], ...
                    [0, 0, x(1), 0, x(2), x(3), 0, x(4)]);

    [~, S2] = ode45(@(t, s) ODEs(t, s, r), [0, x(8)], ...
                    [S1(end, 1:4), x(6), x(7), S1(end, 7:8)]);

    fitness = x(5) + x(8) + ...
              10 * ((S1(end, 1) - 1)^2 + (S1(end, 2) - 2)^2) + ...
              10 * ((S2(end, 1) - 2)^2 + (S2(end, 2) - 2)^2) + ...
              10 * ((S2(end, 7))^2 + S2(end, 8)^2) + ...
              10 * (Hamiltonian(S2(end, :), r)^2);
end



function ds = ODEs(~, s, r)
% s(1) = x, s(2) = y, s(3) = theta, s(4) = v
% s(5) = lambda_x, s(6) = lambda_y, s(7) = lambda_theta, s(8) = lambda_v

gamma = -(r/2)*s(7);
if abs(gamma)>1
    gamma = sign(gamma);
end

a = -(r/2)*s(8);
if abs(a)>1
    a = sign(a);
end
ds(1, 1) = s(4)*cos(s(3));
ds(2, 1) = s(4)*sin(s(3));
ds(3, 1) = gamma;
ds(4, 1) = a;
ds(5, 1) = 0;
ds(6, 1) = 0;
ds(7, 1) = s(5)*s(4)*sin(s(3))-s(6)*s(4)*cos(s(3));
ds(8, 1) = -s(5)*cos(s(3))-s(6)*sin(s(3));
end

% GA options
options = optimoptions('ga', ...
    'UseParallel', true, ...      % enables parallel workers
    'UseVectorized', false, "MaxGenerations",1000);   % fitness evaluated one x at a time

% Run GA (must include options!)
x = ga(@(x) fun(x, r), 8, [], [], [], [], ...
       [0 -1 -1 -2 0.5 -2 -2 0.3], ...
       [2 2 1 1 4 1 2.5 4], ...
       [], options)
%%
% First segment
[~, S1] = ode45(@(t, s) ODEs(t, s, r), linspace(0, x(5), 11), ...
                [0, 0, x(1), 0, x(2), x(3), 0, x(4)]);

% Second segment
[~, S2] = ode45(@(t, s) ODEs(t, s, r), linspace(0, x(8), 11), ...
                [S1(end, 1:4), x(6), x(7), S1(end, 7:8)]);

% Plot
figure
plot(S1(:,1), S1(:,2), '-k', ...   % First trajectory (black)
     S2(:,1), S2(:,2), '-b', ...   % Second trajectory (blue)
     [1,2], [2,2], 'xk')           % Markers at (1,2) and (2,2)

xlabel('x')
ylabel('y')
axis equal

solinit.x = linspace(0, 1, N);
solinit.y = [S1 S2]';
solinit.parameters = [x(5), x(8)]

function ds = ODEMain(t, s,times, r)
ds(1:8, 1) = ODEs(t, s(1:8), r)*times(1);
ds(9:16, 1) = ODEs(t, s(9:16), r)*times(1);
end

function con = bcfunc(so, sf, ~, r)
start_x = 0;
start_y = 0;
city1_x = 1;
city1_y = 2;
city2_x = 2;
city2_y = 2;

con(1) = so(1)-start_x;      % x(0) = 0
con(2) = so(2)-start_y;      % y(0) = 0
con(3) = so(7);      % lambda_theta(0) = 0
con(4) = so(4);      % v(0) = 0
con(5) = sf(1) - city1_x;  % x(t1) = 1
con(6) = sf(2) - city1_y;  % y(t1) = 2
con(7:10) = sf(1:4) - so(9:12);  % x, y, theta, v continuous through t1
con(11:12) = sf(7:8) - so(15:16); % lambda_theta and lambda_v continuous through t1
con(13) = sf(9) - city2_x; % x(tf) = 2
con(14) = sf(10) - city2_y; % y(tf) = 2
con(15) = sf(15);    % lambda_theta(tf) = 0
con(16) = sf(16);    % lambda_v(tf) = 0
con(17) = Hamiltonian(sf(1:8), r);  % H(t1-) = 0
con(18) = Hamiltonian(sf(9:16), r); % H(tf) = 0
end

function H = Hamiltonian(s,r)

gamma = -(r/2)*s(7);
if abs(gamma)>1
    gamma = sign(gamma);
end

a = -(r/2)*s(8);
if abs(a)>1
    a = sign(a);
end

H = 1+(1/r)*(gamma*(gamma^2+a^2)+s(5)*s(4)*cos(s(3))+s(6)*s(4)*sin(s(3))+s(7)*gamma+s(8)*a);
end
%%
con = bcfunc(solinit.y(:, 1), solinit.y(:, end), solinit.parameters, r)'
sol = bvp4c(@(t,s,times)ODEMain(t,s,times,r), @(so,sf,times)bcfunc(so,sf,times, r), solinit)
figure(2)
plot(sol.y(1,:), sol.y(2,:), '--k', sol.y(9,:), sol.y(10,:), '--k')
