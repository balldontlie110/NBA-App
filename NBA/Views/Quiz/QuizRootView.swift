//
//  QuizRootView.swift
//  NBA
//
//  Created by Ali Earp on 22/05/2024.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct QuizRootView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var authModel: AuthModel
    
    @StateObject var viewModel: ScoreboardViewModel = ScoreboardViewModel()
    @StateObject var quizModel: QuizModel = QuizModel()
    
    @State var date: Date = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
    
    @State var answered: String?
    @State var questions: [Question] = []
    @State var questionNumber: Int = 0
    
    @State var correct: Int = 0
    @State var incorrect: Int = 0
    @State var wrongAnswers: [WrongAnswer] = []
    
    @State var completed: Bool = false
    
    var alreadyPlayed: Bool {
        if quizModel.quizzes.contains(where: { quiz in
            let checkDate = Calendar.current.dateComponents([.year, .month, .day], from: quiz.date)
            let realDate = Calendar.current.dateComponents([.year, .month, .day], from: date)
            
            if let checkYear = checkDate.year, let checkMonth = checkDate.month, let checkDay = checkDate.day, let realYear = realDate.year, let realMonth = realDate.month, let realDay = realDate.day {
                return checkYear == realYear && checkMonth == realMonth && checkDay == realDay
            } else {
                return false
            }
        }) {
            return true
        } else {
            return false
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                NavigationLink {
                    LeaderboardView()
                } label: {
                    Image(systemName: "trophy")
                        .foregroundStyle(Color.primary)
                        .font(.system(size: 25, weight: .bold))
                }
                
                DatePicker("", selection: $date, displayedComponents: .date)
            }
            .padding(.horizontal)
            .disabled(completed)
            .blur(radius: completed ? 5.0 : 0.0)
            
            if !questions.isEmpty {
                ZStack {
                    QuestionsView(questions: questions, answered: $answered, questionNumber: $questionNumber, correct: $correct, incorrect: $incorrect, wrongAnswers: $wrongAnswers, completed: $completed, alreadyPlayed: alreadyPlayed)
                    .disabled(alreadyPlayed || completed)
                    .blur(radius: completed ? 5.0 : 0.0)
                    .onChange(of: completed) { _, _ in
                        if completed == true && !alreadyPlayed {
                            Task {
                                try await quizModel.addQuizToQuizzes(date: date, correct: correct, incorrect: incorrect, wrongAnswers: wrongAnswers)
                            }
                        }
                    }
                    .onChange(of: alreadyPlayed) { _, _ in
                        checkAlreadyPlayed()
                    }
                    .onAppear {
                        checkAlreadyPlayed()
                    }
                    
                    if completed {
                        if let quiz = quizModel.quizzes.first(where: { quiz in
                            let checkDate = Calendar.current.dateComponents([.year, .month, .day], from: quiz.date)
                            let realDate = Calendar.current.dateComponents([.year, .month, .day], from: date)
                            
                            if let checkYear = checkDate.year, let checkMonth = checkDate.month, let checkDay = checkDate.day, let realYear = realDate.year, let realMonth = realDate.month, let realDay = realDate.day {
                                return checkYear == realYear && checkMonth == realMonth && checkDay == realDay
                            } else {
                                return false
                            }
                        }) {
                            FinishedCard(quizModel: quizModel, completed: $completed, quiz: quiz)
                        }
                    }
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color(.systemBackground))
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width < 0 {
                        self.date = Calendar.current.date(byAdding: .day, value: 1, to: date) ?? Date()
                    } else if value.translation.width > 0 {
                        self.date = Calendar.current.date(byAdding: .day, value: -1, to: date) ?? Date()
                    }
                }
        )
        .onAppear {
            viewModel.fetchGames(date: date)
        }
        .onChange(of: date) { _, _ in
            self.answered = nil
            self.questions = []
            self.questionNumber = 0
            self.correct = 0
            self.incorrect = 0
            self.wrongAnswers = []
            self.completed = false
            
            viewModel.fetchGames(date: date)
        }
        .onChange(of: quizModel.quizzes) { _, _ in
            if !completed {
                self.answered = nil
                self.questions = []
                self.questionNumber = 0
                self.correct = 0
                self.incorrect = 0
                self.wrongAnswers = []
                self.completed = false
            }
        }
        .onChange(of: viewModel.gameHeaders) { _, _ in
            self.questions = []
            
            if let gameHeaders = viewModel.gameHeaders, let lineScore = viewModel.lineScore, let teamLeaders = viewModel.teamLeaders {
                for gameHeader in gameHeaders {
                    if let gameStatus = gameHeader["GAME_STATUS_ID"] {
                        if gameStatus == "3", let gameId = gameHeader["GAME_ID"] {
                            if let homeTeamId = gameHeader["HOME_TEAM_ID"], let awayTeamId = gameHeader["VISITOR_TEAM_ID"] {
                                let homeTeamLineScore = lineScore.first { lineScore in
                                    lineScore["GAME_ID"] == gameId && lineScore["TEAM_ID"] == homeTeamId
                                }
                                
                                let awayTeamLineScore = lineScore.first { lineScore in
                                    lineScore["GAME_ID"] == gameId && lineScore["TEAM_ID"] == awayTeamId
                                }
                                
                                
                                let homeTeamLeaders = teamLeaders.first { teamLeaders in
                                    teamLeaders["GAME_ID"] == gameId && teamLeaders["TEAM_ID"] == homeTeamId
                                }
                                
                                let awayTeamLeaders = teamLeaders.first { teamLeaders in
                                    teamLeaders["GAME_ID"] == gameId && teamLeaders["TEAM_ID"] == awayTeamId
                                }
                                
                                if let homeTeamLineScore = homeTeamLineScore, let awayTeamLineScore = awayTeamLineScore, let homeTeamLeaders = homeTeamLeaders, let awayTeamLeaders = awayTeamLeaders {
                                    if let homeTeamScore = homeTeamLineScore["PTS"], let homeTeamName = homeTeamLineScore["TEAM_NAME"], let awayTeamScore = awayTeamLineScore["PTS"], let awayTeamName = awayTeamLineScore["TEAM_NAME"], let homeTeamPointsLeaderName = homeTeamLeaders["PTS_PLAYER_NAME"], let homeTeamPointsLeaderPoints = homeTeamLeaders["PTS"], let homeTeamReboundsLeaderName = homeTeamLeaders["REB_PLAYER_NAME"], let homeTeamReboundsLeaderRebounds = homeTeamLeaders["REB"], let homeTeamAssistsLeaderName = homeTeamLeaders["AST_PLAYER_NAME"], let homeTeamAssistsLeaderAssists = homeTeamLeaders["AST"], let awayTeamPointsLeaderName = awayTeamLeaders["PTS_PLAYER_NAME"], let awayTeamPointsLeaderPoints = awayTeamLeaders["PTS"], let awayTeamReboundsLeaderName = awayTeamLeaders["REB_PLAYER_NAME"], let awayTeamReboundsLeaderRebounds = awayTeamLeaders["REB"], let awayTeamAssistsLeaderName = awayTeamLeaders["AST_PLAYER_NAME"], let awayTeamAssistsLeaderAssists = awayTeamLeaders["AST"] {
                                        
                                        let winnerQuestion = Question(question: "Which team won: \(homeTeamName) vs \(awayTeamName)", options: [homeTeamName, awayTeamName], answer: homeTeamScore > awayTeamScore ? homeTeamName : awayTeamName)
                                        
                                        
                                        var homeTeamOptions: [String] = []
                                        for _ in 0..<4 {
                                            var option = homeTeamScore
                                            while homeTeamOptions.contains(option) {
                                                option = String(Int.random(in: (Int(homeTeamScore) ?? 0) - 10...(Int(homeTeamScore) ?? 0) + 10))
                                            }
                                            
                                            homeTeamOptions.append(option)
                                        }
                                        
                                        let homeTeamPointsQuestion = Question(question: "How many points did the \(homeTeamName) score?", options: homeTeamOptions.shuffled(), answer: homeTeamScore)
                                        
                                        
                                        var awayTeamOptions: [String] = []
                                        for _ in 0..<4 {
                                            var option = awayTeamScore
                                            while awayTeamOptions.contains(option) {
                                                option = String(Int.random(in: (Int(awayTeamScore) ?? 0) - 10...(Int(awayTeamScore) ?? 0) + 10))
                                            }
                                            
                                            awayTeamOptions.append(option)
                                        }
                                        
                                        let awayTeamPointsQuestion = Question(question: "How many points did the \(awayTeamName) score?", options: awayTeamOptions.shuffled(), answer: awayTeamScore)
                                        
                                        
                                        var homeTeamPointsLeaderOptions: [String] = []
                                        for _ in 0..<4 {
                                            var option = homeTeamPointsLeaderPoints
                                            while homeTeamPointsLeaderOptions.contains(option) {
                                                option = String(Int.random(in: (Int(homeTeamPointsLeaderPoints) ?? 0) - 5...(Int(homeTeamPointsLeaderPoints) ?? 0) + 5))
                                            }
                                            
                                            homeTeamPointsLeaderOptions.append(option)
                                        }
                                        
                                        let homeTeamPointsLeaderQuestion = Question(question: "How many points did \(homeTeamPointsLeaderName) score?", options: homeTeamPointsLeaderOptions.shuffled(), answer: homeTeamPointsLeaderPoints)
                                        
                                        
                                        var homeTeamReboundsLeaderOptions: [String] = []
                                        for _ in 0..<4 {
                                            var option = homeTeamReboundsLeaderRebounds
                                            while homeTeamReboundsLeaderOptions.contains(option) {
                                                option = String(Int.random(in: (Int(homeTeamReboundsLeaderRebounds) ?? 0) - 5...(Int(homeTeamReboundsLeaderRebounds) ?? 0) + 5))
                                            }
                                            
                                            homeTeamReboundsLeaderOptions.append(option)
                                        }
                                        
                                        let homeTeamReboundsLeaderQuestion = Question(question: "How many rebounds did \(homeTeamReboundsLeaderName) have?", options: homeTeamReboundsLeaderOptions.shuffled(), answer: homeTeamReboundsLeaderRebounds)
                                        
                                        
                                        var homeTeamAssistsLeaderOptions: [String] = []
                                        for _ in 0..<4 {
                                            var option = homeTeamAssistsLeaderAssists
                                            while homeTeamAssistsLeaderOptions.contains(option) {
                                                option = String(Int.random(in: (Int(homeTeamAssistsLeaderAssists) ?? 0) - 5...(Int(homeTeamAssistsLeaderAssists) ?? 0) + 5))
                                            }
                                            
                                            homeTeamAssistsLeaderOptions.append(option)
                                        }
                                        
                                        let homeTeamAssistsLeaderQuestion = Question(question: "How many assists did \(homeTeamAssistsLeaderName) have?", options: homeTeamAssistsLeaderOptions.shuffled(), answer: homeTeamAssistsLeaderAssists)
                                        
                                        
                                        var awayTeamPointsLeaderOptions: [String] = []
                                        for _ in 0..<4 {
                                            var option = awayTeamPointsLeaderPoints
                                            while awayTeamPointsLeaderOptions.contains(option) {
                                                option = String(Int.random(in: (Int(awayTeamPointsLeaderPoints) ?? 0) - 5...(Int(awayTeamPointsLeaderPoints) ?? 0) + 5))
                                            }
                                            
                                            awayTeamPointsLeaderOptions.append(option)
                                        }
                                        
                                        let awayTeamPointsLeaderQuestion = Question(question: "How many points did \(awayTeamPointsLeaderName) score?", options: awayTeamPointsLeaderOptions.shuffled(), answer: awayTeamPointsLeaderPoints)
                                        
                                        
                                        var awayTeamReboundsLeaderOptions: [String] = []
                                        for _ in 0..<4 {
                                            var option = awayTeamReboundsLeaderRebounds
                                            while awayTeamReboundsLeaderOptions.contains(option) {
                                                option = String(Int.random(in: (Int(awayTeamReboundsLeaderRebounds) ?? 0) - 5...(Int(awayTeamReboundsLeaderRebounds) ?? 0) + 5))
                                            }
                                            
                                            awayTeamReboundsLeaderOptions.append(option)
                                        }
                                        
                                        let awayTeamReboundsLeaderQuestion = Question(question: "How many rebounds did \(awayTeamReboundsLeaderName) have?", options: awayTeamReboundsLeaderOptions.shuffled(), answer: awayTeamReboundsLeaderRebounds)
                                        
                                        
                                        var awayTeamAssistsLeaderOptions: [String] = []
                                        for _ in 0..<4 {
                                            var option = awayTeamAssistsLeaderAssists
                                            while awayTeamAssistsLeaderOptions.contains(option) {
                                                option = String(Int.random(in: (Int(awayTeamAssistsLeaderAssists) ?? 0) - 5...(Int(awayTeamAssistsLeaderAssists) ?? 0) + 5))
                                            }
                                            
                                            awayTeamAssistsLeaderOptions.append(option)
                                        }
                                        
                                        let awayTeamAssistsLeaderQuestion = Question(question: "How many assists did \(awayTeamAssistsLeaderName) have?", options: awayTeamAssistsLeaderOptions.shuffled(), answer: awayTeamAssistsLeaderAssists)
                                        
                                        
                                        self.questions += [winnerQuestion, homeTeamPointsQuestion, awayTeamPointsQuestion, homeTeamPointsLeaderQuestion, homeTeamReboundsLeaderQuestion, homeTeamAssistsLeaderQuestion, awayTeamPointsLeaderQuestion, awayTeamReboundsLeaderQuestion, awayTeamAssistsLeaderQuestion]
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .onChange(of: authModel.user) { _, _ in
            Task {
                self.date = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
                self.answered = nil
                self.questions = []
                self.questionNumber = 0
                self.correct = 0
                self.incorrect = 0
                self.wrongAnswers = []
                self.completed = false
                
                await quizModel.getQuizzes()
            }
        }
    }
    
    private func checkAlreadyPlayed() {
        self.completed = alreadyPlayed
        if alreadyPlayed {
            if let quiz = quizModel.quizzes.first(where: { quiz in
                let checkDate = Calendar.current.dateComponents([.year, .month, .day], from: quiz.date)
                let realDate = Calendar.current.dateComponents([.year, .month, .day], from: date)
                
                if let checkYear = checkDate.year, let checkMonth = checkDate.month, let checkDay = checkDate.day, let realYear = realDate.year, let realMonth = realDate.month, let realDay = realDate.day {
                    return checkYear == realYear && checkMonth == realMonth && checkDay == realDay
                } else {
                    return false
                }
            }) {
                self.correct = Int(quiz.correct)
                self.incorrect = Int(quiz.incorrect)
            }
        }
    }
}

#Preview {
    QuizRootView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
        .environmentObject(AuthModel())
}
