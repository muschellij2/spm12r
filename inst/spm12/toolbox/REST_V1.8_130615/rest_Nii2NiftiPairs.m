function rest_Nii2NiftiPairs(PI,PO)
% FORMAT rest_Nii2NiftiPairs(PI,PO)
% NIfTI nii to NIfTI pairs (.hdr/.img)
%   PI - input filename: *.nii, *.nii.gz
%   PO - output filename: *.img
%___________________________________________________________________________
% Written by YAN Chao-Gan 091127. 
% State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University, China, 100875
% ycg.yan@gmail.com
% Revised by YAN Chao-Gan, 111111. Add the support for .nii.gz files.
% Last revised by YAN Chao-Gan, 120306. Will not change pinfo to 1


if strcmpi(PI(end-6:end), '.nii.gz')  %YAN Chao-Gan, 111111. Uncompress data for .nii.gz file.
    gunzip(PI);
    IsNeedDeleteUncompressedVersioin = 1;
    PI = PI(1:end-3);
end


[Data, Head] = rest_ReadNiftiImage(PI,'all');
if size(Data,4)>1
    for i=1:length(size(Data,4))
        Index=['000',num2str(i)];
        Index=Index(end-3:end);
%         Head.pinfo = [1;0;0];
        [Path, fileN, extn] = fileparts(PO);
        POout=[Path,filesep,fileN,'_',Index,extn];
        rest_WriteNiftiImage(Data(:,:,:,i),Head,POout);
    end
else
%     Head.pinfo = [1;0;0];
    rest_WriteNiftiImage(Data,Head,PO);
end

if exist('IsNeedDeleteUncompressedVersioin','var') && IsNeedDeleteUncompressedVersioin == 1
    delete(PI); %YAN Chao-Gan, 111111. Delete the uncompressed version after reading for .nii.gz file.
end
