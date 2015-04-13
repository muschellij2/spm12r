function varargout = rest_DegreeCentrality_gui(varargin)
% Created by Sandy Wang
%
% REST_DEGREECENTRALITY_GUI MATLAB code for rest_DegreeCentrality_gui.fig
%      REST_DEGREECENTRALITY_GUI, by itself, creates a new REST_DEGREECENTRALITY_GUI or raises the existing
%      singleton*.
%
%      H = REST_DEGREECENTRALITY_GUI returns the handle to a new REST_DEGREECENTRALITY_GUI or the handle to
%      the existing singleton*.
%
%      REST_DEGREECENTRALITY_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in REST_DEGREECENTRALITY_GUI.M with the given input arguments.
%
%      REST_DEGREECENTRALITY_GUI('Property','Value',...) creates a new REST_DEGREECENTRALITY_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before rest_DegreeCentrality_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to rest_DegreeCentrality_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help rest_DegreeCentrality_gui

% Last Modified by GUIDE v2.5 04-Sep-2012 23:00:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @rest_DegreeCentrality_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @rest_DegreeCentrality_gui_OutputFcn, ...
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


% --- Executes just before rest_DegreeCentrality_gui is made visible.
function rest_DegreeCentrality_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to rest_DegreeCentrality_gui (see VARARGIN)

%Create image
%if ~isfield(handles , 'brain_icon')
%    set(handles.image_axes,...
%                        'Box' , 'On',...
%                        'Units' , 'Pixel',...
%                        'YDir' , 'normal',...
%                        'XTickLabel' , [],...
%                        'XTick' , [],...
%                        'YTickLabel' , [],...
%                        'YTick' , [],...
%                        'DataAspectRatio' , [1,1,1]);%
%
%    handles.brain_icon=image('Tag' , 'brain_icon' , 'Parent' , handles.image_axes);
%
%    dc_icon=imread(fullfile(rest_misc('WhereIsREST') , 'DegreeCentrality.jpg'));
%    %dc_icon=imresize(dc_icon,[200 500]);
%
%    set(handles.image_axes , 'XLim' , [1 size(dc_icon , 2)],...
%                        'YLim' , [1 size(dc_icon ,1)]);
%
%    set(handles.brain_icon , 'CData' , (dc_icon) , 'HitTest' , 'Off');
%end

if ~isfield(handles , 'data_list')
    handles.data_list='';
end

%if ~isfield(handles , 'logo_icon')
%    set(handles.power_axes,...
%                        'Box' , 'On',...
%                        'Units' , 'Pixel',...
%                        'YDir' , 'normal',...
%                        'XTickLabel' , [],...
%                        'XTick' , [],...
%                        'YTickLabel' , [],...
%                        'YTick' , [],...
%                        'DataAspectRatio' , [1,1,1]);
%
%    handles.logo_icon=image('Tag' , 'logo_icon' , 'Parent' , handles.power_axes);
%
%    logo_icon=imread(fullfile(rest_misc('WhereIsREST') , 'rest_web.jpg'));
%    logo_icon = flipdim(logo_icon,1);
%   %logo_icon = flipdim(logo_icon,2);
%    logo_icon=imresize(logo_icon,[460 600]);
%
%    set(handles.power_axes , 'XLim' , [1 size(dc_icon , 2)],...
%                        'YLim' , [1 size(dc_icon ,1)]);
%
%    set(handles.logo_icon , 'CData' , (logo_icon) , 'HitTest' , 'Off');
%end

if ~isfield(handles , 'data_list')
    handles.data_list='';
end

% Choose default command line output for rest_DegreeCentrality_gui
handles.output = hObject;

%Create list box menu
handles.hContextMenu=uicontextmenu;
set(handles.dir_listbox , 'UIContextMenu' , handles.hContextMenu);
uimenu(handles.hContextMenu , 'Label' , 'Add a directory' ,...
    'Callback' , get(handles.dir_pushbutton, 'Callback'));
uimenu(handles.hContextMenu , 'Label' , 'Remove selected directory',...
    'Callback' , 'rest_DegreeCentrality_gui(''delete_selecteddata'',gcbo,[], guidata(gcbo))');
uimenu(handles.hContextMenu , 'Label' , 'Add recursively all sub-folders of a directory',...
    'Callback', 'rest_DegreeCentrality_gui(''recursive_add_directory'',gcbo,[], guidata(gcbo))');
uimenu(handles.hContextMenu , 'Label' , '==========================');
uimenu(handles.hContextMenu , 'Label' , 'Remove all data directories',...
    'Callback', 'rest_DegreeCentrality_gui(''clear_datalist'',gcbo,[], guidata(gcbo))');
uimenu(handles.hContextMenu , 'Label' , '==========================');
uimenu(handles.hContextMenu , 'Label' , sprintf('Power Spectrum'),...
    'Callback' , get(handles.timecourse_pushbutton , 'Callback'));
    %'Callback', 'rest_DegreeCentrality_gui(''power_spectrum'',gcbo,[], guidata(gcbo))');

%Create Utilities Menu
set(handles.utilities_popupmenu , 'String',...
    {'Degree Centrality',...
    'Amplitude of Low Frequency Fluctuation',...
    'Fractional Amplitude of Low Frequency Fluctuation',...
    'Regional Homogeneity',...
    'Functional Connectivity',...
    'VMHC',...
    '=================================',...
    'Slice Viewer'},...
    'Value' , 1 ,...
    'Callback' , get(handles.utilities_popupmenu, 'Callback'));

