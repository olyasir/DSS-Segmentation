function im_binary = segment_by_rgb_trained(im,theta,rho,size_parts_to_clear)
if nargin<4
    size_parts_to_clear = 3;
end
im_binary = imlincomb(theta(1),im(:,:,1),theta(2),im(:,:,2),theta(3),im(:,:,3),-rho+0.5)==0;
im_binary = clear_small_parts(im_binary,size_parts_to_clear);
% se = strel('disk',3);
% im_binary = imerode(im_binary,se);
% im_binary = imdilate(im_binary,se);
