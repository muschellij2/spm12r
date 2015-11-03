function varargout = rest_NormalityTest_gui(varargin)
%   varargout = rest_NormalityTest_gui(varargin)
%	http://www.restfmri.net
% 	Mail to Authors:  <a href="Dawnwei.Song@gmail.com">SONG Xiao-Wei</a>; <a href="zangzx416@sina.com">Zang Zhen-Xiang</a>; <a href="dongzy08@gmail.com">DONG Zhang-Ye</a> 
%	Version=1.0;
%   
%   This function will perform a Lilliefors goodness-of-fit test or a 
%   Jarque-Bera goodness-of-fit test to determine that the data from 
%   given directory is normally distribute across subjects. For details 
%   of Lilliefors test and JB test, please view the help document of
%   MATLAB.
%   
%   Output: The output result will be a 3-dim paired map in .img and .hdr.
%   The value of every voxel in the result map is P value after estimating
%   the normality of the cross subject values. This P value ranges from
%   0.001 to 0.5. 
%
%   Thanks to: Dong Zhang-Ye, Yan Chao-Gan and Zhang Han for revising.
%   20111218

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @rest_NormalityTest_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @rest_NormalityTest_gui_OutputFcn, ...
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

function rest_NormalityTest_gui_OpeningFcn(hObject, eventdata, handles, varargin)

InitControlProperties(hObject, handles)
 [pathstr, name, ext] = fileparts(mfilename('fullpath'));	
 
    handles.Cfg.DataDirs ={}; %{[pathstr '\SampleData'], 10} ;	
    handles.Cfg.MaskFile = 'Default';                 %the  user defined mask file    	
	handles.Cfg.OutputDir =pwd;			    % pwd is the default dir for Normality map result
    handles.Cfg.rbtnJBTest=1;
	
    
    handles.Performance =0;
    
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
    movegui(handles.figNormalityTestMain, 'center');
	set(handles.figNormalityTestMain,'Name','Normality Test');
	
% Choose default command line output for rest_NormalityTest_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

function varargout = rest_NormalityTest_gui_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;

function listDataDirs_Callback(hObject, eventdata, handles)
	theIndex =get(hObject, 'Value');
	if isempty(theIndex) || theIndex<1,
        msgbox(sprintf('Nothing added.\n\nYou must add some diretories containing only paired {hdr/img} files first'), ...
					'REST' ,'help');
		return;
    end	
	
	if strcmp(get(handles.figNormalityTestMain, 'SelectionType'), 'open') %when double click 
	    msgbox(sprintf('%s \t\nhas\t %d\t volumes\n\nTotal: %d Data Directories' , ... 
					handles.Cfg.DataDirs{theIndex, 1} , ...
	                handles.Cfg.DataDirs{theIndex, 2} , ...
					size(handles.Cfg.DataDirs,1)), ...
					'Volume count in selected dir' ,'help');
	end

function listDataDirs_KeyPressFcn(hObject, eventdata, handles)
	%Delete the selected item when 'Del' is pressed
    key =get(handles.figFCMain, 'currentkey');
    if seqmatch({key},{'delete', 'backspace'})
        DeleteSelectedDataDir(hObject, eventdata,handles);
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
	

	
function listDataDirs_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	    set(hObject,'BackgroundColor','white');
	end



function edtDataDirectory_Callback(hObject, eventdata, handles)

function edtDataDirectory_CreateFcn(hObject, eventdata, handles)
     set(hObject,'String',pwd);

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function btnSelectDataDir_Callback(hObject, eventdata, handles)
if size(handles.Cfg.DataDirs, 1)>0
		theDir =handles.Cfg.DataDirs{1,1};
else
		theDir =pwd;
	end
    theDir =uigetdir(theDir, 'Please select the data directory to perform normality test:');
	if ischar(theDir),
		SetDataDir(hObject, theDir,handles);	
	end

function rbtnDefaultMask_Callback(hObject, eventdata, handles)
    set(handles.edtMaskfile, 'Enable','off', 'String','Use Default Mask');
	set(handles.btnSelectMask, 'Enable','off');	
	drawnow;
    handles.Cfg.MaskFile ='Default';
	guidata(hObject, handles);
    set(handles.rbtnDefaultMask,'Value',1);
	set(handles.rbtnNullMask,'Value',0);
	set(handles.rbtnUserMask,'Value',0);

function rbtnNullMask_Callback(hObject, eventdata, handles)
    set(handles.edtMaskfile, 'Enable','off', 'String','Don''t use any Mask');
	set(handles.btnSelectMask, 'Enable','off');
	drawnow;
	handles.Cfg.MaskFile ='';
	guidata(hObject, handles);
    set(handles.rbtnDefaultMask,'Value',0);
	set(handles.rbtnNullMask,'Value',1);
	set(handles.rbtnUserMask,'Value',0);

