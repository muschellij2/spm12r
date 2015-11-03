function [Z P Header] = rest_TFRtoZ(ImgFile,OutputName,Flag,Df1,Df2,Header)
% FORMAT [Z P Header] = y_TFRtoZ(ImgFile,OutputName,Flag,Df1,Df2,Header)
%   Input:
%     ImgFile    - T, F or R statistical image which wanted to be converted to Z statistical value
%     OutputName - The output name
%     Flag       - 'T', 'F' or 'R'. Indicate the type of the input statsical image
%                - If not defined or defined as empty, then will read the statistical type and degree of freedom information from the image (if the statistical analysis was performed with REST or SPM).
%     Df1        - the degree of freedom of the statistical image. For F statistical image, there is also Df2
%     Df2        - the second degree of freedom of F statistical image
%     Header     - If ImgFile is a MATRIX, the Nifti Header should be specified 
%   Output:
%     Z          - Z statistical image. Also output as .img/.hdr.
%     P          - The corresponding P value
%     Header     - the output Nifti Header
%___________________________________________________________________________
% Written by YAN Chao-Gan 100424.
% State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University, China, 100875
% ycg.yan@gmail.com
% Revised by YAN Chao-Gan 100814. Changed to call spm_t2z for T and R images to use approximation in case of big T values.
% Last revised by YAN Chao-Gan 121223. Convert the big F values to Z values in an approximation like spm_t2z to treat big T values. Detect the Flag and DF from the data if Flag is not defined.

if ischar(ImgFile)
    [Data VoxelSize Header]=rest_readfile(ImgFile);
else
    Data = ImgFile;
    VoxelSize=sqrt(sum(Header.mat(1:3,1:3).^2)); 
end

[nDim1,nDim2,nDim3]=size(Data);

%Added by YAN Chao-Gan 121222. Detect the Flag and DF from the data if Flag is not defined.
if (~exist('Flag','var')) || (exist('Flag','var') && isempty(Flag))
    if isfield(Header,'descrip')
        headinfo=Header.descrip;
        Df2=0;
        if ~isempty(strfind(headinfo,'{T_['))% dong 100331 begin
            Flag='T';
            Tstart=strfind(headinfo,'{T_[')+length('{T_[');
            Tend=strfind(headinfo,']}')-1;
            Df1 = str2num(headinfo(Tstart:Tend));
        elseif ~isempty(strfind(headinfo,'{F_['))
            Flag='F';
            Tstart=strfind(headinfo,'{F_[')+length('{F_[');
            Tend=strfind(headinfo,']}')-1;
            F_Df = str2num(headinfo(Tstart:Tend));
            Df1=F_Df(1,1);
            Df2=F_Df(1,2);
        elseif ~isempty(strfind(headinfo,'{R_['))
            Flag='R';
            Tstart=strfind(headinfo,'{R_[')+length('{R_[');
            Tend=strfind(headinfo,']}')-1;
            Df1 = str2num(headinfo(Tstart:Tend));
        elseif ~isempty(strfind(headinfo,'{Z_['))
            Flag='Z';
            Tstart=strfind(headinfo,'{Z_[')+length('{Z_[');
            Tend=strfind(headinfo,']}')-1;
            Df1 = str2num(headinfo(Tstart:Tend));
        end
    end
end


if strcmpi(Flag,'F')
    fprintf('Convert F to Z...\n');

    Z = norminv(fcdf(Data,Df1,Df2)); %YAN Chao-Gan 100814. Use one-tail because F value is positive and one-tail.
    Z(Data==0) = 0;
    P = 1-fcdf(Data,Df1,Df2);

    %YAN Chao-Gan, 121223. Convert the big F values to Z values in an approximation like spm_t2z to treat big T values.
    %Referenced from spm_t2z.m
    
    %Tol = 1E-16; %minimum tail probability for direct computation
    Tol = 1E-10; %minimum tail probability for direct computation. This is the tolorance value used in spm_t2z.
    
    F1    = finv(1 - Tol,Df1,Df2);
    %mQb   = Data > F1;
    mQb   = isinf(Z); %Only deal with those with Inf values. YAN Chao-Gan, 121223.
    if any(mQb(:))
        z1          = -norminv(Tol);
        F2          = F1-[1:5]/10;
        z2          = norminv(fcdf(F2,Df1,Df2));
        %-least squares line through ([f1,t2],[z1,z2]) : z = m*f + c
        mc          = [[F1,F2]',ones(length([F1,F2]),1)] \ [z1,z2]';
        
        %-------------------------------------------------------------------
        %-Logarithmic extrapolation
        %-------------------------------------------------------------------
        l0=1/mc(1);
        %-Perform logarithmic extrapolation, negate z for positive t-values
        Z(mQb) = ( log( Data(mQb) -F1 + l0 ) + (z1-log(l0)) );
        %-------------------------------------------------------------------
    end
    
    
else % T image or R image: YAN Chao-Gan 100814. Changed to call spm_t2z to use approximation in case of big T values.
    
    if strcmpi(Flag,'R')
        fprintf('Convert R to T...\n');
        Data = Data .* sqrt(Df1 / (1 - Data.*Data));
    end
    
    fprintf('Convert T to Z...\n');
    
    P = 2*(1-tcdf(abs(Data),Df1)); %Two-tailed P value
    
    Tol = 1E-16; %minimum tail probability for direct computation
    Z = spm_t2z(Data,Df1,Tol);
    Z = reshape(Z,[nDim1,nDim2,nDim3]);
end


Z(isnan(Z))=0;
P(isnan(P))=1;


Header.descrip=sprintf('{Z_[%.1f]}',1);
if ~strcmpi(OutputName,'DO NOT OUTPUT IMAGE')%Added by Sandy to make it compatible with Image matrix
    rest_writefile(Z,OutputName,[nDim1,nDim2,nDim3],VoxelSize, Header,'double');
end

fprintf('\n\tT/F/R to Z Calculation finished.\n');