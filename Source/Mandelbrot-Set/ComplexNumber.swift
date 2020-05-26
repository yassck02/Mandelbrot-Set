//
//  Fractal.swift
//  mandelbrot
//
//  Created by Connor yass on 9/16/17.
//  Copyright © 2017 Connor_yass. All rights reserved.
//

struct ComplexNumber {
    
    var real: Double
    var imaginary: Double
    
    func normal() -> Double{
        return real * real + imaginary * imaginary;
    }
}

func *(lhs: ComplexNumber, rhs: ComplexNumber) -> ComplexNumber {
    return ComplexNumber(
        real: lhs.real * rhs.real - lhs.imaginary * rhs.imaginary,
        imaginary: lhs.real * rhs.imaginary + lhs.imaginary * rhs.real
    );
}

func +(lhs: ComplexNumber, rhs: ComplexNumber) -> ComplexNumber {
    return ComplexNumber(
        real: lhs.real + rhs.real,
        imaginary: lhs.imaginary + rhs.imaginary
    )
}

func ^(lhs: ComplexNumber, rhs: Int) -> ComplexNumber {
    var temp = lhs
    for _ in 1 ... rhs { temp = temp * temp }
    return temp
}
