function varargout = rest_ancova1_gui(varargin)
%   varargout = rest_ancova1_gui(varargin)
%   One-way ANOVA or ANCOVA analysis GUI.
%   By YAN Chao-Gan 100401.
%   State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University, China, 100875
%	http://www.restfmri.net
% 	Mail to Authors:  <a href="ycg.yan@gmail.com">YAN Chao-Gan</a>
%	Version=1.0;
%	Release=200100401;
%--------------------------------------------------------------------------

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @rest_ancova1_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @rest_ancova1_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
function rest_ancova1_gui_OpeningFcn(hObject, eventdata, handles, varargin)
handles.Cfg.GroupDirs ={};
handles.Cfg.CovariateDirs ={};
handles.Cfg.OtherTxt = {};
handles.Cfg.MaskFile = '';
handles.Cfg.OutputDir=pwd;
handles.Cfg.OutputName='F';
handles.output = hObject;

InitControlProperties(hObject, handles);

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

% --- Outputs from this function are returned to the command line.
function varargout = rest_ancova1_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btnAddGroup.
function btnAddGroup_Callback(hObject, eventdata, handles)
if size(handles.Cfg.GroupDirs, 1)>0
		theDir =handles.Cfg.GroupDirs{1,1};
else
		theDir =pwd;
end
theDir =uigetdir(theDir, 'Please select the data directory to compute: ');
if ischar(theDir),
	SetDataDir(hObject, theDir,handles);	
end


% --- Executes on selection change in listGroup.
function listGroup_Callback(hObject, eventdata, handles)
% hObject    handle to listGroup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listGroup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listGroup


% --- Executes during object creation, after setting all properties.
function listGroup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listGroup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnCompute.
function btnCompute_Callback(hObject, eventdata, handles)
lenG=size(handles.Cfg.GroupDirs);
lenC=size(handles.Cfg.CovariateDirs);
lenO=size(handles.Cfg.OtherTxt);
if lenG(1)>0
    for i=1:lenG(1)
        DependentDirs(i)=handles.Cfg.GroupDirs(i,1);
    end
else
    DependentDirs={};
end
if lenC(1)>0
    for i=1:lenC(1)
        CovariateDirs(i)=handles.Cfg.CovariateDirs(i,1);
    end
else
    CovariateDirs={};
end
if lenO(1)>0
    for i=1:lenO(1)
        OtherCovariates{i,1}=load(handles.Cfg.OtherTxt{i,1});
    end
else
    OtherCovariates={};
end
MaskFile=handles.Cfg.MaskFile;
outname=get(handles.edtOutput, 'String');
OutputName=[handles.Cfg.OutputDir,filesep,outname];
% try
%     theOldColor=get(hObject,'BackgroundColor');
%     set(hObject,'Enable','off', 'BackgroundColor', 'red');
%     set(handles.btnAddGroup,'Enable','off');
%     set(handles.btnAddCovImages,'Enable','off');
%     set(handles.btnAddOtherCovariates,'Enable','off');
%     set(handles.btnmaskfile,'Enable','off');
%     set(handles.btnoutdir,'Enable','off');
%     drawnow;
rest_ancova1_Image(DependentDirs,...
    OutputName,MaskFile,CovariateDirs,OtherCovariates);
%     set(hObject,'Enable','on', 'BackgroundColor', theOldColor);
%     set(handles.btnAddGroup,'Enable','on');
%     set(handles.btnAddCovImages,'Enable','on');
%     set(handles.btnAddOtherCovariates,'Enable','on');
%     set(handles.btnmaskfile,'Enable','on');
%     set(handles.btnoutdir,'Enable','on');
drawnow;
% catch
%     msgbox ('Please match the dims','Tip');
% end


function edtOutput_Callback(hObject, eventdata, handles)
% hObject    handle to edtOutput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtOutput as text
%        str2double(get(hObject,'String')) returns contents of edtOutput as a double


