function [] = boundaries2json( B,L,N,A ,outfile)
%boundaries2json Convert the output of bwboundaries to GeoJSON format
%  B,L,N,A - output of bwboundaries function
%   B is cell for each object. Each row in the object matrix contains the row and column coordinates of a boundary pixel.
% outfile - output file name in json format
% exterior borders are counter clockwise and interior borders are clockwise
%

if (nargin == 5)
    %  P{1} = outfile;
end


fid=fopen(outfile,'w+');
fprintf(fid,'{\n');

%N is the number of Objects found
for k=1:N
    % starct object
    fprintf(fid,'\t"type": "Polygon",\n');
    fprintf(fid,'\t"coordinates": [\n'); %open coordinates
    fprintf(fid,'\t[\n'); %open object
    for n=size(B{k},1):-1:1
        fprintf(fid,'[%s,%s]',num2str(B{k}(n,2)),num2str(B{k}(n,1)));
        if n > 1
            fprintf(fid,',');
        end
    end
    fprintf(fid,'\t]\n'); % close object
    
    % track object childs
    childs=find(A(:,k));
    for child=childs'
        %fprintf('Process object %d, child %d\n',k,child)
         fprintf(fid,'\t,[\n'); %open object
         if numel(B) < child
             fprintf('ERROR\n');
             break;
         end
        for n=1:size(B{child},1)
            fprintf(fid,'[%s,%s]',num2str(B{child}(n,2)),num2str(B{child}(n,1)));
            if n < size(B{child},1)
               fprintf(fid,',');
            end
        end
       fprintf(fid,'\t]\n'); % close object
    end
    fprintf(fid,'\t]\n'); % closses coordinates

   
end

fprintf(fid,'}\n');
fclose(fid);

end

