close all;
clear;
clc;

%% Creating Gamma
listing = dir('Cambridge_FaceDB_jpg');
indices = [];
for i = 1:size(listing,1)
    if listing(i).isdir == 1
        indices = [indices i];
    elseif ~strcmp(listing(i).name(end-2:end), 'jpg')
        indices = [indices i];
    end
end

while ~isempty(indices)
    listing(indices(end),:) = [];
    indices(end) = [];
end

W = 92;
H = 112;
Gamma = zeros(W*H,size(listing,1));
for idx = 1:size(listing,1)
    img = imread("Cambridge_FaceDB_jpg/"+listing(idx).name);
    if size(img, 3) == 3
        img = rgb2gray(img);
    end
    Gamma(:,idx) = reshape(img,[W*H,1]);
end

holdout = round(rand()*size(Gamma,2));
test_img = Gamma(:,holdout);
Gamma(:,holdout) = [];

%% Difference images
Psi = mean(Gamma,2);
A = Gamma - repmat(Psi,1,size(Gamma,2));

%% PCA calculation
L = transpose(A) * A;

[V, D] = eig(L, 'vector');
[D, idx] = sort(D, 'descend');
V = V(:, idx);

Uraw = A*V;
U = Uraw ./ vecnorm(Uraw);
K = 320;
%K = 50;
U = U(:,1:K);

Y = transpose(U) * A;
Phi = test_img - Psi;
y = transpose(U) * Phi;
difference = vecnorm(Y - y);
[minimum, minimum_index] = min(difference);

%% Reconstruct
Phi_rec = U * Y(:,minimum_index);
recognised_test_img = Phi_rec + Psi;

%% Plot
test_img = uint8(reshape(test_img,[H,W]));
mean_img = uint8(reshape(Psi,[H,W]));
recognised_test_img = uint8(reshape(recognised_test_img,[H,W]));

figure('Name',sprintf('K = %d',K),'NumberTitle','off');
subplot(1,3,1);
imshow(test_img);
title('test');
subplot(1,3,2);
imshow(mean_img);
title('mean face');
subplot(1,3,3);
imshow(recognised_test_img);
title(sprintf('reconstructed from the closest PCA-projection, K=%d',K));

figure('Name',sprintf('Eigenfaces for K = %d',K),'NumberTitle','off')
for i = 1:10
    subplot(2,5,i);
    imagesc(reshape(U(:,i),[H,W])); colormap gray;
end