% --- Executes during object creation, after setting all properties.
function edtOutput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtOutput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtoutdir_Callback(hObject, eventdata, handles)
% hObject    handle to edtoutdir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtoutdir as text
%        str2double(get(hObject,'String')) returns contents of edtoutdir as a double


% --- Executes during object creation, after setting all properties.
function edtoutdir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtoutdir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnoutdir.
function btnoutdir_Callback(hObject, eventdata, handles)
theDir =handles.Cfg.OutputDir;
theDir =uigetdir(theDir, 'Please select the output directory: ');
if ~isequal(theDir, 0)
    SetOutputDir(hObject,handles, theDir);
end

function SetOutputDir(hObject, handles, ADir)
if 7==exist(ADir,'dir')
    handles.Cfg.OutputDir =ADir;
    set(handles.edtoutdir,'String',ADir);
    guidata(hObject, handles);
    UpdateDisplay(handles);
end

function btnHelp_Callback(hObject, eventdata, handles)
msgbox({'ANOVA or ANCOVA analysis:';...
    'If only the group images are specified, then perform voxel-wise ANOVA analysis.';...
    'If the covariate images are also specified (e.g. gray matter proportion images), then voxel-wise ANCOVA analysis is performed while take each voxel in the covariate images as a covaraite. Please make sure the correspondence between the group images and the covariate images.';...
    'Text covariate can be also specified as text files. (E.g. age, brain size, IQ etc.)';...
    'The value of each voxel in the output image is an F statistic value. The degree of freedom information is stored in the header of the output image file.';...
    },'Help');

% --- Executes on button press in btnAddCovImages.
function btnAddCovImages_Callback(hObject, eventdata, handles)
if size(handles.Cfg.CovariateDirs, 1)>0
		theDir =handles.Cfg.CovariateDirs{1,1};
else
		theDir =pwd;
end
theDir =uigetdir(theDir, 'Please select the data directory to compute: ');
if ischar(theDir),
	SetICDataDir(hObject, theDir,handles);	
end

% --- Executes on selection change in listCovariateImages.
function listCovariateImages_Callback(hObject, eventdata, handles)
% hObject    handle to listCovariateImages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listCovariateImages contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listCovariateImages


% --- Executes during object creation, after setting all properties.
function listCovariateImages_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listCovariateImages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnAddOtherCovariates.
function btnAddOtherCovariates_Callback(hObject, eventdata, handles)
[filename, pathname] = uigetfile({'*.txt', 'Text covariates (*.txt)';}, ...
												'Pick a user''s  txt');
if ~(filename==0)
    handles.Cfg.OtherTxt =[ handles.Cfg.OtherTxt;{[pathname filename]}];
    guidata(hObject,handles);
end    
UpdateDisplay(handles);


