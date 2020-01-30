function out = fresnel(x)
qc=0.051798;
if (x<qc)
    out = 1;
else
    ff=sqrt(x*x-qc*qc);
    out = (((x-ff)/(x+ff))^2);
end;