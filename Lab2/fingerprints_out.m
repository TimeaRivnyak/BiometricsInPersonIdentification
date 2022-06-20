close all;
clear;
clc;

original_img = imread('102_6.tif');
original_img = im2double(original_img);
original_img = original_img(:, 1:end-2);
img = imgaussfilt(original_img).*0.1; % 0.4 % 0.1
ramp = linspace(0, 0.85, size(img, 2)); % 0.55 % 0.85
img = img + repmat(ramp, size(img, 1), 1);

%%{
figure(1);
subplot(1, 2, 1);
imshow(original_img);
title('original image');
subplot(1, 2, 2);
imshow(img);
title('noisy image, this should be processed')
%%}

% ---
% please do not edit the code above, write your solution under this line,
% please handle original_img as unknown
% ---

%% Gabor-filtered
sigma = 3.8;
gamma = 1.0;
lambda = 8.5;
[gb_r1,gb_i1] = get_gabor_kernel(0,sigma,gamma,lambda);
out_img1 = apply_gabor_kernel(img,gb_r1,gb_i1);
[gb_r2,gb_i2] = get_gabor_kernel(1/8*pi,sigma,gamma,lambda);
out_img2 = apply_gabor_kernel(img,gb_r2,gb_i2);
[gb_r3,gb_i3] = get_gabor_kernel(2/8*pi,sigma,gamma,lambda);
out_img3 = apply_gabor_kernel(img,gb_r3,gb_i3);
[gb_r4,gb_i4] = get_gabor_kernel(3/8*pi,sigma,gamma,lambda);
out_img4 = apply_gabor_kernel(img,gb_r4,gb_i4);
[gb_r5,gb_i5] = get_gabor_kernel(4/8*pi,sigma,gamma,lambda);
out_img5 = apply_gabor_kernel(img,gb_r5,gb_i5);
[gb_r6,gb_i6] = get_gabor_kernel(5/8*pi,sigma,gamma,lambda);
out_img6 = apply_gabor_kernel(img,gb_r6,gb_i6);
[gb_r7,gb_i7] = get_gabor_kernel(6/8*pi,sigma,gamma,lambda);
out_img7 = apply_gabor_kernel(img,gb_r7,gb_i7);
[gb_r8,gb_i8] = get_gabor_kernel(7/8*pi,sigma,gamma,lambda);
out_img8 = apply_gabor_kernel(img,gb_r8,gb_i8);

figure(2);
subplot(4, 4, 1);
imagesc(gb_r1);
colormap('gray');
axis equal;
title('real part of Gabor, theta=0');
subplot(4, 4, 2);
imagesc(out_img1);
colormap('gray');
axis equal;
title('result of the specific filtering');

subplot(4, 4, 3);
imagesc(gb_r2);
colormap('gray');
axis equal;
title('real part of Gabor, theta=1/8*pi');
subplot(4, 4, 4);
imagesc(out_img2);
colormap('gray');
axis equal;
title('result of the specific filtering');

subplot(4, 4, 5);
imagesc(gb_r3);
colormap('gray');
axis equal;
title('real part of Gabor, theta=2/8*pi');
subplot(4, 4, 6);
imagesc(out_img3);
colormap('gray');
axis equal;
title('result of the specific filtering');

subplot(4, 4, 7);
imagesc(gb_r4);
colormap('gray');
axis equal;
title('real part of Gabor, theta=3/8*pi');
subplot(4, 4, 8);
imagesc(out_img4);
colormap('gray');
axis equal;
title('result of the specific filtering');

subplot(4, 4, 9);
imagesc(gb_r5);
colormap('gray');
axis equal;
title('real part of Gabor, theta=4/8*pi');
subplot(4, 4, 10);
imagesc(out_img5);
colormap('gray');
axis equal;
title('result of the specific filtering');

subplot(4, 4, 11);
imagesc(gb_r6);
colormap('gray');
axis equal;
title('real part of Gabor, theta=5/8*pi');
subplot(4, 4, 12);
imagesc(out_img6);
colormap('gray');
axis equal;
title('result of the specific filtering');

