import UIKit


final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterProtocol {
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: any Error) {
        showNetworkError(message: error.localizedDescription)
    }
        
    // MARK: - Lifecycle
    
    //номер текущего вопроса
    private var currentQuestionIndex = 0
    
    //количество правильных ответов
    private var correctAnswers = 0
    
    //константа количества вопросов
    private let questionsAmount: Int = 10
    
    private var questionFactory: QuestionFactoryProtocol?
    
    private var currentQuestion: QuizQuestion?
    
    private var alertPresenterDelegate: AlertPresenterDelegate?
    
    private var alertPresenter: AlertPresenterProtocol?
    
    private var statisticService: StatisticServiceProtocol = StatisticService()
    
    @IBOutlet private var imageView: UIImageView!
    
    @IBOutlet private var textLabel: UILabel!
    
    @IBOutlet private var counterLabel: UILabel!
    
    @IBOutlet private var yesButton: UIButton!
    
    @IBOutlet private var noButton: UIButton!
    
    @IBOutlet weak var questionField: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override internal func viewDidLoad() {
        super.viewDidLoad()
        clearBorder()
        textLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        counterLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        questionField.font = UIFont(name: "YSDisplay-Bold", size: 23)
        yesButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        noButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        
        questionFactory?.loadData()
        showLoadingIndicator()
        
        let alertPresenterDelegate = AlertPresenter()
        alertPresenterDelegate.alertView = self
        self.alertPresenterDelegate = alertPresenterDelegate
        
        statisticService = StatisticService()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        show(quiz: viewModel)
        
        DispatchQueue.main.async {
            self.show(quiz: viewModel)
        }
    }
    
    //метод создания вью модели вопроса из структуры QuizQuestion
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        
        let image = UIImage(data: model.image) ?? UIImage()
        
        let currentQuestion = QuizStepViewModel(image: image,
                                                question: model.text,
                                                questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return currentQuestion
    }
    
    //метод вывода вопроса
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        questionField.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    // MARK: - AlertPresenterProtocol
    func showNextQuestionOrResults() {
        
        hideLoadingIndicator()
        
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            
            let messageText = """
                Ваш результат: \(correctAnswers)/\(questionsAmount)
                Количество сыгранных квизов: \(statisticService.gamesCount)
                Рекорд: \(statisticService.bestGame.correct)/\(questionsAmount) (\(statisticService.bestGame.date.dateTimeString))
                Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                """
            
            let alertModel = AlertModel(title: "Этот раунд окончен!",
                                        message: messageText,
                                        buttonText:"Сыграть еще раз",
                                        completion: {[weak self] in
                self?.currentQuestionIndex = 0
                self?.correctAnswers = 0
                self?.questionFactory?.requestNextQuestion()
            })
            alertPresenterDelegate?.alertShow(alertModel: alertModel)
        } else {
            currentQuestionIndex += 1
            didLoadDataFromServer()
        }
    }
    
    //метод вывода результата ответа на вопрос
    private func showAnswerResult(isCorrect: Bool) {
        changeStateButton(isEnabled: false)
        showLoadingIndicator()
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        if isCorrect {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            correctAnswers += 1
            
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor

        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {return}
            self.showNextQuestionOrResults()
            changeStateButton(isEnabled: true)
            clearBorder()
        }
    }
    
    //метод отображения скругления постера
    private func clearBorder() {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    //метод блокировки кнопок вариантов ответа
    private func changeStateButton(isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertErrorModel = AlertModel(title: "Ошибка",
                                         message: message,
                                         buttonText:"Попробовать еще раз",
                                         completion: {[weak self] in
            guard let self = self else { return }
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        })
        alertPresenterDelegate?.alertShow(alertModel: alertErrorModel)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}
