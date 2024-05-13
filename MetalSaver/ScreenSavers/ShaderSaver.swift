//
//  ShaderSaver.swift
//  MetalSaver
//
//  Created by Jake Cariello on 5/10/24.
//

import Foundation

//
//  PhysicsSaver.swift
//  MetalSaver
//
//  Created by Jake Cariello on 5/6/24.
//


import Foundation
import ScreenSaver
import SceneKit

///  simple SceneKit demo that renders 50 randomly placed rotating `SCNBox`es
class ShaderSaver: ScreenSaverView {

    var t: CGFloat = 0.0
    let view = SCNView()
    let period: CGFloat = 10

    fileprivate func setupCamera(for scene: SCNScene) {
//        let node = SCNNode().at(.up.scaled(by: 5))
        let node = SCNNode.at(.up.scaled(by: 4))
//        let node: SCNNode = .at(.zero)
        node.camera = SCNCamera()
        node.camera!.fieldOfView = 60
        node.camera!.grainIntensity = 5
//        node.camera!.zNear = 0.01
//        node.look(at: .zero)
//        let v = (simd_float3(.left) + simd_float3(.up)) / 2
//        node.look(at: SCNVector3(x: CGFloat(v.x), y: CGFloat(v.y), z: CGFloat(v.z)))
        node.constraints = [SCNLookAtConstraint(target: .at(.zero))]
        node.runAction(.repeatForever(.rotateBy(x: 0, y: 2 * .pi, z: 0, duration: 10)))
       
        scene.add(node)
    }

    fileprivate func setupLighting(for scene: SCNScene) {
        let omni = SCNNode()
        omni.light = SCNLight()
        omni.light!.type = .omni
        omni.position = SCNVector3(x: 3, y: 3, z: 5)
        scene.add(node: omni)

        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light!.type = .ambient
        ambient.light!.intensity = 100
        ambient.light!.temperature = 4500
        scene.add(node: ambient)
    }

    fileprivate func setupMaterial(for geometry: SCNGeometry) {
        let material = SCNMaterial()

        // Multicolor with Randomization
//        material.diffuse.contents = NSColor.yellow

        // Shiny
        material.specular.contents = NSColor.lightGray // White for strong shine
        material.shininess = 1.0 // Control the sharpness of highlights

        // SCNShaderModifierEntryPointGeometry or SCNShaderModifierEntryPointSurface
        let shaderModifier = """
        mat2 rot2(float a) {
            float s = sin(a), c = cos(a);
            return mat2(c, -s, s, c);
        }

        vec3 hsl2rgb(vec3 c)
        {
            vec3 rgb = clamp(abs(fmod(c.x * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0);
            return c.z + c.y * (rgb - 0.5) * (1.0 - abs(2.0 * c.z - 1.0));
        }

        float line(vec2 point, float slope, vec2 pos) {
            return slope * (pos.x - point.x) + (pos.y - point.y);
        }

        float curve(vec2 pos, float power) {
            return pow(pos.x , power) - pos.y;
        }

        float hash21(vec2 p) {
            p = fract(p*vec2(123.234, 234.34));
            p += dot(p, p + 213.42);
            return fract(p.x * p.y);
        }

        #pragma opaque
        #pragma body
        float ZOOM = 10.0;
        float PI = 3.141592653589793;
        // pixel uv (-.5 to .5)
        // vec2 uv = (1. - (sin(u_time) / 10.)) * ZOOM * _surface.diffuseTexcoord;
        vec2 uv = ZOOM * (_surface.diffuseTexcoord + 0.5);
        
        // oscillating param for "power" of the curve
        // use uv magnitude to shift phase
        float powerParam = sin(u_time / 1. + (length(uv) / 10.)); // 0 to 1;
        
        // along an abs val "V" curve (min: 1, max: 6)
        float power = 2. * abs(powerParam - .5) + 1.;
        
        // when param = .5, then power = 0, so flip the coords for symmetric appearance
        bool flipAxes = powerParam < .5;
        if (flipAxes) {
            uv.xy = uv.yx;
        }
        
        // generate id and modulus (x, y) for each curve cell
        vec2 id = floor(uv);
        vec2 check = fmod(id, 2.);
        
        // define curve space as fractional component of uv (this does the tiling)
        vec2 st = fract(uv);
        
        // id offset flips for every other (x, y) id value (x, y independent of each other)
        vec2 signs = vec2(1.);
        if (check.x >= 1.) {
            st.x = 1. - st.x;
            signs.x = -1.;
        }
        if (check.y >= 1.) {
            st.y = 1. - st.y;
            signs.y = -1.;
        }
        
        // calculate curve value [0, inf)
        float c = curve(st, power);
        
        // shift id to be that of cell we are inside (i.e., which side of curve 0-crossing we are on)
        // this was kind of finnicky, and i found the right combo by trial-and-error
        id.x += sign(signs.x) * sign(c) * .5;
        id.y -= sign(signs.y) * sign(c) * .5;
        if (flipAxes) id.xy = id.yx; // need to flip to follow uv
        
        // compute cell color as function of time and id hash
        // note that the lightness value is slightly augmented by the curve value
        vec3 col = hsl2rgb(vec3(sin(2. * PI * (hash21(id.xy) + u_time / 20.)), 0.8, 0.7 + .2 * abs(c)));

        // step to black when curve value near 0
        col *= smoothstep(.03, .05, abs(c));
        
        _surface.diffuse = vec4(col, 1.0);
        //_surface.diffuse = vec4(_surface.diffuseTexcoord, 0.0, 1.0);
        """
        
        let geometryShader = """
        #pragma body
        float PI = 3.141592653589793;
        float waveFactor = 0.05 * sin(((length((_geometry.texcoords[0].xy - 0.5) * 10.) / 2 * PI) + 5.0 * u_time));
        _geometry.position.xyz += _geometry.normal * waveFactor;
        """

        // Assign the shader modifier to a material
        material.shaderModifiers = [.surface: shaderModifier, .geometry: geometryShader]



        geometry.materials = [material]
    }

