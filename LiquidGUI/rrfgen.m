% Requires an input of either rrfgen(ref_file)
% or rrfgen(data,rrf_file)
% data = matrix of ref values with [qz,intensity,intensity_err]
function rrfgen(rrf_file,input)

switch class(input)
    
    case 'char'
        %Reads data from .ref file
        [qz,intensity,intensity_err,~]=ref_read(input);
        
    case 'double'
        %Reads data from matrix
        qz = input(:,1);
        intensity = input(:,2);
        intensity_err = input(:,3);
end

%Input Variables
offset.range = [-2e-4 2e-4];
qc = .0218; %Critical value
ran_num = 1000; %Amount of random numbers taken
Q.range = [.01 .024]; %Range of qz values
small_num = 1e-12;

%Reads subphase.par and puts the C values into a usable value
[P0,C0]=par_read2('subphase.par');
C1 = C0(5);

%Finds the number of values below the qc
for sub_qc = 1:length(qz)
    if qz(sub_qc + 1) > qc
        break
    end;
end;

%Gets the I0 range from the minimum and maximum intensities for
I0.range = [min(intensity(1:sub_qc))-50 max(intensity(1:sub_qc))+50];

%Shuffels the RNG then gets the random numbers
rng('shuffle');
monte_vars = rand([ran_num 2]);

I0.params = (I0.range(2) - I0.range(1))*monte_vars(:,1) + I0.range(1); %Creates the I0.params from the random numbers
offset.params = (offset.range(2) - offset.range(1)).*monte_vars(:,2) + offset.range(1); %Creates the offset.params from the random numbers
p2(1:ran_num,1) = .334; %Sets the p2 param to .334 for all values

%Merges all parameters into one set
P1 = cat(2,offset.params,p2,I0.params);

%Finds the Q.min and Q.max
Q.min = 1;
Q.max = length(qz);
for k = 1:length(qz)
    
    if qz(k) <= Q.range(1)
        Q.min = k;
    end;
    
    if qz(k) <= Q.range(2)
        Q.max = k;
    else
        break
    end;
end;

%%%%%%%%%%%%%%%%%%%%
%%%%%% Ranges %%%%%%
%%%%%%%%%%%%%%%%%%%%

LB=[offset.range(1);
    .334 - small_num;
    I0.range(1);];

UB=[offset.range(2);
    .334 + small_num;
    I0.range(2);];

%%%%%%%%%%%%%%%%%%%%

fval_optim.sub = 5000; %Initial optim value for catching best values

%Fitting with loop for parameters
for k = 1:ran_num
    
    % P1(k,:) - current parameter row
    % C1 - same value for all parameters
    % Q.min - min row wanted from data
    % Q.max - max row wanted from data
    % P2 - optimized parameters from current parameter
    % fval - fval for optimized parameters
    
    [P2,fval,~,~,~]=optim_fitRF(P1(k,:),C1,qz(Q.min:Q.max),intensity(Q.min:Q.max),intensity_err(Q.min:Q.max),LB,UB,100);
    
    if fval < fval_optim.sub
        fval_optim.sub = fval;
        P0 = P2';
    end;
end



qz = qz-P0(1);

%Gets fres from fresnel for normalizing
for k = 1:length(qz)
    fres(k,1) = fresnel(qz(k));
end;

intensity = (intensity/P0(3));
intensity_err = (intensity_err/P0(3));

P0(1) = 0;
P0(3) = 1;

%%%%%%%%%%%%%%%%%%%%
%%%% PLOTTING%%%%%%%
%%%%%%%%%%%%%%%%%%%%

q=[0.01:0.0001:0.03]';
y1=fitRF(P0,C1,qz);
yfit=fitRF(P0,C1,q);

figure(1)
hold on
ploterr(qz,intensity,[],intensity_err,'ko','hhy',.1);
plot(q,(yfit),'b-','linewidth',2);
hold off
set(gca,'xlim',[.01 .03]);

intensity = intensity./fres;
intensity_err = intensity_err./fres;

fid = fopen(rrf_file,'w');
for k = 1:length(qz)
    fprintf(fid,'%f %c %f %c %f \n',qz(k),' ',intensity(k),' ',intensity_err(k));
end;
fclose(fid);
