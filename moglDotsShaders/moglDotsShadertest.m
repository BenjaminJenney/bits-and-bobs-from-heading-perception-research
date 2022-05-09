function moglDotsShadertest(speed, deg, movieLengthInSec)
    
    sca;
    close all;
    clearvars;

    if nargin < 3
        movieLengthInSec = 5;
    end
    
    if nargin < 2
        deg = 0;
    end
    
    if nargin < 1
        speed = 3; % deg/s 
    end
    
    InitializeMatlabOpenGL(1);
    Screen('Preference', 'SkipSyncTests', 1);

    rand('seed', sum(100 * clock));

    screens = Screen('Screens');

    screenNumber = max(screens);

    white = WhiteIndex(screenNumber);
    black = BlackIndex(screenNumber);
    grey  = white/2;
    inc   = white - grey;

    [window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);

    [screenXpixels, screenYpixels] = Screen('WindowSize', window);

    if screenXpixels > screenYpixels
        resolution = screenXpixels;
    else
        resolution = screenYpixels;
    end

    screenWidth = 344; %mm
    mmPerPixel = screenWidth/resolution;

    [xCenter, yCenter] = RectCenter(windowRect);

    dim = 2000;
    [x, y, z] = meshgrid(-dim:100:dim, -dim:100:dim, -dim:100:dim);

%     pixelScale = screenYpixels / (dim * 2 + 2);
%     x = x .* pixelScale;
%     y = y .* pixelScale;
%     z = z .* pixelScale;

    numDots = numel(x);

    dotPositionMatrix = [reshape(x, 1, numDots); reshape(y, 1, numDots); reshape(z, 1, numDots)];
    dotSizes = rand(1, numDots) .* 20 + 10;

    dotCenter = [xCenter yCenter];

    V.speed = speed;
    V.deg   = deg;
    viewingDistance = 300; % mm
    sf = .009; % cycles per pixel
    gratingSize = 100; 
    af = sf * 2 * pi;
    
    ifi = Screen('GetFlipInterval', window);
    [x, y] = meshgrid(-gratingSize:gratingSize, -gratingSize:gratingSize);
    Vy = (1/mmPerPixel)*(tand(V.speed/2)*2*viewingDistance) * sind(V.deg); % px/mm * (dg/s) -> (mm /s) = px/s
    Vx = (1/mmPerPixel)*(tand(V.speed/2)*2*viewingDistance)* cosd(V.deg); % px/s
    dtx = 0;
    dty = 0;
    
    cycPerSec = 1;
    angle = 0;
    u_phase = 0;
    phaseIncrement = cycPerSec * 360 * ifi;
    %%%%%%%%%%%Uniforms%%%%%%%%%%%%%%%%%%
    u_freq = 1/360;
    u_amplitude = 0.5;
    
    Screen('BeginOpenGL', window);
%     fragShaderPath = 'C:\Users\benje\Desktop\openGLMatlab\moglDotsTestShader.frag';
%     glsl = LoadGLSLProgramFromFiles(fragShaderPath);
    %fragShaderPath = 'C:\Users\benje\Desktop\openGLMatlab\fragmentShader.frag';
    vertShaderPath = 'C:\Users\benje\Desktop\openGLMatlab\moglDotsShaders\moglVertShader.vert';
    glsl = LoadGLSLProgramFromFiles(vertShaderPath);
    u_freqLoc = glGetUniformLocation(glsl, 'u_freq');
    u_amplitudeLoc = glGetUniformLocation(glsl, 'u_amplitude');
    u_phaseLoc = glGetUniformLocation(glsl, 'u_phase');
    % vertexColorLocation = glGetUniformLocation(glsl, 'u_time');
    while ~KbCheck
        glClear(GL.COLOR_BUFFER_BIT);
        
        u_phase = u_phase + phaseIncrement;
        glUseProgram(glsl); % Updating a uniform requires that we use, i.e bind, the shaderProgram    
        
        glUniform1f(u_freqLoc, u_freq);
        glUniform1f(u_amplitudeLoc, u_amplitude);
        glUniform1f(u_phaseLoc, u_phase);
        %xGratings = (grey + inc * sin(af * x + dtx));
        %yGratings = (grey + inc * cos(af * y + dty));
        %plaid = (xGratings + yGratings)/2;
        
        %dtx = dtx + ((2 * pi * (Vx * (1/1000) * sf)) / ifi); % px/s * s/ms * cyc/px * ms/frame = cyc/frame
        %dty = dty + ((2 * pi * (Vy * (1/1000) * sf)) / ifi);
        
        moglDrawDots3D(window, dotPositionMatrix, dotSizes, [], [], [], glsl);
        Screen('EndOpenGL', window);
        Screen('Flip', window);
        Screen('BeginOpenGL', window);
    end

    sca;
end