import UIKit


final class MovieQuizViewController: UIViewController {
    // MARK: - Lifecycle
    
    struct QuizQuestion {
        let image: String
        let text: String
        let correctAnswer: Bool
    }
    
    struct QuizStepViewModel {
        let image: UIImage
        let question: String
        let questionNumber: String
    }
    
    struct QuizResultsViewModel {
        let title: String
        let text: String
        let buttonText: String
    }
    //номер текущего вопроса
    private var currentQuestionIndex = 0
    
    //количество правильных ответов
    private var correctAnswers = 0
    
    //количество сыгранных квизов
    private var games = 0
    
    //средняя точность
    private var accuracy = 0
    
    //лучший результат с указанием даты и времени
    private var result = ""
    
    //массив количества правильных ответов всех квизов
    private var resultArray = [Int]()
    
    //массив структур вопросов квиза
    private let questions: [QuizQuestion] = [
        QuizQuestion(
            image: "The Godfather",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Dark Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Kill Bill",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Avengers",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Deadpool",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Green Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Old",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "The Ice Age Adventures of Buck Wild",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Tesla",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Vivarium",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false)
    ]
    
    
    @IBOutlet private var imageView: UIImageView!
    
    @IBOutlet private var textLabel: UILabel!
    
    @IBOutlet private var counterLabel: UILabel!
    
    @IBOutlet private var yesButton: UIButton!
    
    @IBOutlet private var noButton: UIButton!
    
    @IBOutlet weak var questionField: UILabel!
    
    override internal func viewDidLoad() {
        super.viewDidLoad()
        clearBorder()
        textLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        counterLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        questionField.font = UIFont(name: "YSDisplay-Bold", size: 23)
        yesButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        noButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        
        show(quiz: QuizStepViewModel(image: UIImage(named: "The Godfather") ?? UIImage(),
                                     question: "Рейтинг этого фильма больше чем 6?",
                                     questionNumber: "1/10"))
    }
    
    //функция вывода даты/времени
    private func dateTime() -> String {
        let dateTime = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy, HH:mm"
        let currentDateTime = dateFormatter.string(from: dateTime)
        return currentDateTime
    }
    
    //функция создания вью модели вопроса из структуры QuizQuestion
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let currentQuestion = QuizStepViewModel(image: UIImage(named: model.image) ?? UIImage(), question: model.text, questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
        return currentQuestion
    }
    
    //функция вывода вопроса
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        questionField.text = step.question
        counterLabel.text = step.questionNumber
    }
    //функция вывода алерта с результатом квиза и возвратом в первый вопрос
    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            let firstQuestion = self.questions[self.currentQuestionIndex]
            let viewModel = self.convert(model: firstQuestion)
            self.show(quiz: viewModel)
        }
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
        yesButton.isEnabled = true
        noButton.isEnabled = true
        clearBorder()
    }
    
    //функция вывода следующего вопроса или результата квиза
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questions.count - 1 {
            games += 1
            
            resultArray.append(correctAnswers)
            for i in 0..<resultArray.count {
                if correctAnswers >= resultArray.max() ?? 0 {
                    result = "\(resultArray[i])" + " (\(dateTime()))"
                }
            }
            
            var sumResultArray = 0
            for i in resultArray {
                sumResultArray += i
                accuracy = sumResultArray/resultArray.count * 100 / 10
            }
            
            show(quiz: QuizResultsViewModel(title: "Этот раунд окончен!",
                                            text: "Ваш результат: \(correctAnswers)/10 \n" +
                                            "Количество сыгранных квизов: \(games)\n" +
                                            "Рекорд: \(result) \n" +
                                            "Средняя точность: \(accuracy)%",
                                            buttonText: "Сыграть еще раз"))
        } else {
            currentQuestionIndex += 1
            let nextQuestion = questions[currentQuestionIndex]
            let viewModel = convert(model: nextQuestion)
            show(quiz: viewModel)
            clearBorder()
            yesButton.isEnabled = true
            noButton.isEnabled = true
        }
    }
    
    //функция вывода результата ответа на вопрос
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        if isCorrect {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            correctAnswers += 1
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    
    //функция отображения скругления постера
    private func clearBorder() {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        let currentQuestion = questions[currentQuestionIndex]
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        let currentQuestion = questions[currentQuestionIndex]
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
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
