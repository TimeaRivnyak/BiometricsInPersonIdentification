%% Exercise 3
close all
clear
clc

I = imread('AlfredoBorba_TuscanLandscape.jpg');
I = imresize(I, 0.2);
I = im2double(rgb2gray(I));
K = [1 0 -1; 1 0 -1; 1 0 -1];
I_padded = padarray(I, [(size(K,1)-1)/2,(size(K,2)-1)/2], 0);
K_rotated = rot90(K,2);

I_output = zeros(size(I,1), size(I,2));
for x = 1:size(I_output, 1)
    for y = 1:size(I_output, 2)
        neighbourhood = I_padded(x:x+size(K_rotated,1)-1, y:y+size(K_rotated,2)-1);
        I_output(x,y) = sum(sum(neighbourhood.*K_rotated));
    end
end

kernel = fspecial('prewitt');
kernel = kernel';
out = conv2(I,kernel);

figure('Name','Exercise 3','NumberTitle','off');
subplot(1,3,1);
imshow(I);
title('original image');

subplot(1,3,2);
imagesc(I_output);
colormap gray;
colorbar;
axis equal off;
title('with our convolution');

subplot(1,3,3);
imagesc(out);
colormap(gca,'gray');
colorbar;
axis equal off;
title('with built-in conv2');