set(handles.weigh_entry , 'String' , pwd);
set(handles.bin_entry , 'String' , pwd);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes rest_DegreeCentrality_gui wait for user response (see UIRESUME)
% uiwait(handles.fig_DC);


% --- Outputs from this function are returned to the command line.
function varargout = rest_DegreeCentrality_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
varargout{2} = handles;


% --- Executes on button press in detrend_checkbox.
function detrend_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to detrend_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.detrend_checkbox , 'Value')
    if ~get(handles.bandpass_checkbox , 'Value')
        set(handles.save_checkbox , 'Enable' , 'On');
    end
else
    if ~get(handles.bandpass_checkbox , 'Value')
        set(handles.save_checkbox , 'Enable' , 'Off');
    end
end

if isfield(handles , 'position')
   create_timecourse(hObject , [] , handles); 
end
% Hint: get(hObject,'Value') returns toggle state of detrend_checkbox


% --- Executes on button press in bandpass_checkbox.
function bandpass_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to bandpass_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Judge whether dataset need be filtered or not Sandy 120814
if get(handles.bandpass_checkbox , 'Value')
    set(handles.TR_entry , 'Enable' , 'On');
    set(handles.lowpass_entry , 'Enable' , 'On');
    set(handles.highpass_entry , 'Enable' , 'On');
    if ~get(handles.detrend_checkbox , 'Value')
        set(handles.save_checkbox , 'Enable' , 'On');
    end
else
    set(handles.TR_entry , 'Enable' , 'Off');
    set(handles.lowpass_entry , 'Enable' , 'Off');
    set(handles.highpass_entry , 'Enable' , 'Off');  
    if ~get(handles.detrend_checkbox , 'Value')
        set(handles.save_checkbox , 'Enable' , 'Off');
    end
end
% Hint: get(hObject,'Value') returns toggle state of bandpass_checkbox



function TR_entry_Callback(hObject, eventdata, handles)
% hObject    handle to TR_entry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles , 'position')
   create_timecourse(hObject , [] , handles); 
end
% Hints: get(hObject,'String') returns contents of TR_entry as text
%        str2double(get(hObject,'String')) returns contents of TR_entry as a double


% --- Executes during object creation, after setting all properties.
function TR_entry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TR_entry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lowpass_entry_Callback(hObject, eventdata, handles)
% hObject    handle to lowpass_entry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles , 'position')
   create_timecourse(hObject , [] , handles); 
end
% Hints: get(hObject,'String') returns contents of lowpass_entry as text
%        str2double(get(hObject,'String')) returns contents of lowpass_entry as a double


% --- Executes during object creation, after setting all properties.
function lowpass_entry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lowpass_entry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function highpass_entry_Callback(hObject, eventdata, handles)
% hObject    handle to highpass_entry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles , 'position')
   create_timecourse(hObject , [] , handles); 
end
% Hints: get(hObject,'String') returns contents of highpass_entry as text
%        str2double(get(hObject,'String')) returns contents of highpass_entry as a double

% --- Executes during object creation, after setting all properties.
function highpass_entry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to highpass_entry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in save_checkbox.
function save_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to save_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of save_checkbox

% --- Executes on button press in Default_radiobutton.
function Default_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to Default_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.Default_radiobutton , 'Value')
    set(handles.nomask_radiobutton , 'Enable' , 'On' ,'Value' , 0);
    set(handles.Default_radiobutton, 'Enable', 'inactive');
    set(handles.mask_entry , 'Enable' , 'Off' , 'String' , 'Default Mask');
end
% Hint: get(hObject,'Value') returns toggle state of Default_radiobutton


% --- Executes on button press in nomask_radiobutton.
function nomask_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to nomask_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.nomask_radiobutton , 'Value')
    set(handles.Default_radiobutton , 'Enable' , 'On' , 'Value' , 0);
    set(handles.nomask_radiobutton  , 'Enable', 'inactive');
    set(handles.mask_entry , 'Enable' , 'Off' , 'String' , 'Don''t use any mask');
end
% Hint: get(hObject,'Value') returns toggle state of nomask_radiobutton


% --- Executes on button press in mask_pushbutton.
function mask_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to mask_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    [RESTPath , Filename , extn]=fileparts(which('rest.m'));
    RESTMask=[RESTPath , filesep , 'mask'];
    current_directory=pwd;
    cd(RESTMask);
    [mask_filename , mask_pathname]=uigetfile({'*.img;*.nii;*.nii.gz','Brain Image Files (*.img;*.nii;*.nii.gz)';'*.*', 'All Files (*.*)';}, ...
        'Pick one mask file');
    cd(current_directory);
    mask_entry=[mask_pathname,mask_filename];
    if ischar(mask_entry)
        set(handles.Default_radiobutton , 'Enable' , 'On' , 'Value' , 0);
        set(handles.nomask_radiobutton  , 'Enable' , 'On' , 'Value' , 0);
        set(handles.mask_entry , 'String' , mask_entry);
        if strcmp(upper(get(handles.mask_entry , 'Enable')) , 'OFF')
            set(handles.mask_entry , 'Enable' , 'On');
        end
    end

function mask_entry_Callback(hObject, eventdata, handles)
% hObject    handle to mask_entry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mask_entry as text
%        str2double(get(hObject,'String')) returns contents of mask_entry as a double


