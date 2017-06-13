//
//  typesTests.swift
//  solariTests
//
//  Created by Andy Best on 13/06/2017.
//

import XCTest
import Nimble
@testable import solari

class TypesTests: XCTestCase {
    
    func testTransformRotate() {
        var t = Transform()
        
        t.rotate(axis: Vector3(0, 1, 0), angle: Scalar.quarterPi)
        
        let (pitch, yaw, roll) = t.rotation.toPitchYawRoll()
        expect(pitch).to(beCloseTo(0))
        expect(yaw).to(beCloseTo(Scalar.quarterPi))
        expect(roll).to(beCloseTo(0))
    }
    
    func testTransformUp() {
        var t = Transform()
        // Rotate so up should be forward
        t.rotate(axis: Vector3(1, 0, 0), angle: Scalar.halfPi)
        
        let up = t.up
        expect(up).to(beCloseTo(Vector3(0, 0, 1), within: Scalar.epsilon))
    }
    
    static var allTests: [(String, (TypesTests) -> () -> Void)] = [
        ("testTransformUp", testTransformUp),
        ]
}
