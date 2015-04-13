function varargout = reho_gui(varargin)
%Regional Homogeneity based on Kendall's Coefficient of Concordance GUI by Xiaowei Song
%-----------------------------------------------------------
%	Copyright(c) 2007~2010
%	State Key Laboratory of Cognitive Neuroscience and Learning in Beijing Normal University
%	Written by Xiao-Wei Song 
%	http://resting-fmri.sourceforge.net
% $mail     =dawnwei.song@gmail.com
% $Version =1.0
% $Date    =20070421
%-----------------------------------------------------------
% 	<a href="Dawnwei.Song@gmail.com">Mail to Author</a>: Xiaowei Song
%	Version=1.3;
%	Release=20090420;
%   Modified by GUIDE v2.5 03-Nov-2007 20:10:43
%   Revised by Yan Chao-Gan 080808: also support NIFTI images.
%   Revised by YAN Chao-Gan, 090420. Designate the input file path and output file path for the revised reho.m
%   Last Revised by YAN Chao-Gan, 101025. Added KCC label.

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @reho_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @reho_gui_OutputFcn, ...
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


% --- Executes just before reho_gui is made visible.
function reho_gui_OpeningFcn(hObject, eventdata, handles, varargin)    
	%Matlab -Linux compatible, Initialize controls' default properties, dawnsong , 20070507
	InitControlProperties(hObject, handles);
	%Matlab -v6 compatible, create some frames instead of panels
	InitFrames(hObject,handles);
		
    [pathstr, name, ext] = fileparts(mfilename('fullpath'));	
	%the {hdr/img} directories to be processed , count of volumns(i.e. time series' point number) corresponding to the dir		
    handles.Cfg.DataDirs ={}; %{[pathstr '\SampleData'], 10} ;	
    handles.Cfg.MaskFile = 'Default';                 %the  user defined mask file    
	handles.Cfg.ClusterCount =27 ;			% the cluster type, 27 or 19 or 7	
	handles.Cfg.OutputDir =pwd;			    % pwd is the default dir for reho map result
	handles.Cfg.WantMeanRehoMap ='Yes';		%Calcute the mean ReHo map default
	handles.Filter.BandLow  =0.01;			%Config about Band pass filter, dawnsong 20070429
	handles.Filter.BandHigh =0.08;
	handles.Filter.UseFilter   	='No';
	handles.Filter.Retrend		='Yes';		% by default, do re-trend after linear filtering after removing linear trend and disable changing this value, 20070530 ZangYF decide
	handles.Filter.SamplePeriod=2;			%by default, set TR=2s
	handles.Detrend.BeforeFilter ='No';% ZangYF, 20070530 decide
	handles.Detrend.AfterFilter  ='No';% ZangYF, 20070530 decide
	handles.Log.SelfPath =pathstr;			% 20070507, dawnsong, just for writing log to file for further investigation
	handles.Log.Filename =GetLogFilename('', '');
	%Performance record, use elapsed time to describe it, 20070507
	handles.Performance =0;			
	
    guidata(hObject, handles);
    UpdateDisplay(handles);
	movegui(handles.figRehoMain, 'center');
	set(handles.figRehoMain,'Name','Regional Homogeneity based on Kendall''s Coefficient of Concordance');
	
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
    
    % Choose default command line output for reho_gui
    handles.output = hObject;	    
    guidata(hObject, handles);% Update handles structure

    % UIWAIT makes reho_gui wait for user response (see UIRESUME)
    % uiwait(handles.figRehoMain);

% --- Outputs from this function are returned to the command line.
function varargout = reho_gui_OutputFcn(hObject, eventdata, handles)
    % Get default command line output from handles structure
    varargout{1} = handles.output;

	
	
function edtDataDirectory_Callback(hObject, eventdata, handles)
	theDir =get(hObject, 'String');    
	restGui_SetDataDir(hObject,theDir, handles);		

function edtDataDirectory_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

    % --- Executes on button press in btnSelectDataDir.
function btnSelectDataDir_Callback(hObject, eventdata, handles)
	if prod(size(handles.Cfg.DataDirs))>0 && size(handles.Cfg.DataDirs, 1)>0,
		theDir =handles.Cfg.DataDirs{1,1};
	else
		theDir =pwd;
	end
    theDir =uigetdir(theDir, 'Please select the data directory to compute ReHo map: ');
	if ischar(theDir),
		restGui_SetDataDir(hObject, theDir,handles);	
	end
	
function RecursiveAddDataDir(hObject, eventdata, handles)
	if prod(size(handles.Cfg.DataDirs))>0 && size(handles.Cfg.DataDirs, 1)>0,
		theDir =handles.Cfg.DataDirs{1,1};
	else
		theDir =pwd;
	end
	theDir =uigetdir(theDir, 'Please select the parent data directory of many sub-folders containing EPI data to compute ReHo map: ');
	if ischar(theDir),
		%Make the warning dlg off! 20071201
		setappdata(0, 'ReHo_DoingRecursiveDir', 1);
		theOldColor =get(handles.listDataDirs, 'BackgroundColor');
		set(handles.listDataDirs, 'BackgroundColor', [ 0.7373    0.9804    0.4784]);
		try
			rest_RecursiveDir(theDir, 'reho_gui(''restGui_SetDataDir'',gcbo, ''%s'', guidata(gcbo) )');
		catch
			rest_misc( 'DisplayLastException');
		end	
		set(handles.listDataDirs, 'BackgroundColor', theOldColor);
		rmappdata(0, 'ReHo_DoingRecursiveDir');
	end
	
	
function restGui_SetDataDir(hObject,ADir, handles)	
	theOldWarnings =warning('off', 'all');
	if ~isequal(ADir , 0) && rest_misc('GetMatlabVersion')>=7.3,		
		ADir =strtrim(ADir);
	end	
	if (~isequal(ADir , 0)) &&( (size(handles.Cfg.DataDirs, 1)==0)||(0==length(strmatch(ADir,handles.Cfg.DataDirs( : , 1),'exact' ) ) ))
        %handles.Cfg.DataDirs =[ {ADir , 0}; handles.Cfg.DataDirs];%update the dir    
		handles.Cfg.DataDirs =[handles.Cfg.DataDirs ; {ADir,0}];
        %theVolumnCount =rest_CheckDataDir(handles.Cfg.DataDirs{1,1} );	
		DirList_Count=size(handles.Cfg.DataDirs,1);%Added by Sandy
        theVolumnCount =...
            rest_CheckDataDir(handles.Cfg.DataDirs{DirList_Count,1});		
		if (theVolumnCount<=0),
			if isappdata(0, 'ReHo_DoingRecursiveDir') && getappdata(0, 'ReHo_DoingRecursiveDir'), 
			else
				fprintf('There is no data or non-data files in this directory:\n%s\nPlease re-select\n\n', ADir);
				errordlg( sprintf('There is no data or non-data files in this directory:\n\n%s\n\nPlease re-select', handles.Cfg.DataDirs{1,1} )); 
            end
            %Fix a bug when no data in directory Sandy
			handles.Cfg.DataDirs(DirList_Count,:)=[];
			if size(handles.Cfg.DataDirs, 1)==0
				handles.Cfg.DataDirs=[];
			end	%handles.Cfg.DataDirs = handles.Cfg.DataDirs( 2:end, :);%update the dir        
		else
			handles.Cfg.DataDirs{DirList_Count,2} =theVolumnCount;
		end	
	
        guidata(hObject, handles);
        UpdateDisplay(handles);
    end
	warning(theOldWarnings);
	
%% Update All the uiControls' display on the GUI
function UpdateDisplay(handles)
	if size(handles.Cfg.DataDirs,1)>0	
		%theOldIndex =get(handles.listDataDirs, 'Value');
		%set(handles.listDataDirs, 'String',  handles.Cfg.DataDirs(: ,1) , 'Value', 1);	
        theCount =size(handles.Cfg.DataDirs,1);
		%set(handles.listDataDirs, 'String',  GetInputDirDisplayList(handles) , 'Value', 1);
		set(handles.listDataDirs, 'String',  GetInputDirDisplayList(handles) , 'Value', theCount);
        %Removed by Sandy
        %if (theOldIndex>0) && (theOldIndex<= theCount)
		%	set(handles.listDataDirs, 'Value', theOldIndex);
		%end
		set(handles.edtDataDirectory,'String', handles.Cfg.DataDirs{1,1});
		theResultFilename=get(handles.edtPrefix, 'String');
		theResultFilename=[theResultFilename '_' GetDirName(handles.Cfg.DataDirs{1,1})];
		set(handles.txtResultFilename, 'String', [theResultFilename  '.{hdr/img}']);
	else
		set(handles.listDataDirs, 'String', '' , 'Value', 0);
		set(handles.txtResultFilename, 'String', 'Result: Prefix_DirectoryName.{hdr/img}');
	end
	% set(handles.pnlParametersInput,'Title', ...			%show the first dir's Volumn count in the panel's title	
		 % ['Input Parameters (Volumn count= '...
		  % num2str( cell2mat(handles.Cfg.DataDirs(1,2)) )...
		  % ' in 'handles.Cfg.DataDirs(1,1) ' )']);
	set(handles.edtOutputDir ,'String', handles.Cfg.OutputDir);	
    if isequal(handles.Cfg.MaskFile, '')
        set(handles.edtMaskfile, 'String', 'Don''t use any Mask');
    else
        set(handles.edtMaskfile, 'String', handles.Cfg.MaskFile);    
    end
	%Set detrend dawnsong 20070820
	if strcmpi(handles.Detrend.BeforeFilter, 'Yes')
		%Update filter and detrend button's state according to Option: detrend/Filter 20070820
		set(handles.btnDetrend, 'Enable', 'on');
	else
		%Update filter and detrend button's state according to Option: detrend/Filter 20070820
		set(handles.btnDetrend, 'Enable', 'off');
	end
	%Set filter, dawnsong 20070430
	if strcmpi(handles.Filter.UseFilter, 'Yes')
		set(handles.ckboxFilter, 'Value', 1);		
		set(handles.ckboxRetrend, 'Enable', 'off');		
		set(handles.edtBandLow, 'Enable', 'on', 'String', num2str(handles.Filter.BandLow));
		set(handles.edtBandHigh, 'Enable', 'on', 'String', num2str(handles.Filter.BandHigh));
		set(handles.edtSamplePeriod, 'Enable', 'on', 'String', num2str(handles.Filter.SamplePeriod));
		%Update filter and detrend button's state according to Option: detrend/Filter 20070820
		set(handles.btnBandPass, 'Enable', 'on');		
	else
		set(handles.ckboxFilter, 'Value', 0);		
		set(handles.ckboxRetrend,'Enable', 'off');
		set(handles.edtBandLow, 'Enable', 'off', 'String', num2str(handles.Filter.BandLow));
		set(handles.edtBandHigh, 'Enable', 'off', 'String', num2str(handles.Filter.BandHigh));
		set(handles.edtSamplePeriod, 'Enable', 'off', 'String', num2str(handles.Filter.SamplePeriod));		
		%Update filter and detrend button's state according to Option: detrend/Filter 20070820
		set(handles.btnBandPass, 'Enable', 'off');		
	end
	%Set mean calculation, dawnsong 20070504
	set(handles.ckboxDivideMean, 'Value', strcmpi(handles.Cfg.WantMeanRehoMap, 'Yes'));		
	set(handles.ckboxRemoveTrendBefore, 'Value', strcmpi(handles.Detrend.BeforeFilter, 'Yes'));	
	set(handles.ckboxRemoveTrendAfter, 'Value', strcmpi(handles.Detrend.AfterFilter, 'Yes'));		
		

	
%% check the Data dir to make sure that there are only {hdr,img}
function Result=GetInputDirDisplayList(handles)
	Result ={};
	for x=size(handles.Cfg.DataDirs, 1):-1:1
		Result =[{sprintf('%d# %s',handles.Cfg.DataDirs{x, 2},handles.Cfg.DataDirs{x, 1})} ;Result];
	end

% in this dir
function [nVolumn]=CheckDataDir(ADataDir)
    theFilenames = dir(ADataDir);
	theHdrFiles=dir(fullfile(ADataDir,'*.hdr'));
	theImgFiles=dir(fullfile(ADataDir,'*.img'));
	% if (length(theFilenames)-length(theHdrFiles)-length(theImgFiles))>2
		% nVolumn =-1;
		% errordlg(sprintf(['There should not be any file other than *.{hdr,img} .' ...
					% 'Please re-examin the DataDir\n\n%s '] ...
					% , ADataDir)); 
		% return;
	% end
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
				fprintf('%s, *.{hdr,img} should be pairwise. Please re-examin them.', ADataDir);
				errordlg('*.{hdr,img} should be pairwise. Please re-examin them.'); 
				break;
			end
		end			
	end
    
	
%% --- Executes on button press in btnComputeReho.
function btnComputeReho_Callback(hObject, eventdata, handles)
	if (size(handles.Cfg.DataDirs, 1)==0) %check legal parameter set first
		errordlg('No Data found! Please re-config'); 
		return;
	end
    if (exist('reho.m','file')==2)
		%write log 20070507
		handles.Log.Filename =GetLogFilename(handles.Cfg.OutputDir, get(handles.edtPrefix, 'String'));
		Log2File(handles);
		handles.Performance =cputime; %Write down the Start time , 20070903
		%start computation
		theOldDir =pwd;
		theOldColor=get(hObject,'BackgroundColor');		
		set(hObject,'Enable','off', 'BackgroundColor', 'red');
		drawnow;
		try
			%%Remove the linear trend first, and create a new directory, then do filtering
			if strcmpi(handles.Filter.UseFilter, 'Yes') && strcmpi(handles.Detrend.BeforeFilter, 'Yes'),
				Detrend(hObject, handles);
				%20070614, Bug fix, Update the data structure manually
				handles =guidata(hObject);	% I have to read it again, because I change it for further processing		
			end	
			pause(0.01);
			%%Filter all the data and create a new directory, then compute the ReHo value, dawnsong 20070429
			%Band pass filter			
			if strcmpi(handles.Filter.UseFilter, 'Yes')
				BandPass(hObject, handles);	
				%20070614, Bug fix, Update the data structure manually
				handles =guidata(hObject);	% I have to read it again, because I change it for further processing		
			end	
			pause(0.01);			
			%%Remove the linear trend after filtering, and create a new directory, then do ReHo
			if strcmpi(handles.Filter.UseFilter, 'Yes') && strcmpi(handles.Detrend.AfterFilter, 'Yes'),
				Detrend(hObject, handles);
				%20070614, Bug fix, Update the data structure manually
				handles =guidata(hObject);	% I have to read it again, because I change it for further processing		
			end
			pause(0.01);
			%compute the ReHo brain
			%if size(handles.Cfg.DataDirs, 1)>1,%remove by sandy 20120830 
			%	rest_waitbar(0,'ReHo Batch Compution, wait ...','ReHo','Parent');
            %end
            pause(0.01);
            PF_DataDirs=handles.Cfg.DataDirs(:,1);
            theOutputDir=get(handles.edtOutputDir, 'String');
            thePrefix =get(handles.edtPrefix, 'String');
            PF_ClusterCount=handles.Cfg.ClusterCount;
            PF_MaskFile=handles.Cfg.MaskFile;
            WantMeanRehoMpa=handles.Cfg.WantMeanRehoMap;
			parfor x=1:size(PF_DataDirs , 1)
				%Update display
				%set(handles.listDataDirs, 'Value', x);
				%drawnow;
				%if size(handles.Cfg.DataDirs, 1)>1, 
				%	rest_waitbar((x-1)/size(handles.Cfg.DataDirs, 1)+0.01, ...
				%				handles.Cfg.DataDirs{x, 1}, ...
				%				'ReHo Computing','Parent');
				%end
				
				%cd(handles.Cfg.DataDirs{x, 1});%Change current dir to the data dir	
				fprintf('\nReHo :\n');		
                
				theDstFile=fullfile(theOutputDir,[thePrefix '_' ...
											GetDirName(PF_DataDirs{x}) ] );
		        
                reho(   PF_DataDirs{x}, ...
		                PF_ClusterCount, ...
		                PF_MaskFile, ...
                        theDstFile);      % Revised by YAN Chao-Gan, 090420. Designate the input file path and output file path for the revised reho.m
                    
				%20070504, divide ReHo brain by the mean within the mask
				if strcmpi(WantMeanRehoMpa, 'Yes')
					theOrigReHoMap =theDstFile;				
					theMeanReHoMap =fullfile(theOutputDir,['m' thePrefix '_' ...
												GetDirName(PF_DataDirs{x}) ] );
					theMaskFile =PF_MaskFile;
					rest_DivideMeanWithinMask(theOrigReHoMap, theMeanReHoMap, theMaskFile);
				end
			end	
			handles.Performance =cputime -handles.Performance; %Write down the End time , 20070903
			LogPerformance(handles);
		catch	
			rest_misc( 'DisplayLastException');
			errordlg(sprintf('Exception occured: \n\n%s' , lasterr)); 
		end
		rest_waitbar;
		cd(theOldDir);
		set(hObject,'Enable','on', 'BackgroundColor', theOldColor);
		drawnow;
    else
        errordlg('No reho.m ! Please re-install'); 
    end

%%
function edtMaskfile_Callback(hObject, eventdata, handles)
	theMaskfile =get(hObject, 'String');
	if ~isequal(theMaskfile , 0) && rest_misc('GetMatlabVersion')>=7.3,
		theMaskfile =strtrim(theMaskfile);
	end	
	if exist(theMaskfile, 'file')
		handles.Cfg.MaskFile =theMaskfile;
		guidata(hObject, handles);
	else
		errordlg(sprintf('The mask file "%s" does not exist!\n Please re-check it.', theMaskfile));
	end
	
% --- Executes during object creation, after setting all properties.
function edtMaskfile_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	    set(hObject,'BackgroundColor','white');
	end


%% --- Executes on button press in btnSelectMask.
function btnSelectMask_Callback(hObject, eventdata, handles)
    [filename, pathname] = uigetfile({'*.img;*.nii;*.nii.gz','Brain Image Files (*.img;*.nii;*.nii.gz)';'*.*', 'All Files (*.*)';}, ...
												'Pick a user''s  mask');
    if ~(filename==0)
        handles.Cfg.MaskFile =[pathname filename];
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

%% --- Select Default mask
function rbtnDefaultMask_Callback(hObject, eventdata, handles)	
	set(handles.btnSelectMask, 'Enable','off');		
    handles.Cfg.MaskFile ='Default';
	guidata(hObject, handles);
    set(handles.rbtnDefaultMask,'Value',1);
	set(handles.rbtnNullMask,'Value',0);
	set(handles.rbtnUserMask,'Value',0);
    
% --- Executes on button press in rbtnNullMask.
function rbtnNullMask_Callback(hObject, eventdata, handles)
	set(handles.edtMaskfile, 'Enable','off', 'String','Don''t use any Mask');
	set(handles.btnSelectMask, 'Enable','off');
	drawnow;
	handles.Cfg.MaskFile ='';
	guidata(hObject, handles);
    set(handles.rbtnDefaultMask,'Value',0);
	set(handles.rbtnNullMask,'Value',1);
	set(handles.rbtnUserMask,'Value',0);
		
%% --- Select user defined mask
function rbtnUserMask_Callback(hObject, eventdata, handles)
	set(handles.edtMaskfile,'Enable','on', 'String',handles.Cfg.MaskFile);
	set(handles.btnSelectMask, 'Enable','on');
	set(handles.rbtnDefaultMask,'Value',0);
	set(handles.rbtnNullMask,'Value',0);
	set(handles.rbtnUserMask,'Value',1);
    drawnow;
% --- Executes on button press in rbtn27voxels.
function rbtn27voxels_Callback(hObject, eventdata, handles)
	handles.Cfg.ClusterCount =27;
	guidata(hObject, handles);
    set(handles.rbtn7voxels,'Value',0);
	set(handles.rbtn19voxels,'Value',0);
	set(handles.rbtn27voxels,'Value',1);

% --- Executes on button press in rbtn19voxels.
function rbtn19voxels_Callback(hObject, eventdata, handles)
	handles.Cfg.ClusterCount =19;
	guidata(hObject, handles);
    set(handles.rbtn7voxels,'Value',0);
	set(handles.rbtn19voxels,'Value',1);
	set(handles.rbtn27voxels,'Value',0);
    
% --- Executes on button press in rbtn7voxels.
function rbtn7voxels_Callback(hObject, eventdata, handles)
	handles.Cfg.ClusterCount =7;
	guidata(hObject, handles);    
	set(handles.rbtn7voxels,'Value',1);
	set(handles.rbtn19voxels,'Value',0);
	set(handles.rbtn27voxels,'Value',0);

%% Double-click to show the volumn count of the selected dir
function listDataDirs_Callback(hObject, eventdata, handles)
    theIndex =get(hObject, 'Value');
    if isempty(theIndex) || theIndex<1,
        msgbox(sprintf('Nothing added.\n\nYou must add some diretories containing only paired {hdr/img} files first'), ...
					'REST' ,'help');
		return;
    end
	if strcmp(get(handles.figRehoMain, 'SelectionType'), 'open') %when double click 
	    msgbox(sprintf('%s \t\nhas\t %d\t volumes\n\nTotal: %d Data Directories' , ... 
					handles.Cfg.DataDirs{theIndex, 1} , ...
	                handles.Cfg.DataDirs{theIndex, 2} , ...
					size(handles.Cfg.DataDirs,1)), ...
					'Volume count in selected dir' ,'help');
	end
	
function listDataDirs_KeyPressFcn(hObject, eventdata, handles)
    %Delete the selected item when 'Del' is pressed
    key =get(handles.figRehoMain, 'currentkey');
    if seqmatch({key},{'delete', 'backspace'})
        DeleteSelectedDataDir(hObject, eventdata, handles);
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
	
function listDataDirs_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	    set(hObject,'BackgroundColor','white');
	end

function edtPrefix_Callback(hObject, eventdata, handles)
%nothing need to do, because I get the prefix when I need. Look at line 229 "thePrefix =get(handles.edtPrefix, 'String');"
	UpdateDisplay(handles);

function edtPrefix_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	    set(hObject,'BackgroundColor','white');
	end

function edtOutputDir_Callback(hObject, eventdata, handles)
	theDir =get(hObject, 'String');	
	SetOutputDir(hObject,handles, theDir);	
	

function edtOutputDir_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	    set(hObject,'BackgroundColor','white');
	end

function btnSelectOutputDir_Callback(hObject, eventdata, handles)
	theDir =handles.Cfg.OutputDir;
	theDir =uigetdir(theDir, 'Please select the data directory to compute ReHo map: ');
	if ~isequal(theDir, 0)
		SetOutputDir(hObject,handles, theDir);	
	end	
	
function SetOutputDir(hObject, handles, ADir)
	if 7==exist(ADir,'dir')
		handles.Cfg.OutputDir =ADir;
		guidata(hObject, handles);
	    UpdateDisplay(handles);
	end

function Result=GetDirName(ADir)
	if isempty(ADir), Result=ADir; return; end
	theDir =ADir;
	if strcmp(theDir(end),filesep)==1
		theDir=theDir(1:end-1);
	end	
	[tmp,Result]=fileparts(theDir);
	
%Matlab -v6 compatible, create some frames instead of panels
	
% --- Executes on button press in ckboxFilter.
function ckboxFilter_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
		handles.Filter.UseFilter ='Yes';
	else	
		handles.Filter.UseFilter ='No';
	end	
	guidata(hObject, handles);
	UpdateDisplay(handles);

function edtBandLow_Callback(hObject, eventdata, handles)
	handles.Filter.BandLow =str2double(get(hObject,'String'));
	guidata(hObject, handles);

function edtBandLow_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edtBandHigh_Callback(hObject, eventdata, handles)
	handles.Filter.BandHigh =str2double(get(hObject,'String'));
	guidata(hObject, handles);
	
function edtBandHigh_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function ckboxRetrend_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
		handles.Filter.Retrend ='Yes';
	else	
		handles.Filter.Retrend ='No';
	end	
	guidata(hObject, handles);
	UpdateDisplay(handles);
	
function edtSamplePeriod_Callback(hObject, eventdata, handles)
	handles.Filter.SamplePeriod =str2double(get(hObject,'String'));
	guidata(hObject, handles);
	
function edtSamplePeriod_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	    set(hObject,'BackgroundColor','white');
	end



%Divide ReHo brain by the mean within the mask, output: mRehoMap.{hdr/img}
function ckboxDivideMean_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
		handles.Cfg.WantMeanRehoMap ='Yes';
	else	
		handles.Cfg.WantMeanRehoMap ='No';
	end
	guidata(hObject, handles);
	UpdateDisplay(handles);
	
% ---Manaul Operations, Divide one rehomap by its global mean
function btnDivideMean_Callback(hObject, eventdata, handles)
	theOldColor=get(hObject,'BackgroundColor');		
	set(hObject,'Enable','off', 'BackgroundColor', 'red');
	drawnow;
	try
		[filename, pathname] = uigetfile({'*.img;*.nii;*.nii.gz','Brain Image Files (*.img;*.nii;*.nii.gz)';'*.*', 'All Files (*.*)';}, ...
													'Pick one ReHo map');
	    if (filename~=0)% not canceled
			if strcmpi(filename(end-3:end), '.img')%revise filename to remove extension		
				filename = filename(1:end-4);
			end
			if ~strcmpi(pathname(end), filesep)%revise dir name to remove the last \ or /		
				pathname = [pathname filesep];
			end
			theOrigReHoMap =[pathname filename];
			theMeanReHoMap =[pathname 'm' filename];
			theMaskFile =handles.Cfg.MaskFile;
			rest_DivideMeanWithinMask(theOrigReHoMap, theMeanReHoMap, theMaskFile);
			msgbox(sprintf('ReHo brain "%s.{hdr/img}" \ndivide its mean within mask successfully.\t\n\nSave to "%s.{hdr/img}"\n' , ... 
					theOrigReHoMap, theMeanReHoMap), ...				
					'Divide mean within mask successfully' ,'help');
	    end    
	catch
		rest_misc( 'DisplayLastException');
	end
	set(hObject,'Enable','on', 'BackgroundColor', theOldColor);
	drawnow;
% manually band pass filter	
function btnBandPass_Callback(hObject, eventdata, handles)
	theOldColor=get(hObject,'BackgroundColor');		
	set(hObject,'Enable','off', 'BackgroundColor', 'red');
	drawnow;
	try
	    %Band pass filter
		if strcmpi(handles.Filter.UseFilter, 'Yes')
			BandPass(hObject, handles);
			msgbox('Ideal Band Pass filter Over.',...
					'Filter successfully' ,'help');
		else
			errordlg(sprintf('You didn''t select option "Band Pass". \n\nPlease slect first.'));
		end
		UpdateDisplay(handles);		
	catch
		rest_misc( 'DisplayLastException');
	end	
	rest_waitbar;
	set(hObject,'Enable','on', 'BackgroundColor', theOldColor);
	drawnow;
    
%%Create GUI

%%Create Frames/Lines
function InitFrames(hObject,handles);
	offsetY =80; %dawnsong, 20070504, add for the divide by the mask mean, the Y of Edit "OutPut Diectory"
	% for Matlab 6.5 compatible, draw a panel
	uicontrol(handles.figRehoMain, 'Style','Frame','Position',[2 offsetY+151 433 1]);
	uicontrol(handles.figRehoMain, 'Style','Frame','Position',[2 offsetY+241 433 1]);
	uicontrol(handles.figRehoMain, 'Style','Frame','Position',[90 offsetY+152 1 90]);	
	uicontrol(handles.figRehoMain, 'Style','Frame','Position',[2 offsetY+152 1 233]);	
	uicontrol(handles.figRehoMain, 'Style','Frame','Position',[435 offsetY+152 1 233]);	
	uicontrol(handles.figRehoMain, 'Style','Frame','Position',[2 offsetY+385 433 1]);	
	uicontrol(handles.figRehoMain,'Style','Text','Position',[152 offsetY+380 140 14],...
		'String','Input Parameters');
	uicontrol(handles.figRehoMain,'Style','Text','Position',[8 offsetY+238 40 14],...
		'String','Cluster');	
	uicontrol(handles.figRehoMain,'Style','Text','Position',[208 offsetY+238 40 14],...
		'String','Mask');	
	
	uicontrol(handles.figRehoMain, 'Style','Frame','Position',[2 offsetY+94 433 1]);	
	uicontrol(handles.figRehoMain, 'Style','Frame','Position',[2 offsetY-8 433 1]);	
	uicontrol(handles.figRehoMain, 'Style','Frame','Position',[2 offsetY-8 1 102]);	
	uicontrol(handles.figRehoMain, 'Style','Frame','Position',[435 offsetY-8 1 102]);	
	uicontrol(handles.figRehoMain,'Style','Text','Position',[152 offsetY+88 160 14],...
		'String','Output Parameters (ReHo map)');
		
	uicontrol(handles.figRehoMain, 'Style','Frame','Position',[2 offsetY+400 433 1]);	
	uicontrol(handles.figRehoMain, 'Style','Frame','Position',[435 offsetY+400 1 50]);	
	uicontrol(handles.figRehoMain, 'Style','Frame','Position',[2 offsetY+400 1 50]);	
	uicontrol(handles.figRehoMain, 'Style','Frame','Position',[2 offsetY+450 433 1]);	
	uicontrol(handles.figRehoMain,'Style','Text','Position',[142 offsetY+445 180 14],...
		'String','Option: Ideal Band Pass Filter');
	
	uicontrol(handles.figRehoMain, 'Style','Frame','Position',[2 offsetY+465 433 1]);	
	uicontrol(handles.figRehoMain, 'Style','Frame','Position',[435 offsetY+465 1 50]);	
	uicontrol(handles.figRehoMain, 'Style','Frame','Position',[2 offsetY+465 1 50]);	
	uicontrol(handles.figRehoMain, 'Style','Frame','Position',[2 offsetY+515 433 1]);	
	uicontrol(handles.figRehoMain,'Style','Text','Position',[142 offsetY+505 180 14],...
		'String','Option: Remove Linear Trend');
	
	
	%20070506, Add manual operation button groups like SPM
	uicontrol(handles.figRehoMain, 'Style','Frame','Position',[2 offsetY-25 433 1]);	
	uicontrol(handles.figRehoMain,'Style','Text','Position',[152 offsetY-30 140 14],...
		'String','Manual Operations');
	

function InitControlProperties(hObject, handles)
	%for Linux compatible 20070507 dawnsong
	% --- FIGURE -------------------------------------
	set(handles.figRehoMain,...
		'Units', 'pixels', ...
		'Position', [10 5 440 600], ...
		'Name', 'reho_gui', ...
		'MenuBar', 'none', ...
		'NumberTitle', 'off', ...		
		'Color', get(0,'DefaultUicontrolBackgroundColor'));

	% --- STATIC TEXTS -------------------------------------
	set(handles.text2,	...
		'Style', 'text', ...
		'Units', 'pixels', ...
		'Position', [16 186 170 40], ...
		'FontSize', 24, ...
		'FontWeight', 'bold', ...
        'ToolTipString','Regional Homogeneity based on Kendall''s Coefficient of Concordance', ...
		'String', 'KCC-ReHo');

	set(handles.text4,	...
		'Style', 'text', ...
		'Units', 'pixels', ...
		'Position', [8 109 80 21], ...
		'String', 'Directory:');

	set(handles.txtInputDir,	...
		'Style', 'text', ...
		'Units', 'pixels', ...
		'Position', [7 336 80 21], ...
		'String', 'Data Directory:');

	set(handles.text5,	...
		'Style', 'text', ...
		'Units', 'pixels', ...
		'Position', [9 140 80 21], ...
		'String', 'Prefix:');

	set(handles.txtResultFilename,	...
		'Style', 'text', ...
		'Units', 'pixels', ...
		'Position', [227 148 200 16], ...
		'HorizontalAlignment','left'         , ...
		'String', 'Result: Prefix_DirectoryName.{hdr/img}');

	set(handles.text7,	...
		'Style', 'text', ...
		'Units', 'pixels', ...
		'Position', [144 476 25 51], ...
		'FontSize', 28, ...		
		'String', '~');

	set(handles.text8,	...
		'Style', 'text', ...
		'Units', 'pixels', ...
		'Position', [230 491 45 16], ...
		'String', 'TR: (s)');

	% --- PUSHBUTTONS -------------------------------------
	set(handles.btnSelectOutputDir,	...
		'Style', 'pushbutton', ...
		'Units', 'pixels', ...
		'Position', [396 107 30 25], ...
		'FontSize', 18, ...
		'String', '...');

	set(handles.btnSelectDataDir,	...
		'Style', 'pushbutton', ...
		'Units', 'pixels', ...
		'Position', [396 334 30 25], ...
		'FontSize', 18, ...
		'String', '...', ...
		'CData', zeros(1,0));

	set(handles.btnSelectMask,	...
		'Style', 'pushbutton', ...
		'Units', 'pixels', ...
		'Position', [396 240 30 25], ...
		'FontSize', 18, ...
		'String', '...', ...
		'Enable', 'off', ...
		'CData', zeros(1,0));

	set(handles.btnComputeReho,	...
		'Style', 'pushbutton', ...
		'Units', 'pixels', ...
		'Position', [316 186 110 33], ...
		'FontSize', 12, ...
		'FontWeight', 'bold', ...
		'String', 'Do all');

	
	set(handles.btnDetrend , ...
		'Style', 'pushbutton', ...
		'Units', 'pixels', ...
		'Position', [337 553 90 25], ...
		'FontSize', 10, ...
		'Enable', 'off', ...   %Update filter and detrend button's state according to Option: detrend/Filter 20070820
		'String', 'Detrend');
	set(handles.btnBandPass , ...
		'Style', 'pushbutton', ...
		'Units', 'pixels', ...
		'Position', [337 490 90 25], ...
		'FontSize', 10, ...
		'Enable', 'off', ...  %Update filter and detrend button's state according to Option: detrend/Filter 20070820
		'String', 'Filter');
	set(handles.btnHelp,	...
		'Style', 'pushbutton', ...
		'Units', 'pixels', ...
		'Position', [10 10 90 33], ...
		'FontSize', 10, ...
		'String', 'Help');	
	set(handles.btnDivideMean,	...
		'Style', 'pushbutton', ...
		'Units', 'pixels', ...
		'Position', [110 10 90 33], ...
		'FontSize', 10, ...
		'String', 'Divide Mean');
	set(handles.btnSliceViewer,	...
		'Style', 'pushbutton', ...
		'Units', 'pixels', ...
		'Position', [210 10 90 33], ...
		'FontSize', 10, ...
		'String', 'Slice Viewer');	
	set(handles.btnWaveGraph,	...
		'Style', 'pushbutton', ...
		'Units', 'pixels', ...
		'Position', [314 10 110 33], ...
		'FontSize', 10, ...
		'String', 'Power Spectrum');
		
		
	% --- RADIO BUTTONS -------------------------------------
	set(handles.rbtn7voxels,	...
		'Style', 'radiobutton', ...
		'Units', 'pixels', ...
		'Position', [10 298 70 16], ...
		'String', '7 voxels');

	set(handles.rbtn19voxels,	...
		'Style', 'radiobutton', ...
		'Units', 'pixels', ...
		'Position', [10 273 70 16], ...
		'String', '19 voxels');

	set(handles.rbtn27voxels,	...
		'Style', 'radiobutton', ...
		'Units', 'pixels', ...
		'Position', [10 248 70 16], ...
		'String', '27 voxels');

	set(handles.rbtnDefaultMask,	...
		'Style', 'radiobutton', ...
		'Units', 'pixels', ...
		'Position', [110 297 158 16], ...
		'String', 'Default mask');

	set(handles.rbtnUserMask,	...
		'Style', 'radiobutton', ...
		'Units', 'pixels', ...
		'Position', [110 271 148 16], ...
		'String', 'User-defined mask');

	set(handles.rbtnNullMask,	...
		'Style', 'radiobutton', ...
		'Units', 'pixels', ...
		'Position', [277 298 82 16], ...
		'String', 'No mask');

	% --- CHECKBOXES -------------------------------------
	set(handles.ckboxFilter, ...
		'Style', 'checkbox', ...
		'Units', 'pixels', ...
		'Position', [14 491 80 22], ...
		'String', 'Band (Hz)');
	set(handles.ckboxRetrend, ...		
		'Style', 'checkbox', ...
		'Units', 'pixels', ...
		'Visible', 'off', ...
		'Position', [366 490 60 22], ...
		'String', 'Retrend');
	set(handles.ckboxDivideMean,	...
		'Style', 'checkbox', ...
		'Units', 'pixels', ...
		'Position', [12 82 430 19], ...
		'String', 'Divide ReHo brain by the mean within the mask (mPrefix_DirectoryName.{hdr/img})');
	set(handles.ckboxRemoveTrendBefore, ...
		'Style', 'checkbox', ...
		'Units', 'pixels', ...
		'Position', [13 555 140 21],...
		'String', 'detrend');		%'String', 'detrend BEFORE Filter');
	set(handles.ckboxRemoveTrendAfter, ...
		'Style', 'checkbox', ...
		'Units', 'pixels', ...
		'Position', [171 555 140 21],...
		'Visible', 'off', ...
		'String', 'detrend AFTER Filter');

		
	% --- EDIT TEXTS -------------------------------------
	set(handles.edtOutputDir,	...
		'Style', 'edit', ...
		'Units', 'pixels', ...
		'Position', [94 109 300 23], ...
		'BackgroundColor', [1 1 1], ...
		'String', 'Edit Text');

	set(handles.edtDataDirectory,	...
		'Style', 'edit', ...
		'Units', 'pixels', ...
		'Position', [94 336 300 22], ...
		'BackgroundColor', [1 1 1], ...
		'String', '');

	set(handles.edtMaskfile,	...
		'Style', 'edit', ...
		'Units', 'pixels', ...
		'Position', [94 240 300 23], ...
		'BackgroundColor', [1 1 1], ...
		'String', 'Edit Text', ...
		'Enable', 'off');

	set(handles.edtPrefix,	...
		'Style', 'edit', ...
		'Units', 'pixels', ...
		'Position', [94 142 115 22], ...
		'BackgroundColor', [1 1 1], ...
		'String', 'RehoMap');

	set(handles.edtBandLow,	...
		'Style', 'edit', ...
		'Units', 'pixels', ...
		'Position', [94 491 50 22], ...
		'BackgroundColor', [1 1 1], ...
		'String', '0.01', ...
		'Enable', 'off');

	set(handles.edtBandHigh,	...
		'Style', 'edit', ...
		'Units', 'pixels', ...
		'Position', [171 491 50 22], ...
		'BackgroundColor', [1 1 1], ...
		'String', '0.08', ...
		'Enable', 'off');

	set(handles.edtSamplePeriod,	...
		'Style', 'edit', ...
		'Units', 'pixels', ...
		'Position', [276 491 50 22], ...
		'BackgroundColor', [1 1 1], ...
		'String', '2', ...
		'Enable', 'off');

	% --- LISTBOXES -------------------------------------
	set(handles.listDataDirs,	...
		'Style', 'listbox', ...
		'Units', 'pixels', ...
		'Position', [14 363 413 98], ...
		'BackgroundColor', [1 1 1], ...
		'String', '');

	%20071103, Add context menu to Input Data Directories to add��delete��export��import����
	handles.hContextMenu =uicontextmenu;
	set(handles.listDataDirs, 'UIContextMenu', handles.hContextMenu);	
	uimenu(handles.hContextMenu, 'Label', 'Add a directory', 'Callback', get(handles.btnSelectDataDir, 'Callback'));	
	uimenu(handles.hContextMenu, 'Label', 'Remove selected directory', 'Callback', 'reho_gui(''DeleteSelectedDataDir'',gcbo,[], guidata(gcbo))');
	uimenu(handles.hContextMenu, 'Label', 'Add recursively all sub-folders of a directory', 'Callback', 'reho_gui(''RecursiveAddDataDir'',gcbo,[], guidata(gcbo))');
	uimenu(handles.hContextMenu, 'Label', '=============================');	
	uimenu(handles.hContextMenu, 'Label', 'Remove all data directories', 'Callback', 'reho_gui(''ClearDataDirectories'',gcbo,[], guidata(gcbo))');
	
		
	% Save handles structure
	guidata(hObject,handles);

