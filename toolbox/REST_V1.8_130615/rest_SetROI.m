function varargout=rest_SetROI(AOperation, varargin)	
%Define ROI wizard by Xiao-Wei Song
%------------------------------------------------------------------------------------------------------------------------------
%	Copyright(c) 2007~2010
%	State Key Laboratory of Cognitive Neuroscience and Learning in Beijing Normal University
%	Written by Xiao-Wei Song 
%	http://resting-fmri.sourceforge.net
%------------------------------------------------------------------------------------------------------------------------------
% 20070923
% 	<a href="Dawnwei.Song@gmail.com">Mail to Author</a>: Xiaowei Song
%	Version=1.2;
%	Release=20081223;
%   Modified by Yan Chao-Gan 080808: also support NIFTI images.
%   Last Modified by Yan Chao-Gan 081223: use the NIFTI templates.

%Initializitation
persistent REST_SetROI_Cfg; % run-time persistent config
% if ~mislocked(mfilename),mlock; end

if nargin<1, AOperation='Init'; varargin{1}='';end	%Revise the Start
switch upper(AOperation),
case 'INIT', 		%Init
	REST_SetROI_Cfg =InitControls(REST_SetROI_Cfg);
	if nargin>1,
		AROIDefinition =varargin{1};
	else
		AROIDefinition ='';
	end
	REST_SetROI_Cfg.ROIDefinition =AROIDefinition;
	
	if rest_SetROI( 'IsSphereROI' , AROIDefinition),
		set(REST_SetROI_Cfg.hSlectSphere, 'Value', 1);
		set(REST_SetROI_Cfg.hSlectNonSphere, 'Value', 0);
		set(REST_SetROI_Cfg.hSlectTxt, 'Value', 0);
	elseif rest_SetROI( 'IsImgROI' , AROIDefinition),
		set(REST_SetROI_Cfg.hSlectSphere, 'Value', 0);
		set(REST_SetROI_Cfg.hSlectNonSphere, 'Value', 1);
		set(REST_SetROI_Cfg.hSlectTxt, 'Value', 0);
	elseif rest_SetROI( 'IsTxtROI' , AROIDefinition),
		set(REST_SetROI_Cfg.hSlectSphere, 'Value', 0);
		set(REST_SetROI_Cfg.hSlectNonSphere, 'Value', 0);
		set(REST_SetROI_Cfg.hSlectTxt, 'Value', 1);
	else
		%error or  the definition is space/NaN ...
	end
	rest_SetROI( 'UpdateDisplay' );

	uiwait(REST_SetROI_Cfg.hFig);
	varargout{1} =REST_SetROI_Cfg.ROIDefinition;

case 'DELETE', 		%Delete
	if nargin~=1, error('Usage: result =rest_SetROI( ''Delete'');'); end	
	uiresume(REST_SetROI_Cfg.hFig);
	delete(REST_SetROI_Cfg.hFig);

case 'ISSPHEREROI',		%IsSphereROI
	if nargin~=2, error('Usage: result =rest_SetROI( ''IsSphereROI'' , AROIDefinition);'); end	
	AROIDefinition =varargin{1};
	if rest_SphereROI( 'IsBallDefinition', AROIDefinition),
		varargout{1}=1;
	else
		varargout{1}=0;
	end
	
case {'ISIMGROI', 'ISTMAPROI','ISTEMPLATEROI', 'ISUSERROI'}		%IsImgROI	%IsTMapROI 	%IsTemplateROI 	%IsUserROI
	if nargin~=2, error('Usage: result =rest_SetROI( ''IsImgROI'' , AROIDefinition);'); end	
	AROIDefinition =varargin{1};
	varargout{1}=0;
	if 2==exist(AROIDefinition, 'file'),
		[pathstr, name, ext] = fileparts(AROIDefinition);
		if strcmpi(ext, '.img'),
			varargout{1}=1;		
		end	
	end
	
case 'ISTXTROI',		%IsTxtROI
	if nargin~=2, error('Usage: result =rest_SetROI( ''IsTxtROI'' , AROIDefinition);'); end	
	AROIDefinition =varargin{1};
	varargout{1}=0;
	if 2==exist(AROIDefinition, 'file'),
		[pathstr, name, ext] = fileparts(AROIDefinition);
		if strcmpi(ext, '.txt'),
			varargout{1}=1;		
		end	
	end
	
case 'UPDATEDISPLAY',		%UpdateDisplay	
	if nargin~=1, error('Usage: result =rest_SetROI( ''UpdateDisplay'' );'); end	
	UpdateDisplay(REST_SetROI_Cfg);
	
