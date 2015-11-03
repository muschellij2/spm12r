function rest_ChangeDicomInfo(SourceDir,DestinationDir,SubID,FileNameSurfix)
% FORMAT rest_ChangeDicomInfo(SourceDir,DestinationDir,SubID,FileNameSurfix)
%   Input:
%     SourceDir - directory of source files
%     DestinationDir - directory to store the processed dir
%     SubID - The New ID of the DICOM files
%     FileNameSurfix - The File name surfix of the DICOM files. e.g. IMA, dcm or none.
%   Output:
%     *.IMA/*.dcm - DICOM images without private information
%___________________________________________________________________________
% Written by YAN Chao-Gan 090303.
% State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University, China, 100875
% ycg.yan@gmail.com

if strcmp(FileNameSurfix,'none')
    dtmp= dir([SourceDir,filesep,'*']);
    d = dtmp(3:end);
    FileNameSurfix='dcm';
else
    d = dir([SourceDir,filesep,'*.',FileNameSurfix]);
end

for p = 1:numel(d)
    rest_waitbar(p/numel(d), ...
					SourceDir, ...
					'Anonymizing','Child','NeedCancelBtn');
    info=dicominfo([SourceDir,filesep,d(p).name]);
    I = dicomread(info);
    Indexp=['0000000',num2str(p)];
    Indexp=Indexp(end-6:end);
    info.Filename = [Indexp,'.',FileNameSurfix];
    info.PatientName.FamilyName = SubID;
    info.PatientID = SubID;
    info.PatientBirthDate = '';
    dicomwrite(I,[DestinationDir,filesep,info.Filename],info, 'createmode', 'copy');   %The Data will be changed without copy mode. YAN Chao-Gan 090410. %dicomwrite(I,[DestinationDir,'\',info.Filename],info);
    fprintf(1,'.')
end
rest_waitbar;

fprintf(1,'.\nChange Dicom Information End.')
