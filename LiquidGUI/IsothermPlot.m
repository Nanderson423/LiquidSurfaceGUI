%Initialize Variables from Control Boxes
global Isotherms
global IsoScanList
Dat = get(handles.FileNameBox,'UserData');
fid = fopen(Dat.Full);
scanstr = get(handles.ScanNumInput,'String');
scannum = str2double(scanstr);
fullscreen = get(0,'ScreenSize'); %Gets the screen size
ppi = get(0,'ScreenPixelsPerInch'); %Gets the pixels per inch
LineProps;
repl = get(handles.ReplotToggle,'Value');
MainPosition = get(handles.MainWindow,'Position');

CFGFile = get(handles.MainWindow,'UserData');
[~,~,~,xaxis.column,yaxis.column,xaxis.label,yaxis.label] = ConfigLoad(CFGFile.fullfilename);

%Open Figure 1 (isofig) if necessary
if ishandle(handles.isofig) == 0;
    figure(handles.isofig);
    handles.isoaxes = axes;
    
    set(    handles.isofig, ...
            'name','Isotherm', ...
            'Units','pixels', ...
            'Position',[ppi/2 ppi/2 MainPosition(1)-ppi (MainPosition(1)-ppi)*(3/4)], ...
            'NumberTitle','Off', ...
            'DeleteFcn',{@IsoFig_DeleteFcn, handles}, ...
            'toolbar','none');
            
    set(    handles.isoaxes, ...
            'FontSize',10);
            
end;

%Focus on Isofig
figure(handles.isofig);

if repl == 1;
    hold on;
    legend off;
else
    IsoScanList = {};
    Isotherms = {};
    set(handles.ScanListBox,'String',{});
    hold off
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
area = 2;
pressure = 2;
while strcmp(headercheck{1},'#L') ~= 1;
    
    headercheck = textscan(fid, '%q %q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%*[^\n]', 1);
    
end;

%Finds the columns for the Column Headers (Default is area and Pressure)
while strcmpi(headercheck{area},xaxis.column) ~= 1; %Looks for column with header Area and remembers column number
    area = area + 1;
end;
while strcmpi(headercheck{pressure},yaxis.column) ~= 1; %Looks for column with header Pressure and remembers column number
    pressure = pressure + 1;
end;

%Compensate for first string not having a column
area = area - 1;
pressure = pressure - 1;

%Pulls the data from the .dat file and plots it
IsoData{1} = [];
while isempty(IsoData{1});
    IsoData = textscan(fid, '%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f %*[^\n]','headerlines',1);
end;

%For Scan List Box
%---------------------------------------------
IsoScanList{size(get(handles.ScanListBox,'String'),1)+1} = num2str(scannum);

%Sorts IsoScanList
templist1 = sprintf('%s,', IsoScanList{:});
templist2 = sscanf(templist1, '%g,');
[~, index] = sort(templist2);
IsoScanList = IsoScanList(index);

set(handles.ScanListBox,'String',IsoScanList);
%-------------------------------------------

Isotherms{scannum,2} = IsoData{area};
Isotherms{scannum,3} = IsoData{pressure};

Isotherms{scannum,1} = plot(    IsoData{area},IsoData{pressure}, ...
                                'color',lineprops{1}, ...
                                'LineStyle',lineprops{2}, ...
                                'linewidth',lineprops{3}, ...
                                'Marker',lineprops{4}, ...
                                'MarkerSize',lineprops{5}, ...
                                'DisplayName',['Scan ' scanstr]);


IsoLegend = legend('show','location','NorthEast');

xlabel(xaxis.label,'FontSize',10);
ylabel(yaxis.label,'FontSize',10);
hold off;
fclose(fid);

