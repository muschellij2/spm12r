function varargout = rest_ROIList_gui(varargin)
%List ROI definition list and edit for REST's functional connectivity by Xiao-Wei Song
%------------------------------------------------------------------------------------------------------------------------------
%	Copyright(c) 2007~2010
%	State Key Laboratory of Cognitive Neuroscience and Learning in Beijing Normal University
%	Written by Xiao-Wei Song 
%	http://resting-fmri.sourceforge.net
%------------------------------------------------------------------------------------------------------------------------------
% Begin initialization code - DO NOT EDIT
% 	Mail to Authors:  <a href="Dawnwei.Song@gmail.com">Xiaowei Song</a>; <a href="ycg.yan@gmail.com">Chaogan Yan</a> 
%   Revised by YAN Chao-Gan 080610: NIFTI compatible
%   Revised by Yan Chao-Gan 080808: also support NIFTI images.
%   Last Modified by DONG Zhang-Ye and Yan Chao-Gan 110504: Add "Add multiple user-defined mask files" function. 
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @rest_ROIList_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @rest_ROIList_gui_OutputFcn, ...
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


% --- Executes just before rest_ROIList_gui is made visible.
function rest_ROIList_gui_OpeningFcn(hObject, eventdata, handles, varargin)
	InitControls(hObject, handles);

	set(handles.listROI, 'String', '');
    if ~isempty(varargin),		
		%Calling convention: varargin{1} was discarded
		% x=roi_list('ListROI', './setRoi/listTest.rest_roi')
		% handles.ROISetFile =varargin{2};
		% handles.ROISetList =ReadROIDefineFile(handles);
		handles.ROISetList =varargin{1};
    	if ~isempty(handles.ROISetList) && ( isempty(handles.ROISetList{1}) || all(isspace(handles.ROISetList{1})) ),
        	handles.ROISetList(1) =[];
    	end
	else
		error('There must be 2 parameters at least!');
    end
    
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
    UpdateDisplay(handles);
    % UIWAIT makes rest_ROIList_gui wait for user response (see UIRESUME)
    try
        uiwait(handles.figListROI);
    catch
        uiresume(handles.figListROI);
    end


% --- Outputs from this function are returned to the command line.
function varargout = rest_ROIList_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
% uiwait(handles.figListROI);
% varargout{1} = handles.ROISetFile; %handles.output;
varargout{1} = handles.ROISetList;
delete(handles.figListROI);


function listROI_Callback(hObject, eventdata, handles)

function listROI_KeyPressFcn(hObject, eventdata, handles)
    key =get(handles.figListROI, 'currentkey');
    if seqmatch({key},{'delete', 'backspace'})
        theIndex =get(hObject, 'Value');
		if theIndex> size(handles.ROISetList, 1), return; end
        theDef   =handles.ROISetList{theIndex};        
        tmpMsg=sprintf('Delete\n\n "%s"?', theDef);
        if strcmp(questdlg(tmpMsg, 'Delete confirmation'), 'Yes')
			if theIndex>1,
				set(hObject, 'Value', theIndex-1);
			end
            handles.ROISetList(theIndex, :)=[];
			if size(handles.ROISetList, 1)==0
				handles.ROISetList={};
			end				
            guidata(hObject, handles);
            UpdateDisplay(handles);
        end
    end 
	
function listROI_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnDelete.
function btnDelete_Callback(hObject, eventdata, handles)
% hObject    handle to btnDelete (see GCBO) % handles    structure with handles and user data (see GUIDATA)
	theIndex =get(handles.listROI, 'Value');
	if theIndex> size(handles.ROISetList, 1), return; end
	theDef   =handles.ROISetList{theIndex};        
	tmpMsg=sprintf('Delete\n\n "%s"?', theDef);
	if strcmp(questdlg(tmpMsg, 'Delete confirmation'), 'Yes')
		if theIndex>1,
			set(handles.listROI, 'Value', theIndex-1);
			guidata(hObject, handles);
		end
		handles.ROISetList(theIndex, :)=[];
		if size(handles.ROISetList, 1)==0
			handles.ROISetList={};
		end			
		guidata(hObject, handles);
		UpdateDisplay(handles);
	end
	

% --- Executes on button press in btnAdd.
function btnAdd_Callback(hObject, eventdata, handles)
% hObject    handle to btnAdd (see GCBO)
	theROIDefinition=rest_SetROI;
	if ~isempty(theROIDefinition),		
		handles.ROISetList =[handles.ROISetList; {theROIDefinition}];
		set(handles.listROI, 'Value',size(handles.ROISetList, 1));
		guidata(hObject, handles);
		UpdateDisplay(handles);
	end

% --- Executes on button press in btnView.
function btnView_Callback(hObject, eventdata, handles)
	theIndex =get(handles.listROI, 'Value');
    AROIDef  =handles.ROISetList{theIndex};
	rest_misc( 'ViewROI', AROIDef); 