%% Log options to a log file for further investigation, 20070507
function Log2File(handles)
	constLineSep= '-------------------------------------------------------------------------------';
	[theVer, theRelease] =rest_misc( 'GetRestVersion');
	theMsgVersion = sprintf('REST Version:%s, Release %s\r\n%s\r\n', theVer, theRelease, constLineSep);	
	theMsgHead = sprintf('ReHo computation log %s\r\n%s\r\n', rest_misc( 'GetDateTimeStr'), constLineSep);
	theMsg =sprintf('%s\r\n%s\r\n\r\n%s', theMsgVersion, theMsgHead, constLineSep);
	theMsg =sprintf('%s\r\nRemove Linear Trend options:\r\n%s\r\n\r\n%s',theMsg,...
					LogRemoveLinearTrend(handles), constLineSep);
	theMsg =sprintf('%s\r\nIdeal Band Pass filter options:\r\n%s\r\n\r\n%s',theMsg,...
					LogBandPassFilter(handles), constLineSep);
	theMsg =sprintf('%s\r\nReHo input parameters:\r\n%s\r\n\r\n%s', theMsg, ...
					LogReHoInputParameters(handles), constLineSep);
	theMsg =sprintf('%s\r\nReHo output parameters:\r\n%s\r\n\r\n%s', theMsg, ...
					LogReHoOutputParameters(handles), constLineSep);
	
	fid = fopen(handles.Log.Filename,'w');
	if fid~=-1
		fprintf(fid,'%s',theMsg);
		fclose(fid);
	else
		errordlg(sprintf('Error to open log file:\n\n%s', handles.Log.Filename));
	end


	
