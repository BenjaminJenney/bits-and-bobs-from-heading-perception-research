function plaidData = makeSomePlaid(x, y,spatialFrequency)
    white = 1.0;
    grey  = white/2;
    %inc   = white - grey;
    
    
    %spatialFrequency = 1; % cycles per deg
    spatialFrequency = (1/15.4483).*spatialFrequency; %1/px_per_deg %convert from deg to pix
    angularFrequency = spatialFrequency * 2 * pi;
    
    xGrating = (1+sin(angularFrequency * x))/2;
    yGrating = (1+sin(angularFrequency * y))/2;
    
    plaidData = 255.*((xGrating + yGrating)/2); %BJ: how does multiplying by 255(white right?) make the image grayscale?
    plaidData = repmat(plaidData,[ 1 1 3 ]);
    plaidData = permute(uint8(plaidData),[ 3 2 1 ]);
    plaidData(4,:,:) = 255;
    
    %{
    figure; imagesc(255.*((xGrating + yGrating)/2))
    axis equal
    colormap gray
    shg
    keyboard
%}
end