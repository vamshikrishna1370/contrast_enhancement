%% Function for finding the minima between two significant peaks 
%pass histogram valued array(counts) and location/index of peaks(vtemp3)
%and "number of peaks plus 1"(k),returns L location of minima array and
%M is the minima value array at respective minima location
function [L,M] = find_minima(counts,vtemp3,k) 
fprintf("Finding minima between peaks...\n");
if k>2
    for i=2:k-1
        set=(counts(vtemp3(i-1)+1:vtemp3(i)));
        %fidn the minima of given set and assign the minim ans the location
        %of minima to the M and L respectively 
        [M(i-1),L(i-1)] = min(set);
        L(i-1) = L(i-1) + vtemp3(i-1);
        %plot the minima on the significant peaks plot marked with "O" (circle) 
        hold on; plot(L(i-1),M(i-1),'O');
    end
    fprintf("Identified minima are at location indices \n");
    disp(L);
%If no minima is identified then create the 
else
    fprintf("Identifiedc no peaks between peaks , so for not to slpit the data assigning the L(1)=256 i.e, split at 256 (which is end of plot) \n");
    L(1)=256;
    M(1)=min(counts(vtemp3(1)+1:256));
end

end