
%Initialize Variables from Control Boxes
global Flores
global FloresScanList
Dat = get(handles.FileNameBox,'UserData');
fid = fopen(Dat.Full);
scanstr = get(handles.ScanNumInput,'String');
scannum = str2double(scanstr);
floname = strcat(Dat.Full,'.scan',scanstr,'.mca');
fullscreen = get(0,'ScreenSize'); %Gets the screen size
ppi = get(0,'ScreenPixelsPerInch'); %Gets the pixels per inch
LineProps;
repl = get(handles.ReplotToggle,'Value');
MainPosition = get(handles.MainWindow,'Position');
Erange.min = get(handles.EnergyMin,'UserData');
Erange.max = get(handles.EnergyMax,'UserData');
FullRangeMin = get(handles.FloSBMin,'UserData');
FullRangeMax = get(handles.FloSBMax,'UserData');
BG.Min.low = Erange.min - .5;   %Background
BG.Max.low = Erange.min;   %Background
BG.Min.high = Erange.max;
BG.Max.high = Erange.max + .5;
Errorbars = get(handles.ErrorbarsCheckBox,'Value');

%Check to see if the MCA file exists
if exist(floname,'file') == 0;
    warndlg('Florescence MCA file could not be found!','Bad Florescence Scan');
    return   
end;

%Gets Config Values and Converts to numbers
CFGFile = get(handles.MainWindow,'UserData');
[a,b,Qz,~,~,~,~] = ConfigLoad(CFGFile.fullfilename);
ChCali(1,1) = str2double(a);
ChCali(1,2) = str2double(b);
CritAngle = str2double(Qz);

%Clears values if repl = 0
if repl == 0;
    Flores = {};
    FloresScanList = {};
    set(handles.ScanListBox,'String',{});
end;


%Looks through .dat for Scan Number
found = 0;
while found == 0;
    
    scanoutput = textscan(fid, '%c %c %d %*[^\n]', 1, 'headerLines', 1); %Line by line check for scan
    
    if scanoutput{2} == 'S';
        if scanoutput{3} == scannum;
            found = 1;
        end;
    end;
end;

%Looks through lines of header until it finds data
headercheck{1} = '#';
QzColumn = 3;
MonColumn = 3;

while strcmp(headercheck{1},'#L') ~= 1;
    
    headercheck = textscan(fid, '%q %q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q %*[^\n]', 1);
    
end;

%Finds the columns for the QzColumn
while strcmpi(headercheck{QzColumn},'L') ~= 1; %Looks for column with header L (for Qz) and remembers column number
    QzColumn = QzColumn + 1;
end;

try
while strcmpi(headercheck{MonColumn},'MonitorA') ~= 1; %Looks for column with header MonitorA and remembers column number
    MonColumn = MonColumn + 1;
end;
catch ME
    MonColumn = 3;
    while strcmpi(headercheck{MonColumn},'Monitor') ~= 1; %Looks for column with header MonitorA and remembers column number
        MonColumn = MonColumn + 1;
    end;
end

QzColumn = QzColumn - 1; %Compensate for first string not having column
MonColumn = MonColumn - 1; %Compensate for first string not having column

QzData{1} = [];

while isempty(QzData{1});
QzData = textscan(fid, '%f%f%f%f%f %f%f%f%f%f %f%f%f%f%f %f%f%f%f%f %f%f%f%f%f %f%f%f%f%f ','headerlines',1); % Collects Qz data from file
end;

Qz=QzData{QzColumn};
Mon = QzData{MonColumn};

[floid,bad] = fopen(floname);
n=1;

while ~feof(floid) %Scanning MCA file
    
    %Scans for Data
    floscanoutput = textscan(floid, '%q %d %*[^\n]', 1);
    
    tempchannels{n}{1} = [];
    
    %Pulls the data into cells
    if strcmp('#@CTIME',floscanoutput{1});
        if floscanoutput{2} > .1;
            
            %Finds #N to start collecting data after it
            while strcmp('#N',floscanoutput{1}) ~= 1;
                floscanoutput = textscan(floid, '%q %*[^\n]', 1);
            end;
            
            %Looks for data then collects it
            while isempty(tempchannels{n}{1});
                tempchannels{n} = textscan(floid, '%*2c %d%d%d%d%d %d%d%d%d%d %d%d%d%d%d %d%d%d%d%d %d%d%d%d%d', 'CollectOutput', 1);
            end;
            n = n+1;
        end;
    end;
