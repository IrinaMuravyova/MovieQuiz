//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Irina Muravyeva on 11.12.2025.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }
    
    func testYesButton() {
        sleep(10)
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["Yes"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        
        let indexLabel = app.staticTexts["Index"]
        
        sleep(10)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testNoButton() {
        sleep(10)
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        sleep(6)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        
        let indexLabel = app.staticTexts["Index"]
        
        sleep(10)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testGameFinish() {
        sleep(10)
        
        (1 ... 10).forEach {_ in
            let image = app.images["Poster"]
            XCTAssertTrue(image.waitForExistence(timeout: 6))
            
            app.buttons["Yes"].tap()
        }
        
        let alert = app.alerts["Game Result"]
        XCTAssertTrue(alert.waitForExistence(timeout: 3))
        
        XCTAssertTrue(alert.exists)
        XCTAssertTrue(alert.label == "Этот раунд окончен!")
        XCTAssertTrue(alert.buttons.firstMatch.label == "Сыграть ещё раз")
    }
    
    func testAlertDissmis() {
        sleep(10)
 
        for _ in 0 ..< 10 {
            let image = app.images["Poster"]
            XCTAssertTrue(image.waitForExistence(timeout: 6))
            app.buttons["Yes"].tap()
        }

        let alert = app.alerts["Game Result"]
        
        XCTAssertTrue(alert.waitForExistence(timeout: 5))

        let restartButton = alert.buttons.matching(identifier: "RestartButton").firstMatch
        XCTAssertTrue(restartButton.waitForExistence(timeout: 5))
        restartButton.tap()
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertFalse(alert.exists)
        XCTAssertTrue(indexLabel.waitForExistence(timeout: 2))
        XCTAssertEqual(indexLabel.label, "1/10")
    }
    
    @MainActor
    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
    }
}
