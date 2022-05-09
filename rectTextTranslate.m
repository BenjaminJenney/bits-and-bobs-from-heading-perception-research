global GL;
[window, windowRect] = initOpenGLWindowContext;

[plaidData, gratingSize] = makePlaidData(256);
Screen('BeginOpenGL', window);

glMatrixMode(GL.PROJECTION);
glLoadIdentity;

glMatrixMode(GL.MODELVIEW);
glLoadIdentity;

glEnable(GL.TEXTURE_2D);

plaidTextureID = glGenTextures(1);

glBindTexture(GL.TEXTURE_2D,  plaidTextureID);
glTexParameterfv(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP);
glTexParameterfv(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP);
glTexParameterfv(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
glTexParameterfv(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
glTexImage2D(GL.TEXTURE_2D, 0, GL.RGBA, gratingSize*2, gratingSize*2, 0, GL.RGBA, GL.FLOAT, plaidData);
glTexEnvfv(GL.TEXTURE_ENV, GL.TEXTURE_ENV_MODE, GL.MODULATE);

corners = [0 0;
    1 0;
    1 1;
    0 1];

%halfHeight = winRect(4)/2;
%halfWidth  = winRect(3)/2;
canvas = 200; % pick the larger of the two dimensions, since they are not equal

v=[-canvas -canvas -.5 ;... 
    canvas -canvas -.5 ;...
    canvas canvas  -.5 ;...
    -canvas canvas -.5]';

surroundTexture = glGenLists(1);
glNewList(surroundTexture, GL.COMPILE);
glBegin(GL.POLYGON);
for i = 1:4
    glTexCoord2dv(corners(i,:));
    glVertex3dv(v(:,i));
end
glEnd;
glEndList;

while ~KbCheck
    glClear;
    glCallList(surroundTexture);

    Screen('EndOpenGL', window);
    Screen('Flip', window);
    Screen('BeginOpenGL', window);
end