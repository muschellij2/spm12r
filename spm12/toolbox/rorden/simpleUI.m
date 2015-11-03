function varargout = simpleUI(varargin)
% simpleUI Example for creating GUIs with menus, toolbar, plots without GUIDE
% based on AXESMENUTOOLBAR http://www.mathworks.com/help/matlab/creating_guis/gui-with-axes-menu-and-toolbar.html
% Adds ability to easily call functions from the command line
% Example usage:
% simpleUI %launch program with defaults
% simpleUI('setPlotIndex',4) %load 'membrane' plot
% simpleUI('copyBitmap') %copy image to clipboard
% simpleUI('saveBitmap',{'myPicture.png'}); %save image to disk
% simpleUI('changeAboutString',{'my new version string'});
mOutputArgs = {}; % Variable for storing output when GUI returns
h = findall(0,'tag',mfilename); %run as singleton http://www.mathworks.com/support/solutions/en/data/1-77HLIL/?product=SL&solution=1-77HLIL
if (isempty(h)) % new instance
    h = makeGUI; %set up user interface
else % instance already running
 figure(h); %make active figure
end;
if (nargin) && (ischar(varargin{1})) 
 f = str2func(varargin{1});
 f(guidata(h),varargin{2:nargin})
end

% --- Save screenshot as bitmap image
function saveBitmap(v,varargin)
%simpleUI('saveBitmap',{'myPicture.png'});
if (length(varargin) < 1), return; end;
filename = char(varargin{1});
%saveas(v.hPlotAxes, filename,'png'); %<- save as 150dpi
print (v.hMainFigure, '-r600', '-dpng', filename); %<- save as 600dpi, '-noui'
%end saveBitmap()

% --- other functions demonstrate how to read variables, this function demonstrates how changes the functions' variables
function changeAboutString(v,varargin)
%simpleUI('changeAboutString',{'my new version string'});
if (length(varargin) < 1), return; end;
v.AboutVersionString = char(varargin{1});
guidata(v.hMainFigure,v);% <- REQUIRED to save changed settings
%end changeAboutString()

% --- Copy screenshot to clipboard
function copyBitmap(v)
%simpleUI('copyBitmap')
editmenufcn(v.hMainFigure,'EditCopyFigure');
%end copyBitmap()

% --- select displayed plaot
function setPlotIndex(v,varargin)
%simpleUI('setPlotIndex',5)
if (nargin < 1), return; end;
args = cell2mat(varargin);
set(v.hPlotsPopupmenu,'Value',args(1));
updatePlot(v);
%end setPlotIndex()

% --- Declare and create all the UI objects
function [vFig] =  makeGUI
%types of graphs
sz = [680 480]; % figure width, height in pixels
buttonHeight = 30;
border = 30; %pixels space around edges of figure
screensize = get(0,'ScreenSize');
margin = [ceil((screensize(3)-sz(1))/2) ceil((screensize(4)-sz(2))/2)];
v.hMainFigure = figure('Resize','off','MenuBar','none','Toolbar','none','HandleVisibility','on', ...
'DeleteFcn',@DeleteFigure_Callback,'Tag', mfilename,'Name', mfilename, 'NumberTitle','off', ...
 'position',[margin(1), margin(2), sz(1), sz(2)],'Color', get(0, 'defaultuicontrolbackgroundcolor'));
v.mPlotTypes = {'plot(rand(5))', @(a)plot(a, rand(5));
 'plot(sin(1:0.01:25))', @(a)plot(a, sin(1:0.01:25));
 'bar(1:.5:10)', @(a)bar(a,1:.5:10); 
 'plot(membrane)', @(a)plot(a, membrane);
 'surf(peaks)', @(a)surf(a, peaks)};
%user interface objects
v.hPlotAxes = axes('Parent', v.hMainFigure,'Units', 'pixels', ...
 'HandleVisibility','on','Position',[border (border) (sz(1)-2*border) (sz(2)-border-buttonHeight)]);
v.hPlotsPopupmenu= uicontrol(... % list of available types of plot
 'Parent', v.hMainFigure,'Units','pixels','Position',[0 (sz(2)-buttonHeight) 120 buttonHeight],...
 'HandleVisibility','callback','Callback', @plotsPopup_Callback, ...
 'String',v.mPlotTypes(:,1),'Style','popupmenu');
%menu items
v.hFileMenu = uimenu('Parent',v.hMainFigure,'HandleVisibility','callback','Label','File');
v.hSaveMenuitem = uimenu('Parent',v.hFileMenu,'Label','Save bitmap','HandleVisibility','callback', ...
 'Callback', @saveBitmap_Callback);
v.hEditMenu = uimenu('Parent',v.hMainFigure,'HandleVisibility','callback','Label','Edit');
v.hCopyMenuitem = uimenu('Parent',v.hEditMenu,...
 'Label','Copy','HandleVisibility','callback','Callback', @copyBitmap_Callback);
v.hToolbarMenu = uimenu('Parent',v.hEditMenu,'Label','Show/hide toolbar','HandleVisibility','callback','Callback', @ToolbarMenu_Callback);
v.hHelpMenu = uimenu('Parent',v.hMainFigure,'HandleVisibility','callback','Label','Help');
v.hAboutMenu = uimenu('Parent',v.hHelpMenu,'Label','About','HandleVisibility','callback','Callback', @AboutMenu_Callback);
v.AboutVersionString = 'SimpleUI version 7/2013';
%draw initial figure
vFig = v.hMainFigure;
guidata(v.hMainFigure,v);%store settings
updatePlot(v); 
%end makeGUI()

% --- display version
function AboutMenu_Callback(hObject, eventdata)
v = guidata(hObject)
msgbox(v.AboutVersionString,'About');
%end AboutMenu_Callback()

% --- Show/Hide Figure Toolbar
function ToolbarMenu_Callback(hObject, eventdata)
if strcmpi(get(gcf, 'Toolbar'),'none')
    set(gcf,  'Toolbar', 'figure');
else
    set(gcf,  'Toolbar', 'none');
end
%end ToolbarMenu_Callback()

function plotsPopup_Callback(hObject, eventdata)
updatePlot(guidata(hObject));
%end plotsPopupUI()

% -- save screenshot to selected filename
function saveBitmap_Callback(hObject, eventdata)
%user requested to specify filename so image can be saved as bitmap
[file,path] = uiputfile('*.png','Save image as');
if isequal(file,0), return; end;
saveBitmap(guidata(hObject),[path file]);
%end saveBitmapUI

% --- copy bitmap to clipboard
function copyBitmap_Callback(hObject, eventdata)
copyBitmap (guidata(hObject));
%end copyBitmapUI()

% --- executed when the form closes
function DeleteFigure_Callback(~, ~)
disp('goodbye'); %nothing to do, variables automatically released
%end DeleteFigure_Callback

% --- draw the graph
function updatePlot(v)
v.mPlotTypes{1, 2}(v.hPlotAxes);
v.mPlotTypes{get(v.hPlotsPopupmenu, 'Value'), 2}(v.hPlotAxes);
%end updatePlot()