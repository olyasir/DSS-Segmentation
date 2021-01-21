function [coordinates, success, scale, H, n_ruler_points, n_match_points, frames, descs] = ...
    find_ruler_by_sift(im,ruler,analysis,frames,descs,first_octave, n_octaves,ruler_thresh, ...
    im_thresh,fit_t)
% im, ruler: a color or grayscale uint8 image.
% ruler and im should be at about the same scale.
% frames & descs are the detected sift frames and descriptors of the ruler.
if nargin<10 || isempty(fit_t), fit_t = 0.01; end
if nargin<9 || isempty(im_thresh), im_thresh = 0.005; end
if nargin<8 || isempty(ruler_thresh), ruler_thresh = 0.005; end
if nargin<7 || isempty(n_octaves), n_octaves = 1; end
if nargin<6 || isempty(first_octave), first_octave = 0; end
if nargin<5
    CALC_RULER_SIFT = true;
    if nargin == 4
        warning('frames are given withoud descriptors, calculating both frames and descriptors.');
    end
elseif isempty(frames) || isempty(descs)
    CALC_RULER_SIFT = true;
else CALC_RULER_SIFT = false;
end
if nargin<3 || isempty(analysis), analysis = false; end
% end of arguments handling
[ruler_rows,ruler_cols,d] = size(ruler);
if d==3
    ruler = rgb2gray(ruler);
end
if size(im,3)==3
    im = rgb2gray(im);
end
ruler = single(ruler)/255;
im = single(im)/255;

if analysis, tic, end

if CALC_RULER_SIFT
    [frames,descs] = vl_sift(ruler,'FirstOctave',0,'Octaves',2,'PeakThresh',ruler_thresh);
end
n_ruler_points = size(frames,2);

[frames1,descs1] = vl_sift(im,'FirstOctave',first_octave,'Octaves',n_octaves,'PeakThresh',im_thresh);
matches = vl_ubcmatch(descs,descs1);
if size(matches,2) >= 2
    [H, inliers, success] = ransac_fit_transformation(frames(1:2,matches(1,:)),frames1(1:2,matches(2,:)),fit_t);
else
    success = false;
end

if ~success
    disp('Cannot find ruler in image.');
    scale = [];
    coordinates = [];
    inliers = [];
    H=[];
    n_match_points = 0;
else
    n_match_points = size(inliers,2);
    [ruler_rows,ruler_cols] = size(ruler);
    bounding_box1 = [0,0,1;ruler_cols,0,1;ruler_cols,ruler_rows,1;0,ruler_rows,1]'; % source bounding box
    bounding_box2 = H * bounding_box1;  %bounding box in the search image
    bounding_box2 = bounding_box2./repmat(bounding_box2(3,:),[3 1]);
    scale = norm(bounding_box2(1:2,2)-bounding_box2(1:2,1)) / norm(bounding_box1(1:2,2)-bounding_box1(1:2,1));
    coordinates = bounding_box2(1:2,:)';
    
    % adiel
     
    coordinates(1,1) = min(coordinates(1,1),size(im,2));
    coordinates(2,1) = min(coordinates(2,1),size(im,2));
    coordinates(3,1) = min(coordinates(3,1),size(im,2));
    coordinates(4,1) = min(coordinates(4,1),size(im,2));
end
if analysis, toc, end

if analysis
    im = uint8(im*255);
    imshow(im);
    hold on
    ruler = uint8(ruler*255);
%     imshow(ruler)
%    plotsiftframe(frames); %draw ruler keypoints
%     plot(frames(1,matches(1,inliers)),frames(2,matches(1,inliers)),'ob'); %mark matched keypoints on ruler
    plotsiftframe(frames1(:,matches(2,inliers))); %draw matched keypoints on target image
    disp(['number of matches: ',num2str(length(inliers))]);
    if success
        plot(bounding_box2(1,:),bounding_box2(2,:),'xr');
        line(bounding_box2(1,[1:4,1]),bounding_box2(2,[1:4,1]));
        title(['Scale: ',num2str(scale),', Total ruler points: ',num2str(size(frames,2)),', Inliers: ',num2str(length(inliers))]);
    else
        title(['Can''t find ruler. Total ruler points: ',num2str(size(frames,2)),', Inliers: ',num2str(length(inliers))]);
    end
end
