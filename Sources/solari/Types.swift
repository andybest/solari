/*
 
 MIT License
 
 Copyright (c) 2017 Andy Best
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 
 */

import Foundation

// MARK : - Ray

public struct Ray {
    let origin: Vector3
    let direction: Vector3
}

// MARK: - Intersection

public struct IntersectionResult {
    var distance: Scalar
    var position: Vector3
    var normal: Vector3
}

// MARK: - Transform

public struct Transform {
    public var position: Vector3
    public var rotation: Quaternion
    
    public init() {
        position = Vector3.zero
        rotation = Quaternion(axisAngle: Vector4(Vector3.up.x, Vector3.up.y, Vector3.up.z, 0))
    }
    
    public var up: Vector3 {
        return Vector3.up * rotation
    }
    
    public mutating func rotate(axis: Vector3, angle: Double) {
        rotation = rotation * Quaternion(axisAngle: Vector4(axis.x, axis.y, axis.z, angle))
    }
}

// MARK: - SceneObject

public protocol SceneObject {
    var transform: Transform { get set }
    init()
}

// MARK: - Renderable

public protocol Renderable: SceneObject {
    var surfaceColor: Vector3 { get set }
    
    func getIntersection(intersection: inout IntersectionResult, ray: Ray) -> Bool
}

// MARK: - Light

public protocol Light: SceneObject {
    var intensity: Scalar { get set }
}
