%% Exercise 2
close all
clear
clc

I = imread('bird.png');
I_gray = rgb2gray(I);
H = zeros(1, 256);
for intensity = 0:255
    mask = I_gray==intensity;
    H(intensity+1) = sum(mask(:));
end

min_value = min(I_gray(:));
max_value = max(I_gray(:));
diff = double(max_value - min_value);
I_stretched = zeros(size(I_gray,1), size(I_gray,2), 'uint8');
for x = 1:size(I_gray, 1)
    for y = 1:size(I_gray, 2)
        I_stretched(x, y) = round((255 / diff) * (I_gray(x, y) - min_value));
    end
end

H_stretched = zeros(1, 256);
for intensity = 0:255
    mask = I_stretched==intensity;
    H_stretched(intensity+1) = sum(mask(:));
end

figure('Name','Exercise 2','NumberTitle','off');
subplot(2,2,1);
imshow(I_gray);
title('original grayscale image');

subplot(2,2,2);
imshow(I_stretched);
title('stretched image');

subplot(2,2,3);
bar(H);
title('histogram of the original image');
xlim([0 255]);
xticks(0:50:255);

subplot(2,2,4);
bar(H_stretched);
title('stretched histogram');
xlim([0 255]);
xticks(0:50:255);