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
    let tStep: Float = 0.04

    struct Noise {
        static let frequency = 0.3

        static let octaveCount = 2
        static let persistence = 0.6
        static let lacunarity = 5.0
        static func seed() -> Int32 { Int32(GKRandomSource().nextInt()) }
        static func createNoise(withJitter: Double) -> GKNoise {
            let jitterAmplitude = 0.1 // only use increments of 0.1
            let jitter = GKRandomDistribution(lowestValue: -Int(jitterAmplitude * 10), highestValue: Int(jitterAmplitude * 10)).nextUniform() / 10
            let jitteredFrequency = frequency * (1.0 + Double(jitter))
            return GKNoise(GKPerlinNoiseSource(
                frequency: frequency * jitteredFrequency, // Use jittered frequency
                octaveCount: octaveCount,
                persistence: persistence,
                lacunarity: lacunarity,
                seed: seed()
            ))
        }
        static func create(_ counts: CGSize, _ size: CGSize, with noise: GKNoise, at time: Float) -> GKNoiseMap {
            // Circle parameters
            let radius: Double = Double(size.height) / 4.0 // Adjust the radius as needed
//            let center = vector_double2(Double(size.width) / 2.0, Double(size.height) / 2.0)

            // Calculate origin coordinates based on time
            let angle = Double(time) // Adjust the speed as needed
            let origin: vector_double2 = radius * vector_double2(cos(angle), sin(angle))

            return GKNoiseMap(
                    noise,
                    size: vector_double2(Double(size.width), Double(size.height)),
                    origin: origin, // Use the calculated circular origin
                    sampleCount: vector_int2(Int32(counts.width), Int32(counts.height)),
                    seamless: true
                )
        }
    }

    var xNoise = Noise.createNoise(withJitter: 0.2)
    var yNoise = Noise.createNoise(withJitter: 0.2)

    var xNoiseMap: GKNoiseMap?
    var yNoiseMap: GKNoiseMap?

    /// number of rows and cols of cylinders
    let counts = CGSize(width: 80, height: 40)
    /// dimensions of cylinders plane section
    let dimensions = CGSize(width: 12, height: 7.5)
    /// 2D array for cylinder nodes
    var cylinders: [[SCNNode]] = []
    let radius: CGFloat = 0.05
    let height: CGFloat = 0.75

    private func setupCamera(for scene: SCNScene) {
        let node = SCNNode().at(.k.scaled(by: 6))
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

    override func animateOneFrame() {
        super.animateOneFrame()

        t += tStep // Control the speed of animation

        xNoiseMap = Noise.create(counts, dimensions, with: xNoise, at: t)
        yNoiseMap = Noise.create(counts, dimensions, with: yNoise, at: t)


        for row in 0 ..< Int(counts.height) {
            for col in 0 ..< Int(counts.width) {
                let node = cylinders[row][col]


                guard let x = xNoiseMap?.value(at: vector_int2(Int32(col), Int32(row))) else { return }
                guard let y = yNoiseMap?.value(at: vector_int2(Int32(row), Int32(col))) else { return }

                let lengthScaled = pow(simd_length(simd_float2(x, y)), sqrt(2) / 2)
                let xRotation = simd_quatf(angle: x * .pi / 4.0, axis: SIMD3<Float>(1, 0, 0))
                let yRotation = simd_quatf(angle: y * .pi / 4.0, axis: SIMD3<Float>(0, 1, 0))


                let combinedRotation = simd_mul(xRotation, yRotation)
//                node.simdWorldOrientation = simd_slerp(node.simdWorldOrientation, simd_quatf(real: combinedRotation.real, imag: -combinedRotation.imag), 1.0)
                node.simdWorldOrientation = simd_mul(combinedRotation, simd_quatf(angle: .pi / 2, axis: SIMD3<Float>(1, 0, 0)))
//                node.simdOrientation =

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

        xNoise = { Noise.createNoise(withJitter: 0.1) }()
        yNoise = { Noise.createNoise(withJitter: 0.1) }()
//        lazy var zNoise: GKNoiseMap = { Noise.create(counts, dimensions) }()
//        lazy var xNoise2: GKNoiseMap = { Noise.create(counts, dimensions) }()
//        lazy var yNoise2: GKNoiseMap = { Noise.create(counts, dimensions) }()
//        lazy var zNoise2: GKNoiseMap = { Noise.create(counts, dimensions) }()




    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: NSRect) {
        super.draw(rect)
    }
}
