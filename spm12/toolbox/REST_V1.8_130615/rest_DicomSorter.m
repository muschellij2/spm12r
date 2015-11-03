function dirlist=rest_DicomSorter(rawdir,outdir,dicomtype,DirectoryHierarchy)
% FORMAT dirlist=rest_DicomSorter(rawdir,outdir,dicomtype,DirectoryHierarchy)
%   Input:
%     rawdir - directory of source files
%     outdir - directory to store the sorted dir
%     dicomtype - The File name surfix of the DICOM files. e.g. IMA, dcm or none.
%     DirectoryHierarchy - The Hierarchy of Directory: 0 - SubjectName/SeriesName; 1 - SeriesName/SubjectName.
%   Output:
%     *.IMA/*.dcm/*.* - Sorted DICOM images.
%   By YAN Chao-Gan and Dong Zhang-Ye 091212.
%   State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University, China, 100875
%	http://www.restfmri.net
% 	Mail to Authors:  <a href="ycg.yan@gmail.com">YAN Chao-Gan</a>; <a href="dongzy08@gmail.com">DONG Zhang-Ye</a>
%	Version=1.0;
%	Release=20091215;
%------------------------------------------------------------------------------------------------------------------------------


if strcmp(dicomtype,'none')
    rawdatatmp=dir([rawdir,filesep,'*']);
    rawdata= rawdatatmp(3:end);
else
    rawdata=dir([rawdir,filesep,'*.',dicomtype]);
end
dirlist={};
for i=1:length(rawdata)
     rest_waitbar(i/length(rawdata), ...
					rawdir, ...
					'DICOM Sorting','Child','NeedCancelBtn');
    dicominfotmp = dicominfo([rawdir,filesep,rawdata(i).name]);
    Indextmp=['0000',int2str(dicominfotmp.SeriesNumber)];
    if DirectoryHierarchy==0
        dirname=[outdir,filesep,dicominfotmp.PatientID,filesep,Indextmp(end-3:end),'_',dicominfotmp.ProtocolName];
    else
        dirname=[outdir,filesep,Indextmp(end-3:end),'_',dicominfotmp.ProtocolName,filesep,dicominfotmp.PatientID];
    end
    if ~isdir(dirname)
        mkdir(dirname);
        dirlist=[dirlist;dirname];
    end
    copyfile([rawdir,filesep,rawdata(i).name],dirname);
end