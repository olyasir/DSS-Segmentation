   
pam_dir='~/Projects/TAU/DeadSeatScrolls/iiif/images/PAM/';
D=dir(pam_dir);

P=config_params_pam();
P.min_area_thresh=0.00005;

input_dir='~/temp/shade_removal_result/';
output_dir='~/temp/pam1/';



for n=3:3%numel(D);
    fname=D(n).name;
    fprintf('Process file %d out of %d name=%s\n',n,numel(D),fname);
    pam_name=fullfile(input_dir,[fname(1:end-4),'.png']);
    pam_bw_name=fullfile(input_dir,[fname(1:end-4),'_1_bw.png']);
    
    extract_frags_from_bw_pam(pam_name,pam_bw_name,output_dir,P);
end

return;

D = dir
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