case 'SELECT',		%Select
	if nargin~=1, error('Usage: result =rest_SetROI( ''Select'' );'); end
	theObj	=get(REST_SetROI_Cfg.hFig, 'CurrentObject');
	%Check whether the previous selected object is Sphere
	if ( get(REST_SetROI_Cfg.hSlectSphere, 'Value') && theObj~=REST_SetROI_Cfg.hSlectSphere ) ... 
		|| (get(REST_SetROI_Cfg.hSlectNonSphere, 'Value') && theObj~=REST_SetROI_Cfg.hSlectNonSphere ) ...
		|| (get(REST_SetROI_Cfg.hSlectTxt, 'Value') && theObj~=REST_SetROI_Cfg.hSlectTxt ),
		%Clear the Sphere definition defined in other way
		REST_SetROI_Cfg.ROIDefinition ='';	
	end	
	theRadioButtons =findobj(REST_SetROI_Cfg.hFig, 'Style', 'radiobutton');
	for x=1:length(theRadioButtons), 
		set(theRadioButtons(x), 'Value', 0);
	end
	set(theObj, 'Value', 1);
	if theObj ~= REST_SetROI_Cfg.hSlectSphere && theObj ~= REST_SetROI_Cfg.hSlectTxt,
		set(REST_SetROI_Cfg.hSlectNonSphere, 'Value', 1);
	end
	UpdateDisplay(REST_SetROI_Cfg);
	
case 'NEXT',		%Next
	if nargin~=1, error('Usage: result =rest_SetROI( ''Next'' );'); end
	set(REST_SetROI_Cfg.hNext, 'Enable', 'off', 'ForegroundColor', 'red');
	try
		if get(REST_SetROI_Cfg.hSlectSphere, 'Value'),
			REST_SetROI_Cfg.ROIDefinition =rest_SphereROI('Init', REST_SetROI_Cfg.ROIDefinition);
		elseif get(REST_SetROI_Cfg.hSlectNonSphere, 'Value'),			
			isNeedDefineCluster =true;
			if get(REST_SetROI_Cfg.hFromTMap, 'Value'),
				[filename, pathname] = uigetfile({'*.img;*.nii;*.nii.gz','Brain Image Files (*.img;*.nii;*.nii.gz)';'*.*', 'All Files (*.*)';},'Pick the  statistical map');%100329	
			elseif get(REST_SetROI_Cfg.hFromAAL, 'Value'),	
				pathname =fullfile(rest_misc( 'WhereIsREST'),'Template');
				filename ='aal.nii'; %Yan Chao-Gan 081223: use the NIFTI templates.
			elseif get(REST_SetROI_Cfg.hFromBrodmann, 'Value'),
				pathname =fullfile(rest_misc( 'WhereIsREST'),'Template');
				filename ='brodmann.nii'; %Yan Chao-Gan 081223: use the NIFTI templates.			
			elseif get(REST_SetROI_Cfg.hFromUserDefinedMask, 'Value'),
				[filename, pathname] = uigetfile({'*.img;*.nii;*.nii.gz','Brain Image Files (*.img;*.nii;*.nii.gz)';'*.*', 'All Files (*.*)';},'Pick the user defined mask file(ANALYZE or NIFTI FORMAT)');
				REST_SetROI_Cfg.ROIDefinition =fullfile(pathname, filename);
				isNeedDefineCluster =false;
			else
				warndlg('You must select one option');
			end
			
			if isNeedDefineCluster && any(filename~=0) && ischar(filename),	% not canceled and legal		
				theFig =rest_sliceviewer('ShowOverlay', fullfile(pathname, filename));
				theCallback =sprintf(['uiresume(%f);'], theFig);
				rest_sliceviewer('UpdateCallback_Save2Mask', theFig, theCallback);
				set(theFig, 'WindowStyle', 'modal');
				uiwait(theFig);
				REST_SetROI_Cfg.ROIDefinition =rest_sliceviewer('GetSavedMaskFilename', theFig);
				rest_sliceviewer('Delete', theFig);
			end
		elseif get(REST_SetROI_Cfg.hSlectTxt, 'Value'),			
			[filename, pathname] = uigetfile({'*.txt', 'User defined time courses (*.txt)'},'Pick the user defined txt file(One column is a time course)');
			REST_SetROI_Cfg.ROIDefinition =fullfile(pathname, filename);			
		end
	catch
		rest_misc('DisplayLastException');
	end
	UpdateDisplay(REST_SetROI_Cfg);
	
