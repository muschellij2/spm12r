function nii_exists = nii_filedir_exists(lStr, displaytext)
%returns 1 if file exists

if nargin <2 
 displaytext = 1;
end;

nii_exists = 0; %Report failure if early exit
if isempty(lStr), warning('nii_filedir_exists: Nothing to do'); 
    return;
end;

[pth,nam,ext, versn] = spm_fileparts(lStr);

lSearchStr = dir(fullfile(pth,[nam ext]));
if length(lSearchStr)  == 0
	if displaytext == 1
		disp(sprintf('No files found:  %s', fullfile(pth,[nam ext versn]) ))
	end;
	return  
end

nii_exists = 1; %Report success!