% --- Executes during object creation, after setting all properties.
function mask_entry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mask_entry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in weigh_pushbutton.
function weigh_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to weigh_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
output_dir=pwd;
if ~strcmp(get(handles.weigh_entry , 'String') , pwd) || ~strcmp(get(handles.bin_entry , 'String') , pwd)
    output_dir=get(handles.bin_entry , 'String');
end
weigh_dir=uigetdir(output_dir ,'Select a directory to save weighted DegreeCentrality maps');
if ischar(weigh_dir)
    set(handles.weigh_entry , 'String' , weigh_dir);
end

% --- Executes on button press in bin_pushbutton.
function bin_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to bin_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
output_dir=pwd;
if ~strcmp(get(handles.weigh_entry , 'String') , pwd) || ~strcmp(get(handles.bin_entry , 'String') , pwd)
    output_dir=get(handles.weigh_entry , 'String');
end
    bin_dir=uigetdir(output_dir,'Select a diretory to save binarize DegreeCentrality maps');
if ischar(bin_dir)
    set(handles.bin_entry , 'String' , bin_dir);
end



function weigh_entry_Callback(hObject, eventdata, handles)
% hObject    handle to weigh_entry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of weigh_entry as text
%        str2double(get(hObject,'String')) returns contents of weigh_entry as a double


% --- Executes during object creation, after setting all properties.
function weigh_entry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to weigh_entry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function bin_entry_Callback(hObject, eventdata, handles)
% hObject    handle to bin_entry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bin_entry as text
%        str2double(get(hObject,'String')) returns contents of bin_entry as a double


% --- Executes during object creation, after setting all properties.
function bin_entry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bin_entry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in dir_listbox.
function dir_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to dir_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns dir_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from dir_listbox


% --- Executes during object creation, after setting all properties.
function dir_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dir_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in normalize_checkbox.
function normalize_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to normalize_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.normalize_checkbox , 'Value')
    set(handles.divide_checkbox , 'Value' , 0);
end
% Hint: get(hObject,'Value') returns toggle state of normalize_checkbox


% --- Executes on button press in divide_checkbox.
function divide_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to divide_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.divide_checkbox , 'Value')
    set(handles.normalize_checkbox , 'Value' , 0);
end
% Hint: get(hObject,'Value') returns toggle state of divide_checkbox


function r_entry_Callback(hObject, eventdata, handles)
% hObject    handle to r_entry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of r_entry as text
%        str2double(get(hObject,'String')) returns contents of r_entry as a double


% --- Executes during object creation, after setting all properties.
function r_entry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to r_entry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function prefix_entry_Callback(hObject, eventdata, handles)
% hObject    handle to prefix_entry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of prefix_entry as text
%        str2double(get(hObject,'String')) returns contents of prefix_entry as a double


% --- Executes during object creation, after setting all properties.
function prefix_entry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to prefix_entry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in dir_pushbutton.
function dir_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to dir_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data_dir=uigetdir(pwd , 'Please select the data diretory to compute Degree Centrality map');
handles=select_directory(handles,data_dir);
guidata(hObject,handles);

function result=select_directory(AHandle,data_dir)
if ischar(data_dir)
    if rest_misc('GetMatlabVersion')>=7.3
        data_dir=strtrim(data_dir);
    end
    %if ~isfield(AHandle,'data_list')
    %    AHandle.data_list='';
    %end
    AHandle.data_list=[AHandle.data_list ; {0 , data_dir}];
    DirList_count=size(AHandle.data_list,1);
    theVolumnCount=rest_CheckDataDir(AHandle.data_list{DirList_count , 2});
    if theVolumnCount<=0
        fprintf('There is no data or non-data files in this directory:\n%s\nPlease re-select\n',data_dir);
        errordlg(sprintf('There is no data or non-data files in this directory:\n%s\nPlease re-select\n',data_dir));
        AHandle.data_list(DirList_count,:)=[];
    else
        AHandle.data_list{DirList_count,1}=theVolumnCount;
    end
    if size(AHandle.data_list,1)
        data_listtext=GetInputDirDisplayList(AHandle);
        set(AHandle.dir_listbox , 'String' , data_listtext ,...
            'Value' , DirList_count);
    end
    result=AHandle;
else
    result=AHandle;
end

% --- Executes on button press in timecourse_pushbutton.
function timecourse_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to timecourse_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    show_timecourse(hObject , [] , handles);
%guidata(hObject , handles);
%%


%%
function disable_button(handles , tag)
    tag=upper(tag);
    if strcmp(tag , 'OFF')
        set(handles.load_tag , 'Visible' , 'ON');
    else
        set(handles.load_tag , 'Visible' , 'OFF');
    end
    set(handles.detrend_checkbox      , 'enable' , tag);
    set(handles.bandpass_checkbox     , 'enable' , tag);
    if get(handles.bandpass_checkbox ,     'Value' ) 
        set(handles.TR_entry          , 'enable' , tag);
        set(handles.lowpass_entry     , 'enable' , tag);
        set(handles.highpass_entry    , 'enable' , tag);
    end
    if get(handles.detrend_checkbox , 'Value') ...
        || get(handles.bandpass_checkbox , 'Value')
        set(handles.save_checkbox     , 'enable' , tag);
    end
    set(handles.mask_pushbutton       , 'enable' , tag);
    set(handles.Default_radiobutton   , 'enable' , tag);
    set(handles.nomask_radiobutton   , 'enable' , tag);
    if ~strcmp( get(handles.mask_entry , 'String') , 'Default Mask')...
            && ~strcmp( get(handles.mask_entry , 'String') , 'Don''t use any mask')
        set(handles.mask_entry, 'enable' , tag);    
    end
    set(handles.weigh_pushbutton      , 'enable' , tag);
    set(handles.weigh_entry           , 'enable' , tag);
    set(handles.bin_pushbutton        , 'enable' , tag);
    set(handles.bin_entry             , 'enable' , tag);
    set(handles.r_entry               , 'enable' , tag);
    set(handles.r_entry , 'BackgroundColor' , [0.04 0.52 0.78]);
    if strcmp(tag , 'OFF')
        set(handles.dir_listbox           , 'enable' , 'inactive');
    else
        set(handles.dir_listbox           , 'enable' , 'ON');
    end
    set(handles.timecourse_pushbutton , 'enable' , tag);
    set(handles.dir_pushbutton        , 'enable' , tag);
    set(handles.utilities_popupmenu   , 'enable' , tag);
    set(handles.normalize_checkbox       , 'enable' , tag);
    set(handles.divide_checkbox       , 'enable' , tag);
    set(handles.run_pushbutton        , 'enable' , tag);

