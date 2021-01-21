function output_im_binary = clear_small_parts(im_binary,size_parts_to_clear)
if nargin<2
    size_parts_to_clear = 3;
end
if size_parts_to_clear == 0
    output_im_binary = im_binary;
else
    se = strel('disk',size_parts_to_clear);
    im_binary = imerode(im_binary,se);
    output_im_binary = imdilate(im_binary,se);
end