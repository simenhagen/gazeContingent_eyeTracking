function practicePhase(w,screenRes,SpaceResp,trial_prac)
%% practice phase with 6 trials - 2 in each condition
% uses different images than the testPhase
% NEED TO DECIDE WHICH BIRDS TO USE. USE WARBLERS OR SPARROWS THAT I DONT USE DURING
% THE EXPERIMENT

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


        % STIMULI (SELECTION)
        ProbeImagePath =strcat('stimuli_birds_gray/',char(img1_prac(trial_prac)));
        ProbeImage = imread(char(ProbeImagePath));
        TestImageToPath = strcat('stimuli_birds_gray/',char(img2_prac(trial_prac)));
        TestImage = imread(char(TestImageToPath));
        
        
        finfo = imfinfo(char(TestImageToPath));
        finfo.Filename;
        transferStatus = Eyelink('ImageTransfer', finfo.Filename ,0,0,0,0,round(width/2 - finfo.Width/2) ,round(height/2 - finfo.Height/2),4);
        if transferStatus ~= 0
            fprintf('Image to host transfer failed\n');
        end
        
        
        % create window/mask conditions  
        switch condition_prac(trial_prac)
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


% STEP 7.2
% Do a drift correction at the beginning of each trial
% Performing drift correction (checking) is optional for
% EyeLink 1000 eye trackers.
EyelinkDoDriftCorrection(el);

% STEP 7.3
% start recording eye position (preceded by a short pause so that
% the tracker can finish the mode transition)
% The paramerters for the 'StartRecording' call controls the
% file_samples, file_events, link_samples, link_events availability
Eyelink('Command', 'set_idle_mode');
WaitSecs(0.05);
Eyelink('StartRecording');
% record a few samples before we actually start displaying
% otherwise you may lose a few msec of data
WaitSecs(0.1);

% delete afterwards
eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
if eye_used == el.BINOCULAR; % if both eyes are tracked
    eye_used = el.LEFT_EYE; % use left eye
end


%%%%%% Present fixation #1 %%%%%%%     
switch fixLocation_1(trial_prac)
    case 1 %left fixation
        sector_l = sector_1_left;
        sector_r = AdjoinRect(sector_2_left, sector_l, RectRight);
    case 2 %right fixation
        sector_l = sector_1_right;
        sector_r = AdjoinRect(sector_2_right, sector_l, RectLeft);
    case 3 %up fixation
        sector_l = sector_1_up;
        sector_r =  AdjoinRect(sector_2_up, sector_l, RectBottom);
    case 4 %down fixation
        sector_l = sector_1_down;
        sector_r = AdjoinRect(sector_2_down, sector_l, RectTop);
end

BlobImg = imread('blob.bmp');
TextureBlobImg = Screen('MakeTexture', w, BlobImg);
Screen('FillRect', w, backgroundcolor, sector_l);
Screen('FillRect', w, backgroundcolor, sector_r);
square = [0 0 20 20];
square_l = CenterRect(square, sector_l);
Screen('FillOval', w, fixColor, square_l, []);
Screen('DrawTexture', w, TextureBlobImg);
Screen('Flip', w);