    fileprivate func buildScene() -> SCNScene {
        let scene = SCNScene()
        setupCamera(for: scene)
        setupLighting(for: scene)
        

        let inner = SCNNode(geometry: SCNTorus(ringRadius: 1, pipeRadius: 0.15)).at(.zero)
        setupMaterial(for: inner.geometry!)
//        inner.runAction(.rotateBy(x: 0, y: 2 * .pi / 3, z: 0, duration: 0))
        inner.transform = SCNMatrix4Mult(inner.transform, SCNMatrix4MakeRotation(-2 * .pi / 3, 0, 1, 0))
        inner.runAction(.repeatForever(.rotateBy(x: -2 * .pi, y: 0, z: 0, duration: period)))
        scene.add(node: inner)

        let middle = SCNNode(geometry: SCNTorus(ringRadius: 1.5, pipeRadius: 0.15)).at(.zero)
        middle.runAction(.repeatForever(.rotateBy(x: 0, y: 0, z: 2 * .pi, duration: period)))
        setupMaterial(for: middle.geometry!)
        scene.add(node: middle)

        let outer = SCNNode(geometry: SCNTorus(ringRadius: 2, pipeRadius: 0.15)).at(.zero)
//        inner.runAction(.rotateBy(x: 0, y: -2 * .pi / 3, z: 0, duration: 0))
        outer.transform = SCNMatrix4Mult(outer.transform, SCNMatrix4MakeRotation(2 * .pi / 3, 0, 1, 0))
        outer.runAction(.repeatForever(.rotateBy(x: 2 * .pi, y: 0, z: 0, duration: period)))
        setupMaterial(for: outer.geometry!)
        scene.add(node: outer)




        return scene
    }

    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        addSubview(view)

        /// set up basic view sizing
        view.frame = bounds
        view.autoresizingMask = [.width, .height]

        /// set up graphics
//        view.allowsCameraControl = true
//        view.showsStatistics = true
        view.backgroundColor = .darkGray
        view.scene = buildScene()



    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: NSRect) {
        super.draw(rect)

    }
}
