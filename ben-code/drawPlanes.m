function drawPlanes(GL)
    %InitializeMatlabOpenGL(1);

    %Screen('Preference', 'SkipSyncTests', 1);

    %screenNum = max(Screen('Screens'));

    %black = screenNum;
    %PsychDefaultSetup(2);

    %[win, winRect] = Screen('OpenWindow', 0, screenNum);
    %Screen('BeginOpenGL', win); % Setup the OpenGL rendering context
%     glEnable(GL.TEXTURE_2D); % Enable 2D texture mapping
%     glMatrixMode(GL.PROJECTION);
%     glLoadIdentity;
% 
%     glMatrixMode(GL.MODELVIEW);
%     glLoadIdentity;
    glDisable(GL.BLEND);
    mag_filter = GL.LINEAR; %GL.NEAREST; %_LINEAR;
    min_filter = GL.LINEAR; %GL.NEAREST; %GL.LINEAR_MIPMAP_NEAREST; %_LINEAR

    % Initialize textures
    ds.wall_texid = glGenTextures(1); % this will be the surround texture with the fixation disk and fixation lines embedded

    %% Suuround Texture - the fixation plane surround with fixation disk and fixation lines embedded

    halfTextureSize = 1024;%ds.xc;  % needs to be in pixels for meshgrid

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
        opaque = min(opaque, ((sqrt((x'+xoffset(i)).^2+(y'+yoffset(i)).^2) > rmax_bg)  | ((abs(y'+yoffset(i)) > rstrip) & sqrt((x'+xoffset(i)).^2+(y'+yoffset(i)).^2) < rmin_bg)));
    end
    noys(4,:,:) = shiftdim(255 .* opaque, -1); 


    glBindTexture(GL.TEXTURE_2D, ds.wall_texid);
    glTexParameterfv(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.REPEAT);
    glTexParameterfv(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.REPEAT);
    glTexParameterfv(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, mag_filter);
    glTexParameterfv(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, min_filter);
    % glTexParameterfv(GL.TEXTURE_2D, GL.GENERATE_MIPMAP, GL.TRUE);
    glTexImage2D(GL.TEXTURE_2D, 0, GL.RGBA, halfTextureSize*2, halfTextureSize*2, 0, GL.RGBA, GL.UNSIGNED_BYTE, noys);
    glTexEnvfv(GL.TEXTURE_ENV, GL.TEXTURE_ENV_MODE, GL.MODULATE);

    corners = [0 0;
        1 0;
        1 1;
        0 1];

    canvas = 1.0; % pick the larger of the two dimensions, since they are not equal

    v=[(-canvas/3) -canvas -.5 ;... 
        (canvas/3) -canvas -.5 ;...
        (canvas/3) canvas -.5 ;...
        (-canvas/3) canvas -.5]';

    surroundTexture = glGenLists(1);
    glNewList(surroundTexture, GL.COMPILE);

    glBegin(GL.POLYGON);
    for i = 1:4
        glTexCoord2dv(corners(i,:));
        glVertex3dv(v(:,i));
    end
    glEnd;



    glEndList(); % 1/f noise texture is complete
    glPushMatrix;
    glTranslatef(-1.0 + (canvas/3), 0.0, 0.0);
    glCallList(surroundTexture);
    glPopMatrix;
    glPushMatrix;
    glTranslatef(0.0, 0.0, 0.0);
    glCallList(surroundTexture);
    glPopMatrix;
    glPushMatrix;
    glTranslatef(1.0 - (canvas/3), 0.0, 0.0);
    glCallList(surroundTexture);
    glPopMatrix;
    % Close the OpenGL rendering context
    %Screen('EndOpenGL', win);
    %Screen('Flip', win);
    %KbWait;
    %sca;
    glEnable(GL.BLEND);
    glBlendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);
end