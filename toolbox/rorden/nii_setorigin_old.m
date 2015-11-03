function nii_setorigin (P);
%Attempts to set origin of NIfTI image(s) near anterior commissure.
%  This can prevent normalization from being trapped in a local minima
%   P is either a single T1 image or a T1 image followed by other images from the same session
%  If multiple images are provided, the first image is used to compute the estimate which is then applied to all images.
%  This should ensure that images from the same session stay in register
% Example
%  nii_setorigin ('C:\dir\T1.nii'); %we are only interested in the T1 scan
%  nii_setorigin(strvcat('T1s005.nii', 'fmriblocks009.nii')); %we want both T1 and fMRI realigned

isDisplayResults = false; %should we interactively show our estimate?
FWHM = 8; %smoothing for origin finding, 8mm seems about right
if nargin <1 %no files
 P = spm_select(inf,'image','Image(s) for realignment [for multiple images, first is used for estimate]');
end;
% fprintf('%s WARNING: routines are ALPHA quality - please consider using ACPCdetect\n',mfilename);
ref = deblank(P(1,:));
tic;
mivox =  maxIntenSub(ref,FWHM,isDisplayResults);
M = [1 0 0 -mivox(1); 0 1 0 -mivox(2); 0 0 1 -mivox(3); 0 0 0 1];

disp(P);
fid=fopen([P(1, 1:(end-6)),'_autoreorient.mat'],'w');
for iB=1:length(M), fprintf(fid,'%f\n',M(iB)); end;
fclose(fid);


MM = zeros(4,4,size(P,1));
for j=1:size(P,1),
   MM(:,:,j) = spm_get_space(deblank(P(j,:)));
end;
for j=1:size(P,1),
	spm_get_space(deblank(P(j,:)), M*MM(:,:,j));
end;
toc
if isDisplayResults
    spm_image('init',ref);
    spm_orthviews('Reposition',[0 0 0]);
end;
%end nii_setorigin()

% --- subfunctions follow ---

function mivox = maxIntenSub(V, FWHM, showgraph)
% This attempts to find the origin of an image 
% It returns the number of mm in X,Y,Z that the image should be translated
% This code does not apply this transform!
% Specify a file and the full-width half maximum for the smooth
% An 8mm FWHM seems robust with T1 images
mivox = zeros(1,3); %translate 0mm in X,Y,Z
%extract filename 
[pth,nam,ext] = spm_fileparts(deblank(V(1,:)));
fname = fullfile(pth,[nam ext]);
%report if filename does not exist...
if (exist(fname) ~= 2) 
 	fprintf('%s Error: unable to find image %s.\n',mfilename,fname);
	return;  
end;
%load hdr
fhdr = spm_vol([fname,',1']); 
if (fhdr.dim(1) < 1) or (fhdr.dim(2) < 1)
 	fprintf('%s Error: not a 3D image %s.\n',mfilename,fname);
	return;  
end;
%Find Superior-Inferior dimension
% i.e. find the dimension where Zmm increases the most
dims = [1, fhdr.dim(1), 1, fhdr.dim(2), 1, fhdr.dim(3)];
p = vxl2mmSub (fhdr.mat,[1 1 1]')-vxl2mmSub (fhdr.mat,[dims(2) 1 1]');
zdims(1) = p(3);
p = vxl2mmSub (fhdr.mat,[1 1 1]')-vxl2mmSub (fhdr.mat,[1 dims(4) 1]');
zdims(2) = p(3);
p = vxl2mmSub (fhdr.mat,[1 1 1]')-vxl2mmSub (fhdr.mat,[1 1 dims(6)]');
zdims(3) = p(3);
[C I] = max(abs(zdims));
zdir = round(mean(I)); 
zmm = abs(zdims(zdir))/ fhdr.dim(zdir); %slice thickness in Z dimension
if zdims(zdir) < 0
  dirfoothead = 1;
elseif zdims(zdir) > 0
  dirfoothead = 0;
else
 	fprintf('%s Error: no variation in Zmm %s.\n',mfilename, fname);
	return;
end;  
%at this point
% zdir = 1,2 or 3  : S-I direction is 1st, 2nd or 3rd dimension
% dirfoothead = 1 : I->S
% dirfoothead = 0 : S->I
HeadSkip = round(abs(8/zmm)); %slices to skip from superior dimension before looking for a peak
           %HeadSkip - good idea to skip the first ~8mm incase there is phase-wrap in Superior-Inferior dimension