%Log the total elapsed time by once "Do all"
function LogPerformance(handles)	
	theMsg =sprintf('\r\n\r\nTotal elapsed time for Regional Homogeneity Computing: %g  seconds\r\n',handles.Performance);
	fid = fopen(handles.Log.Filename,'r+');
	fseek(fid, 0, 'eof');
	if fid~=-1
		fprintf(fid,'%s',theMsg);
		fclose(fid);
	else
		errordlg(sprintf('Error to open log file:\n\n%s', handles.Log.Filename));
	end

	
function ResultLogString=LogRemoveLinearTrend(handles)
	ResultLogString ='';
	ResultLogString =sprintf('%s\tremove linear trend BEFORE filter: %s\r\n',ResultLogString, handles.Detrend.BeforeFilter);
	%ResultLogString =sprintf('%s\tremove linear trend AFTER filter: %s\r\n',ResultLogString, handles.Detrend.AfterFilter);
	
function ResultLogString=LogBandPassFilter(handles)
	ResultLogString ='';		
	ResultLogString =sprintf('%s\tUse Filter: %s\r\n',ResultLogString, handles.Filter.UseFilter);
	ResultLogString =sprintf('%s\tBand Low: %g\r\n', ResultLogString, handles.Filter.BandLow);
	ResultLogString =sprintf('%s\tBand High: %g\r\n',ResultLogString, handles.Filter.BandHigh);
	ResultLogString =sprintf('%s\tSample Period(i.e. TR): %g\r\n',ResultLogString, handles.Filter.SamplePeriod);
	
