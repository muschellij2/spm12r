function varargout = rest_DicomSorter_gui(varargin)
%   varargout = rest_DicomSorter_gui(varargin)
%   Sort the DICOM files.
%   By YAN Chao-Gan and Dong Zhang-Ye 091212.
%   State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University, China, 100875
%	http://www.restfmri.net
% 	Mail to Authors:  <a href="ycg.yan@gmail.com">YAN Chao-Gan</a>; <a href="dongzy08@gmail.com">DONG Zhang-Ye</a>
%	Version=1.0;
%	Release=20091215;
%------------------------------------------------------------------------------------------------------------------------------

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @rest_DicomSorter_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @rest_DicomSorter_gui_OutputFcn, ...
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
% End initialization code - DO NOT EDIT


% --- Executes just before rest_DicomSorter_gui is made visible.
function rest_DicomSorter_gui_OpeningFcn(hObject, eventdata, handles, varargin)
InitControlProperties(hObject, handles);
handles.output = hObject;
handles.Cfg.DataDirs ={}; %{[pathstr '\SampleData'], 10} ;	   	
handles.Cfg.OutputDir =pwd;
handles.Cfg.Anonymize=0;
handles.Cfg.DirectoryHierarchy=0;
set(handles.edtOutDir ,'String', handles.Cfg.OutputDir);	

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
UpdateDisplay(handles);
movegui(handles.rest_DicomSorter_gui, 'center');
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = rest_DicomSorter_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listDataDirs.
function listDataDirs_Callback(hObject, eventdata, handles)
% hObject    handle to listDataDirs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listDataDirs contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listDataDirs


% --- Executes during object creation, after setting all properties.
function listDataDirs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listDataDirs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtDataDirectory_Callback(hObject, eventdata, handles)
% hObject    handle to edtDataDirectory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtDataDirectory as text
%        str2double(get(hObject,'String')) returns contents of edtDataDirectory as a double


% --- Executes during object creation, after setting all properties.
function edtDataDirectory_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtDataDirectory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnSelectDataDir.
function btnSelectDataDir_Callback(hObject, eventdata, handles)
if size(handles.Cfg.DataDirs, 1)>0
		theDir =handles.Cfg.DataDirs{1,1};
else
		theDir =pwd;
	end
    theDir =uigetdir(theDir, 'Please select the data directory to convert: ');
	if ischar(theDir),
		SetDataDir(hObject, theDir,handles);	
	end




function edtOutDir_Callback(hObject, eventdata, handles)
% hObject    handle to edtOutDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtOutDir as text
%        str2double(get(hObject,'String')) returns contents of edtOutDir as a double


% --- Executes during object creation, after setting all properties.
function edtOutDir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtOutDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnOutDir.
function btnOutDir_Callback(hObject, eventdata, handles)
theDir =handles.Cfg.OutputDir;
theDir =uigetdir(theDir, 'Please select the output directory: ');
if ~isequal(theDir, 0)
		SetOutputDir(hObject,handles, theDir);	
end	
function SetOutputDir(hObject, handles, ADir)
	if 7==exist(ADir,'dir')
		handles.Cfg.OutputDir =ADir;
        set(handles.edtOutDir,'String',ADir);
		guidata(hObject, handles);
	    UpdateDisplay(handles);
    end
    
function btnRun_Callback(hObject, eventdata, handles)
set(handles.btnOutDir,'Enable','off');
set(handles.btnRun,'Enable','off');
set(handles.btnSelectDataDir,'Enable','off');
drawnow;
dicomtype=get(handles.edtDicomType,'String');
mkdir([handles.Cfg.OutputDir]);
Anonymizeflag=get(handles.checkboxAnonymize,'Value');
for i=1:size(handles.Cfg.DataDirs, 1)
    outfile=[handles.Cfg.OutputDir];
    dirlist={};
    dirlist=[rest_DicomSorter(handles.Cfg.DataDirs{i},outfile,dicomtype,handles.Cfg.DirectoryHierarchy);dirlist];
    if Anonymizeflag
        outdirA=[outfile,'_','Anonymized'];
        if ~isdir(outdirA)
            mkdir(outdirA);
        end
        for j=1:size(dirlist,1)
            [path,dirnameA]=fileparts(dirlist{j});
            [path2,dirnameA2]=fileparts(path);
            outfileA=[outdirA,filesep,dirnameA2,filesep,dirnameA];
            if ~isdir(outfileA)
                mkdir(outfileA);
            end
            rest_ChangeDicomInfo(dirlist{j},outfileA,'',dicomtype);
        end
    end
end
rest_waitbar;
fprintf('Done ...\n');
set(handles.btnOutDir,'Enable','on');
set(handles.btnRun,'Enable','on');
set(handles.btnSelectDataDir,'Enable','on');
drawnow;

