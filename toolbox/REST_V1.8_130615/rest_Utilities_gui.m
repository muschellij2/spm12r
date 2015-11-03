function varargout = rest_Utilities_gui(varargin)
%   varargout = rest_Utilities_gui(varargin)
%   Utilities of REST
%   By YAN Chao-Gan and Dong Zhang-Ye 091126.
%   State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University, China, 100875
%	http://www.restfmri.net
% 	Mail to Authors:  <a href="ycg.yan@gmail.com">YAN Chao-Gan</a>; <a href="dongzy08@gmail.com">DONG Zhang-Ye</a> 
%	Version=1.0;
%	Release=20091215;
%   Modified by YAN Chao-Gan 091212: Added REST DICOM Sorter.
%   Modified by YAN Chao-Gan 100201: Added REST Powerspectrum 1.0.
%   Modified by Sandy Wang   120725: Deleted REST SliceViewer.
%------------------------------------------------------------------------------------------------------------------------------

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @rest_Utilities_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @rest_Utilities_gui_OutputFcn, ...
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

function rest_Utilities_gui_OpeningFcn(hObject, eventdata, handles, varargin)

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

function varargout = rest_Utilities_gui_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;

function btnAlphaSim_Callback(hObject, eventdata, handles)
theFig =findobj(allchild(0),'flat','Tag','figAlphaSim');
if ~isempty(theFig) && rest_misc( 'ForceCheckExistFigure' , theFig),
	figure(theFig);
else
	rest_AlphaSim_gui;
end


function btnSeCov_Callback(hObject, eventdata, handles)

theFig =findobj(allchild(0),'flat','Tag','figCSMain');
if ~isempty(theFig) && rest_misc( 'ForceCheckExistFigure' , theFig),
	figure(theFig);
else
	rest_RegressOutCovariates_gui;
end

function btnImgCal_Callback(hObject, eventdata, handles)

theFig =findobj(allchild(0),'flat','Tag','figIC');
if ~isempty(theFig) && rest_misc( 'ForceCheckExistFigure' , theFig),
	figure(theFig);
else
	rest_ImgCal_gui;
end



% --- Executes on button press in btnERI.
function btnERI_Callback(hObject, eventdata, handles)
theFig =findobj(allchild(0),'flat','Tag','rest_ExtractROITC_gui');
if ~isempty(theFig) && rest_misc( 'ForceCheckExistFigure' , theFig),
	figure(theFig);
else
	rest_ExtractROITC_gui;
end
% --- Executes on button press in btnNii2Pairs.
function btnNii2Pairs_Callback(hObject, eventdata, handles)
theFig =findobj(allchild(0),'flat','Tag','rest_ExtractROITC_gui');
if ~isempty(theFig) && rest_misc( 'ForceCheckExistFigure' , theFig),
	figure(theFig);
else
	rest_Nii2NiftiPairs_gui;
end
% --- Executes on button press in btnResI.
function btnResI_Callback(hObject, eventdata, handles)
theFig =findobj(allchild(0),'flat','Tag','rest_ExtractROITC_gui');
if ~isempty(theFig) && rest_misc( 'ForceCheckExistFigure' , theFig),
	figure(theFig);
else
	rest_ResliceImage_gui;
end


% --- Executes on button press in btnSliceViewer.
function btnSliceViewer_Callback(hObject, eventdata, handles)
rest_sliceviewer;




% --- Executes on button press in pushbuttonDicomSorter.
function pushbuttonDicomSorter_Callback(hObject, eventdata, handles)
rest_DicomSorter_gui;




% --- Executes on button press in Powerspectrum.
function Powerspectrum_Callback(hObject, eventdata, handles)
%Display a brain image like MRIcro, and show specific voxel's time course and its freq domain's fluctuation
theOldColor=get(hObject,'BackgroundColor');
set(hObject,'Enable','off', 'BackgroundColor', 'red');
drawnow;
try
    rest_Powerspectrum_start;
catch
    rest_misc( 'DisplayLastException');
end
set(hObject,'Enable','on', 'BackgroundColor', theOldColor);
drawnow;
rest_waitbar;




% --- Executes on button press in pushbuttonNormalityTest.
function pushbuttonNormalityTest_Callback(hObject, eventdata, handles)
rest_NormalityTest_gui;