function ResultLogString=LogReHoInputParameters(handles)
	ResultLogString ='';
	constLineSep= '-------------------------------------------------------------------------------';
	theDataDirString= '';
	theDataDirCells =get(handles.listDataDirs, 'string');
	for x=1:length(theDataDirCells)
		theDataDirString =sprintf('%s\r\n\t%s', theDataDirString, theDataDirCells{x});
	end
	theDirType ='';
	if strcmpi(handles.Detrend.BeforeFilter, 'Yes')
		theDirType =sprintf(' %s after Detrend processing', theDirType);
	end
	if strcmpi(handles.Detrend.BeforeFilter, 'Yes') && ...
		strcmpi(handles.Filter.UseFilter, 'Yes'),
		theDirType =sprintf(' %s and ', theDirType);
	end
	if strcmpi(handles.Filter.UseFilter, 'Yes')
		theDirType =sprintf(' %s after Filter processing', theDirType);
	end
	ResultLogString =sprintf('%s\tInput Data Directories( %s): \r\n\t%s%s\r\n\t%s\r\n',ResultLogString,...
							theDirType, ...
							constLineSep, ...
							theDataDirString, ...
							constLineSep);
	ResultLogString =sprintf('%s\tMask file: %s\r\n', ResultLogString, handles.Cfg.MaskFile);
	ResultLogString =sprintf('%s\tCluster Count: %g\r\n',ResultLogString, handles.Cfg.ClusterCount);	
		
