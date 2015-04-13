function [ANCOVA_F,ANCOVA_P]=rest_ancova1_Image(DependentDirs,OutputName,MaskFile,CovariateDirs,OtherCovariates)
% [ANCOVA_F,ANCOVA_P]=rest_ancova1_Image(DependentDirs,OutputName,MaskFile,CovariateDirs,OtherCovariates)
% Perform one-way ANOVA or ANCOVA analysis on Images
% Input:
%   DependentDirs - the image directory of dependent variable, each directory indicate a group. Group number by 1 cell
%   OutputName - the output name.
%   MaskFile - the mask file.
%   CovariateDirs - the image directory of covariates, in which the files should be correspond to the DependentDirs. Group number by 1 cell
%   OtherCovariates - The other covariates. Group number by 1 cell 
%                     Perform ANOVA analysis if all the covariates are empty.
% Output:
%   ANCOVA_F - the F value, also write image file out indicated by OutputName
%   ANCOVA_P - the P value
%___________________________________________________________________________
% Written by YAN Chao-Gan 100317.
% State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University, China, 100875
% ycg.yan@gmail.com


if nargin<=4
    OtherCovariates=[];
    if nargin<=3
        CovariateDirs=[];
        if nargin<=2
            MaskFile=[];
        end
    end
end

GroupNumber=length(DependentDirs);

DependentVolume=[];
CovariateVolume=[];
GroupLabel=[];
OtherCovariatesMatrix=[];
for i=1:GroupNumber
    [AllVolume,VoxelSize,theImgFileList, Header,nVolumn] =rest_to4d(DependentDirs{i});
    fprintf('\n\tImage Files in Group %d:\n',i);
    for itheImgFileList=1:length(theImgFileList)
        fprintf('\t%s\n',theImgFileList{itheImgFileList});
    end
    DependentVolume=cat(4,DependentVolume,AllVolume);
    if ~isempty(CovariateDirs)
        [AllVolume,VoxelSize,theImgFileList, Header_Covariate,nVolumn] =rest_to4d(CovariateDirs{i});
        fprintf('\n\tImage Files in Covariate %d:\n',i);
        for itheImgFileList=1:length(theImgFileList)
            fprintf('\t%s\n',theImgFileList{itheImgFileList});
        end
        CovariateVolume=cat(4,CovariateVolume,AllVolume);
        
        if ~all(Header.dim==Header_Covariate.dim)
            msgbox('The dimension of covariate image is different from the dimension of group image, please check them!','Dimension Error','error');
            return;
        end
    end
    if ~isempty(OtherCovariates)
        OtherCovariatesMatrix=[OtherCovariatesMatrix;OtherCovariates{i}];
    end
    GroupLabel=[GroupLabel;ones(nVolumn,1)*i];
    clear AllVolume
end

[nDim1,nDim2,nDim3,nDim4]=size(DependentVolume);

if ~isempty(MaskFile)
    [MaskData,MaskVox,MaskHead]=rest_readfile(MaskFile);
else
    MaskData=ones(nDim1,nDim2,nDim3);
end

rest_waitbar;
ANCOVA_F=zeros(nDim1,nDim2,nDim3);
ANCOVA_P=ones(nDim1,nDim2,nDim3);
fprintf('\n\tANCOVA Test Calculating...\n');
for i=1:nDim1
    rest_waitbar(i/nDim1, 'ANCOVA Test Calculating...', 'ANCOVA Test','Child');
    fprintf('.');
    for j=1:nDim2
        for k=1:nDim3
            if MaskData(i,j,k)
                DependentVariable=squeeze(DependentVolume(i,j,k,:));
                if ~isempty(CovariateDirs)
                    CovariateVariable=squeeze(CovariateVolume(i,j,k,:));
                else
                    CovariateVariable=[];
                end
                if any(DependentVariable)
                    [F P]=rest_ancova1(DependentVariable,GroupLabel,[CovariateVariable,OtherCovariatesMatrix]);
                    ANCOVA_F(i,j,k)=F;
                    ANCOVA_P(i,j,k)=P;
                end
            end
        end
    end
end
ANCOVA_F(isnan(ANCOVA_F))=0;
ANCOVA_P(isnan(ANCOVA_P))=1;

Df_Group=GroupNumber-1;
Df_E=nDim4-Df_Group-1-size([CovariateVariable,OtherCovariatesMatrix],2);
Header.descrip=sprintf('REST{F_[%.1f,%.1f]}',Df_Group,Df_E);
rest_writefile(ANCOVA_F,OutputName,[nDim1,nDim2,nDim3],VoxelSize, Header,'double');
% rest_WriteNiftiImage(ANCOVA_F,Header,OutputName);
% Header.descrip=sprintf('REST{P_[%.1f,%.1f]}',Df_Group,Df_E);
% rest_WriteNiftiImage(ANCOVA_P,Header,[OutputName(1:end-4),'_P','.img']);

rest_waitbar;
fprintf('\n\tANCOVA Test Calculation finished.\n');

