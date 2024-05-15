//
//  NoiseSaver.swift
//  MetalSaver
//
//  Created by Jake Cariello on 5/13/24.
//

import Foundation
import ScreenSaver
import SceneKit
import GameKit

///  simple SceneKit demo that renders 50 randomly placed rotating `SCNBox`es
class NoiseSaver: ScreenSaverView {

    let view = SCNView()

    var t: Float = 0.0
    let tStep: Float = 0.01

    struct Noise {
        static let frequency = 0.1
        static let octaveCount = 2
        static let persistence = 0.5
        static let lacunarity = 5.0
        static func seed() -> Int32 { Int32(GKRandomSource().nextInt()) }
        static func create(f frequencyMultiplier: Double) -> GKNoise {
            GKNoise(GKPerlinNoiseSource(
                frequency: frequency * frequencyMultiplier,
                octaveCount: octaveCount,
                persistence: persistence,
                lacunarity: lacunarity,
                seed: seed()
            ))
        }
    }

    var xNoise = Noise.create(f: 0.99)
    var yNoise = Noise.create(f: 1.03)
    var zNoise = Noise.create(f: 1.27)
    var xNoise2 = Noise.create(f: 0.95)
    var yNoise2 = Noise.create(f: 1.51)
    var zNoise2 = Noise.create(f: 1.39)


    let noiseSource = GKPerlinNoiseSource(
        frequency: Noise.frequency,
        octaveCount: Noise.octaveCount,
        persistence: Noise.persistence,
        lacunarity: Noise.lacunarity,
        seed: Noise.seed()
    )


    var noiseMap: GKNoiseMap?
    var noiseMapSize: CGSize?

    /// number of rows and cols of cylinders
    let counts = CGSize(width: 80, height: 40)
    /// dimensions of cylinders plane section
    let dimensions = CGSize(width: 12, height: 7.5)
    /// 2D array for cylinder nodes
    var cylinders: [[SCNNode]] = []
    let radius: CGFloat = 0.05
    let height: CGFloat = 0.75
    lazy var aspect: CGSize = {
        CGSize(width: dimensions.width / counts.width, height: dimensions.height / counts.height)
    }()

    private func setupCamera(for scene: SCNScene) {
        let node = SCNNode().at(.k.scaled(by: 5))
        node.camera = SCNCamera()
//        node.camera!.usesOrthographicProjection = true
//        node.camera!.orthographicScale = 3
        node.look(at: .origin)
        scene.add(node)
    }

    private func setupLighting(for scene: SCNScene) {
        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light!.type = .ambient
        ambient.light!.intensity = 100
        ambient.light!.temperature = 4500
        scene.add(node: ambient)
    }


    private func setupScene() -> SCNScene {
        let scene = SCNScene()
        setupCamera(for: scene)
        setupLighting(for: scene)

        let spacingX = dimensions.width / (counts.width - 1)
        let spacingY = dimensions.height / (counts.height - 1)

        var sphere: SCNSphere?
        var cone: SCNCone?
        for row in 0 ..< Int(counts.height) {
            var cylinderRow: [SCNNode] = []
            for col in 0 ..< Int(counts.width) {
                var node: SCNNode
                // for performance, reuse the sphere and cone geometries
                if let sphere, let cone {
                    node = Nodes.pin(with: sphere, and: cone)
                } else {
                    node = Nodes.pin(
                        sphereRadius: radius,
                        coneHeight: height,
                        sphereMaterials: [Materials.blue],
                        coneMaterials: [Materials.fade]
                    )
                    // Find child nodes for sphere and cone
                    sphere = node.childNodes.first(where: { $0.geometry is SCNSphere })!.geometry as? SCNSphere
                    cone = node.childNodes.first(where: { $0.geometry is SCNCone })!.geometry as? SCNCone

                }


                node.position = SCNVector3(
                    x: spacingX * CGFloat(col) - dimensions.width / 2,
                    y: spacingY * CGFloat(row) - dimensions.height / 2,
                    z: 0
                )
                node.simdLocalRotate(by: simd_quatf(angle: .pi / 2, axis: SIMD3<Float>(1, 0, 0)))
                scene.add(node)
                cylinderRow.append(node)
            }
            cylinders.append(cylinderRow)
        }

        return scene
    }

    func sampleNoise3D(at position: vector_float3) -> Float {
        let x = xNoise.value(atPosition: vector_float2(position.x, position.z))
        let y = yNoise.value(atPosition: vector_float2(-position.y, position.z))
        let z = zNoise.value(atPosition: vector_float2(position.z, -position.x)) // Note the different coordinate combinations
        return ((abs(x) + abs(y) + abs(z)) / 3.0) - (sqrt(2) / 2)
    }

    func sampleNoise3D2(at position: vector_float3) -> Float {
        let x = xNoise2.value(atPosition: vector_float2(position.x, position.z))
        let y = yNoise2.value(atPosition: vector_float2(position.y, position.z))
        let z = zNoise2.value(atPosition: vector_float2(position.z, position.x)) // Note the different coordinate combinations

        return (x + y + z) / 3.0
    }


    override func animateOneFrame() {
        super.animateOneFrame()

        t += tStep // Control the speed of animation

        for row in 0..<Int(counts.height) {
            for col in 0..<Int(counts.width) {
                let node = cylinders[row][col]

                // 2D noise positions (separate for x and y, z is constant)
                let noisePosition = vector_float3(
                    x: Float(col) * Float(aspect.width),
                    y: Float(row) * Float(aspect.height),
                    z: t
                )
                let x = sampleNoise3D(at: noisePosition)
                let y = sampleNoise3D2(at: noisePosition)

                let lengthScaled = pow(simd_length(simd_float2(x, y)) / (sqrt(2) / 2), 2)
                let xRotation = simd_quatf(angle: x * .pi, axis: SIMD3<Float>(1, 0, 0))
                let yRotation = simd_quatf(angle: y * .pi, axis: SIMD3<Float>(0, 1, 0))

                let combinedRotation = simd_mul(xRotation, yRotation)
                node.simdWorldOrientation = simd_slerp(node.simdWorldOrientation, simd_quatf(real: combinedRotation.real, imag: -combinedRotation.imag), 0.1)

                node.scale = SCNVector3(lengthScaled, lengthScaled, lengthScaled)

            }
        }
    }


    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        addSubview(view)

        /// set up basic view sizing
        view.frame = bounds
        view.autoresizingMask = [.width, .height]

        /// set up graphics
        view.allowsCameraControl = true
        view.showsStatistics = true
        view.backgroundColor = .black
        view.scene = setupScene()

//        noiseMapSize = CGSize(width: Int(counts.width), height: Int(counts.height))
//        noiseMap = GKNoiseMap(
//            GKNoise(noiseSource),
//            size: vector_double2(Double(noiseMapSize!.width), Double(noiseMapSize!.height)),
//            origin: vector_double2(0, 0),
//            sampleCount: vector_int2(Int32(noiseMapSize!.width), Int32(noiseMapSize!
//                .height)),
//            seamless: true
//        )



    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: NSRect) {
        super.draw(rect)
    }
}