ZFOV = 30; %for identifying X and Y peaks, we will look +/-60mm in from the Z peak
% rationale the human brain is ~120mm in the Z [superior-inferior] dimension
%now read Z dimension
[xsum, ysum, zsum] =  sumintensitySub (fhdr, FWHM, dims);
if showgraph == 1
 figure('Position',[30 130 680 480])
 plot(xsum)
 hold all
 plot(ysum)
 hold all
 plot(zsum,'LineWidth',2);
 tabfilename = fullfile(fileparts(which(mfilename)),'zhistogram.tab');
 dlmwrite(tabfilename, zsum, 'delimiter', '\t','precision', 6)
end;
if zdir == 1
	if dirfoothead == 1 %I->S
	  k = lastPeakSub(xsum,HeadSkip );
	else
	  k = firstPeakSub(xsum,HeadSkip );
	end;  
	[dims(1) dims(2)] =  setboundSub (k, ZFOV, zmm, dims(2));
elseif zdir == 2
	if dirfoothead == 1 %I->S
	  k = lastPeakSub(ysum,HeadSkip );
	else
	  k = firstPeakSub(ysum,HeadSkip );
	end;
	[dims(3) dims(4)] =  setboundSub (k, ZFOV, zmm, dims(4));
elseif zdir == 3

	if dirfoothead == 1 %I->S
	  k = lastPeakSub(zsum,HeadSkip );
	else
	  k = firstPeakSub(zsum,HeadSkip );
	end; 
	[dims(5) dims(6)] =  setboundSub (k, ZFOV, zmm, dims(6));
else
 	fprintf('%s Error: incompetent developer %s.\n',mfilename,fname);
	return;
end;  
[xsum, ysum, zsum] =  sumintensitySub (fhdr, 0, dims);
 mivox(1)= vectorcenterSub(xsum);
 mivox(2)= vectorcenterSub(ysum);
 mivox(3)= vectorcenterSub(zsum);
 %mivox is now the center of brightness for the superior part of the head (in voxels)
if showgraph == 1
 figure('Position',[30 130 680 480])
 plot(xsum)
 hold all
 plot(ysum)
 hold all
 plot(zsum,'LineWidth',3);
 fprintf('Origin at %gx%gx%g k = %g\n',mivox(1),mivox(2),mivox(3),k);

end;
 mivox(zdir)=k;
 %next - compute difference between original origin and new origin.
 %       the origin will need to be translated by this many mm
 mivox = mivox';
 mivox = vxl2mmSub(fhdr.mat,mivox)';
 mivox(2)=mivox(2)+23; %AC is typically 23mm anterior to center of brightness
%end maxIntenSub()

function middle = vectorcenterSub(vectin);
%http://en.wikipedia.org/wiki/Center_of_mass
len = length(vectin);
middle = 0;
vect=vectin-min(vectin);
usum = sum(vect); %unweighted sum
if (usum == 0) 
  middle = (len)/2;
  return;
end;
wsum =0; %weighted sum
for i=1:len,
  wsum = wsum + (vect(i)*(i-0.5));
end; %for i
middle = wsum/usum;
%end vectorcenterSub()

function [xsum, ysum, zsum] =  sumintensitySub (fhdr, FWHM, bounds);
fdata = spm_read_vols(fhdr); 
xsum=zeros(1,fhdr.dim(1));
ysum=zeros(1,fhdr.dim(2));
zsum=zeros(1,fhdr.dim(3));
for Zi=bounds(5):bounds(6),
  img      = spm_slice_vol(fdata ,spm_matrix([0 0 Zi]),fhdr.dim(1:2),0);
  px = 0; %image pixels
  for Yi=bounds(3):bounds(4),
  	slicestart=(Yi-1)*fhdr.dim(1);
  	for Xi=bounds(1):bounds(2),
       px = slicestart +Xi;
       xsum(Xi) = xsum(Xi)+img(px);
       ysum(Yi) = ysum(Yi)+img(px);
       zsum(Zi) = zsum(Zi)+img(px);
  	end;
  end; %for Yi
end; %for Zi
%next pad data in cropped dimensions
if bounds(1) > 1
  for i=1:bounds(1),
    xsum(i)=xsum(bounds(1));
  end;
end;%xmin
if bounds(2) < fhdr.dim(1)
  for i=fhdr.dim(1):-1:bounds(2),
    xsum(i)=xsum(bounds(2));
  end;
end;%xmax

if bounds(3) > 1
  for i=1:bounds(3),
    ysum(i)=ysum(bounds(3));
  end;
