function varargout = LiquidGUI(varargin)
% LiquidGUI MATLAB code for LiquidGUI.fig
%      LiquidGUI, or LiquidGUI.fig, is a GUI program used for plotting liquid surface data such as Isotherms, Fluorescence, and Reflectivity.


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LiquidGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @LiquidGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before LiquidGUI is made visible.
function LiquidGUI_OpeningFcn(hObject, eventdata, handles, varargin)
%Sets up Globals and clears/initializes them
global Isotherms;
global IsoScanList;
global Reflec
global ReflecScanList;
global Flores
global FloresScanList
%Creates lists for holding scans
Isotherms = {};
IsoScanList = {};
Reflec = {};
ReflecScanList = {};
Flores = {};
FloresScanList = {};
%Creates figure handles for various plots in advance of calling them
handles.Config = 29;
handles.isofig = 30;
handles.flofig = 32;
handles.reffig = 34;
handles.gidfig = 36;
handles.gidaxes = 37;

set(handles.MainWindow, ...
            'CloseRequestFcn',{@MainWindow_CloseRequestFcn, handles}, ...
            'DeleteFcn',{@MainWindow_DeleteFcn, handles});
set(handles.ScanTypeMenu,'UserData',0)

if isempty(get(handles.MainWindow,'UserData'))
    pathname = pwd; %this is the current location of the exe file
    Default.file = 'Ameslab.cfg';
    Default.fullfilename = strcat(pathname,'/',Default.file);
    set(handles.MainWindow,'UserData',Default)
end;

handles.output = hObject;

guidata(hObject, handles);

ConfigButton_Callback(hObject, eventdata, handles);
close(figure(handles.Config));

function MainWindow_CloseRequestFcn(hObject, eventdata,handles)
result = questdlg(  'Are you sure you want to exit?', ...
                    'Exit?', ...
                    'Yes', 'No','No');
                
if strcmp(result,'Yes')
    delete(hObject);
end;

function MainWindow_DeleteFcn(hObject, eventdata, handles)
set(hObject,'CloseRequestFcn','');
close all;



% --- Outputs from this function are returned to the command line.
function varargout = LiquidGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function FileNameBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FileNameBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
    
end


function ScanNumInput_Callback(hObject, eventdata, handles)
% hObject    handle to ScanNumInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function ScanNumInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ScanNumInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ScanTypeMenu.
function ScanTypeMenu_Callback(hObject, eventdata, handles)
global IsoScanList
global FloresScanList
global ReflecScanList
repl = get(handles.ReplotToggle,'UserData');
Expanded = get(handles.ScanTypeMenu,'UserData');
Errorbars = get(handles.ErrorbarsCheckBox,'UserData');
Y = 429/300; %Expanding Factor

switch get(hObject,'Value')
    
    %Isotherm Selected
    case 1
        
        set(handles.ScanListBox,'Value',[]);
        
        %Brings figure to front if exists
        if ishandle(handles.isofig) == 1;
            figure(handles.isofig)
        end;
        
        set(handles.EnergyRangeText,'Visible','off');
        set(handles.RangeText1,'Visible','off');
        set(handles.EnergyMin,'Visible','off');
        set(handles.EnergyMax,'Visible','off');
        set(handles.RefXRange,'Visible','off');
        set(handles.RefXMin,'Visible','off');
        set(handles.RefXMax,'Visible','off');
        set(handles.RefYRange,'Visible','off');
        set(handles.RefYMin,'Visible','off');
        set(handles.RefYMax,'Visible','off');
        set(handles.RangeText2,'Visible','off');
        set(handles.SurfBulkRangeText,'Visible','off');
        set(handles.FloSBMin,'Visible','off');
        set(handles.FloSBMax,'Visible','off');
        
        if Expanded == 1
            position = get(handles.MainWindow,'Position');
            set(handles.MainWindow,'Position',[position(1) position(2) position(3) position(4)/Y]);
            
            %Objects Inside Main Window
            set(handles.FileNameBox,'Position',[50 261 200 19.5]);
            set(handles.ScanTextBox,'Position',[16.5 223 40.5 19.5]);
            set(handles.ScanNumInput,'Position',[57.5 223 51 19.5]);
            set(handles.TypeTextBox,'Position',[133.5 223 40 19.5]);
            set(handles.ScanTypeMenu,'Position',[175.166 223 101 19.5]);
            set(handles.ScanListTextBox,'Position',[11 188.55 64 15.6]);
            set(handles.ScanListBox,'Position',[16.5 104.05 55 84.5]);
            set(handles.LineText,'Position',[96 165.8 34 19.5]);
            set(handles.LineStyleMenu,'Position',[140 169.05 85 19.5],'Enable','on');
            set(handles.LineFontMenu,'Position',[235 169.05 40 19.5]);
            set(handles.CurrentColor,'Position',[285 151.5 17.5 19.5]);
            set(handles.MarkerText,'Position',[75 135.25 55 19.5]);
            set(handles.MarkerStyleMenu,'Position',[140 138.5 85 19.5],'Value',1);
            set(handles.MarkerFontMenu,'Position',[235 138.5 40 19.5]);
            
            set(handles.ErrorbarsCheckBox,'Visible','off');
            set(handles.YScale,'Visible','off');
            set(handles.BestFitCheckBox,'Visible','off');
            set(handles.NormalizedCheckBox,'Visible','off');
            set(handles.RefXRange,'Visible','off');
            
            set(handles.ScanTypeMenu,'UserData',0) %For Expanded var
        end;
        
        %Sets ScanListBox to IsoScanList
        set(handles.ScanListBox,'String',IsoScanList);
        
        %Removes replot ability if scanlist is empty
        if isempty(get(handles.ScanListBox,'String'))
            set(handles.ReplotToggle,'Value',repl.iso,'Enable','off')
        else
            set(handles.ReplotToggle,'Value',repl.iso,'Enable','on')
        end;
                
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    %Florescence Selected
    case 2
        
        set(handles.ScanListBox,'Value',[]);
        
        %Brings figure to front if exists
        if ishandle(handles.flofig) == 1
            figure(handles.flofig)
        end;
        
        set(handles.EnergyRangeText,'Visible','on');    %Flo
        set(handles.RangeText1,'Visible','on');         %Flo
        set(handles.EnergyMin,'Visible','on');          %Flo
        set(handles.EnergyMax,'Visible','on');          %Flo
        set(handles.RefXRange,'Visible','off');         %Ref
        set(handles.RefXMin,'Visible','off');           %Ref
        set(handles.RefXMax,'Visible','off');           %Ref
        set(handles.RefYRange,'Visible','off');         %Ref
        set(handles.RefYMin,'Visible','off');           %Ref
        set(handles.RefYMax,'Visible','off');           %Ref
        set(handles.RangeText2,'Visible','off');        %Ref
        set(handles.SurfBulkRangeText,'Visible','on');  %Flo
        set(handles.FloSBMin,'Visible','on');           %Flo
        set(handles.FloSBMax,'Visible','on');           %Flo
        
        set(handles.ErrorbarsCheckBox,'Visible','on','Value',Errorbars.flo);
        set(handles.YScale,'Visible','on');
        set(handles.BestFitCheckBox,'Visible','on');
        set(handles.NormalizedCheckBox,'Visible','on');
        
        if Expanded == 0
            position = get(handles.MainWindow,'Position');
            set(handles.MainWindow,'Position',[position(1) position(2) position(3) position(4)*Y]);
            
            %Objects Inside Main Window
            set(handles.FileNameBox,'Position',[50 390 200 19.5]);
            set(handles.ScanTextBox,'Position',[16.5 352 40.5 19.5]);
            set(handles.ScanNumInput,'Position',[57.5 352 51 19.5]);
            set(handles.TypeTextBox,'Position',[133.5 352 40 19.5]);
            set(handles.ScanTypeMenu,'Position',[175.166 352 101 19.5]);
            set(handles.ScanListTextBox,'Position',[11 317.55 64 15.6]);
            set(handles.ScanListBox,'Position',[16.5 233.05 55 84.5]);
            set(handles.LineText,'Position',[96 294.8 34 19.5]);
            set(handles.LineStyleMenu,'Position',[140 298.05 85 19.5],'Enable','on');
            set(handles.LineFontMenu,'Position',[235 298.05 40 19.5]);
            set(handles.CurrentColor,'Position',[285 280.5 17.5 19.5]);
            set(handles.MarkerText,'Position',[75 264.25 55 19.5]);
            set(handles.MarkerStyleMenu,'Position',[140 267.5 85 19.5],'Value',1);
            set(handles.MarkerFontMenu,'Position',[235 267.5 40 19.5]);
            
            set(handles.ScanTypeMenu,'UserData',1); %For Expanded var
            
        else
            set(handles.LineStyleMenu,'Enable','on','Value',1);
            set(handles.LineFontMenu,'Value',3);
        end;
        
        %Sets listbox to FloresScanList
        set(handles.ScanListBox,'String',FloresScanList);
        
        %Removes Replot ability if scanlist is empty
        if isempty(get(handles.ScanListBox,'String'))
            set(handles.ReplotToggle,'Value',repl.flo,'Enable','off')
        else
            set(handles.ReplotToggle,'Value',repl.flo,'Enable','on')
        end;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    %Reflectivity Selected
    case 3
        
        set(handles.ScanListBox,'Value',[]);
        
        %Brings figure to front if exists
        if ishandle(handles.reffig) == 1
            figure(handles.reffig)
        end;
        
        set(handles.EnergyRangeText,'Visible','off');   %Flo
        set(handles.RangeText1,'Visible','on');         %Flo
        set(handles.EnergyMin,'Visible','off');         %Flo
        set(handles.EnergyMax,'Visible','off');         %Flo
        set(handles.RefXRange,'Visible','on');          %Ref
        set(handles.RefXMin,'Visible','on');            %Ref
        set(handles.RefXMax,'Visible','on');            %Ref
        set(handles.RefYRange,'Visible','on');          %Ref
        set(handles.RefYMin,'Visible','on');            %Ref
        set(handles.RefYMax,'Visible','on');            %Ref
        set(handles.RangeText2,'Visible','on');         %Ref
        set(handles.SurfBulkRangeText,'Visible','off'); %Flo
        set(handles.FloSBMin,'Visible','off');          %Flo
        set(handles.FloSBMax,'Visible','off');          %Flo
        
        set(handles.ErrorbarsCheckBox,'Visible','on','Value',Errorbars.ref);
        set(handles.YScale,'Visible','on');
        set(handles.BestFitCheckBox,'Visible','on');
        set(handles.NormalizedCheckBox,'Visible','on');
            
        
        if Expanded == 0
            position = get(handles.MainWindow,'Position');
            set(handles.MainWindow,'Position',[position(1) position(2) position(3) position(4)*Y]);
            
            %Objects Inside Main Window Moving
            set(handles.FileNameBox,'Position',[50 390 200 19.5]);
            set(handles.ScanTextBox,'Position',[16.5 352 40.5 19.5]);
            set(handles.ScanNumInput,'Position',[57.5 352 51 19.5]);
            set(handles.TypeTextBox,'Position',[133.5 352 40 19.5]);
            set(handles.ScanTypeMenu,'Position',[175.166 352 101 19.5]);
            set(handles.ScanListTextBox,'Position',[11 317.55 64 15.6]);
            set(handles.ScanListBox,'Position',[16.5 233.05 55 84.5]);
            set(handles.LineText,'Position',[96 294.8 34 19.5]);
            set(handles.LineStyleMenu,'Position',[140 298.05 85 19.5],'Enable','off','Value',1);
            set(handles.LineFontMenu,'Position',[235 298.05 40 19.5],'Value',1);
            set(handles.CurrentColor,'Position',[285 280.5 17.5 19.5]);
            set(handles.MarkerText,'Position',[75 264.25 55 19.5]);
            set(handles.MarkerStyleMenu,'Position',[140 267.5 85 19.5],'Value',2);
            set(handles.MarkerFontMenu,'Position',[235 267.5 40 19.5]);
           
            set(handles.ScanTypeMenu,'UserData',1); %For Expanded var
            
        else
           set(handles.LineStyleMenu,'Enable','off','Value',1);
           set(handles.LineFontMenu,'Value',1);
           set(handles.MarkerStyleMenu,'Value',2);
        end;
        
            
        
        %Sets listbox to ReflecScanList
        set(handles.ScanListBox,'String',ReflecScanList);
        
        %Removes replot ability if scanlist is empty
        if isempty(get(handles.ScanListBox,'String'))
            set(handles.ReplotToggle,'Value',repl.ref,'Enable','off')
        else
            set(handles.ReplotToggle,'Value',repl.ref,'Enable','on')
        end;
        
    %GID Selected    
    case 4
        
        
