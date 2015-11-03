function fout = rest_progress(x,whichbar, varargin)
%Show a progress bar for REST by Xiao-Wei Song
%Revise from Matlab 2006b waitbar, at least 2 parameters
%Usage:
%rest_progress(APercent,hChild);
%rest_progress(APercent,hChild, AMessage, 'Name', ATitle);
%rest_progress(APercent,hParent,sprintf('Total progress:\n%s',AMessage), 'Name', ATitle);
%rest_progress(APercent,hChild, theMsg, 'Name', ATitle);	
%------------------------------------------------------------------------------------------------------------------------------
%	Copyright(c) 2007~2010
%	State Key Laboratory of Cognitive Neuroscience and Learning in Beijing Normal University
%	Written by Xiao-Wei Song 
%	http://resting-fmri.sourceforge.net
%dawnsong, 20070520
%------------------------------------------------------------------------------------------------------------------------------
%	Dawnwei.Song@gmail.com
% 	<a href="Dawnwei.Song@gmail.com">Mail to Author</a>: Xiaowei Song
%	Version=1.0;
%	Release=20070903;

if nargin>2
    if ischar(whichbar) || iscellstr(whichbar)
        type=2; %we are initializing
        msg=whichbar;
    elseif isnumeric(whichbar)
        type=1; %we are updating, given a handle
        f=whichbar;
    else
        error('MATLAB:waitbar:InvalidInputs', ['Input arguments of type ' class(whichbar) ' not valid.'])
    end
elseif nargin==2    
	f=whichbar;
	if ~isnumeric(f),
		error('rest_progress, Input arguments not valid.');
	end
	IsExistFigure = sum(allchild(0) == f);
    if ~IsExistFigure
        type=2;
        msg='Waitbar';
    else
        type=1;        
    end
else
    error('rest_progress, Input arguments not valid.');
end

if (x>=0)&&(x<=1)
	x = max(0,min(100*x,100));
else
	x=-1;
end	

