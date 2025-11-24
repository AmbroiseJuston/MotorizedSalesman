for r = 1.5:0.1:10
    solinit.x = sol.x;
    solinit.y = sol.y;
    solinit.parameters = sol.parameters;
    sol = bvp4c(@(t,s,times)ODEMain(t,s,times,r), @(so,sf,times)bcfunc(so,sf,times, r, points), solinit, options);
    fprintf("final time  = %2.4f\n", sum(sol.parameters))
end