function recursive_add_directory(hObject , eventdata , handles)
    if prod(size(handles.data_list))>0 && size(handles.data_list,1)>0
        theDir = handles.data_list{1,1};
    else
        theDir = pwd;
    end
    
    theDir = uigetdir(pwd ,...
        ['Please select the parent data directory of many sub-folders ',...
        'containing EPI data to compute degree centrality map: ']);
    if ischar(theDir)
        set(handles.dir_listbox , 'BackgroundColor' , 'Green');
        theFileList = dir(theDir);
        
        disable_button(handles , 'Off')
        for x=1:size(theFileList,1)
            if theFileList(x).isdir && ~strcmp(theFileList(x).name,'.')...
                && ~strcmp(theFileList(x).name,'..')
                
                handles=select_directory(handles ,...
                    [theDir , filesep , theFileList(x).name]);
                pause(0.01);
            end
        end
        disable_button(handles , 'On');
        set(handles.dir_listbox , 'BackgroundColor' , 'White');
    end
    guidata(hObject, handles);
    
%% check the Data dir to make sure that there are only {hdr,img}, nii, nii.gz
function Result=GetInputDirDisplayList(handles)
	Result ={};
	for x=1:size(handles.data_list, 1)
		Result =[Result ,...
            {sprintf('%d# %s',handles.data_list{x, 1},handles.data_list{x, 2})}];
    end
    
function delete_selecteddata(hObject , eventdata , handles)
    theIndex = get(handles.dir_listbox , 'Value');
    if prod(size(handles.data_list))==0 || size(handles.data_list ,1 )==0 ...
            || theIndex > size(handles.data_list , 1)
        return;
    end
    theDir=handles.data_list{theIndex , 2};
    theVolumnCount=handles.data_list{theIndex , 1};
    tmpMsg=sprintf('Delete\n\t %s \nVolumn Count : %d ?' , theDir , theVolumnCount);
    if strcmp(questdlg(tmpMsg , 'Delete confirmation') , 'Yes')
        if theIndex>1
            set(handles.dir_listbox , 'Value' , theIndex-1);
        end
        handles.data_list(theIndex , :)=[];
        if size(handles.data_list , 1)==0
            handles.data_list={};
        end
        data_listtext=GetInputDirDisplayList(handles);
        set(handles.dir_listbox , 'String' , data_listtext);
        guidata(hObject , handles);
    end    
    
function clear_datalist(hObject , eventdata , handles)
    if prod(size(handles.data_list))==0 || size(handles.data_list , 1)==0
        return
    end
    tmpMsg=sprintf('Attention!\nDelete all data directories?');
    if strcmpi(questdlg(tmpMsg , 'Clear confirmation') , 'Yes')
        handles.data_list='';
        set(handles.dir_listbox , 'String' , handles.data_list);
        guidata(hObject , handles);
    end
    
function show_timecourse(hObject , eventdata , handles)
    if prod(size(handles.data_list))==0 || size(handles.data_list , 1)==0
            %Check Input Directory
        warndlg('Please select a data directory to show!');
        check_warning(handles.dir_listbox);
        return;
    end
    
    %Check band and TR
    if ~get(handles.bandpass_checkbox , 'Value')
        warndlg('Please set TR and Band');
        set(handles.bandpass_checkbox , 'Value' , 1);
        
        set(handles.TR_entry , 'String' , '2' , 'Enable' , 'On');
        set(handles.lowpass_entry  , 'String' , '0.01' , 'Enable' , 'On');
        set(handles.highpass_entry , 'String' , '0.08' , 'Enable' , 'On');
        return;
    end
    
    if isempty(get(handles.TR_entry , 'String'))
            check_warning(handles.TR_entry);
        return;
    end
    
    if isempty(get(handles.lowpass_entry , 'String'))
        check_warning(handles.lowpass_entry);
        return;
    end

    if isempty(get(handles.highpass_entry , 'String'))
        check_warning(handles.highpass_entry);
        return;
    end
        
    selected_value=get(handles.dir_listbox , 'Value');
    selected_dir=handles.data_list{selected_value,2};
    dir_struct=dir(selected_dir);
    
    disable_button(handles , 'Off');
    pause(0.01);
    [AllVolume VoxelSize FileList Header]=rest_to4d(selected_dir);
    disable_button(handles , 'On');
        
    handles.Volume=AllVolume;
    guidata(hObject , handles);
    try
        Viewer=rest_sliceviewer('ShowImage' , [selected_dir , filesep, dir_struct(3).name]);
        voxel_position=rest_sliceviewer('GetPosition' , Viewer);
        handles.position=voxel_position;
        create_timecourse(hObject , [] , handles);
        %Update the Callback
        theCallback = '';
        cmdBrainMap = sprintf('voxel_position=rest_sliceviewer(''GetPosition'' , %g);' , Viewer);
        cmdHandle   = sprintf('[AObject , Ahandle ]=rest_DegreeCentrality_gui;');
        cmdPosition = sprintf('Ahandle.position=voxel_position;');
        cmdUpdateTimeCourse = 'rest_DegreeCentrality_gui(''create_timecourse'', AObject , [], Ahandle);';
        theCallback = sprintf('%s\n%s\n%s\n%s\n' , cmdBrainMap , cmdHandle , cmdPosition ,...
                        cmdUpdateTimeCourse);
        
        cmdClearVar = 'clear voxel_position Ahandle';
        rest_sliceviewer('UpdateCallback' , Viewer , [theCallback cmdClearVar] , 'Time Course');
    catch
        rest_misc('DisplayLastException');
    end
    
