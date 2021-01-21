
% segment pam image
close all;
clear all;

P=config_params_pam();

%filename='PAM-4Q51/M43107-1-E.jpg';
imgfullpath='PAM-4Q51/M43124-1-E.jpg';
%imgfullpath='PAM-4Q418/M43474-1-E.jpg';

%filename = 'p-593/P593-Fg001-R-C01-R01-D30122013-T142907-LR445 _ColorCalData_IAA_Left_CC110304_110702.jpg';
if ~exist('im','var')
    [im] = imread([P.IMG_PATH,imgfullpath]);
   [im]=imresize(im,1/P.resize_scale);
    [imgpath,imgname,imgext] = fileparts(imgfullpath);

end


%[pixelCount grayLevels] = imhist(im);

%BW=im2bw(im);

figure(10); imshow(im);

edge1 = edge(im,'Sobel');
figure(1); imshow(edge1); title('Sobel');

edge2 = edge(im,'Canny');
figure(2); imshow(edge2); title('Canny');

edge3 = edge(im,'log');
figure(3); imshow(edge3); title('log');


im_edge = matrix_or(edge1,edge2);
im_edge = matrix_or(im_edge,edge3);

figure(3); imshow(im_edge); title('Final Edge');


im_binary1=im_edge;
im_binary=imclose(im_binary1,strel('disk',3));
figure(4); imshow(im_binary);

[im_labels,last_label,bounding_rects,sorted_areas,origin_labels,im_all_labels] = ...
                biggest_con_comps(im_binary,P.min_area_thresh);
if (last_label >1)
    fprintf('Warning: more than one compononet exracted');
end
if (P.plot_debug)
    figure(5); imshow(im_labels,[]); title('imbinary filled holes');
end


%return;

for m=4:last_label
%m=4; % first label
comp_mask = (im_labels==m);

cropx=bounding_rects(m,2);
cropy=bounding_rects(m,1);
cropw=bounding_rects(m,4)-bounding_rects(m,2);
croph=bounding_rects(m,3)-bounding_rects(m,1);

frag = im;
frag(comp_mask == 0) = 255;
frag = imcrop(frag,[cropx,cropy,cropw,croph]);
%figure(6); imshow(frag);

ROI = imcrop(im,[cropx,cropy,cropw,croph]);

imwrite(frag,fullfile(P.FRAGMENTS_PATH,[imgname,'_',num2str(m),'_frag.png']));
imwrite(comp_mask,fullfile(P.MASK_PATH,[imgname,'_',num2str(m),'_mask.png']));


end