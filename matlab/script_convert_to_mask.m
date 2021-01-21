% converto to mask

%R from  script_align_recto_verso_from_db

img_path = '/Users/adiel/Projects/TAU/DeadSeatScrolls/Segmentation/results/Mask_gc/';
mask_path = '/Users/adiel/Projects/TAU/DeadSeatScrolls/Segmentation/results/Mask/';

for k=1:numel(R)
    fprintf('%d out of %d\n',k,numel(R));
    img = R{k,1};
    if ~exist(fullfile(img_path,[img(1:end-5),'._gc_rect.png']),'file')
        continue;
    end
    im=imread(fullfile(img_path,[img(1:end-5),'._gc_rect.png']));
    
   
    im_bw=(im~=0);
    im_bw=im_bw(:,:,1);
    
    imwrite(im_bw,fullfile(mask_path,[img(1:end-5),'_mask.png']));
end