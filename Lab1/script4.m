%% Exercise 4
close all
clear
clc

I = imread('NotreDame.png');
I = im2double(rgb2gray(I));
FT = fft2(I);
shifted_FT = fftshift(FT);
M_FT = log(abs(shifted_FT)+1);
M_FT = normalize(M_FT,'range');

modified_FT_A = shifted_FT;
modified_FT_A(120:135, 50:122) = 0 + 0i;
modified_FT_A(120:135, 136:200) = 0 + 0i; 
M_FT_A = log(abs(modified_FT_A)+1);
M_FT_A = normalize(M_FT_A,'range');
I_A = abs(ifft2(ifftshift(modified_FT_A)));

modified_FT_B = shifted_FT;
modified_FT_B(92:97, 86:174) = 0 + 0i;
modified_FT_B(158:164, 91:172) = 0 + 0i; 
M_FT_B = log(abs(modified_FT_B)+1);
M_FT_B = normalize(M_FT_B,'range');
I_B = abs(ifft2(ifftshift(modified_FT_B)));

modified_FT_C = shifted_FT;
modified_FT_C(124:133, 124:133) = 0 + 0i;
M_FT_C = log(abs(modified_FT_C)+1);
M_FT_C = normalize(M_FT_C,'range');
I_C = abs(ifft2(ifftshift(modified_FT_C)));

figure('Name','Exercise 3','NumberTitle','off');
subplot(2,4,1);
imshow(I);
title('original');

subplot(2,4,2);
imshow(I_A);
title('result A');

subplot(2,4,3);
imshow(I_B);
title('result B');

subplot(2,4,4);
imshow(I_C);
title('result C');

subplot(2,4,5);
imagesc(M_FT);
axis equal off; colormap gray;
title('magnitude');

subplot(2,4,6);
imagesc(M_FT_A);
axis equal off; colormap gray;
title('modified magnitude A');

subplot(2,4,7);
imagesc(M_FT_B);
axis equal off; colormap gray;
title('modified magnitude B');

subplot(2,4,8);
imagesc(M_FT_C);
axis equal off; colormap gray;
title('modified magnitude C');
