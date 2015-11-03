function varargout = rest_AlphaSim_gui(varargin)
%   varargout = rest_AlphaSim_gui(varargin)
%   GUI for Monte Carlo simulation program similar to the AlphaSim in AFNI.
%   By YAN Chao-Gan, Dong Zhang-Ye and ZHU Wei-Xuan 091108.
%   The mechanism is based on AFNI's AlphaSim, please see more details from http://afni.nimh.nih.gov/pub/dist/doc/manual/AlphaSim.pdf
%   State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University, China, 100875
%	http://www.restfmri.net
% 	Mail to Authors:  <a href="ycg.yan@gmail.com">YAN Chao-Gan</a>; <a	href="dongzy08@gmail.com">DONG Zhang-Ye</a> ; <a href="zhuweixuan@gmail.com">ZHU Wei-Xuan</a> 
%	Version=1.0;
%	Release=20091201;
%------------------------------------------------------------------------------------------------------------------------------

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @rest_AlphaSim_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @rest_AlphaSim_gui_OutputFcn, ...
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

function rest_AlphaSim_gui_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
set(handles.editoutfile ,'String', pwd);
% Make Display correct in linux - YAN Chao-Gan 111025 Added.
if ~ispc
    ZoomFactor=0.85;
    ObjectNames = fieldnames(handles);
    for i=1:length(ObjectNames);
        eval(['IsFontSizeProp=isprop(handles.',ObjectNames{i},',''FontSize'');']);
        if IsFontSizeProp
            eval(['PCFontSize=get(handles.',ObjectNames{i},',''FontSize'');']);
            FontSize=PCFontSize*ZoomFactor;
            eval(['set(handles.',ObjectNames{i},',''FontSize'',',num2str(FontSize),');']);
        end
    end
end
guidata(hObject, handles);

function varargout = rest_AlphaSim_gui_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;

function pushbuttonrun_Callback(hObject, eventdata, handles)
theOldColor =get(hObject, 'BackgroundColor');
set(hObject,'Enable','off', 'BackgroundColor', 'red');
drawnow;
fwhm=str2num(get(handles.editfwhm,'String'));
rmm=str2num(get(handles.editrmm,'String'));
pthr=str2num(get(handles.editpthr,'String'));
iter=str2num(get(handles.edititer,'String'));
mask=get(handles.editmask,'String');
if isempty(mask)
    errordlg('No mask ,please inter .');
    set(hObject,'Enable','on', 'BackgroundColor',theOldColor);
    return;
end
outdir=get(handles.editoutfile,'String');
outname=get(handles.editoutname,'String');
rest_AlphaSim(mask,outdir,outname,rmm,fwhm,pthr,iter);
set(hObject,'Enable','on', 'BackgroundColor', theOldColor);

function pushbuttonquit_Callback(hObject, eventdata, handles)
close(rest_AlphaSim_gui);




function editfwhm_Callback(hObject, eventdata, handles)

function editfwhm_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editrmm_Callback(hObject, eventdata, handles)

function editrmm_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editpthr_Callback(hObject, eventdata, handles)

function editpthr_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edititer_Callback(hObject, eventdata, handles)

function edititer_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editmask_Callback(hObject, eventdata, handles)

function editmask_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editoutfile_Callback(hObject, eventdata, handles)

function editoutfile_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pushbuttonmask_Callback(hObject, eventdata, handles)
[filename, pathname] = uigetfile({'*.img;*.nii;*.nii.gz','Brain Image Files (*.img;*.nii;*.nii.gz)';'*.*', 'All Files (*.*)';}, ...
												'Pick a user''s  mask');
    if ~(filename==0)
        handles.MaskFile =[pathname filename];
        set(handles.editmask,'String',handles.MaskFile);
        guidata(hObject,handles);
    end

function pushbuttonoutfile_Callback(hObject, eventdata, handles)
    theDir =pwd;
	theDir =uigetdir(theDir, 'Please select the output directory: ');
	if ~isequal(theDir, 0)
		set(handles.editoutfile,'String',theDir);	
	end	

function editoutname_Callback(hObject, eventdata, handles)

function editoutname_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function pushbuttonrun_changecolor(hObject, eventdata, handles)
set(hObject,'BackgroundColor','red');
drawnow;


% --- Executes on button press in smoothest_pushbutton.
function smoothest_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to smoothest_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Add by Sandy to estimate FWHM of statistical map
FWHM=rest_Smoothest_gui;
FWHM=['[',num2str(FWHM),']'];
set(handles.editfwhm,'String',FWHM);
