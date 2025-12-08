function H = Hamiltonian(s,r)

gamma = -(r/2)*s(7);
if abs(gamma)>1
    gamma = sign(gamma);
end

a = -(r/2)*s(8);
if abs(a)>1
    a = sign(a);
end

H = 1 + (1/r)*(gamma^2 + a^2) + s(5)*s(4)*cos(s(3)) + s(6)*s(4)*sin(s(3)) + s(7)*gamma + s(8)*a;
end
