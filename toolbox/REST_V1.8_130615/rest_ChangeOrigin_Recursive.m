function Result=rest_ChangeOrigin_Recursive(ADataDir, ANewOrigin)
%Recursive change ANALYZE 7.5 Format's Origin
%-----------------------------------------------------------
%	Copyright(c) 2007~2010
%	State Key Laboratory of Cognitive Neuroscience and Learning in Beijing Normal University
%	Written by Xiao-Wei Song 
%	http://resting-fmri.sourceforge.net
%-----------------------------------------------------------
% 	<a href="Dawnwei.Song@gmail.com">Mail to Author</a>: Xiaowei Song
%	Version=1.0;
%	Release=20071101;

	%Change Self dir first
    rest_ChangeOrigin(ADataDir, ANewOrigin);

	theFileList = dir(ADataDir);	
	ImgDirList ={};
	for x = 1:size(struct2cell(theFileList),2),
	    if theFileList(x).isdir && (~ strcmpi(theFileList(x).name,'.')) && (~ strcmpi(theFileList(x).name,'..')),
			ImgDirList=[ImgDirList; {theFileList(x).name}];            
	    end
	end	
	Result =ImgDirList;
	
	for x = 1:size(ImgDirList,1),
	    rest_ChangeOrigin(fullfile(ADataDir,ImgDirList{x}), ANewOrigin);
		rest_ChangeOrigin_Recursive(fullfile(ADataDir,ImgDirList{x}), ANewOrigin);
	end	
	