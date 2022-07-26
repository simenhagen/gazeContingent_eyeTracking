function gazeExperiment
%%-----------------------------------------------------------------------%%
%                       Gaze-contingent Eye-tracking   
%            Matching-task w/mask; window; and full-view condtions
%                         Bird experts vs. bird novices
%                            Simen Hagen - 2015
%%-----------------------------------------------------------------------%%



clc
PsychJavaTrouble
%jheapcl   % empty java memory
clear all
close all

%Screen('Preference', 'SkipSyncTests', 1); 

% Reseed the random-number generator for each expt.
rand('state',sum(100*clock));

%PsychDefaultSetup(1);

% EXPERIMENT'S SETTINGS
% parameters  - create a structure called p.
diagnosis = 0; % 1 = diagnosis (3 trials)
gaussian = 0; % 1=gaussian mask/window
SameResp = KbName('c');
DiffResp = KbName('m'); 
SpaceResp = KbName('space');
sdate = date;
screenRes = [1024 768];  
if diagnosis == 1 
    img1Duration = 0.5;
else
    img1Duration = 3.0;
end
ms=210; % Setup default aperture size to 2*200+1 x 2*200+1 pixels.  %240
dummymode=0;
fixLocation_1 = randi(4,1,144);
fixLocation_2 = randi(4,1,144);
fixWidth = 70;
fixColor = [255,0,0];

%%%%%%% Participant Information %%%%%%%
repeat=1;
while (repeat)
    prompt= {'Participant number (format: 001)', 'Age', 'Gender', 'Group (expert/control)'};
    defaultAnswer={'','', '', ''};
    options.Resize = 'on';
    answer=inputdlg(prompt,'Participant Information',1, defaultAnswer, options);
    [subjno, subjAge, subjGender, subjGroup]=deal(answer{:});
    if isempty(str2num(subjno)) || ~isreal(str2num(subjno)) || isempty(str2num(subjAge)) || ~isreal(str2num(subjAge)) || isempty(num2str(subjGender)) || isempty(num2str(subjGroup))
        h=errordlg('Subject Number and Age must be integer; Please fill in all information','Input Error');
        repeat=1;
        uiwait(h);
    else
        OutputFile=['data/behavior/GC_subj' subjno '_' subjGroup '.txt'];	% set data file directory and name of the file
        if exist(OutputFile,'file')~=0
            button=questdlg(['Overwrite GC_subj' subjno '_' subjGroup '.txt?']);
            if strcmp(button,'Yes'); repeat=0; end
        else
            repeat=0;
        end
        % create .txt file to store data
        OutputTextFile = fopen(OutputFile, 'w');
        fprintf(OutputTextFile, ...
            '\nTrialIdentifier\tDate\tTrial\tSubNo\tSubjGender\tSubjAge\tSubjGroup\tKeyResponse\tCondition\tACC\tTrialType\tHit\tFA\tRT\tcorrectRT\tBirdFamily');
        
    end
end


% STEP 1
% Added a dialog box to set your own EDF file name before opening
% experiment graphics. Make sure the entered EDF file name is 1 to 8
% characters in length and only numbers or letters are allowed.
prompt = {'Enter tracker EDF file name (1 to 8 letters or numbers)'};
dlg_title = 'Create EDF file';
num_lines= 1;
def     = {'DEMO'};
answer  = inputdlg(prompt,dlg_title,num_lines,def);
edfFile = answer{1};
fprintf('EDFFile: %s\n', edfFile );


%opening operations for the screen function
try    
    % Set hurryup = 1 for benchmarking - Syncing to retrace is disabled
    % in that case so we'll get the maximum refresh rate.
    hurryup=0;
    
    % Open screens
    backgroundcolor = 222;
    whichscreen = max(Screen('Screens'));
    Screen('Resolution', whichscreen,screenRes(1), screenRes(2));  % adjusts screen resolution
    [w,rect] = Screen('OpenWindow', whichscreen, backgroundcolor, [], 32, 2);
    refreshrate = Screen('FrameRate', w);
    Screen('FillRect', w, backgroundcolor); % display grey backgroun
    Screen('Flip', w);
    