% --- Executes on button press in btnDone.
function btnDone_Callback(hObject, eventdata, handles)
% hObject    handle to btnDone (see GCBO)
	%Remove the empty data  at the first position from the list
    try
    	if isempty(handles.ROISetList{1}) || all(isspace(handles.ROISetList{1})),
        	handles.ROISetList(1) =[];
            guidata(hObject, handles);
    	end
    catch
    end
	uiresume(handles.figListROI);
	% delete(handles.figListROI);


function Result =ReadROIDefineFile(handles)
	%Check first
	[pathstr, name, ext] = fileparts(mfilename('fullpath'));
	theROIDir =fullfile(pathstr,'SetROI');
	% Result =handles.ROISetFile; %fullfile(theROIDir, AROIDefineFile);
	Result ={};
	if 7==exist(theROIDir,'dir') && 2==exist(handles.ROISetFile, 'file'),
		%Read the list from ROI definition file
		% Result =textread(handles.ROISetFile,'%s\n', 'whitespace', '');
		h =fopen(handles.ROISetFile, 'r');
		while 1,
		    tline = fgetl(h);
		    if ~ischar(tline), break; end
			Result =[Result; {tline}];
		end
		fclose(h);
	else%The definition dir and file doesn't exist
		if 7~=exist(theROIDir,'dir'),
			%I initialize the list file and the dir
			mkdir(theROIDir);
		end
		h=fopen(handles.ROISetFile, 'w');
		fclose(h);
		return;
	end
function UpdateDisplay(handles)
	set(handles.figListROI, 'Name', 'ROI Definition List');
	set(handles.listROI, 'String', handles.ROISetList);




function InitControls(hObject, handles)
	set(handles.pmnuMisc, 'String', {
		'Misc',
		'==========================================================',
        'Add multiple user-defined mask files',                         %Multiple Files 20110330 DONG,update some words 20110504,DONG and Yan Chao-Gan
		'Retrieve averaged time course from Selected ROI definition',
		'**********************************************************' , 
		'Export List of ROI definitions', 
		'Import List of ROI definitions', 
		'Clear Current List',
		'**********************************************************'}, ...
		'Position',[6 43 410 21],...
		'Value',1);	
		
	%Linux compatible
	set(handles.listROI,'Position',[5 74 411 208]);
	set(handles.btnDelete,'Position',[269 10 69 24]);
	set(handles.btnAdd, 'Position',[348 10 69 24]);
	set(handles.btnView,'Position',[85 10 69 24],'String','View ROI');
	set(handles.btnDone,'Position',[6 10 69 24],'String','Done');
	
	guidata(hObject, handles)
	
% --- Executes on selection change in pmnuMisc.
function pmnuMisc_Callback(hObject, eventdata, handles)
% hObject    handle to pmnuMisc (see GCBO)
	
	switch get(handles.pmnuMisc, 'Value'),
	case {1, 2, 5, 9},	%Misc or '---'
		%Do nothing
    case 3     %Multiple Files 20110330 DONG
        [filename, pathname] = uigetfile({'*.img;*.nii;*.nii.gz','Brain Image Files (*.img;*.nii;*.nii.gz)';'*.*', 'All Files (*.*)';},'Pick the  statistical map','MultiSelect','on'); 
        theLines={};
        if ~isempty(filename)
            if ~iscell(filename)
                theLines ={[pathname,filename]};
            else
                for i=1:size(filename,2)
                    theLines =[ theLines;{[pathname,filename{1,i}]}];
                end
            end
            guidata(hObject,handles);
        end
        
        handles.ROISetList =[handles.ROISetList; theLines];
        %Save before setting selected to the first of imported lines
        guidata(hObject, handles);
        set(handles.pmnuMisc, 'Value', size(handles.ROISetList,1) -size(theLines,1) +1);%Multiple Files 20110330 DONG
           
	case 4, %'Retrieve averaged time course from selected ROI definition'
		if prod(size(handles.ROISetList))>0 && size(handles.ROISetList, 1)>0,
			theIndex =get(handles.listROI, 'Value');
			AROIDef  =handles.ROISetList{theIndex};
			RetrieveTimeCourseFromROIDefinition(AROIDef);
		end
	case 6, %'Export List of ROI definitions'
		if  prod(size(handles.ROISetList))>0 && size(handles.ROISetList, 1)>0,
			[filename, pathname] = uiputfile('*.txt','Save current ROI definition''s list to a text file: ');
			if isequal(filename,0) | isequal(pathname,0),
			else
			   theFilename =fullfile(pathname,filename);
			   rest_misc( 'ExportCells2Txt', handles.ROISetList, theFilename);			   
			end
		end
		
	case 7, %'Import List of ROI definitions'
		[filename, pathname] = uigetfile('*.txt','Load current ROI definition''s list from a text file: ');
		if isequal(filename,0) | isequal(pathname,0),
		else
		   theFilename =fullfile(pathname,filename);
		   theLines=rest_misc( 'ImportLinesFromTxt', theFilename);
		   handles.ROISetList =[handles.ROISetList; theLines];
		   %Save before setting selected to the first of imported lines
		   guidata(hObject, handles);
		   set(handles.pmnuMisc, 'Value', size(handles.ROISetList,1) -size(theLines,1) +1);
		end
	
	case 8, %'Clear Current List'
		if  prod(size(handles.ROISetList))>0 && size(handles.ROISetList, 1)>0,
			tmpMsg=sprintf('Clear All %d ROI Definitions in the list?', size(handles.ROISetList, 1));
	        if strcmp(questdlg(tmpMsg, 'Clear confirmation'), 'Yes')				
	            handles.ROISetList={};
	        end
		end		
	
	otherwise
	end

	set(handles.pmnuMisc, 'Value', 1);
	guidata(hObject, handles);
	UpdateDisplay(handles);

