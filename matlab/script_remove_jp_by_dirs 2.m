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

base_in_dir = '/Volumes/Maxtor/DSS/DSS_Fragments/fragments/';
base_out_dir = '/Volumes/Maxtor/DSS/DSS_Fragments/fragments_nojp1/';

global PLOT;
PLOT=0;

%imname='137-Fg010-R-C01-R01-D24112011-T141946-LR445_ColorCal_both_110209.png';
%imname='137-Fg001-R-C01-R01-D24112011-T123411-LR445_ColorCal_both_110209.png';
%imname='137-Fg008-R-C01-R01-D24112011-T140237-LR445_ColorCal_both_110209.png';
%imname='137/137-Fg003-R-C01-R01-D24112011-T130333-LR445_ColorCal_both_110209.png';
%imname='137-Fg002-R-C01-R01-D24112011-T125142-LR445_ColorCal_both_110209.png';
%imname='249-Fg002-R-C01-R01-D07122011-T150547-LR445_ColorCal_both_110209.png'
%imname='280-Fg004-R-C01-R01-D21112011-T114604-LR445_ColorCal_both_110209.png';
%imname='P283/P283-Fg001-R-C01-R01-D24032013-T152000-LR445_ColorCalData_IAA_Both_CC110304_110702.png';
%imname='P6-Fg005-R-C01-R01-D17062014-T121130-LR445_PSC.png';
%base_in_dir=[base_in_dir,imname(1:strfind(imname,'/')-1)];
%base_out_dir=[base_out_dir,imname(1:strfind(imname,'/')-1)];
%imname=imname(strfind(imname,'/')+1:end);
%process_image(imname,base_in_dir,base_out_dir);
%return;


D=dir(base_in_dir);
for d=11:numel(D)
    % directory contains subdirs
    if isdir(fullfile(D(d).folder,D(d).name))
        if (strcmp(D(d).name,'.') || strcmp(D(d).name,'..'))
            continue;
        end
        fprintf('Process %s %d outof %d\n',D(d).name,d,numel(D))
        in_dir = fullfile(D(d).folder,D(d).name);
        out_dir = fullfile(base_out_dir,D(d).name);
        process_dir(in_dir,out_dir)
    else
        % directory contains images 
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

Ahsv=rgb2hsv(A);

%ab = double(lab_he(:,:,2:3));
ab = double(Ahsv);

nrows = size(ab,1);
ncols = size(ab,2);
ab = reshape(ab,nrows*ncols,3);

% take only pixels in fragments
Ifrag=find(Ag~=0);
ab_frag=ab(Ifrag,:);

nColors = 3;
%repeat the clustering 3 times to avoid local minima
[cluster_idx, cluster_center] = kmeans(ab_frag,nColors,'distance','sqEuclidean', ...
    'Replicates',3);

pixel_labels=zeros(size(ab,1),1);
pixel_labels(Ifrag)=cluster_idx;
pixel_labels_frag=pixel_labels(Ifrag);

%pixel_labels = reshape(cluster_idx,nrows,ncols);
pixel_labels = reshape(pixel_labels,nrows,ncols);

if PLOT
    figure(2);
    imshow(pixel_labels,[]), title('image labeled by cluster index');
end



%compute mean luminance of clusters
L=reshape(lab_he(:,:,1),nrows*ncols,1);
I1=find(pixel_labels==1);
I2=find(pixel_labels==2);
I3=find(pixel_labels==3);
I={I1,I2,I3};
%meanL=[mean(L(I1)),mean(L(I2)),mean(L(I3))]

%[maxL,maxLind]=max(meanL);
%decide which one is JP be svm model
jpIndex=findJpBySVMmodel(ab_frag,pixel_labels_frag);
if jpIndex==-1
    return;
end

pixel_labels1=zeros(size(pixel_labels));
pixel_labels1(Ifrag)=1;
%pixel_labels1(I{maxLind})=0;
for kk=1:numel(jpIndex)
    pixel_labels1(I{jpIndex(kk)})=0;
end


%pixel_labels(I
%im_binary=im2bw(pixel_labels-1);
im_binary=im2bw(pixel_labels1);

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

if ~exist(out_dir,'dir')
    mkdir(out_dir)
end
imwrite(MA,fullfile(out_dir,im_name),'alpha',uint8(BW1.*255));
% 
% if PLOT
%     figure(5);
%     subplot(1,2,1);
%     imshow(MA);
%     subplot(1,2,2);
%     imshow(A);
%     h=gcf;
%     export_fig(fullfile('/Users/adiel/temp/out/',im_name));
% end
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


function jpIndex=findJpBySVMmodel(ab_frag,pixel_labels_frag)
    jpIndex=[];
    if ~exist('Mdl','var')
        load('JP_SVM_MODEL.mat');
    end
    [labelIdx,score] = predict(Mdl,ab_frag);
    I1=find(pixel_labels_frag==1);
    I2=find(pixel_labels_frag==2);
    I3=find(pixel_labels_frag==3);
    % in svm model 0=parchment and letters 1=japanese paper
    meanScores=[mean(labelIdx(I1)),mean(labelIdx(I2)),mean(labelIdx(I3))];
    jpIndex=find(meanScores>=0.1);
   % [mx,jpIndex]=max(meanScores);
    fprintf('MeanScore %f %f %f,JP index=%d\n',meanScores(1),meanScores(2),meanScores(3),jpIndex);
    if isempty(jpIndex)
        jpIndex=-1;
        fprintf('NO Japanese Paper detected\n');
    end

end