function ResultLogString=LogReHoOutputParameters(handles)
	ResultLogString ='';
	ResultLogString =sprintf('%s\tPrefix to the Data directories: %s\r\n',ResultLogString, get(handles.edtPrefix, 'String'));
	ResultLogString =sprintf('\tOutput Prefix: %s\r\n', get(handles.edtPrefix, 'String'));
	ResultLogString =sprintf('%s\tOutput Data Directories: %s\r\n',ResultLogString, handles.Cfg.OutputDir);
	ResultLogString =sprintf('%s\tWant mean ReHo map computation: %s \r\n',ResultLogString, handles.Cfg.WantMeanRehoMap);
	

	
	
%compose the log filename	
function ResultLogFileName=GetLogFilename(ALogDirectory, APrefix)
	if isempty(ALogDirectory)
		[pathstr, name, ext] = fileparts(mfilename('fullpath'));	
		ALogDirectory =pathstr;
	end
	if ~strcmp(ALogDirectory(end), filesep)
		ALogDirectory =[ALogDirectory filesep];
	end
	ResultLogFileName=sprintf('%s%s_%sReHo.log', ...
		ALogDirectory, ...
		APrefix, ...
		rest_misc( 'GetDateTimeStr'));


function btnSliceViewer_Callback(hObject, eventdata, handles)
%Display a brain image like MRIcro
	theOldColor=get(hObject,'BackgroundColor');		
	set(hObject,'Enable','off', 'BackgroundColor', 'red');
	drawnow;
	try
		rest_sliceviewer;
		% [filename, pathname] = uigetfile({'*.img', 'ANALYZE or NIFTI files (*.img)'}, ...
														% 'Pick one brain map');
		% if any(filename~=0) && ischar(filename) && length(filename)>4 ,	% not canceled and legal			
			% if ~strcmpi(pathname(end), filesep)%revise pathname to add \ or /
				% pathname = [pathname filesep];
			% end
			% theBrainMap =[pathname filename];
			% rest_sliceviewer('ShowImage', theBrainMap);
		% end
	catch
		rest_misc( 'DisplayLastException');
	end	
	set(hObject,'Enable','on', 'BackgroundColor', theOldColor);
	drawnow;


