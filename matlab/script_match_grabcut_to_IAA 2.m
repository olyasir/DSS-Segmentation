% fix segmentation with plates from

global DEBUG
DEBUG=0;

global PLATES_DIR
PLATES_DIR='/Volumes/Seagate Expansion Drive/Plate images 040919/';
%PLATES_DIR ='/Volumes/Maxtor/Plate_images_csv/';

global FRAGMENTS_BASE_DIR
FRAGMENTS_BASE_DIR='/Volumes/Maxtor/DSS/DSS_Fragments/fragments/';

global PLATE_FRAGMENTS_DIR
PLATE_FRAGMENTS_DIR='/Volumes/Maxtor/Plate_fragments/';

%global LOG_FNAME
%LOG_FNAME=fullfile(PLATE_FRAGMENTS_OUTPUT_DIR,'log_extract_plate_fragments.txt');


D=dir(FRAGMENTS_BASE_DIR);


im1=imread(fullfile(FRAGMENTS_BASE_DIR,'137/137-Fg009-R-C01-R01-D24112011-T140709-LR445_ColorCal_both_110209.png'));
im2=imread(fullfile(PLATE_FRAGMENTS_DIR,'P137/P137_9.png'));

im1=rgb2gray(im1);
im2=rgb2gray(im2);

original=im2;
distorted=im1;

ptsOriginal = detectSURFFeatures(original);
ptsDistorted = detectSURFFeatures(distorted);
%Extract feature descriptors.

[featuresOriginal,validPtsOriginal] = extractFeatures(original,ptsOriginal);
[featuresDistorted,validPtsDistorted] = extractFeatures(distorted,ptsDistorted);

%Match features by using their descriptors.

indexPairs = matchFeatures(featuresOriginal,featuresDistorted);

%Retrieve locations of corresponding points for each image.
matchedOriginal = validPtsOriginal(indexPairs(:,1));
matchedDistorted = validPtsDistorted(indexPairs(:,2));

%Show point matches. Notice the presence of outliers.

figure
showMatchedFeatures(original,distorted,matchedOriginal,matchedDistorted);
title('Putatively Matched Points (Including Outliers)');

if (numel(matchedOriginal)<2 || numel(matchedDistorted<2))
    fprintf('ERROR The number of points in each set must be at least 2\n'); 
    return;
end
[tform,inlierDistorted,inlierOriginal] = estimateGeometricTransform( ...
    matchedDistorted,matchedOriginal,'similarity');

figure
showMatchedFeatures(original,distorted,inlierOriginal,inlierDistorted);
title('Matching Points (Inliers Only)');
legend('ptsOriginal','ptsDistorted');

Tinv  = tform.invert.T;

ss = Tinv(2,1);
sc = Tinv(1,1);
scale_recovered = sqrt(ss*ss + sc*sc)
theta_recovered = atan2(ss,sc)*180/pi

outputView = imref2d(size(original));
recovered = imwarp(distorted,tform,'OutputView',outputView);

figure
imshowpair(B, distorted,'Scaling','joint')

return

im1=imresize(imfilter(im1,fspecial('gaussian',7,1.),'same','replicate'),1,'bicubic');
im2=imresize(imfilter(im2,fspecial('gaussian',7,1.),'same','replicate'),1,'bicubic');

im1=im2double(im1);
im2=im2double(im2);

%figure;imshow(im1);figure;imshow(im2);

cellsize=3;
gridspacing=1;

addpath('/Users/adiel/Dropbox/Projects/matlab-lib/SIFTflow/');
addpath(fullfile('/Users/adiel/Dropbox/Projects/matlab-lib/SIFTflow/','mexDenseSIFT'));
addpath(fullfile('/Users/adiel/Dropbox/Projects/matlab-lib/SIFTflow/','mexDiscreteFlow'));

sift1 = mexDenseSIFT(im1,cellsize,gridspacing);
sift2 = mexDenseSIFT(im2,cellsize,gridspacing);

SIFTflowpara.alpha=2*255;
SIFTflowpara.d=40*255;
SIFTflowpara.gamma=0.005*255;
SIFTflowpara.nlevels=4;
SIFTflowpara.wsize=2;
SIFTflowpara.topwsize=10;
SIFTflowpara.nTopIterations = 60;
SIFTflowpara.nIterations= 30;


tic;[vx,vy,energylist]=SIFTflowc2f(sift1,sift2,SIFTflowpara);toc

warpI2=warpImage(im2,vx,vy);
figure;imshow(im1);figure;imshow(warpI2);

% display flow
clear flow;
flow(:,:,1)=vx;
flow(:,:,2)=vy;
figure;imshow(flowToColor(flow));

