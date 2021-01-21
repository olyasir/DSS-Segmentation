% texture removal test
%https://www.mathworks.com/help/images/examples/texture-segmentation-using-texture-filters.html
addpath('~/Packages/matlab/export_fig');
imname='../tmp/493-Fg003-R-C01-R01-D31102011-T093610-LR445_ColorCal_both_110209._gc_rect.png';
imname='~/Dropbox/temp/DDS_ForGil_27112017/P382-Fg001-R-C01-R01-D30092013-T152955-LR445 _ColorCalData_IAA_Both_CC110304_110702_gc_rect.png';

dirname='/Users/adiel/Projects/TAU/DeadSeatScrolls/Segmentation/results/Fragments_gc/';
outpath='/Users/adiel/Projects/TAU/DeadSeatScrolls/Segmentation/results/Fragments_no_jp/';

D=dir(dirname);

for curimg=4:numel(D)
   
    
    imname=D(curimg).name;
    fullimname = fullfile(dirname,D(curimg).name);
    fprintf('%d outof %d %s\n',curimg,numel(D),fullimname);
    
    A = imread(fullimname);
    %A = imresize(A,0.50);
    figure(1);
    imshow(A)
    
    cform = makecform('srgb2lab');
    lab_he = applycform(A,cform);
    
    ab = double(lab_he(:,:,2:3));
    nrows = size(ab,1);
    ncols = size(ab,2);
    ab = reshape(ab,nrows*ncols,2);
    
    
    nColors = 2;
    % repeat the clustering 3 times to avoid local minima
    [cluster_idx, cluster_center] = kmeans(ab,nColors,'distance','sqEuclidean', ...
        'Replicates',3);
    
    
    pixel_labels = reshape(cluster_idx,nrows,ncols);
    figure(2);
    imshow(pixel_labels,[]), title('image labeled by cluster index');
    
    im_binary=im2bw(pixel_labels-1);
    
    P.min_area_thresh=0.001;
    [im_labels,last_label,bounding_rects,sorted_areas,origin_labels,im_all_labels,centroid,CCstats] = ...
        biggest_con_comps(im_binary,P.min_area_thresh);
    
    BW=logical(im_labels);
    if BW(1,1)>0
        BW=~BW;
    end
    
    
    se=strel('disk',30);
    BW1=imdilate(BW,se);
    BW1=imerode(BW1,se);
    figure(4); imshow(BW1);
    mask=BW1;
    
    MA=A;
    MA(:,:,1)=MA(:,:,1).*uint8(BW1);
    MA(:,:,2)=MA(:,:,2).*uint8(BW1);
    MA(:,:,3)=MA(:,:,3).*uint8(BW1);
           
    imwrite(MA,fullfile(outpath,imname),'alpha',uint8(BW1.*255));
end


