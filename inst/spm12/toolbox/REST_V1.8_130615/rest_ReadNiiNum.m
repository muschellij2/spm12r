function N=rest_ReadNiiNum(PI)
%function N=rest_ReadNiiNum(PI)
%Get the number of volume in the *.nii file.
%Input:
%   PI: *.nii file name;
%Output:
%   N: the number of volume;
%___________________________________________________________________________
% By DONG Zhang-Ye 110817.
% State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University, China, 100875
% donzy08@gmail.com
% Last revised by YAN Chao-Gan, 111111. Add the support for .nii.gz files.

addpath(fullfile(rest_misc('WhereIsREST'), 'rest_spm5_files'));

if strcmpi(PI(end-6:end), '.nii.gz')  %YAN Chao-Gan, 111111. Uncompress data for .nii.gz file.
    gunzip(PI);
    IsNeedDeleteUncompressedVersioin = 1;
    PI = PI(1:end-3);
end

V = rest_spm_vol(PI);

N=length(V);

if exist('IsNeedDeleteUncompressedVersioin','var') && IsNeedDeleteUncompressedVersioin == 1
    delete(PI); %YAN Chao-Gan, 111111. Delete the uncompressed version after reading for .nii.gz file.
end

rmpath(fullfile(rest_misc('WhereIsREST'), 'rest_spm5_files'));
