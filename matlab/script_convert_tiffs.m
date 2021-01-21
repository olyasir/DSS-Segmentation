

% script_convert_tiffs

basedir='/Users/adiel/';
tiffdir=[basedir,'Dropbox/Projects/TAU/DeadSeatScrolls/iiif/images/MR/'];
outdir=[basedir,'Dropbox/Projects/TAU/DeadSeatScrolls/images/DSS/'];
D=dir(tiffdir);
rs=1;
for d=1:numel(D)
    fprintf('%s\n',D(d).name);
    if (strfind(D(d).name,'tif'))
        tiffim=imread(fullfile(tiffdir,D(d).name));
        resizedim=imresize(tiffim,1/rs);
        imwrite(resizedim,fullfile(outdir,[D(d).name(1:end-4),'.png']));
    end
end
