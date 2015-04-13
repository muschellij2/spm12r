function varargout = rest_ResliceImage_gui(varargin)
%   varargout = rest_ResliceImage_gui(varargin)
%   Reslice Images.
%   By YAN Chao-Gan and Dong Zhang-Ye, 091111.
%   State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University, China, 100875
%	http://www.restfmri.net
% 	Mail to Authors:  <a href="ycg.yan@gmail.com">YAN Chao-Gan</a>; <a href="dongzy08@gmail.com">DONG Zhang-Ye</a> 
%	Version=1.0;
%	Release=20091201;
%------------------------------------------------------------------------------------------------------------------------------

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @rest_ResliceImage_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @rest_ResliceImage_gui_OutputFcn, ...
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


% --- Executes just before rest_ResliceImage_gui is made visible.
function rest_ResliceImage_gui_OpeningFcn(hObject, eventdata, handles, varargin)
InitControlProperties(hObject, handles);
handles.output = hObject;
handles.Cfg.DataDirs ={}; %{[pathstr '\SampleData'], 10} ;	   	
handles.Cfg.OutputDir =pwd;
set(handles.edtOutDir ,'String', handles.Cfg.OutputDir);	
handles.Cfg.InputFile ='ImageItself';
%handles.Cfg.VoxelSize=3;
%handles.Cfg.OutputName='ROITimeCourse';

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
movegui(handles.rest_ResliceImage_gui, 'center');
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = rest_ResliceImage_gui_OutputFcn(hObject, eventdata, handles)
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
    theDir =uigetdir(theDir, 'Please select the data directory of images needed for reslicing: ');
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
set(handles.btnInputImage,'Enable','off');
set(handles.btnOutDir,'Enable','off');
set(handles.btnRun,'Enable','off');
set(handles.btnSelectDataDir,'Enable','off');
drawnow;
NewVoxSize=get(handles.edtNewVoxSize,'String');
NewVoxSize =eval(['[',NewVoxSize,']']);
hld=str2num(get(handles.edtHld,'String'));
TargetSpace=handles.Cfg.InputFile;
outname=get(handles.edtOutName,'String');
ImgFileList ={};
for i=1:size(handles.Cfg.DataDirs, 1)	
    theFileList = dir(fullfile(handles.Cfg.DataDirs{i},'*.hdr'));	
	if ~isempty(theFileList)
		for x = 1:size(struct2cell(theFileList),2)
			if strcmpi(theFileList(x).name(end-3:end), '.hdr') 
				ImgFileList=[ImgFileList; {[handles.Cfg.DataDirs{i},filesep,theFileList(x).name(1:end-4),'.img']}];
			end
		end
	else	%Add *.nii and *.nii.gz support 20120911 by Sandy
		theFileList = dir(fullfile(handles.Cfg.DataDirs{i},'*.nii'));
		if ~isempty(theFileList)
			for x=1:size(struct2cell(theFileList),2)
				ImgFileList=[ImgFileList ; {[handles.Cfg.DataDirs{i},filesep,theFileList(x).name]}];
			end
		else
			theFileList = dir(fullfile(handles.Cfg.DataDirs{i},'*.nii.gz'));
			if ~isempty(theFileList)
				for x=1:size(struct2cell)
					ImgFile=[ImgFileList ; {[handles.Cfg.DataDirs{i},filesep,theFileList(x).name]}];
				end
			else
				errordlg(sprintf('Please check %s, there is no dataset in it' , handles.Cfg.DataDirs{i} , 'NO DATASET!'));
			end	
		end
	end
end

for i=1:length(ImgFileList)
    if size(handles.Cfg.DataDirs, 1)>=1,
        rest_waitbar((i-1)/length(ImgFileList)+0.01, ...
            ImgFileList{i}, ...
            'Computing','Parent');
    end
    [Path, fileN, extn] = fileparts(ImgFileList{i});
    
    IndexFilesep = strfind(ImgFileList{i}, filesep);
    if ~isempty(IndexFilesep)
        DirNameTemp=ImgFileList{i}(IndexFilesep(end-1)+1:IndexFilesep(end)-1);
        PO=[handles.Cfg.OutputDir,filesep,DirNameTemp,'_',outname,filesep,outname,'_',fileN,'.nii'];%Change default data format to Nifti 20120911 by Sandy
        mkdir(fileparts(PO));
    else
        PO=[handles.Cfg.OutputDir,filesep,outname,'_',fileN,'.nii'];%Change default data format to Nifti 20120911 by Sandy
    end
    rest_ResliceImage(ImgFileList{i},PO,NewVoxSize,hld, TargetSpace);
end
rest_waitbar;
fprintf('Done ...\n');
set(handles.btnInputImage,'Enable','on');
set(handles.btnOutDir,'Enable','on');
set(handles.btnRun,'Enable','on');
set(handles.btnSelectDataDir,'Enable','on');
drawnow;
function InitControlProperties(hObject, handles)
    set(handles.edtInputImage, 'Enable','off', 'String','Keep the original space');
	set(handles.btnInputImage, 'Enable','off');	
    set(handles.rbtItself,'Value',1);
    handles.hContextMenu =uicontextmenu;
	set(handles.listDataDirs, 'UIContextMenu', handles.hContextMenu);	
	uimenu(handles.hContextMenu, 'Label', 'Add a directory', 'Callback', get(handles.btnSelectDataDir, 'Callback'));	
	uimenu(handles.hContextMenu, 'Label', 'Remove selected directory', 'Callback', 'rest_ResliceImage_gui(''DeleteSelectedDataDir'',gcbo,[], guidata(gcbo))');
	uimenu(handles.hContextMenu, 'Label', 'Add recursively all sub-folders of a directory', 'Callback', 'rest_ResliceImage_gui(''RecursiveAddDataDir'',gcbo,[], guidata(gcbo))');
	uimenu(handles.hContextMenu, 'Label', '=============================');	
	uimenu(handles.hContextMenu, 'Label', 'Remove all data directories', 'Callback', 'rest_ResliceImage_gui(''ClearDataDirectories'',gcbo,[], guidata(gcbo))');
	
	
	% Save handles structure	
	guidata(hObject,handles);
    
