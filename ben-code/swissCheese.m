InitializeMatlabOpenGL(1);
global GL;

Screen('Preference', 'SkipSyncTests', 1);

screenNum = max(Screen('Screens'));

black = screenNum;

%PsychDefaultSetup(2);

[win, winRect] = Screen('OpenWindow', screenNum, screenNum);

Screen('BeginOpenGL', win);
glEnable(GL_BLEND);
glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
glMatrixMode(GL.PROJECTION);
glLoadIdentity;

glMatrixMode(GL.MODELVIEW);
glLoadIdentity;

glEnable(GL.TEXTURE_2D);


mag_filter = GL_LINEAR; %GL_NEAREST; %_LINEAR;
min_filter = GL_LINEAR; %GL_NEAREST; %GL_LINEAR_MIPMAP_NEAREST; %_LINEAR

% Initialize textures
%wall_texid = glGenTextures(1); % this will be the surround texture with the fixation disk and fixation lines embedded

%% Suuround Texture - the fixation plane surround with fixation disk and fixation lines embedded
%% BEJ: Surround texture adapted to 3 evenly sized planes 8/3/2021
halfTextureSize = 1024;%xc;  % needs to be in pixels for meshgrid

[x,y] = meshgrid(-halfTextureSize+1:halfTextureSize,-halfTextureSize+1:halfTextureSize);

noysSlope = 1.0; %1.5;
noys = 255.*oneoverf(noysSlope, size(x,1), size(x,2)); % oneoverf -> [0:1]
noys=repmat(noys,[ 1 1 3 ]);
noys=permute(uint8(noys),[ 3 2 1 ]);

xoffset = 0;
yoffset = 0;
rmin_bg = 10;%45.6874;% pixels  

% this code pokes out the transparent aperture
opaque = ones(size(x'));

for i = 1:length(xoffset)
    opaque = min(opaque, ((x'+xoffset(i)).^2+(y'+yoffset(i)).^2) > rmax_bg)  | ((x'+xoffset(i)).^2+(y'+yoffset(i)).^2) < rmin_bg;
end
noys(4,:,:) = shiftdim(255 .* opaque, -1); 


glBindTexture(GL_TEXTURE_2D, wall_texid);
glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, mag_filter);
glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, min_filter);
% glTexParameterfv(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, GL_TRUE);
glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, halfTextureSize*2, halfTextureSize*2, 0, GL_RGBA, GL_UNSIGNED_BYTE, noys);
glTexEnvfv(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);

corners = [0 0;
    1 0;
    1 1;
    0 1];

canvas = 1.0;

v=[-canvas -canvas -.5 ;... 
    canvas -canvas -.5 ;...
    canvas canvas  -.5 ;...
   -canvas canvas  -.5]';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% surroundTexture = glGenLists(1);
% glNewList(surroundTexture, GL.COMPILE);
%       
% glBegin(GL.POLYGON);
% 
% for i = 1:4
%     glTexCoord2dv(corners(i,:));
%     glVertex3dv(v(:,i));
% end
% glEnd;
% 
% 
% 
% glEndList(); % 1/f noise texture is complete
% glCallList(surroundTexture);
% % Close the OpenGL rendering context
% Screen('EndOpenGL', win);
% Screen('Flip', win);
% KbWait;
% sca;