end;
fclose(floid); %Closes the MCA file

%Get tempchannels size (number of scan points)
[scanM,scanN] = size(tempchannels);

n = 1; %channels Column Marker and tempchannels Cell Marker
m = 1; %channels Row Marker
j = 1; %tempchannels Row Marker
k = 1; %tempchannels Column Marker

%Takes data from temp channel to more usable
%permanent channel
while n <= scanN;
    
    %Gets number of channels per scan point
    [chansM,chansN] = size(tempchannels{n}{1});
    
    while m <= chansM*chansN;
        channels{1}(m,n) = tempchannels{n}{1}(j,k);  %Takes the data in the temp channel cells 1 to scanN
        m = m + 1;                                   %and puts them into a 1025xQz matrix in channels{1}
        k = k + 1;
        if k == (chansN +1);
            j = j + 1;
            k = 1;
        end;
    end;%End of m while
    
    n = n + 1;
    m = 1;
    j = 1;
    k = 1;
end;%End of n while

channels = cell2mat(channels); %Makes the channels cell into a matrix
channels = double(channels);

%Convert energy range to channel range using the ChCali (channel
%calibration)
XEng = 1:size(channels,1);
XEng = ChCali(1,1)*XEng - ChCali(1,2);

CHrange(1,1) = nearest((Erange.min + ChCali(1,2)) / ChCali(1,1));
CHrange(1,2) = nearest((Erange.max + ChCali(1,2)) / ChCali(1,1));

CHFullrange(1,1) = nearest((FullRangeMin + ChCali(1,2)) / ChCali(1,1));
CHFullrange(1,2) = nearest((FullRangeMax + ChCali(1,2)) / ChCali(1,1));

%Open Figure 2 (flofig) if necessary
if ishandle(handles.flofig) == 0;
    figure(handles.flofig);
    set(    handles.flofig, ...
            'name','Fluorescence', ...
            'NumberTitle','Off', ...
            'Units','pixels', ...
            'Position',[ppi/2 ppi/2 MainPosition(1)-ppi (MainPosition(1)-ppi)*(3/4)], ...
            'DeleteFcn',{@FloFig_DeleteFcn, handles});%, ...
%             'MenuBar','none', ...
%             'toolbar','none');
    
end;

%Focus on flofig
figure(handles.flofig);

%Plotting Florescence Surface Plot
subplot(2,2,1);
hold off;
QzSize = size(Qz);
Flores{scannum}{2,1} = imagesc(Qz,XEng(CHrange(1,1):CHrange(1,2)),channels(CHrange(1,1):CHrange(1,2),:));
xlabel('Qz');
ylabel('Energy');
title(['Fluorescence Surface Plot: Scan ', scanstr]);
set(gca,'YDIR','normal','UserData',scannum);
colorbar;

%Finds the CritAngleColumn
QzIncrement = (Qz(QzSize(1)) - Qz(1)) / (QzSize(1) - 1);
CritAngleColumn = ((CritAngle - Qz(1)) / QzIncrement) + 1;
if QzSize(1) < CritAngleColumn; %Semi check for incomplete Data
    CritAngleColumn = QzSize(1);
end;

channelsSize = size(channels);

%Makes the Energy Slice matrix
floEslice = sum(channels(CHrange(1,1):CHrange(1,2),1:QzSize(1,1)))';
floEslice_norm = floEslice./Mon; % Normalizing
floEslicenorm_err = floEslice_norm.*sqrt(1./floEslice+1./Mon);

%Makes Surface Qz Slice
floQsliceSurf = sum(channels(1:channelsSize(1),1:CritAngleColumn),2);

%Makes Bulk Qz Slice
floQsliceBulk = sum(channels(1:channelsSize(1),CritAngleColumn:QzSize(1)),2);

