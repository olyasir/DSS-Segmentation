function colors = collect_colors(path,filenames,resize_factor,b_hsv)
% colors is a m*3 array of the colors collected from patches in the TGB
% image im.
if nargin<4
    b_hsv=1;
end
if nargin<3
    resize_factor=1;
end
colors = [];
for i=1:length(filenames)
    try
        im = imread([path,filenames{i}]);
        if b_hsv
            fprintf('convert image to hsv');
            im = rgb2hsv(im);
        end
%         im = imread([path,'Betterlight-Test-Chromakey-2.jpg']);
    catch ME
        disp(['Can''t open image file "',filenames{i},'", skipping file, displaying error:']);
        disp(getReport(ME));
        continue
    end
    h=imshow(im);
    if resize_factor~=1
        im = imresize(im,resize_factor);
    end
    [x,y] = ginput();
    for j=1:length(x)/2
        patch = im(round(y(2*j-1):y(2*j)),round(x(2*j-1):x(2*j)),:);
        %         patch_hsv = rgb2hsv(patch);
        local_colors = reshape(patch, [size(patch,1)*size(patch,2),3]);
        %         local_hsv = reshape(patch_hsv, [size(patch,1)*size(patch,2),3]);
        %         local_hsv = uint8(local_hsv*255);
        %         colors = [colors;[local_colors local_hsv]];
        colors = [colors;local_colors];
    end
    close all
end