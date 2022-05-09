%Bas's surround texture, taken from a larger code base and a VR context and drawn on a plain old
%screen -- Benjamin Jenney did this for learning purposes.

InitializeMatlabOpenGL(1);
global GL;

Screen('Preference', 'SkipSyncTests', 1);

screenNum = max(Screen('Screens'));

black = screenNum;

PsychDefaultSetup(2);
white = WhiteIndex(0);
black = BlackIndex(0);
grey  = white/2;
inc   = white - grey;
[win, winRect] = PsychImaging('OpenWindow', screenNum, black);
[screenXpixels, screenYpixels] = Screen('WindowSize', win);

[xCenter, yCenter] = RectCenter(winRect);
Screen('BlendFunction', win, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
gaussDim = 50;
gaussSigma = gaussDim / 3;
[xm, ym] = meshgrid(-gaussDim:gaussDim, -gaussDim:gaussDim);
gauss = exp(-(((xm .^2) + (ym .^2)) ./ (2 * gaussSigma^2)));
[s1, s2] = size(gauss);
mask = ones(s1, s2, 2) * black;
mask(:, :, 2) = white * (1 - gauss);
masktex = Screen('MakeTexture', win, mask);

[xg, yg] = meshgrid(-3:1:3, -3:1:3);
spacing = gaussDim * 2;
xg = xg .* spacing + screenXpixels / 2;
yg = yg .* spacing + screenYpixels / 2;
xg = reshape(xg, 1, numel(xg));
yg = reshape(yg, 1, numel(yg));

% Make the destination rectangles for the gaussian apertures
dstRects = nan(4, numel(xg));
for i = 1:numel(xg)
    dstRects(:, i) = CenterRectOnPointd([0 0 s1, s2], xg(i), yg(i));
end

% fullWindowMask = Screen('MakeTexture', win,...
%    ones(screenYpixels, screenXpixels) .* black);

%Screen('DrawTextures', fullWindowMask, masktex, [], dstRects);
Screen('BeginOpenGL', win);

glEnable(GL_BLEND);
glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
glViewport(0, 0, RectWidth(winRect), RectHeight(winRect));
glMatrixMode(GL.PROJECTION);
glLoadIdentity;

glMatrixMode(GL.MODELVIEW);
glLoadIdentity;


glEnable(GL.TEXTURE_3D);


wall_texid = glGenTextures(1);
halfTextureSize = 128; % in px for meshgrid

%plaidData = makePlaidData(halfTextureSize);
%normalizedPlaidData = (plaidData - min(plaidData)) / ( max(plaidData) - min(plaidData) );

[x,y] = meshgrid(-halfTextureSize+1:halfTextureSize,-halfTextureSize+1:halfTextureSize);

noysSlope = 1.0; %1.5;
noys = 255.*oneoverf(noysSlope, size(x,1), size(x,2)); % oneoverf -> [0:1]
noys=repmat(noys,[ 1 1 3 ]);
noys=permute(uint8(noys),[ 3 2 1 ]);

xoffset = -10:1:10;
yoffset = -10:1:10;
rmin_bg = 45.6874;% pixels 
rmax_bg = 350.7631;% pixels  
rstrip = 11.6268;% this cuts a strip into the fixation disk that has a height the size of the paddle height
% this code pokes out the transparent aperture
opaque = ones(size(x'));

% for i = 1:length(xoffset)
%     opaque = min(opaque, ((sqrt((x'+xoffset(i)).^2+(y'+yoffset(i)).^2) >  rmax_bg)  |( sqrt((x'+xoffset(i)).^2+(y'+yoffset(i)).^2) <  rmin_bg)));
% end
% noys(4,:,:) = shiftdim(255 .* opaque, -1); 

glBindTexture(GL_TEXTURE_3D,  wall_texid);
glTexParameterfv(GL_TEXTURE_3D, GL_TEXTURE_WRAP_S, GL_REPEAT);
glTexParameterfv(GL_TEXTURE_3D, GL_TEXTURE_WRAP_T, GL_REPEAT);
glTexParameterfv(GL_TEXTURE_3D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
glTexParameterfv(GL_TEXTURE_3D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
glTexImage3D(GL_TEXTURE_3D, 0, GL_RGB, halfTextureSize*2, halfTextureSize*2, 0.0, 0, GL_RGB, GL_UNSIGNED_BYTE, noys);
glTexEnvfv(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);

%glClear(GL.COLOR_BUFFER_BIT);
corners = [0 0;
    1 0;
    1 1;
    0 1
];

halfHeight = winRect(4)/2;
halfWidth  = winRect(3)/2;
canvas = .09; % pick the larger of the two dimensions, since they are not equal
depth = 0.0;
v=[-canvas -canvas depth;... 
    canvas -canvas depth;...
    canvas canvas  depth;...
    -canvas canvas depth]';

surroundTexture = glGenLists(1);
glNewList(surroundTexture, GL.COMPILE);
glBegin(GL.POLYGON);

for i = 1:4
    
    glTexCoord2dv(corners(i,:));
    glVertex3dv(v(:,i));
end

glEnd;

glEndList;



translations = struct('x',{},'y',{},'z',{});
index = 1;
offset = 0.1;
for y = -10:2:9
    for x = -10:2:9
        translation.x = x / 10.0 + offset;
        translation.y = y / 10.0 + offset;
        translations{index} = translation;
        index = index+1;
    end
end

    %%%Draw texture grid%%%%
    for i = 1:100
        glPushMatrix;
        if i < 51
             glTranslated(translations(i).x, translations(i).y, -.5);
        else
             glTranslated(translations(i).x, translations(i).y, 0.0);
        end
        glCallList(surroundTexture);
        glPopMatrix;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%
    % we are done with background texture

   % glBindTexture(GL_TEXTURE_2D, 0);    
       % Screen('EndOpenGL', win);
        
        %Screen('DrawTexture', win, fullWindowMask, [], [], [], [], 1);
%Screen('BeginOpenGL', win);
    %% The bag over your head
%     textureIDs = glGenTextures(2);
%     blackTextureData = ones(1024,1024);
%     glActiveTexture(GL_TEXTURE0)
%     glEnable(GL_TEXTURE_2D);
%     glBindTexture(GL_TEXTURE_2D, textureIDs);
% 
%     glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
%     glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
%     glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
%     glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
%     glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 1024, 1024, 0, GL_RGBA, GL_UNSIGNED_BYTE, blackTextureData);
%     glTexEnvfv(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);    
%     glBegin(GL_QUADS);
%         glTexCoord2f(0.0,0.0);
%         glVertex2f(1.0, 1.0);
%         glTexCoord2f(1.0,0.0);
%         glVertex2f(-1.0,1.0);
%         glTexCoord2f(1.0,1.0);
%         glVertex2f(-1.0,-1.0);
%         glTexCoord2f(0.0,1.0);
%         glVertex2f(1.0,-1.0);
%     glEnd;
%     % The holes in the bag over your head
%     gratingSize = 1024; 
%     mask = ones(2*gratingSize+1, 2*gratingSize+1, 2) * 0.5;
%     sigma = 45; % pixels
%     [x, y] = meshgrid(-gratingSize+1:gratingSize, -gratingSize+1:gratingSize);
%     mask(:, :, 2) = (1.0 - exp(-((x/sigma).^2)-((y/sigma).^2)));
%     
%     glBindTexture(GL_TEXTURE_2D, textureIDs(2));
%     glActiveTexture(GL_TEXTURE1);
%     glEnable(GL_TEXTURE_2D);
%     
%     glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
%     glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
%     glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
%     glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
%     glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, gratingSize*2, gratingSize*2, 0, GL_RGBA, GL_UNSIGNED_BYTE, mask);
%     glBegin(GL_QUADS);
%         glMultiTexCoord2f(GL_TEXTURE0, 0, 0);
%         glMultiTexCoord2f(GL_TEXTURE1, 0, 0);
%         glVertex2f(1.0, 1.0);
%         glMultiTexCoord2f(GL_TEXTURE0, 1, 0);
%         glMultiTexCoord2f(GL_TEXTURE1, 1, 0);
%         glVertex2f(-1.0,1.0);
%         glMultiTexCoord2f(GL_TEXTURE0, 1, 1);
%         glMultiTexCoord2f(GL_TEXTURE1, 1, 1);
%         glVertex2f(-1.0,-1.0);
%         glMultiTexCoord2f(GL_TEXTURE0, 0, 1);
%         glMultiTexCoord2f(GL_TEXTURE1, 0, 1);
%         glVertex2f(1.0,-1.0);
%     glEnd;
%     v = rand(3,100);
%     
%     moglDrawDots3D(win, v, 10, [0, 0, 1, .5]);

    Screen('EndOpenGL', win);
    
    Screen('Flip', win);
    %Screen('BeginOpenGL', win);
        
KbWait;
sca;



