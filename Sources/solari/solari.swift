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

public struct Solari {
    public static func render(scene: Scene, width: Int, height: Int) -> [UInt32] {
        let pixelStep = scene.camera.filmWidth / Double(640)
        let halfWidth = Double(640) / 2.0
        let halfHeight = Double(480) / 2.0
        
        var pixelArr = [UInt32](repeating: 0, count: width * height)
        
        pixelArr.withUnsafeMutableBytes { pixels in
            for y in 0..<height {
                let yHeight = (Double(y) - halfHeight) * pixelStep
                for x in 0..<width {
                    let pixelPosition = Vector3((Double(x) - halfWidth) * pixelStep, yHeight, scene.camera.focalLength)
                    let rayDir = pixelPosition.normalized() * scene.camera.transform.rotation
                    let ray = Ray(origin: Vector3.zero, direction: rayDir)
                    
                    pixels.storeBytes(of: renderPixel(x: x, y: y, ray: ray, scene: scene),
                                      toByteOffset: (x + (y * width)) * MemoryLayout<UInt32>.stride,
                                      as: UInt32.self)
                }
            }
        }
        
        return pixelArr
    }
    
    private static func renderPixel(x: Int, y: Int, ray: Ray, scene: Scene) -> UInt32 {
        var intersection = IntersectionResult(distance: 0, position: Vector3.zero, normal: Vector3.zero)
        var didIntersect = false
        var closestDist = Scalar.greatestFiniteMagnitude
        var closestObject: Renderable?
        
        for o in scene.renderableObjects {
            if o.getIntersection(intersection: &intersection, ray: ray) {
                didIntersect = true
                if intersection.distance < closestDist {
                    closestDist = intersection.distance
                    closestObject = o
                }
            }
        }
        
        if didIntersect {
            let color = closestObject!.surfaceColor
            
            return 0xFF000000 | UInt32(color.x * 255.0) << 16 | UInt32(color.y * 255.0) << 8 | UInt32(color.z * 255.0)
        }
        
        return 0xFF000000
    }
}
