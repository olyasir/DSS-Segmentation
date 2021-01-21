
% segment color image
close all;
clear all;

addpath('~/Packages/matlab/edge_detect_pdollar/edges/');
addpath('~/Packages/matlab/edge_detect_pdollar/private');
addpath('~/Packages/matlab/edge_detect_pdollar/models');
addpath('~/Packages/matlab/pdollar_toolbox/toolbox/matlab/');
addpath('~/Packages/matlab/pdollar_toolbox/toolbox/channels/');
addpath('~/Packages/matlab/pdollar_toolbox/toolbox/images/');



P=config_params();

% Demo for Structured Edge Detector (please see readme.txt first).

%% set opts for training (see edgesTrain.m)
opts=edgesTrain();                % default options (good settings)
opts.modelDir='models/';          % model will be in models/forest
opts.modelFnm='modelBsds';        % model name
opts.nPos=5e5; opts.nNeg=5e5;     % decrease to speedup training
opts.useParfor=0;                 % parallelize if sufficient memory

%% train edge detector (~20m/8Gb per tree, proportional to nPos/nNeg)
tic, model=edgesTrain(opts); toc; % will load model if already trained

%% set detection parameters (can set after training)
model.opts.multiscale=0;          % for top accuracy set multiscale=1
model.opts.sharpen=2;             % for top speed set sharpen=0
model.opts.nTreesEval=4;          % for top speed set nTreesEval=1
model.opts.nThreads=4;            % max number threads for evaluation
model.opts.nms=0;                 % set to true to enable nms

%% evaluate edge detector on BSDS500 (see edgesEval.m)
if(0), edgesEval( model, 'show',1, 'name','' ); end



cd ('~/Projects/TAU/DeadSeatScrolls/Segmentation/matlab/');
imgfullpath='p-589/P589-Fg001-R-C01-R01-D12022013-T110529-LR445 _ColorCalData_IAA_Both_CC110304_110702.png';
%imgfullpath='4Q51-P998/P998-Fg005-R-C01-R01-D14112013-T105221-LR445_ColorCalData_IAA_Left_CC110304_110702.png';
%filename = 'p-593/P593-Fg001-R-C01-R01-D30122013-T142907-LR445 _ColorCalData_IAA_Left_CC110304_110702.jpg';
[imgpath,imgname,imgext] = fileparts(imgfullpath);


[I] = imread([P.IMG_PATH,imgfullpath]);
[I]=imresize(I,1/P.resize_scale);


%% detect edge and visualize results
tic, E=edgesDetect(I,model); toc
figure(1); im(I); figure(2); im(1-E);

% extract fragment
im_binary1 = E > 0.1;
im_binary = imfill(im_binary1,'holes');

[im_labels,last_label,bounding_rects,sorted_areas,origin_labels,im_all_labels,centroid] = ...
                biggest_con_comps(im_binary);
if (last_label >1)
    fprintf('Warning: more than one compononet exracted');
 % choose component with centroid close to center
    [h,w]=size(I(:,:,1));
    center=[h/2,w/2];
    for k=1:last_label,
        dist(k)=pdist([centroid(k,:);center],'euclidean')
    end
    [mn,m]=min(dist);
else
    m=1; % first and only label
end
if (P.plot_debug)
    figure(5); imshow(im_labels,[]); title('imbinary filled holes');
end


comp_mask = (im_labels==m);
comp_mask(:,:,2) = comp_mask;
comp_mask(:,:,3) = comp_mask(:,:,1);

frag = I;
frag(comp_mask == 0) = 255;
% 6) Display extracted portion:
figure, imshow(frag);


pos=strfind(imgname,'-');
outfragname = imgname(1:pos(2)-1);


imwrite(frag,fullfile(P.FRAGMENTS_PATH,[outfragname,'_frag.png']));
imwrite(comp_mask(:,:,1),fullfile(P.MASK_PATH,[outfragname,'_mask.png']));



