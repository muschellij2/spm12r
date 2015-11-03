function varargout = rest_GRFCorrection_gui(varargin)
%   varargout = rest_GRFCorrection_gui(varargin)
%   Perform Gaussian Random Field theory multiple comparison correction
%   -------------------------------------------------------------------
%   GUI by Sandy Wang and ZANG Zhen-Xiang
%   State Key Laboratory of Cognitive Neuroscience and Learning in Beijing Normal University
%   Center for Cognition and Brain Disorders and The Affiliated Hospital,Hangzhou Normal University
%   --------------------------------------------------------------------
%   GRF_Function (rest_GRF_Threshold) by YAN Chao-Gan.
%   The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962, USA
%   Child Mind Institute, 445 Park Avenue, New York, NY 10022, USA
%   The Phyllis Green and Randolph Cowen Institute for Pediatric
%   Neuroscience, New York University Child Study Center, New York, NY 10016, USA
%   --------------------------------------------------------------------
%	http://www.restfmri.net
% 	Mail to Authors:  <a href="ycg.yan@gmail.com">YAN Chao-Gan</a>; <a href="zangzx416@sina.com">ZANG Zhen-Xiang</a>; 
%	Version=1.0; Released: 120501

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @rest_GRFCorrection_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @rest_GRFCorrection_gui_OutputFcn, ...
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


% --- Executes just before sandy_GRF_Correction is made visible.
function rest_GRFCorrection_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to sandy_GRF_Correction (see VARARGIN)

% Choose default command line output for sandy_GRF_Correction
handles.output = hObject;

set(handles.output_entry , 'String' , pwd);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes sandy_GRF_Correction wait for user response (see UIRESUME)
% uiwait(handles.fig_GRF_multi);


% --- Outputs from this function are returned to the command line.
function varargout = rest_GRFCorrection_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in input_listbox.
function input_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to input_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns input_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from input_listbox


% --- Executes during object creation, after setting all properties.
function input_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in input_pushbutton.
function input_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to input_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[input_filename , input_pathname]=uigetfile({'*.img;*.nii;*.nii.gz','Brain Image Files (*.img;*.nii;*.nii.gz)';'*.*', 'All Files (*.*)';}, ...
        'Pick statistical maps' , 'MultiSelect' , 'On');
if (ischar(input_filename) || iscell(input_filename)) && ischar(input_pathname)   
    present_list=get(handles.input_listbox , 'String');   
    if iscell(input_filename)
        for i=1:size(input_filename , 2)
            if isempty(present_list)
                present_list={[input_pathname , input_filename{i}]};
            else
                present_list=...
                    [present_list , {[input_pathname , input_filename{i}]}];
            end
        end
    else
        if isempty(present_list)
            present_list={[input_pathname , input_filename]};
        else
            present_list=[present_list , {[input_pathname , input_filename]}];
        end
    end
    set(handles.input_listbox , 'String' , present_list);
    set(handles.input_listbox , 'Value'  , size(present_list ,2));
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
        set(handles.mask_entry , 'String' , mask_entry);
    end


function voxel_entry_Callback(hObject, eventdata, handles)
% hObject    handle to voxel_entry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of voxel_entry as text
%        str2double(get(hObject,'String')) returns contents of voxel_entry as a double


% --- Executes during object creation, after setting all properties.
function voxel_entry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to voxel_entry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cluster_entry_Callback(hObject, eventdata, handles)
% hObject    handle to voxel_entry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of voxel_entry as text
%        str2double(get(hObject,'String')) returns contents of voxel_entry as a double


% --- Executes during object creation, after setting all properties.
function cluster_entry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to voxel_entry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function output_entry_Callback(hObject, eventdata, handles)
% hObject    handle to output_entry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of output_entry as text
%        str2double(get(hObject,'String')) returns contents of output_entry as a double


% --- Executes during object creation, after setting all properties.
function output_entry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to output_entry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in output_pushbutton.
function output_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to output_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
output_dir=uigetdir('Please pick a directory');
set(handles.output_entry , 'String' , output_dir);

% --- Executes on button press in run_pushbutton.
function run_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to run_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
check_tag=0;
if isempty(get(handles.input_listbox , 'String'))
    check_warning(handles.input_listbox);
    check_tag=1;
end

if isempty(get(handles.voxel_entry , 'String'))
    check_warning(handles.voxel_entry);
    check_tag=1;
end

if isempty(get(handles.voxel_entry , 'String'))
    check_warning(handles.voxel_entry);
    check_tag=1;
end

if check_tag==1
    return;
end

is_two_tag=get(handles.two_tail , 'Value');

mask_file=get(handles.mask_entry , 'String');

voxel_p=str2num(get(handles.voxel_entry , 'String'));
cluster_p=str2num(get(handles.cluster_entry , 'String')); 
input=get(handles.input_listbox , 'String');
output_path=get(handles.output_entry , 'String');
try
   set(handles.input_listbox , 'Value' , 1);
   for i=1:size(input ,2) 
        [Data VoxelSize Header]=rest_readfile(input{i});
        [input_path , input_name , input_ext]=fileparts(input{i});
        if isfield(Header,'descrip')
        headinfo=Header.descrip; 
        testDf2=0;
            if ~isempty(strfind(headinfo,'{T_['))% dong 100331 begin
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
        
        rest_GRF_Threshold(input{i},...   %rest_GRF_Threshold(Data,...
            voxel_p,...
            is_two_tag,...
            cluster_p,...
            [output_path , filesep ,  input_name],...
            mask_file,...
            testFlag,...
            testDf,...
            testDf2,...
            VoxelSize,...
            Header); %rest_GRF_Threshold by YAN Chao-Gan
   end
catch
    rest_misc( 'DisplayLastException');
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
        pause(0.1);
        
        
function two_tail_Callback(hObject, eventdata, handles)



% --- Executes when selected object is changed in tail_panel.
function tail_panel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in tail_panel 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
is_two_tag=get(handles.two_tail , 'Value');
if is_two_tag
   uiwait(msgbox('The "two-tailed" option is doing as following (e.g., if set VoxelPThreshold = 0.01 and cluster level p<0.05): 1) Get Group A > Group B, set Z>2.576 (two-tailed p <0.01) and cluster level p<0.025  2) Get Group A < Group B, set a Z<-2.576 (two-tailed p <0.01) and cluster level p<0.025.  3) Add 1 and 2 together, which could ensure the total p<0.05.','Two-tailed')); 
end
