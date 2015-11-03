function Coh_ave=rest_Cohe_ReHo(ATc,ASamplePeriod,AHighPass_LowCutoff,ALowPass_HighCutoff,Auto,TimeP,Overlap)
%Use coherence to measure regional homogeneity of resting-state fMRI signal
%FORMAT Coh_ave=rest_Cohe_ReHo(ATc,ASamplePeriod,AHighPass_LowCutoff,ALowPass_HighCutoff,Auto,TimeP,Overlap)
%Input:
% 	ATC			        time series from the given cluster
% 	ASamplePeriod		TR, or like the variable name
% 	AHighPass_LowCutoff			the low edge of the pass band
% 	ALowPass_HighCutoff			the High edge of the pass band
%   Auto   Define the segment automatically
%   TimeP  Time points in each segment
%   Overlap Overlap for neighboring segments
%Output:
%   Coh_ave                Cohe-ReHo value of the given cluster
%   For methodology, please see: 
%   Liu D, Yan C, Ren J, Yao L, Kiviniemi VJ and Zang Y (2010) Using coherence to measure regional homogeneity of resting-state fMRI signal. Front. Syst. Neurosci. 4:24. doi: 10.3389/fnsys.2010.00024 
%	Writen by Dongqiang Liu, Oct, 2009
%	State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University
%   E-mail: charlesliu116@gmail.com
%   Copywrite (c) 2009
%-----------------------------------------------------------



%initialization
%--------------------------------------------------------------------------
if size(ATc,1)<size(ATc,2)
    ATc=ATc';    
end

[len,nvoxel]=size(ATc);
min_len_seg=1/AHighPass_LowCutoff/ASamplePeriod;
k =floor(len/min_len_seg*2)-1;                                   
N = floor(len/(k+1)*2);                                   
noverlap = ceil(0.5*N);
if Auto == 0
    N=TimeP;
    noverlap=Overlap;
end
w=hanning(N); 
U=w'*w;
f=1/ASamplePeriod;
fb=round([AHighPass_LowCutoff,ALowPass_HighCutoff]/f*N);
fb=(fb(1):fb(end))+1;
n=length(fb);



%segment and de-center
%--------------------------------------------------------------------------
NminusOverlap = N-noverlap;
xStart = 1:NminusOverlap:k*NminusOverlap;
xEnd   = xStart+N-1;

xcurrent=[];
for i=1:length(xStart)
    xtmp=ATc(xStart(i):xEnd(i),:);    
    xcurrent=[xcurrent xtmp];
end
xcurrent=xcurrent-ones(N,1)*mean(xcurrent); %de-center
xcurrent=xcurrent.*(w*ones(1,size(xcurrent,2)));% weighted by window


%power spectrum and cross spectrum estimation
%--------------------------------------------------------------------------
fx=fft(xcurrent);
fx=fx(fb,:);

fx=reshape(fx,[n,nvoxel,k]);fx=permute(fx,[2,1,3]);fx=reshape(fx,[n*nvoxel,k]);
fx=mat2cell(fx,nvoxel*ones(n,1),k);

cp=zeros(nvoxel,nvoxel);Cohe=cp;
for i=1:n
    cptmp{i}=fx{i}*conj(transpose((fx{i})))/U/k;
      %average over frequency bands
      cp=cp+cptmp{i};
end

ap=diag(cp);
cp=abs(cp).^2;


%average across voxel-pairs
%--------------------------------------------------------------------------
for i=1:nvoxel-1
    
    for j=i+1:nvoxel
        app_tmp=ap(i)*ap(j);
        if app_tmp ~=0
          Cohe(i,j)=cp(i,j)/app_tmp;
        else
            Cohe(i,j)=0;
        end
    end
end

nvp=(nvoxel-1)*nvoxel/2;
Coh_ave=sum((Cohe(:)))/nvp;