end;


% --- Executes during object creation, after setting all properties.
function ScanTypeMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ScanTypeMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ScanListBox.
function ScanListBox_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function ScanListBox_CreateFcn(hObject, eventdata, handles)
set(hObject,'Value',[],'String',{});
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ErrorbarsCheckBox.
function ErrorbarsCheckBox_Callback(hObject, eventdata, handles)
global ReflecScanList
global Reflec
global FloresScanList
global Flores
YMin = get(handles.RefYMin,'UserData');
YMax = get(handles.RefYMax,'UserData');
ErrorbarsValue = get(handles.ErrorbarsCheckBox,'Value');
Errorbars = get(hObject,'UserData');
Normalized = get(handles.NormalizedCheckBox,'Value');

%For Scan Type
switch get(handles.ScanTypeMenu,'Value')
    
    %Florescence
    case 2
        Errorbars.flo = ErrorbarsValue;
        scanlist = str2double(FloresScanList);
        
        if ~isempty(FloresScanList) %Only runs if scans have previously been plotted
            %Focus on flofig
            figure(handles.flofig);
            subplot(2,2,2);
            lim.x = get(gca,'Xlim');
            lim.y.b = get(gca,'Ylim');
            
            for k = 1:length(scanlist)
                scannum = scanlist(k);
                color = get(Flores{scannum}{2,2},'color');
                linestyle = get(Flores{scannum}{2,2},'linestyle');
                linewidth = get(Flores{scannum}{2,2},'linewidth');
                markerfont = get(Flores{scannum}{2,2},'Markersize');
                markerstyle = get(Flores{scannum}{2,2},'Marker');
                displayname = get(Flores{scannum}{2,2},'DisplayName');
                xdata = Flores{scannum}{1,2};
                ydata = Flores{scannum}{1,3};
                mon = Flores{scannum}{1,5};
                ydata_norm = ydata./mon;
                ydata_err = ydata_norm.*sqrt(1./ydata + 1./mon);
                
                hold on;
                switch ErrorbarsValue
                    case 0
                        delete(Flores{scannum}{2,2});
                        Flores{scannum}{2,2} = plot(xdata,ydata_norm, ...
                                                    'color',color, ...
                                                    'linestyle',linestyle,...
                                                    'linewidth',linewidth, ...
                                                    'Markersize',markerfont, ...
                                                    'Marker',markerstyle', ...
                                                    'DisplayName',displayname);
                    case 1
                        delete(Flores{scannum}{2,2});
                        Flores{scannum}{2,2} = errorbar(xdata,ydata_norm,ydata_err, ...
                                                        'color',color, ...
                                                        'linestyle',linestyle,...
                                                        'linewidth',linewidth, ...
                                                        'Markersize',markerfont, ...
                                                        'Marker',markerstyle, ...
                                                        'DisplayName',displayname);
                end;
                hold off;
            end;
            lim.y.a = get(gca,'Ylim');
            
            ylim([lim.y.b(1) lim.y.a(2)])
            xlim([lim.x(1) lim.x(2)]);
            title('Florescence Energy Slice Plot');
            xlabel('Qz');
            ylabel('Intensity');
        end;
        
    %Reflectivity
    case 3
        Errorbars.ref = ErrorbarsValue;
        scanlist = str2double(ReflecScanList);
        
        if ~isempty(ReflecScanList) %Only runs if scans have previously been plotted
            
            %Gets current fig properties of already graphed scans
            for k = 1:length(scanlist)
                scannum = scanlist(k);
                color{scannum} = get(Reflec{scannum,1},'color');
                linewidth{scannum} = get(Reflec{scannum,1},'linewidth');
                markerfont{scannum} = get(Reflec{scannum,1},'Markersize');
                markerstyle{scannum} = get(Reflec{scannum,1},'Marker');
                displayname{scannum} = get(Reflec{scannum,1},'DisplayName');
            end;
            
                        
            %Focus on reffig
            figure(handles.reffig);
            hold off;
            x = plot(0,0);
            delete(x);
                        
            switch ErrorbarsValue
                
                %Errorbars Off
                case 0
                    
                    %For Normalization
                    switch Normalized
                        
                        %Normalized Off
                        case 0
                            
                            for k = 1:length(scanlist)
                                
                                hold on;
                                scannum = scanlist(k);
                                                                                                                                                               
                                Reflec{scannum,1} = plot(   Reflec{scannum,2}(:,1), ...
                                                            Reflec{scannum,2}(:,2), ...
                                                            'linestyle','none', ...
                                                            'color',color{scannum}, ...
                                                            'linewidth',linewidth{scannum}, ...
                                                            'markersize',markerfont{scannum}, ...
                                                            'marker',markerstyle{scannum}, ...
                                                            'DisplayName',displayname{scannum});
                            end;
                            
                            %Normalized On
                        case 1
                            
                            for k = 1:length(scanlist)
                                
                                hold on;
                                scannum = scanlist(k);
                                           
                                Reflec{scannum,1} = plot(   Reflec{scannum,2}(:,1), ...
                                                            Reflec{scannum,2}(:,2)./Reflec{scannum,2}(:,5), ...
                                                            'linestyle','none', ...
                                                            'color',color{scannum}, ...
                                                            'linewidth',linewidth{scannum}, ...
                                                            'markersize',markerfont{scannum}, ...
                                                            'marker',markerstyle{scannum}, ...
                                                            'DisplayName',displayname{scannum});
                            end;
                    end %End Normalization switch without errorbars
                    
                    %Errorbars On
                case 1
                    
                    %For Normalization
                    switch Normalized
                        
                        %Normalized Off
                        case 0
                            
                            for k = 1:length(scanlist)
                                
                                hold on;
                                scannum = scanlist(k);
                                
                                Reflec{scannum,1} = errorbar(   Reflec{scannum,2}(:,1), ...
                                                                Reflec{scannum,2}(:,2), ...
                                                                Reflec{scannum,2}(:,4), ...
                                                                Reflec{scannum,2}(:,3), ...
                                                                'linestyle','none', ...
                                                                'color',color{scannum}, ...
                                                                'linewidth',linewidth{scannum}, ...
                                                                'markersize',markerfont{scannum}, ...
                                                                'marker',markerstyle{scannum}, ...
                                                                'DisplayName',displayname{scannum});  
                            end;
                            
                            
                            %Normalized On
                        case 1
                            
                            for k = 1:length(scanlist)
                                
                                hold on;
                                scannum = scanlist(k);
                               
                                Reflec{scannum,1} = errorbar(   Reflec{scannum,2}(:,1), ...
                                                                Reflec{scannum,2}(:,2)./Reflec{scannum,2}(:,5), ...
                                                                Reflec{scannum,2}(:,4)./Reflec{scannum,2}(:,5), ...
                                                                Reflec{scannum,2}(:,3)./Reflec{scannum,2}(:,5), ...
                                                                'linestyle','none', ...
                                                                'color',color{scannum}, ...
                                                                'linewidth',linewidth{scannum}, ...
                                                                'markersize',markerfont{scannum}, ...
                                                                'marker',markerstyle{scannum}, ...
                                                                'DisplayName',displayname{scannum});                            
                            end; % For End                           
                    end %End Normalization switch with errorbars on
            end %End Errorbars switch
            
            %Sets limits and Yscale
            switch get(handles.YScale,'Value')
                case 0
                    set(gca,'Yscale','linear');
                    switch Normalized
                        case 0 
                            ylim([YMin.NotNorm.Linear YMax.NotNorm.Linear])
                        case 1
                            ylim([YMin.Norm.Linear YMax.Norm.Linear])
                    end;
                case 1
                    set(gca,'Yscale','log');
                    switch Normalized
                        case 0 
                            ylim([YMin.NotNorm.Log YMax.NotNorm.Log])
                        case 1
                            ylim([YMin.Norm.Log YMax.Norm.Log])
                    end;
            end;
            
            ReflecLegend = legend('show','location','NorthEast');
            
        end
end

set(hObject,'UserData',Errorbars);


% --------------------------------------------------------------------
function Menu_File_Callback(hObject, eventdata, handles)
% hObject    handle to Menu_File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function DeleteScan_Callback(hObject, eventdata, handles)

global Isotherms
global IsoScanList
global Flores
global FloresScanList
global Reflec
global ReflecScanList
ListBoxValues = get(handles.ScanListBox,'Value');

