//
//  SceneSaver.swift
//  MetalSaver
//
//  Created by Jake Cariello on 5/5/24.
//

import Foundation
import ScreenSaver
import SceneKit


class SceneSaver: ScreenSaverView {

    let materialCount = 10

    var t: CGFloat = 0.0

    let view = SCNView()

    fileprivate func buildMaterials() -> [SCNMaterial] {
        var materials = [SCNMaterial]()

        for _ in 0..<materialCount {
            let material = SCNMaterial()
            material.diffuse.contents = NSColor(
                deviceRed: SSRandomFloatBetween(0, 1),
                green: SSRandomFloatBetween(0, 1),
                blue: SSRandomFloatBetween(0, 1),
                alpha: SSRandomFloatBetween(0, 1))
            material.specular.contents = NSColor.white
            materials.append(material)
        }
//        geometry.firstMaterial = material
        return materials
    }


    // Helper function to generate random material index data
    fileprivate func generateMaterialIndexData(count: Int) -> Data {
        var data = Data(count: count * MemoryLayout<Float>.size)
        data.withUnsafeMutableBytes { (bytes: UnsafeMutableRawBufferPointer) -> Void in
            guard let floatPtr = bytes.baseAddress?.assumingMemoryBound(to: Float.self) else { return }
            for i in 0..<count {
                floatPtr[i] = Float.random(in: 0..<Float(1))
            }
        }
        return data
    }

    fileprivate func buildScene() -> SCNScene {
        let scene = SCNScene()
        let geometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.1)

        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0, 10)
        scene.rootNode.addChildNode(cameraNode)

        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 3, y: 3, z: 5)
        scene.rootNode.addChildNode(lightNode)

        let rotation = SCNAction.rotateBy(x: 3 * .pi, y: 2 * .pi, z: 0, duration: 7)
        let repeatRotation = SCNAction.repeatForever(rotation)


        let count = 50
        for _ in 0..<count {
            let boxNode = SCNNode(geometry: geometry)
            boxNode.position = SCNVector3(
                x: SSRandomFloatBetween(-10, 10),
                y: SSRandomFloatBetween(-5, 5),
                z: 0)
//            boxNode.runAction(repeatRotation)
            scene.rootNode.addChildNode(boxNode)
        }

        return scene
    }

    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        animationTimeInterval = 0.03


        view.frame = bounds
        view.autoresizingMask = [.width, .height]
        addSubview(view)

        view.scene = buildScene()
        view.allowsCameraControl = true
        view.showsStatistics = true
        view.backgroundColor = NSColor.black



    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: NSRect) {
        super.draw(rect)

    }

    override func startAnimation() {
        super.startAnimation()
        t = 0.0
    }


    override func stopAnimation() {
        super.stopAnimation()
    }

    override func animateOneFrame() {
        t += animationTimeInterval



        setNeedsDisplay(bounds)

    }
}
