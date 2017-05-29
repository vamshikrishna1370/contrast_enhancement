%% Function for calculating significant peaks from the histogram given with half-prominanece peak method 
%pass counts= histogram array and x is the x-axis array i.e,1 to 256 
%this returns 3 variables ,loc is location of significant peaks (index of the peak),pks is the peak value at the respective location
%K is the ""(nubmer of peaks identified)+1""  made it like this to make ease further calculation as matlab does not allow index 0 Eg:-A(0)  in further steps  

function [loc,pks,k] = findpeeks(counts,x)
fprintf("Finding Significant Peaks ......\n ");

%thres=Threshold value of the significant peak area i.e, height *width
thres=1;

%calculating the peak width at half promienence 
findpeaks(counts,x,'Annotate','extents','WidthReference','halfprom')
title('Identifying Significant peaks with half-prominance')

% proms is the prominanace of each peak i.s, height of each peak
[pks,locs,widths,proms] = findpeaks(counts,x);

%vtemp1 is the array of areas of significance whichis further compared with
%threshold to obtain significant peaks
vtemp1 = widths.*proms;
fprintf("The significance of each peak is \n");
disp(vtemp1);

%vtemp2 is a variable for total number of peaks (significant with insignificant)
vtemp2 = (size(vtemp1()));
k=1;
for i=1:vtemp2(1)
    if vtemp1(i)>=thres
        vtemp3(k)= locs(i);
        vtemp4(k)= pks(i);
        k=k+1;
    end    
end
%If suppose there is no significant peak then, just assigning the maximum of
%histogram as peak value and making k=2,as now we got a peak identified
if k==1
    [vtemp4,vtemp3] = max(counts);
    k=2;
end    
loc = vtemp3;
pks = vtemp4;
fprintf("Identified significant peaks are at \n");
disp(vtemp3);
fprintf("NOTE: This significance is obtained by considering threshold value as %f ( prominence*width > %f )\n \n",thres,thres);
end
