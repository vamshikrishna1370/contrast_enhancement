function  psnr_score = PSNR(input_image, output_image)
% CALCULATING THE PERFORMANCE OF THE IMAGE ENHANCEMENT TECHNIQUE USING PSNR
    psnr_score = psnr(output_image ,input_image);
end
