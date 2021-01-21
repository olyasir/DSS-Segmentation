close all;
clear all;

P=config_params_pam();


% segment color image
addpath('~/Packages/matlab/edge_detect_pdollar/edges/');
addpath('~/Packages/matlab/edge_detect_pdollar/private');
addpath('~/Packages/matlab/edge_detect_pdollar/models');
addpath('~/Packages/matlab/pdollar_toolbox/toolbox/matlab/');
addpath('~/Packages/matlab/pdollar_toolbox/toolbox/channels/');
addpath('~/Packages/matlab/pdollar_toolbox/toolbox/images/');


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



imgfullpath = '~/Projects/TAU/DeadSeatScrolls/Segmentation/results/PAM/fragments/M43124-1-E_4_d_frag.png';
[imgpath,imgname,imgext] = fileparts(imgfullpath);


[Ig] = imread([imgfullpath]);
%[Ig]=imresize(Ig,1/P.resize_scale);
I(:,:,1)=Ig;
I(:,:,2)=Ig;
I(:,:,3)=Ig;

 detectFASTFeatures(I,'MinContrast',0.1);

%% detect edge and visualize results
tic, E=edgesDetect(I,model); toc
figure(1); im(I); figure(2); im(1-E);


% extract fragment
im_binary = E > 0.01;
%im_binary = imfill(im_binary1,'holes');
%im_binary1=E;
%im_binary=imclose(im_binary1,strel('disk',3));
figure(4); imshow(im_binary);
scr


detector = vision.ForegroundDetector