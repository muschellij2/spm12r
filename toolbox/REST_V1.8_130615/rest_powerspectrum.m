function [varargout]=rest_powerspectrum(AOperation, varargin)
%Visualize the Power Spectrum and the Time course of user specified voxel whose coordinates could be set with SliceViewer By Xiao-Wei Song
%------------------------------------------------------------------------------------------------------------------------------
%	Copyright(c) 2007~2010
%	State Key Laboratory of Cognitive Neuroscience and Learning in Beijing Normal University
%	Written by Xiao-Wei Song 
%	http://resting-fmri.sourceforge.net
%------------------------------------------------------------------------------------------------------------------------------
% Draw the time course fluctions at the specific position in the 3D+time Dataset
% 	Mail to Authors:  <a href="Dawnwei.Song@gmail.com">Xiaowei Song</a>; <a href="ycg.yan@gmail.com">Chaogan Yan</a> 
%	Version=1.2;
%	Release=20080626;
%   Revised by YAN Chao-Gan 080610: NIFTI compatible

if nargin<1, help rest_powerspectrum; return; end

persistent ReHo_WaveGraph_Cfg; % run-time persistent config
%ADataDir, AVoxelPosition, ABandLow, ABandHigh
if ~mislocked(mfilename),mlock; end

switch upper(AOperation),
case 'SHOWFLUCTUATION',	%ShowFluctuation
	if nargin~=5, error('Usage: rest_powerspectrum(''ShowFluctuation'', ADataDir, AVoxelPosition, ASamplePeriod, ABandRange);'); end
	ADataDir 		=varargin{1};
    AVoxelPosition 	=varargin{2};
	ASamplePeriod  	=varargin{3};
	ABandRange  	=varargin{4};
	theFig =ExistDisplayFigure(ReHo_WaveGraph_Cfg, ADataDir);
	isExistFig =rest_misc( 'ForceCheckExistFigure' , theFig);	%Force check whether the figure exist
	if ~isExistFig
		%the specific image didn't exist, so I create one
		ReHo_WaveGraph_Cfg.Config(1+GetDisplayCount(ReHo_WaveGraph_Cfg)) =InitControls(ADataDir, AVoxelPosition, ASamplePeriod, ABandRange);
		%To Force display 
		theFig =ReHo_WaveGraph_Cfg.Config(GetDisplayCount(ReHo_WaveGraph_Cfg)).hFig;
	else
		%Update the VoxelPosition, SamplePeriod, BandRange
		theCardinal =ExistDisplay(ReHo_WaveGraph_Cfg, ADataDir);
		if theCardinal>0,			
			ReHo_WaveGraph_Cfg.Config(theCardinal).VoxelPosition =AVoxelPosition;
			%Add the voxel to the voxel array
			ReHo_WaveGraph_Cfg.Config(theCardinal).VoxelArray =[AVoxelPosition; ReHo_WaveGraph_Cfg.Config(theCardinal).VoxelArray];
			
			ReHo_WaveGraph_Cfg.Config(theCardinal).SamplePeriod	 =ASamplePeriod;
			ReHo_WaveGraph_Cfg.Config(theCardinal).BandRange     =ABandRange;			
			% if get(ReHo_WaveGraph_Cfg.Config(theCardinal).hDetrendBeforeFFT, 'Value'),
				% ReHo_WaveGraph_Cfg.Config(theCardinal).DetrendBeforeFFT ='Yes';
			% else
				% ReHo_WaveGraph_Cfg.Config(theCardinal).DetrendBeforeFFT ='No';
			% end
			PlotFluctuation(ReHo_WaveGraph_Cfg.Config(theCardinal));
		end
	end
	figure(theFig);
	varargout{1} =theFig;	
	
case 'ONFIGUREDELETE',				%OnFigureDelete
	if nargin~=2, error('Usage: rest_powerspectrum(''OnFigureDelete'', ADataDir);'); end
	
	ADataDir =varargin{1};
	ReHo_WaveGraph_Cfg =DeleteFigure(ReHo_WaveGraph_Cfg, ADataDir);	

