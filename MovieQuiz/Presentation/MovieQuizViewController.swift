import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - Constants
    private let borderWidth = CGFloat(8)
    private let cornerRadius = CGFloat(20)
    
    private let alertPresenter = AlertPresenter()
    private var presenter: MovieQuizPresenter!
    
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
        
        presenter = MovieQuizPresenter(viewController: self)
        showLoadingIndicator()
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

            self.presenter.showNextQuestionOrResult()
            self.resetImageBorder()
        }
        
        if isCorrect {
            presenter.correctAnswers += 1
        }
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let message = presenter.makeResultsMessage()
        
        let model = AlertModel(
            title: result.title,
            message: message,
            buttonText: result.buttonText) { [weak self] in
                guard let self = self else { return }
                self.presenter.restartGame()
            }
        
        alertPresenter.show(in: self, model: model)
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать ещё раз") { [weak self] in
                guard let self = self else { return }
                self.presenter.restartGame()
            }
        alertPresenter.show(in: self, model: model)
    }
    
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    // MARK: - Private functions
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
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
        buttonsIsEnable(false)
    }
}
