function varargout = f_alff_gui(varargin)
%ALFF GUI by Xiaowei Song
%-----------------------------------------------------------
%	Copyright(c) 2007~2010
%	State Key Laboratory of Cognitive Neuroscience and Learning in Beijing Normal University
%	Written by Xiao-Wei Song
%	http://www.restfmri.net
% $mail     =dawnwei.song@gmail.com
% $Version =1.4;
% $Date =20100420;
%-----------------------------------------------------------
% 	Mail to Authors:  <a href="Dawnwei.Song@gmail.com">Xiaowei Song</a>; <a href="ycg.yan@gmail.com">Chaogan Yan</a>
%	Version=1.4;
%	Release=20100420;
%   Revised by YAN Chao-Gan 080808: also support NIFTI images.
%   Revised by YAN Chao-Gan 090321, added the fALFF module. Thank Dr. CHENG Wen-Lian for the helpful work.
%   Revised by YAN Chao-Gan, 100420. Fixed a bug in calculating the frequency band.
%   Last Revised by Sandy Wang, 120719. Added parfor.

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @f_alff_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @f_alff_gui_OutputFcn, ...
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


% --- Executes just before f_alff_gui is made visible.
function f_alff_gui_OpeningFcn(hObject, eventdata, handles, varargin)
	%Matlab -Linux compatible, Initialize controls' default properties, dawnsong , 20070507
	InitControlProperties(hObject, handles);
	%Matlab -v6 compatible, create some frames instead of panels
	InitFrames(hObject,handles);

    [pathstr, name, ext] = fileparts(mfilename('fullpath'));
	%the {hdr/img} directories to be processed , count of volumns(i.e. time series' point number) corresponding to the dir
    handles.Cfg.DataDirs ={}; %{[pathstr '\SampleData'], 10} ;
    handles.Cfg.MaskFile = 'Default';                 %the  user defined mask file
	handles.Cfg.OutputDir =pwd;			    % pwd is the default dir for f_alff map result
	handles.Cfg.WantMeanfAlffMap ='Yes';		%Calcute the mean f_alff map default
	handles.Filter.BandLow  =0.01;			%Config about Band pass filter, dawnsong 20070429
	handles.Filter.BandHigh =0.08;
	handles.Filter.UseFilter   	='No';
	handles.Filter.Retrend		='Yes';		% by default, always re-trend after linear filtering after removing linear trend	20070614, bug fixes
	handles.Filter.SamplePeriod=2;			%by default, set TR=2s
	handles.Detrend.BeforeFilter ='No';% ZangYF, 20070530 decide
	handles.Detrend.AfterFilter  ='No';% ZangYF, 20070530 decide
	handles.fALFF.BandLow =0.01;				% Band Info for fALFF computing
	handles.fALFF.BandHigh =0.08;			% Band Info for fALFF computing
	handles.fALFF.SamplePeriod =2;			% Band Info for fALFF computing
	handles.Log.SelfPath =pathstr;			% 20070507, dawnsong, just for writing log to file for further investigation
	handles.Log.Filename =GetLogFilename('','');
	%Performance record, use elapsed time to describe it, 20070507
	handles.Performance =0;

    guidata(hObject, handles);
    UpdateDisplay(handles);
	movegui(handles.figfAlffMain, 'center');
	set(handles.figfAlffMain,'Name','Fractional Amplitude of Low Frequency Fluctuation');

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

    % Choose default command line output for f_alff_gui
    handles.output = hObject;
    guidata(hObject, handles);% Update handles structure

	% UIWAIT makes f_alff_gui wait for user response (see UIRESUME)
	% uiwait(handles.figfAlffMain);

% --- Outputs from this function are returned to the command line.
function varargout = f_alff_gui_OutputFcn(hObject, eventdata, handles)
	% Get default command line output from handles structure
	varargout{1} = handles.output;




function edtDataDirectory_Callback(hObject, eventdata, handles)
	theDir =get(hObject, 'String');
	SetDataDir(hObject, theDir,handles);

function edtDataDirectory_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	    set(hObject,'BackgroundColor','white');
	end


function btnSelectDataDir_Callback(hObject, eventdata, handles)
	if size(handles.Cfg.DataDirs, 1)>0
		theDir =handles.Cfg.DataDirs{1,1};
	else
		theDir =pwd;
	end
    theDir =uigetdir(theDir, 'Please select the data directory to compute f_alff map: ');
	if ischar(theDir),
		SetDataDir(hObject, theDir,handles);
	end

function RecursiveAddDataDir(hObject, eventdata, handles)
	if prod(size(handles.Cfg.DataDirs))>0 && size(handles.Cfg.DataDirs, 1)>0,
		theDir =handles.Cfg.DataDirs{1,1};
	else
		theDir =pwd;
	end
	theDir =uigetdir(theDir, 'Please select the parent data directory of many sub-folders containing EPI data to compute fALFF map: ');
	if ischar(theDir),%Make the warning dlg off! 20071201
		setappdata(0, 'fALFF_DoingRecursiveDir', 1);
		theOldColor =get(handles.listDataDirs, 'BackgroundColor');
		set(handles.listDataDirs, 'BackgroundColor', [ 0.7373    0.9804    0.4784]);
		try
			rest_RecursiveDir(theDir, 'f_alff_gui(''SetDataDir'',gcbo, ''%s'', guidata(gcbo) )');
		catch
			rest_misc( 'DisplayLastException');
		end
		set(handles.listDataDirs, 'BackgroundColor', theOldColor);
		rmappdata(0, 'fALFF_DoingRecursiveDir');
	end

function SetDataDir(hObject, ADir, handles)
	if ~ischar(ADir), return; end	
	theOldWarnings =warning('off', 'all');
    % if (~isequal(ADir , 0)) &&( (size(handles.Cfg.DataDirs, 1)==0)||(0==seqmatch({ADir} ,handles.Cfg.DataDirs( : , 1) ) ) )
	if rest_misc('GetMatlabVersion')>=7.3,
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
			if isappdata(0, 'fALFF_DoingRecursiveDir') && getappdata(0, 'fALFF_DoingRecursiveDir'),
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
		set(handles.ckboxRetrend, 'Enable', 'on');
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
	set(handles.ckboxDivideMean, 'Value', strcmpi(handles.Cfg.WantMeanfAlffMap, 'Yes'));

	% Set detrend option
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
				fprintf('%s, *.{hdr,img} should be pairwise. Please re-examin them.\n', ADataDir);
				errordlg('*.{hdr,img} should be pairwise. Please re-examin them.');
				break;
			end
		end
	end



function btnComputefAlff_Callback(hObject, eventdata, handles)
	if (size(handles.Cfg.DataDirs, 1)==0) %check legal parameter set first
		errordlg('No Data found! Please re-config');
		return;
	end
    if (exist('f_alff.m','file')==2)
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
			if strcmpi(handles.Detrend.BeforeFilter, 'Yes') % Revised by YAN Chao-Gan, 090321. Detrend without filter is also OK. strcmpi(handles.Filter.UseFilter, 'Yes') &&
				Detrend(hObject, handles);
				%20070614, Bug fix, Update the data structure manually
				handles =guidata(hObject);	% I have to read it again, because I change it for further processing
            end
            pause(0.01);
			%%Filter all the data and create a new directory, then compute the f_alff value, dawnsong 20070429
			%Band pass filter
			if strcmpi(handles.Filter.UseFilter, 'Yes')
				BandPass(hObject, handles);
				%20070614, Bug fix, Update the data structure manually
				handles =guidata(hObject);	% I have to read it again, because I change it	for further processing
            end
            pause(0.01);
			%%Remove the linear trend after filtering, and create a new directory, then do ReHo
			if strcmpi(handles.Filter.UseFilter, 'Yes') && strcmpi(handles.Detrend.AfterFilter, 'Yes'),
				Detrend(hObject, handles);
				%20070614, Bug fix, Update the data structure manually
				handles =guidata(hObject);	% I have to read it again, because I change it for further processing
            end
            pause(0.01);
			%compute the f_alff brain
            %Add by Sandy Wang 20120331 for parallel computing
            PF_edtOutputDir=get(handles.edtOutputDir, 'String');
            PF_edtPrefix =get(handles.edtPrefix, 'String');
            PF_DataDirs=handles.Cfg.DataDirs(:,1);
            PF_fALFF_SamplePeriod=handles.fALFF.SamplePeriod;
            PF_fALFF_BandHigh=handles.fALFF.BandHigh;
            PF_fALFF_BandLow=handles.fALFF.BandLow;
            PF_MaskFile=handles.Cfg.MaskFile;
            PF_WantMeanAlffMap=handles.Cfg.WantMeanfAlffMap;
			%for x=1:size(handles.Cfg.DataDirs, 1)
            tic;
            parfor x=1:size(PF_DataDirs,1)
				%Update display
				%set(handles.listDataDirs, 'Value', x);
				%drawnow;
				%if size(handles.Cfg.DataDirs, 1)>1,
				%	rest_waitbar((x-1)/size(handles.Cfg.DataDirs, 1)+0.01, ...
				%				handles.Cfg.DataDirs{x, 1}, ...
				%				'fALFF Computing','Parent');
				%end
				%fprintf('\nfALFF :"%s"\n', handles.Cfg.DataDirs{x, 1});
                fprintf('\nALFF :"%s"\n', PF_DataDirs{x});
				%theOutputDir=get(handles.edtOutputDir, 'String');
                theOutputDir=PF_edtOutputDir;
				%thePrefix =get(handles.edtPrefix, 'String');
                thePrefix=PF_edtPrefix;
				theDstFile=fullfile(theOutputDir,[thePrefix '_' ...
                                            GetDirName(PF_DataDirs{x})]);
											%GetDirName(handles.Cfg.DataDirs{x, 1}) ] );

		        %f_alff( handles.Cfg.DataDirs{x, 1}, ...
						%handles.fALFF.SamplePeriod, ...
						%handles.fALFF.BandHigh, ...
						%handles.fALFF.BandLow, ...
		                %handles.Cfg.MaskFile, ...
						%theDstFile);
                %change by Sandy Wang for parallel computing
                f_alff( PF_DataDirs{x},...
                        PF_fALFF_SamplePeriod,...
                        PF_fALFF_BandHigh,...
                        PF_fALFF_BandLow,...
                        PF_MaskFile,...
                        theDstFile);

				%20070504, divide f_alff brain by the mean within the mask
				%if strcmpi(handles.Cfg.WantMeanfAlffMap, 'Yes')
                if strcmpi(PF_WantMeanAlffMap, 'Yes')    
					theOrigfAlffMap =theDstFile;
					theMeanfAlffMap =fullfile(theOutputDir,['m' thePrefix '_' ...
                                                GetDirName(PF_DataDirs{x})]);
												%GetDirName(handles.Cfg.DataDirs{x, 1}) ] );
					%theMaskFile =handles.Cfg.MaskFile;
                    theMaskFile =PF_MaskFile;
					rest_DivideMeanWithinMask(theOrigfAlffMap, theMeanfAlffMap, theMaskFile);
                end
            end
            toc;
            set(handles.listDataDirs, 'Value', size(PF_DataDirs, 1));
			handles.Performance =cputime -handles.Performance; %Write down the End time , 20070903
			LogPerformance(handles);
		catch
			rest_misc( 'DisplayLastException');
			errordlg(sprintf('Exception occured: \n\n%s' , lasterr));
		end
		cd(theOldDir);
		set(hObject,'Enable','on', 'BackgroundColor', theOldColor);
		drawnow;
		%rest_waitbar;
    else
        errordlg('No f_alff.m ! Please re-install');
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
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	    set(hObject,'BackgroundColor','white');
	end


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





