//
//  QuestionsView.swift
//  NBA
//
//  Created by Ali Earp on 25/05/2024.
//

import SwiftUI

struct QuestionsView: View {
    let questions: [Question]
    
    @Binding var answered: String?
    @Binding var questionNumber: Int
    
    @Binding var correct: Int
    @Binding var incorrect: Int
    @Binding var wrongAnswers: [WrongAnswer]
    
    @Binding var completed: Bool
    
    let alreadyPlayed: Bool
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 5)
            
            ProgressView(value: alreadyPlayed ? Double(questions.count) : Double(questionNumber), total: Double(questions.count))
                .progressViewStyle(.linear)
                .padding()
            
            Spacer()
            
            QuestionCard(answered: $answered, question: questions[questionNumber])
            
            Button {
                self.answered = nil
                if questionNumber >= questions.count - 1 {
                    withAnimation {
                        self.completed = true
                    }
                } else {
                    self.questionNumber += 1
                }
                
                if questionNumber >= questions.count {
                    self.completed = true
                }
            } label: {
                Text(questionNumber >= questions.count - 1 ? "Complete" : "Next Question")
                    .foregroundStyle(Color(.systemBackground))
                    .font(Font.custom("Futura-Bold", size: 20))
                    .padding(.horizontal)
                    .padding(.vertical, 15)
                    .background(Color.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }.opacity(answered == nil ? 0 : 1)
            
            Spacer()
            
            HStack(spacing: 50) {
                VStack {
                    Text(String(correct))
                        .font(Font.custom("Futura-CondensedExtraBold", size: 45))
                    Image(systemName: "checkmark.circle")
                        .foregroundStyle(Color.green)
                        .font(.system(size: 35))
                }
                
                VStack {
                    Text(String(incorrect))
                        .font(Font.custom("Futura-CondensedExtraBold", size: 45))
                    Image(systemName: "x.circle")
                        .foregroundStyle(Color.red)
                        .font(.system(size: 35))
                }
            }.onChange(of: answered) { _, _ in
                if let answered = answered {
                    if answered == questions[questionNumber].answer {
                        correct += 1
                    } else {
                        incorrect += 1
                        
                        let question = questions[questionNumber]
                        let wrongAnswer = WrongAnswer(data: [
                            "question" : question.question,
                            "answer" : question.answer,
                            "wrongAnswer" : answered
                        ], documentID: UUID().uuidString)
                        
                        self.wrongAnswers.append(wrongAnswer)
                    }
                }
            }
            
            Spacer()
                .frame(height: 5)
        }
    }
}
