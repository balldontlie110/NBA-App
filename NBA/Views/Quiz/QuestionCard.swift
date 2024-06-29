//
//  QuestionCard.swift
//  NBA
//
//  Created by Ali Earp on 25/05/2024.
//

import SwiftUI

struct QuestionCard: View {
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var answered: String?
    
    let question: Question
    
    @State var shake: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Text(question.question)
                    .foregroundStyle(Color.white)
                    .font(Font.custom("Futura-Bold", size: 20))
                    .multilineTextAlignment(.center)
                Spacer()
            }
            .padding()
            .background(colorScheme == .light ? Color.black : Color(.darkGray))
            
            VStack(spacing: 15) {
                ForEach(question.options) { option in
                    Button {
                        withAnimation {
                            self.answered = option
                            
                            if option != question.answer {
                                self.shake.toggle()
                            }
                        }
                    } label: {
                        HStack {
                            Text(option)
                                .foregroundStyle(Color.black)
                                .font(Font.custom("Futura", size: 18))
                            Spacer()
                        }
                        .padding(10)
                        .padding(.horizontal, 5)
                        .background {
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(lineWidth: 2)
                                .foregroundStyle(answered == nil ? Color.black : option == answered ? option == question.answer ? Color.green : Color.red : option == question.answer ? Color.green : Color.gray)
                        }
                    }.disabled(answered != nil)
                }.padding(.horizontal)
            }.padding(.vertical)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(color: colorScheme == .light ? Color(.lightGray) : Color.clear, radius: 10)
        .padding()
        .modifier(Shake(animatableData: shake ? 2 : 0))
    }
}

struct Shake: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 2
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)), y: 0))
    }
}

#Preview {
    QuestionCard(answered: .constant(""), question: Question(question: "", options: [], answer: ""))
}