function create_timecourse( hObject , eventdata , handles)
    TR=str2num( get(handles.TR_entry , 'String') );
    lowband=str2num( get(handles.lowpass_entry , 'String') );
    highband=str2num( get(handles.highpass_entry , 'String') );
    %Plot time course
    axes(handles.image_axes);	cla
    timecourse=squeeze(handles.Volume(handles.position(1) , handles.position(2) , handles.position(3),:));
    timepoint=size(handles.Volume,4);
    
    plot((1:timepoint) * TR , timecourse ,'blue');
    xlim([1 , timepoint] * TR);
    theYLim = [min(timecourse) , max(timecourse)];
   
    if ~isfinite(theYLim(1)), theYLim(1)=0; end
	if ~isfinite(theYLim(2)), theYLim(2)=0; end
	if theYLim(2)>theYLim(1), ylim(theYLim); end
	
    set(gca, 'Title',text('String','Time Course', 'Color', 'magenta'));
	xlabel('Time (seconds)');
	ylabel('Intensity');    
    
    %Plot the amlitude in Freq domain
    %pow
    padded_len = rest_nextpow2_one35( timepoint );

    if get(handles.detrend_checkbox , 'Value')    
        timecourse_notrend=detrend(double (timecourse));
        
        axes(handles.image_axes); hold on;
        timecourse_plot=timecourse_notrend + repmat( mean(double(timecourse)) , [timepoint , 1]);
       
        plot( (1:timepoint) * TR , timecourse_plot, 'r:');
        
        theYLim=[min(theYLim(1),min(timecourse_plot)) , max(theYLim(2) , max(timecourse_plot))];
        if ~isfinite(theYLim(1)), theYLim(1)=0; end
		if ~isfinite(theYLim(2)), theYLim(2)=0; end
		if theYLim(2)>theYLim(1), ylim(theYLim); end
        set(gca, 'Title',text('String','Time Course(Red dot line is after removing linear trend)', 'Color', 'magenta'));
		
        power_title ='Power Spectrum after removing linear trend';
		freq_series =fft(timecourse_notrend, padded_len);
    else
    %FFT
        power_title ='Power Spectrum';
        freq_series =fft( double(timecourse) , padded_len);
    end
    
    sample_rate=1/TR;
    freq_precision=sample_rate/padded_len;
    freq_limit= freq_precision : freq_precision : sample_rate/2 ;
    
    x_limit=[2 , (padded_len/2+1)];
    
    freq_series = abs( freq_series( x_limit(1):x_limit(2) ) );
    freq_series(1:end) = freq_series(1:end).^2/timepoint;
    
    freq_series(1:end-1) = freq_series(1:end-1) * 2;
    
    axes(handles.power_axes); cla;
    plot(freq_limit , freq_series , 'Color' , 'blue');
    
    xlim([freq_limit(1) , freq_limit(end)]);
    theYLim = [min(freq_series(1:end))  , max(freq_series(1:end))]; 
	if ~isfinite(theYLim(1)), theYLim(1)=0; end
	if ~isfinite(theYLim(2)), theYLim(2)=0; end
	if theYLim(2)>theYLim(1), ylim(theYLim); end	
    set(gca, 'Title', text('String',power_title, 'Color', 'magenta'));
    xlabel(sprintf('Frequency( Hz), Sample Period( TR)=%g seconds', TR));
    ylabel('Amplitude');
    
    	%hDataCursor = datacursormode(handles.fig_DC); 
		%set(hDataCursor,'DisplayStyle','datatip', 'SnapToDataVertex','on','Enable','on') 
		%set(hDataCursor,'UpdateFcn', @SetDataTip); 
    
    hold on;
    plot([1 ,1] * lowband , get(gca , 'Ylim') , 'r:');
    
    text(lowband , theYLim(2)-theYLim(2)/10 , ...
		sprintf('\\leftarrow %g Hz', lowband),...
		'HorizontalAlignment','left', 'Color', 'red');
    
    plot([1, 1]* highband, get(gca,'Ylim'), 'r:');
    
    text(highband , theYLim(2)-theYLim(2)/10, ...
		sprintf('\\leftarrow %g Hz', highband),...
		'HorizontalAlignment','left', 'Color', 'red');
    %set(handles.image_axes,...
    %                    'Units' , 'Pixel',...
    %                    'YDir' , 'normal',...
    %                    'XTickLabel' , [],...
    %                    'XTick' , [],...
    %                    'YTickLabel' , [],...
    %                    'YTick' , [],...
    %                    'DataAspectRatio' , [1,1,1]);
    fig_size=get(handles.fig_DC , 'Position');
    fig_size(1 ,3)=158;
    set(handles.fig_DC , 'Position' , fig_size);
    guidata(hObject,handles)
