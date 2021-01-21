% texture removal test
%https://www.mathworks.com/help/images/examples/texture-segmentation-using-texture-filters.html
addpath('~/Packages/matlab/export_fig');
imname='../tmp/493-Fg003-R-C01-R01-D31102011-T093610-LR445_ColorCal_both_110209._gc_rect.png';
imname='~/Dropbox/temp/DDS_ForGil_27112017/P382-Fg001-R-C01-R01-D30092013-T152955-LR445 _ColorCalData_IAA_Both_CC110304_110702_gc_rect.png';

%dirname='/Users/adiel/Projects/TAU/DeadSeatScrolls/Segmentation/results/Fragments_gc/';
%outpath='/Users/adiel/Projects/TAU/DeadSeatScrolls/Segmentation/results/Fragments_no_jp/';

%dirname='/Users/adiel/Projects/TAU/DeadSeatScrolls/Segmentation/results/all_no_haifa_images_gc/';
%outpath='/Users/adiel/Projects/TAU/DeadSeatScrolls/Segmentation/results/all_no_haifa_images_gc//';


%dirname='/Users/adiel/Projects/TAU/DeadSeatScrolls/Segmentation/results/Daniel_SBE_and_JT_images_gc/';
%outpath='/Users/adiel/Projects/TAU/DeadSeatScrolls/Segmentation/results/Daniel_SBE_and_JT_images_gc/';

dirname='/Users/adiel/Dropbox/jm_RA_n8_Y49UKCnPJ/results/jm_RA_n8_Y49UKCnPJ_files_gc/';
outpath= dirname;

%dirname='/Users/adiel/temp/tmp1/';
%outpath='/Users/adiel/temp/tmp1out/';


PLOT=0;

D=dir(dirname);

for curimg=3:numel(D)
    
    
    imname=D(curimg).name;
    fullimname = fullfile(dirname,D(curimg).name);
    if strfind(D(curimg).name,'DS_Store')
        continue;
    end
   % if isempty(strfind(D(curimg).name,'ColorCalData_IAA'))
   %     continue;
   % end
    fprintf('%d outof %d %s\n',curimg,numel(D),fullimname);
    
    A = imread(fullimname);
    %A = imresize(A,0.50);
    if PLOT
        figure(1);
        imshow(A)
    end
    
    Ag=rgb2gray(A);
    maskA=Ag~=0;
     
    
    MA=A;
    MA(:,:,1)=MA(:,:,1).*uint8(maskA);
    MA(:,:,2)=MA(:,:,2).*uint8(maskA);
    MA(:,:,3)=MA(:,:,3).*uint8(maskA);
    
    imwrite(MA,fullfile(outpath,imname),'alpha',uint8(maskA.*255));
    
    if PLOT
        figure(5);
        subplot(1,2,1);
        imshow(MA);
        subplot(1,2,2);
        imshow(A);
        h=gcf;
        export_fig(fullfile('/Users/adiel/temp/out/',imname));
    end
end