switch get(handles.ScanTypeMenu,'Value')
    
    
    %Isotherm
    case 1
        for k = 1:size(ListBoxValues,2)
            n = str2double(IsoScanList{ListBoxValues(k)});
            delete(Isotherms{n,1});
            Isotherms{n,1} = {};
            Isotherms{n,2} = {};
            
            IsoScanList{ListBoxValues(k)} = '';
        end;
        
        %Sorts IsoScanList
        templist1 = sprintf('%s,', IsoScanList{:});
        templist2 = textscan(templist1,'%s','delimiter',',','MultipleDelimsAsOne',1);
        templist1 = templist2{1};
        [~, index] = sort(templist1);
        IsoScanList = templist1(index)';
        
        set(handles.ScanListBox,'String',IsoScanList);
        set(handles.ScanListBox,'Value',[]);
        
        %Focus on Isofig and remove
        figure(handles.isofig);
        legend('off');
        legend('show');
        
        %Checks to see if any scans are left
        ScanListString = get(handles.ScanListBox,'String');        
        if isempty(ScanListString) == 1
            close(handles.isofig);
            set(handles.ReplotToggle,'Value',0,'Enable','off');
        end;
        
    %Flores
    case 2
        for k = 1:size(ListBoxValues,2)
            n = str2double(FloresScanList{ListBoxValues(k)});
            delete(Flores{n}{2,2});
            delete(Flores{n}{2,3});
            delete(Flores{n}{2,4});
            Flores{n}{1,1} = {};
            Flores{n}{1,2} = {};
            
            FloresScanList{ListBoxValues(k)} = '';
        end;
        
        %Sorts FloresScanList
        templist1 = sprintf('%s,', FloresScanList{:});
        templist2 = textscan(templist1,'%s','delimiter',',','MultipleDelimsAsOne',1);
        templist1 = templist2{1};
        [~, index] = sort(templist1);
        FloresScanList = templist1(index)';
        
        set(handles.ScanListBox,'String',FloresScanList);
        set(handles.ScanListBox,'Value',[]);
        
        %Focus on flofig and remove
        figure(handles.flofig);
        legend('off');
        legend('show');
        
        %Checks to see if any scans are left
        ScanListString = get(handles.ScanListBox,'String');                
        if isempty(ScanListString) == 1
            close(handles.flofig);
            set(handles.ReplotToggle,'Value',0,'Enable','off');
        end;
        
        
    %Reflec
    case 3
       for k = 1:size(ListBoxValues,2)
            n = str2double(ReflecScanList{ListBoxValues(k)});
            delete(Reflec{n,1});
            Reflec{n,1} = {};
            Reflec{n,2} = {};
            
            ReflecScanList{ListBoxValues(k)} = '';
        end;
        
        %Sorts IsoScanList
        templist1 = sprintf('%s,', ReflecScanList{:});
        templist2 = textscan(templist1,'%s','delimiter',',','MultipleDelimsAsOne',1);
        templist1 = templist2{1};
        [~, index] = sort(templist1);
        ReflecScanList = templist1(index)';
        
        set(handles.ScanListBox,'String',ReflecScanList);
        set(handles.ScanListBox,'Value',[]);
        
        %Focus on Isofig and remove
        figure(handles.reffig);
        legend('off');
        legend('show');
        
        %Checks to see if any scans are left
        ScanListString = get(handles.ScanListBox,'String');
        if isempty(ScanListString) == 1
            close(handles.reffig);
            set(handles.ReplotToggle,'Value',0,'Enable','off');
        end; 
        
end;

% --- Executes on button press in YScale.
function YScale_Callback(hObject, eventdata, handles)
YMin = get(handles.RefYMin,'UserData');
YMax = get(handles.RefYMax,'UserData');

switch get(handles.ScanTypeMenu,'Value')
    
    %Florescence
    case 2
        
        %Reflectivity
    case 3
        
        switch get(hObject,'Value')
            %Linear
            case 0
                switch get(handles.NormalizedCheckBox,'Value')
                    case 0
                        set(handles.RefYMin,'String',YMin.NotNorm.Linear);
                        set(handles.RefYMax,'String',YMax.NotNorm.Linear);
                    case 1
                        set(handles.RefYMin,'String',YMin.Norm.Linear);
                        set(handles.RefYMax,'String',YMax.Norm.Linear);
                end;
            %Log
            case 1
                switch get(handles.NormalizedCheckBox,'Value')
                    case 0
                        set(handles.RefYMin,'String',YMin.NotNorm.Log);
                        set(handles.RefYMax,'String',YMax.NotNorm.Log);
                    case 1
                        set(handles.RefYMin,'String',YMin.Norm.Log);
                        set(handles.RefYMax,'String',YMax.Norm.Log);
                end; 
        end;
        
        if ishandle(handles.reffig)
            figure(handles.reffig);
            switch get(hObject,'Value')
                %Linear
                case 0
                    set(gca,'YScale','Linear');
                    switch get(handles.NormalizedCheckBox,'Value')
                        %Not Norm with Linear
                        case 0
                            ylim([YMin.NotNorm.Linear YMax.NotNorm.Linear]);
                        %Nom with Linear
                        case 1
                            ylim([YMin.Norm.Linear YMax.Norm.Linear]);
                    end;
                %Log
                case 1
                    set(gca,'YScale','Log');
                    switch get(handles.NormalizedCheckBox,'Value')
                        %Not Norm with Linear
                        case 0
                            ylim([YMin.NotNorm.Log YMax.NotNorm.Log]);
                        %Nom with Linear
                        case 1
                            ylim([YMin.Norm.Log YMax.Norm.Log]);
                    end;
                    
            end;
        end;
end;


% --- Executes on button press in BestFitCheckBox.
function BestFitCheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to BestFitCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of BestFitCheckBox


% --- Executes on button press in NormalizedCheckBox.
function NormalizedCheckBox_Callback(hObject, eventdata, handles)
global ReflecScanList
global Reflec
global FloresScanList
global Flores
YMin = get(handles.RefYMin,'UserData');
YMax = get(handles.RefYMax,'UserData');


%Scantype switch
switch get(handles.ScanTypeMenu,'Value')
    
    %Florescence
    case 2
        
        
    %Reflectivity
    case 3
        
        switch get(hObject, 'Value')
            %Not Norm
            case 0
                switch get(handles.YScale,'Value')
                    %Linear
                    case 0
                        set(handles.RefYMin,'String',YMin.NotNorm.Linear);
                        set(handles.RefYMax,'String',YMax.NotNorm.Linear);
                    %Log
                    case 1
                        set(handles.RefYMin,'String',YMin.NotNorm.Log);
                        set(handles.RefYMax,'String',YMax.NotNorm.Log);
                end;
            %Norm
            case 1
                switch get(handles.YScale,'Value')
                    %Linear
                    case 0
                        set(handles.RefYMin,'String',YMin.Norm.Linear);
                        set(handles.RefYMax,'String',YMax.Norm.Linear);
                    %Log
                    case 1
                        set(handles.RefYMin,'String',YMin.Norm.Log);
                        set(handles.RefYMax,'String',YMax.Norm.Log);
                end;
        end;
        
        scanlist = str2double(ReflecScanList);
        
        if ~isempty(ReflecScanList) %Only runs if scans have previously been plotted
            
            %On or Off Switch for checkbox
            switch get(hObject,'Value')
                
                %Normalize being turned off
                case 0
                    for k = 1:size(scanlist,2)
                        
                        %For Errorbars
                        switch get(handles.ErrorbarsCheckBox,'Value')
                            
                            %Without Errorbars
                            case 0
                                set(Reflec{scanlist(k),1}, ... % Handle
                                    'YData',Reflec{scanlist(k),2}(:,2))% Y Data
                                    
                            %With Errorbars
                            case 1
                                
                                set(Reflec{scanlist(k),1}, ... % Handle
                                    'YData',Reflec{scanlist(k),2}(:,2), ... % Y Data
                                    'UData',Reflec{scanlist(k),2}(:,3), ... % Upper Bound errorbar
                                    'LData',Reflec{scanlist(k),2}(:,4)); % Lower Bound errorbar
                        end
                    end
                    figure(handles.reffig); %Focus on Reffig
                    switch get(handles.YScale,'Value')
                        %Linear
                        case 0
                            ylim([YMin.NotNorm.Linear YMax.NotNorm.Linear]); %Changes limits
                        case 1
                            ylim([YMin.NotNorm.Log YMax.NotNorm.Log]); %Changes limits
                    end;
                    
                    %Normalize being turned on
                case 1
                    for k = 1:size(scanlist,2)
                        
                        %For Errorbars
                        switch get(handles.ErrorbarsCheckBox,'Value')
                            
                            %Without ErrorBars
                            case 0
                                set(Reflec{scanlist(k),1}, ... % Handle
                                    'YData',Reflec{scanlist(k),2}(:,2)./Reflec{scanlist(k),2}(:,5)) % Y Data
                                
                            %With ErrorBars
                            case 1
                                
                                set(Reflec{scanlist(k),1}, ... % Handle
                                    'YData',Reflec{scanlist(k),2}(:,2)./Reflec{scanlist(k),2}(:,5), ... % Y Data
                                    'UData',Reflec{scanlist(k),2}(:,3)./Reflec{scanlist(k),2}(:,5), ... % Upper Bound errorbar
                                    'LData',Reflec{scanlist(k),2}(:,4)./Reflec{scanlist(k),2}(:,5)); % Lower Bound errorbar
                        end
                    end
                    figure(handles.reffig); %Focus on Reffig
                    switch get(handles.YScale,'Value')
                        %Linear
                        case 0
                            ylim([YMin.Norm.Linear YMax.Norm.Linear]); %Changes limits
                        case 1
                            ylim([YMin.Norm.Log YMax.Norm.Log]); %Changes limits
                    end;
                    
            end %Close Switch
        end %Close if
end


% --- Executes on button press in ReplotToggle.
function ReplotToggle_Callback(hObject, eventdata, handles)

currentvalue = get(handles.ReplotToggle,'Value');
repl = get(hObject,'UserData');

switch get(handles.ScanTypeMenu,'Value')
    
    %Isotherm
    case 1
        repl.iso = currentvalue;
        
    %Flores
    case 2
        repl.flo = currentvalue;
        
    %Reflec
    case 3
        repl.ref = currentvalue;
        
end

%sets the new values into the ReplotToggle User Data
set(hObject,'UserData',repl);
      

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in PlotButton.
% --- Main Plot Program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function PlotButton_Callback(hObject, eventdata, handles)
fullfilename = get(handles.FileNameBox,'UserData');

%Initializes Good (if Good = 1, plotting programs run)
Good = 1;


if isempty(fullfilename) %Checks for Data File Inputed
    warndlg('No .dat file selected!','No Data File');
    Good = 0;
    
%Checks for a number in the ScanNumInput
elseif strcmp(num2str(str2double(get(handles.ScanNumInput,'String'))),'NaN') 
    warndlg('Scan Box does not contain a number.','Bad Scan Number');
    Good = 0;
    
