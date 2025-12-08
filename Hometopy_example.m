clc;clear
N = 100
cities = [8.5, 6.2, 3.5, 5.1, 4.0, 0.8, 2.4, 1.2, 1.8, 2.4; 4.2, 0.5, 9.0, 9.4, 4.9, 4.9, 3.4, 9.0, 3.7, 1.1];

sequence = [1 2 3 4 5 6 7 8 9 10];
cities_x = [0 cities(1, sequence)]
cities_y = [0 cities(2, sequence)]

plot(cities_x, cities_y, "xk")
axis([0 10 0 10])
grid on
axis equal

% arc_dist = dist2(cities_x, cities_y)
steps_end = polarSteps([cities_x; cities_y])

steps_start = [steps_end(1, :); steps_end(2, 1)*ones(1, length(steps_end))]
difference_rad = steps_end(2, :) - steps_start(2, :)

steps = steps_start;
for ii = 2:length(difference_rad)
    rad_sweep = linspace(steps(2, ii), steps_end(2, ii));
    for jj = 1:N
        steps(2, ii:end) = rad_sweep(jj);
        cartesian_mod = polarSteps2cart([0 0], steps);
        plot(cartesian_mod(1, :), cartesian_mod(2, :));
        axis equal
        pause(1/60)
    end
end

function D = dist2(Array_X, Array_Y)
% Returns the distance of EACH arc segment
% D(i) = distance from point i → i+1
N = numel(Array_X);
D = zeros(1, N-1);

for ii = 1:N-1
    D(ii) = sqrt( (Array_X(ii+1) - Array_X(ii))^2 + ...
                  (Array_Y(ii+1) - Array_Y(ii))^2 );
end
end

function steps = polarSteps(points)
% points is 2×N: [x; y]
% returns 2×(N-1): [distance; angle]

x = points(1,:);
y = points(2,:);

N = size(points,2);
steps = zeros(2, N-1);

for i = 1:N-1
    dx = x(i+1) - x(i);
    dy = y(i+1) - y(i);

    dist  = sqrt(dx^2 + dy^2);   % radial distance between points
    angle = atan2(dy, dx);       % direction to travel

    steps(:, i) = [dist; angle];
end
end

function points = polarSteps2cart(startPoint, steps)
% startPoint : [x0; y0] column vector (2×1)
% steps      : 2×N matrix, each column = [distance; angle]
% returns    : 2×(N+1) matrix of Cartesian coordinates

N = size(steps, 2);
points = zeros(2, N+1);

% Set starting point
points(:,1) = startPoint;

for i = 1:N
    d = steps(1,i);      % distance to next point
    a = steps(2,i);      % angle (radians)

    % Convert polar step→local cartesian displacement
    dx = d * cos(a);
    dy = d * sin(a);

    % accumulate
    points(:, i+1) = points(:, i) + [dx; dy];
end
end
