//
//  ObjLoaderTests.swift
//  solariTests
//
//  Created by Andy Best on 15/06/2017.
//

import Foundation
import XCTest
import Nimble
@testable import solari

class ObjLoaderTests: XCTestCase {
    
    func genTestFile() {
        expect {
            try ObjLoaderTestFile.writeFileToDisk(fileContents: ObjLoaderTestFile.teapot, fileName: "teapot.obj")
            }.notTo(throwError())
    }
    
    func testObjLoaderThrowsExceptionForMissingFile() {
        expect { try ObjLoader.loadObjFile(filePath: "thisDoesNotExist") }.to(throwError())
    }
    
    func testObjLoaderLoadsFileCorrectly() {
        genTestFile()
        
        expect { try ObjLoader.loadObjFile(filePath: "teapot.obj") }.notTo(throwError())
    }
    
    func testObjLoaderLoadsVertex() {
        let input = "v -3.000000 1.800000 0.000000"
        var vertex: Vector3 = Vector3.zero
        
        expect { vertex = try ObjLoader.parseVertex(input: input) }.notTo(throwError())
        expect(vertex).to(beCloseTo(Vector3(-3, 1.8, 0)))
    }
    
    func testObjLoaderThrowsErrorForMalformedVertex() {
        let malformedDouble = "v -3.000a00 1.800000 0.000000"
        expect { _ = try ObjLoader.parseVertex(input: malformedDouble) }.to(throwError())
        
        let malformedVertex = "v -3.000000 1.800000"
        expect { _ = try ObjLoader.parseVertex(input: malformedVertex) }.to(throwError())
    }
    
    func testObjLoaderLoadsFaceIndex() {
        let input = "f 1234 4321 7"
        var index = [Int]()
        
        expect { index = try ObjLoader.parseFaceIndex(input: input) }.notTo(throwError())
        
        expect(index).to(equal([1234, 4321, 7]))
    }
    
    func testObjLoaderThrowsErrorForMalformedFaceIndex() {
        let malformedInt = "f 1234a 4321 7"
        expect { _ = try ObjLoader.parseFaceIndex(input: malformedInt) }.to(throwError())
        
        let malformedFaceIndex = "f 1234 4321"
        expect { _ = try ObjLoader.parseFaceIndex(input: malformedFaceIndex) }.to(throwError())
    }
    
    /*static var allTests: [(String, (TypesTests) -> () -> Void)] = [
        ("testTransformUp", testTransformUp),
        ]*/
}
