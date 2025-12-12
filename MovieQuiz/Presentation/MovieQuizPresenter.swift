//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Irina Muravyeva on 12.12.2025.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    let questionsAmount: Int = 10
    
    private let resultTitle = "Этот раунд окончен!"
    private let resultText = "Ваш результат: "
    private let resultButtonText = "Сыграть ещё раз"
    
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewController?
    private var currentQuestionIndex: Int = 0
    
    var currentQuestion: QuizQuestionModel?
    var correctAnswers = 0
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        
        questionFactory = QuestionFactory(
            moviesLoader: MoviesLoader(),
            delegate: self
        )
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestionModel?) {
        guard let question = question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
        
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
        
    func didFailToLoadData(with error: any Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - Public functions
    func convert(model: QuizQuestionModel) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func showNextQuestionOrResult() {
        if self.isLastQuestion() {
            let text = resultText + "\(correctAnswers)/\(self.questionsAmount)"
            let viewModel = QuizResultsViewModel(
                title: resultTitle,
                text: text,
                buttonText: resultButtonText
            )
            viewController?.show(quiz: viewModel)
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        
        let givenAnswer = isYes
        
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}
