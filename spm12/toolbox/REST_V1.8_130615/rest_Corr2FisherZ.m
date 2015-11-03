function rest_Corr2FisherZ(ACorrMapFilename, AZScoreMapFilename, AMaskFilename)
%	Fisher Z score transformation
%Usage:
%	rest_Corr2FisherZ(ACorrMap, AZScoreMap, AMaskFilename)
%	ACorrMapFilename,			Input, Original Pearson Product Moment correlation map
%	AZScoreMapFilename,		Output, Fisher Z score map
%	AMaskFilename,		Input, Mask file
%
%-----------------------------------------------------------
%	Copyright(c) 2007~2010
%	State Key Laboratory of Cognitive Neuroscience and Learning in Beijing Normal University
%	Written by Xiao-Wei Song 
%	http://resting-fmri.sourceforge.net
% 	Mail to Authors:  <a href="Dawnwei.Song@gmail.com">Xiaowei Song</a>; <a href="ycg.yan@gmail.com">Chaogan Yan</a> 
%	Version=1.3;
%	Release=20090321;
%   Revised by YAN Chao-Gan, 080610. NIFTI compatible
%   Last Revised by YAN Chao-Gan, 090321. Result data will be saved in the format 'single'.
%-----------------------------------------------------------

	if ~(nargin==3) error(' Error using ==> rest_Corr2FisherZ. 3 arguments wanted.'); end

	%Load the original ReHo map file
	[BrainMap,VoxelSize, Header]=rest_readfile(ACorrMapFilename);
	nDim1 = size(BrainMap,1); nDim2 = size(BrainMap,2); nDim3 = size(BrainMap,3);
	BrainSize = [nDim1 nDim2 nDim3]; VoxelSize =VoxelSize';	
	mask=rest_loadmask(nDim1, nDim2, nDim3, AMaskFilename);
		
	pos=find(mask);
	BrainMap(pos) =0.5 * log((1 +BrainMap(pos))./(1- BrainMap(pos)));
	rest_writefile(single(BrainMap),AZScoreMapFilename,BrainSize,VoxelSize,Header, 'single'); %Revised by YAN Chao-Gan, 090321. Result data will be stored in 'single' format. %'double');