case 'ONFIGURERESIZE', 		%OnFigureResize
	if nargin~=2, error('Usage: rest_powerspectrum(''ResizeFigure'', ADataDir);'); end
	ADataDir 		=varargin{1};
	theFig =ExistDisplayFigure(ReHo_WaveGraph_Cfg, ADataDir);
	isExistFig =rest_misc( 'ForceCheckExistFigure' , theFig);	%Force check whether the figure exist
	if isExistFig
		theCardinal =ExistDisplay(ReHo_WaveGraph_Cfg, ADataDir);
		if theCardinal>0			
			OnFigureResize(ReHo_WaveGraph_Cfg.Config(theCardinal));
		end
	end
	
case 'ONOPTIONDETRENDBEFOREFFT', 		%OnOptionDetrendBeforeFFT	
	if nargin~=2, error('Usage: rest_powerspectrum(''OnOptionDetrendBeforeFFT'', ADataDir);'); end
	ADataDir 		=varargin{1};
	theFig =ExistDisplayFigure(ReHo_WaveGraph_Cfg, ADataDir);
	isExistFig =rest_misc( 'ForceCheckExistFigure' , theFig);	%Force check whether the figure exist
	if isExistFig
		theCardinal =ExistDisplay(ReHo_WaveGraph_Cfg, ADataDir);
		if theCardinal>0,
			if get(ReHo_WaveGraph_Cfg.Config(theCardinal).hDetrendBeforeFFT, 'Value'),
				ReHo_WaveGraph_Cfg.Config(theCardinal).DetrendBeforeFFT ='Yes';
			else
				ReHo_WaveGraph_Cfg.Config(theCardinal).DetrendBeforeFFT ='No';
			end
			PlotFluctuation(ReHo_WaveGraph_Cfg.Config(theCardinal));
		end
	end
	varargout{1} =theFig;
	
case 'QUITALLPOWERSPECTRUM',		%QuitAllPowerSpectrum
	if nargin~=1, error('Usage: rest_powerspectrum(''QuitAllPowerSpectrum'');'); end
	for x=1:GetDisplayCount(ReHo_WaveGraph_Cfg), 
		rest_powerspectrum('OnFigureDelete', ReHo_WaveGraph_Cfg.Config(x).DataDir);
	end
	clear ReHo_WaveGraph_Cfg;
		
	
otherwise
end

