


P = config_params();
  P.SHOW_ORIGINAL=0;
  
 %'P1102-Fg003-R-C01-R01-D08122013-T131437-LR445 _ColorCalData_IAA_Left_CC110304_110702'
 % splite directory name from file name
SPLIT_DIRNAME=1;  
RUN_WITH_JP=0;

% gc images directory
img_dir ='/Volumes/My Passport/Second_batch_SQE_060618/';
gc_cords_dir = '/Volumes/Maxtor/DSS/DSS_Fragments/cords/';

% run once with JP and once without JP
if (RUN_WITH_JP)
    gc_img_dir = '/Volumes/Maxtor/DSS/DSS_Fragments/fragments/';
    gc_boundary_dir='/Volumes/Maxtor/DSS/DSS_Fragments/boundaries/fragments/';
    json_output_dir='/Volumes/Maxtor/DSS/DSS_Fragments/json/fragments/';
else
    gc_img_dir = '/Volumes/Maxtor/DSS/DSS_Fragments/fragments_nojp1/';
    gc_boundary_dir='/Volumes/Maxtor/DSS/DSS_Fragments/boundaries/fragments_nojp1/';
    json_output_dir='/Volumes/Maxtor/DSS/DSS_Fragments/json/fragments_nojp1/';
end

%fid=fopen('/Volumes/Maxtor/DSS/files_from_nli_06112018.txt');
fid=fopen('/Volumes/Maxtor/DSS/DSS_Fragments/all_nojp1_01122019.txt');
filelist=textscan(fid,'%s','Delimiter','\n');
fclose(fid);


%D = dir([gc_dir,'*gc_rect.png']);

for k=1:numel(filelist{1})%numel(D)
    [filepath, fname, ext] = fileparts(filelist{1}{k});
    if (SPLIT_DIRNAME)
        filepath=strtok(fname,'-');
    end
    fprintf('Process file %s %d out of %d\n',fname,k,numel(filelist{1}))
    gc_fragment_full_path=fullfile(gc_img_dir,filepath,[fname,'.png']);
    if ~exist(gc_fragment_full_path,'file')
        fprintf('ERROR file %s not found\n',gc_fragment_full_path);
        continue;
    end
    img_gc = imread(gc_fragment_full_path);
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
    cords_file_name = fullfile(gc_cords_dir,filepath,[fname,'_gc_cords.txt']);
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
     boundaries_file_name = fullfile(gc_boundary_dir,filepath,[fname,'_frag_boundaries.mat']);
     
    if ~exist([gc_boundary_dir,filesep,filepath],'dir')
        mkdir([gc_boundary_dir,filesep,filepath]);
    end
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
        
        origimgfile=fullfile(img_dir,filepath,[fname,ext]);
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
         B_orig{kk}= B_orig{kk}.*(1/gc_resize);
    end
    outjson = fullfile (json_output_dir, filepath,[fname,'.json']);
     if ~exist([json_output_dir,filesep,filepath],'dir')
        mkdir([json_output_dir,filesep,filepath]);
    end
    boundaries2json( B_orig,L,N,A ,outjson);
    
end