function InitControlProperties(hObject, handles)
    handles.hContextMenu =uicontextmenu;
	set(handles.listDataDirs, 'UIContextMenu', handles.hContextMenu);	
	uimenu(handles.hContextMenu, 'Label', 'Add a directory', 'Callback', get(handles.btnSelectDataDir, 'Callback'));	
	uimenu(handles.hContextMenu, 'Label', 'Remove selected directory', 'Callback', 'rest_DicomSorter_gui(''DeleteSelectedDataDir'',gcbo,[], guidata(gcbo))');
	uimenu(handles.hContextMenu, 'Label', 'Add recursively all sub-folders of a directory', 'Callback', 'rest_DicomSorter_gui(''RecursiveAddDataDir'',gcbo,[], guidata(gcbo))');
	uimenu(handles.hContextMenu, 'Label', '=============================');	
	uimenu(handles.hContextMenu, 'Label', 'Remove all data directories', 'Callback', 'rest_DicomSorter_gui(''ClearDataDirectories'',gcbo,[], guidata(gcbo))');
	
	
	% Save handles structure	
	guidata(hObject,handles);
    
function SetDataDir(hObject, ADir,handles)	
	if ~ischar(ADir), return; end	
	theOldWarnings =warning('off', 'all');
    % if (~isequal(ADir , 0)) &&( (size(handles.Cfg.DataDirs, 1)==0)||(0==seqmatch({ADir} ,handles.Cfg.DataDirs( : , 1) ) ) )
	if rest_misc('GetMatlabVersion')>=7.3,
		ADir =strtrim(ADir);
    end	
    dicomtype=get(handles.edtDicomType,'String');
	if (~isequal(ADir , 0)) &&( (size(handles.Cfg.DataDirs, 1)==0)||(0==length(strmatch(ADir,handles.Cfg.DataDirs( : , 1),'exact' ) ) ))
        handles.Cfg.DataDirs =[ {ADir , 0}; handles.Cfg.DataDirs];%update the dir    
		theVolumnCount =CheckDataDir(handles.Cfg.DataDirs{1,1},dicomtype);	
		if (theVolumnCount<=0),
			if isappdata(0, 'FC_DoingRecursiveDir') && getappdata(0, 'FC_DoingRecursiveDir'), 
			else
				fprintf('There is no data or non-data files in this directory:\n%s\nPlease re-select\n\n', ADir);
				errordlg( sprintf('There is no data or non-data files in this directory:\n\n%s\n\nPlease re-select', handles.Cfg.DataDirs{1,1} )); 
			end
			handles.Cfg.DataDirs(1,:)=[];
			if size(handles.Cfg.DataDirs, 1)==0
				handles.Cfg.DataDirs=[];
			end	%handles.Cfg.DataDirs = handles.Cfg.DataDirs( 2:end, :);%update the dir        
		else
			handles.Cfg.DataDirs{1,2} =theVolumnCount;
		end	
	
        guidata(hObject, handles);
        UpdateDisplay(handles);
    end
	warning(theOldWarnings);
function UpdateDisplay(handles)
	if size(handles.Cfg.DataDirs,1)>0	
		theOldIndex =get(handles.listDataDirs, 'Value');
		set(handles.listDataDirs, 'String',  GetInputDirDisplayList(handles) , 'Value', 1);
		theCount =size(handles.Cfg.DataDirs,1);
		if (theOldIndex>0) && (theOldIndex<= theCount)
			set(handles.listDataDirs, 'Value', theOldIndex);
		end
		set(handles.edtDataDirectory,'String', handles.Cfg.DataDirs{1,1});
	else
		set(handles.listDataDirs, 'String', '' , 'Value', 0);
    end
%    set(handles.edtVoxelSize,'String',handles.Cfg.VoxelSize);
function Result=GetDirName(ADir)
	if isempty(ADir), Result=ADir; return; end
	theDir =ADir;
	if strcmp(theDir(end),filesep)==1
		theDir=theDir(1:end-1);
	end	
	[tmp,Result]=fileparts(theDir);
function [nVolumn]=CheckDataDir(ADataDir,dicomtype)
theFilenames = dir(ADataDir);
nVolumn = 0;
if strcmp(dicomtype,'none')
    for count = 3:size(struct2cell(theFilenames),2)
        if	(length(theFilenames(count).name)>4) &&~theFilenames(count).isdir
            nVolumn = nVolumn + 1;
        end
    end
else
    for count = 3:size(struct2cell(theFilenames),2)
        if	(length(theFilenames(count).name)>4) && ...
                strcmpi(theFilenames(count).name(end-3:end) , ['.',dicomtype])
            nVolumn = nVolumn + 1;
        end
    end
