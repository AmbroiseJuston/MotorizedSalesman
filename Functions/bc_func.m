clc
clear

start = [0 0]; % Starting Corner

function con = bcfunc(so, sf, ~, r, cities, start, times)

con(1) = so(1)-start(1); % x(0) = 0
con(2) = so(2)-start(2); % y(0) = 0
con(3) = so(7); % lambda_theta(0) = 0
con(4) = so(4); % v(0) = 0

for i = 1:(length(times)-1)
    con(9*i-4:9*i-1) = sf(1+8*(i-1):4+8*(i-1)) - so(8*i+1:8*i+4); % x, y, theta, v continuous
    con(9*i:9*i+1) = [sf(1+8*(i-1)) - cities(1,i)
                      sf(2+8*(i-1)) - cities(2,i)]; % Goes through cities
    con(9*i+2:9*i+3) = sf(7+8*(i-1):8+8*(i-1)) - so(8*i+7:8*i+8); % lambda_theta and lambda_v continuous
    con(9*i+4) = Hamiltonian(sf(1+8*(i-1)):8+8*(i-1),r); % Hamiltonian = 0
end

con(9*i+5) = sf(end-7) - cities(1,i); % x(tf) = cities(1,i)
con(9*i+6) = sf(end-6) - cities(2,i); % y(tf) = cities(2,i)
con(9*i+7) = sf(end-1);    % lambda_theta(tf) = 0
con(9*i+8) = sf(end);    % lambda_v(tf) = 0
con(9*i+9) = Hamiltonian(sf(end-7:end), r); % Hamiltonian(tf) = 0

end
