clear all;

imgSize = 1000; 
for i = 1:10
   
    eval(sprintf(...
        'M%d = 127 + 42*randn(imgSize);', i));
    
    eval(sprintf(...
        'M%d = uint8(M%d) + 1;', i,i)); 
    
    figure;
    eval(sprintf(...
        'imshow(M%d);', i));
    
%    eval(sprintf(...
%        'saveas(gcf, ''stimuli/M%d'', ''bmp'');',i))

    eval(sprintf(...
        'imwrite(M%d, ''stimuli/M%d.bmp'', ''bmp'');',i,i));
    
end

close all