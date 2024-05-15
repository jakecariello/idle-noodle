//
//  Geometries.swift
//  MetalSaver
//
//  Created by Jake Cariello on 5/14/24.
//

import Foundation
import SceneKit


struct Nodes {
    static func pin(sphereRadius: CGFloat = 0.25, coneHeight: CGFloat = 2.0, sphereMaterials: [SCNMaterial], coneMaterials: [SCNMaterial]) -> SCNNode {
        let sphere = SCNSphere(radius: sphereRadius)
        sphere.materials = sphereMaterials
        let cone = SCNCone(topRadius: sphereRadius, bottomRadius: 0, height: coneHeight)
        cone.materials = coneMaterials
        return pin(with: sphere, and: cone)
    }
    
    static func pin(with sphere: SCNSphere, and cone: SCNCone) -> SCNNode {
        let sphereNode = SCNNode(geometry: sphere)
        let coneNode = SCNNode(geometry: cone)
        coneNode.position = SCNVector3(0, cone.height / 2, 0) // Position cone tip at (0, 0, 0)
        sphereNode.position = SCNVector3(0, cone.height, 0) // Position sphere relative to cone tip
        let stickNode = SCNNode()
        stickNode.addChildNode(sphereNode)
        stickNode.addChildNode(coneNode)

        return stickNode
    }
}
