%% Function for calculating domain of every gray level and the crossover points in the membership functions

function [domain,crossoverPoints] = domain_gray(f)

% Calculating domain
domain=zeros(1,256);
for i=1:256
    [~,domain(i)]=max(f(:,i));
end

% Calculating the crossover points
m = size(f,1); crossoverPoints = zeros(m,2); cp = 1; crossoverPoints(1) = 1; crossoverPoints(m,2) = 256;
for i=1:255
    if domain(i+1)-domain(i)>0
        crossoverPoints(cp,2)=i; crossoverPoints(cp+1,1)=i; 
        cp=cp+1;
    end
end