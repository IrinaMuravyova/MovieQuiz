//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Irina Muravyeva on 04.11.2025.
//

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestionModel?)
}
