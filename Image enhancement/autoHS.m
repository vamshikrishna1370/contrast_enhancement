%%              Interval Type-2 Approach to Automatic PDF Generation for Histogram Specification

%function autoHS(img, methodFlag)

% img = Image name within quotes('') with specified format. Example : 'lena.jpg', 'ball.tiff'
% methodFlag = Specify method number for calculation of MEMBERSHIP VALUE
% 1. Pointwise, 2. Centre-of-weights, 3. Area method

%% Data pre-processing
clc;clear all;close all;
img='/home/vamshi/Desktop/Image enhancement/Images and theie enhanced imaged/1.jpg';
img_o = imread(img);                                    %Reading image 
if size(img_o,3)==3
    img_o = rgb2gray(img_o);                                    %Converting the RGB to grayscale
end
methodFlag=1;
%figure, subplot(2,2,1), imshow(img_o);                 %Figure 1, Plotting original image and its histogram
%subplot(2,2,2), imhist(img_o);
%title('Image Histogram');

%% Generating normalized smooth histogram of the image

[histVal,x] = imhist(img_o);                                      %Storing values of 256 histogram bins
smoothHistVal = smooth(histVal);                                    %Smoothening the histogram values

%subplot(2,2,3), bar(x, smoothHistVal);                         %Plotting the unnormalized smooth histogram
%title('Smooth Histogram');

normHistVal = (smoothHistVal - min(smoothHistVal))./(max(smoothHistVal)-min(smoothHistVal));     %Normalizing the histogram
normHistVal = normHistVal';

%subplot(2,2,4), bar(x, normHistVal);                         %Plotting the normalized smooth histogram
%title('Normalized Smooth Histogram');

%% Performing Polynomial fitting on the smoothened histogram.
%Fitting the nth order polynomial to the histogram data
theta = polyfit(x, normHistVal', 2);                              %Getting coefficients of the nth polynomial         
polyVal = polyval(theta,x);                                       %Evaluating the best fit polynomial

%% Generating best fit gaussian

[mf,partition] = membershipFunction(img);  mf = mf';                        %Fitting Gaussian MF and calculating partition
n = size(mf,1);                                                             % No. of MF
%plot(x,mf,'LineWidth',2);

%% Generating upper and lower gaussian membership functions

mfUpper = zeros(n,256); mfLower = zeros(n,256);
mfUpper1 = zeros(n,256); mfLower1 = zeros(n,256); paramUpper = zeros(n,3); paramLower = zeros(n,3);

%Segregating Histogram for Upper and Lower MFs
for i = 1:n
    for j = partition(i):partition(i+1)
        
        if normHistVal(j)>mf(i,j)
            mfUpper1(i,j) = normHistVal(j);
            mfLower1(i,j) = mf(i,j);
        else
            mfUpper1(i,j) = mf(i,j);
            mfLower1(i,j) = normHistVal(j);
        end
    end
end

% Fitting gausssian in the Upper and Lower membership functions
fitU = cell(1,n); fitL = cell(1,n);
for i = 1:n
    fitU{i} = fit(x,mfUpper1(i,:)','gauss1');
    fitL{i} = fit(x,mfLower1(i,:)','gauss1');
    paramUpper(i,:) = coeffvalues(fitU{i});
    paramLower(i,:) = coeffvalues(fitL{i});
    mfUpper(i,:) = gaussian(paramUpper(i,1),0:255,paramUpper(i,2),paramUpper(i,3));
    mfLower(i,:) = gaussian(paramLower(i,1),0:255,paramLower(i,2),paramLower(i,3));
end

%% Generation of Membership Value

[domainLower,cLower] = domain_gray(mfLower);
[domainUpper,cUpper] = domain_gray(mfUpper);
mvLower = zeros(1,256); mvUpper = zeros(1,256);
muUpper = zeros(1,n); muLower = zeros(1,n);


switch (methodFlag)
    case 1 
        %----------Pointwise Method----------
        for i = 1:256
            for j=1:n
                if domainLower(i)==j
                    mvLower(i) = 1 - abs(mfLower(j,i) - normHistVal(i));
                end
                if domainUpper(i)==j
                    mvUpper(i) = 1 - abs(mfUpper(j,i) - normHistVal(i));
                 end
            end
        end
        %--------------------------------------  
    
    case 2
        %-----------Center of Weights Methods--------------
        gLower = sum((repmat(x',n,1).*min(mfLower,normHistVal)),2)./sum(min(mfLower,normHistVal),2);
        gUpper = sum((repmat(x',n,1).*min(mfUpper,normHistVal)),2)./sum(min(mfUpper,normHistVal),2);
        
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
        %-----------------------------------------------------
    
    case 3
        %-----------Area Method-------------
        for i = 1:256
            for j=1:n
                if domainLower(i)==j
                    mvLower(i) = sum(min(mfLower(j,:),normHistVal),2)./sum(mfLower(j,:));
                end
                if domainUpper(i)==j
                    mvUpper(i) = sum(min(mfUpper(j,:),normHistVal),2)./sum(mfUpper(j,:));
                 end
            end
        end
        %------------------------------------
    
    otherwise
        %--------Otherwise use Method 2---------------
        gLower = sum((repmat(x',n,1).*min(mfLower,normHistVal)),2)./sum(min(mfLower,normHistVal),2);
        gUpper = sum((repmat(x',n,1).*min(mfUpper,normHistVal)),2)./sum(min(mfUpper,normHistVal),2);
        
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
        %-------------------------------------------------
end

%% Generating pdf from upper and lower MF
muUpper(:) = paramUpper(:,2);               % Mean of Upper and Lower MFs
muLower(:) = paramLower(:,2);
pdfUpper = zeros(1,256); pdfLower = zeros(1,256);

T = find(normHistVal~=0, 1, 'last' );              % Largest non-zero grayscale value in the image
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
pdfFinal = unNormpdf./s;                    % Final probability density function

%% Histogram Specification from the generated pdf

imgEnhanced = histeq(img_o, pdfFinal);
%imwrite(imgEnhanced, 'en1.jpg');

%% Evaluating image enhancement

%Evaluating performance according to AIC

hist_enhanced = imhist(imgEnhanced);
hist_enhanced = hist_enhanced./sum(hist_enhanced);
temp = -hist_enhanced(hist_enhanced~=0);
scoreEnhanced = sum(temp.*log2(temp));

%Evaluation of the Original Image
s = sum(normHistVal);
pdfOrig = normHistVal./s;                     %Generating PDF for Input Image

temp = pdfOrig(pdfOrig~=0);
scoreOrig = -sum(temp.*log2(temp));
fprintf('Initial Score: %f \n',scoreOrig);
fprintf('Enhanced Image Score: %f \n',scoreEnhanced);

[s1i, s1o] = AMBE(img_o , imgEnhanced);
fprintf('New, Input: %f ,Output: %f \n',s1i,s1o);
fprintf('PSNR: %f \n',psnr(imgEnhanced, img_o));
%% Plotting the original and the enhanced image

figure, subplot(2,2,1), imshow(img_o), title('Original Image')
subplot(2,2,2), imshow(imgEnhanced), title ('Enhanced Image')
subplot(2,2,3), imhist(img_o), title('Histogram of Original Image')
subplot(2,2,4), imhist(imgEnhanced), title('Histogram of Enhanced Image')

figure, area(x, pdfFinal); xlabel('Grayscale'); ylabel('Probability');
title('Automatic generated Probability Density Function');