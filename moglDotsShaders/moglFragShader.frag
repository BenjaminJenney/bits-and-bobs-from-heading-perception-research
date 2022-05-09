float twopi = 2.0 * 3.141592654;

float deg2rad = 3.141592654 / 180.0;

//out vec4 FragColor;

uniform float u_phase;
uniform float u_freq;
uniform float u_amplitude;
void main()
{
    vec3 baseColor = vec3( 0.5, 0.5, 0.5 );
    float posx = gl_FragCoord.x;
    float posy = gl_FragCoord.y;
    float phase = deg2rad * u_phase;
    float freqTwoPi = u_freq * twopi;
    float sv = sin(posx * freqTwoPi + u_phase) + cos(posy * freqTwoPi + u_phase);
    gl_FragColor = vec4(sv,0.0,0.0,1.0);
}