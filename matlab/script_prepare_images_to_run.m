% script_prepare_images_to_run

fid=fopen('../GAUT_2.txt','w+');
%img_base_dir ='/Volumes/Maxtor/DSS_IAA_100717/Bronson_sent/'
%img_base_dir ='/Volumes/Maxtor/DSS_IAA_100717/Haifa_sent/Priority_3/';
%img_base_dir ='/Volumes/Maxtor/DSS_IAA_100717/AntonyParrot/Priority2/';
%img_base_dir ='/Volumes/Maxtor/DSS_IAA_100717/Daniel_SBE_and_JT/';
%img_base_dir ='/Volumes/Maxtor/DSS_IAA_100717/James_Tucker/Priority_2/';
img_base_dir ='/Volumes/Maxtor/DSS_IAA_100717/GAUT_sent/Priority_2/';

D = dir(img_base_dir);
for d=3:numel(D)
    dname=[img_base_dir,D(d).name];
    if isdir(dname);
        fprintf('%s\n',dname);
        DD = dir(dname);
        for dd=3:numel(DD)
           % if strfind(DD(dd).name,'IAA')
           if strfind(DD(dd).name,'LR445') %haifa
                fprintf('%s%s/%s\n',img_base_dir,D(d).name,DD(dd).name);
                fprintf(fid,'%s%s/%s\n',img_base_dir,D(d).name,DD(dd).name);
            end
           
        end
        
    end
end
fclose(fid);