earlystartflag=0;
while earlystartflag == 0
    if Eyelink('NewFloatSampleAvailable') > 0
        % get the sample in the form of an event structure
        evt = Eyelink('NewestFloatSample');
        if eye_used ~= -1 % do we know which eye to use yet?
            % if we do, get current gaze position from sample
            x = evt.gx(eye_used+1); % +1 as we're accessing MATLAB array
            y = evt.gy(eye_used+1);
            % do we have valid data and is the pupil visible?
            if x~=el.MISSING_DATA && y~=el.MISSING_DATA && evt.pa(eye_used+1)>0
                mx=x;
                my=y;
                %added this- change fixation image if looking at it
                Screen(w, 'FillRect', backgroundcolor);
                if (fixLocation_1(trial_prac)==1 && mx>(rect(3)-(rect(3)-fixWidth)) && my>0 && my< rect(4)) || (fixLocation_1(trial_prac)==2 && mx < (rect(3)-fixWidth) && my>0 && my<rect(4)) || (fixLocation_1(trial_prac)==3 && my>(rect(4)-(rect(4)-fixWidth)) && mx>0 && mx<rect(3)+1000) || (fixLocation_1(trial_prac)==4 && my<rect(4)-fixWidth && mx>0 && mx<rect(3)+1000);
                    Screen('FillRect', w, backgroundcolor, sector_l);
                    Screen('FillRect', w, backgroundcolor, sector_r);
                    Screen('FillOval', w, fixColor, square_l);
                    Screen('DrawTexture', w, TextureBlobImg);                    
                else
                    earlystartflag=1;
                end
                Screen('Flip', w);
            end
        end
    end
end

%%%%%%%%%%%%% Display encoding image  %%%%%%%%%%%%%%%%
% make and draw the probe stimulus in the background
TextureProbeImg = Screen('MakeTexture', w, ProbeImage);
Screen('DrawTexture', w, TextureProbeImg);
Screen('Flip', w);
% Send an integration message so that an image can be loaded as
% overlay backgound when performing Data Viewer analysis.  This
% message can be placed anywhere within the scope of a trial_prac (i.e.,
% after the 'trial_pracID' message and before 'trial_prac_RESULT')
% See "Protocol for EyeLink Data to Viewer Integration -> Image
% Commands" section of the EyeLink Data Viewer User Manual.
WaitSecs(img1Duration); % duration of probe image

%%%%%% Present fixation # 2 %%%%%%%
switch fixLocation_2(trial_prac)
    case 1 %left fixation
        sector_l = sector_1_left;
        sector_r = AdjoinRect(sector_2_left, sector_l, RectRight);
    case 2 %right fixation
        sector_l = sector_1_right;
        sector_r = AdjoinRect(sector_2_right, sector_l, RectLeft);
    case 3 %up fixation
        sector_l = sector_1_up;
        sector_r =  AdjoinRect(sector_2_up, sector_l, RectBottom);
    case 4 %down fixation
        sector_l = sector_1_down;
        sector_r = AdjoinRect(sector_2_down, sector_l, RectTop);
end

BlobImg = imread('blob.bmp');
TextureBlobImg = Screen('MakeTexture', w, BlobImg);
Screen('FillRect', w, backgroundcolor, sector_l);
Screen('FillRect', w, backgroundcolor, sector_r);
square = [0 0 20 20];
square_l = CenterRect(square, sector_l);
Screen('FillOval', w, fixColor, square_l);
Screen('DrawTexture', w, TextureBlobImg);
Screen('Flip', w);

earlystartflag=0;
while earlystartflag == 0
    if Eyelink('NewFloatSampleAvailable') > 0
        % get the sample in the form of an event structure
        evt = Eyelink('NewestFloatSample');
        if eye_used ~= -1 % do we know which eye to use yet?
            % if we do, get current gaze position from sample
            x = evt.gx(eye_used+1); % +1 as we're accessing MATLAB array
            y = evt.gy(eye_used+1);
            % do we have valid data and is the pupil visible?
            if x~=el.MISSING_DATA && y~=el.MISSING_DATA && evt.pa(eye_used+1)>0
                mx=x;
                my=y;
                %added this- change fixation image if looking at it
                Screen(w, 'FillRect', backgroundcolor);
                if (fixLocation_2(trial_prac)==1 && mx>(rect(3)-(rect(3)-fixWidth)) && my>0 && my< rect(4)) || (fixLocation_2(trial_prac)==2 && mx < (rect(3)-fixWidth) && my>0 && my<rect(4)) || (fixLocation_2(trial_prac)==3 && my>(rect(4)-(rect(4)-fixWidth)) && mx>0 && mx<rect(3)+1000) || (fixLocation_2(trial_prac)==4 && my<rect(4)-fixWidth && mx>0 && mx<rect(3)+1000);
                    Screen('FillRect', w, backgroundcolor, sector_l);
                    Screen('FillRect', w, backgroundcolor, sector_r);
                    Screen('FillOval', w, fixColor, square_l);
                    Screen('DrawTexture', w, TextureBlobImg);                    
                else
                    earlystartflag=1;
                end
                Screen('Flip', w);
            end
        end
    end
