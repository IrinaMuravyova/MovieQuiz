//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Irina Muravyeva on 07.11.2025.
//

import Foundation

protocol StatisticServiceProtocol {
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    var totalAccuracy: Double { get }
    
    func store(game: GameResult)
}
