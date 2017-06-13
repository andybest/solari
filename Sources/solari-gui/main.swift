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
import solari
import CSDL2
import SDL

extension Optional {
    var sdlUnwrap: Wrapped {
        guard let value = self
            else { fatalError("SDL error: \(SDL.errorDescription ?? "")") }
        
        return value
    }
}

guard SDL.initialize(subSystems: [.video]) else {
    fatalError("Could not initialize SDL subsystems: \(SDL.errorDescription ?? "")")
}

let windowSize = (width: 640, height: 480)
let window = Window(title: "Solari",
                    frame: (x: .centered, y: .centered, width: windowSize.width, height: windowSize.height),
                    options: [.resizable, .shown]).sdlUnwrap
let fps = UInt(window.displayMode?.refresh_rate ?? 60)

let renderer = Renderer(window: window).sdlUnwrap
renderer.drawColor = (0xFF, 0xFF, 0xFF, 0xFF)

var isRunning = true
var event = SDL_Event()

var scene = Scene()
scene.camera.focalLength = 0.018

for _ in 0..<50 {
    var sphere = Sphere(radius: Scalar(arc4random() % 5))
    sphere.transform.position.x = Scalar(arc4random() % 20) - 10.0
    sphere.transform.position.y = Scalar(arc4random() % 20) - 10.0
    sphere.transform.position.z = Scalar(arc4random() % 50) - 25.0
    
    if abs(sphere.transform.position.z) < sphere.radius {
        sphere.transform.position.z += sphere.radius
    }
    sphere.surfaceColor = Vector3(Scalar(arc4random() % 255) / 255.0, Scalar(arc4random() % 255) / 255.0, Scalar(arc4random() % 255) / 255.0)
    
    scene.addRenderable(sphere)
}

while isRunning {
    SDL_PollEvent(&event)
    
    let eventType = SDL_EventType(rawValue: event.type)
    switch eventType {
    case SDL_QUIT, SDL_APP_TERMINATING:
        isRunning = false
    default:
        break
    }
    
    
    let renderedPixels = Solari.render(scene: scene, width: 640, height: 480)
    
    let imageSurface = Surface(rgb: windowSize, depth: 32).sdlUnwrap
    imageSurface.withUnsafeMutableBytes { pixels in
        for i in 0..<(windowSize.width * windowSize.height) {
            pixels.storeBytes(of: renderedPixels[i], toByteOffset: i * MemoryLayout<Int32>.stride, as: UInt32.self)
        }
    }
    
    scene.camera.transform.rotate(axis: Vector3.up, angle: Scalar.pi / 90.0)
    
    let texture = Texture(renderer: renderer, surface: imageSurface).sdlUnwrap
    
    renderer.clear()
    renderer.copy(texture, destination: SDL_Rect(x: 0, y: 0, w: Int32(windowSize.width), h: Int32(windowSize.height)))
    renderer.present()
    
    // sleep to save energy
    /*let frameDuration = SDL_GetTicks() - startTime
    if frameDuration < 1000 / framesPerSecond {
        SDL_Delay((1000 / UInt32(framesPerSecond)) - frameDuration)
    }*/
}