function rbtnDefaultMask_Callback(hObject, eventdata, handles)
	set(handles.edtMaskfile, 'Enable','off', 'String','Use Default Mask');
	set(handles.btnSelectMask, 'Enable','off');
	drawnow;
    handles.Cfg.MaskFile ='Default';
	guidata(hObject, handles);
    set(handles.rbtnDefaultMask,'Value',1);
	set(handles.rbtnNullMask,'Value',0);
	set(handles.rbtnUserMask,'Value',0);

function rbtnUserMask_Callback(hObject, eventdata, handles)
	set(handles.edtMaskfile,'Enable','on', 'String',handles.Cfg.MaskFile);
	set(handles.btnSelectMask, 'Enable','on');
	set(handles.rbtnDefaultMask,'Value',0);
	set(handles.rbtnNullMask,'Value',0);
	set(handles.rbtnUserMask,'Value',1);
    drawnow;

function rbtnNullMask_Callback(hObject, eventdata, handles)
	set(handles.edtMaskfile, 'Enable','off', 'String','Don''t use any Mask');
	set(handles.btnSelectMask, 'Enable','off');
	drawnow;
	handles.Cfg.MaskFile ='';
	guidata(hObject, handles);
    set(handles.rbtnDefaultMask,'Value',0);
	set(handles.rbtnNullMask,'Value',1);
	set(handles.rbtnUserMask,'Value',0);





