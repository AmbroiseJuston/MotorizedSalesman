function ds = ODEMain(t, s, times, r)
for ii = 1:numel(times)
  ds(ii*8-7:ii*8, 1) = ODEs(t, s(1:8), r)*times(ii);
end
end
