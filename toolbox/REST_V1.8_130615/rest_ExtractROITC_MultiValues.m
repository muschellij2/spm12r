function [theROITimeCourses] = rest_ExtractROITC_MultiValues(ADataDir, AROIDef, OutDir)
% FORMAT [] = rest_ExtractROITC_MultiValues(ADataDir, AROIDef, OutDir)
% Extract Multi label values in a single mask file.
% Input:
%   ADataDir - where the 3d+time dataset stay, and there should be 3d EPI functional image files. It must not contain / or \ at the end.
%   AROIDef - A cell of the mask list , ROI list definition. AROIDef would be	treated as a mask in which time courses would be averaged to produce a new time course representing the ROI area
%             e.g. {'ROI Center(mm)=(0, 0, 0); Radius=6.00 mm.';'ROI Center(mm)=(5, 9, 20); Radius=6.00 mm.';'D:\Data\ROI.img'}
%   OutDir - where the results should be written.
% Output:
%   *.mat/.txt - The extracted time courses and Pierson's correlations would be saved as .mat/.txt files in the output directory.
%___________________________________________________________________________
% Written by DONG Zhang-Ye 110504 for REST, based on rest_ExtractROITC.m.
% State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University, China, 100875
% dongzy08@gmail.com


theElapsedTime =cputime;
fprintf('\nExtracting ROI time courses:\t"%s"', ADataDir);
[Path, SubID, extn] = fileparts(ADataDir);
[AllVolume,VoxelSize,theImgFileList, Header,nVolumn] =rest_to4d(ADataDir);
% examin the dimensions of the functional images and set mask
nDim1 = size(AllVolume,1); nDim2 = size(AllVolume,2); nDim3 = size(AllVolume,3);
BrainSize = [nDim1 nDim2 nDim3];
sampleLength = nVolumn;

AROIList =AROIDef;
theROITimeCoursesTotal=[];
if iscell(AROIDef),	%ROI wise, compute corelations between regions
    %ROI time course retrieving, 20070903
    theROITimeCourses =zeros(sampleLength,1);
    for x=1:size(AROIDef,1),
        fprintf('\n\t ROI time courses retrieving through "%s".', AROIDef{x});
        IsDefinedROITimeCourse =0;
        if rest_SphereROI( 'IsBallDefinition', AROIDef{x})
            %The ROI definition is a Ball definition
            maskROI =rest_SphereROI( 'BallDefinition2Mask' , AROIDef{x}, BrainSize, VoxelSize, Header);
        elseif exist(AROIDef{x},'file')==2	% Make sure the Definition file exist
            [maskROI, vsizeTmp, Header]=rest_readfile(AROIDef{x});
        else
            error(sprintf('Wrong ROI definition, Please check: \n%s', AROIDef{x}));
        end

        if ~IsDefinedROITimeCourse,% I need retrieving the ROI averaged time course manualy
            LabelValue=unique(maskROI);
            LabelValue(LabelValue==0)=[];%remove 0 value
            MulmaskROI=maskROI;
            for LabIndex=1:size(LabelValue,1)
                maskROI =find(MulmaskROI==LabelValue(LabIndex));
                for t=1:sampleLength,
                    theTimePoint = squeeze(AllVolume(:,:,:, t));
                    theTimePoint = theTimePoint(maskROI);
                    if ~isempty(theTimePoint),
                        theROITimeCourses(t) =mean(theTimePoint);
                    end
                end	%The Averaged Time Course within the ROI now comes out! 20070903
                save([OutDir,filesep,SubID,'_ROI',num2str(x),'_ROIlabel',num2str(LabelValue(LabIndex)),'_ROISignals.mat'],'theROITimeCourses'); %% Revised by YAN Chao-Gan, 100420. Change the output name from "ROITimeCourses" to "ROISeries'. 
                save([OutDir,filesep,SubID,'_ROI',num2str(x),'_ROIlabel',num2str(LabelValue(LabIndex)),'_ROISignals.txt'],'theROITimeCourses', '-ASCII', '-DOUBLE','-TABS');
                theROITimeCoursesTotal=[theROITimeCoursesTotal,theROITimeCourses];
            end   
        end%if ~IsDefinedROITimeCourse
    end%for
    %Save the ROI averaged time course to disk for further study
    save([OutDir,filesep,SubID,'_entireROISignals.mat'],'theROITimeCoursesTotal'); %% Revised by YAN Chao-Gan, 100420. Change the output name from "ROITimeCourses" to "ROISeries'. 
    save([OutDir,filesep,SubID,'_entireROISignals.txt'],'theROITimeCoursesTotal', '-ASCII', '-DOUBLE','-TABS'); %% Revised by YAN Chao-Gan, 100420. Change the output name from "ROITimeCourses" to "ROISeries'. 

    ResultCorr =corrcoef(theROITimeCoursesTotal);
    save([OutDir,filesep,SubID,'_entireResultCorr.mat'],'ResultCorr');
    save([OutDir,filesep,SubID,'_entireResultCorr.txt'],'ResultCorr', '-ASCII', '-DOUBLE','-TABS');
end%ROI wise


theElapsedTime =cputime - theElapsedTime;
fprintf('\n\t Extracting ROI time courses over, elapsed time: %g seconds.\n', theElapsedTime);