function listDataDirs_Callback(hObject, eventdata, handles)
	theIndex =get(hObject, 'Value');
	if isempty(theIndex) || theIndex<1,
        msgbox(sprintf('Nothing added.\n\nYou must add some diretories containing only paired {hdr/img} files first'), ...
					'REST' ,'help');
		return;
    end

	if strcmp(get(handles.figfAlffMain, 'SelectionType'), 'open') %when double click
	    msgbox(sprintf('%s \t\nhas\t %d\t volumes\n\nTotal: %d Data Directories' , ...
					handles.Cfg.DataDirs{theIndex, 1} , ...
	                handles.Cfg.DataDirs{theIndex, 2} , ...
					size(handles.Cfg.DataDirs,1)), ...
					'Volume count in selected dir' ,'help');
	end

function listDataDirs_KeyPressFcn(hObject, eventdata, handles)
	%Delete the selected item when 'Del' is pressed
    key =get(handles.figfAlffMain, 'currentkey');
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
	theDir =uigetdir(theDir, 'Please select the data directory to compute f_alff map: ');
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


function ckboxDivideMean_Callback(hObject, eventdata, handles)
	if get(hObject,'Value')
		handles.Cfg.WantMeanfAlffMap ='Yes';
	else
		handles.Cfg.WantMeanfAlffMap ='No';
	end
	guidata(hObject, handles);
	UpdateDisplay(handles);

function btnDivideMean_Callback(hObject, eventdata, handles)
	theOldColor=get(hObject,'BackgroundColor');
	set(hObject,'Enable','off', 'BackgroundColor', 'red');
	drawnow;
	try
		[filename, pathname] = uigetfile({'*.img;*.nii;*.nii.gz','Brain Image Files (*.img;*.nii;*.nii.gz)';'*.*', 'All Files (*.*)';}, ...
													'Pick one f_alff map');
	    if (filename~=0)% not canceled
			if strcmpi(filename(end-3:end), '.img')%revise filename to remove extension
				filename = filename(1:end-4);
			end
			if ~strcmpi(pathname(end), filesep)%revise filename to remove extension
				pathname = [pathname filesep];
			end
			theOrigfAlffMap =[pathname filename];
			theMeanfAlffMap =[pathname 'm' filename];
			theMaskFile =handles.Cfg.MaskFile;
			rest_DivideMeanWithinMask(theOrigfAlffMap, theMeanfAlffMap, theMaskFile);
			msgbox(sprintf('fAlff brain "%s.{hdr/img}" \ndivide its mean within mask successfully.\t\n\nSave to "%s.{hdr/img}"\n' , ...
					theOrigfAlffMap, theMeanfAlffMap), ...
					'Divide mean within mask successfully' ,'help');
	    end
	catch
		rest_misc( 'DisplayLastException');
	end
	set(hObject,'Enable','on', 'BackgroundColor', theOldColor);
	drawnow;