%%
    
    % --- Executes on selection change in utilities_popupmenu.
%%
function utilities_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to utilities_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch get(handles.utilities_popupmenu , 'Value')
    case 1 %Uitility
        return;
    case 2 %ALFF
        alff_gui;
        set(handles.utilities_popupmenu , 'Value' , 1);
    case 3 %fALFF
        f_alff_gui;
        set(handles.utilities_popupmenu , 'Value' , 1);
    case 4 %ReHo
        reho_gui;
        set(handles.utilities_popupmenu , 'Value' , 1);
    case 5 %FC
        fc_gui;
        set(handles.utilities_popupmenu , 'Value' , 1);
    case 6 %VMHC
        rest_VMHC_gui;
        set(handles.utilities_popupmenu , 'Value' , 1);
    case 7 %========
        set(handles.utilities_popupmenu , 'Value' , 1);
    case 8 %SliceViewer
        rest_sliceviewer;
        set(handles.utilities_popupmenu , 'Value' , 1);
    otherwise
end
guidata(hObject , handles);
% Hints: contents = cellstr(get(hObject,'String')) returns utilities_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from utilities_popupmenu


% --- Executes during object creation, after setting all properties.
function utilities_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to utilities_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function help_menu_Callback(hObject, eventdata, handles)
% hObject    handle to help_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function web_menu_Callback(hObject, eventdata, handles)
% hObject    handle to web_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    web('http://restfmri.net');

% --------------------------------------------------------------------
function about_DC_menu_Callback(hObject, eventdata, handles)
% hObject    handle to about_DC_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function file_menu_Callback(hObject, eventdata, handles)
% hObject    handle to file_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function save_menu_Callback(hObject, eventdata, handles)
% hObject    handle to save_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName , PathName]=uiputfile('*.mat', 'Save a configure mat for Degree Centrality', 'Degree_Centrality.mat');
save_name=[PathName, FileName];
if ischar(save_name)
    Configure='';
    Configure.detrend_checkbox=get(handles.detrend_checkbox , 'Value');
    Configure.bandpass_checkbox=get(handles.bandpass_checkbox , 'Value');
    if Configure.bandpass_checkbox
        Configure.TR=get(handles.TR_entry , 'String');
        Configure.lowpass=get(handles.lowpass_entry , 'String');
        Configure.highpass=get(handles.highpass_entry , 'String');
    end
    Configure.save_checkbox=get(handles.save_checkbox , 'Value');
    Configure.dir_listbox=get(handles.dir_listbox , 'String');
    Configure.data_list=handles.data_list;
    Configure.mask_entry=get(handles.mask_entry , 'String');
    Configure.r_entry=get(handles.r_entry , 'String');
    Configure.weigh_entry=get(handles.weigh_entry , 'String');
    Configure.bin_entry=get(handles.bin_entry , 'String');
    Configure.normalize_checkbox=get(handles.normalize_checkbox , 'Value');
    Configure.divide_checkbox=get(handles.divide_checkbox , 'Value');
    Configure.prefix_entry=get(handles.prefix_entry , 'String');
    save(save_name , 'Configure');
end

% --------------------------------------------------------------------
function load_menu_Callback(hObject, eventdata, handles)
% hObject    handle to load_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName , PathName] = uigetfile('*.mat' , 'Pick a configure mat for Degree Centrality');
load_name=[PathName , FileName];
if ischar(load_name)
    load(load_name);
else
    return;
end

set(handles.detrend_checkbox , 'Value' , Configure.detrend_checkbox);
set(handles.bandpass_checkbox , 'Value', Configure.bandpass_checkbox);
if Configure.bandpass_checkbox
    set(handles.TR_entry , 'String' , Configure.TR);
    set(handles.lowpass_entry , 'String' , Configure.lowpass);
    set(handles.highpass_entry , 'String' , Configure.highpass);
    set(handles.TR_entry , 'Enable' , 'On');
    set(handles.lowpass_entry , 'Enable' , 'On');
    set(handles.highpass_entry , 'Enable' , 'On');
else
    set(handles.TR_entry , 'Enable' , 'Off');
    set(handles.lowpass_entry , 'Enable' , 'Off');
    set(handles.highpass_entry , 'Enable' , 'Off');
end

if Configure.detrend_checkbox || Configure.bandpass_checkbox
    set(handles.save_checkbox , 'Enable' , 'On');
else
    set(handles.save_checkbox , 'Enable' , 'Off');
end

set(handles.save_checkbox , 'Value' , Configure.save_checkbox);
set(handles.dir_listbox , 'String', Configure.dir_listbox);
handles.data_list=Configure.data_list;
if strcmp(Configure.mask_entry , 'Default Mask')
    set(handles.Default_radiobutton , 'Value' , 1);
    set(handles.nomask_radiobutton , 'Value' , 0);
    set(handles.mask_entry , 'String', Configure.mask_entry);
    set(handles.mask_entry , 'Enable' , 'Off');
