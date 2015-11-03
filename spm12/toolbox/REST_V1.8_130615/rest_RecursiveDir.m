function Result=rest_RecursiveDir(ADataDir, ACallback)
%Recursive do with Dir and all its sub-folders by Xiao-Wei Song
%------------------------------------------------------------------------------------------------------------------------------
%	Copyright(c) 2007~2010
%	State Key Laboratory of Cognitive Neuroscience and Learning in Beijing Normal University
%	Written by Xiao-Wei Song 
%	http://resting-fmri.sourceforge.net
%------------------------------------------------------------------------------------------------------------------------------
%
% 	<a href="Dawnwei.Song@gmail.com">Mail to Author</a>: Xiaowei Song
%	Version=1.0;
%	Release=20071103;
	RunCallback(ADataDir, ACallback);
	pause(0.1);
	
	theFileList = dir(ADataDir);	
	ImgDirList ={};
	for x = 1:size(struct2cell(theFileList),2),
	    if theFileList(x).isdir && (~ strcmpi(theFileList(x).name,'.')) && (~ strcmpi(theFileList(x).name,'..')),
			ImgDirList=[ImgDirList; {theFileList(x).name}];            
	    end
	end	
	Result =ImgDirList;
	
	for x = 1:size(ImgDirList,1),
		RunCallback(fullfile(ADataDir,ImgDirList{x}), ACallback);	    
		rest_RecursiveDir(fullfile(ADataDir,ImgDirList{x}), ACallback);
	end	
	
function RunCallback(ADataDir, ACallback)	
	% Run the Callback
	if ~isempty(ACallback),
		if ischar(ACallback),
			if isempty(strfind(ACallback, '%s')),
				eval(ACallback); %run callback for caller
			else
				eval(sprintf(ACallback, ADataDir)); %run callback for caller
			end
		elseif isa(ACallback, 'function_handle')
			%I give 3 parameters, 20071103,
			%This method not work for reho_gui
			%Error:
			% 	 ??? Unable to find subsindex function for class 
			%hObject, ADataDir, handles
			ACallback(gcbo, ADataDir, guidata(gcbo));
		end
	end