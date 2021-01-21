
imgpath='/Users/adiel/Dropbox/temp/DDS_ForGil_27112017/';
imgname='P387-Fg015-R-C01-R01-D17122012-T102200-LR445 _ColorCalData_IAA_Both_CC110304_110702_gc_rect.png';

A=imread(fullfile(imgpath,imgname));
%A=rgb2hsv(A);
fullimname = fullfile(imgpath,imgname);
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

return;

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



