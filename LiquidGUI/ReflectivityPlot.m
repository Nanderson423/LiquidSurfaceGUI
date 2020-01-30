%Collecting Data and Plotting for Reflectivity
global ReflecScanList
global Reflec
Dat = get(handles.FileNameBox,'UserData');
fid = fopen(Dat.Full);
scanstr = get(handles.ScanNumInput,'String');
scannum = str2double(scanstr);
fullscreen = get(0,'ScreenSize'); %Gets the screen size
ppi = get(0,'ScreenPixelsPerInch'); %Gets the pixels per inch
LineProps;
repl = get(handles.ReplotToggle,'Value');
MainPosition = get(handles.MainWindow,'Position');

%For Limits
XMin = get(handles.RefXMin,'UserData');
XMax = get(handles.RefXMax,'UserData');
YMin = get(handles.RefYMin,'UserData');
YMax = get(handles.RefYMax,'UserData');

if repl == 0;
    Reflec = {};
    ReflecScanList = {};
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
L = 2;
Detector = 2;
Monitor = 2;
while strcmp(headercheck{1},'#L') ~= 1;
    headercheck = textscan(fid, '%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q*[^\n]', 1);
end;

%Finds the number of columns
nCol = 1;
while ~isempty(headercheck{nCol}{1})
    nCol = nCol + 1;
end
nCol = nCol - 2;

%Makes format string from nCol
FormatString = repmat('%f',1,nCol);
FormatString = strcat(FormatString,'%*[^\n]');

%Finds the columns for the L, Detector, and Monitor
try
while strcmpi(headercheck{L},'L') ~= 1; %Looks for column with header L and remembers column number
    L = L + 1;
end;
while strcmpi(headercheck{Detector},'Detector') ~= 1; %Looks for column with header Detector and remembers column number
    Detector = Detector + 1;
end;
while strcmpi(headercheck{Monitor},'MonitorA') ~= 1; %Looks for column with header Monitor and remembers column number
    Monitor = Monitor + 1;
end;
catch
    warndlg('Scan is not a reflectivity!','Bad Reflectivity Scan');
    return
end

%Compensate for first string not having a column
L = L - 1;
Detector = Detector - 1;
Monitor = Monitor - 1;

n = 1;
%Pulls the data from the .dat file
while n < 19;
ScanData{n}{1} = [];
while isempty(ScanData{n}{1});
    ScanData{n} = textscan(fid,FormatString,'headerlines',1,'CollectOutput',1);
end;
n = n + 1;
end;

%Normalize Detector using monitor and compensating for extra scans
tempRef{1} = cat(2, ScanData{1}{1}(:,L), ... %Qz
                    ScanData{1}{1}(:,Detector)./ScanData{1}{1}(:,Monitor), ... %Detector/Monitor
                    (ScanData{1}{1}(:,Detector)./ScanData{1}{1}(:,Monitor)) .* sqrt(1./ScanData{1}{1}(:,Detector) + 1./ScanData{1}{1}(:,Monitor))); %Error
tempRef{2} = cat(2, ScanData{2}{1}(:,L), ... %Qz
                    ScanData{2}{1}(:,Detector)./ScanData{2}{1}(:,Monitor), ... %Detector/Monitor
                    (ScanData{2}{1}(:,Detector)./ScanData{2}{1}(:,Monitor)) .* sqrt(1./ScanData{2}{1}(:,Detector) + 1./ScanData{2}{1}(:,Monitor))); %Error
n = 3;
m = 3;
while n  < 18;
    %Det/Mon - Avg Background (also Det/Mon)
    DetMon = (ScanData{n}{1}(:,Detector)./ScanData{n}{1}(:,Monitor)) - ...
        ((ScanData{n+1}{1}(:,Detector)./ScanData{n+1}{1}(:,Monitor)) + ...
        (ScanData{n+2}{1}(:,Detector)./ScanData{n+2}{1}(:,Monitor)))/2;
    
    %Error for non-background Det/Mon
    det = ScanData{n}{1}(:,Detector);
    mon = ScanData{n}{1}(:,Monitor);
    er1 = sqrt((det)./(mon.^2) + (det.^2)./(mon.^3));
    %Error for first background Det/Mon
    det = ScanData{n+1}{1}(:,Detector);
    mon = ScanData{n+1}{1}(:,Monitor);
    er2 = sqrt((det)./(mon.^2) + (det.^2)./(mon.^3));
    %Error for second background Det/Mon
    det = ScanData{n+2}{1}(:,Detector);
    mon = ScanData{n+2}{1}(:,Monitor);
    er3 = sqrt((det)./(mon.^2) + (det.^2)./(mon.^3));
    %Propogates all error through to 'error'
    error = sqrt(er1.^2 + (er2.^2 + er3.^2)/4);
    
    tempRef{m} = cat(2,ScanData{n}{1}(:,L),DetMon,error);
    n = n + 3;
    m = m + 1;
