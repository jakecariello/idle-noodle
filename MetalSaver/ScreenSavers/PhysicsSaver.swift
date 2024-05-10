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
class PhysicsSaver: ScreenSaverView {

    var t: CGFloat = 0.0
    let gravityStrength: Float = 0.4
    let view = SCNView()
    let attractorNode = SCNNode()

    fileprivate func setupCamera(for scene: SCNScene) {
        let node = SCNNode()
        node.camera = SCNCamera()
        node.position = SCNVector3(0, 0, 10)
        scene.rootNode.addChildNode(node)
    }

    fileprivate func setupLighting(for scene: SCNScene) {
        let node = SCNNode()
        node.light = SCNLight()
        node.light!.type = .omni
        node.position = SCNVector3(x: 3, y: 3, z: 5)
        scene.rootNode.addChildNode(node)
    }

    fileprivate func setupMaterial(for geometry: SCNGeometry) {
        let material = SCNMaterial()

        // Multicolor with Randomization
        material.diffuse.contents = createRandomColor()

        // Shiny
        material.specular.contents = NSColor.white // White for strong shine
        material.shininess = 1.0 // Control the sharpness of highlights

        // Bumpy (Using a Normal Map)
//        let normalMapImage = NSImage(named: "Asphalt_1")
        let normalMapImage = Bundle(for: type(of: self)).image(forResource: "Asphalt_1")
        material.normal.contents = normalMapImage
        material.normal.intensity = 0.5 // Adjust the strength of the bump effect


        let shader = """
        #pragma body
        float waveFactor = 0.03 * sin(1.0 * (20.0 * abs(length(_geometry.texcoords[0].xy - 0.5)) + 5.0 * u_time));
        _geometry.position.xyz += _geometry.normal * waveFactor;
        """

        material.shaderModifiers = [SCNShaderModifierEntryPoint.geometry: shader]

        geometry.materials = [material]
    }

    // Helper to generate random color
    private func createRandomColor() -> NSColor {
        let r = CGFloat.random(in: 0...1)
        let g = CGFloat.random(in: 0...1)
        let b = CGFloat.random(in: 0...1)
        return NSColor(red: r, green: g, blue: b, alpha: 1.0)
    }

    fileprivate func buildScene() -> SCNScene {
        let scene = SCNScene()
        setupCamera(for: scene)
        setupLighting(for: scene)

        let geometry = SCNSphere(radius: 0.5)

        let count = 50
        for _ in 0..<count {
            /// - copy the geometry for each node so that we can later assign separate materials
            /// - this is not memory efficient -- ideally we could do the color selection in a shader that
            ///   can generate a unique random color for each geometry instance
            let node = SCNNode(geometry: SCNSphere(radius: 0.5))
            node.position = SCNVector3(
                x: SSRandomFloatBetween(-10, 10),
                y: SSRandomFloatBetween(-5, 5),
                z: 0)

            setupMaterial(for: node.geometry!)

            /// - same note here about memory efficiency, though this one is unavoidable
            let physicsBody = SCNPhysicsBody(
                type: .dynamic,
                shape: nil)
            physicsBody.isAffectedByGravity = false
            physicsBody.mass = 1.0
            physicsBody.restitution = 0.5
            node.physicsBody = physicsBody
            scene.rootNode.addChildNode(node)
        }

        let osc = SCNNode(geometry: (geometry.copy() as? SCNGeometry))
        osc.physicsBody = SCNPhysicsBody(
            type: .static,
            shape: SCNPhysicsShape(geometry: geometry)
        )
        osc.physicsBody!.restitution = 10.0

        /// PATHS!
        let xMax: Double = 5
        osc.runAction(
                .repeatForever(
                    .sequence([
                        .move(to: SCNVector3(x: -xMax, y: 0, z: 0), duration: 5),
                        .move(to: SCNVector3(x: xMax, y: 0, z: 0), duration: 5),
                        .customAction(duration: 5.0) { node, elapsedTime in
                            let percentage = elapsedTime / CGFloat(5.0)
                            let angle: Double = percentage * CGFloat(2 * Double.pi)
                            let x = xMax * cos(angle)
                            let y = 5 * sin(angle)
                            node.position = SCNVector3(x, y, 0) // Adjust for Z if needed
                        }
                ])
            )
        )



        scene.rootNode.addChildNode(osc)
        let customField = SCNPhysicsField.customField(evaluationBlock: { position, velocity, mass, charge, time in
            let distance: Float = simd_length(simd_float3(position))
            let uncappedForceMagnitude = 20.0 / (distance * distance)

            let maxAcceleration: Float = 0.1
            let cappedForceMagnitude = min(uncappedForceMagnitude, maxAcceleration * mass)

            return SCNVector3(-cappedForceMagnitude * simd_normalize(simd_float3(position)))
        })

        let gravityNode = SCNNode()
        gravityNode.position = SCNVector3(x: 0, y: 0, z: 0)
        gravityNode.physicsField = customField

        scene.rootNode.addChildNode(gravityNode)





        return scene
    }

    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)

        view.frame = bounds
        view.autoresizingMask = [.width, .height]
        addSubview(view)

        view.scene = buildScene()
        view.allowsCameraControl = true
        view.showsStatistics = true
        view.backgroundColor = NSColor.black

        attractorNode.position = SCNVector3(0, 0, 0)

    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: NSRect) {
        super.draw(rect)

    }

    override func startAnimation() {
        super.startAnimation()
    }

    override func stopAnimation() {
        super.stopAnimation()
    }

    override func animateOneFrame() {
        setNeedsDisplay(bounds)
    }

}
