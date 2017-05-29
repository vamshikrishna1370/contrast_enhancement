%% Function which plots and finds asymetric gausian from given mean 
% MuL is peak location and L location of next minima ,vtemp4 is maximum
% value on yaxis  
function [sd,err,gausl] = plot_left_gaussian(L,MuL,vtemp4,x,counts)
fprintf("Finding the best fit gausian (Left side) from last minima(split) at %d to Mean %d.....",L, MuL);
sigma=0.01;
gaustemp1=gaussian_v(vtemp4,MuL,sigma);
gausl=gaustemp1';
% for 1st element to fisrt peak best gausian fitting
err=10000;
for i=1:10000
    k = immse(gausl(L:MuL),counts(L:MuL));
    if err > k
        err= k;
        sd=sigma;
    end
    %fprintf("sigma updated to %f \n",sd);
    sigma=sigma + 0.01;
    gausl=(gaussian_v(vtemp4,MuL,sigma))' ;
        
end
gausl=(gaussian_v(vtemp4,MuL,sd))';
%figure,plot(x,gaus1);
hold on; plot(x(1:MuL),gausl(1:MuL),'r','LineWidth',2);
%hold on; bar(counts);  
fprintf("Sigma for Best fit %f with error %f.\n",sd,err);
end