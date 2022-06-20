%% Exercise 1
close all
clear
clc

I = imread('AlfredoBorba_TuscanLandscape.jpg');
I_rs = imresize(I, 0.1);
fprintf('Size of the image: %d x %d x %d \n', size(I_rs,1), size(I_rs,2), size(I_rs,3));
fprintf('Type of data in the image matrix: uint8: %d, double: %d \n', isa(I_rs,'uint8'), isa(I_rs,'double'));
fprintf('Extrema: min=%d, max=%d \n', min(I_rs, [], 'all'), max(I_rs, [], 'all'));
disp('###');

I_rs_gray = rgb2gray(I_rs);
fprintf('Size of the image: %d x %d x %d \n', size(I_rs_gray,1), size(I_rs_gray,2), size(I_rs_gray,3));
fprintf('Type of data in the image matrix: uint8: %d, double: %d \n', isa(I_rs_gray,'uint8'), isa(I_rs_gray,'double'));
fprintf('Extrema: min=%d, max=%d \n', min(I_rs_gray, [], 'all'), max(I_rs_gray, [], 'all'));
disp('###');

I_rs_double = im2double(I_rs);
fprintf('Size of the image: %d x %d x %d \n', size(I_rs_double,1), size(I_rs_double,2), size(I_rs_double,3));
fprintf('Type of data in the image matrix: uint8: %d, double: %d \n', isa(I_rs_double,'uint8'), isa(I_rs_double,'double'));
fprintf('Extrema: min=%d, max=%f \n', min(I_rs_double, [], 'all'), max(I_rs_double, [], 'all'));
disp('###');

figure('Name','Exercise 1','NumberTitle','off');
subplot(2,3,1);
imshow(I_rs);
hold on;
line([28 48],[26 26],'Color','red','LineWidth',2);
title('original, color');
hold off;

subplot(2,3,2);
imshow(I_rs_gray);
hold on;
line([28 48],[26 26],'Color','red','LineWidth',2);
title('gray with rgb2gray');
hold off;

subplot(2,3,3);
imshow(I_rs_double);
hold on;
line([28 48],[26 26],'Color','red','LineWidth',2);
title('color with im2double');
hold off;

subplot(2,3,4);
hold on;
plot(I_rs(26,28:48,1), '-r');
plot(I_rs(26,28:48,2), '-g');
plot(I_rs(26,28:48,3), '-b');
xlim([1 21]);
ylim([0 250]);
yticks(0:50:250)
title('pixel channel/intensity values in the 26th row');
hold off;

subplot(2,3,5);
plot(I_rs_gray(26,28:48), '-b');
xlim([1 21]);
ylim([60 200]);
yticks(60:20:200)
title('pixel intensity values in the 26th row');

subplot(2,3,6);
hold on;
plot(I_rs_double(26,28:48,1), '-r');
plot(I_rs_double(26,28:48,2), '-g');
plot(I_rs_double(26,28:48,3), '-b');
xlim([1 21]);
ylim([0 1]);
yticks(0:0.2:1)
title('pixel channel/intensity values in the 26th row');
hold off;