end;%ymin
if bounds(4) < fhdr.dim(2)
  for i=fhdr.dim(2):-1:bounds(4),
    ysum(i)=ysum(bounds(4));
  end;
end;%ymax

if bounds(5) > 1
  for i=1:bounds(5),
    zsum(i)=zsum(bounds(5));
  end;
end;%zmin
if bounds(6) < fhdr.dim(3)
  for i=fhdr.dim(3):-1:bounds(6),
    zsum(i)=zsum(bounds(6));
  end;
end;%zmax
%smooth data
if FWHM > 0,
 XYZmm = vxlmmSub (fhdr.mat);
 xsum = smoothvectorSub(xsum, FWHM/XYZmm(1));
 ysum = smoothvectorSub(ysum, FWHM/XYZmm(2));
 zsum = smoothvectorSub(zsum, FWHM/XYZmm(3));
end
%end sumintensitySub()

function [zmin zmax] =  setboundSub (Zcenterslice, ZFOV, Zmm, Zmaxdim);
%load image data
%Zmm = 0 should be impossible at this stage!
%we would have detected Z did not vary
slices = abs(ZFOV/Zmm);
zmin = round(Zcenterslice- slices);
if zmin < 1,
	zmin = 1;
end;
zmax = round(Zcenterslice + slices);
if zmax > Zmaxdim,
	zmax = Zmaxdim;
end;
%end setboundSub()

function sVector = smoothvectorSub(Vector, FWHMvox)
% This is convolves a vector with gaussian smooth
%  This is very slow, but does weight near edges
len = length(Vector);
if len < 1 then
	return;
end;
kern = gaussSub(FWHMvox);
kwid = int32(length(kern));
if kwid < 1 then
	return;
end;
mid = idivide((kwid+1),2);
mid1 = int32(mid - 1);
for i=1:len,
	lo=i-mid1;
	hi=i+mid1;
	if lo < 1
		lo = 1;
	end;
	if hi > len
		hi = len;
	end;
	sumwt = 0;
	sum = 0;
	for x=lo:hi
		wt = kern(i-x+mid);
		sumwt = sumwt+wt;
		sum = sum+ (wt*Vector(x));		
	end;
	sVector(i)=sum/sumwt;
end;
%end smoothvectorSub()

function gkernel =gaussSub(FWHMvox)
s=FWHMvox;
s1 = s/sqrt(8*log(2));              % FWHM -> Gaussian parameter
x  = round(6*s1); x = -x:x; 
gkernel  = spm_smoothkern(s,x,1); 
gkernel   = gkernel /sum(gkernel );
%end gaussSub

function i = lastPeakSub (vector,skip);
%reports final peak
% starts looking at N-skip
if nargin < 2 %no skip specified
 skip = 0;
end
len = length(vector)-round(abs(skip));
if len > length(vector) 
  len = length(vector)
end;
if len < 2 
	i = 1;
	return;
end;
for i=len:-1:2
	%vector(i)
	if vector(i)>vector(i-1)
		return;
	end; 
end;%for each value
%all items in descending order - first item is peak
i = 1;
%end lastPeakSub

function i = firstPeakSub (vector, skip);
%reports first peak in vector with an index greater than skip
if nargin < 2 %no skip specified
 skip = 0;
end
skip = round(abs(skip));
len = length(vector);
if len < 2 
	i = 1;
	return;
end;

if skip > (len-1) 
	i = len;
	return;
end;
for i=skip:(len-1)
	if vector(i)>vector(i+1)
		return;
	end; 
end;%for each value
%all items inascending order - final item is peak
i = len;
%end firstPeakSub()

function XYZmm = vxl2mmSub (M,XYZvxl);
XYZmm     = M(1:3,:)*[XYZvxl; ones(1,size(XYZvxl,2))];
%end vxl2mmSub()

function [mm] = vxlmmSub (M);
% Gives distance between slice centers in millimeters 
orimm = vxl2mmSub (M,[0;0;0]);
imm = vxl2mmSub (M,[1;0;0])-orimm;
jmm = vxl2mmSub (M,[0;1;0])-orimm;
kmm = vxl2mmSub (M,[0;0;1])-orimm;
%total thickness of rows/columns/slices computed by pythagorean theorem
mm(1) = sqrt( imm(1)^2+imm(2)^2+imm(3)^2);
mm(2) = sqrt( jmm(1)^2+jmm(2)^2+jmm(3)^2);
mm(3) = sqrt( kmm(1)^2+kmm(2)^2+kmm(3)^2);
%end vxlmmSub()