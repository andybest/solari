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
    public var material: Material
    
    public let radius: Scalar
    private let radiusSquared: Scalar
    
    public init() {
        self.init(radius: 2.0)
    }
    
    public init(radius: Scalar) {
        self.material = Material()
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


public struct Plane: Renderable {
    public var transform: Transform
    public var material: Material
    
    public init() {
        transform = Transform()
        material = Material()
    }
    
    public func getIntersection(intersection: inout IntersectionResult, ray: Ray) -> Bool {
        let normal = Vector3(0, 1, 0)
        let denom = normal.dot(ray.direction)
        if denom > Scalar.epsilon {
            let p0l0 = transform.position - ray.origin
            let t = p0l0.dot(normal) / denom
            
            intersection.distance = t
            intersection.position = ray.origin + (ray.direction * t)
            intersection.normal = normal
            return t >= 0
        }
        
        return false
    }
}

private func intersectTriangle(v0: Vector3, v1: Vector3, v2: Vector3, intersection: inout IntersectionResult, uvs: inout Vector2, ray: Ray) -> Bool {
    let v0v1 = v1 - v0
    let v0v2 = v2 - v0
    let pvec = ray.direction.cross(v0v2)
    let det = v0v1.dot(pvec)
    
    // Single sided
    //if det < Scalar.epsilon { return false }
    
    // Double sided
    if fabs(det) < Scalar.epsilon { return false }
    
    let invDet = 1.0 / det
    let tvec = ray.origin - v0
    let u = tvec.dot(pvec) * invDet
    
    // Check side bounds
    if u < 0 || u > 1 { return false }
    
    let qvec = tvec.cross(v0v1)
    let v = ray.direction.dot(qvec) * invDet
    
    // Check top/bottom bounds
    if v < 0 || u + v > 1 { return false }
    
    let t = v0v2.dot(qvec) * invDet
    
    intersection.distance = t
    uvs.x = u
    uvs.y = v
    
    return true
}

public func generatePolySphere(radius: Scalar, divisions: Int) -> TriangleMesh {
    let numVertices = (divisions - 1) * divisions + 2
    var vertices = [Vector3](repeating: Vector3.zero, count: numVertices)
    var normals = [Vector3](repeating: Vector3.zero, count: numVertices)
    var st = [Vector2](repeating: Vector2.zero, count: numVertices)
    
    var u = -Scalar.halfPi
    var v = -Scalar.pi
    let du = Scalar.pi / Scalar(divisions)
    let dv = 2 * Scalar.pi / Scalar(divisions)
    
    vertices[0] = Vector3(0, -radius, 0)
    normals[0] = Vector3(0, -radius, 0)
    var k = 1
    for _ in 0..<(divisions - 1) {
        u += du
        v = -Double.pi
        
        for _ in 0..<divisions {
            let x = radius * cos(u) * cos(v)
            let y = radius * sin(u)
            let z = radius * cos(u) * sin(v)
            vertices[k] = Vector3(x, y, z)
            normals[k] = Vector3(x, y, z)
            st[k].x = u / Scalar.pi + 0.5
            st[k].y = v * 0.5 / Scalar.pi + 0.5
            v += dv
            k += 1
        }
    }
    
    vertices[k] = Vector3(0, radius, 0)
    normals[k] = Vector3(0, radius, 0)
    
    let numPolys = divisions * divisions
    var faceIndex = [Int](repeating: 0, count: numPolys)
    var vertsIndex = [Int](repeating: 0, count: ((6 + (divisions - 1) * 4) * divisions))
    
    var vid = 1
    var numV = 0
    var l = 0
    k = 0
    
    for i in 0..<divisions {
        for j in 0..<divisions {
            if i == 0 {
                faceIndex[k] = 3
                k += 1
                vertsIndex[l] = 0
                vertsIndex[l + 1] = j + vid
                vertsIndex[l + 2] = (j == (divisions - 1)) ? vid : j + vid + 1
                l += 3
            } else if i == (divisions - 1) {
                faceIndex[k] = 3
                k += 1
                vertsIndex[l] = j + vid + 1 - divisions
                vertsIndex[l + 1] = vid + 1
                vertsIndex[l + 2] = (j == (divisions - 1)) ? vid + 1 - divisions : j + vid + 2 - divisions
                l += 3
            } else {
                faceIndex[k] = 4
                k += 1
                vertsIndex[l] = j + vid + 1 - divisions
                vertsIndex[l + 1] = j + vid + 1
                vertsIndex[l + 2] = (j == (divisions - 1)) ? vid + 1 : j + vid + 2
                vertsIndex[l + 3] = (j == (divisions - 1)) ? vid + 1 - divisions : j + vid + 2 - divisions
                l += 4
            }
            numV += 1
        }
        vid = numV
    }
    
    return TriangleMesh(numFaces: numPolys, faceIndex: faceIndex, vertsIndex: vertsIndex, verts: vertices, normals: normals, st: st)
}

public struct Triangle: Renderable {
    public var transform: Transform
    public var material: Material
    
    private var v0: Vector3
    private var v1: Vector3
    private var v2: Vector3
    
    public init() {
        transform = Transform()
        material = Material()
        
        v0 = Vector3.zero
        v1 = Vector3.zero
        v2 = Vector3.zero
    }
    
    public init(v0: Vector3, v1: Vector3, v2: Vector3) {
        transform = Transform()
        material = Material()
        
        self.v0 = v0
        self.v1 = v1
        self.v2 = v2
    }
    
    public func getIntersection(intersection: inout IntersectionResult, ray: Ray) -> Bool {
        var uvs = Vector2.zero
        return intersectTriangle(v0: v0 * transform.rotation + transform.position,
                                 v1: v1 * transform.rotation + transform.position,
                                 v2: v2 * transform.rotation + transform.position,
                                 intersection: &intersection,
                                 uvs: &uvs,
                                 ray: ray)
    }
}

public struct TriangleMesh: Renderable {
    
    public var transform: Transform
    public var material: Material
    
    private var numTris: Int
    private let vertices: [Vector3]
    private let trisIndex: [Int]
    private let normals: [Vector3]
    private let texCoords: [Vector2]
    
    public init() {
        transform = Transform()
        material = Material()
        
        numTris = 0
        vertices = [Vector3]()
        trisIndex = [Int]()
        normals = [Vector3]()
        texCoords = [Vector2]()
    }
    
    public init(numFaces: Int, faceIndex: [Int], vertsIndex: [Int], verts: [Vector3], normals normal: [Vector3], st: [Vector2]) {
        transform = Transform()
        material = Material()
        material.surfaceColor = Vector3(1, 0, 0)
        
        var k = 0
        var maxVertIndex = 0
        numTris  = 0
        
        for i in 0..<numFaces {
            numTris += faceIndex[i] - 2
            for j in 0..<faceIndex[i] {
                if vertsIndex[k + j] > maxVertIndex {
                    maxVertIndex = vertsIndex[k + j]
                }
            }
            k += faceIndex[i]
        }
        maxVertIndex += 1
        
        var P = [Vector3](repeating: Vector3.zero, count: maxVertIndex)
        for i in 0..<maxVertIndex {
            P[i] = verts[i]
        }
        
        var trisIndex = [Int](repeating: 0, count: numTris * 3)
        var N = [Vector3](repeating: Vector3.zero, count: numTris * 3)
        var texCoords = [Vector2](repeating: Vector2.zero, count: numTris * 3)
        var l = 0
        k = 0
        for i in 0..<numFaces {
            for j in 0..<(faceIndex[i] - 2) {
                trisIndex[l] = vertsIndex[k]
                trisIndex[l + 1] = vertsIndex[k + j + 1]
                trisIndex[l + 2] = vertsIndex[k + j + 2]
                /*N[l] = normal[k]
                N[l + 1] = normal[k + j + 1]
                N[l + 2] = normal[k + j + 2]
                texCoords[l] = st[k]
                texCoords[l + 1] = st[k + j + 1]
                texCoords[l + 2] = st[k + j + 2]*/
                l += 3
            }
            k += faceIndex[i]
        }
        
        self.vertices = P
        self.trisIndex = trisIndex
        self.normals = N
        self.texCoords = texCoords
    }
    
    public func getIntersection(intersection: inout IntersectionResult, ray: Ray) -> Bool {
        var j = 0
        var didIntersect = false
        var triIndex = 0
        
        var nearest = Scalar.greatestFiniteMagnitude
        var uvOut = Vector2.zero
        
        for i in 0..<numTris {
            let v0 = vertices[trisIndex[j]] * transform.rotation + transform.position
            let v1 = vertices[trisIndex[j + 1]] * transform.rotation + transform.position
            let v2 = vertices[trisIndex[j + 2]] * transform.rotation + transform.position
            
            var triIntersection = IntersectionResult(distance: 0, position: Vector3.zero, normal: Vector3.zero)
            var uvs = Vector2.zero
            
            if intersectTriangle(v0: v0, v1: v1, v2: v2, intersection: &triIntersection, uvs: &uvs, ray: ray) {
                if triIntersection.distance < nearest {
                    nearest = triIntersection.distance
                    uvOut = uvs
                    triIndex = i
                    didIntersect = true
                }
            }
            j += 3
        }
        
        if didIntersect {
            intersection.distance = nearest
            let n0 = vertices[trisIndex[triIndex * 3]]
            let n1 = vertices[trisIndex[triIndex * 3 + 1]]
            let n2 = vertices[trisIndex[triIndex * 3 + 2]]
            intersection.normal = (n1 - n0).cross(n2 - n0).normalized()
            intersection.position = ray.origin + (ray.direction * nearest)
        }
        
        return didIntersect
    }
}