function btnBandPass_Callback(hObject, eventdata, handles)
	theOldColor=get(hObject,'BackgroundColor');		
	set(hObject,'Enable','off', 'BackgroundColor', 'red');
	drawnow;
	try
	    %Band pass filter
		if strcmpi(handles.Filter.UseFilter, 'Yes')
			tic;
            BandPass(hObject, handles);
            handles =guidata(hObject);
            toc;
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

function InitFrames(hObject,handles)
	offsetY =83; %dawnsong, 20070504, add for the divide by the mask mean, the Y of Edit "OutPut Diectory"
	% for Matlab 6.5 compatible, draw a panel
	uicontrol(handles.figfAlffMain, 'Style','Frame','Position',[2 offsetY+152 433 1]);
	uicontrol(handles.figfAlffMain, 'Style','Frame','Position',[2 offsetY+202 433 1]);
	uicontrol(handles.figfAlffMain, 'Style','Frame','Position',[90 offsetY+291 343 1]);
	uicontrol(handles.figfAlffMain, 'Style','Frame','Position',[90 offsetY+202 1 90]);
	uicontrol(handles.figfAlffMain, 'Style','Frame','Position',[2 offsetY+152 1 280]);
	uicontrol(handles.figfAlffMain, 'Style','Frame','Position',[435 offsetY+152 1 280]);
	uicontrol(handles.figfAlffMain, 'Style','Frame','Position',[2 offsetY+432 433 1]);
	uicontrol(handles.figfAlffMain,'Style','Text','Position',[152 offsetY+430 100 14],...
		'String','Input Parameters');
	uicontrol(handles.figfAlffMain,'Style','Text','Position',[208 offsetY+288 40 14],...
		'String','Mask');

	uicontrol(handles.figfAlffMain, 'Style','Frame','Position',[2 offsetY+94 433 1]);
	uicontrol(handles.figfAlffMain, 'Style','Frame','Position',[2 offsetY-8 433 1]);
	uicontrol(handles.figfAlffMain, 'Style','Frame','Position',[2 offsetY-8 1 102]);
	uicontrol(handles.figfAlffMain, 'Style','Frame','Position',[435 offsetY-8 1 102]);
	uicontrol(handles.figfAlffMain,'Style','Text','Position',[152 offsetY+88 160 14],...
		'String','Output Parameters (fALFF map)');

	uicontrol(handles.figfAlffMain, 'Style','Frame','Position',[2 offsetY+450 433 1]);
	uicontrol(handles.figfAlffMain, 'Style','Frame','Position',[435 offsetY+450 1 50]);
	uicontrol(handles.figfAlffMain, 'Style','Frame','Position',[2 offsetY+450 1 50]);
	uicontrol(handles.figfAlffMain, 'Style','Frame','Position',[2 offsetY+500 433 1]);
	uicontrol(handles.figfAlffMain,'Style','Text','Position',[142 offsetY+495 180 14],...
		'String','Option: Ideal Band Pass Filter');

	uicontrol(handles.figfAlffMain, 'Style','Frame','Position',[2 offsetY+515 433 1]);
	uicontrol(handles.figfAlffMain, 'Style','Frame','Position',[435 offsetY+515 1 50]);
	uicontrol(handles.figfAlffMain, 'Style','Frame','Position',[2 offsetY+515 1 50]);
	uicontrol(handles.figfAlffMain, 'Style','Frame','Position',[2 offsetY+565 433 1]);
	uicontrol(handles.figfAlffMain,'Style','Text','Position',[142 offsetY+555 180 14],...
		'String','Option: Remove Linear Trend');


	%20070506, Add manual operation button groups like SPM
	uicontrol(handles.figfAlffMain, 'Style','Frame','Position',[2 offsetY-25 433 1]);
	uicontrol(handles.figfAlffMain,'Style','Text','Position',[152 offsetY-30 140 14],...
		'String','Manual Operations');