end;

%Merge Matricies from different cells into a single matrix
n = 1;
tempRef2 = [];
while n < m
    tempRef2 = cat(1,tempRef2,tempRef{n});
    n = n + 1;
end;

%Gets rid of any Y values less than or equal to zero in the data
n = 1;
m = 1;
while n <= length(tempRef2);
    if tempRef2(n,2) > 0;
        RefData(m,:) = tempRef2(n,:);
        m = m + 1;
    end;
    n = n + 1;    
end;

%Make the Lower Limit Error Bars
for k = 1:length(RefData);
    if RefData(k,2) - RefData(k,3) <= 0;
        RefData(k,4) = RefData(k,2)*.99;
    else
        RefData(k,4) = RefData(k,3);
    end;
end;

%Normalizing Factor
for k = 1:length(RefData)
    RefData(k,5) = fresnel(RefData(k,1));
end;

%Puts the Data into Reflec for Later
Reflec{scannum,2} = RefData;
    
%Plotting

%Open Figure 3 (reffig) if necessary
if ishandle(handles.reffig) == 0;
    figure(handles.reffig);
    set(    handles.reffig, ...
            'name','Reflectivity', ...
            'Units','pixels', ...
            'Position',[ppi/2 ppi/2 MainPosition(1)-ppi (MainPosition(1)-ppi)*(3/4)], ...
            'NumberTitle','Off', ...
            'DeleteFcn',{@RefFig_DeleteFcn, handles}, ...
            'MenuBar','none', ...
            'toolbar','none');
    handles.refaxes = axes;
end;

%Focus on reffig
figure(handles.reffig);

if repl == 1;
    hold on;
    legend off
else
    clf;
    hold on
end;

%For Scan List Box
%---------------------------------------------
ReflecScanList{size(get(handles.ScanListBox,'String'),1)+1} = num2str(scannum);

%Sorts ReflecScanList
templist1 = sprintf('%s,', ReflecScanList{:});
templist2 = sscanf(templist1, '%g,');
[~, index] = sort(templist2);
ReflecScanList = ReflecScanList(index);

set(handles.ScanListBox,'String',ReflecScanList);
%-------------------------------------------

switch get(handles.NormalizedCheckBox,'Value')
    
    %Non-Normalized
    case 0
        
        switch get(handles.ErrorbarsCheckBox,'Value')
            
            %Non-Normalized without Errorbars
            case 0
                Reflec{scannum,1} = plot(   RefData(:,1), ...
                    RefData(:,2), ...
                    'linestyle','none');
                                
            %Non-Normalized with Errorbars
            case 1
                Reflec{scannum,1} = errorbar( RefData(:,1), ...
                    RefData(:,2), ...
                    RefData(:,4), ...
                    RefData(:,3), ...
                    'linestyle','none');
        end;
                
        %Normalized
    case 1
        
        switch get(handles.ErrorbarsCheckBox,'Value')
            
            %Normalized without Errorbars
            case 0
                Reflec{scannum,1} = plot( RefData(:,1), ...
                    RefData(:,2)./RefData(:,5), ...
                    'linestyle','none');
                                                
            %Normalized with Errorbars
            case 1
                Reflec{scannum,1} = errorbar( RefData(:,1), ...
                    RefData(:,2)./RefData(:,5), ...
                    RefData(:,4)./RefData(:,5), ...
                    RefData(:,3)./RefData(:,5), ...
                    'linestyle','none');
                
        end;
end;

switch get(handles.YScale,'Value')
    
    case 0
        
        %Setting Limits for Normalized on Linear
        switch  get(handles.NormalizedCheckBox,'Value')
            %Non-Normalized
            case 0
                ylim([YMin.NotNorm.Linear YMax.NotNorm.Linear]);
                %Normalized
            case 1
                ylim([YMin.Norm.Linear YMax.Norm.Linear]);
        end;
       
    case 1
        
        %Setting Limits for Normalized on Log
        switch  get(handles.NormalizedCheckBox,'Value')
            %Non-Normalized
            case 0
                ylim([YMin.NotNorm.Log YMax.NotNorm.Log]);
                %Normalized
            case 1
                ylim([YMin.Norm.Log YMax.Norm.Log]);
        end;
        set(gca,'YScale','log');
        
end;
xlim([XMin XMax]);

%Setting Line Properties
set(Reflec{scannum,1}, ...
    'color',lineprops{1}, ...
    'linewidth',lineprops{3}, ...
    'Marker', lineprops{4}, ...
    'MarkerSize',lineprops{5}, ...
    'DisplayName',['Scan ' scanstr]);


ReflecLegend = legend('show','location','NorthEast');

%%%%%%%%%%%%%%%
%For Data Saving to ref
Ref_Save(RefData,scannum,Dat.Name);
%%%%%%%%%%%

save('test.mat');

hold off;
fclose(fid);

