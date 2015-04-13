function varargout = rest_CorrectionThresholdsByAlphaSim(varargin)
% REST_CORRECTIONTHRESHOLDSBYALPHASIM M-file for rest_CorrectionThresholdsByAlphaSim.fig
%      REST_CORRECTIONTHRESHOLDSBYALPHASIM, by itself, creates a new REST_CORRECTIONTHRESHOLDSBYALPHASIM or raises the existing
%      singleton*.
%
%      H = REST_CORRECTIONTHRESHOLDSBYALPHASIM returns the handle to a new REST_CORRECTIONTHRESHOLDSBYALPHASIM or the handle to
%      the existing singleton*.
%
%      REST_CORRECTIONTHRESHOLDSBYALPHASIM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in REST_CORRECTIONTHRESHOLDSBYALPHASIM.M with the given input arguments.
%
%      REST_CORRECTIONTHRESHOLDSBYALPHASIM('Property','Value',...) creates a new REST_CORRECTIONTHRESHOLDSBYALPHASIM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before rest_CorrectionThresholdsByAlphaSim_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to rest_CorrectionThresholdsByAlphaSim_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help rest_CorrectionThresholdsByAlphaSim

% Last Modified by GUIDE v2.5 08-Nov-2009 17:58:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @rest_CorrectionThresholdsByAlphaSim_OpeningFcn, ...
                   'gui_OutputFcn',  @rest_CorrectionThresholdsByAlphaSim_OutputFcn, ...
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


% --- Executes just before rest_CorrectionThresholdsByAlphaSim is made visible.
function rest_CorrectionThresholdsByAlphaSim_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to rest_CorrectionThresholdsByAlphaSim (see VARARGIN)

% Choose default command line output for rest_CorrectionThresholdsByAlphaSim
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes rest_CorrectionThresholdsByAlphaSim wait for user response (see UIRESUME)
% uiwait(handles.figCorrectionThresholdsByAlphaSim);


% --- Outputs from this function are returned to the command line.
function varargout = rest_CorrectionThresholdsByAlphaSim_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbuttonOK.
function pushbuttonOK_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.figCorrectionThresholdsByAlphaSim); 


