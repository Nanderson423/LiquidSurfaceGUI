%Saves data to txt file (Version 1.1)
%Create by Nate Anderson 8/17/11
%Modified on 8/22/11
function Txt_Save(filename,varargin)

%Adds .txt to the end if missing it
if isempty(strfind(filename,'.txt'))
    filename = strcat(filename,'.txt');
end;

%Finds max variable length
max = length(varargin{1});
for n = 2:length(varargin)
    if length(varargin{n}) > max
        max = length(varargin{n});
    end
end

data = zeros(max,length(varargin));    

for k = 1:length(varargin) %For each variable entered
    for m = 1:length(varargin{k}) %For each value of every variable
        data(m,k) = varargin{k}(m);
    end
end

dlmwrite(filename,data,'delimiter','\t','precision',10);
end