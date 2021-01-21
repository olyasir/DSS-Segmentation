% fix segmentation with plates from

global DEBUG
DEBUG=0;

global PLATES_DIR
PLATES_DIR='/Volumes/Seagate Expansion Drive/Plate images 040919/';
%PLATES_DIR ='/Volumes/Maxtor/Plate_images_csv/';

FRAGMENTS_BASE_DIR='/Volumes/Maxtor/DSS/DSS_Fragments/fragments/';
global PLATE_FRAGMENTS_OUTPUT_DIR
PLATE_FRAGMENTS_OUTPUT_DIR='/Volumes/Maxtor/Plate_fragments/';

global LOG_FNAME
LOG_FNAME=fullfile(PLATE_FRAGMENTS_OUTPUT_DIR,'log_extract_plate_fragments.txt');


D=dir([PLATES_DIR,'*.xls']);
D1=dir(FRAGMENTS_BASE_DIR);

%Extract fragments from Plates

for d=72:numel(D)
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

