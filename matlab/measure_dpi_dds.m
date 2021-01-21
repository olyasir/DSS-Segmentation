function [dpi score] = measure_dpi_dds(im_ruler)
dpi=0; score=0; 
im_gray = imadjust(rgb2gray(im_ruler));
 im_bw = im2bw(im_gray);
im_tstrip =imcrop(im_gray,[0,0,size(im_ruler,2),35]);
im_t_strip_bw = im2bw(im_tstrip,50/255);
im_t_strip_bw = ~im_t_strip_bw;

figure(4); imshow(im_t_strip_bw);

s = strel('rectangle',[4,250]);
im_open = imopen(im_t_strip_bw,s);
 figure(5); imshow(im_open)
 
 stats = regionprops(im_open,'BoundingBox');
 
 pxinch=0;
 for k=1:numel(stats)
     pxinch(k)=stats(k).BoundingBox(3);
 end
 dpi = mean(pxinch);
 
 return;
 % im_open = imopen(1.-im_bw,ones(5,110));
 im_open = imopen(1.-im_bw,ones(5,50));
L = bwlabel(im_open);
stats = regionprops(L,'BoundingBox');
lines_length = 0;
max_length = 0;
for i=1:size(stats,1)
    lines_length(i) = stats(i,1).BoundingBox(3);
    if lines_length(i) > max_length
        max_length = lines_length(i);
        max_index = i;
    end
end
idx_cm = find(lines_length<max_length);
mean_cm = mean(lines_length(idx_cm));
if (max_length/mean_cm > 2.7 || max_length/mean_cm < 2.4)
    dpi = 0;
    score = 0;
else
    dpi = mean([max_length, lines_length(idx_cm)*2.54]);%/resize_factor;
    score = std([max_length, lines_length(idx_cm)*2.54]);
end