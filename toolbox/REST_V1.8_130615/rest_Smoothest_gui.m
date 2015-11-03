function varargout = rest_Smoothest_gui(varargin)
% REST_SMOOTHEST_GUI MATLAB code for rest_Smoothest_gui.fig
%      REST_SMOOTHEST_GUI, by itself, creates a new REST_SMOOTHEST_GUI or raises the existing
%      singleton*.
%
%      H = REST_SMOOTHEST_GUI returns the handle to a new REST_SMOOTHEST_GUI or the handle to
%      the existing singleton*.
%
%      REST_SMOOTHEST_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in REST_SMOOTHEST_GUI.M with the given input arguments.
%
%      REST_SMOOTHEST_GUI('Property','Value',...) creates a new REST_SMOOTHEST_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before rest_Smoothest_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to rest_Smoothest_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help rest_Smoothest_gui

% Last Modified by GUIDE v2.5 14-Aug-2012 08:25:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @rest_Smoothest_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @rest_Smoothest_gui_OutputFcn, ...
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


% --- Executes just before rest_Smoothest_gui is made visible.
function rest_Smoothest_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to rest_Smoothest_gui (see VARARGIN)

% Choose default command line output for rest_Smoothest_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

movegui(handles.Fig_Smoothest, 'center');

% UIWAIT makes rest_Smoothest_gui wait for user response (see UIRESUME)
try
    uiwait(handles.Fig_Smoothest);
catch
    uiresume(handles.Fig_Smoothest);
end
    
% --- Outputs from this function are returned to the command line.
function varargout = rest_Smoothest_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isempty(handles)
    varargout{1}='';
else    
    varargout{1} = handles.FWHM;
    delete(handles.Fig_Smoothest);
end



function input_entry_Callback(hObject, eventdata, handles)
% hObject    handle to input_entry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_entry as text
%        str2double(get(hObject,'String')) returns contents of input_entry as a double


% --- Executes during object creation, after setting all properties.
function input_entry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_entry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in input_pushbutton.
function input_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to input_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[input_filename,input_pathname]=uigetfile({'*.img;*.nii;*.nii.gz','Brain Image Files (*.img;*.nii;*.nii.gz)';'*.*', 'All Files (*.*)'},'Select a Statistical Map');
 if ischar(input_filename) || ischar(input_pathname)   
    input_path=[input_pathname,input_filename];
    set(handles.input_entry,'string',input_path);
 end


function Output_entry_Callback(hObject, eventdata, handles)
% hObject    handle to Output_entry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Output_entry as text
%        str2double(get(hObject,'String')) returns contents of Output_entry as a double


% --- Executes during object creation, after setting all properties.
function Output_entry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Output_entry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Output_pushbutton.
function Output_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Output_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[output_filename,output_pathname]=uiputfile({'*.txt';},'Save FWHM report');
 if ischar(output_filename) && ischar(output_pathname)
    output_path=[output_pathname,output_filename];
    set(handles.Output_entry,'string',output_path);
 end

% --- Executes on button press in Comput_pushbutton.
function Comput_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Comput_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Get Statistical Map's filename
input_file=get(handles.input_entry,'String');
if strcmp(input_file,'Please Select A Statistical Maps');
    errordlg('Please Select A Statistical Maps');
    return;
end
%Get Mask's filename
mask_file=get(handles.Mask_entry,'String');
if strcmp(mask_file,'Default: NO MASK! You do not need a mask in AlphaSim')
    mask_file='';
end
%Get Output filename
output_file=get(handles.Output_entry,'String');
if strcmp(output_file,'Default: NO OUTOUT! Display in Commond Line')
    output_file='';
end

%Get Statistical data and headfile
[Statistical_data VoxelSize Header]=rest_readfile(input_file);
if isfield(Header,'descrip')
    headinfo=Header.descrip; 
    testDf2=0;
        if ~isempty(strfind(headinfo,'{T_['))
            testFlag='T';
            Tstart=strfind(headinfo,'{T_[')+length('{T_[');
            Tend=strfind(headinfo,']}')-1;
            testDf = str2num(headinfo(Tstart:Tend));
        elseif ~isempty(strfind(headinfo,'{F_['))
            testFlag='F';
            Tstart=strfind(headinfo,'{F_[')+length('{F_[');
            Tend=strfind(headinfo,']}')-1;
            F_Df = str2num(headinfo(Tstart:Tend));
            testDf=F_Df(1,1);
            testDf2=F_Df(1,2);
        elseif ~isempty(strfind(headinfo,'{R_['))
            testFlag='R';
            Tstart=strfind(headinfo,'{R_[')+length('{R_[');
            Tend=strfind(headinfo,']}')-1;
            testDf = str2num(headinfo(Tstart:Tend));
        elseif ~isempty(strfind(headinfo,'{Z_['))
            testFlag='Z';
            Tstart=strfind(headinfo,'{Z_[')+length('{Z_[');
            Tend=strfind(headinfo,']}')-1;
            testDf = str2num(headinfo(Tstart:Tend));
        end
end

DOF=100;
if strcmp(testFlag,'Z')
    [dLh,resels,FWHM, nVoxels]=rest_Smoothest(Statistical_data, mask_file, DOF, VoxelSize);
else
    [Z_map P] = rest_TFRtoZ(Statistical_data,'DO NOT OUTPUT IMAGE',testFlag,testDf,testDf2,Header);
    [dLh,resels,FWHM, nVoxels]=rest_Smoothest(Z_map, mask_file, DOF, VoxelSize);
end
%Save report
if ~isempty(output_file)
    v_FWHM=FWHM./VoxelSize;
    text=[sprintf('FWHMx = %f voxels\tFWHMy = %f voxels\tFWHMz = %f voxels\n',v_FWHM(1),v_FWHM(2),v_FWHM(3)),...
        sprintf('FWHMx = %f mm\tFWHMy = %f mm\tFWHMz = %f mm\n',FWHM(1),FWHM(2),FWHM(3)),...
        sprintf('DLH = %f\tVOLUME = %d\tRESELS = %f\n',dLh,nVoxels,resels)];
    save(output_file,text);
end
handles.FWHM=FWHM;

guidata(hObject, handles);

uiresume(handles.Fig_Smoothest);

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


% --- Executes on button press in Mask_pushbutton.
function Mask_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Mask_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[mask_filename,mask_pathname]=uigetfile({'*.img;*.nii;*.nii.gz','Brain Image Files (*.img;*.nii;*.nii.gz)';'*.*', 'All Files (*.*)'},'Select a Mask');
 if ischar(mask_filename) && ischar(mask_pathname)   
    mask_path=[mask_pathname,mask_filename];
    set(handles.Mask_entry,'string',mask_path);
 end
