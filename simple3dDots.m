 InitializeMatlabOpenGL(1);
 global GL;
 Screen('Preference', 'SkipSyncTests', 1);
 screenNumber = 0; 
 [window, windowRect] = Screen('OpenWindow', screenNumber, 0);

% vertices currently only contains position information %
vertices = [
    .50,    .25, .75; % vertex 1
    .50,    .25, .75; % vertex 2
    .20,      .40,  .10; % vertex 3
];


 moglDrawDots3D(window, vertices, 5, [], [.5,.5,0], [], 0);
 %Screen('EndOpenGL', window);
 Screen('Flip', window);
 
 KbWait;
 sca;