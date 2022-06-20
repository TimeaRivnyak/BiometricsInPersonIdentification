% iris segmentation, iris code, matching with Hamming distance
% initial file
% 2021. 11. 19.
% on the basis of Libor Masek's thesis: 
% https://www.peterkovesi.com/studentprojects/libor/index.html
% images: selected from the CASIA db, Chinese Academy of Sciences
% http://www.cbsr.ia.ac.cn/english/IrisDatabase.asp

close all;
clear;
clc;

filenames = {'./input/S1007R05.jpg', './input/S1007R07.jpg', ...
    './input/S1008L02.jpg', './input/S1008L10.jpg', ...
    './input/S1011L02.jpg', './input/S1011L09.jpg'};

I_templates = cell(0);
I_noise_mask = cell(0);

for idx = 1:length(filenames)
    iris = im2double(imread(filenames{idx}));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % STEP 1: calculate edge-images to circular Hough + linear Hough:
    iris_edges_all = edge(imgaussfilt(iris,9), 'Canny');
    iris_horizontal_edges = edge(iris, 'Prewitt');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % STEP 2: circular and linear Hough transforms to detect boundaries:
    % pupil-iris and iris-sclera boundaries
    [centers_pupil, radii_pupil] = imfindcircles(iris_edges_all, [30, 70], 'Method', 'TwoStage', 'Sensitivity', 0.95);
    [centers_iris_outer, radii_iris_outer] = imfindcircles(iris_edges_all, [70, 125], 'Method', 'PhaseCode', 'Sensitivity', 0.98);
    c_1 = centers_pupil(1,:);
    r_1 = radii_pupil(1);
    c_2 = centers_iris_outer(1,:);
    r_2 = radii_iris_outer(1);
    
    % lower eyelid
    lower_part = round(3*size(iris, 1)/4);
    bottom_quarter = iris_horizontal_edges(lower_part+1:end, :);
    [H_bottom, theta_bottom, rho_bottom] = hough(bottom_quarter, 'Theta', [-90:-85, 85:89]);
    peaks_bottom = houghpeaks(H_bottom, 5, 'Theta', theta_bottom);
    H_lines_bottom = houghlines(bottom_quarter, theta_bottom, rho_bottom, peaks_bottom);
    H_bottom_row_coords = [];
    for k = 1:size(H_lines_bottom,2)
        H_bottom_row_coords = [H_bottom_row_coords, H_lines_bottom(k).point1(2), H_lines_bottom(k).point2(2)];
    end
    highest_row_to_remove = min(H_bottom_row_coords) + lower_part;
    
    % upper eyelid
    top_quarter = iris_horizontal_edges(1:round(size(iris, 1)/4), :);
    [H_top, theta_top, rho_top] = hough(top_quarter, 'Theta', [-90:-85, 85:89]);
    peaks_top = houghpeaks(H_top, 5, 'Theta', theta_top);
    H_lines_top = houghlines(top_quarter, theta_top, rho_top, peaks_top);
    H_top_row_coords = [];
    for k = 1:size(H_lines_top,2)
        H_top_row_coords = [H_top_row_coords, H_lines_top(k).point1(2), H_lines_top(k).point2(2)];
    end
    lowest_row_to_remove = max(H_top_row_coords);
    
    % mask iris image
    masked_iris = iris;
    masked_iris(1:lowest_row_to_remove, :) = NaN;
    masked_iris(highest_row_to_remove:end, :) = NaN;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % STEP 3: normalisation step
    % on the basis of Daugman's rubber sheet model
    % theta and radius values
    r_div = 30;
    th_div = 180;
    thetas = 0:2*pi/th_div:2*pi;
    thetas(end) = [];
    radii = 0:1/(r_div-1):1;
    
    % centers’ displacement and other parts of the formula
    ox = c_1(1) - c_2(1);
    oy = c_1(2) - c_2(2);
    alphas = repmat(ox^2 + oy^2, 1, th_div);
    phi = atan2(oy, ox);
    betas = cos(pi - phi - thetas);
    r = sqrt(alphas) .* betas + sqrt(alphas.*betas.^2 - (alphas - r_2^2));
    
    % r_matrix (distances of the sampling points from c_1)
    r = r - r_1;
    r_matrix = repmat(r, r_div, 1);
    r_mati = transpose(repmat(radii, th_div, 1));
    r_matrix = r_matrix .* r_mati;
    r_matrix = r_matrix + r_1;
    
    % cartesian locations
    x_cos_matrix = repmat(cos(thetas), r_div, 1);
    x_sin_matrix = repmat(sin(thetas), r_div, 1);
    x0 = r_matrix .* x_cos_matrix + c_1(1);
    y0 = r_matrix .* x_sin_matrix + c_1(2);
    
    % intensity values into polar representation
    [x_, y_] = meshgrid(1:size(iris, 2), 1:size(iris, 1));
    polar_array = interp2(x_, y_, double(masked_iris), x0, y0);
    
    % overwrite the NaNs, create a noise mask
    nan_coords = find(isnan(polar_array));
    val_coords = find(~isnan(polar_array));
    polar_array(nan_coords) = mean(polar_array(val_coords),'all');
    noise_mask = zeros(size(polar_array));
    noise_mask(nan_coords) = 1;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % STEP 4: visualize:
    figure(1);
    subplot(length(filenames), 6, (idx-1)*6+1);
    imshow(iris);
    
    %%{
    % please uncomment if you are ready with STEP 1
    subplot(length(filenames), 6, (idx-1)*6+2);
    imshow(iris_edges_all); % result of canny
    subplot(length(filenames), 6, (idx-1)*6+3);
    imshow(iris_horizontal_edges);
    %%}
    
    %%{
    % please uncomment if you are ready with STEP 2 / circular Hough
    subplot(length(filenames), 6, (idx-1)*6+4);
    imshow(iris);
    hold on;
    viscircles(c_1(1, :), r_1(1));
    viscircles(c_2(1, :), r_2(1));
    %%}
    %%{
    % please uncomment if you are ready with STEP 2 / linear Hough
    for k = 1:length(H_lines_bottom)
        plot([H_lines_bottom(k).point1(1), H_lines_bottom(k).point2(1)], ...
            [H_lines_bottom(k).point1(2), H_lines_bottom(k).point2(2)]+lower_part, 'g');
    end
    for k = 1:length(H_lines_top)
        plot([H_lines_top(k).point1(1), H_lines_top(k).point2(1)], ...
            [H_lines_top(k).point1(2), H_lines_top(k).point2(2)], 'b');
    end
    %%}
    
    %%{
    % please uncomment if you are ready with STEP 3
    subplot(length(filenames), 6, (idx-1)*6+5);
    imshow(polar_array);
    subplot(length(filenames), 6, idx*6);
    imshow(noise_mask);
    %%}
    
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % STEP 5: calculate an iris-code - log Gabor
    % initialization
    nrows = size(polar_array, 1);
    ndata = size(polar_array, 2);
    if mod(ndata, 2) == 1
        ndata = ndata-1; % to have even number of sample points
    end
    filter_values = zeros(1, ndata);
    filtered_img = zeros(nrows, ndata);
    wavelength = 18;
    sigma_on_f = 0.5;
    f0 = 1/wavelength;
    
    % filter coeff
    frequency_scale = [0:ndata/2]/ndata;
    frequency_scale(1) = 1;
    filter_values(1:ndata/2+1) = exp((-(log(frequency_scale/f0)).^2) / (2*log(sigma_on_f)^2));
    filter_values(1) = 0;
    
    % filtered signal
    for r = 1:nrows
        signal = polar_array(r, 1:ndata);
        FT = fft(signal);
        filtered_img(r, :) = ifft(FT .* filter_values);
    end
    
    % iris template
    template_length = size(polar_array, 2)*2;
    iris_template = zeros(nrows, template_length);
    iris_template_noise_mask = zeros(size(iris_template));
    H1 = real(filtered_img) > 0;
    H2 = imag(filtered_img) > 0;
    H3 = abs(filtered_img) < 10^-4;
    for ind = 1:ndata
        iris_template(:, 2*ind-1) = H1(:, ind);
        iris_template(:, 2*ind) = H2(:, ind);
        iris_template_noise_mask(:, 2*ind-1) = noise_mask(:, ind) | H3(:, ind);
        iris_template_noise_mask(:, 2*ind) = noise_mask(:, ind) | H3(ind);
    end
    
    % visualize and save template and noise mask
    figure(2);
    subplot(length(filenames), 2, (idx-1)*2+1);
    imshow(iris_template);
    subplot(length(filenames), 2, idx*2);
    imshow(iris_template_noise_mask);
    
    I_templates{idx} = iris_template;
    I_noise_mask{idx} = iris_template_noise_mask;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STEP 6: matching with Hamming distance
HD_matrix = zeros(length(I_templates), length(I_templates));
colors = {'r', 'g', 'b', 'm', 'y', 'c', 'k'};
for idx1 = 1:length(I_templates)
    figure('Name', strcat('idx1=', num2str(idx1)));
    hold on;
    for idx2 = 1:length(I_templates)
        temp1 = logical(I_templates{idx1});
        temp2 = logical(I_templates{idx2});
        mask1 = logical(I_noise_mask{idx1});
        mask2 = logical(I_noise_mask{idx2});
        shifts = -8:8;
        HDs = zeros(1, length(shifts));
        for sh_idx = 1:length(shifts)
            temp1_shifted = circshift(temp1, shifts(sh_idx)*2, 2);
            mask1_shifted = circshift(mask1, shifts(sh_idx)*2, 2);
            maskU = mask1_shifted | mask2;
            C = xor(temp1_shifted, temp2);
            C = C & ~maskU;
            HDs(sh_idx) = sum(C(:)) / (numel(temp1)-sum(maskU(:)));
        end
        HD_matrix(idx1, idx2) = min(HDs);
        plot(HDs, 'Color', colors{idx2});
    end
end

HD_matrix
