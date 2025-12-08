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