function InitControlProperties(hObject, handles)
	%for Linux compatible 20070507 dawnsong
	% --- FIGURE -------------------------------------
	set(handles.figfAlffMain,...
		'Units', 'pixels', ...
		'Position', [20 5 440 650], ...
		'Name', 'f_alff_gui', ...
		'MenuBar', 'none', ...
		'NumberTitle', 'off', ...
		'Color', get(0,'DefaultUicontrolBackgroundColor'));

	% --- STATIC TEXTS -------------------------------------
	set(handles.txtfAlff,	...
		'Style', 'text', ...
		'Units', 'pixels', ...
		'Position', [16 186 130 40], ...
		'FontSize', 24, ...
		'FontWeight', 'bold', ...
		'String', 'fALFF');

	theFontSize =8;
	if isunix, theFontSize =10; end
	set(handles.txtfAlffLongName,	...
		'Style', 'text', ...
		'Units', 'pixels', ...
		'Position', [10 300 65 76], ...
		'FontSize', theFontSize, ...
		'FontWeight', 'normal', ...
		'Enable', 'off', ...
		'String', sprintf('Fractional\nAmplitude\nof Low\nFrequency\nFluctuation\nComputation'));

	set(handles.txtOutputDir,	...
		'Style', 'text', ...
		'Units', 'pixels', ...
		'Position', [8 109 80 21], ...
		'FontSize', theFontSize, ...
		'String', 'Directory:');

	set(handles.txtInputDir,	...
		'Style', 'text', ...
		'Units', 'pixels', ...
		'Position', [7 386 80 21], ...
		'String', 'Data Directory:');

	set(handles.txtPrefix,	...
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

	set(handles.txtBandSep,	...
		'Style', 'text', ...
		'Units', 'pixels', ...
		'Position', [146 526 25 51], ...
		'FontSize', 28, ...
		'String', '~');

	set(handles.txtTR,	...
		'Style', 'text', ...
		'Units', 'pixels', ...
		'Position', [230 540 40 16], ...
		'String', 'TR: (s)');

	set(handles.txtfAlffBand,	...
		'Style', 'text', ...
		'Units', 'pixels', ...
		'Position', [20 245 50 16], ...
		'String', 'Band( Hz)');

	set(handles.txtfAlffBandSep,	...
		'Style', 'text', ...
		'Units', 'pixels', ...
		'Position', [144 230 25 51], ...
		'FontSize', 28, ...
		'String', '~');

	set(handles.txtfAlffTR,	...
		'Style', 'text', ...
		'Units', 'pixels', ...
		'Position', [230 245 40 16], ...
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
		'Position', [396 384 30 25], ...
		'FontSize', 18, ...
		'String', '...', ...
		'CData', zeros(1,0));

	set(handles.btnSelectMask,	...
		'Style', 'pushbutton', ...
		'Units', 'pixels', ...
		'Position', [396 290 30 25], ...
		'FontSize', 18, ...
		'String', '...', ...
		'Enable', 'off', ...
		'CData', zeros(1,0));

	set(handles.btnComputefAlff,	...
		'Style', 'pushbutton', ...
		'Units', 'pixels', ...
		'Position', [320 186 107 33], ...
		'FontSize', 12, ...
		'FontWeight', 'bold', ...
		'String', 'Do all');


	set(handles.btnDetrend , ...
		'Style', 'pushbutton', ...
		'Units', 'pixels', ...
		'Position', [337 603 90 25], ...
		'FontSize', 10, ...
		'Enable', 'off', ...  %Update filter and detrend button's state according to Option: detrend/Filter 20070820
		'String', 'Detrend');
	set(handles.btnBandPass , ...
		'Style', 'pushbutton', ...
		'Units', 'pixels', ...
		'Position', [337 540 90 25], ...
		'FontSize', 10, ...
		'Enable', 'off', ...  %Update filter and detrend button's state according to Option: detrend/Filter 20070820
		'String', 'Filter');
	set(handles.btnfAlffBandDetail , ...
		'Style', 'pushbutton', ...
		'Units', 'pixels', ...
		'Position', [337 244 90 25], ...
		'FontSize', 10, ...
		'String', 'Band Hint');


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
	set(handles.rbtnDefaultMask,	...
		'Style', 'radiobutton', ...
		'Units', 'pixels', ...
		'Position', [110 347 158 16], ...
		'String', 'Default mask');

	set(handles.rbtnUserMask,	...
		'Style', 'radiobutton', ...
		'Units', 'pixels', ...
		'Position', [110 321 148 16], ...
		'String', 'User-defined mask');

	set(handles.rbtnNullMask,	...
		'Style', 'radiobutton', ...
		'Units', 'pixels', ...
		'Position', [277 348 82 16], ...
		'String', 'No mask');

	% --- CHECKBOXES -------------------------------------
	set(handles.ckboxFilter,	...
		'Style', 'checkbox', ...
		'Units', 'pixels', ...
		'Position', [14 540 80 22], ...
		'String', 'Band (Hz)', ...
		'Enable', 'off');

	set(handles.ckboxDivideMean,	...
		'Style', 'checkbox', ...
		'Units', 'pixels', ...
		'Position', [12 82 430 19], ...
		'String', 'Divide fALFF brain by the mean within the mask (mPrefix_DirectoryName.{hdr/img})');

	set(handles.ckboxRetrend,	...
		'Style', 'checkbox', ...
		'Units', 'pixels', ...
		'Position', [366 540 60 22], ...
		'Enable', 'Off', ...
		'String', 'Retrend');

	set(handles.ckboxRemoveTrendBefore, ...
		'Style', 'checkbox', ...
		'Units', 'pixels', ...
		'Position', [13 605 140 21],...
		'String', 'detrend'); %'String', 'detrend BEFORE Filter');
	set(handles.ckboxRemoveTrendAfter, ...
		'Style', 'checkbox', ...
		'Units', 'pixels', ...
		'Position', [171 605 140 21],...
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
		'Position', [94 386 300 22], ...
		'BackgroundColor', [1 1 1], ...
		'String', '');

	set(handles.edtMaskfile,	...
		'Style', 'edit', ...
		'Units', 'pixels', ...
		'Position', [94 290 300 23], ...
		'BackgroundColor', [1 1 1], ...
		'String', 'Edit Text', ...
		'Enable', 'off');

	set(handles.edtPrefix,	...
		'Style', 'edit', ...
		'Units', 'pixels', ...
		'Position', [94 142 115 22], ...
		'BackgroundColor', [1 1 1], ...
		'String', 'fALFFMap');

	set(handles.edtBandLow,	...
		'Style', 'edit', ...
		'Units', 'pixels', ...
		'Position', [94 541 50 22], ...
		'BackgroundColor', [1 1 1], ...
		'String', '0.01', ...
		'Enable', 'off');

	set(handles.edtBandHigh,	...
		'Style', 'edit', ...
		'Units', 'pixels', ...
		'Position', [171 541 50 22], ...
		'BackgroundColor', [1 1 1], ...
		'String', '0.08', ...
		'Enable', 'off');

	set(handles.edtSamplePeriod,	...
		'Style', 'edit', ...
		'Units', 'pixels', ...
		'Position', [276 541 50 22], ...
		'BackgroundColor', [1 1 1], ...
		'String', '2', ...
		'Enable', 'off');

	set(handles.edtfAlffBandLow,	...
		'Style', 'edit', ...
		'Units', 'pixels', ...
		'Position', [94 245 50 22], ...
		'BackgroundColor', [1 1 1], ...
		'String', '0.01', ...
		'Enable', 'on');

	set(handles.edtfAlffBandHigh,	...
		'Style', 'edit', ...
		'Units', 'pixels', ...
		'Position', [171 245 50 22], ...
		'BackgroundColor', [1 1 1], ...
		'String', '0.08', ...
		'Enable', 'on');

	set(handles.edtfAlffSamplePeriod,	...
		'Style', 'edit', ...
		'Units', 'pixels', ...
		'Position', [276 245 50 22], ...
		'BackgroundColor', [1 1 1], ...
		'String', '2', ...
		'Enable', 'on');


	% --- LISTBOXES -------------------------------------
	set(handles.listDataDirs,	...
		'Style', 'listbox', ...
		'Units', 'pixels', ...
		'Position', [14 413 413 98], ...
		'BackgroundColor', [1 1 1], ...
		'String', '');

	%20071103, Add context menu to Input Data Directories to add��delete��export��import����
	handles.hContextMenu =uicontextmenu;
	set(handles.listDataDirs, 'UIContextMenu', handles.hContextMenu);
	uimenu(handles.hContextMenu, 'Label', 'Add a directory', 'Callback', get(handles.btnSelectDataDir, 'Callback'));
	uimenu(handles.hContextMenu, 'Label', 'Remove selected directory', 'Callback', 'f_alff_gui(''DeleteSelectedDataDir'',gcbo,[], guidata(gcbo))');
	uimenu(handles.hContextMenu, 'Label', 'Add recursively all sub-folders of a directory', 'Callback', 'f_alff_gui(''RecursiveAddDataDir'',gcbo,[], guidata(gcbo))');
	uimenu(handles.hContextMenu, 'Label', '=============================');
	uimenu(handles.hContextMenu, 'Label', 'Remove all data directories', 'Callback', 'f_alff_gui(''ClearDataDirectories'',gcbo,[], guidata(gcbo))');


	% Save handles structure
	guidata(hObject,handles);

