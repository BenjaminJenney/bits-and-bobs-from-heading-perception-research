float twopi = 2.0 * 3.141592654;

float deg2rad = 3.141592654 / 180.0;

uniform float u_phase;
uniform float u_freq;
uniform float u_amplitude;
void main(void)
{
   float posx = gl_Vertex.x;
    float posy = gl_Vertex.y;
    float phase = deg2rad * u_phase;
    float freqTwoPi = u_freq * twopi;
    float sv = sin(posx * freqTwoPi + u_phase) + cos(posy * freqTwoPi + u_phase);
    gl_FrontColor = vec4(sv,0.0,0.0,1.0);
    gl_Position   = gl_ModelViewProjectionMatrix * gl_Vertex;
}

