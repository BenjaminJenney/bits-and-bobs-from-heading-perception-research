InitializeMatlabOpenGL(1);
global GL;
Screen('Preference', 'SkipSyncTests', 1);
[w, wr] = Screen('OpenWindow', 0, [0 0 0 0]);

Screen('BeginOpenGL', w);
glMatrixMode(GL.PROJECTION)
glLoadIdentity;

glMatrixMode(GL.MODELVIEW);
glLoadIdentity;
glEnable(GL.TEXTURE_2D);
screenRenderWidthMonocular_px     = 1920; % the discrepancy btw. oculus's spec reported res of 1080 * 1200 is that the render resolution is higher than the screen res in order to make up for the barrel transform.
screenRenderHeightMonocular_px    = 1080;

screenWidthMonocular_px  = 1920; % this is what is reported in oculus's cv1 specs.
screenHeightMonocular_px = 1080; % this is what is reported in oculus's cv1 specs.
        screenWidthBinocular_px  = screenWidthMonocular_px*2; % apparently just multiply by # of lens.
        screenWidthBinocular_px  = screenHeightMonocular_px*2; % apparently just multiply by # of lens.
        hFOV_perPersonAvg   = 87; % based on averages taken from https://www.infinite.cz/blog/VR-Field-of-View-measured-explained   
        %hFOV_psych          = hmdinfo.fovL(1) + hmdinfo.fovL(2); % in deg - symmetric for fovL and fovR
        vFOV_perPersonAvg   = 84; % based on averages taken from https://www.infinite.cz/blog/VR-Field-of-View-measured-explained   
        %hFOV_psych          = hmdinfo.fovL(3) + hmdinfo.fovL(4); % in deg - vertical field of view
        screenX_deg = hFOV_perPersonAvg;
        screenY_deg = vFOV_perPersonAvg;
        px_per_deg  = screenRenderWidthMonocular_px/screenX_deg; %~15.45 this seems pretty good check out: https://www.roadtovr.com/understanding-pixel-density-retinal-resolution-and-why-its-important-for-vr-and-ar-headsets/
        deg_per_px  = 1/px_per_deg;
        focalLength = 1.2;

% Set up texture for the three planes
planeTextureWidth_px   = 1920;
planeTextureHeight_px  = 1080;
 
xHalfTextureSize = planeTextureWidth_px/2;
yHalfTextureSize = planeTextureHeight_px/2;

[x,y] = meshgrid(-xHalfTextureSize+1:xHalfTextureSize,-yHalfTextureSize+1:yHalfTextureSize);

spatialFrequency = .5;% cycles/deg % sf of plaid
textureData  = makeSomePlaid(x,y,spatialFrequency);
planeTexture = Texture(GL, GL_TEXTURE_2D, xHalfTextureSize*2, yHalfTextureSize*2, textureData);
% End texture for the three planes

% Setup vertices for the three planes

planeDepths_m  = [0, 0, 0]; % near, mid, far.
numPlanes      = length(planeDepths_m);
planeWidths_m  = zeros(1, numPlanes);
planeHeights_m = zeros(1, numPlanes);

for i = 1:numPlanes
   planeWidths_m(i)  = 1;
   planeHeights_m(i) = 1;
end

numVertices = 4;
corners = [0 0;
    1 0;
    1 1;
    0 1];

planes = zeros(1, numPlanes);

for i = 1:numPlanes
    
    ithPlaneVertices =[-planeWidths_m(i)/2 -planeHeights_m(i)/2 planeDepths_m(i) ;... 
                        planeWidths_m(i)/2 -planeHeights_m(i)/2 planeDepths_m(i) ;...
                        planeWidths_m(i)/2  planeHeights_m(i)/2 planeDepths_m(i) ;...
                       -planeWidths_m(i)/2  planeHeights_m(i)/2 planeDepths_m(i) ]';
    planes(i) = glGenLists(1);

    glNewList(planes(i), GL.COMPILE);
        planeTexture.bind;
        glBegin(GL.POLYGON);
        for j = 1:numVertices
            glTexCoord2dv(corners(j,:));
            glVertex3dv(ithPlaneVertices(:,j));
        end
        glEnd;
    glEndList(); 
    
end

glCallList(planes(1));

% Close the OpenGL rendering context
Screen('EndOpenGL', w);
Screen('Flip', w);
KbWait;
sca;
