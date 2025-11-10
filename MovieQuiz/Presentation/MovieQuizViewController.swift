import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    private let questionsAmount = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestionModel?
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    // MARK: - Constants
    private let borderWidth = CGFloat(8)
    private let cornerRadius = CGFloat(20)
    private let resultTitle = "Этот раунд окончен!"
    private let resultText = "Ваш результат: "
    private let resultButtonText = "Сыграть ещё раз"
    
    private let alertPresenter = AlertPresenter()
    private let statisticService: StatisticServiceProtocol = StatisticService()
    
    // MARK: - IBOutlets
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        let questionFactory = QuestionFactory()
        questionFactory.setDelegate(self)
        self.questionFactory = questionFactory
        self.questionFactory?.requestNextQuestion()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestionModel?) {
        guard let question = question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: - Private functions
    private func convert(model: QuizQuestionModel) -> QuizStepViewModel {
        QuizStepViewModel(
            image: model.image,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = UIImage(named: step.image)
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        buttonsIsEnable(true)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = borderWidth
        imageView.layer.borderColor = isCorrect ?
            UIColor(named: "YP Green")?.cgColor : UIColor(named: "YP Red")?.cgColor
        imageView.layer.cornerRadius = cornerRadius
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResult()
            self.resetImageBorder()
        }
        
        if isCorrect {
            correctAnswers += 1
        }
    }
    
    private func showNextQuestionOrResult() {
        if currentQuestionIndex == questionsAmount - 1 {
            let text = resultText + "\(correctAnswers)/\(questionsAmount)"
            let viewModel = QuizResultsViewModel(
                title: resultTitle,
                text: text,
                buttonText: resultButtonText
            )
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        statisticService.store(game: GameResult(correct: correctAnswers, total: 10, date: Date()))
        let gamesCount = statisticService.gamesCount
        
        let currentResultText = result.text + "\n"
        let gamesCountText = "Количество сыгранных квизов: \(gamesCount)\n"
        let recordText = "Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) \(statisticService.bestGame.date.dateTimeString)\n"
        let accuracyText = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        let message = currentResultText + gamesCountText + recordText + accuracyText
        
        let model = AlertModel(
            title: result.title,
            message: message,
            buttonText: result.buttonText) { [weak self] in
                guard let self = self else { return }
                self.restartGame()
            }
        alertPresenter.show(in: self, model: model)
    }
    
    private func resetImageBorder() {
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = nil
    }
    
    private func buttonsIsEnable(_ onToggle: Bool) {
        if onToggle {
            noButton.isEnabled = true
            yesButton.isEnabled = true
        } else {
            noButton.isEnabled = false
            yesButton.isEnabled = false
        }
    }
    
    private func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    // MARK: - IBActions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        yesButton.isHighlighted = true
        buttonsIsEnable(false)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        buttonsIsEnable(false)
    }
}
