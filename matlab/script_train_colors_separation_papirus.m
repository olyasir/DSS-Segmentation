% script_train_colors_separation
%apply_paths;
P=config_params();
images_path = P.IMG_PATH;
filenames{1} = 'p-589/P589-Fg001-R-C01-R01-D12022013-T110529-LR445 _ColorCalData_IAA_Both_CC110304_110702.png';

RESELECT_COLORS = true;
%collect paper colors
if RESELECT_COLORS
    fragment_colors = collect_colors(images_path,filenames);
    background_colors = collect_colors(images_path,filenames);
 %   white_paper_colors = collect_colors(images_path,filenames);
 %   ruler_colors = collect_colors(images_path,filenames);
    save colors.mat fragment_colors background_colors 
else
    load colors.mat
end
vectors = [fragment_colors ; background_colors];%; ruler_colors];
% vectors = [fragment_colors; white_paper_colors];
labels = [1*ones(size(fragment_colors,1),1) ; 2*ones(size(background_colors,1),1)];%;
%     4*ones(size(ruler_colors,1),1)];
% labels = [1*ones(size(fragment_colors,1),1) ; 2*ones(size(white_paper_colors,1),1)];

%perm = randperm(size(vectors,1));
%n_samples = round(0.01 * length(perm));
%vectors = vectors(perm(1:n_samples),:);
%vectors = vectors(:,[1 2 3]);
vectors = double(vectors);
%labels = labels(perm(1:n_samples));

svm_struct=svmtrain(vectors,labels);

%C = 1;
%cmd = ['-s 0 -t 0 -c ' num2str( 1 )];
%% [success_mean, success_std] = calc_svm_with_scaling(vectors, labels, C, 'Linear', 0, 0.8) % last: test percent
%svm_struct = svmtrain(labels,vectors, cmd);

% test
return;
im_hsv=rgb2hsv(im);
im_binary = segment_by_rgb_trained_dss(im_hsv,svm_struct);

return;
im = imread([images_path,'I.A.34_L2F0B0S2.jpg']);
% im_colors = reshape(im, [size(im,1)*size(im,2),3]);
% im_colors = double(im_colors);
% classes = svmpredict(ones(size(im_colors),1), im_colors, svm_struct);
% im_binary = reshape(classes,[size(im,1),size(im,2)]);
[theta,rho] = svm_struct_2_theta_rho(svm_struct);
im_binary = segment_by_rgb_trained(im,theta,rho);
figure(1);imshow(im);
figure(2);imshow(im_binary==1);