function btnWaveGraph_Callback(hObject, eventdata, handles)
	%Display a brain image like MRIcro, and show specific voxel's time course and its freq domain's fluctuation
	theOldColor=get(hObject,'BackgroundColor');		
	set(hObject,'Enable','off', 'BackgroundColor', 'red');
	drawnow;
	try
        rest_Powerspectrum_start; %YAN Chao-Gan, 101025. Use new program to start power spectrum.
% 		% if strcmpi(handles.Filter.UseFilter, 'Yes'),
% 		% else
% 			% msgbox(sprintf('You didn''t select option "Band Pass" before show Wave Graph. \n\nYou may enable it first and then you can set Band parameter and TR.'));
% 		% end
% 		[filename, pathname] = uigetfile({'*.img', 'ANALYZE or NIFTI files (*.img)'}, ...
% 														'Pick one functional EPI brain map in the dataset''s directory');
% 		if any(filename~=0) && ischar(filename) && length(filename)>4 ,	% not canceled and legal			
% 			if ~strcmpi(pathname(end), filesep)%revise pathname to remove extension		
% 				pathname = [pathname filesep];
% 			end
% 			theBrainMap 	=[pathname filename];			
% 			theViewer =rest_sliceviewer('ShowImage', theBrainMap);
% 			
% 			%Set the ALFF figure to show corresponding voxel's time-course and its freq amplitude
% 			theDataSetDir 	=pathname;
% 			theVoxelPosition=rest_sliceviewer('GetPosition', theViewer);
% 			theSamplePeriod =handles.Filter.SamplePeriod;
% 			theBandRange	=[handles.Filter.BandLow, handles.Filter.BandHigh];						
% 			rest_powerspectrum('ShowFluctuation', theDataSetDir, theVoxelPosition, ...
% 							theSamplePeriod, theBandRange);
% 							
% 			%Update the Callback
% 			theCallback 	='';
% 			cmdDataSetDir	=sprintf('theDataSetDir= ''%s'';', theDataSetDir);
% 			cmdBrainMap 	=sprintf('theVoxelPosition=rest_sliceviewer(''GetPosition'', %g);', theViewer);
% 			cmdSamplePeriod =sprintf('theSamplePeriod= %g;', handles.Filter.SamplePeriod);
% 			cmdBandRange	=sprintf('theBandRange= [%g, %g];', handles.Filter.BandLow, handles.Filter.BandHigh);
% 			cmdUpdateWaveGraph	='rest_powerspectrum(''ShowFluctuation'', theDataSetDir, theVoxelPosition, theSamplePeriod, theBandRange);';
% 			theCallback	=sprintf('%s\n%s\n%s\n%s\n%s\n',cmdDataSetDir, ...
% 								cmdBrainMap, cmdSamplePeriod, cmdBandRange, ...
% 								cmdUpdateWaveGraph);
% 			cmdClearVar ='clear theDataSetDir theVoxelPosition theSamplePeriod theBandRange;';
% 			rest_sliceviewer('UpdateCallback', theViewer, [theCallback cmdClearVar], 'ALFF Analysis');
% 			
% 			% Update some Message
% 			theMsg =sprintf('TR( s): %g\nBand( Hz): %g~%g', ...
% 							theSamplePeriod, theBandRange(1), theBandRange(2) );
% 			rest_sliceviewer('SetMessage', theViewer, theMsg);				
% 		end		
	catch
		rest_misc( 'DisplayLastException');
	end	
	set(hObject,'Enable','on', 'BackgroundColor', theOldColor);
	drawnow;
	rest_waitbar;


