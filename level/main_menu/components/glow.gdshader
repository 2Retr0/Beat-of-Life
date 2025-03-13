shader_type spatial;
render_mode unshaded, fog_disabled;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	//***********    Basic setup    **********
    
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = SCREEN_UV;
	// Position of fragment relative to centre of screen
    vec2 pos = 0.5 - uv;
    // Adjust y by aspect for uniform transforms
    pos.y /= VIEWPORT_SIZE.x/VIEWPORT_SIZE.y;
    
    //**********         Glow        **********
    
    // Equation 1/x gives a hyperbola which is a nice shape to use for drawing glow as 
    // it is intense near 0 followed by a rapid fall off and an eventual slow fade
    float dist = 1.0/length(pos);
    
    //**********        Radius       **********
    
    // Dampen the glow to control the radius
    dist *= 0.1;
    
    //**********       Intensity     **********
    
    // Raising the result to a power allows us to change the glow fade behaviour
    // See https://www.desmos.com/calculator/eecd6kmwy9 for an illustration
    // (Move the slider of m to see different fade rates)
    dist = pow(dist, 1.8);
    
    // Knowing the distance from a fragment to the source of the glow, the above can be 
    // written compactly as: 
    //	float getGlow(float dist, float radius, float intensity){
    //		return pow(radius/dist, intensity);
	//	}
    // The returned value can then be multiplied with a colour to get the final result
       
    // Add colour
    vec3 col = dist * vec3(1.0, 0.5, 0.25);
	
    // Tonemapping. See comment by P_Malin
    col = 1.0 - exp( -col );
    
    // Output to screen
    ALBEDO = col;// = vec4(col, 1.0);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