function rbtnUserMask_Callback(hObject, eventdata, handles)
    set(handles.edtMaskfile,'Enable','on', 'String',handles.Cfg.MaskFile);
	set(handles.btnSelectMask, 'Enable','on');
	set(handles.rbtnDefaultMask,'Value',0);
	set(handles.rbtnNullMask,'Value',0);
	set(handles.rbtnUserMask,'Value',1);
    drawnow;
	


function Run_Callback(hObject, eventdata, handles)

if (size(handles.Cfg.DataDirs, 1)==0) %check legal parameter set first
		errordlg('No Data found! Please re-config'); 
		return;
end

if get(handles.rbtnLillieforsTest,'Value') == 0 && get(handles.rbtnJBTest,'Value')==0,
    errordlg ('No method was seleceted! Please check');
    return;
end

    handles.Performance =cputime; %Write down the Start time , 20070903
	%start computation
	theOldDir =pwd;
	theOldColor=get(hObject,'BackgroundColor');		
	set(hObject,'Enable','off', 'BackgroundColor', 'red');
	drawnow;
for x=1:size(handles.Cfg.DataDirs, 1)	
    %Update display
	set(handles.listDataDirs, 'Value', x);
	drawnow;
    if size(handles.Cfg.DataDirs, 1)>1, 
					rest_waitbar((x-1)/size(handles.Cfg.DataDirs, 1)+0.01, ...
					handles.Cfg.DataDirs{x, 1}, ...
					'Normality Test performing','Parent');
    end
   thePrefix =[get(handles.edtPrefix, 'String')];
   theOutput=[get(handles.edtOutputDir, 'String'),thePrefix];
   % Method = 1: Lilliefors test; Mehod = 0: Jarque-Bera test
   Method = get(handles.rbtnLillieforsTest,'Value');
   rest_NormalityTest(handles.Cfg.DataDirs{x, 1},Method,theOutput,handles.Cfg.MaskFile);
   fprintf('\n\t Done');
  cd(theOldDir);
set(hObject,'Enable','on', 'BackgroundColor', theOldColor);
drawnow;
rest_waitbar;
end


function edtPrefix_Callback(hObject, eventdata, handles)

function edtPrefix_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtOutputDir_Callback(hObject, eventdata, handles)
	theDir =get(hObject, 'String');
	SetOutputDir(hObject,handles, theDir);
function edtOutputDir_CreateFcn(hObject, eventdata, handles)
    set(hObject,'String',pwd);
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnSelectOutputDir.
function btnSelectOutputDir_Callback(hObject, eventdata, handles)
	theDir =handles.Cfg.OutputDir;
	theDir =uigetdir(theDir, 'Please select the data directory to save Normality map: ');
	if ~isequal(theDir, 0)
		SetOutputDir(hObject,handles, theDir);	
	end	


function RecursiveAddDataDir(hObject, eventdata, handles)
	if prod(size(handles.Cfg.DataDirs))>0 && size(handles.Cfg.DataDirs, 1)>0,
		theDir =handles.Cfg.DataDirs{1,1};
	else
		theDir =pwd;
	end
	theDir =uigetdir(theDir, 'Please select the parent data directory of many sub-folders containing EPI data to regress out covarites: ');
	if ischar(theDir),
		%Make the warning dlg off! 20071201
		setappdata(0, 'FC_DoingRecursiveDir', 1);
		theOldColor =get(handles.listDataDirs, 'BackgroundColor');
		set(handles.listDataDirs, 'BackgroundColor', [ 0.7373    0.9804    0.4784]);
		try
			rest_RecursiveDir(theDir, 'rest_NormalityTest_gui(''SetDataDir'',gcbo, ''%s'', guidata(gcbo) )');
		catch
			rest_misc( 'DisplayLastException');
		end	
		set(handles.listDataDirs, 'BackgroundColor', theOldColor);
		rmappdata(0, 'FC_DoingRecursiveDir');
	end	

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
		%set(handles.listDataDirs, 'String',  handles.Cfg.DataDirs(: ,1) , 'Value', 1);	
		set(handles.listDataDirs, 'String',  GetInputDirDisplayList(handles) , 'Value', 1);
		theCount =size(handles.Cfg.DataDirs,1);
		if (theOldIndex>0) && (theOldIndex<= theCount)
			set(handles.listDataDirs, 'Value', theOldIndex);
		end
		set(handles.edtDataDirectory,'String', handles.Cfg.DataDirs{1,1});
	else
		set(handles.listDataDirs, 'String', '' , 'Value', 0);
    end
    set(handles.edtOutputDir ,'String', handles.Cfg.OutputDir);	
	% set(handles.pnlParametersInput,'Title', ...			%show the first dir's Volumn count in the panel's title	
		 % ['Input Parameters (Volumn count= '...
		  % num2str( cell2mat(handles.Cfg.DataDirs(1,2)) )...
		  % ' in 'handles.Cfg.DataDirs(1,1) ' )']);
    function Result=GetDirName(ADir)
	if isempty(ADir), Result=ADir; return; end
	theDir =ADir;
	if strcmp(theDir(end),filesep)==1
		theDir=theDir(1:end-1);
	end	
	[tmp,Result]=fileparts(theDir);

