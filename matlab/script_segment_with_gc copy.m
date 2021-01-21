


P = config_params();

% gc images directory
gc_dir = '/Users/adiel/Projects/TAU/DeadSeatScrolls/Segmentation/results/Mask_gc/';
img_dir = '/Users/adiel/Projects/TAU/DeadSeatScrolls/images/Bronson-sent/p998/';
%output_mask
D = dir([gc_dir,'*.png']);

for k=1:numel(D)
    fprintf('Process file %s\n',D(k).name)
    img_gc = imread(fullfile(gc_dir,D(k).name));
    img_gc_bin = img_gc~=0;
    img_gc_bin = img_gc_bin(:,:,1);
    
    [im_labels,last_label,bounding_rects,sorted_areas,origin_labels,im_all_labels,centroid] = ...
        biggest_con_comps(img_gc_bin);
    
    [B,L,N,A] = bwboundaries(im_labels);
    enclosed_boundaries = find(A(:,1));
   % imshow(label2rgb(im_labels, @jet, [.5 .5 .5]))
    hold on
    for kk = 1:length(B)
        boundary = B{kk};
        plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2)
    end
    
    % show on original image
    if (P.SHOW_ORIGINAL)
        origimgfile=fullfile(img_dir,[D(k).name(1:end-12),'.jpg']);
        origimg=imread(origimgfile);
        figure;
        imshow(origimg);
        hold on
        for kk = 1:length(B)
            boundary = B{kk}.*2;
            plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2)
        end
    end
    
    % save polygon boundaries in GeoJSON format
    outjson = fullfile (P.JSON_PATH, [D(k).name(1:end-3),'.json']);
    boundaries2json( B,L,N,A ,outjson);
    
end