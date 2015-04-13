function rest_Fix_Read_Write_Error()
% Fix the error of reading and writing NIfTI images in REST.
% Please install REST first. And you need to install SPM5 (or above release) and compile the mex files correctly according to http://en.wikibooks.org/wiki/SPM/Installation_on_64bit_Linux.
%-----------------------------------------------------------
%	Copyright(c) 2009~2012
%	State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University
%	Written by YAN Chao-Gan
%	http://www.restfmri.net
%   Date =20100426;
%-----------------------------------------------------------
% 	Mail to Author:  <a href="ycg.yan@gmail.com">YAN Chao-Gan</a>
%-----------------------------------------------------------
%   Revised by YAN Chao-Gan, 100410. Do not need to copy spm_bwlabel.* and spm_sample_vol.*.
%   Last revised by YAN Chao-Gan, 100426. Fixed a reading and writing bug of compatibility with SPM8.

if ~(exist('rest.m'))
    uiwait(msgbox('Please install REST first.','Info'));
    return
end
if ~(exist('spm.m'))
    uiwait(msgbox('Fixing the error of reading and writing NIfTI images for REST. Please install SPM5 (or above release) and compile the mex files correctly according to http://en.wikibooks.org/wiki/SPM/Installation_on_64bit_Linux.','Info'));
    return
end

[RESTPath, fileN, extn] = fileparts(which('rest.m'));
[SPMPath, fileN, extn] = fileparts(which('spm.m'));

[SPMversion,c]=spm('Ver');
SPMversion=str2double(SPMversion(end));

try
    if SPMversion==8
        Files=dir([SPMPath,filesep,'@file_array',filesep,'private',filesep,'mat2file.*']);
        for i=1:length(Files)
            copyfile([SPMPath,filesep,'@file_array',filesep,'private',filesep,Files(i).name],[RESTPath,filesep,'rest_spm5_files',filesep,'rest_',Files(i).name],'f')
        end
        % Added by YAN Chao-Gan, 100426. Fixed a reading and writing bug of compatibility with SPM8.
        copyfile([SPMPath,filesep,'@file_array',filesep,'file_array.m'],[RESTPath,filesep,'rest_spm5_files',filesep,'@file_array',filesep,'file_array.m'],'f')
    else
        Files=dir([SPMPath,filesep,'mat2file.*']);
        for i=1:length(Files)
            copyfile([SPMPath,filesep,Files(i).name],[RESTPath,filesep,'rest_spm5_files',filesep,'rest_',Files(i).name],'f')
        end
        % Added by YAN Chao-Gan, 100426. Fixed a reading and writing bug of compatibility with SPM8.
        copyfile([SPMPath,filesep,'@file_array',filesep,'file_array.m'],[RESTPath,filesep,'rest_spm5_files',filesep,'@file_array',filesep,'file_array.m'],'f')
    end
    
    %Revised by YAN Chao-Gan, 100410. Do not need to copy spm_bwlabel.* and spm_sample_vol.*.
    % Files=dir([SPMPath,filesep,'spm_bwlabel.*']);
    % for i=1:length(Files)
    %     copyfile([SPMPath,filesep,Files(i).name],[RESTPath,filesep,'rest_spm5_files',filesep,'rest_',Files(i).name],'f')
    % end
    %
    % Files=dir([SPMPath,filesep,'spm_sample_vol.*']);
    % for i=1:length(Files)
    %     copyfile([SPMPath,filesep,Files(i).name],[RESTPath,filesep,'rest_spm5_files',filesep,'rest_',Files(i).name],'f')
    % end
    
    Files=dir([SPMPath,filesep,'spm_slice_vol.*']);
    for i=1:length(Files)
        copyfile([SPMPath,filesep,Files(i).name],[RESTPath,filesep,'rest_spm5_files',filesep,'rest_',Files(i).name],'f')
    end
catch
    error('Meet error while fixing read write error. Please restart MATLAB, and run "rest_Fix_Read_Write_Error" before starting anything.');
end
