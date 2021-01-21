function edges = find_thin_edges(im,threshold)
gaus = fspecial('gaussian',3,1);
sob = [1 0 2 0 1;0 0 0 0 0;0 0 0 0 0;0 0 0 0 0;-1 0 -2 0 -1];
sob_y=conv2(sob,gaus);
im = double(im);
edges = imfilter(im,sob_y,'same','symmetric').^2 + imfilter(im,sob_y','same','symmetric').^2;
if nargin<2 || isempty(threshold)
    threshold = 1.2^2*median(edges(:));
else
    threshold = threshold^2;
end
edges = edges > threshold;
edges([1:3,end-2:end],:) = 1;
edges(:,[1:3,end-2:end]) = 1;
edges = bwmorph(edges,'thin',inf);
