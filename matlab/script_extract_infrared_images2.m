
base_in_dir = '/Volumes/Maxtor/DSS/DSS_Fragments/fragments/';
base_out_dir = '/Volumes/Maxtor/DSS/DSS_Fragments/fragments_nojp/';

D=dir(base_in_dir);
for d=3:numel(D),
    if isdir(fullfile(D(d).folder,D(d).name))
        if (strcmp(D(d).name,'.') || strcmp(D(d).name,'..'))
            continue;
        end
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
    end
end