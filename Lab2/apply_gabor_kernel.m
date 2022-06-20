function [out_img] = apply_gabor_kernel(in_img,gb_r,gb_i)
    filtered_r = conv2(in_img, gb_r, 'valid');
    filtered_i = conv2(in_img, gb_i, 'valid');
    out_img = sqrt((filtered_r.^2 + filtered_i.^2)./2);
end

