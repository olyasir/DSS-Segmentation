% script_binarize_dollar.m

%PAM direcotry
clear all; close all;
pam_dir='~/Dropbox/Projects/TAU/DeadSeatScrolls/iiif/images/PAM/';
edge_dir='~/temp/DDS-PAM-Dollar/';

%pam='M43572-1-E';
pam='M43664-1-E';
pam_plate=[pam,'.jpg'];
pam_edge=[pam,'.png'];

im_edges=imread(fullfile(edge_dir,pam_edge));
im_binary = im2bw(im_edges, 20/255);
%im_binary1=E;
%im_binary=imclose(im_binary,strel('disk',3));
figure(1); imshow(im_binary);
 
border_size_px=fix(0.1*size(im_binary,2));

im_binary(1:border_size_px,:)=0;
im_binary(end-border_size_px-1:end,:)=0;
im_binary(:,1:border_size_px)=0;
im_binary(:,end-border_size_px-1:end)=0;
figure(2); imshow(im_binary);

im_binary = imfill(im_binary,'holes');
im_binary=imclose(im_binary,strel('disk',20));
figure(3); imshow(im_binary);


P=config_params_pam();
P.resize_scale=2;


[im_labels,last_label,bounding_rects,sorted_areas,origin_labels,im_all_labels,centroid,CCstats] = ...
    biggest_con_comps(im_binary,P.min_area_thresh);


figure(4); imshow(im_labels,[]);
