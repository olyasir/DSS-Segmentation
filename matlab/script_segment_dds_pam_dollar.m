
% segment pam image
% preprocess image and segment it to single fragments

close all;
clear all;

P=config_params_pam();
P.resize_scale=2;

% segment color image
addpath('~/Dropbox/dev-libs/pdollar_toolbox/edges/');
addpath('~/Dropbox/dev-libs/pdollar_toolbox/edges/private');
addpath('~/Dropbox/dev-libs/pdollar_toolbox/edges/models');
addpath('~/Dropbox/dev-libs/pdollar_toolbox/toolbox/matlab/');
addpath('~/Dropbox/dev-libs/pdollar_toolbox/toolbox/channels/');
addpath('~/Dropbox/dev-libs/pdollar_toolbox/toolbox/images/');


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
model.opts.multiscale=1;          % for top accuracy set multiscale=1
model.opts.sharpen=2;             % for top speed set sharpen=0
model.opts.nTreesEval=4;          % for top speed set nTreesEval=1
model.opts.nThreads=4;            % max number threads for evaluation
model.opts.nms=0;                 % set to true to enable nms

%% evaluate edge detector on BSDS500 (see edgesEval.m)
if(0), edgesEval( model, 'show',1, 'name','' ); end




cd ('~/Dropbox/Projects/TAU/DeadSeatScrolls/Segmentation/matlab/');

output_dir='~/temp/pam2_dd/pam_bw/';
output_dir_edges='~/temp/DDS-PAM-Dollar';
pam_dir='~/Dropbox/Projects/TAU/DeadSeatScrolls/iiif/images/PAM/';
D=dir(pam_dir);


for n=1:999%numel(D);
    fname=D(n).name;
    fprintf('Process file %d out of %d name=%s\n',n,numel(D),fname);
    imgfullpath=fullfile(pam_dir,[fname(1:end-4),'.jpg']);
    
    %imgfullpath='PAM-4Q51/M43124-1-E.jpg';
    %imgfullpath='PAM-forgil/M42029-1-C.jpg';
    %imgfullpath='PAM-forgil1/387.jpg';
    
    [imgpath,imgname,imgext] = fileparts(imgfullpath);
    
    try 
        [Ig] = imread(imgfullpath);
        if isempty(Ig)
            continue;
        end
        [Ig]=imresize(Ig,1/P.resize_scale);
    
    %figure(1);
    %grayimage=Ig;
  %  se_background=strel('disk',10);
  %  background = imclose(grayimage,se_background);
   % subplot(1,5,2);imshow(background)
   % foreground = background-grayimage;
   % subplot(1,5,3);imshow(foreground)
   % fore_adjusted = imadjust(foreground);
   % subplot(1,5,4);imshow(fore_adjusted)
   % grayt=graythresh(fore_adjusted);
   % Imgbw=im2bw(fore_adjusted,grayt);
   % subplot(1,5,5);imshow(Imgbw)
  %  Ig=background;
    
    clear I;
    I(:,:,1)=Ig;
    I(:,:,2)=Ig;
    I(:,:,3)=Ig;
    
    
    %% detect edge and visualize results
        tic, E=edgesDetect(I,model); toc
    %figure(1); im(I); figure(2); im(1-E);
    
        imwrite(E,fullfile(output_dir_edges,[imgname,'.png']));
    catch ME
        fprintf ('Error %d\n',n);
    end
    % extract fragment
    %im_binary = E > 0.004;
    %im_binary = imfill(im_binary,'holes');
    %im_binary1=E;
    %im_binary=imclose(im_binary1,strel('disk',3));
    
    %figure(4);
    %subplot(1,3,1); imshow(Ig);
    %subplot(1,3,2); imshow(E);
    %subplot(1,3,3); imshow(im_binary);
    
    %imwrite(im_binary,fullfile(output_dir,[imgname,'_bw.png']));
    
end
return

[im_labels,last_label,bounding_rects,sorted_areas,origin_labels,im_all_labels,centroid,CCstats] = ...
    biggest_con_comps(im_binary,P.min_area_thresh);


figure; imshow(im_labels);

outfragname=imgname;
pos=strfind(imgname,'-');
if ~isempty(pos)
    outfragname = imgname(1:pos(2)-1);
end

%return;

for m=1:last_label
    fprintf('Process %d out of %d\n',m,last_label);
    %m=4; % first label
    comp_mask = (im_labels==m);
    
    
    [im_labels1,last_label1,bounding_rects1,sorted_areas1,origin_labels1,im_all_labels1,centroid1,CCstats1] = ...
        biggest_con_comps(comp_mask,P.min_area_thresh);
    
    comp_mask=im_labels1;
    comp_mask=imfill(comp_mask,'holes');
    
    cropx=bounding_rects(m,2)-P.crop_pad;
    cropy=bounding_rects(m,1)-P.crop_pad;
    cropw=bounding_rects(m,4)-bounding_rects(m,2)+2*P.crop_pad;
    croph=bounding_rects(m,3)-bounding_rects(m,1)+2*P.crop_pad;
    
    frag = Ig;
    frag = imcrop(frag,[cropx,cropy,cropw,croph]);
    
    frag_masked=Ig;
    frag_masked(comp_mask == 0) = 255;
    frag_masked = imcrop(frag_masked,[cropx,cropy,cropw,croph]);
    
    %figure(6); imshow(frag);
    
    %ROI = imcrop(Ig,[cropx,cropy,cropw,croph]);
    
    outpath = [P.PREPROCESSED_PATH,imgname];
    if ~exist(outpath)
        fprintf('create dirctory %s\n',outpath);
        mkdir(outpath);
    end
    imwrite(frag,fullfile(outpath, [imgname,'_',num2str(m),'_d_frag.png']));
    imwrite(frag_masked,fullfile(outpath,[imgname,'_',num2str(m),'_d_mask.png']));
    
    
end

save (fullfile(outpath, [imgname,'_frags.mat']),'CCstats');




%imwrite(frag,fullfile(P.FRAGMENTS_PATH,[outfragname,'_frag.png']));
%imwrite(comp_mask(:,:,1),fullfile(P.MASK_PATH,[outfragname,'_mask.png']));