%% Log options to a log file for further investigation, 20070507
function Log2File(handles)
	constLineSep= '-------------------------------------------------------------------------------';
	[theVer, theRelease] =rest_misc( 'GetRestVersion');
	theMsgVersion = sprintf('REST Version:%s, Release %s\r\n%s\r\n', theVer, theRelease, constLineSep);
	theMsgHead = sprintf('fALFF computation log %s\r\n%s\r\n', rest_misc( 'GetDateTimeStr'), constLineSep);
	theMsg =sprintf('%s\r\n%s\r\n\r\n%s', theMsgVersion, theMsgHead, constLineSep);
	theMsg =sprintf('%s\r\nRemove Linear Trend options:\r\n%s\r\n\r\n%s',theMsg,...
					LogRemoveLinearTrend(handles), constLineSep);
	theMsg =sprintf('%s\r\nIdeal Band Pass filter options:\r\n%s\r\n\r\n%s',theMsg,...
					LogBandPassFilter(handles), constLineSep);
	theMsg =sprintf('%s\r\nfALFF input parameters:\r\n%s\r\n\r\n%s', theMsg, ...
					LogInputParameters(handles), constLineSep);
	theMsg =sprintf('%s\r\nfALFF Band Config:\r\n%s\r\n\r\n%s',theMsg,...
					LogfALFFParameters(handles), constLineSep);
	theMsg =sprintf('%s\r\nfALFF output parameters:\r\n%s\r\n\r\n%s', theMsg, ...
					LogOutputParameters(handles), constLineSep);

	fid = fopen(handles.Log.Filename,'w');
	if fid~=-1
		fprintf(fid,'%s',theMsg);
		fclose(fid);
	else
		errordlg(sprintf('Error to open log file:\n\n%s', handles.Log.Filename));
	end

