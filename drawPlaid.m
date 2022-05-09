function drawPlaid(speed, deg, movieLengthInSec) 
    if nargin < 3
        movieLengthInSec = 5;
    end
    
    if nargin < 2
        deg = 0;
    end
    
    if nargin < 1
        speed = 3; % deg/s 
    end
    
    PsychDefaultSetup(2);
    Screen('Preference', 'SkipSyncTests', 1); 
    screenNumber = max(Screen('Screens'));
    % priorityLevel = MaxPriority(window);
    %Priority(priorityLevel);
    white = WhiteIndex(screenNumber);
    grey  = white/2;
    inc   = white - grey;
    screenWidth = 344; % mm
    res = 1920; % pixels
    mmPerPixel = 344/1920;
    
    [window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, [0, 0, 720, 480], 32, 2,...
    [], [], kPsychNeed32BPCFloat);
    
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
    vbl = Screen('Flip', window);
    numFrames = movieLengthInSec * 60;
    plaidTextures = zeros(1, numFrames);
    for i = 1:numFrames
        xGratings = (grey + inc * sin(af * x + dtx));
        yGratings = (grey + inc * cos(af * y + dty));
        plaid = (xGratings + yGratings)/2;
        plaidTextures(i) = Screen('MakeTexture', window, plaid);
        %dtx = dtx + ((2 * pi * (Vx * sf)) / (1/frameRate)); % px/s * cyc/px * s/frame = cyc/frame  
        %dty = dty + ((2 * pi * (Vy * sf)) / (1/frameRate)); % px/s * cyc/px * s/frame = cyc/frame  
        dtx = dtx + ((2 * pi * (Vx * (1/1000) * sf)) / ifi); % px/s * s/ms * cyc/px * ms/frame = cyc/frame
        dty = dty + ((2 * pi * (Vy * (1/1000) * sf)) / ifi);
    end
    Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    mask = ones(2*gratingSize+1, 2*gratingSize+1, 2) * grey;
    sigma = 45; % pixels
    [x, y] = meshgrid(-gratingSize:gratingSize, -gratingSize:gratingSize);
    mask(:, :, 2) = (white - exp(-((x/sigma).^2)-((y/sigma).^2)));
    gaussMaskTexture = Screen('MakeTexture', window, mask);
    
    %Screen('DrawTexture', window, plaidTextures(1));
    %Screen('DrawTexture', window, plaidTextures(2));
   
   waitframes = 1;
     for i = 1:length(plaidTextures)
         Screen('DrawTexture', window, plaidTextures(i));
         Screen('DrawTexture', window, gaussMaskTexture, [0,0, 201, 201]);
         vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
     end
     %sca;
     KbPressWait
     sca;
end