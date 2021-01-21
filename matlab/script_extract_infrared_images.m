

fragmentsBaseDir = '/Volumes/Maxtor/DSS/DSS_Fragments/fragments/';
fragmentsCordsBaseDir='/Volumes/Maxtor/DSS/DSS_Fragments/cords/';
baseOutDir = '/Volumes/Maxtor/DSS/DSS_Fragments/fragments_w/';


% list of all fragments that were succesfully processed
fNameProcessedFragments=fullfile('/Volumes/Maxtor/DSS/DSS_Fragments/', 'fragments_26112019.txt');
%imagesToProcessBaseDir='/Volumes/My Passport/';
%fName2and3batch=fullfile(imagesToProcessBaseDir,'2_and_3_batch.txt');


imagesToProcessBaseDir='/Volumes/Seagate Expansion Drive/2011to2013/';
fName2and3batch=fullfile(imagesToProcessBaseDir,'2011to2013_jpeg.txt');


fid1=fopen(fName2and3batch);
filesToProcess=textscan(fid1,'%s','Whitespace','\n');
fclose(fid1);
filesToProcess=filesToProcess{1};


fid2=fopen(fNameProcessedFragments);
fragmentsList=textscan(fid2,'%s','Whitespace','\n');
fclose(fid2);
fragmentsList=fragmentsList{1};


for k=14698:numel(filesToProcess)
    fName=filesToProcess{k};
    fprintf('%d  outof %d\n',k,numel(filesToProcess));
    %engn 'Second_batch_SQE_060618//SQE_2013B/PX63-Fg006-V-C01-R01-D22042013-T115651-RLIR_026.jpg'
    % search for processed fragment
    bkslPos=strfind(fName,'/');
    fNameShort=fName(bkslPos(end)+1:end);
    dName=fNameShort(1:strfind(fNameShort,'Fg')-2); %directory name
    if isempty(dName)
        fprintf('ERROR %s\n',fName);
        continue;
    end
    hyphenPos=strfind(fNameShort,'-');
    fNameShortShort=fNameShort(1:hyphenPos(5)-1);
    % location in fragment list
    I=find(contains(fragmentsList,fNameShortShort));
    if isempty(I)
        fprintf('ERROR didnt find fragment %s\n',fNameShort);
        continue;
    end
    if numel(I)>1
        I=I(1);
    end
    frag=imread(fullfile(fragmentsBaseDir,fragmentsList{I}));
    fid=fopen(fullfile(fragmentsCordsBaseDir,strrep(fragmentsList{I},'.png','_gc_cords.txt')));
    cords=textscan(fid,'%d %d %f');
    if cords{1}==0 || cords{2}==0
        fprintf('ERROR cords=0\n');
        continue
    end
    scale=1/cords{3};
    x=cords{2}*scale;
    y=cords{1}*scale;
    fclose(fid);
    im=imread(fullfile(imagesToProcessBaseDir,fName));
    if size(im,3)>1
        im=im(:,:,1);
    end
    imCroped=imcrop(im,[x,y,size(frag,2)*2-1,size(frag,1)*2-1]);
    
    mask=frag(:,:,1)~=0;
    mask=imresize(mask,scale);
    imCroped=imCroped.*uint8(mask);
    
    if ~exist(fullfile(baseOutDir,dName),'dir')
        mkdir(fullfile(baseOutDir,dName));
    end
    imwrite(imCroped,fullfile(baseOutDir,dName,fNameShort));
end