function ResultLogString=LogRemoveLinearTrend(handles)
	ResultLogString ='';
	ResultLogString =sprintf('%s\tremove linear trend BEFORE filter: %s\r\n',ResultLogString, handles.Detrend.BeforeFilter);
	ResultLogString =sprintf('%s\tremove linear trend AFTER filter: %s\r\n',ResultLogString, handles.Detrend.AfterFilter);

function ResultLogString=LogBandPassFilter(handles)
	ResultLogString ='';
	ResultLogString =sprintf('%s\tUse Filter: %s\r\n',ResultLogString, handles.Filter.UseFilter);
	ResultLogString =sprintf('%s\tBand Low: %g\r\n', ResultLogString, handles.Filter.BandLow);
	ResultLogString =sprintf('%s\tBand High: %g\r\n',ResultLogString, handles.Filter.BandHigh);
	ResultLogString =sprintf('%s\tSample Period(i.e. TR): %g\r\n',ResultLogString, handles.Filter.SamplePeriod);

function ResultLogString=LogfALFFParameters(handles)
	ResultLogString ='';
	ResultLogString =sprintf('%s\tBand Low: %g\r\n', ResultLogString, handles.fALFF.BandLow);
	ResultLogString =sprintf('%s\tBand High: %g\r\n',ResultLogString, handles.fALFF.BandHigh);
	ResultLogString =sprintf('%s\tSample Period(i.e. TR): %g\r\n',ResultLogString, handles.fALFF.SamplePeriod);

function ResultLogString=LogInputParameters(handles)
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

function ResultLogString=LogOutputParameters(handles)
	ResultLogString ='';
	ResultLogString =sprintf('%s\tPrefix to the Data directories: %s\r\n',ResultLogString, get(handles.edtPrefix, 'String'));
	ResultLogString =sprintf('%s\tOutput Data Directories: %s\r\n',ResultLogString, handles.Cfg.OutputDir);
	ResultLogString =sprintf('%s\tWant mean ReHo map computation: %s \r\n',ResultLogString, handles.Cfg.WantMeanfAlffMap);


%Log the total elapsed time by once "Do all"
function LogPerformance(handles)
	theMsg =sprintf('\r\n\r\nTotal elapsed time for fALFF Computing: %g  seconds\r\n',handles.Performance);
	fid = fopen(handles.Log.Filename,'r+');
	fseek(fid, 0, 'eof');
	if fid~=-1
		fprintf(fid,'%s',theMsg);
		fclose(fid);
	else
		errordlg(sprintf('Error to open log file:\n\n%s', handles.Log.Filename));
	end


