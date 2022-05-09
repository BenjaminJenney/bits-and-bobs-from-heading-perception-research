function [plaidData, gratingSize] = makePlaidData(size) 
    
    white = WhiteIndex(0);
    grey  = white/2;
    inc   = white - grey;
    sf = .009; % cycles per pixel
    gratingSize = size;
    [x, y] = meshgrid(-gratingSize:gratingSize, -gratingSize:gratingSize);
    af = sf * 2 * pi;
    xGratings = (grey + inc * sin(af * x));
    yGratings = (grey + inc * cos(af * y));
    plaidData = (xGratings + yGratings)/2;
end