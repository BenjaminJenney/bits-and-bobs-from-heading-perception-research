global GL; 
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

    dim = 1000;
    [x, y, z] = meshgrid(-dim:100:dim, -dim:100:dim, -dim:100:dim);

%     pixelScale = screenYpixels / (dim * 2 + 2);
%     x = x .* pixelScale;
%     y = y .* pixelScale;
%     z = z .* pixelScale;

    numDots = numel(x);

    dotPositionMatrix = [reshape(x, 1, numDots); reshape(y, 1, numDots); reshape(z, 1, numDots)];
    dotSizes = rand(1, numDots) .* 20 + 10;
 Screen('BeginOpenGL', window);
%   glMatrixMode(GL.PROJECTION);
%     glLoadIdentity;
%   glMatrixMode(GL.MODELVIEW);
%     glLoadIdentity;

wall_texid = glGenTextures(1);
halfTextureSize = 128; % in px for meshgrid

%plaidData = makePlaidData(halfTextureSize);
%normalizedPlaidData = (plaidData - min(plaidData)) / ( max(plaidData) - min(plaidData) );

[x,y] = meshgrid(-halfTextureSize+1:halfTextureSize,-halfTextureSize+1:halfTextureSize);

noysSlope = 1.0; %1.5;
noys = 255.*oneoverf(noysSlope, size(x,1), size(x,2)); % oneoverf -> [0:1]
noys=repmat(noys,[ 1 1 3 ]);
noys=permute(uint8(noys),[ 3 2 1 ]);

xoffset = 0;
yoffset = 0;
rmin_bg = 45.6874;% pixels 
rmax_bg = 350.7631;% pixels  
rstrip = 11.6268;% this cuts a strip into the fixation disk that has a height the size of the paddle height
% this code pokes out the transparent aperture
opaque = ones(size(x'));

for i = 1:length(xoffset)
    opaque = min(opaque, ((sqrt((x'+xoffset(i)).^2+(y'+yoffset(i)).^2) >  rmax_bg)  | ((abs(y'+yoffset(i)) >  rstrip) & sqrt((x'+xoffset(i)).^2+(y'+yoffset(i)).^2) <  rmin_bg)));
end
noys(4,:,:) = shiftdim(255 .* opaque, -1); 

glBindTexture(GL_TEXTURE_2D,  wall_texid);
glEnable(GL_POINT_SPRITE);
glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, halfTextureSize*2, halfTextureSize*2, 0, GL_RGBA, GL_UNSIGNED_BYTE, noys);
glTexEnvfv(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
glTexEnvi(GL_POINT_SPRITE, GL_COORD_REPLACE, GL_TRUE);

    vertShaderPath = 'C:\Users\benje\Desktop\openGLMatlab\moglDotsShaders\vertForGeomTest.vert';
    geomShaderPath = 'C:\Users\benje\Desktop\openGLMatlab\moglDotsShaders\geometryShader.geom';
    fragShaderPath = 'C:\Users\benje\Desktop\openGLMatlab\moglDotsShaders\fragForGeomTest.frag';
    glsl = LoadGLSLProgramFromFiles({vertShaderPath, geomShaderPath, fragShaderPath});
    [x,y] = meshgrid(-halfTextureSize+1:halfTextureSize,-halfTextureSize+1:halfTextureSize);

     while ~KbCheck
        glClear(GL.COLOR_BUFFER_BIT);
         glUseProgram(glsl);
        moglDrawDots3D(window, dotPositionMatrix, dotSizes, [1 1 1 1], [], 2, glsl);
        Screen('EndOpenGL', window);
        Screen('Flip', window);
        Screen('BeginOpenGL', window);
     end
    
     sca;