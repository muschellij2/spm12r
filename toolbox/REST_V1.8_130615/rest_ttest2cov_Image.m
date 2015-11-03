function [TTest2Cov_T,TTest2Cov_P]=rest_ttest2cov_Image(DependentDirs,OutputName,MaskFile,CovariateDirs,OtherCovariates)
% [TTest2Cov_T,TTest2Cov_P]=rest_ttest2cov_Image(DependentDirs,OutputName,MaskFile,CovariateDirs,OtherCovariates)
% Perform two sample t test with or without covariates.
% Input:
%   DependentDirs - the image directory of dependent variable, each directory indicate a group. The T is corresponding to the first group minus the second group. 2 by 1 cell
%   OutputName - the output name.
%   MaskFile - the mask file.
%   CovariateDirs - the image directory of covariates, in which the files should be correspond to the DependentDirs. 2 by 1 cell
%   OtherCovariates - The other covariates. 2 by 1 cell 
% Output:
%   TTest2Cov_T - the T value (corresponding to the first group minus the second group), also write image file out indicated by OutputName
%   TTest2Cov_P - the P value
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

GroupLabel(GroupLabel==2)=-1;

[nDim1,nDim2,nDim3,nDim4]=size(DependentVolume);

if ~isempty(MaskFile)
    [MaskData,MaskVox,MaskHead]=rest_readfile(MaskFile);
else
    MaskData=ones(nDim1,nDim2,nDim3);
end

Df_E=nDim4-2-size(OtherCovariatesMatrix,2);
if ~isempty(CovariateDirs)
    Df_E=Df_E-1;
end

rest_waitbar;
TTest2Cov_T=zeros(nDim1,nDim2,nDim3);
TTest2Cov_P=ones(nDim1,nDim2,nDim3);
fprintf('\n\tTwo Sapmle T Test Calculating...\n');
for i=1:nDim1
    rest_waitbar(i/nDim1, 'Two Sample T Test Calculating...', 'Two Sapmle T Test','Child');
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
                    % Calculate SSE_H: sum of squared errors when H0 is true
                    [b,r,SSE_H] = rest_regress_ss(DependentVariable,[ones(nDim4,1),CovariateVariable,OtherCovariatesMatrix]);
                    % Calulate SSE
                    [b,r,SSE] = rest_regress_ss(DependentVariable,[ones(nDim4,1),GroupLabel,CovariateVariable,OtherCovariatesMatrix]);
                    % Calculate F
                    F=((SSE_H-SSE)/1)/(SSE/Df_E);
                    P =1-fcdf(F,1,Df_E);
                    T=sqrt(F)*sign(b(2));
                    TTest2Cov_T(i,j,k)=T;
                    TTest2Cov_P(i,j,k)=P;
                end
            end
        end
    end
end
TTest2Cov_T(isnan(TTest2Cov_T))=0;
TTest2Cov_P(isnan(TTest2Cov_P))=1;

Header.descrip=sprintf('REST{T_[%.1f]}',Df_E);
rest_writefile(TTest2Cov_T,OutputName,[nDim1,nDim2,nDim3],VoxelSize, Header,'double');
% rest_WriteNiftiImage(TTest2Cov_T,Header,OutputName);
% Header.descrip=sprintf('REST{P_[%.1f]}',Df_E);
% rest_WriteNiftiImage(TTest2Cov_P,Header,[OutputName(1:end-4),'_P','.img']);

rest_waitbar;
fprintf('\n\tTwo Sample T Test Calculation finished.\n');
