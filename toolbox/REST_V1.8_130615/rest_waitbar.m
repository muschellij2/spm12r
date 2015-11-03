function rest_waitbar(APercent, AMessage, ATitle, AIsUpdateWho, ANeedCancel, ACancelCallback)
%Parent and child waitbar for REST, by Xiao-Wei Song
%------------------------------------------------------------------------------------------------------------------------------
%	Copyright(c) 2007~2010
%	State Key Laboratory of Cognitive Neuroscience and Learning in Beijing Normal University
%	Written by Xiao-Wei Song 
%	http://resting-fmri.sourceforge.net
%------------------------------------------------------------------------------------------------------------------------------
% Parent is outside of the for-loop or outside of sub-function or inside of GUI
% Child is inside of the for-loop or inside of sub-function or outside of GUI
% Example can be checked in reho_gui.m
%dawnsong, 20070520
% 	<a href="Dawnwei.Song@gmail.com">Mail to Author</a>: Xiaowei Song
%	Version=1.0;
%	Release=20070903;

global hParent hChild;
persistent Last_UpdateClock;
if isempty(Last_UpdateClock), 
	Last_UpdateClock =clock; 
	setappdata(0, 'FlagToRaiseError','no'); %Initialize the error flag
end

%Great priority, 20070530
if isappdata(0, 'FlagToRaiseError') ...
	&& strcmpi(getappdata(0, 'FlagToRaiseError'), 'Yes'),
	
	rmappdata(0, 'FlagToRaiseError');
	
	error('User canceled the operation!');
end

if nargin==0
	%Close wait bar
	if rest_misc( 'ForceCheckExistFigure' , hParent)
		close(hParent);
	end	
	if rest_misc( 'ForceCheckExistFigure' , hChild)
		close(hChild);
	end
	clear hParent hChild;
elseif (nargin==1)||(nargin==3)
	%Update current child progress display
	if rest_misc( 'ForceCheckExistFigure' , hChild)
		if (nargin==1)
			rest_progress(APercent,hChild);
		elseif nargin==3
			rest_progress(APercent,hChild, AMessage, 'Name', ATitle);
		end		
	else
		error('progress bar has not initialized.');
	end	
elseif nargin==4 || nargin==5 ||nargin==6
	%Full parameters	
	if nargin==4 
		ANeedCancel ='I don''t need';
		ACancelCallback ='';
	elseif nargin==5 		
		ACancelCallback ='';
	elseif nargin==6
		%Do nothing because all parameters I need have been set by the Caller
	end
	if strcmpi(AIsUpdateWho, 'parent')
		GetHandleOrCreate('parent', 'true', ANeedCancel, ACancelCallback);
		
		rest_progress(APercent,hParent,sprintf('Total progress:\n%s',AMessage), 'Name', ATitle);
	elseif strcmpi(AIsUpdateWho, 'child')
		GetHandleOrCreate('child', 'true', ANeedCancel, ACancelCallback);
		
		if rest_misc( 'ForceCheckExistFigure' , hParent)
			theMsg =sprintf('Current progress:\n%s',AMessage);
		else
			theMsg =AMessage;
		end
		
		rest_progress(APercent,hChild, theMsg, 'Name', ATitle);		
        if etime(clock, Last_UpdateClock)>1
            Last_UpdateClock =clock;
			if rest_misc( 'ForceCheckExistFigure' , hParent)
				rest_progress(-1,hParent);	
			end	    			
        end    
	end
	%Adjust progress window's position to make the child always stay on top of the parent
	if rest_misc( 'ForceCheckExistFigure' , hParent) ...
		&& rest_misc( 'ForceCheckExistFigure' , hChild) ,
		theParentPosition =get(hParent, 'Position');
		theChildPosition =get(hChild, 'Position');	
		theChildPosition(1) =theParentPosition(1);
		theChildPosition(2) = theParentPosition(4) +theParentPosition(2) +50;
		set(hChild, 'Position', theChildPosition);
	end
else
	error('Bad call to rest_waitbar(AIsUpdateWho, APercent, AMessage, ATitle)');
end


function GetHandleOrCreate(AIsCheckWho, AIsCreate, ANeedCancel, ACancelCallback)
	global hParent hChild
	
	if strcmpi(AIsCheckWho, 'parent')
		hParent = findobj(allchild(0),'flat','Tag','DParent_Waitbar');
		if isempty(hParent) && strcmpi(AIsCreate, 'true') ...
			&& ~rest_misc( 'ForceCheckExistFigure' , hParent),
			%Check whether to Create a Button to allow cancel current operation
			if strcmpi(ANeedCancel,'NeedCancelBtn'),
				hParent=rest_progress(0,'Total Progress','Tag','DParent_Waitbar', ...
							'CreateCancelBtn', @BtnCancelCallback);
			else
				hParent=rest_progress(0,'Total Progress','Tag','DParent_Waitbar');
			end	
		end			
	elseif strcmpi(AIsCheckWho, 'child')
		hChild  = findobj(allchild(0),'flat','Tag','DChild_Waitbar');
		if isempty(hChild) && strcmpi(AIsCreate, 'true') ...
			&& ~rest_misc( 'ForceCheckExistFigure' , hChild),
			%Check whether to Create a Button to allow cancel current operation
			if strcmpi(ANeedCancel,'NeedCancelBtn'),
				hChild=rest_progress(0,'Current Progress','Tag','DChild_Waitbar', ...
								'CreateCancelBtn', @BtnCancelCallback);
			else
				hChild=rest_progress(0,'Current Progress','Tag','DChild_Waitbar');
			end
		end	
	end
function BtnCancelCallback(h,varargin)
	%I can't throw the exception out because Matlab always catch the error in Controls' Callback.
	%Then I can't make the program stop by simply issue a error statement
	%So I have to set a flag and check the flag in the next time
	% dawnsong ,20070530
	setappdata(0, 'FlagToRaiseError',questdlg('Cancel calculating?','Confirm','Cancel'));
		
	% if strcmpi(questdlg('Cancel calculating?','Confirm','Cancel'), 'yes'),		
		% Evaluate the user-defined Callback
		% fprintf('.');
		% error(sprintf('User Canceled the Operation'));		
	% end