function [theROITimeCourses] = rest_ExtractROITC(ADataDir, AROIDef,OutDir)
% FORMAT [] = rest_ExtractROITC(ADataDir, AROIDef)
% Input:
%   ADataDir - where the 3d+time dataset stay, and there should be 3d EPI functional image files. It must not contain / or \ at the end.
%   AROIDef - A cell of the mask list , ROI list definition. AROIDef would be	treated as a mask in which time courses would be averaged to produce a new time course representing the ROI area
%             e.g. {'ROI Center(mm)=(0, 0, 0); Radius=6.00 mm.';'ROI Center(mm)=(5, 9, 20); Radius=6.00 mm.';'D:\Data\ROI.img'}
% Output:
%   *.mat - The extracted time courses and Pierson's correlations would be saved as .mat files in the current directory of MATLAB.
%___________________________________________________________________________
% Written by YAN Chao-Gan 081212 for DPARSF, based on fc.m.
% State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University, China, 100875
% ycg.yan@gmail.com
% Revised by DONG Zhang-Ye, 091111. Added output directory.
% Revised by YAN Chao-Gan, 100420. Change the output name from "ROITimeCourses" to "ROISeries'. 


theElapsedTime =cputime;
fprintf('\nExtracting ROI time courses:\t"%s"', ADataDir);
[Path, SubID, extn] = fileparts(ADataDir);
[AllVolume,VoxelSize,theImgFileList, Header,nVolumn] =rest_to4d(ADataDir);
% examin the dimensions of the functional images and set mask
nDim1 = size(AllVolume,1); nDim2 = size(AllVolume,2); nDim3 = size(AllVolume,3);
BrainSize = [nDim1 nDim2 nDim3];
sampleLength = nVolumn;

AROIList =AROIDef;
if iscell(AROIDef),	%ROI wise, compute corelations between regions
    %ROI time course retrieving, 20070903
    theROITimeCourses =zeros(sampleLength, size(AROIDef,1));
    for x=1:size(AROIDef,1),
        fprintf('\n\t ROI time courses retrieving through "%s".', AROIDef{x});
        IsDefinedROITimeCourse =0;
        if rest_SphereROI( 'IsBallDefinition', AROIDef{x})
            %The ROI definition is a Ball definition
            maskROI =rest_SphereROI( 'BallDefinition2Mask' , AROIDef{x}, BrainSize, VoxelSize, Header);
        elseif exist(AROIDef{x},'file')==2	% Make sure the Definition file exist
            maskROI =rest_loadmask(nDim1, nDim2, nDim3, AROIDef{x});
        else
            error(sprintf('Wrong ROI definition, Please check: \n%s', AROIDef{x}));
        end

        if ~IsDefinedROITimeCourse,% I need retrieving the ROI averaged time course manualy
            maskROI =find(maskROI);
            % [rangeX, rangeY, rangeZ] = ind2sub(size(maskROI), find(maskROI));
            % theTimeCourses =zeros(length(unique(rangeX)), length(unique(rangeY)), length(unique(rangeZ)));
            for t=1:sampleLength,
                theTimePoint = squeeze(AllVolume(:,:,:, t));
                theTimePoint = theTimePoint(maskROI);
                if ~isempty(theTimePoint),
                    theROITimeCourses(t, x) =mean(theTimePoint);
                end
            end	%The Averaged Time Course within the ROI now comes out! 20070903
        end%if ~IsDefinedROITimeCourse
    end%for
    %Save the ROI averaged time course to disk for further study
    save([OutDir,filesep,SubID,'_ROISignals.mat'],'theROITimeCourses'); %% Revised by YAN Chao-Gan, 100420. Change the output name from "ROITimeCourses" to "ROISeries'. %YAN 110504: Change to ROISignals
    save([OutDir,filesep,SubID,'_ROISignals.txt'],'theROITimeCourses', '-ASCII', '-DOUBLE','-TABS'); %% Revised by YAN Chao-Gan, 100420. Change the output name from "ROITimeCourses" to "ROISeries'.  %YAN 110504: Change to ROISignals

    ResultCorr =corrcoef(theROITimeCourses);
    save([OutDir,filesep,SubID,'_ResultCorr.mat'],'ResultCorr');
    save([OutDir,filesep,SubID,'_ResultCorr.txt'],'ResultCorr', '-ASCII', '-DOUBLE','-TABS');
end%ROI wise


theElapsedTime =cputime - theElapsedTime;
fprintf('\n\t Extracting ROI time courses over, elapsed time: %g seconds.\n', theElapsedTime);