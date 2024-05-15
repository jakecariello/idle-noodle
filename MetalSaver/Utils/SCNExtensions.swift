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
    static let origin = SCNVector3(0, 0, 0)

    /// Creates a unit vector pointing in the positive X direction (1, 0, 0).
    static let i = SCNVector3(1, 0, 0)

    /// Creates a unit vector pointing in the positive Y direction (0, 1, 0).
    static let j = SCNVector3(0, 1, 0)

    /// Creates a unit vector pointing in the positive Z direction (0, 0, 1).
    static let k = SCNVector3(0, 0, 1)

    /// Create a new vector multiplied by a scalar
    func scaled(by factor: CGFloat) -> SCNVector3 {
        return SCNVector3(x * factor, y * factor, z * factor)
    }

    func normalized() -> SCNVector3 {
        return SCNVector3(simd_normalize(SIMD3<Float>(Float(x), Float(y), Float(z))))
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

    /// Returns self with its position modified to the specified vector.
    ///
    /// - Parameter position: The new position for the copied node.
    /// - Returns: A copy of the node with its position modified to the given `position`.
    func at(_ position: SCNVector3) -> SCNNode {
        self.position = position
        return self
    }

    /// Creates a new `SCNNode` with the specified geometry.
    ///
    /// - Parameter geometry: The geometry to assign to the new node.
    /// - Returns: A new `SCNNode` instance containing the given geometry.
    static func with(_ geometry: SCNGeometry) -> SCNNode {
        let newNode = SCNNode()
        newNode.geometry = geometry
        return newNode
    }

    func orient(along vector: SCNVector3) {
        let normalizedVector = vector.normalized()

        // Handle special case where vector is pointing straight up or down
        if normalizedVector.x == 0 && normalizedVector.y == 0 {
            if normalizedVector.z > 0 {
                self.simdOrientation = simd_quatf(angle: 0, axis: SIMD3<Float>(0, 1, 0)) // No rotation needed if pointing up
            } else {
                self.simdOrientation = simd_quatf(angle: .pi, axis: SIMD3<Float>(0, 1, 0)) // 180-degree rotation if pointing down
            }
            return
        }

        // Calculate projection onto XZ plane and its angle from the positive X-axis
        let xzProjection = SCNVector3(normalizedVector.x, 0, normalizedVector.z)
        let xzAngle = atan2(xzProjection.z, xzProjection.x)

        // First rotation around Y-axis to align with xzProjection
        let rotationAroundY = simd_quatf(angle: Float(xzAngle), axis: SIMD3<Float>(0, 1, 0))

        // Second rotation around X-axis to align Z-axis with vector
        let angleFromXZ = acos(normalizedVector.y)
        let rotationAroundX = simd_quatf(angle: Float(angleFromXZ), axis: SIMD3<Float>(1, 0, 0))

        // Combine rotations (order matters!)
        self.simdOrientation = rotationAroundX * rotationAroundY
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

extension SCNTorus {
    /// Updates the `pipeSegmentCount` and `ringSegmentCount`
    ///
    /// - Parameters:
    ///   - pipe: The number of segments along the torus's pipe (minor circumference).
    ///   - ring: The number of segments around the torus's ring (major circumference).
    /// - Returns: A `SCNTorus` instance with the specified segment counts.
    func segmentedBy(_ pipe: Int, and ring: Int) -> SCNTorus {
        pipeSegmentCount = pipe
        ringSegmentCount = ring
        return self
    }
}


extension SCNMaterial {

    /// Creates a copy of this material and applies the given shader modifiers.
    ///
    /// - Parameter shaders: A dictionary of shader entry points and their corresponding code.
    /// - Returns: A new material with the modifiers applied.
    func modified(by shaders: [SCNShaderModifierEntryPoint: String]) -> SCNMaterial {
        let modifiedMaterial = self.copy() as! SCNMaterial
        modifiedMaterial.shaderModifiers = shaders
        return modifiedMaterial
    }

    /// Creates a new material with the specified shader modifiers.
    ///
    /// - Parameter shaders: A dictionary of shader entry points and their corresponding code.
    /// - Returns: A new material with the modifiers applied.
    static func modified(with shaders: [SCNShaderModifierEntryPoint: String]) -> SCNMaterial {
        let material = SCNMaterial()
        material.shaderModifiers = shaders
        return material
    }
}
