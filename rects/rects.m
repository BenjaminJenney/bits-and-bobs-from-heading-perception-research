% Clear the workspace and the screen
sca;
close all;
clear;

InitializeMatlabOpenGL(1);
% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);
global GL;
Screen('Preference', 'SkipSyncTests', 1);

% Get the screen numbers
screens = Screen('Screens');

% Draw to the external screen if avaliable
screenNumber = max(screens);

% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

% Open an on screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

Screen('BeginOpenGL', window);

glMatrixMode(GL.PROJECTION);
glLoadIdentity;

glMatrixMode(GL.MODELVIEW);
glLoadIdentity;

sca;