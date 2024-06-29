//
//  BoxScoreView.swift
//  NBA
//
//  Created by Ali Earp on 20/03/2024.
//

import SwiftUI

struct BoxScoreView: View {
    // MARK: - Environment Variables
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - State Objects
    @StateObject private var viewModel = BoxScoreViewModel()
    
    // MARK: - State Variables
    @State private var homeTeam: Bool = true
    
    // MARK: - Constants
    private let segmentControlBackgroundColor = UIColor.systemGray5
    private let segmentPickerPadding: CGFloat = 10
    private let segmentPickerHeight: CGFloat = 40
    
    private var dividerColor: Color { colorScheme == .light ? .black : .white }
    
    let gameId: String
    
    // MARK: - Initializer
    init(gameId: String) {
        UISegmentedControl.appearance().backgroundColor = segmentControlBackgroundColor
        self.gameId = gameId
    }
    
    var body: some View {
        VStack {
            if viewModel.boxScore != nil {
                ScrollView {
                    boxScore
                    
                    Spacer().frame(height: 60)
                }
                .scrollIndicators(.hidden)
                .overlay(alignment: .bottom) {
                    if let boxScore = viewModel.boxScore {
                        segmentPicker(for: boxScore)
                    }
                }
                .refreshable {
                    refresh()
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            viewModel.fetchBoxScore(gameId: gameId)
        }
    }
    
    // MARK: - Score View
    
    private var boxScore: some View {
        HStack(spacing: 0) {
            if let boxScore = viewModel.boxScore {
                VStack {
                    PlayersSection(boxScore: boxScore, homeTeam: homeTeam, isStarter: "1", gameStatus: boxScore.gameStatus, dividerColor: dividerColor)
                    
                    Divider()
                        .background(dividerColor)
                    
                    PlayersSection(boxScore: boxScore, homeTeam: homeTeam, isStarter: "0", gameStatus: boxScore.gameStatus, dividerColor: dividerColor)
                }
                .frame(maxWidth: 165)
                .padding(.top, 10)
                
                Divider()
                    .background(dividerColor)
                
                ScrollView(.horizontal) {
                    StatisticsSection(boxScore: boxScore, homeTeam: homeTeam, isStarter: "1", dividerColor: dividerColor)
                    
                    Divider()
                        .background(dividerColor)
                    
                    StatisticsSection(boxScore: boxScore, homeTeam: homeTeam, isStarter: "0", dividerColor: dividerColor)
                }
                .scrollIndicators(.hidden)
                .padding(.top, 10)
            }
        }
        .font(Font.custom("Futura", size: 14))
    }
    
    // MARK: - Segment Picker
    
    private func segmentPicker(for boxScore: BoxScoreGame) -> some View {
        Picker("", selection: $homeTeam) {
            Text(boxScore.homeTeam.teamTricode)
                .tag(true)
            Text(boxScore.awayTeam.teamTricode)
                .tag(false)
        }
        .pickerStyle(.segmented)
        .frame(height: segmentPickerHeight)
        .padding(segmentPickerPadding)
    }
    
    // MARK: - Refresh Function
    
    private func refresh() {
        DispatchQueue.main.async {
            viewModel.fetchBoxScore(gameId: gameId)
        }
    }
}

// MARK: - Players Section

struct PlayersSection: View {
    // MARK: - State Variables
    @State var playerProfileView: String?
    
    // MARK: - Constants
    private let columns = [GridItem(.flexible())]
    
    let boxScore: BoxScoreGame
    let homeTeam: Bool
    let isStarter: String
    let gameStatus: Int
    let dividerColor: Color
    
    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading) {
            Text(isStarter == "1" ? "STARTERS" : "BENCH")
                .font(Font.custom("Futura-Bold", size: 14))
        }.padding(.leading, 10)
        
        Divider()
            .background(dividerColor)
        
        LazyVGrid(columns: columns, alignment: .leading) {
            let team = homeTeam ? boxScore.homeTeam : boxScore.awayTeam
            let players = team.players.filter { $0.starter == isStarter }
            
            ForEach(players) { player in
                PlayerRow(player: player, gameStatus: gameStatus, onTap: { playerProfileView = String(player.personId) })
            }
            .frame(height: 20)
        }
        .padding(.leading, 10)
        .sheet(item: $playerProfileView) { playerId in
            PlayerProfileView(playerId: playerId)
                .presentationDetents([.medium, .large])
        }
    }
}

