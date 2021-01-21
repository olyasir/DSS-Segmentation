

% and PAM image


clear all; close all;

P=config_params();
pam_dir='~/Dropbox/Projects/TAU/DeadSeatScrolls/iiif/images/PAM/';

%pam='M43572-1-E';
pam='M43664-1-E';
pam_plate=[pam,'.jpg'];


[im_pam] = imread(fullfile(pam_dir,pam_plate));
[im_pam]=imresize(im_pam,1/P.resize_scale);

im_binary = im2bw(im_pam, 195/255);
im_binary = ~im_binary;

if (P.plot_debug)
    figure(1);
    imshow(im_pam);
    figure(2); 
    imshow(im_binary); title('imbinary');
end

return;
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