elseif strcmp(Configure.mask_entry , 'Don''t use any mask')
    set(handles.Default_radiobutton , 'Value' , 0);
    set(handles.nomask_radiobutton , 'Value' , 1);
    set(handles.mask_entry , 'String', Configure.mask_entry);
    set(handles.mask_entry , 'Enable' , 'Off');
else
    set(handles.Default_radiobutton , 'Value' , 0);
    set(handles.nomask_radiobutton , 'Value' , 0);
    set(handles.mask_entry , 'String', Configure.mask_entry);
    set(handles.mask_entry , 'Enable' , 'On');
end
set(handles.r_entry , 'String', Configure.r_entry);
set(handles.weigh_entry , 'String', Configure.weigh_entry);
set(handles.bin_entry , 'String', Configure.bin_entry);
set(handles.normalize_checkbox , 'Value' , Configure.normalize_checkbox);
set(handles.divide_checkbox , 'Value' , Configure.divide_checkbox);
set(handles.prefix_entry , 'String'  , Configure.prefix_entry);

guidata(hObject , handles);    


% --------------------------------------------------------------------
function quit_menu_Callback(hObject, eventdata, handles)
% hObject    handle to quit_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.fig_DC);
%%




% --- Executes on button press in run_pushbutton.
function run_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to run_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    set(handles.dir_listbox , 'Value' , 1);
    if strcmp( get(handles.mask_entry , 'String') , 'Default Mask' )
        [RESTPath , Filename , extn]=fileparts(which('rest.m'));
        mask_file=[RESTPath , filesep , 'mask' , filesep , 'BrainMask_05_61x73x61.img'];
    elseif strcmp( get(handles.mask_entry , 'String') , 'Don''t use any mask' )
        mask_file='';
    else
        mask_file=get(handles.mask_entry , 'String');
    end
    
    %Check Input Directory
    if size(handles.data_list, 1)==0
        set(handles.dir_listbox , 'BackgroundColor' , 'Red');
        pause(0.1);
        set(handles.dir_listbox , 'BackgroundColor' , 'White');
        pause(0.1);
        set(handles.dir_listbox , 'BackgroundColor' , 'Red');
        pause(0.1);       
        set(handles.dir_listbox , 'BackgroundColor' , 'White');
        pause(0.1);
        set(handles.dir_listbox , 'BackgroundColor' , 'Red');
        pause(0.1);       
        set(handles.dir_listbox , 'BackgroundColor' , 'White');
        return;
    end
    
    if isempty( get(handles.r_entry , 'String'))...
        || ~isfloat(str2num(get(handles.r_entry , 'String')))...
        || ~(str2num(get(handles.r_entry , 'String'))>=0 && str2num(get(handles.r_entry , 'String'))<1)
        set(handles.bin_entry , 'BackgroundColor' , 'Red');
        pause(0.1);
        set(handles.r_entry , 'BackgroundColor' , 'White');
        pause(0.1);
        set(handles.r_entry , 'BackgroundColor' , 'Red');
        pause(0.1);       
        set(handles.r_entry , 'BackgroundColor' , 'White');
        pause(0.1);
        set(handles.r_entry , 'BackgroundColor' , 'Red');
        pause(0.1);       
        set(handles.r_entry , 'BackgroundColor' , 'White');
        return;  
    end
    r_thres=str2num( get(handles.r_entry , 'String') );
    PF_output={ get(handles.weigh_entry , 'String'); get(handles.bin_entry , 'String')};
    
    %Init TR, LOWPASS, HIGHPASS
    if get(handles.bandpass_checkbox , 'Value')
        PF_TR=str2num( get(handles.TR_entry , 'String') );
        PF_Lp=str2num( get(handles.lowpass_entry  , 'String') );
        PF_Hp=str2num( get(handles.highpass_entry , 'String') );
    else
        PF_TR='';
    end  
    output_prefix=get(handles.prefix_entry , 'String');
    normalize_tag=get(handles.normalize_checkbox , 'Value');
    divide_tag=get(handles.divide_checkbox , 'Value');