%Plotting Slice Matricies
%Check for Replot
if repl == 1
    
    %Energy Slice
    subplot(2,2,2);                             %Top Right
    hold on;
    switch Errorbars
        case 0
            Flores{scannum}{2,2} = plot(    Qz,floEslice_norm, ... 
                                        'linestyle',lineprops{2}, ...
                                        'linewidth',lineprops{3}, ...
                                        'color',lineprops{1}, ...
                                        'marker',lineprops{4}, ...
                                        'markersize',lineprops{5}); 
        case 1
            Flores{scannum}{2,2} = errorbar(    Qz,floEslice_norm,floEslicenorm_err, ... 
                                        'linestyle',lineprops{2}, ...
                                        'linewidth',lineprops{3}, ...
                                        'color',lineprops{1}, ...
                                        'marker',lineprops{4}, ...
                                        'markersize',lineprops{5});
    end;
    old = get(gca,'Xlim');
    if old(2) < (Qz(QzSize(1))+.001)
        xlim([(Qz(1)-.001) (Qz(QzSize(1))+.001)]);
    end;
    
    hold off;
    
    %Qz Surface Slice
    subplot(2,2,3);                             %Bottom Left
    hold on;
    Flores{scannum}{2,3} = plot(	XEng, floQsliceSurf, ...      
                                    'linewidth',lineprops{3}, ...
                                    'color',lineprops{1}); 
    hold off;
    
    %Qz Bulk Slice
    subplot(2,2,4);                             %Bottom Right
    hold on;
    Flores{scannum}{2,4} = semilogy(	XEng, floQsliceBulk, ...      
                                        'linewidth',lineprops{3}, ...
                                        'color',lineprops{1}, ...
                                        'DisplayName',['Scan ' scanstr]); 
    legend('off');
    
else
    
    %Energy Slice
    subplot(2,2,2) % Top Right
    hold off;
    switch Errorbars
        case 0
            Flores{scannum}{2,2} = plot(	Qz,floEslice_norm, ...
                                        'linestyle',lineprops{2}, ...
                                        'linewidth',lineprops{3}, ...
                                        'color',lineprops{1}, ...
                                        'marker',lineprops{4}, ...
                                        'markersize',lineprops{5});            
        case 1
            Flores{scannum}{2,2} = errorbar(	Qz,floEslice_norm,floEslicenorm_err, ...
                                        'linestyle',lineprops{2}, ...
                                        'linewidth',lineprops{3}, ...
                                        'color',lineprops{1}, ...
                                        'marker',lineprops{4}, ...
                                        'markersize',lineprops{5});
    end;
    title('Fluorescence Energy Slice Plot');
    xlabel('Qz');
    ylabel('Intensity');
    xlim([(Qz(1)-.001) (Qz(QzSize(1))+.001)]);
    
    %Qz Surface Slice
    subplot(2,2,3); %Bottom Left
    hold off;
    Flores{scannum}{2,3} = plot(	XEng, floQsliceSurf, ...
                                    'linewidth',lineprops{3}, ...
                                    'color',lineprops{1});
    xlabel('Energy');
    ylabel('Intensity');
    surftitle = strcat('Fluorescence Qz Surface Slice (Qz <  ',num2str(CritAngle),')');
    title(surftitle);
    xlim([FullRangeMin FullRangeMax]);
%     set(gca,'XTick',XTick);
%     set(gca,'XTickLabel',XTickLabel);
    
    
    %Qz Bulk Slice
    subplot(2,2,4); %Bottom Right
    hold off;
    Flores{scannum}{2,4} = plot(	XEng, floQsliceBulk, ...
                                    'linewidth',lineprops{3}, ...
                                    'color',lineprops{1}, ...
                                    'DisplayName',['Scan ' scanstr]);
    xlabel('Energy');
    ylabel('Intensity');
    bulktitle = strcat('Fluorescence Qz Bulk Slice (Qz >',num2str(CritAngle),')');
    title(bulktitle);
    xlim([FullRangeMin FullRangeMax]);
%     set(gca,'XTick',XTick);
%     set(gca,'XTickLabel',XTickLabel);
    
           
    gcf = handles.flofig;
    
end;

%For Scan List Box
%---------------------------------------------
FloresScanList{size(get(handles.ScanListBox,'String'),1)+1} = num2str(scannum);

%Sorts ReflecScanList
templist1 = sprintf('%s,', FloresScanList{:});
templist2 = sscanf(templist1, '%g,');
[~, index] = sort(templist2);
FloresScanList = FloresScanList(index);

set(handles.ScanListBox,'String',FloresScanList);
%-------------------------------------------

%Saves channels into Flores
Flores{scannum}{1,1} = channels;
%Saves Qz into Flores
Flores{scannum}{1,2} = Qz;
%Saves the Energy Slice into Flores
Flores{scannum}{1,3} = floEslice;
%Saves the Background Value
Flores{scannum}{1,4} = XEng;
%Normalizing Factor
Flores{scannum}{1,5} = Mon;

legend = legend('show');
set(legend,'Position', [0.0060146 0.5114 0.1126 0.061]);
hold off;
