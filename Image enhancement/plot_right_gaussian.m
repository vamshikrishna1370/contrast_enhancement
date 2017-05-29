%% Function which plots and finds asymetric gausian from given mean 
% MuL is peak location and L location of next minima ,vtemp4 is maximum
% value on yaxis  
function [sd,err,gausr] = plot_right_gaussian(MuL,L,vtemp4,x,counts)
fprintf("Finding the best fit gausian (Right side) from mean %d to next minima at(split) %d.....",MuL, L);
sigma=0.01;
gaustemp1=gaussian_v(vtemp4,MuL,sigma);
gausr=gaustemp1';

% for 1st element to fisrt peak best gausian fitting
err=10000;
for i=1:10000
    k = immse(gausr(MuL:L),counts(MuL:L));
    if err > k
        % err is updated only when minimum error is identified and now it
        % self sd(standard deviation sigma is alos identified)
        err= k;
        sd=sigma;
        
    end
    %fprintf("sigma updated to %f \n",sd);
    sigma=sigma + 0.01;
    gausr=(gaussian_v(vtemp4,MuL,sigma))' ;
        
end
gausr=(gaussian_v(vtemp4,MuL,sd))';
%figure,plot(x,gaus1);
hold on;plot(x(MuL:256),gausr(MuL:256),'g','LineWidth',2);
%hold on ; bar(counts);
fprintf("Sigma for Best fit %f with error %f.\n",sd,err);
end