subplot(4, 4, 13);
imagesc(gb_r7);
colormap('gray');
axis equal;
title('real part of Gabor, theta=6/8*pi');
subplot(4, 4, 14);
imagesc(out_img7);
colormap('gray');
axis equal;
title('result of the specific filtering');

subplot(4, 4, 15);
imagesc(gb_r8);
colormap('gray');
axis equal;
title('real part of Gabor, theta=7/8*pi');
subplot(4, 4, 16);
imagesc(out_img8);
colormap('gray');
axis equal;
title('result of the specific filtering');

img_gabor = out_img1 + out_img2 + out_img3 + out_img4 + out_img5 + out_img6 + out_img7 + out_img8;
img_gabor = img_gabor/max(img_gabor,[],'all');

figure(3);
subplot(1, 2, 1);
imshow(img);
title('noisy input');
subplot(1, 2, 2);
imshow(img_gabor);
title('Gabor-filtered, normalized');

%% Bradley corrected
FT = fft2(img_gabor);
FT = fftshift(FT);
M_FT = log(abs(FT)+1);
M_FT = normalize(M_FT,'range');
FT(160:180, 160:180) = 0 + 0i;
I = abs(ifft2(ifftshift(FT)));
I_m = imbinarize(I,0.1);
I_m(:,1:7) = 0;
I_m(:,end-7:end) = 0;
I_m_2 = imdilate(I_m,strel('disk',11,8));
img_gabor_masked = img_gabor + ~I_m_2;
bradley_thresholded = bradley(img_gabor_masked, [15 15], 10);
I_m_2erode = imerode(I_m_2,strel('disk',11,8));
bradley_eroded = bradley_thresholded + ~I_m_2erode;

figure(4);
subplot(2, 3, 1);
imshow(M_FT);
title('magnitude of FFT');
subplot(2, 3, 2);
imshow(I_m);
title('baseline mask');
subplot(2, 3, 3);
imshow(I_m_2);
title('dilated mask');
subplot(2, 3, 4);
imshow(img_gabor_masked);
title('masked version of the Gabor-filtered');
subplot(2, 3, 5);
imshow(bradley_thresholded);
title('after Bradley');
subplot(2, 3, 6);
imshow(bradley_eroded);
title('boundaries of Bradley corrected');

%% Fill the holes
bw = bradley_eroded;
filled = imfill(~bw, 'holes');
holes = filled & bw;
bigholes = bwareaopen(holes, 20);
smallholes = holes & ~bigholes;
small_holes_removed = bw & ~smallholes;

figure(5);
subplot(2, 3, 1);
imshow(bradley_eroded);
title('boundaries of Bradley corrected');
subplot(2, 3, 2);
imshow(filled);
title('filled holes');
subplot(2, 3, 3);
imshow(holes);
title('holes');
subplot(2, 3, 4);
imshow(bigholes);
title('big holes');
subplot(2, 3, 5);
imshow(smallholes);
title('small holes');
subplot(2, 3, 6);
imshow(small_holes_removed);
title('small holes removed');

%%  Minutiae
skeletonized = ~bwmorph(~small_holes_removed,'skel',Inf);
cleaned = ~skeletonized;
struct = regionprops(~skeletonized,'Area','PixelIdxList');
for i = 1:numel(struct)
    if struct(i).Area < 20
        cleaned(struct(i).PixelIdxList) = 0;
    end
end
[bx,by] = ind2sub(size(cleaned),find(bwmorph(cleaned,'branchpoints')));
[ex,ey] = ind2sub(size(cleaned),find(bwmorph(cleaned,'endpoints')));

figure(6);
subplot(1, 2, 1);
imshow(skeletonized);
title('skeletonized image');
subplot(1, 2, 2);
hold on;
imshow(cleaned);
plot(ey,ex,'ro');
plot(by,bx,'gs');
legend('end points','branch points');
hold off;
title('cleaned from small independent line segments');

