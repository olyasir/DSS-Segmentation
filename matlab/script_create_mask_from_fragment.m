% texture removal test
%https://www.mathworks.com/help/images/examples/texture-segmentation-using-texture-filters.html
%http://www.mathworks.com/help/images/examples/color-based-segmentation-using-k-means-clustering.html
addpath('~/Packages/matlab/export_fig');


%dirname='/Users/adiel/temp/DSS-Haifa/results/p505_gc/';
%outpath='/Users/adiel/temp/DSS-Haifa/results/p505_nojp/';


%dirname='/Users/adiel/temp/DSS/MR/results/p589_gc/';
%outpath='/Users/adiel/temp/DSS/MR/results/p589_gc_nojp/';



base_in_dir = '/Volumes/Maxtor/DSS/DSS_Fragments/fragments/';
base_out_dir = '/Volumes/Maxtor/DSS/DSS_Fragments/mask/fragments/';
D=dir(base_in_dir);
for d=3:numel(D),
    if isdir(fullfile(D(d).folder,D(d).name))
        fprintf('Process %s %d outof %d\n',D(d).name,d,numel(D))
        in_dir = fullfile(D(d).folder,D(d).name);
        out_dir = fullfile(base_out_dir,D(d).name);
        process_dir(in_dir,out_dir)
    end
end

function process_dir(in_dir,out_dir)
PLOT=0;

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
        
        A = imread(fullimname);
        %A = imresize(A,0.50);
        if PLOT
            figure(1);
            imshow(A)
        end
        
        
        im_binary=A>0;
        im_binary=im_binary(:,:,1);
        
       % P.min_area_thresh=0.0001;
       % [im_labels,last_label,bounding_rects,sorted_areas,origin_labels,im_all_labels,centroid,CCstats] = ...
       %     biggest_con_comps(im_binary,P.min_area_thresh);
        
       % BW=logical(im_labels);
       % if BW(1,1)>0
       %     BW=~BW;
       % end
        
        
        imwrite(im_binary,fullfile(out_dir,imname));
        
        if PLOT
            figure(5);
            subplot(1,2,1);
            imshow(im_binary);
            subplot(1,2,2);
            imshow(A);
          %  h=gcf;
          %  export_fig(fullfile('/Users/adiel/temp/out/',imname));
        end
        
    catch ME
        disp(ME.identifier)
    end
end
end