end

%%%%%%%%%% Display test image %%%%%%%%%%

% Build texture for foveated region:
foveatex=Screen('MakeTexture', w, foveaimdata);
tRect=Screen('Rect', foveatex);

% Build texture for peripheral (non-foveated) region:
nonfoveatex=Screen('MakeTexture', w, peripheryimdata);
[ctRect, dx, dy]=CenterRect(tRect, rect);

% We create a Luminance+Alpha matrix for use as transparency mask:
% Layer 1 (Luminance) is filled with 'backgroundcolor'.
transLayer=2;
[x,y]=meshgrid(-ms:ms, -ms:ms);

maskblob=ones(2*ms+1, 2*ms+1, transLayer) * backgroundcolor;

% Layer 2 (Transparency aka Alpha) is filled with gaussian transparency
% mask.
xsd=ms/2.2;
ysd=ms/2.2;

if gaussian == 1
     maskblob(:,:,transLayer)=round(255 - exp(-((x/xsd).^2)-((y/ysd).^2))*255);
 else 
%     maskblob(:,:,transLayer) = ((x + xsd).^2 + (y - ysd).^2 < xsd^2);
%     % uniform square shape
maskblob(:,:,transLayer)= 255 * (1 - (x.^2 + y.^2 <= xsd^2));
 end


% Build a single transparency mask texture:
masktex=Screen('MakeTexture', w, maskblob);
mRect=Screen('Rect', masktex);

fprintf('Size image texture: %d x %d\n', RectWidth(tRect), RectHeight(tRect));
fprintf('Size  mask texture: %d x %d\n', RectWidth(mRect), RectHeight(mRect));

WaitSecs(0.1);

eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
if eye_used == el.BINOCULAR; % if both eyes are tracked
    eye_used = el.LEFT_EYE; % use left eye
end

%Set background color to 'backgroundcolor' and do flip to show
%blank screen:
Screen('FillRect', w, 222);
Screen('Flip', w);

% The mouse-cursor position will define gaze-position (center of
% fixation) to simulate (x,y) input from an eyetracker. Set cursor
% initially to center of screen:
[a,b]=RectCenter(rect);
WaitSetMouse(a,b,whichscreen); % set cursor and wait for it to take effect

HideCursor;
buttons=0;

priorityLevel=MaxPriority(w);
Priority(priorityLevel);

% Wait until all keys on keyboard are released:
while KbCheck; WaitSecs(0.1); end;

mxold=0;
myold=0;

oldvbl=Screen('Flip', w);
startrt = GetSecs; % record the time that the image is displayed
tavg = 0;
ncount = 0;

% Send an integration message so that an image can be loaded as
% overlay backgound when performing Data Viewer analysis.  This
% message can be placed anywhere within the scope of a trial_prac (i.e.,
% after the 'trial_pracID' message and before 'trial_prac_RESULT')
% See "Protocol for EyeLink Data to Viewer Integration -> Image
% Commands" section of the EyeLink Data Viewer User Manual.

