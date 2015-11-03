function rest_Powerspectrum_start()
%   Prepare for showing the Power Spectrum and the Time course of user specified voxel whose coordinates could be set with SliceViewer
%   By YAN Chao-Gan and Dong Zhang-Ye 101025.
%   State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University, China, 100875
%	http://www.restfmri.net
% 	Mail to Authors:  <a href="ycg.yan@gmail.com">YAN Chao-Gan</a>; <a href="dongzy08@gmail.com">DONG Zhang-Ye</a> 
%	Version=1.0;
%	Release=20101025;

try
    [filename, pathname] = uigetfile({'*.img;*.nii;*.nii.gz','Brain Image Files (*.img;*.nii;*.nii.gz)';'*.*', 'All Files (*.*)';}, ...
        'Pick one functional EPI brain map in the dataset''s directory');
    if any(filename~=0) && ischar(filename),	% not canceled and legal
        if ~strcmpi(pathname(end), filesep)%revise pathname to remove extension
            pathname = [pathname filesep];
        end
        theBrainMap 	=[pathname filename];
        theViewer =rest_sliceviewer('ShowImage', theBrainMap);
        %Set the ALFF figure to show corresponding voxel's time-course and its freq amplitude
        theDataSetDir 	=pathname;
        theVoxelPosition=rest_sliceviewer('GetPosition', theViewer);
        theSamplePeriod =inputdlg('Please input the Sample Period: (i.e. TR)', ...
            'REST Power Spectrum');
        theSamplePeriod 	=str2num(theSamplePeriod{1});
        
        theBandRange =inputdlg('Please input the Band Limit you want to see', ...
            'REST Power Spectrum',1,{'[0.01 0.08]'});
        theBandRange 	=eval(['[',theBandRange{1},']']);
        
        
        button = questdlg('Do you want to yoke with structural image (e.g., ch2.nii)?','Yoke with structural image','Yes','No','Yes');
        if strcmpi(button,'Yes')
            [filenameU, pathnameU] = uigetfile({'*.img;*.nii;*.nii.gz','Brain Image Files (*.img;*.nii;*.nii.gz)';'*.*', 'All Files (*.*)';}, ...
            'Pick one Structure brain map for Underlay (e.g., ch2.nii)');
                theNewUnderlay =[pathnameU,filesep,filenameU];
                theViewer2 =rest_sliceviewer('ShowImage', theNewUnderlay);
        end
        
        rest_powerspectrum('ShowFluctuation', theDataSetDir, theVoxelPosition, ...
            theSamplePeriod, theBandRange);

        %Update the Callback
        theCallback 	='';
        cmdDataSetDir	=sprintf('theDataSetDir= ''%s'';', theDataSetDir);
        cmdBrainMap 	=sprintf('theVoxelPosition=rest_sliceviewer(''GetPosition'', %g);', theViewer);
        cmdSamplePeriod =sprintf('theSamplePeriod= %g;', theSamplePeriod);
        cmdBandRange	=sprintf('theBandRange= [%g, %g];', theBandRange(1), theBandRange(2));
        cmdUpdateWaveGraph	='rest_powerspectrum(''ShowFluctuation'', theDataSetDir, theVoxelPosition, theSamplePeriod, theBandRange);';
        theCallback	=sprintf('%s\n%s\n%s\n%s\n%s\n',cmdDataSetDir, ...
            cmdBrainMap, cmdSamplePeriod, cmdBandRange, ...
            cmdUpdateWaveGraph);
        cmdClearVar ='clear theDataSetDir theVoxelPosition theSamplePeriod theBandRange;';
        rest_sliceviewer('UpdateCallback', theViewer, [theCallback cmdClearVar], 'ALFF Analysis');

        % Update some Message
        theMsg =sprintf('TR( s): %g\nBand( Hz): %g~%g', ...
            theSamplePeriod, theBandRange(1), theBandRange(2) );
        rest_sliceviewer('SetMessage', theViewer, theMsg);
    end
catch
    rest_misc( 'DisplayLastException');
end



