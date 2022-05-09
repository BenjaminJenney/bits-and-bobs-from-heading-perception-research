#version 410 compatibility
in vec2 TexCoord; // From the geometry shader
uniform sampler2D SpriteTex;

void main()
{
    gl_FragColor = texture(SpriteTex, TexCoord);
}