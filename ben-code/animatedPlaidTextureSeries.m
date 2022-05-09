function animatedPlaid = animatedPlaidTextureSeries(speed, deg, movieLengthInSec)
    if nargin < 3
        movieLengthInSec = 5;
    end
    
    if nargin < 2
        deg = 0;
    end
    
    if nargin < 1
        speed = 3; % deg/s 
    end
    
    white = 1.0;
    grey  = white/2;
    inc   = white - grey;
    scrnNum = 0;
    
    mmPerPixel = 344/1920; % mm/px should parameterize this
    
    V.speed = speed;
    V.deg   = deg;
    viewingDistance = 300; % mm
    sf = .009; % cycles per pixel
    gratingSize = 100; 
    af = sf * 2 * pi;
    
    ifi = 0.017;
    [x, y] = meshgrid(-gratingSize:gratingSize, -gratingSize:gratingSize);
    Vy = (1/mmPerPixel)*(tand(V.speed/2)*2*viewingDistance) * sind(V.deg); % px/mm * (dg/s) -> (mm /s) = px/s
    Vx = (1/mmPerPixel)*(tand(V.speed/2)*2*viewingDistance) * cosd(V.deg); % px/s
    dtx = 0;
    dty = 0;
    xGratings = (grey + inc * sin(af * x + dtx));
    yGratings = (grey + inc * cos(af * y + dty));
    plaid = (xGratings + yGratings)/2;
    %disp(plaid);
    disp("size x grating: " + size(xGratings));
    disp("size y grating: " + size(yGratings));
    fps = 60;
    numFrames = movieLengthInSec * fps; % s * frames/s = frames
    plaids = zeros(gratingSize*2 + 1, gratingSize*2 + 1, numFrames);
   
    
    for i = 1:numFrames
        xGratings = (grey + inc * sin(af * x + dtx));
        yGratings = (grey + inc * cos(af * y + dty));
        plaids(:,:,i) = (xGratings + yGratings)/2;
        % dtx = dtx + ((2 * pi * (Vx * sf)) / (1/frameRate)); % px/s * cyc/px * s/frame = cyc/frame  
        % dty = dty + ((2 * pi * (Vy * sf)) / (1/frameRate)); % px/s * cyc/px * s/frame = cyc/frame  
        dtx = dtx + ((2 * pi * (Vx * (1/1000) * sf)) / ifi); % px/s * s/ms * cyc/px * ms/frame = cyc/frame
        dty = dty + ((2 * pi * (Vy * (1/1000) * sf)) / ifi);
    end
     disp("size plaids: " + size(plaids));
    animatedPlaid = plaids;
end
    
    
    
    