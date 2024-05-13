//
//  SCNExtensions.swift
//  MetalSaver
//
//  Created by Jake Cariello on 5/11/24.
//

import Foundation
import SceneKit

extension SCNVector3 {
    /// Creates a zero vector (0, 0, 0).
    static let zero = SCNVector3(0, 0, 0)

    /// Created a unit vector pointing in the negative X direction (-1, 0, 0).
    static let left = SCNVector3(-1, 0, 0)

    /// Creates a unit vector pointing in the positive X direction (1, 0, 0).
    static let right = SCNVector3(1, 0, 0)

    /// Creates a unit vector pointing in the positive Y direction (0, 1, 0).
    static let up = SCNVector3(0, 1, 0)

    /// Creates a unit vector pointing in the positive Z direction (0, 0, 1).
    static let forward = SCNVector3(0, 0, 1)

    /// Creates a unit vector pointing in the negative Y direction (0, -1, 0).
    static let down = SCNVector3(0, -1, 0)

    /// Creates a unit vector pointing in the negative Z direction (0, 0, -1).
    static let back = SCNVector3(0, 0, -1)

    /// Create a new vector multiplied by a scalar
    func scaled(by factor: CGFloat) -> SCNVector3 {
        return SCNVector3(x * factor, y * factor, z * factor)
    }
}

extension SCNNode {

    /// Returns a new node with its position modified to the specified vector.
    ///
    /// - Parameter position: The new position for the copied node.
    /// - Returns: A copy of the node with its position modified to the given `position`.
    static func at(_ position: SCNVector3) -> SCNNode {
        let newNode = SCNNode()
        newNode.position = position
        return newNode
    }
    
    /// Returns a copy of the node with its position modified to the specified vector.
    ///
    /// - Parameter position: The new position for the copied node.
    /// - Returns: A copy of the node with its position modified to the given `position`.
    func at(_ position: SCNVector3) -> SCNNode {
        let newNode = self.copy() as! SCNNode
        newNode.position = position
        return newNode
    }
}

extension SCNScene {

    /// Adds a node as a child of the scene's root node.
    ///
    /// - Parameter node: The node to add to the root node.
    func add(node: SCNNode) {
        rootNode.addChildNode(node)
    }
    
    /// Adds a node as a child of the scene's root node.
    ///
    func add(_ node: SCNNode) {
        rootNode.addChildNode(node)
    }
}

