//
//  ObjLoader.swift
//  solariTests
//
//  Created by Andy Best on 15/06/2017.
//

import Foundation

public enum ObjLoaderError: Error {
    case malformedEntry(String)
}

public struct ObjModel {
    public let vertices: [Vector3]
    public let faces: [[Int]]
}

public struct ObjLoader {
    static func loadObjFile(filePath: String) throws -> String {
        return try String(contentsOfFile: filePath)
    }
    
    static func parseVertex(input: String) throws -> Vector3 {
        let components = input.split(separator: " ")
        
        if components.count != 4 {
            throw ObjLoaderError.malformedEntry("Malformed vertex: '\(input)'")
        }
        
        let coords = try components.dropFirst().map { i throws -> Double in 
            let coord = Double(String(i))
            if coord == nil {
                throw ObjLoaderError.malformedEntry("Malformed vertex: '\(input)'")
            }
            return coord!
        }
            
        return Vector3(coords[0], coords[1], coords[2])
    }
    
    static func parseFaceIndex(input: String) throws -> [Int] {
        let components = input.split(separator: " ")
        
        if components.count != 4 {
            throw ObjLoaderError.malformedEntry("Malformed face: '\(input)'")
        }
        
        let indices = try components.dropFirst().map { i throws -> Int in
            let idx = Int(String(i))
            if idx == nil {
                throw ObjLoaderError.malformedEntry("Malformed face: '\(input)'")
            }
            return idx!
        }
        
        return indices
    }
    
    public static func loadObj(fromFile filePath: String) throws -> ObjModel {
        var vertices = [Vector3]()
        var faces = [[Int]]()
        
        let lines = try loadObjFile(filePath: filePath).split(separator: "\n")
        
        for line in lines {
            
            if line.hasPrefix("v") {
                // Vertex
                let vert = try parseVertex(input: String(line))
                vertices.append(vert)
            } else if line.hasPrefix("f") {
                // Face
                let face = try parseFaceIndex(input: String(line))
                faces.append(face)
            }
        }
        
        return ObjModel(vertices: vertices, faces: faces)
    }
}
