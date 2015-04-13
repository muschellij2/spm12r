function [rCorr,pCorr]=rest_corr_Image(DependentDir,SeedSeries,OutputName,MaskFile,CovariateDir,OtherCovariate)
% [rCorr,pCorr]=rest_corr_Image(DependentDir,SeedSeries,OutputName,MaskFile,CovariateDir,OtherCovariate)
% Perform correlation analysis with or without covariate.
% Input:
%   DependentDir - the image directory of the group
%   SeedSeries - the seed series
%   OutputName - the output name.
%   MaskFile - the mask file.
%   CovariateDir - the image directory of covariate, in which the files should be correspond to the DependentDir
%   OtherCovariate - The other covariate
% Output:
%   rCorr - Pearson's Correlation Coefficient or partial correlation coeffcient, also write image file out indicated by OutputName
%   pCorr - the P value
%___________________________________________________________________________
% Written by YAN Chao-Gan 100411.
% State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University, China, 100875
% ycg.yan@gmail.com

if nargin<=5
    OtherCovariate=[];
    if nargin<=4
        CovariateDir=[];
        if nargin<=3
            MaskFile=[];
        end
    end
end


[DependentVolume,VoxelSize,theImgFileList, Header,nVolumn] =rest_to4d(DependentDir);
fprintf('\n\tImage Files in the Group:\n');
for itheImgFileList=1:length(theImgFileList)
    fprintf('\t%s\n',theImgFileList{itheImgFileList});
end

if ~isempty(CovariateDir)
    [CovariateVolume,VoxelSize,theImgFileList, Header_Covariate,nVolumn] =rest_to4d(CovariateDir);
    fprintf('\n\tImage Files in the Covariate:\n');
    for itheImgFileList=1:length(theImgFileList)
        fprintf('\t%s\n',theImgFileList{itheImgFileList});
    end
    
    if ~all(Header.dim==Header_Covariate.dim)
        msgbox('The dimension of covariate image is different from the dimension of group image, please check them!','Dimension Error','error');
        return;
    end
end

[nDim1,nDim2,nDim3,nDim4]=size(DependentVolume);

if ~isempty(MaskFile)
    [MaskData,MaskVox,MaskHead]=rest_readfile(MaskFile);
else
    MaskData=ones(nDim1,nDim2,nDim3);
end

Df_E=nDim4-2-size(OtherCovariate,2);
if ~isempty(CovariateDir)
    Df_E=Df_E-1;
end

rest_waitbar;
rCorr=zeros(nDim1,nDim2,nDim3);
pCorr=ones(nDim1,nDim2,nDim3);
fprintf('\n\tCorrelation Calculating...\n');
for i=1:nDim1
    rest_waitbar(i/nDim1, 'Correlation Calculating...', 'Correlation Analysis','Child');
    fprintf('.');
    for j=1:nDim2
        for k=1:nDim3
            if MaskData(i,j,k)
                DependentVariable=squeeze(DependentVolume(i,j,k,:));
                if ~isempty(CovariateDir)
                    CovariateVariable=squeeze(CovariateVolume(i,j,k,:));
                else
                    CovariateVariable=[];
                end
                if any(DependentVariable)
                    if isempty([CovariateVariable,OtherCovariate])
                        [r p]=corrcoef(DependentVariable,SeedSeries);
                    else
                        [r p]=partialcorr([DependentVariable,SeedSeries],[CovariateVariable,OtherCovariate]);
                    end
                    rCorr(i,j,k)=r(1,2);
                    pCorr(i,j,k)=p(1,2);
                end
            end
        end
    end
end
rCorr(isnan(rCorr))=0;
pCorr(isnan(pCorr))=1;

Header.descrip=sprintf('REST{R_[%.1f]}',Df_E);
rest_writefile(rCorr,OutputName,[nDim1,nDim2,nDim3],VoxelSize, Header,'double');
% rest_WriteNiftiImage(rCorr,Header,OutputName);
%  Header.descrip=sprintf('REST{P_[%.1f]}',Df_E);
%  rest_WriteNiftiImage(pCorr,Header,[OutputName(1:end-4),'_P','.img']);

rest_waitbar;
fprintf('\n\tCorrelation Calculation finished.\n');
