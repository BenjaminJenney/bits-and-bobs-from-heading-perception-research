// GLSL VERTEX SHADER
#version 120
uniform mat4 u_mv;
void main ()
{
    gl_Position = u_mv * gl_Vertex;
}