load('mask.mat');
files = dir('CelebrityDatabase/*.jpg');
data_matrix = [];
unmasked_pixels = find(mask);
for i = 1:length(files)
    im = imread(strcat('CelebrityDatabase/',files(i).name));
    im_vector = im(unmasked_pixels);
    data_matrix = [data_matrix; im_vector'];
end

data_matrix = double(data_matrix);
norm_matrix = bsxfun(@minus, data_matrix, mean(data_matrix));

[U,S,V] = svd(norm_matrix', 'econ');
[D order] = sort(diag(S),'descend');  %# sort eigenvalues in descending order
U = U(:,order);

full_im = zeros(size(mask));
for i=1:10
    pos_vector = U(:,i) - min(U(:,i));
    im_vector = pos_vector/range(pos_vector);
    full_im(unmasked_pixels) = im_vector;
    imwrite(full_im, strcat(num2str(i), '.jpg'), 'jpg');
end

im = imread('CelebrityDatabase/Cuba GoodingJR.jpg');
im_vector = double(im(unmasked_pixels)) - mean(data_matrix)';
approx_vector = zeros(size(data_matrix, 2), 1);
for i=1:10
    w = dot(im_vector, U(:, i) ./ norm(U(:, i)));
    approx_vector = approx_vector + w * U(:, i);
end

im_vector = approx_vector + mean(data_matrix)';
full_im(unmasked_pixels) = im_vector;
imshow(uint8(full_im));
