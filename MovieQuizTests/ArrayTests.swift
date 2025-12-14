//
//  ArrayTests.swift
//  MovieQuizTests
//
//  Created by Irina Muravyeva on 08.12.2025.
//

import XCTest
@testable import MovieQuiz

class ArrayTests: XCTestCase {
    func testGetValueInRange() throws {
        // Given
        let array = [0, 1, 2, 3, 4]
        
        // When
        let value = array[safe: 2]
        
        // Then
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 2)
    }
    
    func testGetValueOutOfRange() throws {
        // Given
        let array = [0, 1, 2, 3, 4]
        
        // When
        let value = array[safe: 8]
        
        // Then
        XCTAssertNil(value)
    }
}
