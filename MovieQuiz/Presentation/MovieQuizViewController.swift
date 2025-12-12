import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    private var questionFactory: QuestionFactoryProtocol?
    private var correctAnswers = 0
    
    // MARK: - Constants
    private let borderWidth = CGFloat(8)
    private let cornerRadius = CGFloat(20)
    private let resultTitle = "Этот раунд окончен!"
    private let resultText = "Ваш результат: "
    private let resultButtonText = "Сыграть ещё раз"
    
    private let alertPresenter = AlertPresenter()
    private let statisticService: StatisticServiceProtocol = StatisticService()
    private let presenter = MovieQuizPresenter()
    
    // MARK: - IBOutlets
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let questionFactory = QuestionFactory(
            moviesLoader: MoviesLoader(),
            delegate: self
        )
        self.questionFactory = questionFactory
        presenter.viewController = self

        showLoadingIndicator()
        questionFactory.loadData()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestionModel?) {
        presenter.didReceiveNextQuestion(question: question)
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: any Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        buttonsIsEnable(true)
    }
    
    func showAnswerResult(isCorrect: Bool) {
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
    
    // MARK: - Private functions
    private func showNextQuestionOrResult() {
        if presenter.isLastQuestion() {
            let text = resultText + "\(correctAnswers)/\(presenter.questionsAmount)"
            let viewModel = QuizResultsViewModel(
                title: resultTitle,
                text: text,
                buttonText: resultButtonText
            )
            show(quiz: viewModel)
        } else {
            presenter.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        statisticService.store(game: GameResult(correct: correctAnswers, total: presenter.questionsAmount, date: Date()))
        let gamesCount = statisticService.gamesCount
        
        let currentResultText = result.text + "\n"
        let gamesCountText = "Количество сыгранных квизов: \(gamesCount)\n"
        let recordText = "Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))\n"
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
        presenter.resetQuestionIndex()
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать ещё раз") { [weak self] in
                guard let self = self else { return }
                
                presenter.resetQuestionIndex()
                correctAnswers = 0
                
                questionFactory?.requestNextQuestion()
            }
        alertPresenter.show(in: self, model: model)
    }
    
    // MARK: - IBActions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
        buttonsIsEnable(false)
    }
}
