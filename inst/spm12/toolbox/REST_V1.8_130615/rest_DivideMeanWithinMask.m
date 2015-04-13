function rest_DivideMeanWithinMask(ASrcReHo, ADstReHo, AMaskFilename)
% Compute the mean within the mask and divide ReHo brain by the mean
%format: rest_DivideMeanWithinMask(ASrcReHo, ADstReHo, AMaskFilename)
% Input:
% ASrcReHo, string, a ReHo brain file (i.e RehoMap or RehoMap.{hdr/img})
% AMaskFile, string, a mask file (i.e mask.{hdr/img} or mask.mat)
% Output:
% ADstReHo, string, a ReHo brain file (i.e mRehoMap, no {hdr/img})
%------------------------------------------------------------------------------------------------------------------------------
%	Copyright(c) 2007~2010
%	State Key Laboratory of Cognitive Neuroscience and Learning in Beijing Normal University
%	Written by Xiao-Wei Song 
%	http://resting-fmri.sourceforge.net
%------------------------------------------------------------------------------------------------------------------------------
% Dawnwei.Song@gmail.com
% 20070504
% 	Mail to Authors:  <a href="Dawnwei.Song@gmail.com">Xiaowei Song</a>; <a href="ycg.yan@gmail.com">Chaogan Yan</a> 
%	Version=1.3;
%	Release=20090321;
%   Revised by YAN Chao-Gan, 080610. NIFTI compatible
%   Last Revised by YAN Chao-Gan, 090321. Result data will be saved in the format 'single'.

	if ~(nargin==3) error(' Error using ==> DivideMaskMean. 3 arguments wanted.'); end

	%Load the original ReHo map file
	[brainMap,vsize, Header]=rest_readfile(ASrcReHo);
	M = size(brainMap,1); N = size(brainMap,2); O = size(brainMap,3);
	isize = [M N O]; vsize =vsize';
	mask=rest_loadmask(M, N, O, AMaskFilename);

	%Calcute the mean and divide ReHo map by the mean
	pos=find(mask);
	masked_brainMap=zeros(size(brainMap,1),size(brainMap,2),size(brainMap,3));
	masked_brainMap(pos)=brainMap(pos);
	mean_value=reshape(masked_brainMap, size(masked_brainMap,1)*size(masked_brainMap,2)*size(masked_brainMap,3), 1);
	mean_value=double(sum(mean_value)) / double(length(pos));
	ResultReHoMap=brainMap./mean_value;
	rest_writefile(single(ResultReHoMap),ADstReHo,isize,vsize,Header, 'single'); %Revised by YAN Chao-Gan, 090321. Result data will be stored in 'single' format. %'double');


