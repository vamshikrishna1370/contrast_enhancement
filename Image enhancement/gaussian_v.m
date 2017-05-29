function g = guassian_v(a,b,c)
for x = 1:256;
    g(x) = a*exp(-((x-b)/c)^2);
end
return;
