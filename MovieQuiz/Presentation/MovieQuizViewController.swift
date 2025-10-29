import UIKit

final class MovieQuizViewController: UIViewController {
    private let questions = [
        QuizQuestionModel(
            image: "The Godfather",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ),
        QuizQuestionModel(
            image: "The Dark Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ),
        QuizQuestionModel(
            image: "Kill Bill",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ),
        QuizQuestionModel(
            image: "The Avengers",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ),
        QuizQuestionModel(
            image: "Deadpool",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ),
        QuizQuestionModel(
            image: "The Green Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ),
        QuizQuestionModel(
            image: "Old",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false
        ),
        QuizQuestionModel(
            image: "The Ice Age Adventures of Buck Wild",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false
        ),
        QuizQuestionModel(
            image: "Tesla",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false
        ),
        QuizQuestionModel(
            image: "Vivarium",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false
        )
    ]
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    // MARK: - Constants
    private let borderWidth = CGFloat(8)
    private let cornerRadius = CGFloat(20)
    private let resultTitle = "Этот раунд окончен!"
    private let resultText = "Ваш результат "
    private let resultButtonText = "Сыграть ещё раз"
    
    // MARK: - IBOutlets
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let firstQuestion = convert(model: questions[0])
        show(quiz: firstQuestion)
    }
    
    // MARK: - Private functions
    private func convert(model: QuizQuestionModel) -> QuizStepViewModel {
        QuizStepViewModel(
            image: model.image,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)"
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResult()
            self.resetImageBorder()
        }
        
        if isCorrect {
            correctAnswers += 1
        }
    }
    
    private func showNextQuestionOrResult() {
        if currentQuestionIndex == questions.count - 1 {
            let text = resultText + "\(correctAnswers)/\(questions.count)"
            let viewModel = QuizResultsViewModel(
                title: resultTitle,
                text: text,
                buttonText: resultButtonText
            )
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            let newQuestion = questions[currentQuestionIndex]
            let viewModel = convert(model: newQuestion)
            show(quiz: viewModel)
        }
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert
        )
            
        let action = UIAlertAction(
            title: result.buttonText,
            style: .default) { [weak self] _ in
                guard let self else { return }
                currentQuestionIndex = 0
                correctAnswers = 0
                let currentQuestion = questions[currentQuestionIndex]
                let viewModel = convert(model: currentQuestion)
                show(quiz: viewModel)
            }
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
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
    
    // MARK: - IBActions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        let currentQuestion = questions[currentQuestionIndex]
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        yesButton.isHighlighted = true
        buttonsIsEnable(false)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        let currentQuestion = questions[currentQuestionIndex]
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        buttonsIsEnable(false)
    }
}

/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
*/
