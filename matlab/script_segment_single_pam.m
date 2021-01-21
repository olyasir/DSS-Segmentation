
imgfullpath = '../../Haifa/ManualSegmentation/im1c.png';
[imgpath,imgname,imgext] = fileparts(imgfullpath);

im = imread(fullfile(imgpath,[imgname,imgext]));

im=imrotate(im,5);

%im = imread('../../Haifa/ManualSegmentation/im1a.png';
if size(im,3) > 1
    im= im(:,:,1);
end
im_binary = im ~=255;
[im_labels,last_label,bounding_rects,sorted_areas,origin_labels,im_all_labels,centroid] = ...
                biggest_con_comps(im_binary);  
            m=1;
cropx=bounding_rects(m,2);
cropy=bounding_rects(m,1);
cropw=bounding_rects(m,4)-bounding_rects(m,2);
croph=bounding_rects(m,3)-bounding_rects(m,1);


frag = im;
comp_mask = (im_labels==m);
frag(comp_mask == 0) = 255;
frag = imcrop(frag,[cropx,cropy,cropw,croph]);
mask= imcrop(comp_mask(:,:,1),[cropx,cropy,cropw,croph]);
% 6) Display extracted portion:
figure, imshow(frag);


%pos=strfind(imgname,'.');
%outfragname = imgname(1:pos(2)-1);
outfragname=imgname;

%imwrite(frag,fullfile(P.FRAGMENTS_PATH,[outfragname,'_frag.png']));
imwrite(frag,fullfile(imgpath,[outfragname,'_croped.png']));