return;

% this is the code doing the brute force matching
tic;[flow2,energylist2]=mexDiscreteFlow(Sift1,Sift2,[alpha,alpha*20,60,30]);toc
figure;imshow(flowToColor(flow2));

return;


%Extract fragments from Plates

for d=3:3%numel(D)
    %curDir='136';
    D(d).name;
    plateName=D(d).name(1:strfind(D(d).name,'_')-1);
    fprintf('%d outof %d Process plate %s\n',d,numel(D),plateName);
    writeLog(sprintf('%d outof %d Process plate %s\n',d,numel(D),plateName));
    
    [A,fragCenters]=readFile(fullfile(PLATES_DIR,D(d).name));
    imPlateName = fullfile(PLATES_DIR,[plateName,'.jpg']);
    extractFragmentsFromPlate(imPlateName,plateName,fragCenters)
%     for d2=3:3
%         curFrag=D2(d2).name;
%         fprintf('Process fragment %s\n',curFrag);
%         imFrag=imread(fullfile(fullDir,curFrag));
%         if (DEBUG)
%             imshow(imFrag);
%         end
%         [A,fragCenters]=readFile(fullfile(PLATES_DIR,'P136_nFrag.xls'));
%         % [num,txt,raw]=xlsread(fullfile(PLATES_DIR,'P137_nFrag.csv'));
%         imPlateName = fullfile(PLATES_DIR,'P136.JPG');
%         extractFragmentsFromPlate(imPlateName,plateName,fragCenters)
%         fprintf('dd');
%     end
end


function [A,fragCenters] = readFile(fname)
fid=fopen(fname);
%fseek(fid,3,'bof');
%A = textscan(fid, '%d%f%f%d', 'delimiter', ',', 'HeaderLines', 0);
A = textscan(fid, '%d%f%f%d', 'HeaderLines', 0);
fclose(fid);
fragCenters=[A{2} A{3}];
end


function extractFragmentsFromPlate(imPlateName,plateName,fragCenters)
% fragCenters extracted with method readFile
global PLATE_FRAGMENTS_OUTPUT_DIR
global DEBUG

imPlate=imread(imPlateName);
imPlateGray=rgb2gray(imPlate);
BW=imPlateGray<255;
min_area_ratio=0.00003;
flag_use_filled_area=1;
flag_smooth=0;
[im_labels,last_label,bounding_rects,sorted_areas,origin_labels,im_all_labels,centroid,stats] =...
    biggest_con_comps(BW, min_area_ratio,flag_use_filled_area,flag_smooth);
fprintf('Found %d labels\n',last_label);
if (DEBUG)
  imshow(im_labels);
end
for k=1:last_label,
  %  fprintf('Process fragment %d\n',k);
    mask=im_labels==k;
    fragBoundingBox=regionprops(mask,'BoundingBox');
    BB=fragBoundingBox.BoundingBox; %% [x,y,width,height]
    maskedRgbImage = bsxfun(@times, imPlate, cast(mask, 'like', imPlate));
    im1=imcrop(maskedRgbImage,[floor(BB(1)),floor(BB(2)),BB(3:4)]);
    fragLabel=findFragmentLabel(BB,fragCenters);
    if fragLabel~= 0
        if ~exist(fullfile(PLATE_FRAGMENTS_OUTPUT_DIR,plateName),'dir')
            mkdir(fullfile(PLATE_FRAGMENTS_OUTPUT_DIR,plateName));
        end
        outFragName=fullfile(PLATE_FRAGMENTS_OUTPUT_DIR,plateName,[plateName,'_',num2str(fragLabel),'.png']);
        imwrite(im1,outFragName);
    else
        fprintf('ERROR did not find CC %d \n',k);
        writeLog(sprintf('ERROR plate %s did not find CC %d \n',plateName,k));
    end
end
fprintf('done\n');
end
%
% for d=1:numel(D)ma
%     fprintf('%s\n',D(d).name);
% end

function fragLabel= findFragmentLabel(BB,fragCenters)
% fragCenters is N*2 array with plate fragments centers
    fragLabel=0;
    for k=1:size(fragCenters,1)
        
        if fragCenters(k,1)>BB(1) && fragCenters(k,1)<BB(1)+BB(3) 
            if fragCenters(k,2)>BB(2) && fragCenters(k,2)< BB(2)+BB(4)
                fragLabel=k;
          %      fprintf('fragment label=%d\n',fragLabel);
                break;
            end
        end
    end
end

function writeLog(txt)
global LOG_FNAME
fid=fopen(LOG_FNAME,'a');
fprintf(fid,txt);
fclose(fid);
end