function Result =InitControls(ADataDir, AVoxelPosition, ASamplePeriod, ABandRange)	
	%Construct 3D+time dataset	
	[theDataset, theVoxelSize, theImgFileList, Header,nVolumn]=rest_to4d(ADataDir);
	[nDim1, nDim2, nDim3, nDim4] =size(theDataset);
	rest_waitbar;
	
	%Initialization 20070525
	theFig =figure('Units', 'pixel', 'MenuBar', 'none', 'Toolbar', 'figure', ...
				'NumberTitle', 'off', 'Name', ADataDir, ...
				'DeleteFcn', sprintf('rest_powerspectrum(''OnFigureDelete'', ''%s'');', rest_misc('ReplaceSingleQuota', ADataDir)) , ...
				'ResizeFcn', sprintf('rest_powerspectrum(''OnFigureResize'', ''%s'');', rest_misc('ReplaceSingleQuota', ADataDir)) );
	MarginX =10; MarginY =10;
	OffsetX =3*MarginX; 	OffsetY =MarginY;
		
	%Create Axes and lines and images			
	hVoxelPosition  =uicontrol(theFig, 'Style','radiobutton', 'Units','pixels', ...
							  'String', sprintf('(%d,%d,%d)',AVoxelPosition), ...
							  'BackgroundColor', get(theFig,'Color'), ...
							  'HorizontalAlignment', 'left', ...
							  'Position',[OffsetX, OffsetY, 150,15]);
		
	%Create options to draw the Power Spectrum
	OffsetX =3*MarginX; 	OffsetY =MarginY +25;				
	hDetrendBeforeFFT =uicontrol(theFig, 'Style','checkbox', 'Units','pixels', ...
							  'String', 'Remove Linear Trend Before Power Spectrum', ...
							  'BackgroundColor', get(theFig,'Color'), ...
							  'HorizontalAlignment', 'left', ...
							  'Value', 1, ...
							  'Callback', ...
							  sprintf('rest_powerspectrum(''OnOptionDetrendBeforeFFT'', ''%s'');', rest_misc('ReplaceSingleQuota', ADataDir)), ...
							  'Position',[OffsetX, OffsetY, 250,15]);
		
	%Create Axes
	OffsetX =6*MarginX; 	OffsetY =3*MarginY +15 +3*MarginY;				
	hAxesTimeCourse	=axes('Parent', theFig, ...
						  'Units', 'pixel', 'DrawMode','fast', ...
						  'Position', [OffsetX OffsetY 3*nDim4 150]);
						  
	OffsetX =6*MarginX; 	OffsetY =3*MarginY +15 +6*MarginY +150 +6*MarginY;
	hAxesAmplitude	=axes('Parent', theFig, ...
						  'Units', 'pixel', 'DrawMode','fast', ...
						  'Position', [OffsetX OffsetY 3*nDim4 150], ...
						  'NextPlot', 'replacechildren');						  
	%Save to config
	AConfig.hFig			=theFig;			%handle of the config
	%Save Axes's handles
	AConfig.hAxesTimeCourse 	=hAxesTimeCourse;
	AConfig.hAxesAmplitude 		=hAxesAmplitude;
	
	%Save Voxel position label handle
	AConfig.hVoxelPosition 		=hVoxelPosition;
	% Save Options' handles
	AConfig.hDetrendBeforeFFT	=hDetrendBeforeFFT;
		
	%Save important variables
	AConfig.DataDir 		=ADataDir;		
	AConfig.VoxelPosition 	=AVoxelPosition;		%[x y z] the Voxel position in Volume current showing its amplitude and its time course
	AConfig.VoxelArray		=AVoxelPosition;		%20070718
	
	AConfig.Dataset 		=theDataset;
	AConfig.SamplePeriod 	=ASamplePeriod;		%TR
	AConfig.BandRange 		=ABandRange;		%[BandLow BandHigh] or [HighCutoff LowCutoff]
	AConfig.DetrendBeforeFFT='Yes';				% Remove linear trend before FFT
    Result =AConfig;
	
	
	%%Display Images
	PlotFluctuation(AConfig);
	
	%Resize figure width and height
	FigWidth  =6*MarginX + 3*nDim4 + 6*MarginX;
	FigHeight =3*MarginY +15 +6*MarginY +150 +6*MarginY + 150+ 3*MarginY ;
	thePos =get(theFig, 'Position');	
	theScreenSize =get(0,'ScreenSize');
	if thePos(1)>= theScreenSize(3)
		thePos(1) =theScreenSize(1);
	end	
	if 	(thePos(2) +FigHeight) +100>= theScreenSize(4)
		thePos(2) =theScreenSize(4) -FigHeight -100;
	end
	thePos =[thePos(1), thePos(2), FigWidth,FigHeight];	
	set(theFig, 'Position', thePos);	
	%Force resize the figure	
	OnFigureResize(AConfig);
	
	return;



function Result =DeleteFigure(AGlobalConfig, ADataDir)
	x =ExistDisplay(AGlobalConfig, ADataDir);
	if x>0
		theDisplayCount =GetDisplayCount(AGlobalConfig);
		isExistFig =rest_misc( 'ForceCheckExistFigure' , AGlobalConfig.Config(x).hFig);
		if isExistFig
			delete(AGlobalConfig.Config(x).hFig);
			if theDisplayCount>x
				for y=x:theDisplayCount-1
					AGlobalConfig.Config(x) =AGlobalConfig.Config(x+1);
                end
            end	
            AGlobalConfig.Config(theDisplayCount)=[];
		end	
	end
	Result =AGlobalConfig;
