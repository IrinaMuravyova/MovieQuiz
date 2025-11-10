//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Irina Muravyeva on 07.11.2025.
//

import Foundation

final class StatisticService: StatisticServiceProtocol {
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        case gamesCount
        case bestGameCorrect
        case bestGameTotal
        case bestGameDate
        case totalCorrectAnswers
        case totalQuestionsAsked
    }
    
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue )
        }
        set {
            let currentCount = storage.integer(forKey: Keys.gamesCount.rawValue)
            let newGamesCount = currentCount + 1
            storage.set(newGamesCount, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        get {
            let totalCorrectAnswers: Int = storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
            let totalQuestionsAsked: Int = storage.integer(forKey: Keys.totalQuestionsAsked.rawValue)
            
            if totalQuestionsAsked == 0 {
                return 0
            } else {
                return Double(totalCorrectAnswers) / Double(totalQuestionsAsked) * 100
            }
        }
    }
    
    func store(game: GameResult) {
        let lastTotalCorrectAnswers: Int =  storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        let lastTotalQuestionsAsked: Int = storage.integer(forKey: Keys.totalQuestionsAsked.rawValue)
        
        let newTotalCorrectAnswers = lastTotalCorrectAnswers + game.correct
        let newTotalQuestionsAsked = lastTotalQuestionsAsked + 10
        
        storage.set(newTotalCorrectAnswers, forKey: Keys.totalCorrectAnswers.rawValue)
        storage.set(newTotalQuestionsAsked, forKey: Keys.totalQuestionsAsked.rawValue)
      
        gamesCount += 1
        
        if game.isBetterThan(bestGame) {
            bestGame = game
        }
    }
}
