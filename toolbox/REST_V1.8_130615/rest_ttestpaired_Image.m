function [TTestPaired_T]=rest_ttestpaired_Image(DependentDirs,OutputName,MaskFile)
% [TTestPaired_T]=rest_ttestpaired_Image(DependentDirs,OutputName,MaskFile)
% Perform Paired T test.
% Input:
%   DependentDirs - the image directory of dependent variable. Cell 1 indicate Situation 1 and Cell 2 indicate Situation 2. The T is corresponding to Situation 1 minus Situation 2. 2 by 1 cell
%   OutputName - the output name.
%   MaskFile - the mask file.
% Output:
%   TTestPaired_T - the T value, also write image file out indicated by OutputName
%___________________________________________________________________________
% Written by YAN Chao-Gan 100317.
% State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University, China, 100875
% ycg.yan@gmail.com

if nargin<=2
    MaskFile=[];
end

[Situation1Volume,VoxelSize,theImgFileList, Header,nVolumn] =rest_to4d(DependentDirs{1});
fprintf('\n\tImage Files in Condition 1:\n');
for itheImgFileList=1:length(theImgFileList)
    fprintf('\t%s\n',theImgFileList{itheImgFileList});
end
[Situation2Volume,VoxelSize,theImgFileList, Header,nVolumn] =rest_to4d(DependentDirs{2});
fprintf('\n\tImage Files in Condition 2:\n');
for itheImgFileList=1:length(theImgFileList)
    fprintf('\t%s\n',theImgFileList{itheImgFileList});
end

[nDim1,nDim2,nDim3,nDim4]=size(Situation1Volume);

if ~isempty(MaskFile)
    [MaskData,MaskVox,MaskHead]=rest_readfile(MaskFile);
else
    MaskData=ones(nDim1,nDim2,nDim3);
end

Df_E=nDim4-1;

rest_waitbar;
TTestPaired_T=zeros(nDim1,nDim2,nDim3);
fprintf('\n\tPaired T Test Calculating...\n');

DependentVolume=Situation1Volume-Situation2Volume;
MeanVariable=mean(DependentVolume,4);
StdVariable=std(DependentVolume,0,4);
TTestPaired_T=MeanVariable./(StdVariable/sqrt(nDim4));

TTestPaired_T(~isfinite(TTestPaired_T))=0;
TTestPaired_T=TTestPaired_T.*MaskData;

Header.descrip=sprintf('REST{T_[%.1f]}',Df_E);
rest_writefile(TTestPaired_T,OutputName,[nDim1,nDim2,nDim3],VoxelSize, Header,'double');
% rest_WriteNiftiImage(TTestPaired_T,Header,OutputName);

rest_waitbar;
fprintf('\n\tPaired T Test Calculation finished.\n');