function Result =GetDisplayCount(AGlobalConfig)
%Get the Count of display, this program allow multi-view of brain like MRIcro
	if isempty(AGlobalConfig) || isempty(AGlobalConfig.Config),
		Result =0;		
	else
		Result =length(AGlobalConfig.Config);
	end
	return;
	
function Result =ExistDisplayFigure(AGlobalConfig, ADataDir)
%Check if specific view exist by its image's filename, Result is the cardinal number of the specify display
	Result =-1;
	theCardinal =ExistDisplay(AGlobalConfig, ADataDir);
	if theCardinal>0,
		Result =AGlobalConfig.Config(theCardinal).hFig;
    end
    
function Result =ExistDisplay(AGlobalConfig, ADataDir)
%Check if specific view exist by its image's filename , Result is the cardinal number of the specify display
	Result =0;
	if (isstruct(AGlobalConfig) && isstruct(AGlobalConfig.Config))
		for x=1:length(AGlobalConfig.Config)
			if strcmpi( AGlobalConfig.Config(x).DataDir, ADataDir)
				Result =x;
				return;
            end
        end        
	else				
		return;
	end	



function PlotFluctuation(AConfig)
	theX =AConfig.VoxelPosition(1);
	theY =AConfig.VoxelPosition(2);
	theZ =AConfig.VoxelPosition(3);
	
	% AConfig.VoxelPosition =reshape(AConfig.VoxelPosition, [1, 3]);, 20071008
	if all([AConfig.VoxelPosition,0]<=size(AConfig.Dataset)) && all(AConfig.VoxelPosition>=[1 1 1]),
	else	%Illegal
		error(sprintf('Illegal voxel position: (%s)', num2str(AConfig.VoxelPosition)));
	end
	
	%Plot the time course
	theTimeCourse =squeeze(AConfig.Dataset(theX, theY, theZ, :));
	axes(AConfig.hAxesTimeCourse);	cla;
	if rest_misc('GetMatlabVersion')>=7.3,	
		plot([1:length(theTimeCourse)] *AConfig.SamplePeriod, ...
				theTimeCourse,'blue', 'DisplayName', 'Time Course');
	else	% Matlab 6.5 doesn't support  plot's property 'DisplayName'
		plot([1:length(theTimeCourse)] *AConfig.SamplePeriod, ...
			theTimeCourse,'blue');
	end	
	xlim([1, length(theTimeCourse)] *AConfig.SamplePeriod);
	theYLim =[min(theTimeCourse), max(theTimeCourse)];
	if ~isfinite(theYLim(1)), theYLim(1)=0; end
	if ~isfinite(theYLim(2)), theYLim(2)=0; end
	if theYLim(2)>theYLim(1), ylim(theYLim); end	
	set(gca, 'Title',text('String','Time Course', 'Color', 'magenta'));
	xlabel('Time( seconds)');
	ylabel('Intensity');
	
	%Plot the amplitude in Freq domain
	thePaddedLen =rest_nextpow2_one35(length(theTimeCourse));
	if strcmpi(AConfig.DetrendBeforeFFT, 'Yes'),				
		%Before FFT, remove linear trend first
		theTimeCourseNoTrend =detrend(double(theTimeCourse))  ;%...
					%+ repmat(mean(double(theTimeCourse)),[length(theTimeCourse), 1]);
		%Draw the detrended data in the timeCourse Axes
		axes(AConfig.hAxesTimeCourse);	hold on;
		thePlotTimeCourse =theTimeCourseNoTrend + repmat(mean(double(theTimeCourse)), [length(theTimeCourse), 1]);
		if rest_misc('GetMatlabVersion')>=7.3,
			plot([1:length(theTimeCourse)] *AConfig.SamplePeriod, ...
					thePlotTimeCourse, 'g:', 'DisplayName', 'Detrended Time Course');		
		else
			plot([1:length(theTimeCourse)] *AConfig.SamplePeriod, ...
					thePlotTimeCourse, 'g:');		
		end
		theYLim =[min(theYLim(1),min(thePlotTimeCourse)), max(theYLim(2),max(thePlotTimeCourse))];
		if ~isfinite(theYLim(1)), theYLim(1)=0; end
		if ~isfinite(theYLim(2)), theYLim(2)=0; end
		if theYLim(2)>theYLim(1), ylim(theYLim); end
		set(gca, 'Title',text('String','Time Course(Green dot line is after removing linear trend)', 'Color', 'magenta'));
		
		%Calculate the FFT
		thePowerTitle ='Power Spectrum after removing linear trend';
		
		theFreqSeries =fft(theTimeCourseNoTrend, thePaddedLen); % multiply 2 just because I only plot half of the spectrum, so I make all enery to the plotted half part
	else		
		%Don't remove the linear trend before FFT
		thePowerTitle ='Power Spectrum';
		
		theFreqSeries =fft(double(theTimeCourse), thePaddedLen); % multiply 2 just because I only plot half of the spectrum, so I make all enery to the plotted half part
	end		
	
	theSampleFreq		=1/AConfig.SamplePeriod ;
	theFreqPrecision 	=theSampleFreq/thePaddedLen;
	theFreqLim =[theFreqPrecision: theFreqPrecision :theSampleFreq/2];
	theXLim =[2,(thePaddedLen/2 +1)];	%don't Contain DC, because AFNI don't contain it in PowerSpectrum
	
	%Calcute the Power Spectrum
	theFreqSeries =abs(theFreqSeries([theXLim(1):theXLim(2)])); % Get the half's amplitude	
	theFreqSeries(1:end) =theFreqSeries(1:end).^2 /length(theTimeCourse);%Don't containt the DC component because abs didn't make DC 2-times to its original amplitude , dawnsong 20070629
	%theFreqSeries(1) =theFreqSeries(1) /length(theTimeCourse);	% now process the DC component
	
	%Since we dropped half the FFT, we multiply mx by 2 to keep the same energy.  
	% The DC component and Nyquist component, if it exists, are unique and should not 
	% be mulitplied by 2. 
	theFreqSeries(1:end-1) =theFreqSeries(1:end-1) *2;
	
	
	axes(AConfig.hAxesAmplitude);	cla;
	if rest_misc('GetMatlabVersion')>=7.3,
		plot(theFreqLim, theFreqSeries, ...
			'Color', 'blue', 'DisplayName', 'Power Spectrum');	
	else
		plot(theFreqLim, theFreqSeries, 'Color', 'blue');	
	end
	
	xlim([theFreqLim(1) , theFreqLim(end)]);
	theYLim =[min(theFreqSeries(1:end)), max(theFreqSeries(1:end))];
	if ~isfinite(theYLim(1)), theYLim(1)=0; end
	if ~isfinite(theYLim(2)), theYLim(2)=0; end
	if theYLim(2)>theYLim(1), ylim(theYLim); end	
	set(gca, 'Title',text('String',thePowerTitle, 'Color', 'magenta'));	
	xlabel(sprintf('Frequency( Hz), Sample Period( TR)=%g seconds', AConfig.SamplePeriod));
	ylabel('Amplitude');
	
	%Enable datacursormode for Matlab 7
	if rest_misc('GetMatlabVersion')>=7.0,
		hDataCursor = datacursormode(AConfig.hFig); 
		set(hDataCursor,'DisplayStyle','datatip', 'SnapToDataVertex','on','Enable','on') 
		set(hDataCursor,'UpdateFcn', @SetDataTip); 
	end
		
	%Draw the range defined by BandRange
	hold on;
	if rest_misc('GetMatlabVersion')>=7.3,
		plot([1, 1]*AConfig.BandRange(1), get(gca,'Ylim'), 'r:', 'DisplayName', 'Band Limit');
	else
		plot([1, 1]*AConfig.BandRange(1), get(gca,'Ylim'), 'r:');
	end
	text(AConfig.BandRange(1),theYLim(2)-theYLim(2)/10, ...
		sprintf('\\leftarrow %g Hz', AConfig.BandRange(1)),...
		'HorizontalAlignment','left', 'Color', 'red');
	if rest_misc('GetMatlabVersion')>=7.3,	
		plot([1, 1]*AConfig.BandRange(2), get(gca,'Ylim'), 'r:', 'DisplayName', 'Band Limit');
	else
		plot([1, 1]*AConfig.BandRange(2), get(gca,'Ylim'), 'r:');
	end
	text(AConfig.BandRange(2),theYLim(2)-theYLim(2)/10, ...
		sprintf('\\leftarrow %g Hz', AConfig.BandRange(2)),...
		'HorizontalAlignment','left', 'Color', 'red');
		
	% Draw the Voxel position
	theName =sprintf('(%d,%d,%d)',AConfig.VoxelPosition);
	% theName =sprintf('%s Time Course: mean=%g, std=%g ',theName, ...
					% mean(double(theTimeCourse)), std(double(theTimeCourse)));	
	set(AConfig.hVoxelPosition, ...
		'String', theName, ...
		'TooltipString', sprintf('Time Course: mean=%g, std=%g\n', ...
					mean(double(theTimeCourse)), std(double(theTimeCourse))) );
	%Force resize the figure	
	OnFigureResize(AConfig);
	
