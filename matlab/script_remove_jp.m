% texture removal test
%https://www.mathworks.com/help/images/examples/texture-segmentation-using-texture-filters.html
%http://www.mathworks.com/help/images/examples/color-based-segmentation-using-k-means-clustering.html
addpath('~/Packages/matlab/export_fig');


base_in_dir = '/Volumes/Maxtor/DSS/DSS_Fragments/fragments/';
base_out_dir = '/Volumes/Maxtor/DSS/DSS_Fragments/fragments_nojp/';

SPLIT_DIRNAME=1;
PLOT=0;

fid=fopen('/Volumes/Maxtor/DSS/files_from_nli_06112018.txt');
filelist=textscan(fid,'%s','Delimiter','\n');
fclose(fid);



for k=2811:3100%numel(filelist{1})%numel(D)
    [filepath, imname, ext] = fileparts(filelist{1}{k});
    if (SPLIT_DIRNAME)
        filepath=strtok(imname,'-');
    end
    
    try
        
        fprintf('Process file %s %d out of %d\n',imname,k,numel(filelist{1}))
        gc_fragment_full_path=fullfile(base_in_dir,filepath,[imname,'.png']);
        if ~exist(gc_fragment_full_path,'file')
            fprintf('ERROR file %s not found\n',gc_fragment_full_path);
            continue;
        end
        
        out_dir = fullfile(base_out_dir,filepath);
        if ~exist(out_dir,'dir')
            mkdir(out_dir);
        end
        
        A = imread(gc_fragment_full_path);
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
        
        
        nColors = 2;
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
        
        imwrite(MA,fullfile(out_dir,[imname,'.png']),'alpha',uint8(BW1.*255));
        
        if PLOT
            figure(5);
            subplot(1,2,1);
            imshow(MA);
            subplot(1,2,2);
            imshow(A);
            h=gcf;
            export_fig(fullfile('/Users/adiel/temp/out/',imname));
        end
        
    catch ME
        disp(ME.identifier)
    end
end