% Define sectors in fixation dot phase    
sector_1_left = [0,0,(rect(3)-(rect(3)-100)),rect(4)];
sector_2_left = [(rect(3)-(rect(3)-100)),0,rect(3),rect(4)];
sector_1_right = [(rect(3)-100),0,rect(3),rect(4)];
sector_2_right = [0,0,(rect(3)-100),rect(4)];
sector_1_up = [0,0,rect(3),(rect(4)-(rect(4)-100))];
sector_2_up = [0,(rect(4)-(rect(4)-100)),rect(3),rect(4)];
sector_1_down = [0,(rect(4)-100),rect(3),rect(4)];
sector_2_down = [0,0,rect(3),(rect(4)-100)];
    
    
    % STEP 3
    % Provide Eyelink with details about the graphics environment
    % and perform some initializations. The information is returned
    % in a structure that also contains useful defaults
    % and control codes (e.g. tracker state bit and Eyelink key values).
    el=EyelinkInitDefaults(w);
    el.backgroundcolour = backgroundcolor;
    el.targetbeep = 0;
    el.calibrationtargetcolour= [255,0,0];
    el.calibrationtargetsize= 1;
    el.calibrationtargetwidth=0.5;
    el.displayCalResults = 1;
    el.eyeimgsize=50;
    EyelinkUpdateDefaults(el);
    
    
    % STEP 4
    % Initialization of the connection with the Eyelink Gazetracker.
    % exit program if this fails.
    dummymode=0;
    if ~EyelinkInit(dummymode)
        fprintf('Eyelink Init aborted.\n');
        cleanup;  % cleanup function
        return;
    end
    [v vs]=Eyelink('GetTrackerVersion');
    fprintf('Running experiment on a ''%s'' tracker.\n', vs );
    
    % open file to record data to
    i = Eyelink('Openfile', edfFile);
    if i~=0
          fprintf('Cannot create EDF file ''%s'' ', edffilename);
        cleanup;
        %         Eyelink( 'Shutdown');
        return;
    end
    
    Eyelink('command', 'add_file_preamble_text ''Recorded by EyelinkToolbox demo-experiment''');
    [width, height]=Screen('WindowSize', whichscreen);
    
    
    % STEP 5
    % SET UP TRACKER CONFIGURATION
    % Setting the proper recording resolution, proper calibration type,
    % as well as the data file content;
    Eyelink('command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, width-1, height-1);
    Eyelink('message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, width-1, height-1);
    % set calibration type.
    Eyelink('command', 'calibration_type = HV9');
    % set EDF file contents
    Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON');
    Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,GAZERES,STATUS');
    % set link data (used for gaze cursor)
    Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON');
    Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS');
    % allow to use the big button on the eyelink gamepad to accept the
    % calibration/drift correction target
    Eyelink('command', 'button_function 5 "accept_target_fixation"');
    
    % make sure we're still connected.
    if Eyelink('IsConnected')~=1
        cleanup;
        return;
    end;
    
    
    HideCursor;
    
    % Display instruction screen
    InstructionScreen(w, rect, SpaceResp, screenRes);
    
    %puts host-pc i camera setup mode
    EyelinkDoTrackerSetup(el);
    
    WaitSecs(0.1);
    
% Practice instruction screen    
practiceText01 = {'Lets try a few practice trials.'};
practiceText02 = {'Hit space-bar to start.'};
Screen('TextSize', w, 12);
DrawFormattedText(practiceText01, w, 'center', screenRes(2)/2);
DrawFormattedText(practiceText02, w, 'center', (screenRes(2)/2)+100);

touch = 0;
   while ~touch
      [touch,tpress,keycode] = KbCheck;
        if keycode(SpaceResp)
            break;
        else
            touch = 0;
        end
   end
        while KbCheck; end

    
for phase = 1:2 % 1=practice ; 2= test
    
    if phase == 1
        TrialList = 'practiceList.txt';
    elseif phase == 2
        TrialList = 'TrialList.txt';
    end
    
[TrialIdentifier, TrialType, img1, img2, condition, ~, birdFamily] = textread(TrialList,'%d %d %s %s %d %s %s');

nTrials = length(TrialType);
RandomTrialSequence = randperm(nTrials)';
TrialIdentifier = TrialIdentifier(RandomTrialSequence);
TrialType = TrialType(RandomTrialSequence);
img1 = img1(RandomTrialSequence);
img2 = img2(RandomTrialSequence);
condition = condition(RandomTrialSequence);
birdFamily = birdFamily(RandomTrialSequence);

    
    
    %% Start the actual experiment
    for trial = 1:nTrials
       
      if phase == 2  
        if trial == 36 || trial == 72 || trial == 108
            EyelinkDoTrackerSetup(el);
        end
      end
        % wait a bit between trials (ITI)
        WaitSecs(0.500);
        
        % initialize KbCheck and variables to make sure they're
        % properly initialized/allocted by Matlab - this to avoid time
        % delays in the critical reaction time measurement part of the
        % script:
        [KeyIsDown, endrt, KeyCode] = KbCheck;
        
        % STEP 7.1
        % Sending a 'TRIALID' message to mark the start of a trial in Data
        % Viewer.  This is different than the start of recording message
        % START that is logged when the trial recording begins. The viewer
        % will not parse any messages, events, or samples, that exist in
        % the data file prior to this message.
        
        
        % This supplies the title at the bottom of the eyetracker display
        Eyelink('command', 'record_status_message "TRIAL %d/%d"', trial, nTrials);
        
        Eyelink('Command', 'set_idle_mode');
        % clear tracker display and draw box at center
        Eyelink('Command', 'clear_screen %d', 0);
        
        
        % STIMULI (SELECTION)
        ProbeImagePath =strcat('stimuli_birds_gray/',char(img1(trial)));
        ProbeImage = imread(char(ProbeImagePath));
        TestImageToPath = strcat('stimuli_birds_gray/',char(img2(trial)));
        TestImage = imread(char(TestImageToPath));
        
        
        finfo = imfinfo(char(TestImageToPath));
        finfo.Filename;
        transferStatus = Eyelink('ImageTransfer', finfo.Filename ,0,0,0,0,round(width/2 - finfo.Width/2) ,round(height/2 - finfo.Height/2),4);
        if transferStatus ~= 0
            fprintf('Image to host transfer failed\n');
        end
        
        
        % create window/mask conditions  
        switch condition(trial)
            case 1
                foveaimdata = TestImage;
                peripheryimdata = TestImage;
            case 2
                PeripheryimdataPath = strcat('stimuli/','GreyMask.bmp');
                peripheryimdata = imread(char(PeripheryimdataPath));
                foveaimdata = TestImage;
            case 3
                peripheryimdata = TestImage;
                foveaimdatapath = strcat('stimuli/','GreyMask.bmp');
                foveaimdata = imread(char(foveaimdatapath));
        end
        
        
        %   STIMULI (PRESENTATION)
        PresentImageStimulus(phase, TrialIdentifier, fixColor,sector_1_left,sector_2_left,sector_1_right,sector_2_right,sector_1_up,sector_2_up,sector_1_down,sector_2_down,fixWidth,fixLocation_1,fixLocation_2,condition, sdate,img1Duration,subjno, subjGender,subjAge, subjGroup, gaussian, SameResp, DiffResp, TrialType, w, rect, width, height, endrt, KeyCode, ProbeImage, ProbeImagePath, TestImageToPath, TestImage, peripheryimdata,foveaimdata, ms, backgroundcolor, el, whichscreen, dummymode, hurryup, trial, OutputTextFile, birdFamily)
        
        Screen('Close') % dispose no longer needed offscreen windows/textures.
        
    end
    
    if phase == 1
    % Display Get Ready screen for test phase
    getReadyTxt01 = {'You finished the practice trials.'};
    getReadyTxt02 = {'Press space-bar to start the actual experiment.'};
    Screen('TextSize',w,12)
    DrawFormattedText(getReadyTxt01,w,'center',screenRes(2)/2);
    DrawFormattedText(getReadyTxt02,w,'center',(screenRes(2)/2)+150);
    
    touch=0;
    while ~touch
        [touch,tpress,keycode] = KbCheck;
        if keycode(SpaceResp)
            break;
        else
            touch=0;
        end
    end 
    end
    
    Eyelink('Command', 'set_idle_mode');
    WaitSecs(0.5);
    Eyelink('CloseFile');
    
closing_screen( w, screenRes, SpaceResp );

    % download data file
    try
        fprintf('Receiving data file ''%s''\n', edfFile );
        status=Eyelink('ReceiveFile');
        if status > 0
            fprintf('ReceiveFile status %d\n', status);
        end
        if 2==exist(edfFile, 'file')
            fprintf('Data file ''%s'' can be found in ''%s''\n', edfFile, pwd );
        end
    catch
        fprintf('Problem receiving data file ''%s''\n', edfFile );
    end
    
    
    % Cleanup at end of experiment - Close window, show mouse cursor, close
    % result file, switch Matlab/Octave back to priority 0 -- normal
    % priority:
    Screen('CloseAll');
    ShowCursor;
    fclose('all');
    Priority(0);
    
    % End of experiment:
    return;
    
catch
    Screen('CloseAll')
    rethrow(lasterror)
end



% % Cleanup routine:
    function cleanup
        Shutdown Eyelink:
        Eyelink('Shutdown');
        Screen('CloseAll');
        sca;
    end

end