end



function Result=GetInputDirDisplayList(handles)
	Result ={};
	for x=size(handles.Cfg.DataDirs, 1):-1:1
		Result =[{sprintf('%d# %s',handles.Cfg.DataDirs{x, 2},handles.Cfg.DataDirs{x, 1})} ;Result];
    end
function ClearDataDirectories(hObject, eventdata, handles)	
	if prod(size(handles.Cfg.DataDirs))==0 ...
		|| size(handles.Cfg.DataDirs, 1)==0,		
		return;
	end
	tmpMsg=sprintf('Attention!\n\n\nDelete all data directories?');
	if strcmpi(questdlg(tmpMsg, 'Clear confirmation'), 'Yes'),		
		handles.Cfg.DataDirs(:)=[];
		if prod(size(handles.Cfg.DataDirs))==0,
			handles.Cfg.DataDirs={};
		end	
		guidata(hObject, handles);
		UpdateDisplay(handles);
    end
function RecursiveAddDataDir(hObject, eventdata, handles)
	if prod(size(handles.Cfg.DataDirs))>0 && size(handles.Cfg.DataDirs, 1)>0,
		theDir =handles.Cfg.DataDirs{1,1};
	else
		theDir =pwd;
	end
	theDir =uigetdir(theDir, 'Please select the parent data directory of many sub-folders containing EPI data to convert: ');
	if ischar(theDir),
		%Make the warning dlg off! 20071201
		setappdata(0, 'FC_DoingRecursiveDir', 1);
		theOldColor =get(handles.listDataDirs, 'BackgroundColor');
		set(handles.listDataDirs, 'BackgroundColor', [ 0.7373    0.9804    0.4784]);
		try
			rest_RecursiveDir(theDir, 'rest_DicomSorter_gui(''SetDataDir'',gcbo, ''%s'', guidata(gcbo) )');
		catch
			rest_misc( 'DisplayLastException');
		end	
		set(handles.listDataDirs, 'BackgroundColor', theOldColor);
		rmappdata(0, 'FC_DoingRecursiveDir');
	end	
function DeleteSelectedDataDir(hObject, eventdata, handles)	
	theIndex =get(handles.listDataDirs, 'Value');
	if prod(size(handles.Cfg.DataDirs))==0 ...
		|| size(handles.Cfg.DataDirs, 1)==0 ...
		|| theIndex>size(handles.Cfg.DataDirs, 1),
		return;
	end
	theDir     =handles.Cfg.DataDirs{theIndex, 1};
	theVolumnCount=handles.Cfg.DataDirs{theIndex, 2};
	tmpMsg=sprintf('Delete\n\n "%s" \nVolumn Count :%d ?', theDir, theVolumnCount);
	if strcmp(questdlg(tmpMsg, 'Delete confirmation'), 'Yes')
		if theIndex>1,
			set(handles.listDataDirs, 'Value', theIndex-1);
		end
		handles.Cfg.DataDirs(theIndex, :)=[];
		if size(handles.Cfg.DataDirs, 1)==0
			handles.Cfg.DataDirs={};
		end	
		guidata(hObject, handles);
		UpdateDisplay(handles);
	end








function edtDicomType_Callback(hObject, eventdata, handles)
handles.Cfg.DataDirs ={};	
uiwait(msgbox('The DICOM file extension has been changed, please re-select the Data Dir.','Re-select Data Dir'));
guidata(hObject, handles);
UpdateDisplay(handles);


% --- Executes during object creation, after setting all properties.
function edtDicomType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtDicomType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxAnonymize.
function checkboxAnonymize_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    handles.Cfg.Anonymize = 1;
else
    handles.Cfg.Anonymize = 0;
end
guidata(hObject, handles);
set(handles.checkboxAnonymize,'Value',handles.Cfg.Anonymize);

 

% --- Executes on button press in radiobuttonSubjectFirst.
function radiobuttonSubjectFirst_Callback(hObject, eventdata, handles)
    handles.Cfg.DirectoryHierarchy=0;
    set(handles.radiobuttonSeriesFirst,'Value',0);
	set(handles.radiobuttonSubjectFirst,'Value',1);
    drawnow;    
	guidata(hObject, handles);   
    UpdateDisplay(handles); 
    
% --- Executes on button press in radiobuttonSeriesFirst.
function radiobuttonSeriesFirst_Callback(hObject, eventdata, handles)
    handles.Cfg.DirectoryHierarchy=1;
    set(handles.radiobuttonSeriesFirst,'Value',1);
	set(handles.radiobuttonSubjectFirst,'Value',0);
    drawnow;    
	guidata(hObject, handles);   
    UpdateDisplay(handles);  