% Infinite display loop: Whenever "gaze position" changes, we update
% the display accordingly. Loop aborts on keyboard press or mouse
% click or after 10000 frames...
while (ncount < 10000)
    
    
    if dummymode==0 
        error=Eyelink('CheckRecording');
        if(error~=0)
            break;
        end
        
        if Eyelink( 'NewFloatSampleAvailable') > 0
            % get the sample in the form of an event structure
            evt = Eyelink( 'NewestFloatSample');
            if eye_used ~= -1 % do we know which eye to use yet?
                % if we do, get current gaze position from sample
                x = evt.gx(eye_used+1); % +1 as we're accessing MATLAB array
                y = evt.gy(eye_used+1);
                % do we have valid data and is the pupil visible?
                if x~=el.MISSING_DATA && y~=el.MISSING_DATA && evt.pa(eye_used+1)>0
                    mx=x;
                    my=y;
                end
            end
        end
    else
        
        % Query current mouse cursor position (our "pseudo-eyetracker") -
        % (mx,my) is our gaze position.
        if (hurryup==0)
            [mx, my, buttons]=GetMouse; %(w);
        else
            % In benchmark mode, we just do a quick sinusoidal motion
            % without query of the mouse:
            mx=500 + 500*sin(ncount/10); my=300;
        end;
     end


    % We only redraw if gazepos. has changed:
    if (mx~=mxold || my~=myold)
        % Compute position and size of source- and destinationrect and
        % clip it, if necessary...
        myrect=[mx-ms my-ms mx+ms+1 my+ms+1]; % center dRect on current mouseposition
        dRect = ClipRect(myrect,ctRect);
        sRect=OffsetRect(dRect, -dx, -dy);
        
        % Valid destination rectangle?
        if ~IsEmptyRect(dRect)
            % Yes! Draw image for current frame:
            
            % Step 1: Draw the alpha-mask into the backbuffer. It
            % defines the aperture for foveation: The center of gaze
            % has zero alpha value. Alpha values increase with distance from
            % center of gaze according to a gaussian function and
            % approach 255 at the border of the aperture...
            Screen('BlendFunction', w, GL_ONE, GL_ZERO);
            Screen('DrawTexture', w, masktex, [], myrect);
            
            % Step 2: Draw peripheral image. It is only drawn where
            % the alpha-value in the backbuffer is 255 or high, leaving
            % the foveated area (low or zero alpha values) alone:
            % This is done by weighting each color value of each pixel
            % with the corresponding alpha-value in the backbuffer
            % (GL_DST_ALPHA).
            Screen('BlendFunction', w, GL_DST_ALPHA, GL_ZERO);
            Screen('DrawTexture', w, nonfoveatex, [], ctRect);
            
            % Step 3: Draw foveated image, but only where the
            % alpha-value in the backbuffer is zero or low: This is
            % done by weighting each color value with one minus the
            % corresponding alpha-value in the backbuffer
            % (GL_ONE_MINUS_DST_ALPHA).
            Screen('BlendFunction', w, GL_ONE_MINUS_DST_ALPHA, GL_ONE);
            Screen('DrawTexture', w, foveatex, sRect, dRect);
            
            % Show final result on screen. This also clears the drawing
            % surface back to black background color and a zero alpha
            % value.
            % Actually... We use clearmode=2: This doesn't clear the
            % backbuffer, but we don't need to clear it for this kind
            % of stimulus and it gives us 2 msecs extra headroom for
            % higher refresh rates! For benchmark purpose, we disable
            % syncing to retrace if hurryup is == 1.
            vbl = Screen('Flip', w, 0, 2, 2*hurryup);
            vbl = GetSecs;
            tavg = tavg + (vbl-oldvbl);
            oldvbl=vbl;
            ncount = ncount + 1;
        end;
    end;
    
    % Keep track of last gaze position:
    mxold=mx;
    myold=my;
    
    % We wait 1 ms each loop-iteration so that we
    % don't overload the system in realtime-priority:
    WaitSecs(0.001);
       
    % if response keys were pressed stop display
    if (KeyCode(DiffResp) || KeyCode(SameResp))
        break;
    end
    [KeyIsDown, endrt, KeyCode]=KbCheck;
    
    
    
end

% Flip screen to prepare a new trial_prac.
Screen('BlendFunction', w, GL_ONE, GL_ZERO);
Screen('Flip', w);


end