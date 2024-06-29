//
//  ScoreboardView.swift
//  NBA
//
//  Created by Ali Earp on 19/03/2024.
//

import SwiftUI
import CoreData

struct ScoreboardView: View {
    // MARK: - State Variables
    @StateObject private var viewModel = ScoreboardViewModel()
    @State private var date: Date = Calendar.current.date(byAdding: .hour, value: -12, to: Date()) ?? Date()
    
    // MARK: - Fetch Request
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \FavoriteTeam.teamId, ascending: true)],
        animation: .default
    )
    private var favoriteTeams: FetchedResults<FavoriteTeam>
    
    // MARK: - Constants
    private let titleText = "Games"
    private let fontName = "Futura-CondensedExtraBold"
    private let dateFontSize: CGFloat = 32
    private let paddingHorizontal: CGFloat = 16
    private let paddingBottom: CGFloat = 5
    private let spacing: CGFloat = 5
    private let progressViewFrame: CGFloat = .infinity
    private let dividerHeight: CGFloat = 1
    
    var body: some View {
        VStack(spacing: 0) {
            header
            Divider().frame(height: dividerHeight)
            content
                .gesture(dragGesture)
        }
        .onAppear {
            viewModel.fetchGames(date: date)
        }
        .onChange(of: date) { _, _ in
            viewModel.fetchGames(date: date)
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        HStack {
            Text(titleText)
                .font(Font.custom(fontName, size: dateFontSize))
            DatePicker("", selection: $date, displayedComponents: [.date])
        }
        .padding(.horizontal, paddingHorizontal)
        .padding(.bottom, paddingBottom)
    }
    
    // MARK: - Content
    
    private var content: some View {
        Group {
            if viewModel.gameHeaders != nil, viewModel.lineScore != nil {
                gameList
            } else {
                ProgressView()
                    .frame(maxWidth: progressViewFrame, maxHeight: progressViewFrame)
            }
        }
    }
    
    // MARK: - Game List
    
    private var gameList: some View {
        ScrollView {
            Spacer().frame(height: spacing)
            if let lineScore = viewModel.lineScore {
                LazyVStack(spacing: spacing) {
                    ForEach(favoriteGameHeaders, id: \.self) { gameHeader in
                        if let gameId = gameHeader["GAME_ID"], let homeTeamId = gameHeader["HOME_TEAM_ID"], let awayTeamId = gameHeader["VISITOR_TEAM_ID"] {
                            if let homeTeamLineScore = lineScore.first(where: { $0["GAME_ID"] == gameId && $0["TEAM_ID"] == homeTeamId }),
                               let awayTeamLineScore = lineScore.first(where: { $0["GAME_ID"] == gameId && $0["TEAM_ID"] == awayTeamId }) {
                                NavigationLink {
                                    GameDetailView(gameId: gameId, gameHeader: gameHeader, homeTeamLineScore: homeTeamLineScore, awayTeamLineScore: awayTeamLineScore, date: date)
                                } label: {
                                    GameCard(gameHeader: gameHeader, homeTeamLineScore: homeTeamLineScore, awayTeamLineScore: awayTeamLineScore, date: date, favoriteTeams: favoriteTeams)
                                }
                            }
                        }
                    }
                }
            }
            Spacer().frame(height: spacing)
        }
        .refreshable {
            refresh()
        }
    }
    
    // MARK: - Favorite Game Headers
    
    private var favoriteGameHeaders: [[String : String]] {
        if var gameHeaders = viewModel.gameHeaders {
            for gameHeader in gameHeaders {
                if let homeTeamId = gameHeader["HOME_TEAM_ID"], let awayTeamId = gameHeader["VISITOR_TEAM_ID"],
                   favoriteTeams.contains(where: { $0.teamId == homeTeamId || $0.teamId == awayTeamId }) {
                    gameHeaders.removeAll { $0["GAME_ID"] == gameHeader["GAME_ID"] }
                    gameHeaders.insert(gameHeader, at: 0)
                }
            }
            return gameHeaders
        } else {
            return []
        }
    }
    
    // MARK: - Refresh Function
    
    private func refresh() {
        DispatchQueue.main.async {
            viewModel.fetchGames(date: date)
        }
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onEnded { value in
                if value.translation.width < 0 {
                    self.date = Calendar.current.date(byAdding: .day, value: 1, to: date) ?? Date()
                } else if value.translation.width > 0 {
                    self.date = Calendar.current.date(byAdding: .day, value: -1, to: date) ?? Date()
                }
            }
    }
}

