function [org_score, new_score] = AMBE(input_image, output_image)
% CALCULATING THE PERFORMANCE OF THE IMAGE ENHANCEMENT TECHNIQUE USING AMBE
    
org_score = mean(input_image(:));
new_score = mean(output_image(:));
end