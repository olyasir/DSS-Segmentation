% fix segmentation with plates from 

DEBUG=1;

PLATES_DIR='/Volumes/Seagate Expansion Drive/Plate images 040919/';
FRAGMENTS_BASE_DIR='/Volumes/Maxtor/DSS/DSS_Fragments/fragments/';

D=dir(PLATES_DIR);
D1=dir(FRAGMENTS_BASE_DIR);

for d1=3:3%numel(D1)
    curDir='40';%D1(d1).name;
    fullDir=fullfile(FRAGMENTS_BASE_DIR,curDir);
    fprintf('Process dir %s\n',fullDir);
    D2=dir(fullDir);
    for d2=3:3
        curFrag=D2(d2).name;
        fprintf('Process fragment %s\n',curFrag);
        imFrag=imread(fullfile(fullDir,curFrag));
        if (DEBUG)
            imshow(imFrag);
        end
        [num,txt,raw]=xlsread(fullfile(PLATES_DIR,'P105_nFrag.xls'));
        imPlate=imread(fullfile(PLATES_DIR,'P105.JPG'));
        fprintf('dd');
    end
end



% 
% for d=1:numel(D)
%     fprintf('%s\n',D(d).name);
% end

