function [ P ,S] = boundaries2wkt( B,L,N,A ,outwktfile)
%boundaries2wkt Convert the output of bwboundaries to well known text format
%  B,L,N,A - output of bwboundaries function
%   B is cell for each object. Each row in the object matrix contains the row and column coordinates of a boundary pixel.
% outwktfile - output file name in wkt format
% output is in cvs format:  Filename,POLYGON(?),POLYGON(?), ? \n
P=[];
P={};
S='';
if (nargin == 5)
    P{1} = outwktfile;
end

%N is the number of Objects found
for k=1:N
    % starct object
    S='';
    S = strcat(S,'POLYGON(');
    for n=1:size(B{k},1)
        S = strcat(S,sprintf('%s %s',num2str(B{k}(n,2)),num2str(B{k}(n,1))));
        if n < size(B{k},1)
            S = strcat(S,',');
        end
    end
    % track object childs
    childs=find(A(:,k));
    for child=childs'
        fprintf('Process object %d, child %d\n',k,child)
        S = strcat(S,'(');
        for n=1:size(B{child},1)
            S = strcat(S,sprintf('%s %s',num2str(B{k}(n,2)),num2str(B{k}(n,1))));
            if n < size(B{child},1)
                S = strcat(S,',');
            end
        end
        S = strcat(S,')');
    end
    
    % close object
    S = strcat(S,')');
    P{end+1}=S;
end

% save as JSON file format
if (nargin == 5)
    saveJson(P)
end
end

function saveJson(P)

 fid=fopen(outwktfile,'w+');
 fprintf(fid,'{\n');
 fprintf(fid,'\t"type": "Polygon",\n');
 fprintf(fid,'\t"coordinates": [\n');
 fprintf(fid,'\t[\n');
 fprintf(fid,'\t]\n');
 fprintf(fid,'\t]\n'); % closses coordinates
 fprintf(fid,'}\n');
 fclose(fid);
%  
%  {
%      "type": "Polygon",
%      "coordinates": [
%      [
%      [0, 0], [10, 10], [10, 0], [0, 0]
%      ],
%      [
%      [0, 0], [10, 10], [10, 0], [0, 0]
%      ]
%      ]
%      }
 
% write to file
% if (nargin == 5)
%     fid=fopen(outwktfile,'w+');
%     for n=1:numel(P)
%         fprintf(fid,'%s',P{n});
%         if (n<numel(P))
%             fprintf(fid,',');
%         end
%     end
%     fprintf(fid,'\n');
%     fclose(fid);
%     
% end

end



