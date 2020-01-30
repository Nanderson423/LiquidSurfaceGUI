%data save
function Ref_Save(Data,scannum,filename)

if ~isempty(findstr(filename,'.dat'))
    scan = num2str(scannum);
    filename = strrep(filename,'.dat','_');
    filename = strcat(filename,scan,'.ref');
end


fid = fopen(filename,'w');

for k = 1:size(Data,1)
fprintf(fid,'%e %c %e %c %e %c %e \n',Data(k,1),' ',Data(k,2),' ',Data(k,3),' ',Data(k,5));
end;

fclose(fid);
