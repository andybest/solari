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

public struct Camera: SceneObject {
    public var transform: Transform
    public var filmWidth: Scalar
    public var focalLength: Scalar
    
    public init() {
        transform = Transform()
        transform.rotation = Quaternion(axisAngle: Vector4(0, 1, 0, 0))
        transform.position.z = 0
        
        filmWidth = 0.035
        focalLength = 0.05
    }
}

public struct Foo {
    private var testInt:[Int] = [Int]()
    public var test: [Int] {
        return testInt
    }
}

public struct Scene {
    public var camera = Camera()
    
    public var renderables: [Renderable] = [Renderable]()
    public var renderableObjects: [Renderable] {
        return renderables
    }
    
    private var lights: [Light] = [Light]()
    public var sceneLights: [Light] {
        return lights
    }
    
    public init() {
        
    }
    
    public mutating func addRenderable(_ r: Renderable) {
        renderables.append(r)
    }
    
    public mutating func addLight(_ l: Light) {
        lights.append(l)
    }
}