% --- Executes on selection change in listOtherCovariates.
function listOtherCovariates_Callback(hObject, eventdata, handles)
% hObject    handle to listOtherCovariates (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listOtherCovariates contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listOtherCovariates


% --- Executes during object creation, after setting all properties.
function listOtherCovariates_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listOtherCovariates (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtmaskfile_Callback(hObject, eventdata, handles)
% hObject    handle to edtmaskfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtmaskfile as text
%        str2double(get(hObject,'String')) returns contents of edtmaskfile as a double


% --- Executes during object creation, after setting all properties.
function edtmaskfile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtmaskfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnmaskfile.
function btnmaskfile_Callback(hObject, eventdata, handles)
[filename, pathname] = uigetfile({'*.img;*.nii;*.nii.gz','Brain Image Files (*.img;*.nii;*.nii.gz)';'*.*', 'All Files (*.*)';}, ...
    'Pick a user''s  mask');
if ~(filename==0)
    handles.Cfg.MaskFile =[pathname filename];
    set(handles.edtmaskfile, 'String', handles.Cfg.MaskFile); 
    guidata(hObject,handles);
end

function InitControlProperties(hObject, handles)
handles.hContextMenu =uicontextmenu;
set(handles.listGroup, 'UIContextMenu', handles.hContextMenu);
uimenu(handles.hContextMenu, 'Label', 'Add a group', 'Callback', get(handles.btnAddGroup, 'Callback'));
uimenu(handles.hContextMenu, 'Label', 'Remove selected group', 'Callback', 'rest_ancova1_gui(''DeleteSelectedG'',gcbo,[], guidata(gcbo))');
uimenu(handles.hContextMenu, 'Label', '=============================');
uimenu(handles.hContextMenu, 'Label', 'Remove all data groups', 'Callback', 'rest_ancova1_gui(''ClearG'',gcbo,[], guidata(gcbo))');

handles.hContextMenui =uicontextmenu;
set(handles.listCovariateImages, 'UIContextMenu', handles.hContextMenui);
uimenu(handles.hContextMenui, 'Label', 'Add a covariate', 'Callback', get(handles.btnAddCovImages, 'Callback'));
uimenu(handles.hContextMenui, 'Label', 'Remove selected covariate', 'Callback', 'rest_ancova1_gui(''DeleteSelectedIC'',gcbo,[], guidata(gcbo))');
uimenu(handles.hContextMenui, 'Label', '=============================');
uimenu(handles.hContextMenui, 'Label', 'Remove all covariates', 'Callback', 'rest_ancova1_gui(''ClearIC'',gcbo,[], guidata(gcbo))');

handles.hContextMenui =uicontextmenu;
set(handles.listOtherCovariates, 'UIContextMenu', handles.hContextMenui);
uimenu(handles.hContextMenui, 'Label', 'Add a covariate', 'Callback', get(handles.btnAddOtherCovariates, 'Callback'));
uimenu(handles.hContextMenui, 'Label', 'Remove selected covariate', 'Callback', 'rest_ancova1_gui(''DeleteSelectedOC'',gcbo,[], guidata(gcbo))');
uimenu(handles.hContextMenui, 'Label', '=============================');
uimenu(handles.hContextMenui, 'Label', 'Remove all covariates', 'Callback', 'rest_ancova1_gui(''ClearOC'',gcbo,[], guidata(gcbo))');

set(handles.edtmaskfile, 'String', handles.Cfg.MaskFile);
set(handles.edtoutdir, 'String', handles.Cfg.OutputDir);
set(handles.edtOutput, 'String', handles.Cfg.OutputName);
guidata(hObject,handles);

function SetDataDir(hObject, ADir,handles)
if ~ischar(ADir), return; end
theOldWarnings =warning('off', 'all');
if rest_misc('GetMatlabVersion')>=7.3,
    ADir =strtrim(ADir);
end
if (~isequal(ADir , 0)) &&( (size(handles.Cfg.GroupDirs, 1)==0)||(0==length(strmatch(ADir,handles.Cfg.GroupDirs( : , 1),'exact' ) ) ))
    handles.Cfg.GroupDirs =[handles.Cfg.GroupDirs;{ADir , 0}];%update the dir
    tmpSize=size(handles.Cfg.GroupDirs);
    theVolumnCount =rest_CheckDataDir(handles.Cfg.GroupDirs{tmpSize(1),1} );
    if (theVolumnCount<=0),
        if isappdata(0, 'FC_DoingRecursiveDir') && getappdata(0, 'FC_DoingRecursiveDir'),
        else
            fprintf('There is no data or non-data files in this directory:\n%s\nPlease re-select\n\n', ADir);
            errordlg( sprintf('There is no data or non-data files in this directory:\n\n%s\n\nPlease re-select',ADir ));
        end
        handles.Cfg.GroupDirs(tmpSize(1),:)=[];
        if size(handles.Cfg.GroupDirs, 1)==0
            handles.Cfg.GroupDirs=[];
        end
    else
        handles.Cfg.GroupDirs{tmpSize(1),2} =theVolumnCount;
    end
    guidata(hObject, handles);
    UpdateDisplay(handles);
end
warning(theOldWarnings);

function SetICDataDir(hObject, ADir,handles)
if ~ischar(ADir), return; end
theOldWarnings =warning('off', 'all');
if rest_misc('GetMatlabVersion')>=7.3,
    ADir =strtrim(ADir);
end
if (~isequal(ADir , 0)) &&( (size(handles.Cfg.CovariateDirs, 1)==0)||(0==length(strmatch(ADir,handles.Cfg.CovariateDirs( : , 1),'exact' ) ) ))
    handles.Cfg.CovariateDirs =[handles.Cfg.CovariateDirs;{ADir , 0}];%update the dir
    tmpSize=size(handles.Cfg.CovariateDirs);
    theVolumnCount =rest_CheckDataDir(handles.Cfg.CovariateDirs{tmpSize(1),1} );
    if (theVolumnCount<=0),
        if isappdata(0, 'FC_DoingRecursiveDir') && getappdata(0, 'FC_DoingRecursiveDir'),
        else
            fprintf('There is no data or non-data files in this directory:\n%s\nPlease re-select\n\n', ADir);
            errordlg( sprintf('There is no data or non-data files in this directory:\n\n%s\n\nPlease re-select',ADir ));
        end
        handles.Cfg.CovariateDirs(tmpSize(1),:)=[];
        if size(handles.Cfg.CovariateDirs, 1)==0
            handles.Cfg.CovariateDirs=[];
        end
    else
        handles.Cfg.CovariateDirs{tmpSize(1),2} =theVolumnCount;
    end
    guidata(hObject, handles);
    UpdateDisplay(handles);
end
warning(theOldWarnings);

function SetOCDataDir(hObject, ADir,handles)
if ~ischar(ADir), return; end
theOldWarnings =warning('off', 'all');
if rest_misc('GetMatlabVersion')>=7.3,
    ADir =strtrim(ADir);
end
if (~isequal(ADir , 0)) &&( (size(handles.Cfg.OtherTxt, 1)==0)||(0==length(strmatch(ADir,handles.Cfg.OtherTxt( : , 1),'exact' ) ) ))
    handles.Cfg.OtherTxt =[handles.Cfg.OtherTxt;{ADir , 0}];%update the dir
    tmpSize=size(handles.Cfg.OtherTxt);
    theVolumnCount =CheckTDataDir(handles.Cfg.OtherTxt{tmpSize(1),1} );
    if (theVolumnCount<=0),
        if isappdata(0, 'FC_DoingRecursiveDir') && getappdata(0, 'FC_DoingRecursiveDir'),
        else
            fprintf('There is no data or non-data files in this directory:\n%s\nPlease re-select\n\n', ADir);
            errordlg( sprintf('There is no data or non-data files in this directory:\n\n%s\n\nPlease re-select',ADir ));
        end
        handles.Cfg.OtherTxt(tmpSize(1),:)=[];
        if size(handles.Cfg.OtherTxt, 1)==0
            handles.Cfg.OtherTxt=[];
        end
    else
        handles.Cfg.OtherTxt{tmpSize(1),2} =theVolumnCount;
    end
    guidata(hObject, handles);
    UpdateDisplay(handles);
end
warning(theOldWarnings);

function UpdateDisplay(handles)
if size(handles.Cfg.GroupDirs,1)>0
    theOldIndex =get(handles.listGroup, 'Value');
    set(handles.listGroup, 'String',  GetInputDirDisplayList(handles) , 'Value', 1);
    theCount =size(handles.Cfg.GroupDirs,1);
    if (theOldIndex>0) && (theOldIndex<= theCount)
        set(handles.listGroup, 'Value', theOldIndex);
    end
else
    set(handles.listGroup, 'String', '' , 'Value', 0);
end

if size(handles.Cfg.CovariateDirs,1)>0
    theOldIndexi =get(handles.listCovariateImages, 'Value');%here
    set(handles.listCovariateImages, 'String',  GetInputICDisplayList(handles) , 'Value', 1);
    theCount =size(handles.Cfg.CovariateDirs,1);
    if (theOldIndexi>0) && (theOldIndexi<= theCount)
        set(handles.listCovariateImages, 'Value', theOldIndexi);
    end
else
    set(handles.listCovariateImages, 'String', '' , 'Value', 0);
end

if size(handles.Cfg.OtherTxt)>0
    theOldIndext =get(handles.listOtherCovariates, 'Value');%here
    set(handles.listOtherCovariates, 'String',  GetInputOCDisplayList(handles) , 'Value', 1);
    theCount =size(handles.Cfg.OtherTxt,1);
    if (theOldIndext>0) && (theOldIndext<= theCount)
        set(handles.listOtherCovariates, 'Value', theOldIndext);
    end
else
    set(handles.listOtherCovariates, 'String', '' , 'Value', 0);
end



function Result=GetInputDirDisplayList(handles)
Result ={};
for x=size(handles.Cfg.GroupDirs, 1):-1:1
    Result =[{sprintf('G%d : %d img %s',x,handles.Cfg.GroupDirs{x, 2},handles.Cfg.GroupDirs{x, 1})} ;Result];
end

function Result=GetInputICDisplayList(handles)
Result ={};
for x=size(handles.Cfg.CovariateDirs, 1):-1:1
    Result =[{sprintf('C%d : %d img %s',x,handles.Cfg.CovariateDirs{x, 2},handles.Cfg.CovariateDirs{x, 1})} ;Result];
end

function Result=GetInputOCDisplayList(handles)
Result ={};
for x=size(handles.Cfg.OtherTxt, 1):-1:1
    Result =[{sprintf('TC%d: 1 txt %s',x,handles.Cfg.OtherTxt{x})} ;Result];
end

function [nVolumn]=CheckDataDir(ADataDir)
theFilenames = dir(ADataDir);
theHdrFiles=dir(fullfile(ADataDir,'*.hdr'));
theImgFiles=dir(fullfile(ADataDir,'*.img'));
if ~length(theHdrFiles)==length(theImgFiles)
    nVolumn =-1;
    fprintf('%s, *.{hdr,img} should be pairwise. Please re-examin them.\n', ADataDir);
    errordlg('*.{hdr,img} should be pairwise. Please re-examin them.');
    return;
end
count = 3; nVolumn = 0;
for count = 3:size(struct2cell(theFilenames),2)
    if	(length(theFilenames(count).name)>4) && ...
            strcmpi(theFilenames(count).name(end-3:end) , '.hdr')
        if strcmpi(theFilenames(count).name(1:end-4) ...                %hdr
                , theFilenames(count+1).name(1:end-4) )     %img
            nVolumn = nVolumn + 1;
        else
            nVolumn =-1;
            fprintf('%s, *.{hdr,img} should be pairwise. Please re-examin them.\n', ADataDir);
            errordlg('*.{hdr,img} should be pairwise. Please re-examin them.');
            break;
        end
    end
end

function [nVolumn]=CheckTDataDir(ADataDir)
theFilenames = dir(ADataDir);
theTxtFiles=dir(fullfile(ADataDir,'*.txt'));
count = 3; nVolumn = 0;
for count = 3:size(struct2cell(theFilenames),2)
    if	(length(theFilenames(count).name)>4) && ...
            strcmpi(theFilenames(count).name(end-3:end) , '.txt')
        nVolumn = nVolumn + 1;
    end
end


function DeleteSelectedG(hObject, eventdata, handles)
theIndex =get(handles.listGroup, 'Value');
if prod(size(handles.Cfg.GroupDirs))==0 ...
        || size(handles.Cfg.GroupDirs, 1)==0 ...
        || theIndex>size(handles.Cfg.GroupDirs, 1),
    return;
end
theDir     =handles.Cfg.GroupDirs{theIndex, 1};
theVolumnCount=handles.Cfg.GroupDirs{theIndex, 2};
tmpMsg=sprintf('Delete\n\n "%s" \nVolumn Count :%d ?', theDir, theVolumnCount);
if strcmp(questdlg(tmpMsg, 'Delete confirmation'), 'Yes')
    if theIndex>1,
        set(handles.listGroup, 'Value', theIndex-1);
    end
    handles.Cfg.GroupDirs(theIndex, :)=[];
    if size(handles.Cfg.GroupDirs, 1)==0
        handles.Cfg.GroupDirs={};
    end
    guidata(hObject, handles);
    UpdateDisplay(handles);
end

function DeleteSelectedIC(hObject, eventdata, handles)
theIndex =get(handles.listCovariateImages, 'Value');
if prod(size(handles.Cfg.CovariateDirs))==0 ...
        || size(handles.Cfg.CovariateDirs, 1)==0 ...
        || theIndex>size(handles.Cfg.CovariateDirs, 1),
    return;
end
theDir     =handles.Cfg.CovariateDirs{theIndex, 1};
theVolumnCount=handles.Cfg.CovariateDirs{theIndex, 2};
tmpMsg=sprintf('Delete\n\n "%s" \nVolumn Count :%d ?', theDir, theVolumnCount);
if strcmp(questdlg(tmpMsg, 'Delete confirmation'), 'Yes')
    if theIndex>1,
        set(handles.listCovariateImages, 'Value', theIndex-1);
    end
    handles.Cfg.CovariateDirs(theIndex, :)=[];
    if size(handles.Cfg.CovariateDirs, 1)==0
        handles.Cfg.CovariateDirs={};
    end
    guidata(hObject, handles);
    UpdateDisplay(handles);
end


function DeleteSelectedOC(hObject, eventdata, handles)
theIndex =get(handles.listOtherCovariates, 'Value');
if prod(size(handles.Cfg.OtherTxt))==0 ...
        || theIndex>size(handles.Cfg.OtherTxt, 1),
    return;
end
theDir     =handles.Cfg.OtherTxt{theIndex};
tmpMsg=sprintf('Delete\n\n "%s" \n?', theDir);
if strcmp(questdlg(tmpMsg, 'Delete confirmation'), 'Yes')
    if theIndex>1,
        set(handles.listOtherCovariates, 'Value', theIndex-1);
    end
    handles.Cfg.OtherTxt(theIndex, :)=[];
    if size(handles.Cfg.OtherTxt)==0
        handles.Cfg.OtherTxt={};
    end
    guidata(hObject, handles);
    UpdateDisplay(handles);
end

function ClearG(hObject, eventdata, handles)
if prod(size(handles.Cfg.GroupDirs))==0 ...
        || size(handles.Cfg.GroupDirs, 1)==0,
    return;
end
tmpMsg=sprintf('Attention!\n\n\nDelete all data directories?');
if strcmpi(questdlg(tmpMsg, 'Clear confirmation'), 'Yes'),
    handles.Cfg.GroupDirs(:)=[];
    if prod(size(handles.Cfg.GroupDirs))==0,
        handles.Cfg.GroupDirs={};
    end
    guidata(hObject, handles);
    UpdateDisplay(handles);
end

function ClearIC(hObject, eventdata, handles)
if prod(size(handles.Cfg.CovariateDirs))==0 ...
        || size(handles.Cfg.CovariateDirs, 1)==0,
    return;
end
tmpMsg=sprintf('Attention!\n\n\nDelete all data directories?');
if strcmpi(questdlg(tmpMsg, 'Clear confirmation'), 'Yes'),
    handles.Cfg.CovariateDirs(:)=[];
    if prod(size(handles.Cfg.CovariateDirs))==0,
        handles.Cfg.CovariateDirs={};
    end
    guidata(hObject, handles);
    UpdateDisplay(handles);
end

function ClearOC(hObject, eventdata, handles)
if prod(size(handles.Cfg.OtherTxt))==0 ...
        || size(handles.Cfg.OtherTxt, 1)==0,
    return;
end
tmpMsg=sprintf('Attention!\n\n\nDelete all data directories?');
if strcmpi(questdlg(tmpMsg, 'Clear confirmation'), 'Yes'),
    handles.Cfg.OtherTxt(:)=[];
    if prod(size(handles.Cfg.OtherTxt))==0,
        handles.Cfg.OtherTxt={};
    end
    guidata(hObject, handles);
    UpdateDisplay(handles);
end


