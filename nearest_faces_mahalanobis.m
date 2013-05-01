load('mask.mat');
celebs = dir('CelebrityDatabase/*.jpg');
stds = dir('StudentDatabase/*.jpg');

data_matrix = [];
unmasked_pixels = find(mask);
for i = 1:length(celebs)
    im = imread(strcat('CelebrityDatabase/',celebs(i).name));
    im_vector = im(unmasked_pixels);
    data_matrix = [data_matrix; im_vector'];
end

data_matrix = double(data_matrix);
norm_matrix = bsxfun(@minus, data_matrix, mean(data_matrix));

[U,S,V] = svd(norm_matrix', 'econ');
[D order] = sort(diag(S),'descend');  %# sort eigenvalues in descending order
U = U(:,order);

small_celebs = [];
for j =1:length(celebs)
    im_clb = imread(strcat('CelebrityDatabase/',celebs(j).name));
    im_clb_vector = double(im_clb(unmasked_pixels));
    one_celeb = [];
    for i=1:10
        w = dot(im_clb_vector, U(:, i) ./ norm(U(:, i)));
        one_celeb = [one_celeb w];
    end
    small_celebs = [small_celebs; one_celeb];
end

cov_small_celebs = cov(small_celebs);
unmasked_pixels = find(mask);
faces = '';
for i=1:length(stds)
    im_std = imread(strcat('StudentDatabase/',stds(i).name));
    im_std_vector = double(im_std(unmasked_pixels));
    distances = [];
    student_small = [];
    for k=1:10
        w = dot(im_std_vector, U(:, k) ./ norm(U(:, k)));
        student_small = [student_small w];
    end

    for j =1:length(celebs)
        im_clb_vector = small_celebs(j,:);
        xy = student_small - im_clb_vector;
        dist = sqrt(xy / cov_small_celebs * xy');
        distances = [distances dist];
    end
    [D order] = sort(distances,'ascend');
    ordered_celebs = celebs(order);
    names = sprintf('%s_%s_%s', stds(i).name, ordered_celebs(1).name, ordered_celebs(2).name);
    faces = sprintf('%s\n%s', faces, names);
end