function OnFigureResize(AConfig)
	MarginX =10; MarginY =10;
	
	theFigPos =get(AConfig.hFig, 'Position');
	FigWidth =theFigPos(3);
	FigHeight=theFigPos(4);
	
	
	% Resize the Axes's width
	theAxesTimeCoursePos =get(AConfig.hAxesTimeCourse, 'Position');
	theAxesTimeCoursePos(3) =FigWidth -6*MarginX -3*MarginX;	
	%Resize the Axes's height
	theAxesTimeCoursePos(2) =6*MarginY +15;
	theAxesTimeCoursePos(4) =(FigHeight -3*MarginY)/2 -9*MarginY;
	set(AConfig.hAxesTimeCourse, 'Position', theAxesTimeCoursePos);
	
	% Resize the Axes's width
	theAxesAmplitudePos =get(AConfig.hAxesAmplitude, 'Position');
	theAxesAmplitudePos(3) =FigWidth -6*MarginX -3*MarginX;	
	%Resize the Axes's height
	theAxesAmplitudePos(2) =theAxesTimeCoursePos(2) +theAxesTimeCoursePos(4) +9*MarginY;
	theAxesAmplitudePos(4) =(FigHeight -3*MarginY)/2-9*MarginY;
	set(AConfig.hAxesAmplitude, 'Position', theAxesAmplitudePos);
	
	%Resize the Voxel information's width
	thePos =get(AConfig.hVoxelPosition,'Position');
	thePos(3) =FigWidth -thePos(1) -MarginX;
	set(AConfig.hVoxelPosition,'Position', thePos);
	
	drawnow;
	
function Result =SetDataTip(empt, event_obj)	
	pos = get(event_obj,'Position'); 
	hTarget = get(event_obj,'Target');
	theName = get(hTarget,'DisplayName');
	theIdx  =get(event_obj,'DataIndex');
	if strcmpi(theName(1:5), 'Power') ,
		Result = {	[theName], ...
					sprintf('\nFrequency: \t%g Hz', pos(1)), ...					
					sprintf('Power: \t%g',pos(2)), ...
					sprintf('\nIndex: \t%d', theIdx) }; 
	elseif any(findstr(theName, 'Time')),
		Result = {	sprintf('%s\n',theName), ...
					sprintf('Time: %g seconds',pos(1)), ... 
					['Intensity: ',num2str(pos(2))] , ...
					sprintf('\nIndex: \t%d', theIdx) };
	else
		Result = {	sprintf('%s\n',theName), ...
					['X: ',num2str(pos(1))], ... 
					['Y: ',num2str(pos(2))]  };
	end