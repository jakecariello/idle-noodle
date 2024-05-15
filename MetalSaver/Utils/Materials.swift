//
//  Materials.swift
//  MetalSaver
//
//  Created by Jake Cariello on 5/14/24.
//


import Foundation
import SceneKit

struct Materials {
    static let fade: SCNMaterial = .modified(
        with: [.surface: """
                #pragma transparent
                #pragma body
                vec4 bodyColor = vec4(0.6, 0.4, 1.0, 1.0); // Pale blue for the body

                float yCoord = _surface.diffuseTexcoord.y;

                _surface.diffuse = bodyColor;
                _surface.transparent.a = pow(1.0 - yCoord, 2.0);
            """])
    
    static var red: SCNMaterial = {
        let material = SCNMaterial()
        material.diffuse.contents = NSColor.red
        return material
    }()
    
    static var blue: SCNMaterial = {
        let material = SCNMaterial()
        material.diffuse.contents = NSColor(calibratedRed: 0.6, green: 0.4, blue: 1.0, alpha: 1.0)
        return material
    }()
}
