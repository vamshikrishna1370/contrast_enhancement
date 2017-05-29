function [gausf,l] = membershipFunction(image)
I = imread(image);                                         %Extracting image as a unnormalized histogram
grayflag=size(size(I)');
if grayflag(1)==3
    I = rgb2gray(I);                                                %Converting the rgb figure to grayscale figure
end
% figure, subplot(2,2,1), imshow(I); %Figure 1
% title('GrayScale Image');
% subplot(2,2,2), imhist(I);
% title('Histogram of Image');
%%
% Step: 1--Smoothen the histogram of the input image
[counts,x] = imhist(I);                                         %Extracting data for Image I in form of number of pixels having the particular gray level
counts = smooth(counts);
% subplot(2,2,3), bar(x, counts);
% title('Smooth Histogram');
counts = (counts - min(counts))./(max(counts)-min(counts));     %Normalizing the Image I
counts = smooth(counts);
% subplot(2,2,4), bar(x, counts);
% title('Normalized Smooth Histogram');
% figure,plot(x,counts);

%Assumin the plot has three peaks 
%%
[vtemp3,vtemp4,k] = find_peeks(counts,x); %plot the peak identified graph with half peak prominanace algorithm
%%
[L,M]=find_minima(counts,vtemp3,k);% get the minima between the identified significant peaks ,k returns number of significant peaks +1
k=k-1;
%%
l =[1 L 256];
%% genralization of the fitting for any number of significant peaks
%gausl is matrix of all left fitted gausians
%gausr is matrix of all right fitted gausians
%gausf is matrix (256Xn) of combined left and right gausians ,where n is
%the number of peaks identified.
figure, bar(counts);
gausl=zeros(256,k);
gausr=zeros(256,k);
gausf=zeros(256,k);
for i=1:k
    [sdl(i),errl(i),gausl(:,i)] = plot_left_gaussian(l(i),vtemp3(i),vtemp4(i),x,counts);
    [sdr(i),errr(i),gausr(:,i)] = plot_right_gaussian( vtemp3(i),l(i+1),vtemp4(i),x,counts );
    gausf(:,i)=[gausl(1:vtemp3(i),i); gausr(vtemp3(i)+1:256,i)];
end
return;
end