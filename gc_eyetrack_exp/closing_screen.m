function closing_screen( w, screenRes, SpaceResp )
% Closing screen for GC eyetracking study
%   Detailed explanation goes here

text1 = 'You have finished the experiment.';
text2 = 'Thank you for participating'; 
text3 = 'Please hit space-bar';

DrawFormattedText(w,text1,'center',(screenRes(2)/2)-50);
DrawFormattedText(w, text2, 'center', screenRes(2)/2);
DrawFormattedText(w, text3, 'center', (screenRes(2)/2)+100);

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
end

