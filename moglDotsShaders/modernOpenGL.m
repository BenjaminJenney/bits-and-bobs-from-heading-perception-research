sizeofFloat = 4;
 sizeofDouble = 8;
 InitializeMatlabOpenGL(1);
 global GL;
 Screen('Preference', 'SkipSyncTests', 1);
 screenNumber = 0; 
 [window, windowRect] = Screen('OpenWindow', screenNumber);

% vertices currently only contains position information %
vertices = [
    %point1        point2       point3
    single(-0.25), single(0.0), single(0.25),
    single(0.0),  single(0.0), single(0.0),    
    single(0.25),   single(0.0),  single(0.0)
];

 %dim = 10;
 %[x, y, z] = meshgrid(-dim:.3:dim, -dim:.3:dim, -dim:.3:dim);
 %numDots = numel(x);

%  dotPositionMatrix = [reshape(x, 1, numDots); reshape(y, 1, numDots); reshape(z, 1, numDots)];
%  dotSizes = rand(1, numDots) .* 20 + 10;
 
ifi = Screen('GetFlipInterval', window);

Screen('BeginOpenGL', window);
glEnable(GL_PROGRAM_POINT_SIZE)
VAO = glGenVertexArrays(1);
VBO = glGenBuffers(1);

glBindVertexArray(VAO); % BIND VERTEX ARRAY BEFORE VERTEX BUFFER OBJECT!!!! 

glBindBuffer(GL.ARRAY_BUFFER, VBO);
glBufferData(GL.ARRAY_BUFFER, sizeof(vertices), vertices, GL.STATIC_DRAW);

glVertexAttribPointer(0, 3, GL.FLOAT, GL.FALSE, 3 * sizeofFloat, 0);
glEnableVertexAttribArray(0); % This HAS to be enabled, yet its not enabled by default.

% note that this is allowed, the call to glVertexAttribPointer registered VBO as the vertex attribute's bound vertex buffer object so afterwards we can safely unbind
glBindBuffer(GL_ARRAY_BUFFER, 0); 

% You can unbind the VAO afterwards so other VAO calls won't accidentally modify this VAO, but this rarely happens. Modifying other
% VAOs requires a call to glBindVertexArray anyways so we generally don't unbind VAOs (nor VBOs) when it's not directly necessary.
glBindVertexArray(0);


cycPerSec = .01;
angle = 0;
u_phase = 0;
phaseIncrement = cycPerSec * 360 * ifi;
%%%%%%%%%%%Uniforms%%%%%%%%%%%%%%%%%%
u_freq = 1/360;
u_amplitude = 0.5;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fragShaderPath = 'C:\Users\benje\Desktop\openGLMatlab\fragmentShader.frag';
vertShaderPath = 'C:\Users\benje\Desktop\openGLMatlab\vertexShader.vert';
glsl = LoadGLSLProgramFromFiles({fragShaderPath, vertShaderPath});
u_freqLoc = glGetUniformLocation(glsl, 'u_freq');
u_amplitudeLoc = glGetUniformLocation(glsl, 'u_amplitude');
u_phaseLoc = glGetUniformLocation(glsl, 'u_phase');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
while ~KbCheck
    glClearColor(0.2,0.3,0.3,1.0);
    glClear(GL.COLOR_BUFFER_BIT);
    
    u_phase = u_phase + phaseIncrement;
    glUseProgram(glsl); % Updating a uniform requires that we use, i.e bind, the shaderProgram    
    
    glUniform1f(u_freqLoc, u_freq);
    glUniform1f(u_amplitudeLoc, u_amplitude);
    glUniform1f(u_phaseLoc, u_phase);
    glBindVertexArray(VAO);
    glDrawArrays(GL.POINTS, 0, 3);
    
    Screen('EndOpenGL', window);
    Screen('Flip', window); 
    Screen('BeginOpenGL', window);
end
sca;















    