function ckboxRemoveTrendBefore_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
		handles.Detrend.BeforeFilter ='Yes';
	else	
		handles.Detrend.BeforeFilter ='No';
	end	
	guidata(hObject, handles);
	UpdateDisplay(handles);

function ckboxRemoveTrendAfter_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
		handles.Detrend.AfterFilter ='Yes';
	else	
		handles.Detrend.AfterFilter ='No';
	end	
	guidata(hObject, handles);
	UpdateDisplay(handles);


% --- Executes on button press in btnDetrend.
function btnDetrend_Callback(hObject, eventdata, handles)
	theOldColor=get(hObject,'BackgroundColor');		
	set(hObject,'Enable','off', 'BackgroundColor', 'red');
	drawnow;
	try
		Detrend(hObject,handles);
		msgbox('Remove the Linear Trend Over.',...
				'Detrend successfully' ,'help');
	catch
		rest_misc( 'DisplayLastException');
	end
	rest_waitbar;	
	set(hObject,'Enable','on', 'BackgroundColor', theOldColor);
	drawnow;
	
function Detrend(hObject,handles)
	PF_DataDirs=handles.Cfg.DataDirs(:,1);
    tic;
    parfor x=1:size(PF_DataDirs, 1)	
		%Update display
		%set(handles.listDataDirs, 'Value', x);
		%drawnow;
		%Changed by Sandy Wang for parallel computing 20120518
        %if size(handles.Cfg.DataDirs, 1)>1,
		%	rest_waitbar((x-1)/size(handles.Cfg.DataDirs, 1)+0.01, ...
		%			handles.Cfg.DataDirs{x, 1}, ...
		%			'Removing the Linear Trend','Parent');
		%end		
		rest_detrend(PF_DataDirs{x}, '_detrend');
    end
    for x=1:size(PF_DataDirs, 1)
		%Revise the data directories
		handles.Cfg.DataDirs{x, 1}=[handles.Cfg.DataDirs{x, 1} , '_detrend'];
    end
    guidata(hObject, handles);	% Save Dir names
    toc;
    set(handles.listDataDirs, 'Value', size(PF_DataDirs, 1));
	UpdateDisplay(handles);