case 'UPDATEROIDEFINITION',			%UpdateROIDefinition
	if nargin~=2, error('Usage: result =rest_SetROI( ''UpdateROIDefinition'' , AROIDefinition);'); end	
	REST_SetROI_Cfg.ROIDefinition =varargin{1};
	
case 'MANUALYCHANGEROIDEFINITIONINEDIT',		%ManualyChangeROIDefinitionInEdit
	if nargin~=1, error('Usage: result =rest_SetROI( ''ManualyChangeROIDefinitionInEdit'');'); end	
	REST_SetROI_Cfg.ROIDefinition =get(gcbo, 'String');
	
case 'VIEWROI',		%ViewROI	
	if nargin~=1, error('Usage: rest_SetROI( ''ViewROI'');'); end
	if isempty(REST_SetROI_Cfg.ROIDefinition) || all(isspace(REST_SetROI_Cfg.ROIDefinition)),
		warndlg('No ROI defined yet!');
	else
		rest_misc( 'ViewROI', REST_SetROI_Cfg.ROIDefinition); 
	end
	
otherwise,
	
end

function Result =InitControls(AConfig)
	theFig =figure('Units', 'pixel', 'Toolbar', 'none', 'MenuBar', 'none', ...
				'CloseRequestFcn', sprintf('rest_SetROI(''Delete'');'), ...
				'Resize', 'off', ...
				'NumberTitle', 'off', 'Name', 'ROI (Region of interest) Definition');
	thePos =get(theFig, 'Position');
	set(theFig, 'Position', [thePos(1) thePos(2) 400 400],'WindowStyle', 'modal');
	movegui(theFig, 'center');
	set(theFig, 'DeleteFcn', sprintf('rest_SetROI(''Delete'');')  );
	AConfig.hFig =theFig;
	
	MarginX =10; MarginY =10;
	OffsetX =MarginX;
	OffsetY =MarginY +25 +MarginY;	
	theLeft =OffsetX; theBottom =OffsetY;
	
	%Time Course
	uicontrol(AConfig.hFig, 'Style','Frame', 'Units','pixels', ...
			'BackgroundColor', get(AConfig.hFig,'Color'), ...
			'Position', [theLeft,theBottom,380,70]);
	hSlectTxt =uicontrol('Style', 'radiobutton',	'Units', 'pixels', ...
				'BackgroundColor', get(AConfig.hFig,'Color'), 'Value', 0,...
				'Position', [theLeft+10,theBottom+60,120,20],...
				'String', 'Time courses');
	uicontrol('Style', 'text',	'Units', 'pixels', ...
			'BackgroundColor', get(AConfig.hFig,'Color'), ...
			'HorizontalAlignment', 'left', ...
			'Visible', 'on', ...
			'Position', [theLeft+10,theBottom+30,360,25], ...
			'String', sprintf(['User defined time courses contained in a txt file']));
	hROITxtLocation =uicontrol('Style', 'edit', 'Units', 'pixels', ...%'BackgroundColor', get(AConfig.hFig,'Color'), ...
					'HorizontalAlignment', 'left', ...
					'Visible', 'on', ...					
					'ForegroundColor', 'red', 'FontWeight', 'bold', ...
					'Position', [theLeft+10,theBottom+10,360,20], ...
					'String', 'dd');
	set(hROITxtLocation, 'Callback',sprintf('rest_SetROI( ''ManualyChangeROIDefinitionInEdit'')'));
	
	%ROI
	OffsetX =MarginX;
	OffsetY =MarginY+80;	
	
	theLeft =OffsetX; theBottom =OffsetY +40;
	uicontrol(AConfig.hFig, 'Style','Frame', 'Units','pixels', ...
			'BackgroundColor', get(AConfig.hFig,'Color'), ...
			'Position', [theLeft,theBottom,380,160]);
	hSlectNonSphere =uicontrol('Style', 'radiobutton',	'Units', 'pixels', ...
				'BackgroundColor', get(AConfig.hFig,'Color'), ...100329 dong 
				'Position', [theLeft+10,theBottom+150,120,20],'String', 'Predefined ROI');
	hNonSphereDescription =uicontrol('Style', 'text',	'Units', 'pixels', ...
				'BackgroundColor', get(AConfig.hFig,'Color'), ...
				'HorizontalAlignment', 'left', ...
				'Visible', 'on', ...
				'Position', [theLeft+10,theBottom+40,360,105], ...100326 dong
				'String', sprintf(['There are 4 methods to generate the ROI mask file:' ...
				 '\n\n1. From statistical map by selecting cluster after thresholding' ...
				  '\n2. From AAL template by selecting specific area'...
				  '\n3. From Brodmann template by selecting specific area'...
				  '\n4. From user defined mask file']));
	hFromTMap=uicontrol('Style', 'radiobutton',	'Units', 'pixels', ...
				'BackgroundColor', get(AConfig.hFig,'Color'), ...
				'Visible', 'off', ...100329 dong
				'Position', [theLeft+30,theBottom+105,340,16],'String', '1. From statistical map by selecting cluster after thresholding');
	hFromAAL=uicontrol('Style', 'radiobutton',	'Units', 'pixels', ...
				'BackgroundColor', get(AConfig.hFig,'Color'), ...
				'Visible', 'off', ...
				'Position', [theLeft+30,theBottom+85,340,16],'String', '2. From AAL template by selecting specific area');
	hFromBrodmann=uicontrol('Style', 'radiobutton',	'Units', 'pixels', ...
				'BackgroundColor', get(AConfig.hFig,'Color'), ...
				'Visible', 'off', ...
				'Position', [theLeft+30,theBottom+65,340,16],'String', '3. From Brodmann template by selecting specific area');
	hFromUserDefinedMask=uicontrol('Style', 'radiobutton',	'Units', 'pixels', ...
				'BackgroundColor', get(AConfig.hFig,'Color'), ...
				'Visible', 'off', ...
				'Position', [theLeft+30,theBottom+45,340,16],'String', '4. From user defined mask file');
	hROINonSphereInfo =uicontrol('Style', 'edit', 'Units', 'pixels', ...%'BackgroundColor', get(AConfig.hFig,'Color'), ...
					'HorizontalAlignment', 'left', ...
					'Visible', 'on', ...
					'ForegroundColor', 'red', 'FontWeight', 'bold', ...
					'Position', [theLeft+10,theBottom+10,360,20], ...
					'String', 'dd');
	set(hROINonSphereInfo, 'Callback',sprintf('rest_SetROI( ''ManualyChangeROIDefinitionInEdit'')'));
	
	
	%Seed ROI
	theLeft =OffsetX; theBottom =OffsetY +220;
	uicontrol(AConfig.hFig, 'Style','Frame', 'Units','pixels', ...
			'BackgroundColor', get(AConfig.hFig,'Color'), ...
			'Position', [theLeft,theBottom,380,70]);
	hSlectSphere =uicontrol('Style', 'radiobutton',	'Units', 'pixels', ...
				'BackgroundColor', get(AConfig.hFig,'Color'), 'Value', 1,...
				'Position', [theLeft+10,theBottom+60,120,20],'String', 'Spherical ROI');  %Revised by YAN Chao-Gan, 100130. %'Position', [theLeft+10,theBottom+60,120,20],'String', 'Seed ROI');
	uicontrol('Style', 'text',	'Units', 'pixels', ...
			'BackgroundColor', get(AConfig.hFig,'Color'), ...
			'HorizontalAlignment', 'left', ...
			'Visible', 'on', ...
			'Position', [theLeft+10,theBottom+30,360,25], ...
			'String', sprintf(['Define a seed ROI by setting the center coordinate and the radius(mm)']));
	hROISphereInfo =uicontrol('Style', 'edit', 'Units', 'pixels', ...%'BackgroundColor', get(AConfig.hFig,'Color'), ...
					'HorizontalAlignment', 'left', ...
					'Visible', 'on', ...
					'ForegroundColor', 'red', 'FontWeight', 'bold', ...
					'Position', [theLeft+10,theBottom+10,360,20], ...
					'String', 'dd');
	set(hROISphereInfo, 'Callback',sprintf('rest_SetROI( ''ManualyChangeROIDefinitionInEdit'')'));
	
	
	uicontrol('Style', 'pushbutton',	'Units', 'pixels', ...
				'Visible', 'on', 'Callback', sprintf('rest_SetROI(''Delete'');') ,...
				'Position', [MarginX,MarginY,75,25], ...
				'String', 'Done');
	%rest_misc( 'ViewROI', AROIDef); 
	uicontrol('Style', 'pushbutton',	'Units', 'pixels', ...
				'Visible', 'on', 'Callback', sprintf('rest_SetROI(''ViewROI'');') ,...
				'Position', [MarginX+80,MarginY,75,25], ...
				'String', 'View ROI');
	
	hNext =uicontrol('Style', 'pushbutton',	'Units', 'pixels', ...
				'Visible', 'on', ...
				'Callback', 'rest_SetROI( ''Next'' );', ...
				'Position', [MarginX+305,MarginY,75,25], ...
				'String', 'Next');
	
	theRadioButtons =findobj(AConfig.hFig, 'Style', 'radiobutton');
	for x=1:length(theRadioButtons), 
		set(theRadioButtons(x), 'Callback', 'rest_SetROI( ''Select'' );');
	end
	%Save handles			
	AConfig.hSlectNonSphere =hSlectNonSphere;
	AConfig.hNonSphereDescription =hNonSphereDescription;	
	AConfig.hFromTMap		=hFromTMap	;	
	AConfig.hFromAAL	=hFromAAL;
	AConfig.hFromBrodmann	=hFromBrodmann;
	AConfig.hFromUserDefinedMask=hFromUserDefinedMask;	
	AConfig.hROINonSphereInfo=hROINonSphereInfo;
	
	AConfig.hSlectSphere=hSlectSphere;
	AConfig.hROISphereInfo=hROISphereInfo;
	
	AConfig.hSlectTxt =hSlectTxt;
	AConfig.hROITxtLocation =hROITxtLocation;
	
	AConfig.hNext =hNext;
		
	Result =AConfig;
	
