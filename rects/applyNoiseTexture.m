function applyNoiseTexture(GL)

    %PsychDefaultSetup(2);
    glEnable(GL.TEXTURE_2D);

    wall_texid = glGenTextures(1);
    halfTextureSize = 256; % in px for meshgrid
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
    %glEnable(GL.BLEND);
    %glBlendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);
    glBindTexture(GL.TEXTURE_2D,  wall_texid);
    %glEnable(GL.POINT_SPRITE);
    glTexParameterfv(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.REPEAT);
    glTexParameterfv(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.REPEAT);
    glTexParameterfv(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
    glTexParameterfv(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
    glTexImage2D(GL.TEXTURE_2D, 0, GL.RGBA, halfTextureSize*2, halfTextureSize*2, 0, GL.RGBA, GL.UNSIGNED_BYTE, noys);
    glTexEnvfv(GL.TEXTURE_ENV, GL.TEXTURE_ENV_MODE, GL.MODULATE);
   % glTexEnvi(GL.POINT_SPRITE, GL.COORD_REPLACE, GL.TRUE);
    %glDisable(GL.BLEND);
    %disp('aliased point size: ' + glGetFloatv(GL.ALIASED_POINT_SIZE_RANGE));
    corners = [ 
        0 0;
        1 0;
        1 1;
        0 1 
     ];
%     for i = 1:4
%         glTexCoord2dv(corners(i,:));
%     end
end