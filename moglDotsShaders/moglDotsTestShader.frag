
uniform float u_time;
float pi = 3.14159;
//out vec4 FragColor;

void main()
{
    vec3 blah = abs(sin(2*pi*.01 * u_time + 2));
    //vec3 color = ;
    gl_FragColor = (blah, 1.0); // Uniforms are global across shaders??
}