% --- Executes during object creation, after setting all properties.
function pmnuMisc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pmnuMisc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function RetrieveTimeCourseFromROIDefinition(AROIDef)	
	try	
		theROIFilename ='ROITimeCourse_%s.txt';
		if rest_SphereROI( 'IsBallDefinition', AROIDef),
			%The ROI definition is a Ball definition			
			[filename, pathname] = uigetfile({'*.img;*.nii;*.nii.gz','Brain Image Files (*.img;*.nii;*.nii.gz)';'*.*', 'All Files (*.*)';}, ...
															'Pick one functional brain map(EPI)');
			if any(filename~=0) && ischar(filename) && length(filename)>4 ,	% not canceled and legal				
				%Get the 4D brain
				[the4DBrain, VoxelSize, ImgFileList, Header,nVolumn] =rest_to4d(pathname);				
				%Generate the mask				
				BrainSize =size(the4DBrain);
				BrainSize =BrainSize(1:3);				
				
				[AROICenter, AROIRadius] =rest_SphereROI('STR2ROIBALL', AROIDef);
				maskROI =rest_SphereROI( 'BallDefinition2Mask' , AROIDef, BrainSize, VoxelSize, Header);		
				theROIFilename =sprintf(theROIFilename, sprintf('%g_%g_%g_%g', AROICenter(1),AROICenter(2),AROICenter(3), AROIRadius));
			end
			
		elseif exist(AROIDef,'file')==2,	% Make sure the Definition file exist
			[pathstr, name, ext] = fileparts(AROIDef);
			if strcmpi(ext, '.txt'),
				warndlg(sprintf('%s\n\n is already a ROI time course definition!', AROIDef));
				return;
			elseif strcmpi(ext, '.img'),
				[filename, pathname] = uigetfile({'*.img;*.nii;*.nii.gz','Brain Image Files (*.img;*.nii;*.nii.gz)';'*.*', 'All Files (*.*)';}, ...
															'Pick one functional brain map(EPI)');
				if any(filename~=0) && ischar(filename) && length(filename)>4 ,	% not canceled and legal				
					%Get the 4D brain
					[the4DBrain, VoxelSize, ImgFileList, Header,nVolumn] =rest_to4d(pathname);	
					[nDim1, nDim2, nDim3, nDim4]=size(the4DBrain);
					%The ROI definition is a mask file
					maskROI =rest_loadmask(nDim1, nDim2, nDim3, AROIDef);
					theROIFilename =sprintf(theROIFilename, name);
				end
				
			else
				error(sprintf('REST doesn''t support the selected ROI definition now, Please check: \n%s', AROIDef));
			end
		else
			error(sprintf('Wrong ROI definition, Please check: \n%s', AROIDef));
		end
		
		%Retrieve the TimeCourse		
		maskROI = (0~=maskROI);
		theROITimeCourse =zeros(size(the4DBrain, 4), 1);
		for t=1:size(the4DBrain, 4),
			theTimePoint = squeeze(the4DBrain(:,:,:, t));
			theTimePoint = theTimePoint(maskROI);
			if ~isempty(theTimePoint),
				theROITimeCourse(t) =mean(theTimePoint);
			end
		end	%The Averaged Time Course within the ROI now comes out! 20070903				
		rest_waitbar;
		
		%Save ROI time course to a txt file
		[theROIFilename, pathname] = uiputfile(theROIFilename,'Save current ROI averaged time course to a text file: ');
		if isequal(theROIFilename,0) | isequal(pathname,0),
		else
			theFilename =fullfile(pathname,theROIFilename);		   
			save(theFilename, 'theROITimeCourse', '-ASCII', '-DOUBLE','-TABS')		
		end
	catch
		rest_misc( 'DisplayLastException');
	end	
	


% --- Executes when user attempts to close figListROI.
function figListROI_CloseRequestFcn(hObject, eventdata, handles)
	btnDone_Callback(hObject, eventdata, handles)
% Hint: delete(hObject) closes the figure
%delete(hObject);


