function varargout = rest_GRF_for_sliceview(varargin)
% REST_GRF_FOR_SLICEVIEW MATLAB code for rest_GRF_for_sliceview.fig
%      REST_GRF_FOR_SLICEVIEW, by itself, creates a new REST_GRF_FOR_SLICEVIEW or raises the existing
%      singleton*.
%
%      H = REST_GRF_FOR_SLICEVIEW returns the handle to a new REST_GRF_FOR_SLICEVIEW or the handle to
%      the existing singleton*.
%
%      REST_GRF_FOR_SLICEVIEW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in REST_GRF_FOR_SLICEVIEW.M with the given input arguments.
%
%      REST_GRF_FOR_SLICEVIEW('Property','Value',...) creates a new REST_GRF_FOR_SLICEVIEW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before rest_GRF_for_sliceview_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to rest_GRF_for_sliceview_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help rest_GRF_for_sliceview

% Last Modified by GUIDE v2.5 07-Sep-2012 23:40:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @rest_GRF_for_sliceview_OpeningFcn, ...
                   'gui_OutputFcn',  @rest_GRF_for_sliceview_OutputFcn, ...
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


% --- Executes just before rest_GRF_for_sliceview is made visible.
function rest_GRF_for_sliceview_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to rest_GRF_for_sliceview (see VARARGIN)
% Choose default command line output for rest_GRF_for_sliceview
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

movegui(handles.fig_GRFCorrection_SliceViewer, 'center');

% UIWAIT makes rest_GRF_for_sliceview wait for user response (see UIRESUME)
try
    uiwait(handles.fig_GRFCorrection_SliceViewer);
catch
    uiresume(handles.fig_GRFCorrection_SliceViewer);
end


% --- Outputs from this function are returned to the command line.
function varargout = rest_GRF_for_sliceview_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isempty(handles)
    varargout{1}='';
    varargout{2}='';
    varargout{3}='';
    varargout{4}='';
else
    varargout{1} = handles.mask_file;
    varargout{2} = handles.voxel_p;
    varargout{3} = handles.cluster_p;
    varargout{4} = handles.Is_two_tail;
    delete(handles.fig_GRFCorrection_SliceViewer);
end




function Data_entry_Callback(hObject, eventdata, handles)
% hObject    handle to Data_entry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Data_entry as text
%        str2double(get(hObject,'String')) returns contents of Data_entry as a double


% --- Executes during object creation, after setting all properties.
function Data_entry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Data_entry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Data_select_pushbutton.
function Data_select_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Data_select_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function Mask_entry_Callback(hObject, eventdata, handles)
% hObject    handle to Mask_entry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Mask_entry as text
%        str2double(get(hObject,'String')) returns contents of Mask_entry as a double


% --- Executes during object creation, after setting all properties.
function Mask_entry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Mask_entry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Mask_select_pushbutton.
function Mask_select_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Mask_select_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[RESTPath , Filename , extn]=fileparts(which('rest.m'));
RESTMask=[RESTPath , filesep , 'mask'];
current_directory=pwd;
cd(RESTMask);
[mask_filename,mask_pathname]=uigetfile({'*.img;*.nii;*.nii.gz','Brain Image Files (*.img;*.nii;*.nii.gz)';'*.*', 'All Files (*.*)';}, ...
        'Pick one mask file');
cd(current_directory);    
mask_path=[mask_pathname,mask_filename];
if ischar(mask_path)
    set(handles.Mask_entry,'string',mask_path);
end



function Voxel_P_entry_Callback(hObject, eventdata, handles)
% hObject    handle to Voxel_P_entry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Voxel_P_entry as text
%        str2double(get(hObject,'String')) returns contents of Voxel_P_entry as a double


% --- Executes during object creation, after setting all properties.
function Voxel_P_entry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Voxel_P_entry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Cluster_P_entry_Callback(hObject, eventdata, handles)
% hObject    handle to Cluster_P_entry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Cluster_P_entry as text
%        str2double(get(hObject,'String')) returns contents of Cluster_P_entry as a double


% --- Executes during object creation, after setting all properties.
function Cluster_P_entry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Cluster_P_entry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Run_pushbutton.
function Run_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Run_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mask_file  =    get(handles.Mask_entry,'string');
if strcmp(mask_file,'Select mask for image (Default: NO MASK!!!)')
    mask_file='';
end
handles.mask_file=mask_file;% Mask filename
handles.voxel_p    =    str2num(get(handles.Voxel_P_entry,'string'));% Voxel's p
handles.cluster_p  =    str2num(get(handles.Cluster_P_entry,'string'));% Cluster's p
handles.Is_two_tail=get(handles.Two_tail_radiobutton,'Value');

guidata(hObject, handles);

uiresume(handles.fig_GRFCorrection_SliceViewer);


% --- Executes when selected object is changed in uipanel1.
function uipanel1_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel1 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

is_two_tag=get(handles.Two_tail_radiobutton , 'Value');
if is_two_tag
   uiwait(msgbox('The "two-tailed" option is doing as following (e.g., if set VoxelPThreshold = 0.01 and cluster level p<0.05): 1) Get Group A > Group B, set Z>2.576 (two-tailed p <0.01) and cluster level p<0.025  2) Get Group A < Group B, set a Z<-2.576 (two-tailed p <0.01) and cluster level p<0.025.  3) Add 1 and 2 together, which could ensure the total p<0.05.','Two-tailed')); 
end