function SetDataDir(hObject, ADir,handles)	
	if ~ischar(ADir), return; end	
	theOldWarnings =warning('off', 'all');
    % if (~isequal(ADir , 0)) &&( (size(handles.Cfg.DataDirs, 1)==0)||(0==seqmatch({ADir} ,handles.Cfg.DataDirs( : , 1) ) ) )
	if rest_misc('GetMatlabVersion')>=7.3,
		ADir =strtrim(ADir);
	end	
	if (~isequal(ADir , 0)) &&( (size(handles.Cfg.DataDirs, 1)==0)||(0==length(strmatch(ADir,handles.Cfg.DataDirs( : , 1),'exact' ) ) ))
        handles.Cfg.DataDirs =[ {ADir , 0}; handles.Cfg.DataDirs];%update the dir    
		theVolumnCount =rest_CheckDataDir(handles.Cfg.DataDirs{1,1} );	
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
				%error('*.{hdr,img} should be pairwise. Please re-examin them.'); 
				nVolumn =-1;
				fprintf('%s, *.{hdr,img} should be pairwise. Please re-examin them.\n', ADataDir);	
				errordlg('*.{hdr,img} should be pairwise. Please re-examin them.'); 
				break;
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
	theDir =uigetdir(theDir, 'Please select the parent data directory of many sub-folders containing EPI data to reslice: ');
	if ischar(theDir),
		%Make the warning dlg off! 20071201
		setappdata(0, 'FC_DoingRecursiveDir', 1);
		theOldColor =get(handles.listDataDirs, 'BackgroundColor');
		set(handles.listDataDirs, 'BackgroundColor', [ 0.7373    0.9804    0.4784]);
		try
			rest_RecursiveDir(theDir, 'rest_ResliceImage_gui(''SetDataDir'',gcbo, ''%s'', guidata(gcbo) )');
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


% --- Executes on button press in rbtDefImg.
function rbtDefImg_Callback(hObject, eventdata, handles)
    if strcmp(handles.Cfg.InputFile,'ImageItself')
        set(handles.edtInputImage,'Enable','on', 'String','');
    else
        set(handles.edtInputImage,'Enable','on', 'String',handles.Cfg.InputFile);
    end
	set(handles.btnInputImage, 'Enable','on');
	set(handles.rbtItself,'Value',0);
	set(handles.rbtDefImg,'Value',1);
    drawnow;


% --- Executes on button press in rbtItself.
function rbtItself_Callback(hObject, eventdata, handles)
    set(handles.edtInputImage, 'Enable','off', 'String','Keep the original space');
	set(handles.btnInputImage, 'Enable','off');	
    set(handles.rbtDefImg,'Value',0);
    set(handles.rbtItself,'Value',1);
    handles.Cfg.InputFile='ImageItself';
    guidata(hObject, handles);



function edtInputImage_Callback(hObject, eventdata, handles)
% hObject    handle to edtInputImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtInputImage as text
%        str2double(get(hObject,'String')) returns contents of edtInputImage as a double


% --- Executes during object creation, after setting all properties.
function edtInputImage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtInputImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnInputImage.
function btnInputImage_Callback(hObject, eventdata, handles)
[filename, pathname] = uigetfile({'*.img;*.nii;*.nii.gz','Brain Image Files (*.img;*.nii;*.nii.gz)';'*.*', 'All Files (*.*)';}, ...
												'Pick a user''s  img');
    if ~(filename==0)
        handles.Cfg.InputFile =[pathname filename];
        set(handles.edtInputImage, 'String',[pathname filename]);
        [Data Vox Head]=rest_readfile(handles.Cfg.InputFile);
        set(handles.edtNewVoxSize, 'String', mat2str(Vox));
        guidata(hObject,handles);
        
    elseif ~( exist(handles.Cfg.InputFile, 'file')==2)
        set(handles.rbtItself, 'Value',[1]);        
        set(handles.rbtDefImg, 'Value',[0]); 
		set(handles.edtInputImage, 'Enable','off');
		set(handles.btnInputImage, 'Enable','off');			
		handles.Cfg.InputFile ='ImageItself';
		guidata(hObject, handles);        
    end    
    UpdateDisplay(handles);


function edtNewVoxSize_Callback(hObject, eventdata, handles)
% hObject    handle to edtNewVoxSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtNewVoxSize as text
%        str2double(get(hObject,'String')) returns contents of edtNewVoxSize as a double


% --- Executes during object creation, after setting all properties.
function edtNewVoxSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtNewVoxSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtHld_Callback(hObject, eventdata, handles)
% hObject    handle to edtHld (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtHld as text
%        str2double(get(hObject,'String')) returns contents of edtHld as a double


% --- Executes during object creation, after setting all properties.
function edtHld_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtHld (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtOutName_Callback(hObject, eventdata, handles)
% hObject    handle to edtOutName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtOutName as text
%        str2double(get(hObject,'String')) returns contents of edtOutName as a double


% --- Executes during object creation, after setting all properties.
function edtOutName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtOutName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


