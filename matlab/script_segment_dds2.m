
% segment spectral image
% and PAM image

P=config_params();

filename='4Q51-P998/P998-Fg005-R-C01-R01-D14112013-T105221-LR445 _001.jpg';
%filename = 'p-593/P593-Fg001-R-C01-R01-D30122013-T142907-LR445 _ColorCalData_IAA_Left_CC110304_110702.jpg';


[im] = imread([P.IMG_PATH,filename]);
[im]=imresize(im,1/P.resize_scale);

%im_hsv=rgb2hsv(im);
%im_hsv=im_hsv*255;

thresh1 = employ_threshold(im,true,[1 0 0],10);
thresh2 = employ_threshold(im,false,[1 0 0],30);

if (P.plot_debug)
%    figure(1); imshow(im_hsv./255)
    figure(2); imshow(thresh1,[]); title('thresh 1');
    figure(3); imshow(thresh2,[]); title('thresh 2');
end

%return;
im_binary=matrix_and(thresh1,thresh2);
%im_binary=thresh1;
im_binary=clear_small_parts(im_binary);

if (P.plot_debug)
    figure(4); imshow(im_binary,[]); title('imbinary1');
end

returnl

[im_labels,last_label,bounding_rects,sorted_areas,origin_labels,im_all_labels] = biggest_con_comps(im_binary);
if (last_label >1)
    fprintf('Warning: more than one compononet exracted');
end
if (P.plot_debug)
    figure(5); imshow(im_labels,[]); title('imbinary filled holes');
end


m=1; % first label
comp_mask = (im_labels==m);
comp_mask(:,:,2) = comp_mask;
comp_mask(:,:,3) = comp_mask(:,:,1);

ROI = im;
ROI(comp_mask == 0) = 255;
% 6) Display extracted portion:
figure, imshow(ROI);


