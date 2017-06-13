//
//  NimbleVectorMatchers.swift
//  solariTests
//
//  Created by Andy Best on 14/06/2017.
//

import Foundation
@testable import solari
import Nimble

// MARK: - Vector3

func beCloseTo(_ expectedValue: Vector3, within delta: Double = Scalar.epsilon) -> Predicate<Vector3> {
    return Predicate.define { actualExpression in
        let actual: Vector3? = try actualExpression.evaluate()
        return isCloseTo(actual, expectedValue: expectedValue, delta: delta)
    }
}

func isCloseTo(_ actualValue: Vector3?,
                expectedValue: Vector3,
                        delta: Double)
    -> PredicateResult {
        let errorMessage = "be close to <\(stringify(expectedValue))> (within \(stringify(delta)))"
        let xVal = abs(actualValue!.x - expectedValue.x) < delta
        let yVal = abs(actualValue!.y - expectedValue.y) < delta
        let zVal = abs(actualValue!.z - expectedValue.z) < delta
        
        return PredicateResult(
            bool: actualValue != nil &&
                xVal && yVal && zVal,
            message: .expectedCustomValueTo(errorMessage, "<\(stringify(actualValue))>")
        )
}


// MARK: - Vector4

func beCloseTo(_ expectedValue: Vector4, within delta: Double = Scalar.epsilon) -> Predicate<Vector4> {
    return Predicate.define { actualExpression in
        let actual: Vector4? = try actualExpression.evaluate()
        return isCloseTo(actual, expectedValue: expectedValue, delta: delta)
    }
}

func isCloseTo(_ actualValue: Vector4?,
               expectedValue: Vector4,
               delta: Double)
    -> PredicateResult {
        let errorMessage = "be close to <\(stringify(expectedValue))> (within \(stringify(delta)))"
        let xVal = abs(actualValue!.x - expectedValue.x) < delta
        let yVal = abs(actualValue!.y - expectedValue.y) < delta
        let zVal = abs(actualValue!.z - expectedValue.z) < delta
        let wVal = abs(actualValue!.w - expectedValue.w) < delta
        
        return PredicateResult(
            bool: actualValue != nil &&
                xVal && yVal && zVal && wVal,
            message: .expectedCustomValueTo(errorMessage, "<\(stringify(actualValue))>")
        )
}