%compose the log filename
function ResultLogFileName=GetLogFilename(ALogDirectory, APrefix)
	if isempty(ALogDirectory)
		[pathstr, name, ext] = fileparts(mfilename('fullpath'));
		ALogDirectory =pathstr;
	end
	if ~strcmp(ALogDirectory(end), filesep)
		ALogDirectory =[ALogDirectory filesep];
	end
	ResultLogFileName=sprintf('%s%s_%s.log', ...
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
			% if ~strcmpi(pathname(end), filesep)%revise pathname to remove extension
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
% 		[filename, pathname] = uigetfile({'*.img', 'ANALYZE or NIFTI files (*.img)'}, ...
% 														'Pick one functional EPI brain map in the dataset''s directory');
% 		if any(filename~=0) && ischar(filename),	% not canceled and legal
% 			if ~strcmpi(pathname(end), filesep)%revise pathname to remove extension
% 				pathname = [pathname filesep];
% 			end
% 			theBrainMap 	=[pathname filename];
% 			theViewer =rest_sliceviewer('ShowImage', theBrainMap);
%
% 			%Set the fALFF figure to show corresponding voxel's time-course and its freq amplitude
% 			theDataSetDir 	=pathname;
% 			theVoxelPosition=rest_sliceviewer('GetPosition', theViewer);
% 			theSamplePeriod =handles.fALFF.SamplePeriod;
% 			theBandRange	=[handles.fALFF.BandLow, handles.fALFF.BandHigh];
% 			rest_powerspectrum('ShowFluctuation', theDataSetDir, theVoxelPosition, ...
% 							theSamplePeriod, theBandRange);
%
% 			%Update the Callback
% 			theCallback 	='';
% 			cmdDataSetDir	=sprintf('theDataSetDir= ''%s'';', theDataSetDir);
% 			cmdBrainMap 	=sprintf('theVoxelPosition=rest_sliceviewer(''GetPosition'', %g);', theViewer);
% 			cmdSamplePeriod =sprintf('theSamplePeriod= %g;', theSamplePeriod);
% 			cmdBandRange	=sprintf('theBandRange= [%g, %g];', theBandRange(1), theBandRange(2));
% 			cmdUpdateWaveGraph	='rest_powerspectrum(''ShowFluctuation'', theDataSetDir, theVoxelPosition, theSamplePeriod, theBandRange);';
% 			theCallback	=sprintf('%s\n%s\n%s\n%s\n%s\n',cmdDataSetDir, ...
% 								cmdBrainMap, cmdSamplePeriod, cmdBandRange, ...
% 								cmdUpdateWaveGraph);
% 			cmdClearVar ='clear theDataSetDir theVoxelPosition theSamplePeriod theBandRange;';
% 			rest_sliceviewer('UpdateCallback', theViewer, [theCallback cmdClearVar], 'fALFF Analysis');
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



function edtfAlffBandLow_Callback(hObject, eventdata, handles)
	handles.fALFF.BandLow =str2double(get(hObject,'String'));
	guidata(hObject, handles);

function edtfAlffBandLow_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	    set(hObject,'BackgroundColor','white');
	end


function edtfAlffBandHigh_Callback(hObject, eventdata, handles)
	handles.fALFF.BandHigh =str2double(get(hObject,'String'));
	guidata(hObject, handles);

function edtfAlffBandHigh_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	    set(hObject,'BackgroundColor','white');
	end


function edtfAlffSamplePeriod_Callback(hObject, eventdata, handles)
	handles.fALFF.SamplePeriod =str2double(get(hObject,'String'));
	guidata(hObject, handles);

function edtfAlffSamplePeriod_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	    set(hObject,'BackgroundColor','white');
	end




function btnfAlffBandDetail_Callback(hObject, eventdata, handles)
%Compute the fALFF Band detailed message and show it
%Revised by YAN Chao-Gan, 100420. Fixed the bug in calculating the frequency band.
	sampleLength =inputdlg('Please input sample length: (i.e. the total number of time points)', ...
							'fALFF Band Detailed Message');
	sampleLength 	=str2num(sampleLength{1});
	sampleFreq 	 	=1/handles.fALFF.SamplePeriod;
	paddedLength	=rest_nextpow2_one35(sampleLength);
	freqPrecision	=sampleFreq /paddedLength;
	BandLowIdx		=handles.fALFF.BandLow * paddedLength * handles.fALFF.SamplePeriod + 1; %Revised by YAN Chao-Gan, 100420. Fixed the bug in calculating the frequency band. %BandLowIdx		=handles.fALFF.BandLow * paddedLength * handles.fALFF.SamplePeriod;
	rBandLowIdx		=round(BandLowIdx);
	rBandLow		=(rBandLowIdx - 1) /paddedLength /handles.fALFF.SamplePeriod; %Revised by YAN Chao-Gan, 100420. Fixed the bug in calculating the frequency band. %rBandLow		=rBandLowIdx /paddedLength /handles.fALFF.SamplePeriod;
	BandHighIdx		=handles.fALFF.BandHigh * paddedLength * handles.fALFF.SamplePeriod + 1; %Revised by YAN Chao-Gan, 100420. Fixed the bug in calculating the frequency band. %BandHighIdx		=handles.fALFF.BandHigh * paddedLength * handles.fALFF.SamplePeriod;
	rBandHighIdx	=round(BandHighIdx);
	rBandHigh		=(rBandHighIdx - 1) /paddedLength /handles.fALFF.SamplePeriod; %Revised by YAN Chao-Gan, 100420. Fixed the bug in calculating the frequency band. %rBandHigh		=rBandHighIdx /paddedLength /handles.fALFF.SamplePeriod;

	theWantBandInfo  =sprintf('%gHz --> Index=%g,    %gHz --> Index=%g', ...
						handles.fALFF.BandLow, BandLowIdx, ...
						handles.fALFF.BandHigh, BandHighIdx);
	theRealBandInfo  =sprintf('%gHz --> Index=%g,    %gHz --> Index=%g', ...
						rBandLow, rBandLowIdx, ...
						rBandHigh, rBandHighIdx);
	if rBandLowIdx==ceil(BandLowIdx)
		rBandLowIdx =floor(BandLowIdx);
	else
		rBandLowIdx =ceil(BandLowIdx);
	end
	rBandLow		=(rBandLowIdx - 1) /paddedLength /handles.fALFF.SamplePeriod; %Revised by YAN Chao-Gan, 100420. Fixed the bug in calculating the frequency band. %rBandLow		=rBandLowIdx /paddedLength /handles.fALFF.SamplePeriod;
	if rBandHighIdx==ceil(BandHighIdx)
		rBandHighIdx =floor(BandHighIdx);
	else
		rBandHighIdx =ceil(BandHighIdx);
	end
	rBandHigh		=(rBandHighIdx - 1) /paddedLength /handles.fALFF.SamplePeriod; %Revised by YAN Chao-Gan, 100420. Fixed the bug in calculating the frequency band. %rBandHigh		=rBandHighIdx /paddedLength /handles.fALFF.SamplePeriod;
	theAnother2Point =sprintf('%gHz --> Index=%g,    %gHz --> Index=%g', ...
						rBandLow, rBandLowIdx, ...
						rBandHigh, rBandHighIdx);

	msgbox( sprintf('The Band you want to use is:\n%s\n\nAdopted fALFF Band is:\n%s\n\n\nAnother 2 points'' Infomation:\n%s\n\nYou can view full information in "Power Spectrum"', theWantBandInfo, theRealBandInfo, theAnother2Point), ...
			'Calculated Band Range Hint' ,'help');

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
	%web (sprintf('%s/man/English/fALFF/index.html', rest_misc( 'WhereIsREST')), '-helpbrowser');
