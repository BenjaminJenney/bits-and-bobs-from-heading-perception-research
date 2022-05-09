%Bas's surround texture, taken from a larger code base and a VR context and drawn on a plain old
%screen -- Benjamin Jenney did this for learning purposes.

InitializeMatlabOpenGL(1);
global GL;

Screen('Preference', 'SkipSyncTests', 1);

screenNum = max(Screen('Screens'));

black = screenNum;

%PsychDefaultSetup(2);

[win, winRect] = Screen('OpenWindow', screenNum, screenNum);

Screen('BeginOpenGL', win);

glMatrixMode(GL.PROJECTION);
glLoadIdentity;

glMatrixMode(GL.MODELVIEW);
glLoadIdentity;

glEnable(GL.TEXTURE_2D);
glEnable(GL.BLEND);
glBlendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);


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

%glClear(GL.COLOR_BUFFER_BIT);

corners = [0 0;
    1 0;
    1 1;
    0 1
];

halfHeight = winRect(4)/2;
halfWidth  = winRect(3)/2;
canvas = .128; % pick the larger of the two dimensions, since they are not equal

v=[-canvas -canvas -.5 ;... 
    canvas -canvas -.5 ;...
    canvas canvas  -.5 ;...
    -canvas canvas -.5]';

surroundTexture = glGenLists(1);
glNewList(surroundTexture, GL.COMPILE);
glPointSize(200.0)
glBegin(GL.POINTS);
for i = 1:4
    glTexCoord2dv(corners(i,:));
    glVertex3dv(v(:,i));
end
glEnd;
glEndList;
glBindTexture(GL_TEXTURE_2D, 0);
gaussDim = 128;
gaussSigma = gaussDim / 7; % csb: controls how big the apertures are
[xm, ym] = meshgrid(-gaussDim:gaussDim, -gaussDim:gaussDim);
gauss = exp(-(((xm .^2) + (ym .^2)) ./ (2 * gaussSigma^2)));

[s1, s2] = size(gauss);
mask = ones(s1, s2, 2) * 0.0;
mask(:, :, 2) = 1.0 * (1 - gauss);

mask_texid = glGenTextures(1);
glBindTexture(GL_TEXTURE_2D,  mask_texid);
glEnable(GL_POINT_SPRITE);
glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, gaussDim*2, gaussDim*2, 0, GL_LUMINANCE, GL_FLOAT, mask);
glTexEnvfv(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
glTexEnvi(GL_POINT_SPRITE, GL_COORD_REPLACE, GL_TRUE);


maskTexture = glGenLists(1);
glNewList(maskTexture, GL.COMPILE);
glPointSize(200.0)
glBegin(GL.POINTS);
for i = 1:4
    glTexCoord2dv(corners(i,:));
    glVertex3dv(v(:,i));
end
glEnd;
glEndList;

while ~KbCheck
    glClear;
    glCallList(surroundTexture);
    glCallList(maskTexture);
    Screen('EndOpenGL', win);
    Screen('Flip', win);
    Screen('BeginOpenGL', win);
end

sca;



