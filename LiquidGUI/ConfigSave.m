function ConfigSave(filename,a,b,Qz,xa,ya,xal,yal)

fid = fopen(filename,'w');
fprintf(fid,'%s%s\n','Calibration A = ',a);
fprintf(fid,'%s%s\n','Calibration B = ',b);
fprintf(fid,'%s%s\n','Qz = ',Qz);
fprintf(fid,'%s%s\n','Isotherm X-axis Column Header = ',xa);
fprintf(fid,'%s%s\n','Isotherm Y-axis Column Header = ',ya);
fprintf(fid,'%s%s\n','Isotherm X-axis Label = ',xal);
fprintf(fid,'%s%s\n','Isotherm Y-axis Label = ',yal);
fclose(fid);

end