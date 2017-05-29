function [mssim, ssim_map] = ssim_index(img1, img2)


% Similarity to the reference image

%Input : (1) img1: the first image being compared
%        (2) img2: the second image being compared
%        (3) K: constants in the SSIM index formula 
%            defualt value: K = [0.01 0.03]
%        (4) window: local window for statistics
%            default widnow is Gaussian given by
%            window = fspecial('gaussian', 11, 1.5);
%        (5) L: dynamic range of the images. default: L = 255
%
%Output: (1) mssim: the mean SSIM index value between 2 images.
%            If one of the images being compared is regarded as 
%            perfect quality, then mssim can be considered as the
%            quality measure of the other image.
%            If img1 = img2, then mssim = 1.
%
%Default Usage:
%   Given 2 test images img1 and img2, whose dynamic range is 0-255
% 
%   [mssim ssim_map] = ssim_index(img1, img2);
%
%   Results:
%
%   mssim                        %Gives the mssim value
%   imshow(max(0, ssim_map).^4)  %Shows the SSIM index map

% Default Values 
window = fspecial('gaussian', 11, 1.5);	
K(1) = 0.01;								      
K(2) = 0.03;								      
L = 255;                                         

C1 = (K(1)*L)^2;
C2 = (K(2)*L)^2;
window = window/sum(sum(window));
img1 = double(img1);
img2 = double(img2);

%Y = filter2(H,X) applies a finite impulse response filter to a matrix of
%data X according to coefficients in a matrix H

mu1   = filter2(window, img1, 'valid');                                     
mu2   = filter2(window, img2, 'valid');
mu1_sq = mu1.*mu1;
mu2_sq = mu2.*mu2;
mu1_mu2 = mu1.*mu2;
sigma1_sq = filter2(window, img1.*img1, 'valid') - mu1_sq;
sigma2_sq = filter2(window, img2.*img2, 'valid') - mu2_sq;
sigma12 = filter2(window, img1.*img2, 'valid') - mu1_mu2;

numerator1 = 2*mu1_mu2 + C1;
numerator2 = 2*sigma12 + C2;
denominator1 = mu1_sq + mu2_sq + C1;
denominator2 = sigma1_sq + sigma2_sq + C2;
ssim_map = ones(size(mu1));
index = (denominator1.*denominator2 > 0);
ssim_map(index) = (numerator1(index).*numerator2(index))./(denominator1(index).*denominator2(index));
index = (denominator1 ~= 0) & (denominator2 == 0);
ssim_map(index) = numerator1(index)./denominator1(index);

%mean2() fins the mean of the matrix elements
mssim = mean2(ssim_map);

return