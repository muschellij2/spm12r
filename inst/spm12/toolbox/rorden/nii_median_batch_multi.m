function nii_median_batch_multi ;
% Computes median for many images, saves results in text file
%
%YOU CAN EDIT SUBJ TO BE LIST OF ALL IMAGES...
%  subj = strvcat('/usr/a/im1.nii','/usr/a/im2.nii','/usr/a/im3.nii');
%CHANGE 'mask.voi' to be name of mask
%  mask could be .nii, .nii.gz or .voi

%select files with a dialog
 subj = spm_select(inf,'image','Select images to compute median');
%select regions of integer with a dialog 
 roi = spm_select(inf,'image','Select regions of interest');

fileID = fopen('results.txt','w');
%header line shows filenames
fprintf(fileID,'RegionOfInterest');
for i=1:size(subj,1)
    fprintf(fileID,'\t%s',deblank(subj(i,:)));
end;
fprintf(fileID,'\n');


b = zeros(size(roi,1) ,size(subj,1));
for r=1:size(roi,1)
    fprintf(fileID,'%s',deblank(roi(r,:)));
    for i=1:size(subj,1)
        b(r,i) =  nii_median(deblank(subj(i,:)),deblank(roi(r,:)));
        fprintf(fileID,'\t%12.8f',b(r,i));
    end;
    fprintf(fileID,'\n');
end;
fclose(fileID);
%out= 'results.txt';
%dlmwrite(out,'median','-append', 'delimiter', '');
%dlmwrite(out, b, '-append', 'delimiter', '\t');