function [gb_r,gb_i] = get_gabor_kernel(theta,sigma,gamma,lambda)
    x = -20:20;
    [X,Y] = meshgrid(x);
    X_th = X.*cos(theta) + Y.*sin(theta);
    Y_th = -X.*sin(theta) + Y.*cos(theta);
    gb_r = exp(-(X_th.^2 + gamma^2 .* Y_th.^2)./(2*sigma^2)) .* cos(2*pi.*X_th/lambda);
    gb_i = exp(-(X_th.^2 + gamma^2 .* Y_th.^2)./(2*sigma^2)) .* sin(2*pi.*X_th/lambda);
end

