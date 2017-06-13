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

public struct Sphere: Renderable {
    
    public var transform: Transform
    public var surfaceColor: Vector3
    
    public let radius: Scalar
    private let radiusSquared: Scalar
    
    public init() {
        self.init(radius: 2.0)
    }
    
    public init(radius: Scalar) {
        self.surfaceColor = Vector3(1, 0, 0)
        self.transform = Transform()
        self.radius = radius
        self.radiusSquared = radius + radius
    }
    
    public func getIntersection(intersection: inout IntersectionResult, ray: Ray) -> Bool {
        let L = transform.position - ray.origin
        
        let tca = L.dot(ray.direction)
        if tca < 0 { return false }
        
        let d2 = L.dot(L) - tca * tca
        if d2 > radiusSquared { return false }
        
        let thc = sqrt(radiusSquared - d2)
        var t0 = tca - thc
        var t1 = tca + thc
        
        if t0 > t1 { swap(&t0, &t1) }
        if t0 < 0 {
            t0 = t1
            if t0 < 0 { return false }
        }
        
        let t = t0
        intersection.distance = t
        intersection.position = ray.origin + (ray.direction.normalized() * t)
        intersection.normal = (intersection.position - transform.position).normalized()
        return true
    }
}
