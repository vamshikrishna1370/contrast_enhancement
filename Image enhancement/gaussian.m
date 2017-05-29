function g = guassian(a,x,u,sigma)
g = a*exp(-((x-u)./sigma).^2);
end