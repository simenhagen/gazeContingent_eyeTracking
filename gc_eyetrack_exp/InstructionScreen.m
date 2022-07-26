function InstructionScreen( w, rect, SpaceResp, screenRes)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

instructText_01 = 'Your task is to recognize the two birds presented in two';
instructText_02 = 'different images as the same (s) or different (d) species.';
instructText_03 = 'Please respond as QUICKLY and ACCURATELY as you can.';
instructText_04 = 'There will be 3 brakes in the experiment';
instructText_05 = 'All bird images will be facing left.';
instructText_06 = 'Please hit space-bar to see an example of task';
Screen('TextSize', w, 12);
DrawFormattedText(w, instructText_01, 'center', (screenRes(2)/2)-50);
DrawFormattedText(w, instructText_02, 'center', screenRes(2)/2);
DrawFormattedText(w, instructText_03, 'center', (screenRes(2)/2)+80);
DrawFormattedText(w, instructText_04, 'center', (screenRes(2)/2)+130);
DrawFormattedText(w, instructText_05, 'center', (screenRes(2)/2)+180);
DrawFormattedText(w, instructText_06, 'center', (screenRes(2)/2)+250);
Screen('Flip', w);

        touch=0;		% Detect space bar press to continue
        while ~touch
            [touch,tpress,keycode]=KbCheck;
            if keycode(SpaceResp);
                break; 
            else
                touch=0;
            end
        end
        while KbCheck; end
   
    % Show example image of trial
    exampleImg_01 = imread('stimuli/task_example_01.png');
    Screen('PutImage', w, exampleImg_01, [1,1,screenRes(1),screenRes(2)]);
    Screen('Flip', w);

        touch=0;		% Detect space bar press to continue
        while ~touch
            [touch,tpress,keycode]=KbCheck;
            if keycode(SpaceResp);
                break; 
            else
                touch=0;
            end
        end
        while KbCheck; end
        
    % Show example image of trial
    exampleImg_02 = imread('stimuli/task_example_02.png');
    Screen('PutImage', w, exampleImg_02, [1,1,screenRes(1),screenRes(2)]);
    Screen('Flip', w);

        touch=0;		% Detect space bar press to continue
        while ~touch
            [touch,tpress,keycode]=KbCheck;
            if keycode(SpaceResp);
                break; 
            else
                touch=0;
            end
        end
        while KbCheck; end
        
   % Show example image of trial
    exampleImg_03 = imread('stimuli/task_example_03.png');
    Screen('PutImage', w, exampleImg_03, [1,1,screenRes(1),screenRes(2)]);
    Screen('Flip', w);

        touch=0;		% Detect space bar press to continue
        while ~touch
            [touch,tpress,keycode]=KbCheck;
            if keycode(SpaceResp);
                break; 
            else
                touch=0;
            end
        end
        while KbCheck; end
        
    % Show example image of trial
    exampleImg_04 = imread('stimuli/task_example_04.png');
    Screen('PutImage', w, exampleImg_04, [1,1,screenRes(1),screenRes(2)]);
    Screen('Flip', w);

        touch=0;		% Detect space bar press to continue
        while ~touch
            [touch,tpress,keycode]=KbCheck;
            if keycode(SpaceResp);
                break; 
            else
                touch=0;
            end
        end
        while KbCheck; end

FlushEvents('keyDown');
Screen('Close')
    
    
    
end


