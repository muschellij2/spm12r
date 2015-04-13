function varargout = rest_FDR_gui(varargin)
%   varargout = rest_FDR_gui(varargin)
%   GUI for setting parameters for false discovery rate (FDR) correction.
%   Input: Q-value, Mask filename, Conproc, Tchoose.
%   Output: Q-value, Mask filename, Conproc, Tchoose.
%   By YAN Chao-Gan and Dong Zhang-Ye 100201.
%   State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University, China, 100875
%	http://www.restfmri.net
% 	Mail to Authors:  <a href="ycg.yan@gmail.com">YAN Chao-Gan</a>; <a href="dongzy08@gmail.com">DONG Zhang-Ye</a> 
%	Version=1.0;
%	Release=20100201;
%------------------------------------------------------------------------------------------------------------------------------



gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @rest_FDR_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @rest_FDR_gui_OutputFcn, ...
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


% --- Executes just before rest_FDR is made visible.
function rest_FDR_gui_OpeningFcn(hObject, eventdata, handles, varargin)
if ~isempty(varargin),
    handles.Qvalue =varargin{1};
    handles.Qmaskname =varargin{2};
    handles.Conproc =varargin{3};
    handles.Tchoose =varargin{4};
else
    error('There must be 3 parameters at least!');
end
InitControls(hObject, handles);

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

% Update handles structure
guidata(hObject, handles);
try
	uiwait(handles.figFDR);
catch
	uiresume(handles.figFDR);
end

% UIWAIT makes rest_FDR wait for user response (see UIRESUME)
% uiwait(handles.figFDR);


% --- Outputs from this function are returned to the command line.
function varargout = rest_FDR_gui_OutputFcn(hObject, eventdata, handles) 
if isempty(handles)%Added by Sandy to fix a bug when kill the FDR window
    varargout{1} = '';
    varargout{2} = '';
    varargout{3} = '';
    varargout{4} = '';
else    
    varargout{1} = handles.Qvalue;
    varargout{2} = handles.Qmaskname;
    varargout{3} = handles.Conproc;
    varargout{4} = handles.Tchoose;
    delete(handles.figFDR);
end
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure



% --- Executes on button press in rtnIndependT.
function rtnIndependT_Callback(hObject, eventdata, handles)
handles.Conproc =1;
guidata(hObject, handles);
set(handles.rtnIndependT,'Value',1);
set(handles.rtnDepentT,'Value',0);
drawnow;



% --- Executes on button press in rtnDepentT.
function rtnDepentT_Callback(hObject, eventdata, handles)
handles.Conproc =2;
guidata(hObject, handles);
set(handles.rtnIndependT,'Value',0);
set(handles.rtnDepentT,'Value',1);
guidata(hObject, handles);
drawnow;



function edtQvalue_Callback(hObject, eventdata, handles)
% hObject    handle to edtQvalue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtQvalue as text
%        str2double(get(hObject,'String')) returns contents of edtQvalue as a double


% --- Executes during object creation, after setting all properties.
function edtQvalue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtQvalue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtMaskFile_Callback(hObject, eventdata, handles)
% hObject    handle to edtMaskFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtMaskFile as text
%        str2double(get(hObject,'String')) returns contents of edtMaskFile as a double


% --- Executes during object creation, after setting all properties.
function edtMaskFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtMaskFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnOK.
function btnOK_Callback(hObject, eventdata, handles)
handles.Qvalue=str2double(get(handles.edtQvalue, 'String'));
handles.Qmaskname=get(handles.edtMaskFile, 'String');
guidata(hObject, handles);
uiresume(handles.figFDR);


function btnMaskFile_Callback(hObject, eventdata, handles)
[filename, pathname] = uigetfile({'*.img;*.nii;*.nii.gz','Brain Image Files (*.img;*.nii;*.nii.gz)';'*.*', 'All Files (*.*)';}, ...
    'Pick a user''s  mask');
if ~(filename==0)
    handles.Qmaskname =[pathname filename];
end
set(handles.edtMaskFile,'String',handles.Qmaskname);
guidata(hObject, handles);

function InitControls(hObject, handles)
if handles.Conproc == 1
    set(handles.rtnIndependT,'Value',1);
    set(handles.rtnDepentT,'Value',0);
else
    set(handles.rtnIndependT,'Value',0);
    set(handles.rtnDepentT,'Value',1);
end
if handles.Tchoose == 1
    set(handles.rtnOnetail,'Value',1);
    set(handles.rtnTwetail,'Value',0);
%     set(handles.rtnIndependT,'Enable','off'); %YAN Chao-Gan, 100201
%     set(handles.rtnDepentT,'Enable','off'); %YAN Chao-Gan, 100201
else
    set(handles.rtnTwetail,'Value',1);
    set(handles.rtnOnetail,'Value',0);
%     set(handles.rtnIndependT,'Enable','on'); %YAN Chao-Gan, 100201
%     set(handles.rtnDepentT,'Enable','on'); %YAN Chao-Gan, 100201
end

set(handles.edtMaskFile,'String',handles.Qmaskname);
set(handles.edtQvalue,'String',num2str(handles.Qvalue));
guidata(hObject, handles);




% --- Executes on button press in rtnOnetail.
function rtnOnetail_Callback(hObject, eventdata, handles)
handles.Tchoose =1;
guidata(hObject, handles);
set(handles.rtnOnetail,'Value',1);
set(handles.rtnTwetail,'Value',0);
% set(handles.rtnIndependT,'Enable','off');  %YAN Chao-Gan, 100201
% set(handles.rtnDepentT,'Enable','off');  %YAN Chao-Gan, 100201
drawnow;


% --- Executes on button press in rtnTwetail.
function rtnTwetail_Callback(hObject, eventdata, handles)
handles.Tchoose =2;
guidata(hObject, handles);
set(handles.rtnOnetail,'Value',0);
set(handles.rtnTwetail,'Value',1);
% set(handles.rtnIndependT,'Enable','on');  %YAN Chao-Gan, 100201
% set(handles.rtnDepentT,'Enable','on');  %YAN Chao-Gan, 100201
drawnow;


