function [window, windowRect] = initOpenGLWindowContext 
     InitializeMatlabOpenGL(1);
    Screen('Preference', 'SkipSyncTests', 1);
    screenNumber = 0; 
    [window, windowRect] = Screen('OpenWindow', screenNumber);
    
end