struct GameCard: View {
    // MARK: - Constants
    private let columns: [GridItem] = [
        GridItem(.fixed(90)),
        GridItem(.flexible()),
        GridItem(.fixed(50)),
        GridItem(.flexible()),
        GridItem(.fixed(90))
    ]
    private let fontName = "Futura"
    private let smallFontSize: CGFloat = 12
    private let largeFontSize: CGFloat = 30
    private let mediumFontSize: CGFloat = 16
    private let verticalPadding: CGFloat = 15
    private let horizontalPadding: CGFloat = 5
    private let primaryColor = Color.primary
    private let lightGrayColor = Color(.lightGray)
    private let labelColor = Color(.label)
    
    let gameHeader: [String : String]
    let homeTeamLineScore: [String : String]
    let awayTeamLineScore: [String : String]
    let date: Date
    let favoriteTeams: FetchedResults<FavoriteTeam>
    
    var body: some View {
        ZStack {
            Color(.systemGray6)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            LazyVGrid(columns: columns) {
                teamColumn(teamLineScore: homeTeamLineScore, home: true)
                scores
                teamColumn(teamLineScore: awayTeamLineScore, home: false)
            }
            .foregroundStyle(labelColor)
            .padding(.vertical, verticalPadding)
        }
        .padding(.horizontal, horizontalPadding)
    }
    
    // MARK: - Team Column
    
    private func teamColumn(teamLineScore: [String : String], home: Bool) -> some View {
        VStack {
            if let teamId = teamLineScore["TEAM_ID"] {
                Image(teamId)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50)
                    .overlay {
                        if favoriteTeams.contains(where: { $0.teamId == teamId }) {
                            Image(systemName: "star.fill")
                                .foregroundStyle(Color.yellow)
                                .offset(x: home ? -25 : 25, y: -25)
                        }
                    }
            }
            if let teamName = teamLineScore["TEAM_NAME"], let winLoss = teamLineScore["TEAM_WINS_LOSSES"] {
                Text(teamName)
                Text(winLoss)
                    .foregroundStyle(lightGrayColor)
            }
        }
        .font(Font.custom(fontName, size: smallFontSize))
    }
    
    // MARK: - Scores
    
    private var scores: some View {
        Group {
            if let homeTeamScore = homeTeamLineScore["PTS"], let awayTeamScore = awayTeamLineScore["PTS"], let gameStatusText = gameHeader["GAME_STATUS_TEXT"], let gameStatus = gameHeader["GAME_STATUS_ID"] {
                Text(homeTeamScore)
                    .font(Font.custom("Futura-CondensedExtraBold", size: largeFontSize))
                    .foregroundStyle(gameStatus == "3" ? Int(homeTeamScore) ?? 0 > Int(awayTeamScore) ?? 0 ? primaryColor : lightGrayColor : primaryColor)
                
                Group {
                    let gameTime = getGameTime(gameStatusText: gameStatusText)
                    let gameTimeString = getGameTimeString(date: gameTime)
                    
                    if date == Date() && gameTime.timeIntervalSince(Date()) <= 300 && gameStatus == "1" {
                        Text("PREGAME")
                    } else if gameStatus == "1" {
                        Text(gameTimeString)
                    } else {
                        Text(gameStatusText.uppercased())
                    }
                }
                .font(Font.custom("Futura-CondensedMedium", size: mediumFontSize))
                .multilineTextAlignment(.center)
                
                Text(awayTeamScore)
                    .font(Font.custom("Futura-CondensedExtraBold", size: largeFontSize))
                    .foregroundStyle(gameStatus == "3" ? Int(awayTeamScore) ?? 0 > Int(homeTeamScore) ?? 0 ? primaryColor : lightGrayColor : primaryColor)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ScoreboardView()
    }
}

