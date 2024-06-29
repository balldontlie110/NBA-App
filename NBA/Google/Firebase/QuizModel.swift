//
//  QuizModel.swift
//  NBA
//
//  Created by Ali Earp on 27/05/2024.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

struct Quiz: Identifiable, Equatable {
    var id: String { documentID }
    
    let date: Date
    let correct: Int
    let incorrect: Int
    let wrongAnswers: [WrongAnswer]
    let documentID: String
    
    init(data: [String : Any], wrongAnswers: [WrongAnswer], documentID: String) {
        self.date = (data["date"] as? Timestamp ?? Timestamp()).dateValue()
        self.correct = data["correct"] as? Int ?? 0
        self.incorrect = data["incorrect"] as? Int ?? 0
        self.wrongAnswers = wrongAnswers
        self.documentID = documentID
    }
    
    static func ==(lhs: Quiz, rhs: Quiz) -> Bool {
        return lhs.id == rhs.id
    }
}

struct WrongAnswer: Identifiable {
    var id: String { documentID }
    
    let question: String
    let answer: String
    let wrongAnswer: String
    let documentID: String
    
    init(data: [String : Any], documentID: String) {
        self.question = data["question"] as? String ?? ""
        self.answer = data["answer"] as? String ?? ""
        self.wrongAnswer = data["wrongAnswer"] as? String ?? ""
        self.documentID = documentID
    }
}

struct Question: Identifiable {
    var id = UUID().uuidString
    
    let question: String
    let options: [String]
    let answer: String
}

@MainActor
class QuizModel: ObservableObject {
    @Published var quizzes: [Quiz] = []
    
    init() {
        Task {
            await getQuizzes()
        }
    }
    
    func getQuizzes() async {
        self.quizzes = []
        
        if let uid = Auth.auth().currentUser?.uid {
            do {
                let quizCollection = Firestore.firestore().collection("users").document(uid).collection("quizzes")
                
                let quizzesSnapshot = try await quizCollection.getDocuments()
                quizzesSnapshot.documents.forEach { quizSnapshot in
                    Task {
                        var wrongAnswers: [WrongAnswer] = []
                        
                        let wrongAnswersSnapshot = try await quizCollection.document(quizSnapshot.documentID).collection("wrongAnswers").getDocuments()
                        wrongAnswersSnapshot.documents.forEach { wrongAnswerSnapshot in
                            let wrongAnswer = WrongAnswer(data: wrongAnswerSnapshot.data(), documentID: wrongAnswerSnapshot.documentID)
                            wrongAnswers.append(wrongAnswer)
                        }
                        
                        let quiz = Quiz(data: quizSnapshot.data(), wrongAnswers: wrongAnswers, documentID: quizSnapshot.documentID)
                        self.quizzes.append(quiz)
                    }
                }
            } catch {
                print(error)
            }
        }
    }
    
    func addQuizToQuizzes(date: Date, correct: Int, incorrect: Int, wrongAnswers: [WrongAnswer]) async throws {
        do {
            if let uid = Auth.auth().currentUser?.uid {
                let userDocument = Firestore.firestore().collection("users").document(uid)
                let quizDocument = userDocument.collection("quizzes").document()
                
                try await quizDocument.setData([
                    "date" : Timestamp(date: date),
                    "correct" : correct,
                    "incorrect" : incorrect
                ])
                
                for wrongAnswer in wrongAnswers {
                    try await quizDocument.collection("wrongAnswers").document().setData([
                        "question" : wrongAnswer.question,
                        "answer" : wrongAnswer.answer,
                        "wrongAnswer" : wrongAnswer.wrongAnswer
                    ])
                }
                
                if let data = try await Firestore.firestore().collection("users").document(uid).getDocument().data() {
                    let totalCorrect = (data["totalCorrect"] as? Int ?? 0) + correct
                    let totalIncorrect = (data["totalIncorrect"] as? Int ?? 0) + incorrect
                    
                    try await Firestore.firestore().collection("users").document(uid).updateData([
                        "totalCorrect" : totalCorrect,
                        "totalIncorrect" : totalIncorrect,
                        "date" : Timestamp(date: date)
                    ])
                }
                
                await getQuizzes()
            }
        } catch {
            print("Failed to add quiz to quizzes in core data: \(error)")
        }
    }
}
