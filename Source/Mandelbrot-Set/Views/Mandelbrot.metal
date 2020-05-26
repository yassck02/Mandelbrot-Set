//
//  MandelbrotShader.metal
//  mandelbrot-set
//
//  Created by Connor yass on 1/14/19.
//  Copyright © 2019 HSY_Technologies. All rights reserved.
//

#include <metal_stdlib>
#include <metal_math>

using namespace metal;

struct Mandelbrot {
    uint exponent;
    uint iterations;
};

struct ComplexNumber {
    float real;
    float imaginary;
    
    ComplexNumber(float r = 0, float i = 0) {
        real = r;
        imaginary = i;
    }
    
    float normal() {
        return real * real + imaginary * imaginary;
    }
};

float CalculateMandelbrot(ComplexNumber c, int iterations)
{
    int i = 0;
    
    ComplexNumber z = ComplexNumber(0, 0);
    ComplexNumber tmp;
    
    while(i < iterations) {
        tmp.real = z.real * z.real - z.imaginary * z.imaginary + c.real;
        tmp.imaginary = 2 * z.real * z.imaginary + c.imaginary;
        
        if(tmp.normal() > 16) {
            return 10 * i / float(iterations);
        } else {
            z = tmp;
            i++;
        }
    }
    return 0.0;
}

vertex float4 vertex_shader(const device float2* verticies [[ buffer(0) ]],
                            const unsigned int i           [[ vertex_id ]])
{
    return float4(verticies[i], 0.0, 1.0);
}


fragment half4 fragment_shader(const float4 position      [[ position  ]],
                               const device Mandelbrot& M [[ buffer(0) ]])
{
    ComplexNumber c = ComplexNumber(x, y);
    
    float tmp = CalculateMandelbrot(c, M.iterations);
    
    if (tmp > 2.0) {
        return half4(0.0, 0.0, 0.0, 1.0);
    } else {
        float gradientCount = 3; //float(P.gradientCount);
        
        float n = tmp / 4.0;
        
        int lower_index = floor((gradientCount-1) * n);
        int upper_index = ceil((gradientCount-1) * n);
        
        float lower_pos = float(lower_index) / (gradientCount-1);
        float upper_pos = float(upper_index) / (gradientCount-1);
        
        float percent = 0.0;
        if(n != lower_pos && upper_pos != lower_pos) {
            percent = (n - lower_pos) / (upper_pos - lower_pos);
        }
        
        return half4(1, 1, 1, 1);
    }
}
