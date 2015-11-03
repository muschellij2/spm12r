function ZMap=rest_gca_Std(FMap,ZMap,AMaskFilename)
% Transform the F values to normal-distributed ZF values 
% Input:
% Fmap: The F'-value maps computed by "rest_gca_residual" 
% AMaskFilename: A mask file (i.e. mask.{hdr/img})
% Output:
% ZMap: The transformed F'-value map.
% -------------------------------------------------------------------------
% written by Zang Zhen-Xiang 110504
% Beijing Jiaotong University
% State Key Laboratory of Cognitive Neuroscience and Learning in Beijing
% Normal University
% http://resting-fmri.sourceforge.net
% zangzx416@sina.com
% -------------------------------------------------------------------------


if ~(nargin==3) error(' Error using ==> 3 arguments wanted.'); end

%Load the original GCA maps file
[brainMap,vsize, Header]=rest_readfile(FMap);
M = size(brainMap,1); N = size(brainMap,2); O = size(brainMap,3);
isize = [M N O]; vsize =vsize';
mask=rest_loadmask(M, N, O, AMaskFilename);

%Divide mean within mask
pos=find(mask);
masked_brainMap=zeros(size(brainMap,1),size(brainMap,2),size(brainMap,3));
masked_brainMap(pos)=brainMap(pos);
mean_value=mean(reshape(masked_brainMap, size(masked_brainMap,1)*size(masked_brainMap,2)*size(masked_brainMap,3), 1));
Std=std(reshape(masked_brainMap, size(masked_brainMap,1)*size(masked_brainMap,2)*size(masked_brainMap,3), 1));
ResultMap=(brainMap-mean_value)./Std;
ResultMap=ResultMap.*mask;
rest_writefile(single(ResultMap),ZMap,isize,vsize,Header, 'single');



















