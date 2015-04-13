function gantry2(varargin)

if nargin < 1
    DIRlist(1,1).path_in = uigetdir('C:\','SELECT INPUT DIRECTORY');
    if DIRlist(1,1).path_in == 0
        clc
        disp('ERROR: at least 1 input directory path is neccessary!')
        clear all;
        return;
    end
    pause(1)
    DIRlist(1,1).path_out = uigetdir(DIRlist(1,1).path_in,'SELECT OUTPUT DIRECTORY OR CLOSE WINDOW TO OVERWRITE INPUT FILES');
    DIRlist(1,1).status = 'PROGRESS 0%';
    DIRlist(1,1).skip = false;
    button = questdlg({'CONVERT all files now';'NEW input and new output directory';'OVERWRITE input files in the newly selected input directory'},'ADD ANOTHER DIRECTORY?','CONVERT','NEW','OVERWRITE','CONVERT');
    while strcmpi('NEW',button) == true || strcmpi('OVERWRITE',button) == true
        len = length(DIRlist) + 1;
        DIRlist(len,1).path_in = uigetdir(DIRlist(len-1,1).path_in,'SELECT INPUT DIRECTORY');
        if strcmpi('NEW',button) == true
            pause(1)
            DIRlist(len,1).path_out = uigetdir(DIRlist(len,1).path_in,'SELECT OUTPUT DIRECTORY');
        else DIRlist(len,1).path_out = 0;
        end
        DIRlist(len,1).status = 'PROGRESS 0%';
        DIRlist(len,1).skip = false;
        button = questdlg({'CONVERT all files now';'NEW input and new output directory';'OVERWRITE input files in the newly selected input directory'},'ADD ANOTHER DIRECTORY?','CONVERT','NEW','OVERWRITE','CONVERT');
    end
    clear button;
end
clc
show(DIRlist);

%%% Remove non-file elements from file lists
for d = 1 : length(DIRlist)
    files = dir([DIRlist(d,1).path_in, '/', '*.dcm']);
    for q = length(files) : -1 : 1
        if files(q,1).isdir == true
            files(q) = [];
        else continue;
        end
    end
    DIRlist(d,1).files = files;
    clear files;
end

%%% Check DICOM headers %%%
for d = 1 : length(DIRlist)
    info = dicominfo([DIRlist(d,1).path_in '/' DIRlist(d,1).files(1,1).name]);
    len_f = length(DIRlist(d,1).files);
    check = false(len_f,1);
    for q = 2 : len_f
        info(q,1) = dicominfo([DIRlist(d,1).path_in '/' DIRlist(d,1).files(q,1).name]);
        if strcmp(info(q,1).SeriesInstanceUID, info(q,1).SeriesInstanceUID) == false
            DIRlist(d,1).status = 'ERROR: Files from different series';
            DIRlist(d,1).skip = true;
            show(DIRlist);
            break;
        elseif strcmp(info(q,1).Modality, 'CT') == false
            DIRlist(d,1).status = 'ERROR: Non CT files or mixed modalities!';
            DIRlist(d,1).skip = true;
            show(DIRlist);
            break;
        end
        check(q,1) = logical(abs(info(q,1).GantryDetectorTilt));
    end
    if sum(check) == 0
        DIRlist(d,1).status = 'SKIPPED: Gantry angle is already zero';
        DIRlist(d,1).skip = true;
        show(DIRlist);
        continue;
    end
    clear info check;
end 

%%% Transform slice-wise and write new DCMinfo into dicom header %%%
for d = 1 : length(DIRlist)
    len_f = length(DIRlist(d,1).files);
    if DIRlist(d,1).skip == false
        for q = 1 : len_f
            if strcmp(DIRlist(d,1).status,sprintf('PROGRESS %d%%',ceil(q/len_f*100))) == false
                if ceil(q/len_f*100) == 100
                    DIRlist(d,1).status = 'COMPLETED';
                else DIRlist(d,1).status = sprintf('PROGRESS %d%%',ceil(q/len_f*100));
                end
                 show(DIRlist);
            end
            INFO = dicominfo([DIRlist(d,1).path_in '/' DIRlist(d,1).files(q,1).name]);
            if q == 1
                
                offset = 0;
                first = INFO.SliceLocation;
            else offset = round(tan(convang(INFO.GantryDetectorTilt,'deg','rad')) * (INFO.SliceLocation - first) / INFO.PixelSpacing(2,1));
            end
            disp(INFO.GantryDetectorTilt);            
            IN = dicomread(INFO.Filename);
            if INFO.GantryDetectorTilt > 0
                mtx = [1 0 0;0 1 0;0 -offset 1];
            elseif INFO.GantryDetectorTilt < 0
                mtx = [1 0 0;0 1 0;0 offset 1];
            end
            tform = maketform('affine',mtx);
            OUT = imtransform(IN,tform,'XData', [1 double(INFO.Columns)],'YData',[1+mtx(2,3) double(INFO.Rows)+mtx(2,3)]);
            INFO.GantryDetectorTilt = 0;
            if DIRlist(1,1).path_out == 0
                dicomwrite(OUT, [DIRlist(d,1).path_in '/' DIRlist(d,1).files(q,1).name], INFO);
            else dicomwrite(OUT, [DIRlist(d,1).path_out '/' DIRlist(d,1).files(q,1).name], INFO);
            end
            clear IN OUT INFO offset mtx tform fname list;
        end
    else continue;
    end
end

function show(DIRlist)
clc
for w=1:length(DIRlist)
    disp({['INPUT    ' DIRlist(w,1).path_in];['OUTPUT   ' DIRlist(w,1).path_out];DIRlist(w,1).status})
end