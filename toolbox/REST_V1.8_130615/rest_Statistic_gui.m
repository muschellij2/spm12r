function varargout = rest_Statistic_gui(varargin)
%   varargout = rest_Statistic_gui(varargin)
%   Statistical Analysis GUI.
%   By YAN Chao-Gan 100401.
%   State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University, China, 100875
%	http://www.restfmri.net
% 	Mail to Authors:  <a href="ycg.yan@gmail.com">YAN Chao-Gan</a>
%	Version=1.0;
%	Release=200100401;
%--------------------------------------------------------------------------

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @rest_Statistic_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @rest_Statistic_gui_OutputFcn, ...
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

function rest_Statistic_gui_OpeningFcn(hObject, eventdata, handles, varargin)

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

handles.output = hObject;

guidata(hObject, handles);

function varargout = rest_Statistic_gui_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;

function btnTtest1_Callback(hObject, eventdata, handles)
rest_ttest1_gui;

function btnTtestpaired_Callback(hObject, eventdata, handles)
rest_ttestpaired_gui;

function btnTtest2cov_Callback(hObject, eventdata, handles)
rest_ttest2cov_gui;

function btnAncova_Callback(hObject, eventdata, handles)
rest_ancova1_gui;

function btnCorr_Callback(hObject, eventdata, handles)
rest_corr_gui;

% --- Executes on button press in normalize_pushbutton.
function normalize_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to normalize_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
rest_NormalityTest_gui;

% --- Executes on button press in Alpha_sim_pushbutton.
function Alpha_sim_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Alpha_sim_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
rest_AlphaSim_gui;

% --- Executes on button press in smooth_pushbutton.
function smooth_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to smooth_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
rest_Smoothest_gui;

% --- Executes on button press in GRF_pushbutton.
function GRF_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to GRF_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
rest_GRFCorrection_gui;