function BandPass(hObject, handles)
	%add by Sandy Wang 20120430 for parallel computation
    PF_DataDirs=handles.Cfg.DataDirs(:,1);
    PF_BandHigh=handles.Filter.BandHigh;
    PF_SamplePeriod=handles.Filter.SamplePeriod;
    PF_BandLow=handles.Filter.BandLow;
    PF_Retrend=handles.Filter.Retrend;
    PF_MaskFile=handles.Cfg.MaskFile;
    %for x=1:size(handles.Cfg.DataDirs, 1)
    parfor x=1:size(PF_DataDirs, 1)
		%Update display
		%set(handles.listDataDirs, 'Value', x);
		%drawnow;
		%if size(handles.Cfg.DataDirs, 1)>1,
		%	rest_waitbar((x-1)/size(handles.Cfg.DataDirs, 1)+0.01, ...
		%			handles.Cfg.DataDirs{x, 1}, ...
		%			'Band Pass filter','Parent');
		%end
				
        %rest_(handles.Cfg.DataDirs{x, 1}, ...
        %              handles.Filter.SamplePeriod, ...								  
        %              handles.Filter.BandHigh, ...
        %              handles.Filter.BandLow, ...
        %              handles.Filter.Retrend, ...
        %              handles.Cfg.MaskFile);
        rest_bandpass(PF_DataDirs{x}, ...
                      PF_SamplePeriod, ...								  
                      PF_BandHigh, ...
                      PF_BandLow, ...
                      PF_Retrend, ...
                      PF_MaskFile);
    end
    for x=1:size(handles.Cfg.DataDirs, 1)
		%build the postfix for filtering
		thePostfix ='_filtered';					
		%Revise the data directories
		handles.Cfg.DataDirs{x, 1}=[handles.Cfg.DataDirs{x, 1} , thePostfix];
    end
    guidata(hObject, handles);% Save Dir names    
    set(handles.listDataDirs, 'Value', size(PF_DataDirs, 1));
	UpdateDisplay(handles);

function btnHelp_Callback(hObject, eventdata, handles)
	web('http://resting-fmri.sourceforge.net');
	%web (sprintf('%s/man/English/ReHo/index.html', rest_misc( 'WhereIsREST')), '-helpbrowser');

