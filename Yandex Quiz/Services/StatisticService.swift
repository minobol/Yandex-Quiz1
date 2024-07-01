import Foundation

final class StatisticService: StatisticServiceProtocol {
    
    var gamesCount: Int {
        get {
            let gamesCount = storage.integer(forKey: Keys.gamesCount.rawValue)
            return gamesCount
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.correct.rawValue)
            let total = storage.integer(forKey: Keys.total.rawValue)
            let date = storage.object(forKey: Keys.date.rawValue) as? Date ?? Date()
            return GameResult(correct: correct, total: total, date: date)
        }
        set(newValue) {
            storage.set(newValue.correct, forKey: Keys.correct.rawValue)
            storage.set(newValue.total, forKey: Keys.total.rawValue)
            storage.set(newValue.date, forKey: Keys.date.rawValue)
        }
    }
    
    // метод подсчета лучшего результата
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        storage.set(amount, forKey: Keys.total.rawValue)
        
        let prevRecord = bestGame
        let record = GameResult(correct: count, total: amount, date: Date())
        if record.isBetterThan(prevRecord) {
            bestGame = record
            storage.set(count, forKey: Keys.correct.rawValue)
            storage.set(Date(), forKey: Keys.date.rawValue)
        }
        sumCorrectAnswers += record.correct
    }
    
    // средняя точность
    var totalAccuracy: Double {
        get {
            Double(sumCorrectAnswers)/Double(gamesCount) * Double(100/10)
        }
    }
    
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        case correct
        case bestGame
        case gamesCount
        case total
        case date
    }
    
    private var sumCorrectAnswers = 0
}


