function [binary_im,grey_im] = employ_threshold(im,bigger,values,threshold)
% employs a threshold on the image dimension required, bigger is boolean, means to make
% all the pixels that are bigger as true, and the others false.  if bigger
% is false it means 'smaller'.
% grey_im is the image before the threshold, binary_im is the binary
% thresholded image.
if sum(values~=0)==1
    dim = find(values~=0);
    if bigger
        grey_im = im(:,:,dim);
        binary_im = grey_im > threshold/values(dim);
    else
        grey_im = im(:,:,dim);
        binary_im = grey_im < threshold/values(dim);
    end
else
    if bigger
        grey_im = imlincomb(values(1),im(:,:,1),values(2),im(:,:,2),values(3),im(:,:,3),-threshold);
        binary_im =  grey_im > 0;
    else
        grey_im = imlincomb(values(1),im(:,:,1),values(2),im(:,:,2),values(3),im(:,:,3),-threshold);
        binary_im = grey_im < 0;
    end        
end
