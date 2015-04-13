function nii_make4d
%simple script to generate 4d nifti image - useful for testing other routines
nvol = 256;
nam = 'test4d.nii';
tr= 1; %e.g. 2.2 if 2.2s per volume
%we traditionally try to preserve 0.01-0.1Hz signals 
slowestFreq = 0.00390625;
highestFreq = 0.25;
%slowestFreq = 0.01;
%freqInc = 0.005;

inname = fullfile(spm('Dir'),'apriori','brainmask.nii');
%inname = fullfile('rbrainmask.nii');

if ~exist(inname, 'file')
    fprintf('%s error: unable to find image named %s\n', mfilename,inname);
    return;
end

hdr = spm_vol([inname,',1']); 
[img] = spm_read_vols(hdr);
[nX nY nZ nV] = size(img);


%create one sine wave for each slice
fprintf('volume TR is %f\n',tr);

t=[0:tr:(tr*nvol)]; %onset time of each volume
%t = t + 1; %all frequencies are zero at time zero
y=zeros(nZ,length(t));
freqInc = (highestFreq-slowestFreq) / (nZ-1);
for z=1:nZ
        f = slowestFreq + ((z-1)*freqInc);
        y(z,:)=sin(2*pi*f*t);
        fprintf('slice %d has a frequency of %f\n',z,f);
end;
%plot(t,y)

    
pth = pwd;
hdr.fname   = fullfile(pth,[nam ]);
hdr.private.timing.toffset= 0;
hdr.private.timing.tspace= tr;
%next: save data as 32-bit real
hdr.dt(1) = 16; %make 32 bit real
hdr.private.dat.dtype = 'FLOAT32-LE';
hdr.private.dat.scl_slope = 1;
hdr.private.dat.scl_inter = 0;
hdr.pinfo(1) = 16; %make 32 bit real
%M = zeros([nX nY nZ])
imgVol1 = img(:, :, :, 1); %first volume of data
%embed column in volume so all slices have clear signal
for zi=1:nZ
    for yi=10:20
        for xi=10:20
            imgVol1(xi,yi,zi) = 1;
        end
    end;
end;

imgMod = imgVol1;
for vol=1:nvol
    hdr.n(1)=vol;
    for z=1:nZ
        imgMod(:,:,z) = imgVol1(:,:,z)*y(z,vol);
    end;
    imgMod = imgMod + imgVol1; %shift baseline away from zero
    imgMod = imgMod + 0.1*vol; %add drift
    
    linearTrend = 1+ 0.1*vol;
    for yi=25:35
        for xi=10:20
            imgMod(xi,yi,:) = linearTrend;
        end
    end;
    
    for yi=45:55
        for xi=10:20
            imgMod(xi,yi,:) = 1;
        end
    end;
    
    spm_write_vol(hdr,imgMod(:, :, :, 1));
end;