function SetOutputDir(hObject, handles, ADir)
	if 7==exist(ADir,'dir')
		handles.Cfg.OutputDir =ADir;
		guidata(hObject, handles);
	    UpdateDisplay(handles);
	end

function btnOutdir_Callback(hObject, eventdata, handles)
theDir =handles.Cfg.OutputDir;
theDir =uigetdir(theDir, 'Please select the output directory: ');
if ~isequal(theDir, 0)
    SetOutputDir(hObject,handles, theDir);
end
 
function InitControlProperties(hObject, handles)
    set(handles.edtMaskfile, 'Enable','off', 'String','Use Default Mask');
	set(handles.btnSelectMask, 'Enable','off');	
    handles.Cfg.MaskFile ='Default';
    set(handles.rbtnDefaultMask,'Value',1);
    handles.hContextMenu =uicontextmenu;
	set(handles.listDataDirs, 'UIContextMenu', handles.hContextMenu);	
	uimenu(handles.hContextMenu, 'Label', 'Add a directory', 'Callback', get(handles.btnSelectDataDir, 'Callback'));	
	uimenu(handles.hContextMenu, 'Label', 'Remove selected directory', 'Callback', 'rest_RegressOutCovariates_gui(''DeleteSelectedDataDir'',gcbo,[], guidata(gcbo))');
	
	
	% Save handles structure	
	guidata(hObject,handles);
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



function edtMaskfile_Callback(hObject, eventdata, handles)
    theMaskfile =get(hObject, 'String');
	if rest_misc('GetMatlabVersion')>=7.3,
		theMaskfile =strtrim(theMaskfile);
	end	
	if exist(theMaskfile, 'file')
		handles.Cfg.MaskFile =theMaskfile;
		guidata(hObject, handles);
	else
		errordlg(sprintf('The mask file "%s" does not exist!\n Please re-check it.', theMaskfile));
	end

function edtMaskfile_CreateFcn(hObject, eventdata, handles)
    set(hObject,'String',pwd);

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






% --- Executes on button press in btnSelectMask.
function btnSelectMask_Callback(hObject, eventdata, handles)

[filename, pathname] = uigetfile({'*.img;*.nii;*.nii.gz','Brain Image Files (*.img;*.nii;*.nii.gz)';'*.*', 'All Files (*.*)';}, ...
												'Pick a user''s  mask');
    if ~(filename==0)
        handles.Cfg.MaskFile =[pathname filename];
        set(handles.edtMaskfile, 'String',[pathname filename]);
        guidata(hObject,handles);
    elseif ~( exist(handles.Cfg.MaskFile, 'file')==2)
        set(handles.rbtnDefaultMask, 'Value',[1]);        
        set(handles.rbtnUserMask, 'Value',[0]); 
		set(handles.edtMaskfile, 'Enable','off');
		set(handles.btnSelectMask, 'Enable','off');			
		handles.Cfg.MaskFile ='Default';
		guidata(hObject, handles);        
    end    
    UpdateDisplay(handles);



% --- Executes on button press in rbtnLillieforsTest.
function rbtnLillieforsTest_Callback(hObject, eventdata, handles)
	set(handles.rbtnJBTest,'Value',0);
	set(handles.rbtnLillieforsTest,'Value',1);
    uiwait(msgbox({'Lilliefors test is a 2-sided goodness-of-fit test suitable for situations';...
    'where a fully-specified null distribution is not known, and its parameters';...
    'must be estimated.'},'Lilliefors test'));
    drawnow;


% --- Executes on button press in rbtnJBTest.
function rbtnJBTest_Callback(hObject, eventdata, handles)
	set(handles.rbtnJBTest,'Value',1);
	set(handles.rbtnLillieforsTest,'Value',0);
    uiwait(msgbox({'The Jarque-Bera test is a 2-sided goodness-of-fit test suitable for';...
    'situations where a fully-specified null distribution is not known, and its';...
    'parameters must be estimated. Jarque-Bera test is not suitable for small sample.'},'Jarque-Bera test'));
    drawnow;









% --- Executes on button press in btnReadMe.
function btnReadMe_Callback(hObject, eventdata, handles)
msgbox({'The current GUI performs the Lilliefors or Jarque-Bera goodness-of-fit test. The paired img/hdr file will be generated. The result is a P map ranking from 0.001 to 0.5.';...
    'Voxels with p less than a given threshold mean that the null hypothesis ("the data are normally distributed") will be rejected. If p is larger than a given threshold, it indicates that the distribution is normal.';...
    'For details, see MATLAB help'},'Help');



