


P = config_params();
  P.SHOW_ORIGINAL=0;
  
  
% gc images directory
gc_cords_dir = '/Users/adiel/Projects/TAU/DeadSeatScrolls/Segmentation/results/Daniel_SBE_and_JT_images_cords/';
gc_img_dir = '/Users/adiel/Projects/TAU/DeadSeatScrolls/Segmentation/results/Daniel_SBE_and_JT_images_gc/';
gc_boundary_dir='/Users/adiel/Projects/TAU/DeadSeatScrolls/Segmentation/results/Daniel_SBE_and_JT_images_boundaries/'
img_dir ='/Volumes/Maxtor/DSS_IAA_100717/Daniel_SBE_and_JT_images_gc/'

fid=fopen('/Users/adiel/Projects/TAU/DeadSeatScrolls/Segmentation/Daniel_SBE_and_JT_images.txt');
filelist=textscan(fid,'%s','Delimiter','\n');
fclose(fid);

if ~exist(gc_boundary_dir,'dir')
    mkdir(gc_boundary_dir);
end


%D = dir([gc_dir,'*gc_rect.png']);

for k=1:numel(filelist{1})%numel(D)
    [filepath, fname, ext] = fileparts(filelist{1}{k});
    fprintf('Process file %s %d out of %d\n',fname,k,numel(filelist{1}))
    if ~exist(fullfile(gc_img_dir,[fname,'._gc_rect.png']),'file')
        fprintf('ERROR file gc_rect not found\n');
        continue;
    end
    img_gc = imread(fullfile(gc_img_dir,[fname,'._gc_rect.png']));
    img_gc_bin = img_gc~=0;
    img_gc_bin = img_gc_bin(:,:,1);
    
    [im_labels,last_label,bounding_rects,sorted_areas,origin_labels,im_all_labels,centroid] = ...
        biggest_con_comps(img_gc_bin);
    if isempty(origin_labels)
        fprintf('ERROR!!!');
        continue;
    end
    
    % offset of croped image from original image (row, column) and resize
    % scale
    cords_file_name = fullfile(gc_cords_dir,[fname,'._gc_cords.txt']);
    fid_cords=fopen(cords_file_name,'r');
    s=fscanf(fid_cords,'%d %d %f');
    gc_resize=s(3);
   
    
    fclose(fid_cords);
    % B is cell with row, column of each pixel 
    [B,L,N,A] = bwboundaries(im_labels);
    B_orig=cell(size(B));
    for kk = 1:length(B)
        B_orig{kk}=B{kk} + repmat(s(1:2)',size(B{kk},1),1);
    end
     boundaries_file_name = fullfile(gc_boundary_dir,[fname,'_frag_boundaries.mat']);
     save(boundaries_file_name,'B_orig','L','N','A','gc_resize');
   
    
    %enclosed_boundaries = find(A(:,1));
   % imshow(label2rgb(im_labels, @jet, [.5 .5 .5]))
   % hold on
   % for kk = 1:length(B)
   %    B_orig{kk}=B{kk} + repmat(s',size(B{kk},1),1);
   %     boundary = B_orig{kk};
   %     plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2)
   % end
    
    % show on original image
    if (P.SHOW_ORIGINAL)
        
        origimgfile=fullfile(filepath,[fname,ext]);
        origimg=imread(origimgfile);
        figure;
        imshow(origimg);
        hold on
        for kk = 1:length(B)
            boundary = B_orig{kk}.*(1/gc_resize);
            plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2)
        end
    end
    
    % save polygon boundaries in GeoJSON format
    for kk = 1:length(B)
         B_orig{kk}= B_orig{kk}.*2;
    end
    outjson = fullfile (P.JSON_PATH, [fname,'.json']);
  %  boundaries2json( B_orig,L,N,A ,outjson);
    
end