switch type
    case 1,  % waitbar(x)    update
		ProgressStartTime =getappdata(f, 'ProgressStartTime');
		OldPercent =getappdata(f, 'OldPercent');				
        if isempty(ProgressStartTime) || isempty(OldPercent) || ((x>=0)&&(OldPercent >x+3))
			ProgressStartTime =clock;
            OldPercent =0;
		end
		if x~=-1	%normal
			OldPercent =x;
		elseif ~isempty(OldPercent)		%Update GUI only, don't change progress x%
			x =OldPercent; %Update message  or time-msg only,x=-1
		else
			x=0;
        end
		setappdata(f, 'ProgressStartTime', ProgressStartTime);
		setappdata(f, 'OldPercent', OldPercent);
		% Update time indicator
		hTime = findobj(f,'Tag','DTimeIndicator');
		timeElapsed =etime(clock, ProgressStartTime);
		timeRemain  =timeElapsed *(100-x)/(1+x);
		theTimeMsg  =sprintf('%d%%  Elapsed %d:%d:%d, Remain %d:%d:%d    %d:%d:%d Started', ...
								floor(x), ...
								floor(timeElapsed /60 /60), ...
								mod(floor(timeElapsed /60),60) , ...
								mod(floor(timeElapsed), 60) , ...
								floor(timeRemain /60 /60), ...
								mod(floor(timeRemain /60),60), ...								
								mod(floor(timeRemain), 60) , ...
								ProgressStartTime(4), ...
								ProgressStartTime(5), ...
								floor(ProgressStartTime(6)) );
		set(hTime, 'string', theTimeMsg);
		
			  
        p = findobj(f,'Type','patch');
        l = findobj(f,'Type','line');
        if isempty(f) || isempty(p) || isempty(l),
            error('MATLAB:waitbar:WaitbarHandlesNotFound', 'Couldn''t find waitbar handles.');
        end
        xpatch = get(p,'XData');
		%Clear old first
		reset(p);
        xpatch = [0 x x 0];%Update now
		ypatch = [0 0 1 1];
        set(p,'XData',xpatch, 'YData',ypatch, 'FaceColor', 'r')
        xline = get(l,'XData');
        set(l,'XData',xline);

		
		
        if nargin>2,
            % Update Message
			SetMessage(f, 'DMessage',varargin{1});            
						
			propList = varargin(2:2:end);
            valueList = varargin(3:2:end);
            
            for ii = 1:length( propList )
                try                    
					% simply set the prop/value pair of the figure
					set( f, propList{ii}, valueList{ii});                    
                catch
                    disp ( ['Warning: could not set property ''' propList{ii} ''' with value ''' num2str(valueList{ii}) '''' ] );
                end
            end
        end
		
    case 2,  % waitbar(x,msg)  initialize
        vertMargin = 5;
        if nargin > 2,
            % we have optional arguments: property-value pairs
            if rem(nargin, 2 ) ~= 0
                error('MATLAB:waitbar:InvalidOptionalArgsPass',  'Optional initialization arguments must be passed in pairs');
            end
        end       
        
		oldUnit =get(0, 'Units');
		set(0,'Units','pixels');
		screenSize =get(0, 'ScreenSize');
		set(0,'Units',oldUnit);
        width = 360;
        height = 75;
		%Screen Center
        pos = [screenSize(3)/2-width/2 screenSize(4)/2-height/2 width height];

        f = figure(...
            'Units', 'pixels', ...
            'BusyAction', 'queue', ...
            'Position', pos, ...
            'Resize','off', ...
            'CreateFcn','', ...
            'NumberTitle','off', ...
            'IntegerHandle','off', ...
            'MenuBar', 'none', ...
            'Tag','TMWWaitbar',...
            'Interruptible', 'off', ...
            'Visible','off');

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % set figure properties as passed to the fcn
        % pay special attention to the 'cancel' request
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        visValue = 'on';
        if nargin > 2,
            propList = varargin(1:2:end);
            valueList = varargin(2:2:end);
            cancelBtnCreated = 0;

            visibleExist = strmatch('vis',lower(propList));
            if ~isempty(visibleExist)
                visValue = valueList{visibleExist};
            end

            for ii = 1:length( propList )
                try
                    if strcmpi(propList{ii}, 'CreateCancelBtn' ) && ~cancelBtnCreated
                        cancelBtnHeight = 25;
                        cancelBtnWidth = 90;
                        newPos = pos;
                        vertMargin = 5 + cancelBtnHeight+5;
                        newPos(4) = newPos(4)+vertMargin;
                        callbackFcn = [valueList{ii}];
                        set( f, 'Position', newPos); %, 'CloseRequestFcn', callbackFcn );
                        uicontrol('Parent',f, 'Tag', 'btnCancel', ... 
	                            'Units','pixels', ...
								'Interruptible', 'off', ...
	                            'Callback',callbackFcn, ...	                            
	                            'Enable','on', ...	                            
	                            'Position', [pos(3)-cancelBtnWidth-5, 5,  ...
	                            cancelBtnWidth, cancelBtnHeight], ...
	                            'String','Cancel');
                        cancelBtnCreated = 1;
                    else
                        % simply set the prop/value pair of the figure
                        set( f, propList{ii}, valueList{ii});
                    end
                catch
                    disp ( ['Warning: could not set property ''' propList{ii} ''' with value ''' num2str(valueList{ii}) '''' ] );
                end
            end
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
		hTime=uicontrol('Style', 'text', 'Parent', f, ...			
			'Tag', 	'DTimeIndicator', ...
			'Units', 'pixels', ...
			'FontSize', 10, ...
			'Position', [5 vertMargin pos(3)-10 15], ...
			'HorizontalAlignment', 'left', ...
			'BackgroundColor', get(f,'Color'), ...
			'String', 'Elapsed 0:0:0, remain 0:0:0');
		vertMargin =vertMargin +21 +5;	

        colormap([]);       		
        axPos=[5 vertMargin pos(3)-10 15];

        h = axes('XLim',[0 100],...
            'YLim',[0 1],...
            'Box','on', ...
            'Units','pixels',...
            'FontSize', 16,...
            'Position',axPos,...
            'XTickMode','manual',...
            'YTickMode','manual',...
            'XTick',[],...
            'YTick',[],...
            'XTickLabelMode','manual',...
            'XTickLabel',[],...
            'YTickLabelMode','manual',...
            'YTickLabel',[] );

        
		hMessage=uicontrol('Style', 'text', 'Parent', f, ...			
			'Tag', 	'DMessage', ...
			'Units', 'pixels', ...
			'FontSize', 10, ...
			'Position', [5 vertMargin+20 pos(3)-10 21], ...
			'HorizontalAlignment', 'left', ...
			'BackgroundColor', get(f,'Color'), ...
			'String', msg);
        SetMessage(f, 'DMessage', msg); 

        xpatch = [0 x x 0];
        ypatch = [0 0 1 1];
        xline = [100 0 0 100 100];
        yline = [0 0 1 1 0];

        p = patch(xpatch,ypatch,'r','EdgeColor','r','EraseMode','none');
        l = line(xline,yline,'EraseMode','none');
        set(l,'Color',get(gca,'XColor'));


        set(f,'HandleVisibility','callback','Visible', visValue);
end  % case
drawnow;

if nargout==1,
    fout = f;
end

function SetMessage(AFigHandle,ATag ,AMessage)
	hMsg  = findobj(AFigHandle ,'Tag',ATag);
	set(hMsg,'string',AMessage);	
	
	theOldPosition =get(hMsg,'Position');	
	[newMsg,newMsgPos]=textwrap(hMsg,cellstr(AMessage));	
	%newMsgPos(3) =theOldPosition(3);	%the width is suppressed to be same 
	
	%Adjust the Figure's Height
	theFigurePos =get(AFigHandle,'Position');
	theFigurePos(4) =theFigurePos(4) + ( newMsgPos(4)-theOldPosition(4) );	
	set(AFigHandle,'Position', theFigurePos);
	
	newMsgPos(3) =max(newMsgPos(3), theOldPosition(3));
    set(hMsg, 'String', newMsg, 'Position', newMsgPos);