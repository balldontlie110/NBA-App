//
//  FinishedCard.swift
//  NBA
//
//  Created by Ali Earp on 25/05/2024.
//

import SwiftUI

struct FinishedCard: View {
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject private var viewModel: RewardedViewModel = RewardedViewModel()
    
    let quizModel: QuizModel
    
    @Binding var completed: Bool
    
    let quiz: Quiz
    
    @State var showWrongAnswers: Bool = false
    
    var body: some View {
        VStack {
            let percentage = Double(quiz.correct) / Double(quiz.correct + quiz.incorrect)
            
            VStack {
                Text(percentage > 0.75 ? "Well Done!" : percentage > 0.5 ? "Almost there!" : "Better luck next time!")
                    .font(Font.custom("Futura-CondensedExtraBold", size: 36))
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                Text("\(quiz.correct)/\(quiz.correct + quiz.incorrect)")
                    .font(Font.custom("Futura-Bold", size: 36))
                
                Spacer()
                
                Button {
                    self.showWrongAnswers.toggle()
                } label: {
                    HStack {
                        Text("Wrong Answers")
                        Image(systemName: "exclamationmark.circle")
                    }
                    .foregroundStyle(Color.green)
                    .font(Font.custom("Futura-Bold", size: 20))
                }.opacity(quiz.wrongAnswers.isEmpty ? 0 : 1)
                
                Spacer()
                
                Button {
                    withAnimation {
                        self.completed = false
                    }
                } label: {
                    Text("Close")
                        .font(Font.custom("Futura-CondensedExtraBold", size: 24))
                }
            }
            .foregroundStyle(Color.white)
            .padding()
            .frame(width: UIScreen.main.bounds.width - 75, height: UIScreen.main.bounds.height / 2.5)
            .background(
                LinearGradient(
                    colors:
                        percentage > 0.75 ? [Color.teal, Color.blue] : percentage > 0.5 ? [Color.yellow, Color.orange] : [Color.red, Color.orange]
                    ,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .padding()
            .shadow(radius: colorScheme == .light ? 5 : 0)
            .transition(.push(from: .bottom))
            .sheet(isPresented: $showWrongAnswers) {
                WrongAnswers(quiz: quiz)
            }
            
            Button {
                viewModel.showAd(date: quiz.date, correct: quiz.correct, incorrect: quiz.incorrect)
            } label: {
                Text("Watch a video to try again")
                    .foregroundStyle(Color(.systemBackground))
                    .font(Font.custom("Futura-Bold", size: 20))
                    .padding(.horizontal)
                    .padding(.vertical, 15)
                    .background(Color.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .frame(width: UIScreen.main.bounds.width / 2)
            }
        }
        .offset(y: -50)
        .onChange(of: viewModel.rewardClaimed) { _, _ in
            Task {
                self.completed = false
                await quizModel.getQuizzes()
            }
        }
        .onAppear {
            Task {
                await viewModel.loadAd()
            }
        }
    }
}

struct WrongAnswers: View {
    let quiz: Quiz
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(quiz.wrongAnswers) { wrongAnswer in
                    QuestionCard(answered: .constant(wrongAnswer.wrongAnswer), question: Question(question: wrongAnswer.question, options: [wrongAnswer.wrongAnswer, wrongAnswer.answer], answer: wrongAnswer.answer))
                }
            }
        }
    }
}

#Preview {
    FinishedCard(quizModel: QuizModel(), completed: .constant(false), quiz: Quiz(data: [:], wrongAnswers: [], documentID: ""))
}
