function [TTest1_T]=rest_ttest1_Image(DependentDirs,OutputName,MaskFile,Base)
% [TTest1_T]=rest_ttest1_Image(DependentDirs,OutputName,MaskFile)
% Perform one sample t test.
% Input:
%   DependentDirs - the image directory of dependent variable. 1 by 1 cell
%   OutputName - the output name.
%   MaskFile - the mask file.
%   Base - the base of one sample T Test. 0: default.
% Output:
%   TTest1_T - the T value, also write image file out indicated by OutputName
%___________________________________________________________________________
% Written by YAN Chao-Gan 100317.
% State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University, China, 100875
% ycg.yan@gmail.com

if nargin<=3
    Base=0;
    if nargin<=2
        MaskFile=[];
    end
end

[DependentVolume,VoxelSize,theImgFileList, Header,nVolumn] =rest_to4d(DependentDirs{1});
fprintf('\n\tImage Files in the Group:\n');
for itheImgFileList=1:length(theImgFileList)
    fprintf('\t%s\n',theImgFileList{itheImgFileList});
end

[nDim1,nDim2,nDim3,nDim4]=size(DependentVolume);

if ~isempty(MaskFile)
    [MaskData,MaskVox,MaskHead]=rest_readfile(MaskFile);
else
    MaskData=ones(nDim1,nDim2,nDim3);
end

Df_E=nDim4-1;

rest_waitbar;
TTest1_T=zeros(nDim1,nDim2,nDim3);
fprintf('\n\tOne Sample T Test Calculating...\n');

DependentVolume=DependentVolume-Base;
MeanVariable=mean(DependentVolume,4);
StdVariable=std(DependentVolume,0,4);
TTest1_T=MeanVariable./(StdVariable/sqrt(nDim4));

TTest1_T(~isfinite(TTest1_T))=0;
TTest1_T=TTest1_T.*MaskData;

Header.descrip=sprintf('REST{T_[%.1f]}',Df_E);
rest_writefile(TTest1_T,OutputName,[nDim1,nDim2,nDim3],VoxelSize, Header,'double');
% rest_WriteNiftiImage(TTest1_T,Header,OutputName);

rest_waitbar;
fprintf('\n\tOne Sample T Test Calculation finished.\n');
