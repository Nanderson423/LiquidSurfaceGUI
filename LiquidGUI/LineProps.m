%Gets all the current settings for Line/Markers and outputs them lineprops
lineprops{1} = get(handles.CurrentColor,'BackgroundColor');

%Line Style
switch get(handles.LineStyleMenu,'Value')
    case 1
        lineprops{2} = '-';
    case 2
        lineprops{2} = '--';
    case 3
        lineprops{2} = ':';
    case 4
        lineprops{2} = '-.';
    case 5
        lineprops{2} = 'none';
end

%Line Font
switch get(handles.LineFontMenu,'Value');
    case 1
        lineprops{3} = 1;
    case 2
        lineprops{3} = 2;
    case 3
        lineprops{3} = 3;
    case 4
        lineprops{3} = 4;
    case 5
        lineprops{3} = 6;
    case 6
        lineprops{3} = 8;
    case 7
        lineprops{3} = 12;
end;

%Marker Style
switch get(handles.MarkerStyleMenu,'Value');
    case 1
        lineprops{4} = 'none';
    case 2
        lineprops{4} = '+';
    case 3
        lineprops{4} = 'o';
    case 4
        lineprops{4} = '*';
    case 5
        lineprops{4} = 'x';
    case 6
        lineprops{4} = 's';
    case 7
        lineprops{4} = 'd';
    case 8
        lineprops{4} = '^';
    case 9
        lineprops{4} = 'v';
    case 10
        lineprops{4} = '>';
    case 11
        lineprops{4} = '<';
    case 12
        lineprops{4} = 'p';
    case 13
        lineprops{4} = 'h';
end;

%Marker Font
switch get(handles.MarkerFontMenu,'Value');
    case 1
        lineprops{5} = 4;
    case 2
        lineprops{5} = 6;
    case 3
        lineprops{5} = 8;
    case 4
        lineprops{5} = 12;
    case 5
        lineprops{5} = 16;
    case 6
        lineprops{5} = 20;
end;