// MARK: - Player Row View

struct PlayerRow: View {
    let player: Player
    let gameStatus: Int
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            Text(player.nameI).lineLimit(1)
            
            if player.starter == "1" {
                Text(player.position ?? "")
                    .foregroundStyle(Color(.lightGray))
            }
            
            if player.oncourt == "1" && gameStatus != 3 {
                Image(systemName: "circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 7.5)
                    .foregroundStyle(Color.red)
            }
        }
        .onTapGesture(perform: onTap)
    }
}

// MARK: - Statistics Section View

struct StatisticsSection: View {
    // MARK: - Constants
    private let columns: [GridItem] = [GridItem](repeating: GridItem(.flexible(minimum: 45)), count: 20)
    
    let boxScore: BoxScoreGame
    let homeTeam: Bool
    let isStarter: String
    let dividerColor: Color
    
    var body: some View {
        LazyVGrid(columns: columns) {
            Text("MIN")
            Text("PTS"); Text("REB"); Text("AST"); Text("STL"); Text("BLK")
            Text("FGM"); Text("FGA"); Text("FG%")
            Text("3PM"); Text("3PA"); Text("3P%")
            Text("FTM"); Text("FTA"); Text("FT%")
            Text("OREB"); Text("DREB")
            Text("TO")
            Text("FLS")
            Text("+/-")
        }
        .font(Font.custom("Futura-Bold", size: 14))
        .padding(.horizontal, 10)
        
        Divider()
            .background(dividerColor)
        
        LazyVGrid(columns: columns) {
            let team = homeTeam ? boxScore.homeTeam : boxScore.awayTeam
            let players = team.players.filter { $0.starter == isStarter }
            
            ForEach(players) { player in
                StatisticsRow(player: player)
            }
            .frame(height: 20)
        }
        .padding(.horizontal, 10)
    }
}

// MARK: - Statistics Row View

struct StatisticsRow: View {
    let player: Player
    
    var body: some View {
        Group {
            Text(getPlayerMinutes(player.statistics.minutes))
            Text(String(player.statistics.points))
            Text(String(player.statistics.reboundsTotal))
            Text(String(player.statistics.assists))
            Text(String(player.statistics.steals))
            Text(String(player.statistics.blocks))
            Text(String(player.statistics.fieldGoalsMade))
            Text(String(player.statistics.fieldGoalsAttempted))
            Text(String(getPercentage(player.statistics.fieldGoalsPercentage)))
            Text(String(player.statistics.threePointersMade))
            Text(String(player.statistics.threePointersAttempted))
            Text(String(getPercentage(player.statistics.threePointersPercentage)))
            Text(String(player.statistics.freeThrowsMade))
            Text(String(player.statistics.freeThrowsAttempted))
            Text(String(getPercentage(player.statistics.freeThrowsPercentage)))
            Text(String(player.statistics.reboundsOffensive))
            Text(String(player.statistics.reboundsDefensive))
            Text(String(player.statistics.turnovers))
            Text(String(player.statistics.foulsPersonal))
            Text(String(player.statistics.plusMinusPoints))
        }
    }
    
    // MARK: - Get Player Minutes
    
    private func getPlayerMinutes(_ timePlayed: String) -> String {
        let minutes = timePlayed.components(separatedBy: CharacterSet.decimalDigits.inverted)[2]
        let seconds = timePlayed.components(separatedBy: CharacterSet.decimalDigits.inverted)[3]
        return "\(minutes):\(seconds)"
    }
    
    // MARK: - Get Percentage
    
    private func getPercentage(_ value: Double) -> String {
        let doubleValue = value
        return String(format: "%.1f%%", doubleValue * 100)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        BoxScoreView(gameId: "0042300302")
    }
}
