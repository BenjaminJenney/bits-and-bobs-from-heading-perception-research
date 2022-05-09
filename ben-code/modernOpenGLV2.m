sizeofFloat = 4;
 
 InitializeMatlabOpenGL(1);
 global GL;
 Screen('Preference', 'SkipSyncTests', 1);
 screenNumber = 0; 
 [window, windowRect] = Screen('OpenWindow', screenNumber);

% vertices currently only contains position information %
vertices = [
    single(0.5), single(0.5), single(0.0), single(1.0), single(1.0),  % vertex 1
    single(0.5),  single(-0.5), single(0.0), single(1.0), single(0.0), % vertex 2
    single(-0.5),  single(-0.5), single(0.0), single(0.0), single(0.0),% vertex 3
    single(-0.5), single(0.5), single(0.0),  single(0.0), single(1.0),
];

    indices = [
        uint8(0), uint8(1), uint8(3), % first triangle
        uint8(1), uint8(2), uint8(3)  % second triangle
    ];

Screen('BeginOpenGL', window);

VAO = glGenVertexArrays(1);
VBO = glGenBuffers(1);
EBO = glGenBuffers(1);

glBindVertexArray(VAO); % BIND VERTEX ARRAY BEFORE VERTEX BUFFER OBJECT!!!! 

glBindBuffer(GL.ARRAY_BUFFER, VBO);
glBufferData(GL.ARRAY_BUFFER, length(vertices), vertices, GL.STATIC_DRAW);

glBindBuffer(GL.ELEMENT_ARRAY_BUFFER, EBO);
glBufferData(GL.ELEMENT_ARRAY_BUFFER, length(indices), indices, GL.STATIC_DRAW);

%position attributes
glVertexAttribPointer(0, 3, GL.FLOAT, GL.FALSE, 5 * sizeofFloat, 0);
glEnableVertexAttribArray(0); % This HAS to be enabled, yet its not enabled by default.

%texture coord attributes
glVertexAttribPointer(1,2, GL.FLOAT, GL.FALSE, 5 * sizeofFloat, 3*sizeofFloat);
glEnableVertexAttribArray(1);

% Load and create Texture
textureID = glGenTextures(1);
glBindTexture(GL.TEXTURE_2D, textureID);
textureData = animatedPlaidTextureSeries;
glTexParameterfv(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.REPEAT);
glTexParameterfv(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.REPEAT);
glTexParameterfv(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
glTexParameterfv(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
glTexImage2D(GL.TEXTURE_2D, 0, GL.RGB, 201, 201, 0, GL.RGB, GL.FLOAT, textureData(:,:,1));
glGenerateMipmap(GL.TEXTURE_2D);


% note that this is allowed, the call to glVertexAttribPointer registered VBO as the vertex attribute's bound vertex buffer object so afterwards we can safely unbind
%glBindBuffer(GL_ARRAY_BUFFER, 0); 

% You can unbind the VAO afterwards so other VAO calls won't accidentally modify this VAO, but this rarely happens. Modifying other
% VAOs requires a call to glBindVertexArray anyways so we generally don't unbind VAOs (nor VBOs) when it's not directly necessary.
%glBindVertexArray(0);

%%%%%%%%%%%TEXTURES%%%%%%%%%%%%%%%%%%
%imgData = imread('C:\Users\benje\Desktop\openGLMatlab\brick-texture');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fragShaderPath = 'C:\Users\benje\Desktop\openGLMatlab\fragmentShader.frag';
vertShaderPath = 'C:\Users\benje\Desktop\openGLMatlab\vertexShader.vert';
glsl = LoadGLSLProgramFromFiles({fragShaderPath, vertShaderPath});
%vertexColorLocation = glGetUniformLocation(glsl, 'u_color');
glUniform1i(glGetUniformLocation(glsl, 'ourTexture'), 0);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
while ~KbCheck
    glClearColor(0.2,0.3,0.3,1.0);
    glClear(GL.COLOR_BUFFER_BIT);
    
    
    timeValuef = single(GetSecs);
    greenValuef = single(sin(timeValuef) / 2.0 + 0.5);
    %glUniform4f(vertexColorLocation, single(0.0), greenValuef, single(0.0), single(1.0));
    glActiveTexture(GL.TEXTURE0);
    glBindTexture(GL.TEXTURE_2D, textureID);
    glUseProgram(glsl); % Updating a uniform requires that we use, i.e bind, the shaderProgram    
    glBindVertexArray(VAO);
    glDrawElements(GL.TRIANGLES, 6, GL.UNSIGNED_INT, 0);
    
    Screen('EndOpenGL', window);
    Screen('Flip', window); 
    Screen('BeginOpenGL', window);
end
sca;















    





