#version 330 core

/*
    This vertex shader is probably the most simple vertex shader we can imagine because we
    did no processing whatsoever on the input data and simply forwarded it to the shader’s output. In
    real applications the input data is usually not already in normalized device coordinates so we first
    have to transform the input data to coordinates that fall within OpenGL’s visible region.
*/

// The Vertex Shader handles each vertex attribute, i.e position, one by one.
// Therefore we have to point it to the beginning of the buffer.

layout (location = 0) in vec3 position;// position is a vertex attribute. We can have many vertex attributes

void main()
{
    gl_PointSize = 200.0f;
    /*  To set the output of the vertex shader we have to assign the position data to the predefined
        gl_Position variable which is a vec4 behind the scenes. At the end of the main function,
        whatever we set gl_Position to will be used as the output of the vertex shader. */
    gl_Position = vec4(position.x, position.y, position.z, 1.0); // fourth param is used for 'Perspective Division'
}