%%     Vamshi         Interval Type-2 Approach to Automatic PDF Generation for Histogram Specification

%% Data pre-processing -- Give Input Here

clc;
clear all;
close all;
img = '/home/vamshi/Desktop/Image enhancement/Images and theie enhanced imaged/4.pgm';                                               %Image name
img_o = imread(img);                                            %Reading image 
grayflag=size(size(img_o)');
if grayflag(1)==3
    img_o = rgb2gray(img_o);                                                %Converting the rgb figure to grayscale figure
end

%% Choose Method to find the Membership Values from Membership function
% A = Pointwise Method
% B = Center of Weights Method
% C = Area Method

METHOD_FLAG = 'A';

%% Step: 1--Smoothening and Normalization of histogram of the input image

figure, subplot(2,2,1), imshow(img_o);                            %Figure 1, Plotting original image and its histogram
subplot(2,2,2), imhist(img_o);
title('Image Histogram');

[histVal,x] = imhist(img_o);                                      %Storing values of 256 histogram bins
smoothHistVal = smooth(histVal);                                  %Smoothening the histogram values

subplot(2,2,3), bar(x, smoothHistVal);                            %Plotting the unnormalized smooth histogram
title('Smooth Histogram');

normHistVal = (smoothHistVal - min(smoothHistVal))./(max(smoothHistVal)-min(smoothHistVal));     
normHistVal = normHistVal';                                       % Normalizing histogram

subplot(2,2,4), bar(x, normHistVal);                              %Plotting the normalized smooth histogram
title('Normalized Smooth Histogram');

%% Step: 2--Performing Polynomial fitting on the smoothened histogram.
%Fitting the nth order polynomial to the histogram data
theta = polyfit(x, normHistVal', 2);                              %Getting coefficients of the nth polynomial         
polyVal = polyval(theta,x);                                       %Evaluating the best fit polynomial


%% Step: 3 Fitting the gaussian.

[mf,partition] = membershipFunction(img);  mf = mf';              %Fitting Gaussian MF and calculating partition
n = size(mf,1);                                                   % No. of MF
figure,
plot(x,mf,'LineWidth',2);

%% Step: 4 Generating upper and lower gaussian membership functions

mfUpper = zeros(n,256); mfLower = zeros(n,256);

%Segregating Histogram for Upper and Lower MFs
for i = 1:n
    for j = partition(i):partition(i+1)
        
        if normHistVal(j)>mf(i,j)
            mfUpper(i,j) = normHistVal(j);
            mfLower(i,j) = mf(i,j);
        else
            mfUpper(i,j) = mf(i,j);
            mfLower(i,j) = normHistVal(j);
        end
    end
end

% Calculating difference in original and upper, lower histograms
mfUpper1 = zeros(n,256); mfLower1 = zeros(n,256); paramUpper = zeros(n,3); paramLower = zeros(n,3);
for i=1:n
    for j = partition(i):partition(i+1)
        mfUpper1(i,j) = mfUpper(i,j) - normHistVal(j);
        mfLower1(i,j) = normHistVal(j) - mfLower(i,j);
    end
end

% Fitting gausssian in the difference curve
fitU = cell(1,n); fitL = cell(1,n);
for i = 1:n
    fitU{i} = fit(x,mfUpper1(i,:)','gauss1');
    fitL{i} = fit(x,mfLower1(i,:)','gauss1');
    paramUpper(i,:) = coeffvalues(fitU{i});
    paramLower(i,:) = coeffvalues(fitL{i});
    mfUpper(i,:) = gaussian(paramUpper(i,1),0:255,paramUpper(i,2),paramUpper(i,3));
    mfLower(i,:) = gaussian(paramLower(i,1),0:255,paramLower(i,2),paramLower(i,3));
end

%Generating upper and lower gaussian membership functions
mfUpper = mf + mfUpper;
mfLower = abs(mf - mfLower) ;

figure, plot(x,mfUpper);
hold on, plot(x,mfLower);
title('FOU is the region between two curves');

%% Step :5 Generating Membership Value using different Methods (Switch Cases)
% Determining the domain and cross-over points
[domainLower,cLower] = domain_gray(mfLower);
[domainUpper,cUpper] = domain_gray(mfUpper);
mvLower = zeros(1,256); mvUpper = zeros(1,256);
muUpper = zeros(1,n); muLower = zeros(1,n);

switch (METHOD_FLAG)
    case 'A'
        % Obtaining Fuzzy Membership Value : Pointwise Methods
        fprintf('Pointwise Method in processing \n');
        gLower = 1 - sqrt((mfLower - normHistVal).^2);
        gUpper = 1 - sqrt((mfUpper - normHistVal).^2);
          
    case 'B'
        % Obtaining Fuzzy Membership Value : Center of Weights Methods
        fprintf('Center of Weights Method in processing\n');
        gLower = sum((repmat(x',n,1).*min(mfLower,normHistVal)),2)./sum(min(mfLower,normHistVal),2);
        gUpper = sum((repmat(x',n,1).*min(mfUpper,normHistVal)),2)./sum(min(mfUpper,normHistVal),2);
           
    case 'C'
        % Obtaining Fuzzy Membership Value : Area Method
        fprintf('Area Method in processing\n');
        gLower = sum((repmat(x',n,1).*min(mfLower,normHistVal)),2)./sum(mfLower,2);
        gUpper = sum((repmat(x',n,1).*min(mfUpper,normHistVal)),2)./sum(mfUpper,2);
    otherwise
        fprintf('Invalid!!!');
end


for i = 1:256
    for j=1:n
        if domainLower(i)==j
            mvLower(i) = gaussian(paramLower(j,1),gLower(j),paramLower(j,2),paramLower(j,3));
        end
        if domainUpper(i)==j
            mvUpper(i) = gaussian(paramUpper(j,1),gUpper(j),paramUpper(j,2),paramUpper(j,3));
        end
    end
end

%% Step :6 Generating pdf from upper and lower MF

muUpper(:) = paramUpper(:,2);                                 % Mean of Upper and Lower MFs
muLower(:) = paramLower(:,2);
pdfUpper = zeros(1,256); pdfLower = zeros(1,256);

T = find(normHistVal~=0, 1, 'last' );                         % Largest non-zero grayscale value in the image
for i = 1:255
    if i < muUpper(domainUpper(i))
        pdfUpper(i) = T+2*mvUpper(i)*((muUpper(domainUpper(i))+cUpper(domainUpper(i),1))/2 - i);
    else
        pdfUpper(i) = T-2*mvUpper(i)*((muUpper(domainUpper(i))+cUpper(domainUpper(i),2))/2 - i);
    end
    
    if i < muLower(domainLower(i))
        pdfLower(i) = T+2*mvLower(i)*((muLower(domainLower(i))+cLower(domainLower(i),1))/2 - i);
    else
        pdfLower(i) = T-2*mvLower(i)*((muLower(domainLower(i))+cLower(domainLower(i),2))/2 - i);
    end
end

unNormpdf = (pdfLower+pdfUpper)/2; s = sum(unNormpdf);
pdfFinal = unNormpdf./s;                                       % Final probability density function

%% Step :7 Histogram Specification from the generated pdf

imgEnhanced = histeq(img_o, pdfFinal);
%imwrite(imgEnhanced, 'en1.jpg');

%% Step :8 Evaluating image enhancement using different quatitative measure.

%METHOD 8.1--Evaluating performance according to AIC-More Increment, better
%enhancement
hist_enhanced = imhist(imgEnhanced);
hist_enhanced = hist_enhanced./sum(hist_enhanced);
temp = -hist_enhanced(hist_enhanced~=0);
scoreEnhanced = sum(temp.*log2(temp));
fprintf('Enhanced Image Score: %f \n',scoreEnhanced);

%Evaluation of the Original Image
s = sum(normHistVal);
pdfOrig = normHistVal./s;                     %Generating PDF for Input Image

temp = -pdfOrig(pdfOrig~=0);
scoreOrig = sum(temp.*log2(temp));
fprintf('Initial Score: %f \n',scoreOrig);

%METHOD 8.2--Calculating AMBE Scores of original and Enhanced Image-Less
%Increment, better enhancement

[AMBE_org_score, AMBE_new_score] = AMBE(img_o, imgEnhanced);
fprintf('Initial AMBE Score: %f \n', AMBE_org_score);
fprintf('Final AMBE Score: %f \n', AMBE_new_score);

%METHOD 8.3--Calculating PSNR Score(in db)- More is the value, better is
%the enhancement

PSNR_score = PSNR(img_o, imgEnhanced);
fprintf('Final PSNR Score: %f db.\n', PSNR_score);

%METHOD 8.4--Calculating SSIM Index: More the value close to 1, better is
%the enhancement.

[mssim, ssim_map] = ssim_index(img_o, imgEnhanced);

fprintf('SSIM img_o : %f \n',mssim);


%% Plotting the original and the enhanced image
figure, subplot(2,2,1), imshow(img_o), title('Original Image');
subplot(2,2,2), imshow(imgEnhanced), title ('Enhanced Image');
subplot(2,2,3), imhist(img_o), title('Histogram of Original Image');
subplot(2,2,4), imhist(imgEnhanced), title('Histogram of Enhanced Image');