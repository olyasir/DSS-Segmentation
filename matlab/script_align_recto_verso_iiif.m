

global PLOT
global RV

RV={};
PLOT=0;

P=config_params();


base_in_dir = '/Volumes/Maxtor/DSS/DSS_Fragments/mask/fragments/';
D=dir(base_in_dir);

for d=1:numel(D),
%for d=1:10%numel(D),
    if isdir(fullfile(D(d).folder,D(d).name))
        fprintf('Process %s %d outof %d\n',D(d).name,d,numel(D));
        process_dir(base_in_dir,D(d).name);
        
    end
end

fid = fopen('RV_11092019.csv', 'w') ;
for k=1:size(RV,1)
 fprintf(fid, '%s,%s,%f\n', RV{k,1},RV{k,2},RV{k,3}) ;
end
 fclose(fid) ;

function process_dir(base_in_dir,plateDir)
global RV;
in_dir = fullfile(base_in_dir,plateDir);
D=dir([in_dir,'/','*.png']);

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
        
        if contains(fullimname,'-R-')
            RName=imname;
            pos=strfind(RName,'-R-');
            listFiles = dir(fullfile(in_dir,[RName(1:pos),'*']));%  'P1-Fg001-*%s.txt.png')]);
            % in case there are more than 2 files / it means that the
            % original image is big and splitted into different sub images
            if numel(listFiles) == 2
                VName=listFiles(2).name;%fullfile(in_dir,listFiles(2).name);           
                [rotationAngle] = findAngle(fullfile(in_dir,RName), fullfile(in_dir,VName))
                fprintf('angle=%f\n',rotationAngle);
                RV=[RV;{RName,VName, rotationAngle}];
            end
        end
        
    catch ME
        disp(ME.identifier)
    end
end
end

function [rotationAngle] = findAngle(RName, VName)
global PLOT
fprintf('Find Angle--- %s . %s\n',RName, VName);
rotationAngle=-999;
imgRecto=imread(RName);
imgVerso=imread(VName);
if PLOT
    figure(1);
    subplot(2,1,1);
    imshow(imgRecto);
    subplot(2,1,2);
    imshow(imgVerso)
end

imgVersoFlipped = fliplr(imgVerso);

stats1 = regionprops(imgRecto,'Orientation','Area');
stats2 = regionprops(imgVersoFlipped,'Orientation','Area');

if isempty(stats1)
    return;
end
if isempty(stats2)
    return;
end

stats1tbl = struct2table(stats1);
stats2tbl = struct2table(stats2);

[S1,I1]=sort(table2array(stats1tbl(:,1)),'descend');
[S2,I2]=sort(table2array(stats2tbl(:,1)),'descend');

stats1Orientation=stats1(I1(1)).Orientation;
stats2Orientation=stats2(I2(1)).Orientation;

if PLOT
    figure(1);
    subplot(1,2,1);title('Recto')
    imshow(imgRecto);
    subplot(1,2,2);title('Verso');
    imshow(imgVersoFlipped);
end

rotationAngle = stats2Orientation-stats1Orientation;
fprintf('Rotation=%f\n',rotationAngle);
end


%return;

%
% RA=zeros(1364,1);
% for k=1:1364
%
%     fragname1=RV{k,1};
%     if ~exist(fullfile(P.MASK_PATH,[fragname1(1:end-5),'_mask.png']),'file')
%         continue;
%     end
%     im1 = imread(fullfile(P.MASK_PATH,[fragname1(1:end-5),'_mask.png']));
%
%     fragname2=RV{k,2};
%     if ~exist(fullfile(P.MASK_PATH,[fragname2(1:end-5),'_mask.png']),'file')
%         continue;
%     end
%
%     im2 = imread(fullfile(P.MASK_PATH,[fragname2(1:end-5),'_mask.png']));
%     im2f = fliplr(im2);
%
%     stats1 = regionprops(im1,'Orientation','Area');
%     stats2 = regionprops(im2f,'Orientation','Area');
%
%     if isempty(stats1)
%         continue;
%     end
%     if isempty(stats2)
%         continue;
%     end
%
%     stats1tbl = struct2table(stats1);
%     stats2tbl = struct2table(stats2);
%
%     [S1,I1]=sort(table2array(stats1tbl(:,1)),'descend');
%     [S2,I2]=sort(table2array(stats2tbl(:,1)),'descend');
%
%     stats1Orientation=stats1(I1(1)).Orientation;
%     stats2Orientation=stats2(I2(1)).Orientation;
%
%     if PLOT
%         figure(1);
%         subplot(1,2,1);title('Recto')
%         imshow(im1);
%         subplot(1,2,2);title('Verso');
%         imshow(im2f);
%
%
%         figure(2);
%         subplot(1,2,1);title('Recto')
%         imshow(im1);
%         subplot(1,2,2);title('Verso');
%         imshow(im2f);
%     end
%
%     rotationAngle = stats2Orientation-stats1Orientation;
%     RA(k)=rotationAngle;
%     fprintf('Rotation=%f\n',rotationAngle);
%
%     im2fr=imrotate(im2f,-rotationAngle);
%
%     imwrite(im2f,fullfile(P.MASK_ALIGNED_PATH,[fragname2,'_filped_mask.png']));
%     imwrite(im2fr,fullfile(P.MASK_ALIGNED_PATH,[fragname2,'_fliped_rotated_mask.png']));
%
%     im2frag = imread(fullfile(P.FRAGMENTS_PATH,[fragname2(1:end-5),'._gc_rect.png']));
%     im2fragrot=imrotate(im2frag,-rotationAngle);
%     imwrite(im2fragrot,fullfile(P.FRAGMENTS_ROTATED_PATH,[fragname2(1:end-5),'_rotated_frag.png']));
%     continue;
%
%     if PLOT
%         figure(3);
%         subplot(1,2,1);
%         imshow(im1);
%         subplot(1,2,2);
%         imshow(im2fr);
%     end
%     %BoundingBox: [23.5000 26.5000 553 750] uperleft x,y.. width x, width y
%     stats = regionprops(im2fr,'BoundingBox','Area');
%     statstbl = struct2table(stats);
%     [S1,I1]=sort(table2array(statstbl(:,1)),'descend');
%
%     bb=stats(I1(1)).BoundingBox;
%
%
%
%     % bb=stats.BoundingBox;
%     im2frc = im2fr(bb(2)+0.5:bb(2)+bb(4)-0.5,bb(1)+0.5:bb(1)+bb(3)-0.5);
%
%     im2frc = im2frc(1:size(im1,1),:);
%     aligned_mask=bitor(im1, im2frc);
%
%     imwrite(aligned_mask, fullfile(P.MASK_PATH,[fragname1,'_mask_av.png']));
%
%     if PLOT
%         figure(4);
%         subplot(1,3,1);
%         imshow(im1);
%         subplot(1,3,2);
%         imshow(im2frc);
%         subplot(1,3,3);
%         imshow(aligned_mask);
%     end
% end
%
% end