try    
    set(handles.run_pushbutton , 'BackgroundColor' , 'Red');
    CUTNUMBER=10;
    disable_button(handles , 'Off');
    pause(0.01);
    %RUN!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!11
    if get(handles.save_checkbox , 'Value')
        %Detrend
        if get(handles.detrend_checkbox , 'Value')
            suffix='_detrend';
            %Change Dir Name
            PF_inputdata=handles.data_list(: , 2);
            for i=1:size(handles.data_list , 1)
                handles.data_list{i ,2}=[handles.data_list{i ,2} , suffix];
            end

            %Calculate
            parfor i=1:size(PF_inputdata ,1)   
                rest_detrend (PF_inputdata{i}, suffix , CUTNUMBER);
            end
            pause(0.01);
            %Update display
            disable_button(handles, 'On');pause(0.01);  
            set(handles.dir_listbox , 'String' , GetInputDirDisplayList(handles));
            guidata(hObject , handles);
            disable_button(handles, 'Off');pause(0.01);  
            
            NeedDetrend=0;
        end
        pause(0.01);
        %Bandpass
        if get(handles.bandpass_checkbox , 'Value')
            suffix='_filtered';
            %Change Dir Name
            PF_inputdata=handles.data_list(: , 2);
            for i=1:size(handles.data_list , 1)
                handles.data_list{i ,2}=[handles.data_list{i ,2} , suffix];
            end

            %Calculate
            parfor i=1:size(PF_inputdata ,1)   
                rest_bandpass(PF_inputdata{i}, ...
                                PF_TR, ...
                                PF_Hp, ...
                                PF_Lp, ...
                                'No', ...
                                mask_file,...
                                CUTNUMBER)
            end
            pause(0.01);
            %Update display
            disable_button(handles, 'On');pause(0.01);            
            set(handles.dir_listbox , 'String' , GetInputDirDisplayList(handles));
            guidata(hObject , handles);
            disable_button(handles, 'Off');pause(0.01);  
            
            NeedBandpass='';
        end
        PF_inputdata=handles.data_list(: , 2);
    else %Do not save data generated by bandpass or detrend
        PF_inputdata=handles.data_list(: , 2);
        NeedDetrend=get(handles.detrend_checkbox , 'Value');
        if get(handles.bandpass_checkbox , 'Value')
            NeedBandpass=[PF_Lp , PF_Hp];
        else
            NeedBandpass='';
        end
    end
    pause(0.01);

    nPF_list=[];
    mPF_list=[];
    %Calculate Degree Centrality
    for i=1:size(PF_inputdata ,1) 
        [input_path , input_name , input_ext]=fileparts(PF_inputdata{i});
        if i==1
            PF_list={[PF_output{1} , filesep , output_prefix ,input_name],...
                [PF_output{2} , filesep , output_prefix , input_name]};
            %Need normalize
            if normalize_tag
                nPF_list=...
                    {[PF_output{1} , filesep , 'z' , output_prefix ,input_name],...
                    [PF_output{2} , filesep , 'z' , output_prefix , input_name]};
            end
            %Need divide
            if divide_tag
                mPF_list=...
                    {[PF_output{1} , filesep , 'm' , output_prefix ,input_name],...
                    [PF_output{2} , filesep , 'm' , output_prefix , input_name]};
            end
        else
            PF_list=[PF_list  ; {[PF_output{1} , filesep , output_prefix ,input_name],...
                [PF_output{2} , filesep , output_prefix , input_name]}];
            %Need normalize
            if normalize_tag
                nPF_list=[nPF_list  ;...
                    {[PF_output{1} , filesep , 'z' ,output_prefix ,input_name],...
                    [PF_output{2} , filesep , 'z' , output_prefix , input_name]}];
            end   
            %Need divide
            if divide_tag
                mPF_list=[mPF_list  ;...
                    {[PF_output{1} , filesep , 'm' ,output_prefix ,input_name],...
                    [PF_output{2} , filesep , 'm' , output_prefix , input_name]}];
            end            
        end
    end
    
    parfor i=1:size(PF_inputdata ,1) 
        [DC_PW, DC_PB, Header]=rest_DegreeCentrality(  PF_inputdata{i}, ...
                                r_thres,         ...
                                PF_list(i , :),       ...
                                mask_file,       ...
                                NeedDetrend,     ...
                                NeedBandpass,    ...
                                PF_TR,           ...
                                '',              ...%Scrubbing Default NO
                                '',              ...%If USER want to scrube
                                '',              ...%data, see rest_DegreeCentrality.m
                                '',              ...%Header
                                CUTNUMBER);
        %Normalize result
        
        Header.pinfo = [1;0;0];
        Header.dt    =[16,0];
        
        if normalize_tag && iscell(nPF_list)
            z_output=nPF_list(i ,:);
            
            %Revised by YAN Chao-Gan, 120904.
            BrainMaskData=rest_readfile(mask_file);
            %Weighed
            Temp = ((DC_PW - mean(DC_PW(find(BrainMaskData)))) ./ std(DC_PW(find(BrainMaskData)))) .* (BrainMaskData~=0);
            rest_WriteNiftiImage(Temp,Header,z_output{1});

            %Bin
            Temp = ((DC_PB - mean(DC_PB(find(BrainMaskData)))) ./ std(DC_PB(find(BrainMaskData)))) .* (BrainMaskData~=0);
            rest_WriteNiftiImage(Temp,Header,z_output{2});
        
        end
        
        %Divide mean result
        if divide_tag && iscell(mPF_list)
            m_output=mPF_list(i ,:);
            
            %Revised by YAN Chao-Gan, 120904.
            BrainMaskData=rest_readfile(mask_file);
            
            %Weighed
            Temp = (DC_PW ./ mean(DC_PW(find(BrainMaskData)))) .* (BrainMaskData~=0);
            rest_WriteNiftiImage(Temp,Header,m_output{1});

            %Bin
            Temp = (DC_PB ./ mean(DC_PB(find(BrainMaskData)))) .* (BrainMaskData~=0);
            rest_WriteNiftiImage(Temp,Header,m_output{2});
          
        end
        
    end
    set(handles.run_pushbutton , 'BackgroundColor' , [0.86 , 0.86 , 0.86]);
    disable_button(handles , 'On');
catch
    set(handles.run_pushbutton , 'BackgroundColor' , [0.86 , 0.86 , 0.86]);
    rest_misc( 'DisplayLastException');
    disable_button(handles , 'On');
end
        
function check_warning(UIcontrol)
        set(UIcontrol , 'BackgroundColor' , 'Red');
        pause(0.1);
        set(UIcontrol , 'BackgroundColor' , 'White');
        pause(0.1);
        set(UIcontrol , 'BackgroundColor' , 'Red');
        pause(0.1);       
        set(UIcontrol , 'BackgroundColor' , 'White');
        pause(0.1);
        set(UIcontrol , 'BackgroundColor' , 'Red');
        pause(0.1);       
        set(UIcontrol , 'BackgroundColor' , 'White');
   