function UpdateDisplay(AConfig)
	if get(AConfig.hSlectSphere, 'Value'),
		set(AConfig.hROISphereInfo, 'String', AConfig.ROIDefinition);
		
		set(AConfig.hSlectNonSphere, 'Value', 0);
		set(AConfig.hNonSphereDescription, 'String', sprintf(['There are 4 methods to generate the ROI mask file:' ...
				 '\n\n1. From statistical map by selecting cluster after thresholding' ...100329 dong
				  '\n2. From AAL template by selecting specific area'...
				  '\n3. From Brodmann template by selecting specific area'...
				  '\n4. From user defined mask file'])); 
		set(AConfig.hFromTMap, 'Visible', 'off');
		set(AConfig.hFromAAL, 'Visible', 'off');
		set(AConfig.hFromBrodmann, 'Visible', 'off');
		set(AConfig.hFromUserDefinedMask, 'Visible', 'off');
		set(AConfig.hROINonSphereInfo, 'String', '');
				
		set(AConfig.hSlectTxt, 'Value', 0);
		set(AConfig.hROITxtLocation, 'String', '');
		
	elseif get(AConfig.hSlectNonSphere, 'Value'),
		set(AConfig.hSlectSphere, 'Value', 0);
		set(AConfig.hROISphereInfo, 'String', '');
		
		set(AConfig.hNonSphereDescription, 'String',sprintf(['There are 4 methods to generate the ROI mask file:'])); 
		set(AConfig.hFromTMap, 'Visible', 'on');
		set(AConfig.hFromAAL, 'Visible', 'on');
		set(AConfig.hFromBrodmann, 'Visible', 'on');
		set(AConfig.hFromUserDefinedMask, 'Visible', 'on');
		set(AConfig.hROINonSphereInfo, 'String', AConfig.ROIDefinition);
		
		set(AConfig.hSlectTxt, 'Value', 0);
		set(AConfig.hROITxtLocation, 'String', '');
	elseif get(AConfig.hSlectTxt, 'Value'),
		set(AConfig.hSlectSphere, 'Value', 0);
		set(AConfig.hROISphereInfo, 'String', '');	
		
		set(AConfig.hSlectNonSphere, 'Value', 0);
		set(AConfig.hNonSphereDescription, 'String', sprintf(['There are 4 methods to generate the ROI mask file:' ...
				 '\n\n1. From statistical map by selecting cluster after thresholding' ...100329
				  '\n2. From AAL template by selecting specific area'...
				  '\n3. From Brodmann template by selecting specific area'...
				  '\n4. From user defined mask file'])); 
		set(AConfig.hFromTMap, 'Visible', 'off');
		set(AConfig.hFromAAL, 'Visible', 'off');
		set(AConfig.hFromBrodmann, 'Visible', 'off');
		set(AConfig.hFromUserDefinedMask, 'Visible', 'off');
		set(AConfig.hROINonSphereInfo, 'String', '');
		
		set(AConfig.hROITxtLocation, 'String', AConfig.ROIDefinition);		
	end
	
	set(AConfig.hNext, 'Enable', 'on', 'ForegroundColor', 'black');
	