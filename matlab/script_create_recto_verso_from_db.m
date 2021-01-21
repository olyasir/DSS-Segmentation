

% script arrange recto verso


db_fname='../SegmentationProcess0210017.csv';

fileID=fopen(db_fname);
C = textscan(fileID,'%d%s%s%s%s%d','Whitespace','\\ ','Delimiter',',','EndOfLine','\n');
fclose(fileID);
CC=reshape(C{2},[2,numel(C{2})/2]);
R=CC';
CC=reshape(C{3},[2,numel(C{3})/2]);
R=[R,CC(2,:)'];
CC=reshape(C{5},[2,numel(C{5})/2]);
R=[R,CC(2,:)'];

I=cellfun(@isempty,strfind(R(:,1),'-R-'));
ind_recto=find(I==0);
n=0;
RV=cell(3341,2);
for k=1:numel(ind_recto)
    
    
    I1=strfind(R{ind_recto(k)},'-R-');
    verso_pattern=[R{ind_recto(k)}(1:I1-1),'-V-'];

    I=cellfun(@isempty,strfind(R(:,1),verso_pattern));
    ind_verso=find(I==0);

    if ~isempty(ind_verso)
        n=n+1;
        RV{n,1}=R{ind_recto(k)};
         RV{n,2}=R{ind_verso};
    end
end

save('RV.mat','RV');
