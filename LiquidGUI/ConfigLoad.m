function [a,b,Qz,xa,ya,xal,yal] = ConfigLoad(filename)
%Opens the filename, reads the config data from the file and saves it to a
%cell

fid = fopen(filename);

Config = textscan(fid,'%s%s%*[^\n]','CollectOutput',1,'Delimiter','=');

fclose(fid);

a = Config{1}{1,2}; % a for Calibration
b = Config{1}{2,2}; % b for Calibration
Qz = Config{1}{3,2}; % Qz value
xa = Config{1}{4,2}; % xaxis iso header
ya = Config{1}{5,2}; % yaxis iso header
xal = Config{1}{6,2}; % xaxis iso label
yal = Config{1}{7,2}; % yaxis iso label

end