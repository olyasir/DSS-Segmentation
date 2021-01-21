function extract_frags_from_bw_pam(pam_name,pam_bw_name,output_dir,P)
fprintf('Extract frags from bw pam %s\n',pam_name);

[imgpath,imgbwname,imgext] = fileparts(pam_bw_name);
[Ig] = imread(pam_name);
im_binary=imread(pam_bw_name);

fprintf('run CC1\n');
[im_labels,last_label,bounding_rects,sorted_areas,origin_labels,im_all_labels,centroid,CCstats] = ...
    biggest_con_comps(im_binary,P.min_area_thresh);

im_labels= imfill(im_labels,'holes');


%figure(1);subplot(1,3,1); imshow(Ig); title('pam');
%figure(1);subplot(1,3,2); imshow(im_binary); title('im_binary');
%figure(1);subplot(1,3,3); imshow(im_labels); title('im_labels');
%saveas(gcf,fullfile(output_dir,[imgbwname,'_plot.png']));

imwrite(im_labels,fullfile(output_dir,
%outfragname=imgname;
%pos=strfind(imgname,'-');
%if ~isempty(pos)
%    outfragname = imgname(1:pos(2)-1);
%end

return;

for m=1:1%last_label
    fprintf('Process %d out of %d\n',m,last_label);
    %m=4; % first label
    comp_mask = (im_labels==m);
    
    
    [im_labels1,last_label1,bounding_rects1,sorted_areas1,origin_labels1,im_all_labels1,centroid1,CCstats1] = ...
        biggest_con_comps(comp_mask,P.min_area_thresh);
    
    comp_mask=im_labels1;
    comp_mask=imfill(comp_mask,'holes');
    
    cropx=bounding_rects(m,2)-P.crop_pad;
    cropy=bounding_rects(m,1)-P.crop_pad;
    cropw=bounding_rects(m,4)-bounding_rects(m,2)+2*P.crop_pad;
    croph=bounding_rects(m,3)-bounding_rects(m,1)+2*P.crop_pad;
    
    frag = Ig;
    frag = imcrop(frag,[cropx,cropy,cropw,croph]);
    
    frag_masked=Ig;
    frag_masked(comp_mask == 0) = 255;
    frag_masked = imcrop(frag_masked,[cropx,cropy,cropw,croph]);
    
    %figure(6); imshow(frag);
    
    %ROI = imcrop(Ig,[cropx,cropy,cropw,croph]);
    
    outpath = output_dir;
    if ~exist(outpath,'dir')
        fprintf('create dirctory %s\n',outpath);
        mkdir(outpath);
    end
    
    imwrite(frag,fullfile(outpath, [imgbwname,'_',num2str(m),'_frag.png']));
    imwrite(frag_masked,fullfile(outpath,[imgbwname,'_',num2str(m),'_mask.png']));
    
    
end

return
    
% script
close all;
P=config_params_pam();
P.min_area_thresh=0.00005;
input_dir='~/temp/shade_removal_result/'
name='M43680-1-E';
pam_name=fullfile(input_dir,[name,'.png']);
pam_bw_name=fullfile(input_dir,[name,'_1_bw.png']);
output_dir='~/temp/pam1/';
extract_frags_from_bw_pam(pam_name,pam_bw_name,output_dir,P)
