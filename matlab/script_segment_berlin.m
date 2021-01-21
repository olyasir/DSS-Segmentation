
% segment color image
close all;
clear all;

P=config_params();

%imgpath='/Users/adiel/Projects/TAU/DeadSeatScrolls/images/Berlin/';
imgpath='/Users/adiel/Dropbox/Projects/TAU/DeadSeatScrolls/images/Berlin/';
imgname='_MG_0738.jpg'
imgfullpath=fullfile(imgpath,imgname);

outpath='/Users/adiel/Dropbox/Projects/TAU/DeadSeatScrolls/Segmentation/results/berlin';

[imgpath,imgname,imgext] = fileparts(imgfullpath);


[im] = imread(imgfullpath);
%[im]=imresize(im,1/P.resize_scale);

im_hsv=rgb2hsv(im);
im_hsv=im_hsv*255;

thresh1 = employ_threshold(im_hsv,true,[0 1 0],30);
thresh2 = employ_threshold(im_hsv,true,[0 0 1],60); 

if (P.plot_debug)
    figure(1); imshow(im_hsv./255)
    figure(2); imshow(thresh1,[]); title('thresh 1');
    figure(3); imshow(thresh2,[]); title('thresh 2');
end


%im_binary=matrix_or(thresh1,thresh2);
im_binary=thresh1;
%im_binary=clear_small_parts(im_binary);

imwrite(im_binary,fullfile(outpath,'components.png'));



if (P.plot_debug)
    figure(4); imshow(im_binary,[]); title('imbinary1');
end

[im_labels,last_label,bounding_rects,sorted_areas,origin_labels,im_all_labels] = biggest_con_comps(im_binary);
if (last_label >1)
    fprintf('Warning: more than one compononet exracted');
end
if (P.plot_debug)
    figure(5); imshow(im_labels,[]); title('imbinary filled holes');
end




return;
m=1; % first label
comp_mask = (im_labels==m);
comp_mask(:,:,2) = comp_mask;
comp_mask(:,:,3) = comp_mask(:,:,1);

frag = im;
frag(comp_mask == 0) = 255;
% 6) Display extracted portion:
figure, imshow(frag);


pos=strfind(imgname,'-');
outfragname = imgname(1:pos(2)-1);

imwrite(frag,fullfile(P.FRAGMENTS_PATH,[outfragname,'_frag.png']));
imwrite(comp_mask(:,:,1),fullfile(P.MASK_PATH,[outfragname,'_mask.png']));



