
% segment color image
close all;
clear all;

P=config_params();

%imgfullpath='4Q51-P998/P998-Fg005-R-C01-R01-D14112013-T105221-LR445 _001.jpg';
%imgfullpath='4Q51-P998/P998-Fg005-R-C01-R01-D14112013-T105519-RRIR _028.jpg';
imgfullpath='4Q51-P998/P998-Fg005-R-C01-R01-D14112013-T105359-ML595 _017.jpg';



[imgpath,imgname,imgext] = fileparts(imgfullpath);


[im] = imread([P.IMG_PATH,imgfullpath]);
[im]=imresize(im,1/P.resize_scale);


% load mask

pos=strfind(imgname,'-');
maskname = imgname(1:pos(2)-1);

comp_mask = imread(fullfile(P.MASK_PATH,[maskname,'_mask.png']));


frag = im;
frag(comp_mask == 0) = 255;
% 6) Display extracted portion:
figure, imshow(frag);

imwrite(frag,fullfile(P.FRAGMENTS_PATH,[imgname,'_frag.png']));
imwrite(comp_mask(:,:,1),fullfile(P.MASK_PATH,[imgname,'_mask.png']));



