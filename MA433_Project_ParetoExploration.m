clc; clear; close all
%% initialization of the problem
cities = [8.5, 6.2, 3.5, 5.1, 4.0, 0.8, 2.4, 1.2, 1.8, 2.4; 4.2, 0.5, 9.0, 9.4, 4.9, 4.9, 3.4, 9.0, 3.7, 1.1];
cityseq = perms(1:10);
sequences = [ones(length(cityseq), 1), cityseq; 2*ones(length(cityseq), 1), cityseq; 3*ones(length(cityseq), 1), cityseq; 4*ones(length(cityseq), 1), cityseq];
corners = [0, 10, 10, 0; 0, 0, 10, 10];

%% showing sequences
SequenceIndex = [184489;
                 320648;
                 321757;
                 6555397;
                 10862208;
                 11882431;
                 11882551;
                 11884207;
                 11813066;
                 321757;
                 322009;
                 81420];

for ii = 1:numel(SequenceIndex)
    figure(ii)
    [turning, distance] = ShowSequence(sequences,cities, corners, SequenceIndex(ii));
end
%% itteration
sequence_distance = zeros(length(sequences), 1);
sequence_turning = zeros(length(sequences), 1);
for ii = 1:length(sequences)
    x = [corners(1, sequences(ii, 1)), cities(1, sequences(ii, 2:end))];
    y = [corners(2, sequences(ii, 1)), cities(2, sequences(ii, 2:end))];
    sequence_distance(ii) = dist2(x, y);
    sequence_turning(ii) = turning_angles(x, y);
    disp(ii)
end

%% Plotting all points that matlab can show
figure(1)
plot(sequence_turning, sequence_distance, 'kx')

%% Pareto front
% Combine turning and distance into a matrix
data = [sequence_turning, sequence_distance];

% Loop to find lower-left (Pareto front) sequences
isBoundary = true(size(data,1),1);
for i = 1:size(data,1)
    for j = 1:size(data,1)
        if i ~= j
            % j dominates i if smaller in both turning and distance
            if all(data(j,:) <= data(i,:)) && any(data(j,:) < data(i,:))
                isBoundary(i) = false;
                break
            end
        end
    end
end

% Indices of boundary sequences
boundaryIdx = find(isBoundary);
% Get Boundary points from the logical array
boundaryPoints = data(boundaryIdx,:);

% Plot all sequences
figure(2); hold on;
scatter(sequence_turning, sequence_distance, 10, 'k', 'filled'); % all sequences
scatter(boundaryPoints(:,1), boundaryPoints(:,2), 50, 'r', 'filled'); % lower-left boundary
xlabel('Total Turning (deg)');
ylabel('Total Distance');
grid on;
title('Distance vs Turning with Lower-left Boundary Highlighted');
legend('All sequences','Lower-left boundary');

% indices ofthe bounded sequences
disp('Indices of sequences on lower-left boundary:');
disp(boundaryIdx);


function [D] = dist2(Array_X, Array_Y)
% -Discrete distance calculator given a list of values in vector form
% -Array_X/Y corresponds to the X and Y coordinates given to the function
% -Returns the distance D covered by follwoing the curve defined 
%  by the coordinates in Array_X/Y
%
% Array_X and Array_Y must be of the same size/numbe of elements
D = 0.0;
for ii = 1:numel(Array_X)-1
  D = D + sqrt( (Array_X(ii+1)-Array_X(ii))^2 + (Array_Y(ii+1)-Array_Y(ii))^2 );
end
end

function [turning] = turning_angles(Array_X, Array_Y)
% Calculates the turning angle between consecutive path segments
n = numel(Array_X);
angles = zeros(1, n-2); % n-2 internal angles

for ii = 2:n-1
    v1 = [Array_X(ii) - Array_X(ii-1), Array_Y(ii) - Array_Y(ii-1)];
    v2 = [Array_X(ii+1) - Array_X(ii), Array_Y(ii+1) - Array_Y(ii)];
    % Compute angle between vectors
    cosTheta = dot(v1, v2) / (norm(v1) * norm(v2));
    % Protect against rounding errors
    cosTheta = max(min(cosTheta, 1), -1);
    angles(ii-1) = acosd(cosTheta); % in degrees
end
    turning = sum(angles);
end

% ShowSequence without 'figure' inside
function [sequence_turning, sequence_distance] = ShowSequence(sequences,cities, corners, idx)
    scatter(cities(1, :), cities(2, :), 'xk')
    hold on;
    x = [corners(1, sequences(idx, 1)), cities(1, sequences(idx, 2:end))];
    y = [corners(2, sequences(idx, 1)), cities(2, sequences(idx, 2:end))];
    plot(x, y, 'Color', [1, 0, 0])
    axis equal 
    axis([0 10 0 10])
    grid on
    hold off

    sequence_distance = dist2(x, y);
    sequence_turning = turning_angles(x, y);
end