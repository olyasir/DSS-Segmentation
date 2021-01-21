
% segment color papirus image by trained svm
close all;
clear all;

P=config_params();

%imgfullpath='p-589/P589-Fg001-R-C01-R01-D12022013-T110529-LR445 _ColorCalData_IAA_Both_CC110304_110702.png';
%imgfullpath='p-589/P589-Fg001-R.jpg';
%imgfullpath='p-589/P589-Fg001-V.jpg';

%imgfullpath='4Q51-P998/P998-Fg005-R-C01-R01-D14112013-T105221-LR445_ColorCalData_IAA_Left_CC110304_110702.png';
%filename = 'p-593/P593-Fg001-R-C01-R01-D30122013-T142907-LR445 _ColorCalData_IAA_Left_CC110304_110702.jpg';

[imgpath,imgname,imgext] = fileparts(imgfullpath);


[im] = imread([P.IMG_PATH,imgfullpath]);
[im]=imresize(im,1/P.resize_scale);

im_hsv=rgb2hsv(im);

if (P.plot_debug)
%    figure(1); imshow(im_hsv./255)
%    figure(2); imshow(thresh1,[]); title('thresh 1');
%    figure(3); imshow(thresh2,[]); title('thresh 2');
end

%return;
%im_binary=matrix_or(thresh1,thresh2);
%im_binary=thresh1;
%im_binary=clear_small_parts(im_binary);

% this loads svm_struct 
load('svm_struct_papirus.mat');
im_binary = segment_by_rgb_trained_dss(im_hsv,svm_struct);


if (P.plot_debug)
   figure(1); imshow(im_binary)
%    figure(2); imshow(thresh1,[]); title('thresh 1');
%    figure(3); imshow(thresh2,[]); title('thresh 2');
end

[im_labels,last_label,bounding_rects,sorted_areas,origin_labels,im_all_labels,centroid] =...
                biggest_con_comps(im_binary, 0.003,1,0);
if (last_label >1)
    fprintf('Warning: more than one compononet exracted');
 % choose component with centroid close to center
    [h,w]=size(im(:,:,1));
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

%m=2; % first label
comp_mask = (im_labels==m);
comp_mask(:,:,2) = comp_mask;
comp_mask(:,:,3) = comp_mask(:,:,1);


cropx=bounding_rects(m,2);
cropy=bounding_rects(m,1);
cropw=bounding_rects(m,4)-bounding_rects(m,2);
croph=bounding_rects(m,3)-bounding_rects(m,1);





% read aligned mask from verso and recto 
if (0)
    aligned_mask_rv=imread(fullfile(P.MASK_PATH,[imgname,'_mask_av.png']));
    aligned_mask_rv(:,:,2) = aligned_mask_rv;
    aligned_mask_rv(:,:,3) = aligned_mask_rv(:,:,1);
    frag = imcrop(im,[cropx,cropy,cropw,croph]);

    frag(aligned_mask_rv == 0) = 255;
    imwrite(frag,fullfile(P.FRAGMENTS_PATH,[imgname,'_frag_av.png']));
return;
end
frag = im;
frag(comp_mask == 0) = 255;
frag = imcrop(frag,[cropx,cropy,cropw,croph]);
mask= imcrop(comp_mask(:,:,1),[cropx,cropy,cropw,croph]);
% 6) Display extracted portion:
figure, imshow(frag);

%pos=strfind(imgname,'.');
%outfragname = imgname(1:pos(2)-1);
outfragname=imgname;

imwrite(frag,fullfile(P.FRAGMENTS_PATH,[outfragname,'_frag.png']));
imwrite(mask,fullfile(P.MASK_PATH,[outfragname,'_mask.png']));



