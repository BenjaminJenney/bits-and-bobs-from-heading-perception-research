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