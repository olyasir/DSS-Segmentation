% texture removal test
%https://www.mathworks.com/help/images/examples/texture-segmentation-using-texture-filters.html
%http://www.mathworks.com/help/images/examples/color-based-segmentation-using-k-means-clustering.html
addpath('~/Packages/matlab/export_fig');


%dirname='/Users/adiel/temp/DSS-Haifa/results/p505_gc/';
%outpath='/Users/adiel/temp/DSS-Haifa/results/p505_nojp/';


%base_in_dir='/Users/adiel/temp/DSS/MR/results/p686/jp';
%base_out_dir='/Users/adiel/temp/DSS/MR/results/p686/npjp';

%base_in_dir = '/Volumes/Maxtor/DSS/DSS_Fragments/fragments/';
%base_out_dir = '/Volumes/Maxtor/DSS/DSS_Fragments/fragments_nojp/';

base_in_dir = '/Volumes/Maxtor/DSS/DSS_Fragments/fragments/137/';
base_out_dir = '/Volumes/Maxtor/DSS/DSS_Fragments/fragments_nojp/137/';

global PLOT;
PLOT=1;

imname='137-Fg010-R-C01-R01-D24112011-T141946-LR445_ColorCal_both_110209.png';
%imname='137-Fg008-R-C01-R01-D24112011-T140237-LR445_ColorCal_both_110209.png';
process_image(imname,base_in_dir,base_out_dir);
return;


D=dir(base_in_dir);
for d=3:numel(D)
    if isdir(fullfile(D(d).folder,D(d).name))
        if (strcmp(D(d).name,'.') || strcmp(D(d).name,'..'))
            continue;
        end
        fprintf('Process %s %d outof %d\n',D(d).name,d,numel(D))
        in_dir = fullfile(D(d).folder,D(d).name);
        out_dir = fullfile(base_out_dir,D(d).name);
        process_dir(in_dir,out_dir)
    else
        fprintf('2 Process %s %d outof %d\n',D(d).name,d,numel(D))
        in_dir = base_in_dir;
        out_dir = base_out_dir;
        process_dir(in_dir,out_dir)
        break;
    end
end

function process_image(im_name,in_dir, out_dir)
global PLOT

fullimname = fullfile(in_dir,im_name);

A = imread(fullimname);
% A = imresize(A,0.50);
if PLOT
    figure(1);
    imshow(A)
end

Ag=rgb2gray(A);
maskA=Ag~=0;

cform = makecform('srgb2lab');
lab_he = applycform(A,cform);
% imwrite(lab_he,fullfile(out_dir,[imname(1:end-4),'_lab.png']));

ab = double(lab_he(:,:,2:3));
nrows = size(ab,1);
ncols = size(ab,2);
ab = reshape(ab,nrows*ncols,2);


nColors = 3;
%repeat the clustering 3 times to avoid local minima
[cluster_idx, cluster_center] = kmeans(ab,nColors,'distance','sqEuclidean', ...
    'Replicates',3);


pixel_labels = reshape(cluster_idx,nrows,ncols);
if PLOT
    figure(2);
    imshow(pixel_labels,[]), title('image labeled by cluster index');
end

im_binary=im2bw(pixel_labels-1);

P.min_area_thresh=0.001;
[im_labels,last_label,bounding_rects,sorted_areas,origin_labels,im_all_labels,centroid,CCstats] = ...
    biggest_con_comps(im_binary,P.min_area_thresh);

BW=logical(im_labels);
if BW(1,1)>0
    BW=~BW;
end


se=strel('disk',30);
BW1=imdilate(BW,se);
BW1=imerode(BW1,se);

BW1 = BW1 & maskA;
if PLOT
    figure(4); imshow(BW1);
end


MA=A;
MA(:,:,1)=MA(:,:,1).*uint8(BW1);
MA(:,:,2)=MA(:,:,2).*uint8(BW1);
MA(:,:,3)=MA(:,:,3).*uint8(BW1);

imwrite(MA,fullfile(out_dir,im_name),'alpha',uint8(BW1.*255));

if PLOT
    figure(5);
    subplot(1,2,1);
    imshow(MA);
    subplot(1,2,2);
    imshow(A);
    h=gcf;
    export_fig(fullfile('/Users/adiel/temp/out/',im_name));
end
end

function process_dir(in_dir,out_dir)

D=dir([in_dir,'/','*.png']);
if ~exist(out_dir,'dir')
    mkdir(out_dir);
end
for curimg=1:numel(D)
    
    try
        imname=D(curimg).name;
        fullimname = fullfile(in_dir,D(curimg).name);
        if strfind(D(curimg).name,'DS_Store')
            continue;
        end
        % if isempty(strfind(D(curimg).name,'ColorCalData_IAA'))
        %     continue;
        % end
        fprintf('%d outof %d %s\n',curimg,numel(D),fullimname);
        
        process_image(D(curimg).name,in_dir,out_dir);
        
        
    catch ME
        disp(ME.identifier)
    end
end
end