%Checks for Already Plotted Scans    
elseif get(handles.ReplotToggle,'Value') 
    %Gets a list of the Scans in ListBox (cell of strings
    scanlist = get(handles.ScanListBox,'String');
    %Gets the current scan input as a string
    scaninput = get(handles.ScanNumInput,'String');
    for k = 1:length(scanlist)
        if strcmp(scanlist(k),scaninput)
            warndlg('Scan number has already been plotted! Please pick another scan.','Bad Scan Number');
            Good = 0;
        end;
    end;
end;

%If statement for Goodscan
if Good == 1
    
    %Turns on Replot ability after first plotting
    if strcmp(get(handles.ReplotToggle,'Enable'),'off')
        set(handles.ReplotToggle,'Enable','on');
    end;
        
    switch get(handles.ScanTypeMenu,'Value')
        
        %Isotherm
        case 1
                 
            IsothermPlot; %Runs IsothermPlot macro
                        
        %Florescence
        case 2
                        
            FloresencePlot; %Runs FloresencePlot macro
            
        %Reflectivity
        case 3
            
            ReflectivityPlot; %Runs ReflectivityPlot macro
    end;
    
    
    set(handles.ScanListBox,'Value',[]);
end;

hold off; %Turns off hold
shg; %Pops up current graph


% --------------------------------------------------------------------
function Menu_Open_Callback(hObject, eventdata, handles)
[filename,pathname] = uigetfile('*.dat','Select your data file');

if isequal(filename,0) || isequal(pathname,0)

else
    
    fullfilename = strcat(pathname,filename);
    
    Dat.Name = filename;
    Dat.Full = fullfilename;
    
    set(    handles.FileNameBox, ...  [] 
            'String',['File name: ' Dat.Name], ...
            'UserData',Dat);
end;


% --------------------------------------------------------------------
function Menu_Save_Callback(hObject, eventdata, handles)
% hObject    handle to Menu_Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Menu_SaveAs_Callback(hObject, eventdata, handles)
global Isotherms
global Flores
global Reflec

[file.name,file.path] = uiputfile('*.mat','Enter the name of your Workspace');
set(hObject,'UserData',file);
fullname = strcat(file.path,file.name);
save(fullname,'Isotherms','Flores','Reflec');


% --------------------------------------------------------------------
function Menu_Exit_Callback(hObject, eventdata, handles)

MainWindow_CloseRequestFcn;


% --------------------------------------------------------------------
function Menu_Help_Callback(hObject, eventdata, handles)
% hObject    handle to Menu_Help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Menu_About_Callback(hObject, eventdata, handles)
% hObject    handle to Menu_About (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in LineText.
function LineColorButton_Callback(hObject, eventdata, handles)
% hObject    handle to LineText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Sets scans selected in Listbox to specific Line Style
function LineStyleMenu_Callback(hObject, eventdata, handles)
global Isotherms
global IsoScanList
global Flores
global FloresScanList
LineProps;
ListBoxValues = get(handles.ScanListBox,'Value');

switch get(handles.ScanTypeMenu,'Value')

    %Isotherm
    case 1
        for k = 1:size(ListBoxValues,2)
            n = str2double(IsoScanList{ListBoxValues(k)});
            set(Isotherms{n,1},'LineStyle',lineprops{2});
        end;
        
    %Flores
    case 2
        for k = 1:size(ListBoxValues,2)
            n = str2double(FloresScanList{ListBoxValues(k)});
            set(Flores{n}{2,2},'LineStyle',lineprops{2});
            set(Flores{n}{2,3},'LineStyle',lineprops{2});
            set(Flores{n}{2,4},'LineStyle',lineprops{2});
        end;
        
    %Reflec - Linestyle is Disabled in Reflectivity mode
    case 3
       
end;

% --- Executes during object creation, after setting all properties.
function LineStyleMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LineStyleMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CurrentColor.
function CurrentColor_Callback(hObject, eventdata, handles)
linecolor = get(handles.CurrentColor,'BackgroundColor');
linecolor = uisetcolor(linecolor,'Select your line color');
set(handles.CurrentColor,'BackgroundColor',linecolor);

%For Changing Currently Selected Lines
global Isotherms
global IsoScanList
global Flores
global FloresScanList
global Reflec
global ReflecScanList
LineProps;
ListBoxValues = get(handles.ScanListBox,'Value');

switch get(handles.ScanTypeMenu,'Value')

    %Isotherm
    case 1
        for k = 1:size(ListBoxValues,2)
            n = str2double(IsoScanList{ListBoxValues(k)});
            set(Isotherms{n,1},'color',lineprops{1});
        end;
        
    %Flores
    case 2
        for k = 1:size(ListBoxValues,2)
            n = str2double(FloresScanList{ListBoxValues(k)});
            set(Flores{n}{2,2},'color',lineprops{1});
            set(Flores{n}{2,3},'color',lineprops{1});
            set(Flores{n}{2,4},'color',lineprops{1});            
        end;
        
    %Reflec
    case 3
        for k = 1:size(ListBoxValues,2)
            n = str2double(ReflecScanList{ListBoxValues(k)});
            set(Reflec{n,1},'color',lineprops{1});
        end;
end;


% --- Executes on selection change in LineFontMenu.
function LineFontMenu_Callback(hObject, eventdata, handles)

%For changing font of Selected Scans
global Isotherms
global IsoScanList
global Flores
global FloresScanList
global Reflec
global ReflecScanList
LineProps;
ListBoxValues = get(handles.ScanListBox,'Value');

switch get(handles.ScanTypeMenu,'Value')

    %Isotherm
    case 1
        for k = 1:size(ListBoxValues,2)
            n = str2double(IsoScanList{ListBoxValues(k)});
            set(Isotherms{n,1},'LineWidth',lineprops{3});
        end;
        
    %Flores
    case 2
        for k = 1:size(ListBoxValues,2)
            n = str2double(FloresScanList{ListBoxValues(k)});
            set(Flores{n}{2,2},'LineWidth',lineprops{3});
            set(Flores{n}{2,3},'LineWidth',lineprops{3});
            set(Flores{n}{2,4},'LineWidth',lineprops{3});
        end;
        
    %Reflec
    case 3
        for k = 1:size(ListBoxValues,2)
            n = str2double(ReflecScanList{ListBoxValues(k)});
            set(Reflec{n,1},'LineWidth',lineprops{3});
        end;
end;


% --- Executes during object creation, after setting all properties.
function LineFontMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LineFontMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in MarkerStyleMenu.
function MarkerStyleMenu_Callback(hObject, eventdata, handles)

%For changing marker style of selected scans
global Isotherms
global IsoScanList
global Flores
global FloresScanList
global Reflec
global ReflecScanList
LineProps;
ListBoxValues = get(handles.ScanListBox,'Value');

switch get(handles.ScanTypeMenu,'Value')

    %Isotherm
    case 1
        for k = 1:size(ListBoxValues,2)
            n = str2double(IsoScanList{ListBoxValues(k)});
            set(Isotherms{n,1},'Marker',lineprops{4});
        end;
        
    %Flores
    case 2
        for k = 1:size(ListBoxValues,2)
            n = str2double(FloresScanList{ListBoxValues(k)});
            set(Flores{n}{2,2},'Marker',lineprops{4});
        end;
        
    %Reflec
    case 3
        if strcmp(lineprops{4},'none')
            warndlg('A marker type must be selected for error bars to work!','Bad Marker Type');
            set(hObject,'Value',2);
        else
            for k = 1:size(ListBoxValues,2)
                n = str2double(ReflecScanList{ListBoxValues(k)});
                set(Reflec{n,1},'Marker',lineprops{4});
            end;
        end;
end;


% --- Executes during object creation, after setting all properties.
function MarkerStyleMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MarkerStyleMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in MarkerFontMenu.
function MarkerFontMenu_Callback(hObject, eventdata, handles)

%For changing marker font of selected scans
global Isotherms
global IsoScanList
global Flores
global FloresScanList
global Reflec
global ReflecScanList
LineProps;
ListBoxValues = get(handles.ScanListBox,'Value');

switch get(handles.ScanTypeMenu,'Value')

    %Isotherm
    case 1
        for k = 1:size(ListBoxValues,2)
            n = str2double(IsoScanList{ListBoxValues(k)});
            set(Isotherms{n,1},'MarkerSize',lineprops{5});
        end;
        
    %Flores
    case 2
        for k = 1:size(ListBoxValues,2)
            n = str2double(FloresScanList{ListBoxValues(k)});
            set(Flores{n}{2,2},'MarkerSize',lineprops{5});
        end;
        
    %Reflec
    case 3
        for k = 1:size(ListBoxValues,2)
            n = str2double(ReflecScanList{ListBoxValues(k)});
            set(Reflec{n,1},'MarkerSize',lineprops{5});
        end;
end;


% --- Executes during object creation, after setting all properties.
function MarkerFontMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MarkerFontMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function DeselectScans_Callback(hObject, eventdata, handles)
set(handles.ScanListBox,'Value',[]);


% --------------------------------------------------------------------
function ScanListMenu_Callback(hObject, eventdata, handles)

num = length(get(handles.ScanListBox,'Value'));
set(handles.ExportTxt,'Visible','off');
set(handles.RefGen,'Visible','off');
set(handles.RrfGen,'Visible','off');
set(handles.MergeFlo,'Visible','off');

switch get(handles.ScanTypeMenu,'Value')
    
    %Isotherm
    case 1
    
        if num == 1
            set(handles.ExportTxt,'Visible','on');
        end
    
    %Fluores    
    case 2
        
        if num == 1
            set(handles.ExportTxt,'Visible','on');
        elseif num > 1
            set(handles.MergeFlo,'Visible','on');
        end
        
    %Ref    
    case 3
    
        if num == 1
            set(handles.RefGen,'Visible','on');
            set(handles.RrfGen,'Visible','on');
        end
end
        
 
% --- Executes during object creation, after setting all properties.
function ScanTextBox_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function MainWindow_CreateFcn(hObject, eventdata, handles)

%Sets MainWindow to leftside of screen
fullscreen = get(0,'ScreenSize'); %Gets the screen size
ppi = get(0,'ScreenPixelsPerInch'); %Gets the ppi of the screen
set(hObject,'Position',[fullscreen(3)-ppi/2-300 ppi/2 310 300]);


% --- Executes on button press in ConfigButton.
function ConfigButton_Callback(hObject, eventdata, handles)

position = get(handles.MainWindow,'Position');%Gets the MainWindow position and size
textcolor = [0.55  0.55  0.55]; %Initial text color before changing values

CFGFile = get(handles.MainWindow,'UserData');

[CaliA,CaliB,Qz,xa,ya,xal,yal] = ConfigLoad(CFGFile.fullfilename);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% General %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Creates the figure
handles.Config = figure(handles.Config);
set(handles.Config, 'Units', 'Pixels', ...
                    'Position', [position(1) position(2) 300 300], ...
                    'MenuBar','none', ...
                    'ToolBar','auto', ...
                    'Name','Configuration', ...
                    'NumberTitle','off', ...
                    'Color',get(handles.MainWindow,'Color'));
                
%Creates ConfigFile Textbox
handles.ConfigFile = uicontrol( handles.Config, ...
                                'Style','text', ...
                                'string',['Config File: ' CFGFile.file], ...
                                'UserData',CFGFile, ...
                                'FontWeight','bold', ...
                                'Units','pixels', ...
                                'Position',[20 248 220 19.5], ...
                                'HorizontalAlignment','left', ...
                                'TooltipString','Current Config File'); 
                            
%Creates ConfigCreate button
handles.ConfigCreate = uicontrol( handles.Config, ...
                                'Style','pushbutton', ...
                                'string','Create...', ...
                                'FontWeight','bold', ...
                                'Units','pixels', ...
                                'Position',[215 260 70 19.5], ...
                                'HorizontalAlignment','left', ...
                                'TooltipString','Create a new CFG file'); 
                            
%Creates ConfigBrowse button
handles.ConfigBrowse = uicontrol( handles.Config, ...
                                'Style','pushbutton', ...
                                'string','Browse...', ...
                                'FontWeight','bold', ...
                                'Units','pixels', ...
                                'Position',[215 240 70 19.5], ...
                                'HorizontalAlignment','left', ...
                                'TooltipString','Browse for Config file');                           
                            
%Creates ConfigTypeMenu
handles.ConfigTypeMenu = uicontrol( handles.Config, ...
                                    'Style','popupmenu', ...
                                    'string',{'Isotherm';'Fluorescence';'Reflectivity'}, ...
                                    'FontWeight','bold', ...
                                    'Units','pixels', ...
                                    'Position',[108 220 101 19.5], ...
                                    'HorizontalAlignment','left', ...
                                    'BackgroundColor','white', ...
                                    'Value',get(handles.ScanTypeMenu,'Value'), ...
                                    'TooltipString','Scan Type');                            
                            
                            
                            
%Creates ConfigSave Button
handles.ConfigSave = uicontrol( handles.Config, ...
                          'Style','pushbutton', ...
                          'string','Save', ...
                          'UserData',0, ...
                          'FontWeight','bold', ...
                          'Units','pixels', ...
                          'Position',[160 20 60 19.5], ...
                          'TooltipString','Save Changes'); 
                      
%Creates ConfigClose Button
handles.ConfigClose = uicontrol( handles.Config, ...
                          'Style','pushbutton', ...
                          'string','Close', ...
                          'FontWeight','bold', ...
                          'Units','pixels', ...
                          'Position',[230 20 60 19.5], ...
                          'TooltipString','Close Configuation Window'); 
 
%-------------------------------------------------------------%                      
                      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% Isotherm %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Creates Column Textbox
handles.ColumnTextBox = uicontrol( handles.Config, ...
                                        'Style','text', ...
                                        'string','Column Headers:', ...
                                        'FontWeight','bold', ...
                                        'Units','pixels', ...
                                        'Position',[30 178.5 120 22], ...
                                        'TooltipString','Desired column headers (case insensitive)');
                                    
%Creates XAxisText
handles.XAxisTextBox = uicontrol( handles.Config, ...
                               'Style','text', ...
                               'string','X Axis: ', ...
                               'FontWeight','bold', ...
                               'Units','pixels', ...
                               'Position',[17 159 50 19.5], ...
                               'TooltipString','Column header for X axis data');
                           
%Creates XAxis
handles.XAxis = uicontrol( handles.Config, ...
                           'Style','edit', ...
                           'string',xa, ...
                           'FontWeight','bold', ...
                           'Units','pixels', ...
                           'Position',[65 161 110 19.5], ...
                           'TooltipString','Column header for X axis data', ...
                           'BackgroundColor','white', ...
                           'ForegroundColor',textcolor);
                           
%Creates YAxisText
handles.YAxisTextBox = uicontrol( handles.Config, ...
                               'Style','text', ...
                               'string','Y Axis: ', ...
                               'FontWeight','bold', ...
                               'Units','pixels', ...
                               'Position',[17 136 50 19.5], ...
                               'TooltipString','Column header for Y axis data');
                           
%Creates YAxis
handles.YAxis = uicontrol( handles.Config, ...
                           'Style','edit', ...
                           'string',ya, ...
                           'FontWeight','bold', ...
                           'Units','pixels', ...
                           'Position',[65 138 110 19.5], ...
                           'TooltipString','Column header for Y axis data', ...
                           'BackgroundColor','white', ...
                           'ForegroundColor',textcolor);
                      
%Creates GraphLabel Textbox
handles.GraphLabelTextBox = uicontrol( handles.Config, ...
                                        'Style','text', ...
                                        'string','Graph Labels:', ...
                                        'FontWeight','bold', ...
                                        'Units','pixels', ...
                                        'Position',[170 178.5 120 22], ...
                                        'TooltipString','Labels for graph');
                                    
%Creates XAxisGraphLabel
handles.XAxisGraphLabel = uicontrol( handles.Config, ...
                           'Style','edit', ...
                           'string',xal, ...
                           'FontWeight','bold', ...
                           'Units','pixels', ...
                           'Position',[180 161 110 19.5], ...
                           'TooltipString','Column header for Y axis data', ...
                           'BackgroundColor','white', ...
                           'ForegroundColor',textcolor);
                       
%Creates XAxisGraphLabel
handles.YAxisGraphLabel = uicontrol( handles.Config, ...
                           'Style','edit', ...
                           'string',yal, ...
                           'FontWeight','bold', ...
                           'Units','pixels', ...
                           'Position',[180 138 110 19.5], ...
                           'TooltipString','Graph label for Y axis', ...
                           'BackgroundColor','white', ...
                           'ForegroundColor',textcolor);


%-------------------------------------------------------------%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% Fluorescence %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                     
                      
%Creates Calibration Textbox
handles.CalibrationTextBox = uicontrol( handles.Config, ...
                                        'Style','text', ...
                                        'string','Channel Calibration:', ...
                                        'FontWeight','bold', ...
                                        'Units','pixels', ...
                                        'Position',[25 178.5 250 22], ...
                                        'TooltipString','Energy = a * Channel + b');
                                                                                    
%Creates CaliText1
handles.CaliText1 = uicontrol( handles.Config, ...
                               'Style','text', ...
                               'string','Energy = ', ...
                               'FontWeight','bold', ...
                               'Units','pixels', ...
                               'Position',[11 159 63 19.5], ...
                               'TooltipString','Energy = a * Channel + b');
                            
%Creates CaliA
handles.CaliA = uicontrol( handles.Config, ...
                           'Style','edit', ...
                           'string',CaliA, ...
                           'FontWeight','bold', ...
                           'Units','pixels', ...
                           'Position',[78 161 55 19.5], ...
                           'TooltipString',CaliA, ...
                           'BackgroundColor','white', ...
                           'ForegroundColor',textcolor);
                            
%Creates CaliText2
handles.CaliText2 = uicontrol( handles.Config, ...
                               'Style','text', ...
                               'string',' * Channels - ', ...
                               'FontWeight','bold', ...
                               'Units','pixels', ...
                               'Position',[135 159 95 19.5], ...
                               'TooltipString','Energy = a * Channel + b');
                            
%Creates CaliB
handles.CaliB = uicontrol( handles.Config, ...
                           'Style','edit', ...
                           'string',CaliB, ...
                           'FontWeight','bold', ...
                           'Units','pixels', ...
                           'Position',[230 161 55 19.5], ...
                           'TooltipString',CaliB, ...
                           'BackgroundColor','white', ...
                           'ForegroundColor',textcolor);
                        
%Creates QzText
handles.QzText = uicontrol( handles.Config, ...
                            'Style','text', ...
                            'string','Qc :', ...
                            'FontWeight','bold', ...
                            'Units','pixels', ...
                            'Position',[123 125 50 19.5], ...
                            'TooltipString','Critical Angle Value');
                        
%Creates QzEdit
handles.QzEdit = uicontrol( handles.Config, ...
                            'Style','edit', ...
                            'string',Qz, ...
                            'FontWeight','bold', ...
                            'Units','pixels', ...
                            'Position',[119 105.5 60 19.5], ...
                            'TooltipString',Qz, ...
                            'BackgroundColor','white', ...
                            'ForegroundColor',textcolor);
                        
%-------------------------------------------------------------%                        
                            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% Reflectivity %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                       
                        
                      
%-------------------------------------------------------------%


%Set visibilty of objects depending on the ScanType
set(handles.ConfigTypeMenu,'Value',get(handles.ScanTypeMenu,'Value'));

%%%% CALLBACK DEFINITIONS %%%%
set(handles.CaliA, 'Callback', {@CaliA_Callback, handles});
set(handles.CaliB, 'Callback', {@CaliB_Callback, handles});
set(handles.XAxis,'Callback',{@XAxis_Callback, handles});
set(handles.YAxis,'Callback',{@YAxis_Callback, handles});
set(handles.XAxisGraphLabel,'Callback',{@XAxisGraphLabel_Callback, handles});
set(handles.YAxisGraphLabel,'Callback',{@YAxisGraphLabel_Callback, handles});
set(handles.QzEdit, 'Callback', {@QzEdit_Callback, handles});
set(handles.ConfigTypeMenu, 'Callback', {@ConfigTypeMenu_Callback, handles});
set(handles.ConfigSave, 'Callback', {@ConfigSave_Callback, handles});
set(handles.ConfigClose, 'Callback', {@ConfigClose_Callback, handles});
set(handles.ConfigBrowse, 'Callback', {@ConfigBrowse_Callback, handles});
set(handles.ConfigCreate, 'Callback', {@ConfigCreate_Callback, handles});
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ConfigTypeMenu_Callback(handles.ConfigTypeMenu,eventdata,handles)


% --------------------------------------------------------------------                    
function CaliA_Callback(hObject, eventdata, handles)
    set(    hObject, ...
            'ForegroundColor',[0 0 0], ...
            'TooltipString',get(hObject,'String'));

    set(handles.ConfigSave,'UserData',1) %For checking to see if any values have changed
    

% --------------------------------------------------------------------                    
function CaliB_Callback(hObject, eventdata, handles)
    set(    hObject, ...
            'ForegroundColor',[0 0 0], ...
            'TooltipString',get(hObject,'String'));
    
    set(handles.ConfigSave,'UserData',1) %For checking to see if any values have changed 
    
    % --------------------------------------------------------------------                    
function XAxis_Callback(hObject, eventdata, handles)
    set(    hObject, ...
            'ForegroundColor',[0 0 0], ...
            'TooltipString',get(hObject,'String'));

    set(handles.ConfigSave,'UserData',1) %For checking to see if any values have changed
    
% --------------------------------------------------------------------                    
function YAxis_Callback(hObject, eventdata, handles)
    set(    hObject, ...
            'ForegroundColor',[0 0 0], ...
            'TooltipString',get(hObject,'String'));

    set(handles.ConfigSave,'UserData',1) %For checking to see if any values have changed
    
% --------------------------------------------------------------------                    
function XAxisGraphLabel_Callback(hObject, eventdata, handles)
    set(    hObject, ...
            'ForegroundColor',[0 0 0], ...
            'TooltipString',get(hObject,'String'));

    set(handles.ConfigSave,'UserData',1) %For checking to see if any values have changed
    
% --------------------------------------------------------------------                    
function YAxisGraphLabel_Callback(hObject, eventdata, handles)
    set(    hObject, ...
            'ForegroundColor',[0 0 0], ...
            'TooltipString',get(hObject,'String'));

    set(handles.ConfigSave,'UserData',1) %For checking to see if any values have changed


% --------------------------------------------------------------------                    
function QzEdit_Callback(hObject, eventdata, handles)
    set(    hObject, ...
            'ForegroundColor',[0 0 0], ...
            'TooltipString',get(hObject,'String'));

    set(handles.ConfigSave,'UserData',1) %For checking to see if any values have changed


% --------------------------------------------------------------------
function ConfigTypeMenu_Callback(hObject, eventdata, handles)

switch get(hObject,'Value')
    %Isotherm
    case 1
        %%%% ISO %%%%
        set(handles.ColumnTextBox,'Visible','on');
        set(handles.XAxisTextBox,'Visible','on');
        set(handles.XAxis,'Visible','on');
        set(handles.YAxisTextBox,'Visible','on');
        set(handles.YAxis,'Visible','on');
        set(handles.GraphLabelTextBox,'Visible','on');
        set(handles.XAxisGraphLabel,'Visible','on');
        set(handles.YAxisGraphLabel,'Visible','on');
        %%%% FLUORES %%%%
        set(handles.CalibrationTextBox,'Visible','off')
        set(handles.CaliText1,'Visible','off')
        set(handles.CaliA,'Visible','off');
        set(handles.CaliText2,'Visible','off')
        set(handles.CaliB,'Visible','off');
        set(handles.QzText,'Visible','off')
        set(handles.QzEdit,'Visible','off');
        
    case 2
        %%%% ISO %%%%
        set(handles.ColumnTextBox,'Visible','off');
        set(handles.XAxisTextBox,'Visible','off');
        set(handles.XAxis,'Visible','off');
        set(handles.YAxisTextBox,'Visible','off');
        set(handles.YAxis,'Visible','off');
        set(handles.GraphLabelTextBox,'Visible','off');
        set(handles.XAxisGraphLabel,'Visible','off');
        set(handles.YAxisGraphLabel,'Visible','off');
        %%%% FLUORES %%%%
        set(handles.CalibrationTextBox,'Visible','on')
        set(handles.CaliText1,'Visible','on')
        set(handles.CaliA,'Visible','on');
        set(handles.CaliText2,'Visible','on')
        set(handles.CaliB,'Visible','on');
        set(handles.QzText,'Visible','on')
        set(handles.QzEdit,'Visible','on');
        
    case 3
        %%%% ISO %%%%
        set(handles.ColumnTextBox,'Visible','off');
        set(handles.XAxisTextBox,'Visible','off');
        set(handles.XAxis,'Visible','off');
        set(handles.YAxisTextBox,'Visible','off');
        set(handles.YAxis,'Visible','off');
        set(handles.GraphLabelTextBox,'Visible','off');
        set(handles.XAxisGraphLabel,'Visible','off');
        set(handles.YAxisGraphLabel,'Visible','off');
        %%%% FLUORES %%%%
        set(handles.CalibrationTextBox,'Visible','off')
        set(handles.CaliText1,'Visible','off')
        set(handles.CaliA,'Visible','off');
        set(handles.CaliText2,'Visible','off')
        set(handles.CaliB,'Visible','off');
        set(handles.QzText,'Visible','off')
        set(handles.QzEdit,'Visible','off');
        
end

function ConfigCreate_Callback(hObject, eventdata, handles)

%Browse
[CFGFile.file,pathname] = uiputfile('*.cfg','New CFG file');

if isequal(CFGFile.file,0) || isequal(pathname,0)
    return;
end;

if isempty(strfind(CFGFile.file,'.cfg')) 
    strcat(CFGFile.File,'.cfg');
end;

CFGFile.fullfilename = strcat(pathname,CFGFile.file);

switch exist(CFGFile.fullfilename,'file')
    %File does not already exist
    case 0
        ConfigSave(CFGFile.fullfilename,'0','0','0')
end;
set(handles.ConfigFile,'String',['Config File: ' CFGFile.file],'UserData',CFGFile);
set(handles.MainWindow,'UserData',CFGFile);
[CaliA,CaliB,Qz,xa,ya,xal,yal]=ConfigLoad(CFGFile.fullfilename);
textcolor = [0.55    0.55    0.55]; %Grey color for unmodified values

%Isotherm
set(    handles.XAxis, ...
    'String',xa, ...
    'ForegroundColor',textcolor');

set(    handles.YAxis, ...
    'String',ya, ...
    'ForegroundColor',textcolor');

set(    handles.XAxisGraphLabel, ...
    'String',xal, ...
    'ForegroundColor',textcolor');

set(    handles.YAxisGraphLabel, ...
    'String',yal, ...
    'ForegroundColor',textcolor');

%Fluorescence
set(    handles.CaliA, ...
    'String',CaliA, ...
    'TooltipString',CaliA, ...
    'ForegroundColor',textcolor);

set(    handles.CaliB, ...
    'String',CaliB, ...
    'TooltipString',CaliB, ...
    'ForegroundColor',textcolor);

set(    handles.QzEdit, ...
    'String',Qz, ...
    'TooltipString',Qz, ...
    'ForegroundColor',textcolor);

%Reflectivity



 

function ConfigBrowse_Callback(hObject, eventdata, handles)


%Browse
[CFGFile.file,pathname] = uigetfile('*.cfg','Select your config file');

if isequal(CFGFile.file,0) || isequal(pathname,0)
    return;
end;

CFGFile.fullfilename = strcat(pathname,CFGFile.file);
set(handles.ConfigFile,'String',['Config File: ' CFGFile.file],'UserData',CFGFile);
set(handles.MainWindow,'UserData',CFGFile);

%Gets Config Data from file
[CaliA,CaliB,Qz,xa,ya,xal,yal] = ConfigLoad(CFGFile.fullfilename);

textcolor = [0.55    0.55    0.55]; %Grey color for unmodified values

%Isotherm
set(    handles.XAxis, ...
    'String',xa, ...
    'ForegroundColor',textcolor');

set(    handles.YAxis, ...
    'String',ya, ...
    'ForegroundColor',textcolor');

set(    handles.XAxisGraphLabel, ...
    'String',xal, ...
    'ForegroundColor',textcolor');

set(    handles.YAxisGraphLabel, ...
    'String',yal, ...
    'ForegroundColor',textcolor');

%FlUorescence
set(    handles.CaliA, ...
    'String',CaliA, ...
    'TooltipString',CaliA, ...
    'ForegroundColor',textcolor);

set(    handles.CaliB, ...
    'String',CaliB, ...
    'TooltipString',CaliB, ...
    'ForegroundColor',textcolor);

set(    handles.QzEdit, ...
    'String',Qz, ...
    'TooltipString',Qz, ...
    'ForegroundColor',textcolor);

%Reflectivity


set(handles.ConfigSave,'UserData',0) %For checking to see if any values have changed




function ConfigSave_Callback(hObject, eventdata, handles)

textcolor = [0.55    0.55    0.55]; %Grey color for saved values
CFGFile = get(handles.MainWindow,'UserData');

%Isotherm
xa = get(handles.XAxis,'String');
set(handles.XAxis,'ForegroundColor',textcolor);
ya = get(handles.YAxis,'String');
set(handles.YAxis,'ForegroundColor',textcolor);
xal = get(handles.XAxisGraphLabel,'String');
set(handles.XAxisGraphLabel,'ForegroundColor',textcolor);
yal = get(handles.YAxisGraphLabel,'String');
set(handles.YAxisGraphLabel,'ForegroundColor',textcolor);

%Florescence
CaliA = get(handles.CaliA,'String');
set(handles.CaliA,'ForegroundColor',textcolor);
CaliB = get(handles.CaliB,'String');
set(handles.CaliB,'ForegroundColor',textcolor);
Qz = get(handles.QzEdit,'String');
set(handles.QzEdit,'ForegroundColor',textcolor);

%Reflectivity


%Saves to file
ConfigSave(CFGFile.fullfilename,CaliA,CaliB,Qz,xa,ya,xal,yal);
set(hObject,'UserData',0);

function ConfigClose_Callback(hObject, eventdata, handles)

if get(handles.ConfigSave,'UserData') == 1 %For data having changed
    
    result = questdlg(  'Close Configuration Window without saving values?', ...
                        'Configuration Values Unsaved!', ...
                        'Yes', 'No','No');
else
    result = 'Yes';
end;

if strcmp(result,'Yes')
    
    close(handles.Config)
    
end;


function EnergyMin_Callback(hObject, eventdata, handles)
global Flores;
global FloresScanList;

new = str2double(get(hObject,'String'));
old = get(hObject,'UserData');
Max = get(handles.EnergyMax,'UserData');

if isempty(new)
    warndlg('Input is not a number! Please give a new number.','Bad Minimum Value!');
    set(hObject,'String',old);
elseif new >= Max
    warndlg('Minimum value must be smaller than maximum value!','Bad Minimum Value!');
    set(hObject,'String',old);
elseif new <= 0
    warndlg('Energy Minimum range cannot be less than or equal to 0!','Bad Minimum Value!')
    set(hObject,'String',old);
else
    set(hObject,'UserData',new);
    
    if ishandle(handles.flofig) %Only runs if flofig is open
        
        %Gets Energy Min and Max
        EnergyMin = new;
        EnergyMax = Max;
        
        %Gets Config Values and Converts to numbers
        CFGFile = get(handles.MainWindow,'UserData');
        [a,b,~] = ConfigLoad(CFGFile.fullfilename);
        ChCali(1,1) = str2double(a);
        ChCali(1,2) = str2double(b);
        
        %Convert energy range to channel range using the ChCali (channel
        %calibration)
        CHrange(1,1) = nearest((EnergyMin + ChCali(1,2)) / ChCali(1,1));
        CHrange(1,2) = nearest((EnergyMax + ChCali(1,2)) / ChCali(1,1));
        
        %Current imagesc scan
        figure(handles.flofig); %Focus on Flofig
        subplot(2,2,1); %Focus on correct subplot
        ImageScan = get(gca,'UserData');
        scanstr = num2str(ImageScan);
        
        %Gets Data for imagesc
        Qz = Flores{ImageScan}{1,2};
        QzSize = size(Qz);
        channels = Flores{ImageScan}{1,1};
        Energy = (EnergyMin:.1:EnergyMax);
        
        %Plots and labels imagesc
        Flores{ImageScan}{2,1} = imagesc(Qz,Energy,channels(CHrange(1,1):CHrange(1,2),:));
        xlabel('Qz');
        ylabel('Energy');
        title(['Florescence Surface Plot: Scan ', scanstr]);
        set(gca,'YDir','normal','UserData',ImageScan);
        colorbar;
        
        
        %Changes the Energy slice matrix
        for k = 1:size(FloresScanList,2)
            n = str2double(FloresScanList{k});
            
            %Makes the Energy Slice matrix
            channels = Flores{n}{1,1};
            mon = Flores{n}{1,5};
            floEslice = sum(channels(CHrange(1,1):CHrange(1,2),1:QzSize(1,1)))';
            floEslice_norm = floEslice./mon; %Normalizing with respec to monitor
            Flores{n}{1,3} = floEslice;
            floEslice_err = floEslice_norm.*sqrt(1./floEslice + 1./mon);
            
            set(    Flores{n}{2,2}, ...
                'YData',floEslice_norm)
            if get(handles.ErrorbarsCheckBox,'Value')
                set(Flores{n}{2,2}, ...
                    'UData',floEslice_err, ...
                    'LData',floEslice_err);
            end;
            subplot(2,2,2);
            ylim('auto');
        end;
        
    end;
end;

% --- Executes during object creation, after setting all properties.
function EnergyMin_CreateFcn(hObject, eventdata, handles)

set(hObject,'UserData',2);

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function EnergyMax_Callback(hObject, eventdata, handles)
global Flores;
global FloresScanList;

new = str2double(get(hObject,'String'));
old = get(hObject,'UserData');
Min = get(handles.EnergyMin,'UserData');

if isempty(new)
    warndlg('Input is not a number! Please give a new number.','Bad Maximum Value!');
    set(hObject,'String',old);
elseif new <= Min
    warndlg('Maximum value must be larger than minimum value!','Bad Maximum Value!');
    set(hObject,'String',old);
else
    set(hObject,'UserData',new);
    
    if ishandle(handles.flofig) == 1 %Only runs if flofig is open
        
        %Gets Energy Min and Max
        EnergyMax = new;
        EnergyMin = Min;
        
        %Gets Config Values and Converts to numbers
        CFGFile = get(handles.MainWindow,'UserData');
        [a,b,~] = ConfigLoad(CFGFile.fullfilename);
        ChCali(1,1) = str2double(a);
        ChCali(1,2) = str2double(b);
        
        %Convert energy range to channel range using the ChCali (channel
        %calibration)
        CHrange(1,1) = nearest((EnergyMin + ChCali(1,2)) / ChCali(1,1));
        CHrange(1,2) = nearest((EnergyMax + ChCali(1,2)) / ChCali(1,1));
        
        %Current imagesc scan
        figure(handles.flofig); %Focus on Flofig
        subplot(2,2,1); %Focus on correct subplot
        ImageScan = get(gca,'UserData');
        scanstr = num2str(ImageScan);
        
        %Gets Data for imagesc
        Qz = Flores{ImageScan}{1,2};
        QzSize = size(Qz);
        channels = Flores{ImageScan}{1,1};
        Energy = (EnergyMin:.1:EnergyMax);
        
        %Plots and labels imagesc
        Flores{ImageScan}{2,1} = imagesc(Qz,Energy,channels(CHrange(1,1):CHrange(1,2),:));
        xlabel('Qz');
        ylabel('Energy');
        title(['Florescence Surface Plot: Scan ', scanstr]);
        set(gca,'YDir','normal','UserData',ImageScan);
        colorbar;
        
        
        %Changes the Energy slice matrix
        for k = 1:size(FloresScanList,2)
            n = str2double(FloresScanList{k});
            
            %Makes the Energy Slice matrix
            channels = Flores{n}{1,1};
            mon = Flores{n}{1,5};
            floEslice = sum(channels(CHrange(1,1):CHrange(1,2),1:QzSize(1,1)))';
            floEslice_norm = floEslice./mon; %Normalizing with respec to monitor
            Flores{n}{1,3} = floEslice;
            floEslice_err = floEslice_norm.*sqrt(1./floEslice + 1./mon);
            
            set(    Flores{n}{2,2}, ...
                'YData',floEslice_norm);
            if get(handles.ErrorbarsCheckBox,'Value')
                set( Flores{n}{2,2}, ...
                    'UData',floEslice_err, ...
                    'LData',floEslice_err);
            end;
            subplot(2,2,2);
            ylim('auto')
        end;
    end;
    
end;


% --- Executes during object creation, after setting all properties.
function EnergyMax_CreateFcn(hObject, eventdata, handles)

set(hObject,'UserData',8.5);

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%For Deleting Figures
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function RefFig_DeleteFcn(hObject, eventdata, handles)
global Reflec
global ReflecScanList
repl = get(handles.ReplotToggle,'UserData');

Reflec = {};
ReflecScanList = {};
repl.ref = 0;
set(handles.ReplotToggle,'UserData',repl);

if get(handles.ScanTypeMenu,'Value') == 3
    set(handles.ReplotToggle,'Value',repl.ref,'Enable','off');
    set(handles.ScanListBox,'String',{});
end;

function IsoFig_DeleteFcn(hObject, eventdata, handles)

global Isotherms
global IsoScanList
repl = get(handles.ReplotToggle,'UserData');

Isotherms = {};
IsoScanList = {};
repl.iso = 0;
set(handles.ReplotToggle,'UserData',repl);

if get(handles.ScanTypeMenu,'Value') == 1
    set(handles.ReplotToggle,'Value',repl.iso,'Enable','off');
    set(handles.ScanListBox,'String',{});
end;

function FloFig_DeleteFcn(hObject, eventdata, handles)

global Flores
global FloresScanList
repl = get(handles.ReplotToggle,'UserData');

Flores = {};
FloresScanList = {};
repl.flo = 0;
set(handles.ReplotToggle,'UserData',repl);
set(handles.ScanListBox,'UserData',{});

if get(handles.ScanTypeMenu,'Value') == 2
    set(handles.ReplotToggle,'Value',repl.flo,'Enable','off');
    set(handles.ScanListBox,'String',{});
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% --- Executes during object creation, after setting all properties.
function ReplotToggle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ReplotToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

repl.iso = 0;
repl.flo = 0;
repl.ref = 0;

set(hObject,'UserData',repl);

% function FloFig_WindowButtonDownFcn(hObject, eventdata, handles)
% 
% selectiontype = get(hObject,'SelectionType');
% 
% if strcmp(selectiontype,'Alternate');
%     if exists(handles.ANcross1)
%         delete(handles.ANcross1)
%         delete(handles.ANcross2)
%         delete(handles.ANtext)
%     end;    
% else
%             
%     cp = get(gca,'Currentpoint');
%     cp = cp(1,:);
%     disp(cp);
%     
%     
%     handles.ANcross1 = annotation(  'line', ... % Horizontal line
%                                     [cp(1)-.125 cp(1)+.125], ... % X values
%                                     [cp(2) cp(2)], ... % Y values
%                                     'units','inches');
%                                 
%     handles.ANcross2 = annotation(  'line', ... % Vertical line
%                                     [cp(1) cp(1)], ... % X values
%                                     [cp(2)-.125 cp(2)+.125], ... % Y values
%                                     'units','pixels');
%     
%     handles.ANtext = annotation(    'textbox', ... %Annotation Text
%                                     [cp(1)+.125 cp(2)+.125 .25 1], ...
%                                     'String', ['(',cp(1),'),(',cp(2),')'], ...
%                                     'units','pixels');
%         
%     
%     set(hObject,'WindowButtonMotionFcn',{@FloStartDragging})
%     
% end;
% 
% function FloStartDragging(hObject, eventdata, handles)
% 
% cp = get(gca,'Currentpoint');
% 
% set(    handles.ANcross1, ...
%     'x', [cp(1)-15 cp(1)+15], ...
%     'y', [cp(2) cp(2)]);
% 
% set(    handles.ANcross2, ...
%     'x', [cp(1) cp(1)], ...
%     'y', [cp(2)-15 cp(2)+15]);
% 
% set(    handles.ANtext, ...
%     'Postion', [cp(1)+15 cp(2)+15 15 40], ...
%     'String', ['(',cp(1),'),(',cp(2),')']);
% 
% 
% 
% function FloFig_WindowButtonUpFcn(hObject, eventdata, handles)
% 
% set(hObject,'WindowButtonMotionFcn','')


function RefXMin_Callback(hObject, eventdata, handles)
MinNum = str2double(get(hObject,'string'));
MaxNum = get(handles.RefXMax,'UserData');
old = get(hObject,'UserData');

if isempty(MinNum)
    warndlg('Input is not a number! Please give a new number.','Bad Minimum Value!');
    set(hObject,'String',old);
else
    if MinNum >= MaxNum
        warndlg('Minimum value must be smaller than maximum value!','Bad Minimum Value!');
        set(hObject,'String',old);
    else
        set(hObject,'UserData',MinNum);
        
        %Only runs if plot is open
        if ishandle(handles.reffig) == 1
            figure(handles.reffig)
            xlim([MinNum MaxNum]);
        end;
    end;
    
end


% --- Executes during object creation, after setting all properties.
function RefXMin_CreateFcn(hObject, eventdata, handles)

XMin = 0;

set(hObject,'UserData',XMin,'String',XMin);

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function RefXMax_Callback(hObject, eventdata, handles)
MaxNum = str2double(get(hObject,'string'));
MinNum = get(handles.RefXMin,'UserData');
old = get(hObject,'UserData');

if isempty(MaxNum)
    warndlg('Input is not a number! Please give a new number.','Bad Maximum Value!');
    set(hObject,'String',old);
else
    if MinNum >= MaxNum
        warndlg('Maximum value must be larger than minimum value!','Bad Maximum Value!');
        set(hObject,'String',old);
    else
        set(hObject,'UserData',MaxNum);
        
        %Only runs if plot is open
        if ishandle(handles.reffig) == 1
            figure(handles.reffig)
            xlim([MinNum MaxNum]);
        end;
    end;
    
end


% --- Executes during object creation, after setting all properties.
function RefXMax_CreateFcn(hObject, eventdata, handles)

XMax = .7;

set(hObject,'UserData',XMax,'string',XMax);

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function RefYMax_Callback(hObject, eventdata, handles)
MaxNum = str2double(get(hObject,'string'));
MinNum = get(handles.RefYMin,'UserData');
old = get(hObject,'UserData');

switch get(handles.YScale,'Value')
    
    %Linear Scale
    case 0
        switch get(handles.NormalizedCheckBox,'Value')
            %Non-Normalized with Linear
            case 0
                MinNum2 = MinNum.NotNorm.Linear;
                old2 = old.NotNorm.Linear;
                %Normalized with Linear
            case 1
                MinNum2 = MinNum.Norm.Linear;
                old2 = old.Norm.Linear;
        end;
        
    %Log Scale
    case 1
        switch get(handles.NormalizedCheckBox,'Value')
            %Non-Normalized with Log
            case 0
                MinNum2 = MinNum.NotNorm.Log;
                old2 = old.NotNorm.Log;
                %Normalized with Log
            case 1
                MinNum2 = MinNum.Norm.Log;
                old2 = old.Norm.Log;
        end;
end;

if isempty(MaxNum)
    warndlg('Input is not a number! Please give a new number.','Bad Maximum Value!');
    set(hObject,'String',old2);
elseif MinNum2 >= MaxNum
    warndlg('Maximum value must be larger than minimum value!','Bad Maximum Value!');
    set(hObject,'String',old2);
else
    %Sets the MaxNum into new
    new = old;
    switch get(handles.YScale,'Value')
        case 0
            switch get(handles.NormalizedCheckBox,'Value')
                case 0
                    new.NotNorm.Linear = MaxNum;
                case 1
                    new.Norm.Linear = MaxNum;
                    
            end;   
        case 1
            switch get(handles.NormalizedCheckBox,'Value')
                case 0
                    new.NotNorm.Log = MaxNum;
                case 1
                    new.Norm.Log = MaxNum;  
            end;
    end;
    
    set(hObject,'UserData',new)
    
    %Only runs if plot is open
    if ishandle(handles.reffig) == 1
        figure(handles.reffig)
        ylim([MinNum2 MaxNum]);
        
    end;
end;



% --- Executes during object creation, after setting all properties.
function RefYMax_CreateFcn(hObject, eventdata, handles)

YMax.NotNorm.Log = 10e4;
YMax.NotNorm.Linear = 5000;
YMax.Norm.Log = 10e4;
YMax.Norm.Linear = 5000;

set(hObject,'UserData',YMax,'string',YMax.NotNorm.Linear);

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function RefYMin_Callback(hObject, eventdata, handles)
MinNum = str2double(get(hObject,'string'));
MaxNum = get(handles.RefYMax,'UserData');
old = get(hObject,'UserData');

switch get(handles.YScale,'Value')
        case 0
            switch get(handles.NormalizedCheckBox,'Value')
                case 0
                    MaxNum2 = MaxNum.NotNorm.Linear;
                    old2 = old.NotNorm.Linear;
                case 1
                    MaxNum2 = MaxNum.Norm.Linear;
                    old2 = old.NotNorm.Linear;
                    
            end;   
        case 1
            switch get(handles.NormalizedCheckBox,'Value')
                case 0
                    MaxNum2 = MaxNum.NotNorm.Log;
                    old2 = old.NotNorm.Log;
                case 1
                    MaxNum2 = MaxNum.Norm.Log;
                    old2 = old.NotNorm.Log;
            end;
end;

if isempty(MinNum)
    warndlg('Input is not a number! Please give a new number.','Bad Minimum Value!');
    set(hObject,'String',old2);
elseif MinNum >= MaxNum2
    warndlg('Minimum value must be smaller than maximum value!','Bad Minimum Value!');
    set(hObject,'String',old2);    
elseif MinNum <= 0 && get(handles.NormalizedCheckBox,'Value') == 1
    warndlg('Minimum range cannot be less than or equal to 0 on a log scale!','Bad Minimum Value!')
    set(hObject,'String',old2);    
else
    new = old;
    switch get(handles.YScale,'Value')
        case 0
            switch get(handles.NormalizedCheckBox,'Value')
                case 0
                    new.NotNorm.Linear = MinNum;
                case 1
                    new.Norm.Linear = MinNum;
                    
            end;   
        case 1
            switch get(handles.NormalizedCheckBox,'Value')
                case 0
                    new.NotNorm.Log = MinNum;
                case 1
                    new.Norm.Log = MinNum;  
            end;
    end;
    
    set(hObject,'UserData',new)
    
    %Only runs if plot is open
    if ishandle(handles.reffig) == 1
        figure(handles.reffig);
        ylim([MinNum MaxNum2]);
        
    end;
end;


% --- Executes during object creation, after setting all properties.
function RefYMin_CreateFcn(hObject, eventdata, handles)

YMin.NotNorm.Log = 10e-8;
YMin.NotNorm.Linear = 0;
YMin.Norm.Log = 1;
YMin.Norm.Linear = 0;


set(hObject,'UserData',YMin,'string',YMin.NotNorm.Linear);

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FloSBMin_Callback(hObject, eventdata, handles)

old = get(hObject,'UserData');
Max = get(handles.FloSBMax,'UserData');

new = str2double(get(hObject,'String'));

if isempty(new)
    warndlg('Input is not a number! Please give a new number.','Bad Minimum Value!');
    set(hObject,'String',old);
elseif new >= Max
    warndlg('Minimum value must be smaller than maximum value!','Bad Minimum Value!');
    set(hObject,'String',old);
elseif new <= 0
    warndlg('Energy Minimum range cannot be less than or equal to 0!','Bad Minimum Value!')
    set(hObject,'String',old);
else
    set(hObject,'UserData',new);
    
    if ishandle(handles.flofig)
        figure(handles.flofig)
        
        subplot(2,2,3);
        xlim([new Max]);
        
        subplot(2,2,4)
        xlim([new Max]);
    end;
    
end;


% --- Executes during object creation, after setting all properties.
function FloSBMin_CreateFcn(hObject, eventdata, handles)

set(hObject,'UserData',2);

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function FloSBMax_Callback(hObject, eventdata, handles)

old = get(hObject,'UserData');
Min = get(handles.FloSBMin,'UserData');

new = str2double(get(hObject,'String'));

if isempty(new)
    warndlg('Input is not a number! Please give a new number.','Bad Maximum Value!');
    set(hObject,'String',old);
elseif Min >= new
    warndlg('Maximum value must be larger than minimum value!','Bad Maximum Value!');
    set(hObject,'String',old);
else
    set(hObject,'UserData',new);
    
    if ishandle(handles.flofig)
        figure(handles.flofig)
        
        subplot(2,2,3);
        xlim([Min new]);
        
        subplot(2,2,4)
        xlim([Min new]);
        
    end;
    
end;


% --- Executes during object creation, after setting all properties.
function FloSBMax_CreateFcn(hObject, ~, ~) %#ok<DEFNU>

set(hObject,'UserData',8.5);

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function ErrorbarsCheckBox_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
Errorbars.flo = 0;
Errorbars.ref = 0;

set(hObject,'UserData',Errorbars);


% --- Executes during object creation, after setting all properties.
function ScanListTextBox_CreateFcn(hObject, ~, ~) %#ok<DEFNU>

defaultBackground = get(0,'defaultUicontrolBackgroundColor');
set(hObject,'BackgroundColor',defaultBackground)


% --- Executes during object creation, after setting all properties.
function TypeTextBox_CreateFcn(hObject, ~, ~) %#ok<DEFNU>

defaultBackground = get(0,'defaultUicontrolBackgroundColor');
set(hObject,'BackgroundColor',defaultBackground)


% --- Executes during object creation, after setting all properties.
function RangeText2_CreateFcn(hObject, ~, ~) %#ok<DEFNU>

defaultBackground = get(0,'defaultUicontrolBackgroundColor');
set(hObject,'BackgroundColor',defaultBackground)


% --- Executes during object creation, after setting all properties.
function SurfBulkRangeText_CreateFcn(hObject, ~, ~) %#ok<DEFNU>

defaultBackground = get(0,'defaultUicontrolBackgroundColor');
set(hObject,'BackgroundColor',defaultBackground) 


% --- Executes during object creation, after setting all properties.
function RangeText1_CreateFcn(hObject, ~, ~) %#ok<DEFNU>

defaultBackground = get(0,'defaultUicontrolBackgroundColor');
set(hObject,'BackgroundColor',defaultBackground)


% --- Executes during object creation, after setting all properties.
function RefXRange_CreateFcn(hObject, ~, ~) %#ok<DEFNU>

defaultBackground = get(0,'defaultUicontrolBackgroundColor');
set(hObject,'BackgroundColor',defaultBackground)


% --- Executes during object creation, after setting all properties.
function EnergyRangeText_CreateFcn(hObject, ~, ~) %#ok<DEFNU>

defaultBackground = get(0,'defaultUicontrolBackgroundColor');
set(hObject,'BackgroundColor',defaultBackground)


% --- Executes during object creation, after setting all properties.
function RefYRange_CreateFcn(hObject, ~, ~) %#ok<DEFNU>

defaultBackground = get(0,'defaultUicontrolBackgroundColor');
set(hObject,'BackgroundColor',defaultBackground)


% --- Executes during object creation, after setting all properties.
function PlotButton_CreateFcn(hObject, ~, ~) %#ok<DEFNU>

defaultBackground = get(0,'defaultUicontrolBackgroundColor');
set(hObject,'BackgroundColor',defaultBackground)


% --- Executes during object creation, after setting all properties.
function ConfigButton_CreateFcn(hObject, ~, ~) %#ok<DEFNU>

defaultBackground = get(0,'defaultUicontrolBackgroundColor');
set(hObject,'BackgroundColor',defaultBackground)


% --- Executes during object creation, after setting all properties.
function MarkerText_CreateFcn(hObject, ~, ~) %#ok<DEFNU>

defaultBackground = get(0,'defaultUicontrolBackgroundColor');
set(hObject,'BackgroundColor',defaultBackground)


% --- Executes during object creation, after setting all properties.
function LineText_CreateFcn(hObject, ~, ~) %#ok<DEFNU>

defaultBackground = get(0,'defaultUicontrolBackgroundColor');
set(hObject,'BackgroundColor',defaultBackground)


% --------------------------------------------------------------------
function ExportTxt_Callback(hObject, eventdata, handles)
global Isotherms
global IsoScanList
global Flores
global FloresScanList
global Reflec
global ReflecScanList


Dat = get(handles.FileNameBox,'UserData');
listval = get(handles.ScanListBox,'Value');

switch get(handles.ScanTypeMenu,'Value')
    %Isotherm
    case 1
        scanstr = IsoScanList(listval(1));
        scanstr = scanstr{1};
        scannum = str2double(scanstr) ;       
        txt = strcat('_scan',scanstr,'.txt');
        txtfile = strrep(Dat.Name,'.dat',txt);
        area = Isotherms{scannum,2};
        pressure = Isotherms{scannum,3};
        [file,path] = uiputfile('.txt','Choose file name and location',txtfile);
        fullname = strcat(path,file);
        Txt_Save(fullname,area,pressure);
        
    %Flores
    case 2
        scanstr = FloresScanList(listval(1));
        scanstr = scanstr{1};
        scannum = str2double(scanstr);
        txt = strcat('_scan',scanstr,'.txt');
        txtfile = strrep(Dat.Name,'.dat',txt);
        Qz = Flores{scannum}{1,2};
        floEslice = Flores{scannum}{1,3};
        err = sqrt(floEslice);
        [file,path] = uiputfile('.txt','Choose file name and location',txtfile);
        fullname = strcat(path,file);
        Txt_Save(fullname,Qz,floEslice,err);
        
    %Reflec
    case 3
        scanstr = ReflecScanList(listval(1));
        scanstr = scanstr{1};
        scannum = str2double(scanstr);
        txt = strcat('_scan',scanstr,'.txt');
        txtfile = strrep(Dat.Name,'.dat',txt);
        Data = Reflec{scannum,2};
        Qz = Data(:,1);
        Ref = Data(:,2);
        Ref_err = Data(:,3);
        Rrf = Data(:,2)./Data(:,5);
        Rrf_err = Data(:,3)./Data(:,5);
        [file,path] = uiputfile('.txt','Choose file name and location',txtfile);
        fullname = strcat(path,file);
        Txt_Save(fullname, Qz, Ref, Ref_err, Rrf, Rrf_err);
end;


% --- Executes on key press with focus on ScanListBox and none of its controls.
function ScanListBox_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to ScanListBox (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over ScanListBox.
function ScanListBox_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to ScanListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function RefGen_Callback(hObject, eventdata, handles)
global Reflec
global ReflecScanList

listval = get(handles.ScanListBox,'Value');
scanstr = ReflecScanList(listval(1));
scanstr = scanstr{1};
scannum = str2double(scanstr);
RefData = Reflec{scannum,2};
Dat = get(handles.FileNameBox,'UserData');
filename = strrep(Dat.Name,'.dat','_');
filename = strcat(filename,scanstr,'.ref');
fullfilename = strrep(Dat.Full,Dat.Name,filename);
[file,path] = uiputfile('.ref','Choose file name and location',fullfilename);
fullfilename = strcat(path,file);
Ref_Save(RefData,scannum,fullfilename)

% --------------------------------------------------------------------
function RrfGen_Callback(hObject, eventdata, handles)
global Reflec
global ReflecScanList

listval = get(handles.ScanListBox,'Value');
scanstr = ReflecScanList(listval(1));
scanstr = scanstr{1};
scannum = str2double(scanstr);
RefData = Reflec{scannum,2};
Dat = get(handles.FileNameBox,'UserData');
filename = strrep(Dat.Name,'.dat','_');
filename = strcat(filename,scanstr,'.rrf');
fullfilename = strrep(Dat.Full,Dat.Name,filename);
[file,path] = uiputfile('.rrf','Choose file name and location',fullfilename);
fullfilename = strcat(path,file);
rrfgen(fullfilename,RefData)


% --------------------------------------------------------------------
function MergeFlo_Callback(hObject, eventdata, handles)
global Flores
global FloresScanList
MergedScans = get(handles.ScanListBox,'UserData');
listval = get(handles.ScanListBox,'Value');

scannum = zeros(size(listval));
for k=1:length(listval)
    scannum(k) = str2double(FloresScanList{listval(k)});
end

merged = Flores{scannum(1)}{1,1};
mon = Flores{scannum(1)}{1,5};
qz = Flores{scannum(1)}{1,2}; %Qz

%Merges s1 through s4
for k = 2:length(scannum)
    merged = merged + Flores{scannum(k)}{1,1};
    mon = mon + Flores{scannum(k)}{1,5};
end;

merged = double(merged);
mon = double(mon);

MergedScans{scannum(1)}{1} = merged;
MergedScans{scannum(1)}{2} = mon;
MergedScans{scannum(1)}{3} = qz;
MergedScans{scannum(1)}{4} = scannum;

set(handles.ScanListBox,'UserData',MergedScans);

newstr = strcat('M',num2str(scannum(1)));


% --- Executes during object deletion, before destroying properties.
function ScanListBox_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to ScanListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
