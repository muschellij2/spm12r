function nii_median_batch (Filenames);
% Computes median for many images, saves results in text file
%
%YOU CAN EDIT SUBJ TO BE LIST OF ALL IMAGES...
%  subj = strvcat('/usr/a/im1.nii','/usr/a/im2.nii','/usr/a/im3.nii');
%CHANGE 'mask.voi' to be name of mask
%  mask could be .nii, .nii.gz or .voi

%select files with a dialog…
 subj = spm_select(inf,'image','Select images to compute median');
%or set files manually…
% subj = strvcat('MNI152_T1_2mm_brain.nii.gz','R_ant_insula.nii.gz');
out= 'results.txt';
b = zeros(1,size(subj,1));
for i=1:size(subj,1)
   b(1,i) =  nii_median(deblank(subj(i,:)),'mask.voi');
end;
dlmwrite(out,'median','-append', 'delimiter', '');
dlmwrite(out, b, '-append', 'delimiter', '\t');