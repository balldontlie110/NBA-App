//
//  GameSummaryView.swift
//  NBA
//
//  Created by Ali Earp on 03/05/2024.
//

import SwiftUI
import SDWebImageSwiftUI

struct GameSummaryView: View {
    // MARK: - State Objects
    @StateObject private var viewModel = BoxScoreViewModel()
    
    // MARK: - State Variables
    @State var playerProfileView: String?
    
    // MARK: - Constants
    private let sectionTitleFont = Font.custom("Futura-CondensedExtraBold", size: 24)
    private let sectionTitlePadding: Edge.Set = [.leading, .top]
    private let defaultPadding: CGFloat = 5
    private let imageWidth: CGFloat = 75
    private let periodFont = Font.custom("Futura", size: 14)
    private let topPerformerFont = Font.custom("Futura", size: 14)
    private let periodColumnFont = Font.custom("Futura-CondensedExtraBold", size: 32)
    private let periodLabelFont = Font.custom("Futura", size: 14)
    private let comparisonCardFont = Font.custom("Futura-Bold", size: 12)
    private let comparisonCardValueFont = Font.custom("Futura-CondensedExtraBold", size: 20)
    private let infoCardFont = Font.custom("Futura", size: 18)
    private let infoCardDetailFont = Font.custom("Futura", size: 14)
    private let imageHeight: CGFloat = 30
    private let maxPeriod = 4
    
    let gameId: String
    
    var body: some View {
        VStack(alignment: .leading) {
            if viewModel.boxScore != nil {
                ScrollView {
                    VStack(spacing: defaultPadding) {
                        PeriodSummaryView(viewModel: viewModel, periods: viewModel.boxScore?.period ?? 0 > maxPeriod ? viewModel.boxScore?.period ?? 0 : maxPeriod)
                        TopPerformersView(viewModel: viewModel, playerProfileView: $playerProfileView)
                        TeamComparisonView(viewModel: viewModel)
                        GameInfoView(viewModel: viewModel)
                    }
                    .padding(.horizontal, defaultPadding)
                    .padding(.top, defaultPadding)
                    
                    Spacer().frame(height: defaultPadding)
                }
                .scrollIndicators(.hidden)
                .refreshable {
                    refresh()
                }
            } else {
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            viewModel.fetchBoxScore(gameId: gameId)
        }
        .sheet(item: $playerProfileView) { playerId in
            PlayerProfileView(playerId: playerId)
                .presentationDetents([.medium, .large])
        }
    }
    
    // MARK: - Refresh Function
    
    private func refresh() {
        DispatchQueue.main.async {
            viewModel.fetchBoxScore(gameId: gameId)
        }
    }
}

// MARK: - Period Summary View

struct PeriodSummaryView: View {
    // MARK: - Constants
    private let sectionPadding: CGFloat = 5
    
    let viewModel: BoxScoreViewModel
    let periods: Int
    
    var body: some View {
        VStack {
            if let boxScore = viewModel.boxScore {
                let width = UIScreen.main.bounds.width / CGFloat((periods + 3))
                
                HStack {
                    Image("0")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: width, height: 30)
                    
                    ForEach(1...periods, id: \.self) { period in
                        Text(period > periods ? "OT\(period - periods)" : "Q\(period)")
                    }
                    .frame(width: width)
                    
                    Text("T").frame(width: width)
                }
                .foregroundStyle(Color(.lightGray))
                .font(Font.custom("Futura", size: 14))
                .padding(.top)
                
                TeamPeriodByPeriodRow(boxScore: boxScore, team: boxScore.homeTeam, width: width)
                TeamPeriodByPeriodRow(boxScore: boxScore, team: boxScore.awayTeam, width: width)
            }
        }
    }
}

// MARK: - Top Performers View

struct TopPerformersView: View {
    let viewModel: BoxScoreViewModel
    @Binding var playerProfileView: String?
    
    var body: some View {
        if let boxScore = viewModel.boxScore {
            VStack(alignment: .leading) {
                Text("TOP PERFORMERS")
                    .font(Font.custom("Futura-CondensedExtraBold", size: 24))
                    .padding([.leading, .top])
                
                Spacer()
                
                TopPerformer(
                    teamTricode: boxScore.homeTeam.teamTricode,
                    player: boxScore.homeTeam.players.max(by: { $0.statistics.points < $1.statistics.points })!,
                    onTap: { self.playerProfileView = String(boxScore.homeTeam.players.max(by: { $0.statistics.points < $1.statistics.points })!.personId) }
                )
                
                TopPerformer(
                    teamTricode: boxScore.awayTeam.teamTricode,
                    player: boxScore.awayTeam.players.max(by: { $0.statistics.points < $1.statistics.points })!,
                    onTap: { self.playerProfileView = String(boxScore.awayTeam.players.max(by: { $0.statistics.points < $1.statistics.points })!.personId) }
                )
            }
        }
    }
}

// MARK: - Team Comparison View

struct TeamComparisonView: View {
    // MARK: - Constants
    private let sectionPadding: CGFloat = 5
    
    let viewModel: BoxScoreViewModel
    
    var body: some View {
        if let boxScore = viewModel.boxScore {
            VStack(alignment: .leading) {
                Text("TEAM COMPARISON")
                    .font(Font.custom("Futura-CondensedExtraBold", size: 24))
                    .padding([.leading, .top])
                
                Spacer()
                
                let homeStats = boxScore.homeTeam.statistics
                let awayStats = boxScore.awayTeam.statistics
                
                TeamComparisonCards(type: "Field Goals", boxScore: boxScore, homeValue1: homeStats.fieldGoalsMade, homeValue2: homeStats.fieldGoalsAttempted, homeValue3: homeStats.fieldGoalsPercentage, awayValue1: awayStats.fieldGoalsMade, awayValue2: awayStats.fieldGoalsAttempted, awayValue3: awayStats.fieldGoalsPercentage)
                TeamComparisonCards(type: "3 Pointers", boxScore: boxScore, homeValue1: homeStats.threePointersMade, homeValue2: homeStats.threePointersAttempted, homeValue3: homeStats.threePointersPercentage, awayValue1: awayStats.threePointersMade, awayValue2: awayStats.threePointersAttempted, awayValue3: awayStats.threePointersPercentage)
                TeamComparisonCards(type: "Free Throws", boxScore: boxScore, homeValue1: homeStats.freeThrowsMade, homeValue2: homeStats.freeThrowsAttempted, homeValue3: homeStats.freeThrowsPercentage, awayValue1: awayStats.freeThrowsMade, awayValue2: awayStats.freeThrowsAttempted, awayValue3: awayStats.freeThrowsPercentage)
                TeamComparisonCards(type: "Assists", boxScore: boxScore, homeValue: homeStats.assists, awayValue: awayStats.assists)
                TeamComparisonCards(type: "Steals", boxScore: boxScore, homeValue: homeStats.steals, awayValue: awayStats.steals)
                TeamComparisonCards(type: "Blocks", boxScore: boxScore, homeValue: homeStats.blocks, awayValue: awayStats.blocks)
                TeamComparisonCards(type: "Total Rebounds", boxScore: boxScore, homeValue: homeStats.reboundsTotal, awayValue: awayStats.reboundsTotal)
                TeamComparisonCards(type: "Offensive Rebounds", boxScore: boxScore, homeValue: homeStats.reboundsOffensive, awayValue: awayStats.reboundsOffensive)
                TeamComparisonCards(type: "Defensive Rebounds", boxScore: boxScore, homeValue: homeStats.reboundsDefensive, awayValue: awayStats.reboundsDefensive)
                TeamComparisonCards(type: "Fast Break Points", boxScore: boxScore, homeValue: homeStats.pointsFastBreak, awayValue: awayStats.pointsFastBreak)
                TeamComparisonCards(type: "Second Chance Points", boxScore: boxScore, homeValue: homeStats.pointsSecondChance, awayValue: awayStats.pointsSecondChance)
                TeamComparisonCards(type: "Points Off Turnovers", boxScore: boxScore, homeValue: homeStats.pointsFromTurnovers, awayValue: awayStats.pointsFromTurnovers)
            }
        }
    }
}

private struct GameInfoView: View {
    // MARK: - Constants
    private let sectionPadding: CGFloat = 5
    
    let viewModel: BoxScoreViewModel
    
    var body: some View {
        if let boxScore = viewModel.boxScore {
            VStack(alignment: .leading) {
                Text("GAME INFO")
                    .font(Font.custom("Futura-CondensedExtraBold", size: 24))
                    .padding([.leading, .top])
                
                Spacer()
                
                GameInfoCard(type: boxScore.arena.arenaName, values: [boxScore.arena.arenaCity, boxScore.arena.arenaState])
                GameInfoCard(type: "Officials", values: boxScore.officials.map { $0.name })
            }
        }
    }
}

// MARK: - Top Performer

struct TopPerformer: View {
    // MARK: - Constants
    private let columns: [GridItem] = Array(repeating: GridItem(.flexible()), count: 3)
    private let performerFont = Font.custom("Futura", size: 14)
    private let performerTitleFont = Font.custom("Futura-CondensedExtraBold", size: 32)
    private let performerSubtitleFont = Font.custom("Futura", size: 14)
    private let performerBackgroundColor = Color(.systemGray5)
    private let performerImageWidth: CGFloat = 75
    private let performerFrameWidth: CGFloat = 125
    private let performerMaxWidth: CGFloat = .infinity
    private let performerPadding: CGFloat = 10
    
    let teamTricode: String
    let player: Player
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            performerBackgroundColor.clipShape(RoundedRectangle(cornerRadius: 10))
            
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    Spacer()
                    
                    WebImage(url: URL(string: "https://cdn.nba.com/headshots/nba/latest/260x190/\(player.personId).png"))
                        .resizable()
                        .scaledToFit()
                        .frame(width: performerImageWidth)
                        .background(Color.black)
                        .clipShape(Circle())
                    
                    Spacer()
                    
                    Text(player.name)
                    
                    HStack {
                        Text(teamTricode)
                        
                        Divider()
                        
                        Text("#\(player.jerseyNum)")
                        
                        if let position = player.position {
                            Divider()
                            Text(position)
                        }
                    }.foregroundStyle(Color(.lightGray))
                    
                    Spacer()
                }
                .font(performerFont)
                .multilineTextAlignment(.center)
                .frame(maxWidth: performerFrameWidth)
                
                LazyVGrid(columns: columns) {
                    Group {
                        Text(String(player.statistics.points))
                        Text(String(player.statistics.reboundsTotal))
                        Text(String(player.statistics.assists))
                    }
                    .font(performerTitleFont)
                    
                    Group {
                        Text("PTS")
                        Text("REB")
                        Text("AST")
                    }
                    .font(performerSubtitleFont)
                    .foregroundStyle(Color(.lightGray))
                }
                .frame(maxWidth: performerMaxWidth)
                .padding(.leading, 30)
            }
            .padding(.horizontal, performerPadding)
            .padding(.vertical)
        }
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Team Comparison Cards

struct TeamComparisonCards: View {
    // MARK: - Constants
    private let comparisonCardSpacing: CGFloat = 5
    
    let type: String
    let homeTricode: String
    let awayTricode: String
    
    let homeValue1: Int
    let homeValue2: Int
    let homeValue3: Double?
    
    let awayValue1: Int
    let awayValue2: Int
    let awayValue3: Double?
    
    // MARK: - Initializer 1
    init(type: String, boxScore: BoxScoreGame, homeValue: Int, awayValue: Int) {
        self.type = type
        self.homeTricode = boxScore.homeTeam.teamTricode
        self.awayTricode = boxScore.awayTeam.teamTricode
        self.homeValue1 = homeValue
        self.awayValue2 = homeValue
        self.awayValue1 = awayValue
        self.homeValue2 = awayValue
        self.homeValue3 = nil
        self.awayValue3 = nil
    }
    
    // MARK: - Initializer 2
    init(type: String, boxScore: BoxScoreGame, homeValue1: Int, homeValue2: Int, homeValue3: Double, awayValue1: Int, awayValue2: Int, awayValue3: Double) {
        self.type = type
        self.homeTricode = boxScore.homeTeam.teamTricode
        self.awayTricode = boxScore.awayTeam.teamTricode
        self.homeValue1 = homeValue1
        self.homeValue2 = homeValue2
        self.homeValue3 = homeValue3
        self.awayValue1 = awayValue1
        self.awayValue2 = awayValue2
        self.awayValue3 = awayValue3
    }
    
    var body: some View {
        HStack(spacing: comparisonCardSpacing) {
            TeamComparisonCard(
                type: type,
                tricode: homeTricode,
                value1: homeValue1,
                value2: homeValue2,
                value3: homeValue3,
                color: homeValue3 != nil ? (homeValue3! > (awayValue3 ?? 0) ? .green : .red) : (homeValue1 > awayValue1 ? .green : .red)
            )
            
            TeamComparisonCard(
                type: type,
                tricode: awayTricode,
                value1: awayValue1,
                value2: awayValue2,
                value3: awayValue3,
                color: awayValue3 != nil ? (awayValue3! > (homeValue3 ?? 0) ? .green : .red) : (awayValue1 > homeValue1 ? .green : .red)
            )
        }
    }
}

// MARK: - Team Comparison Card

struct TeamComparisonCard: View {
    // MARK: - Constants
    private let cardFont = Font.custom("Futura-Bold", size: 12)
    private let cardValueFont = Font.custom("Futura-CondensedExtraBold", size: 20)
    private let cardBackgroundColor = Color(.systemGray5)
    private let cardPadding: CGFloat = 10
    
    let type: String
    let tricode: String
    let value1: Int
    let value2: Int
    let value3: Double?
    let color: Color
    
    var body: some View {
        ZStack {
            cardBackgroundColor.clipShape(RoundedRectangle(cornerRadius: 5))
            
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    Text(type)
                        .foregroundStyle(Color(.lightGray))
                        .font(cardFont)
                    
                    Spacer()
                    
                    if let value3 = value3 {
                        Text("\(String(format: "%.1f", value3))%")
                            .font(cardValueFont)
                    } else {
                        Text(String(value1))
                            .font(cardValueFont)
                    }
                }
                .padding(.bottom, 5)
                
                HStack(alignment: .bottom) {
                    Text(tricode)
                    
                    Spacer()
                    
                    if value3 != nil {
                        Text("\(value1)/\(value2)")
                    }
                }
                .font(cardFont)
                .padding(.bottom, -10)
                
                ProgressView("", value: Double(min(value1, value2)), total: Double(max(value1, value2)))
                    .tint(color)
            }
            .padding(cardPadding)
        }
    }
}

// MARK: - Game Info Card

struct GameInfoCard: View {
    // MARK: - Constants
    private let infoFont = Font.custom("Futura", size: 18)
    private let detailFont = Font.custom("Futura", size: 14)
    private let cardBackgroundColor = Color(.systemGray5)
    private let cardPadding: CGFloat = 10
    
    let type: String
    let values: [String]
    
    var body: some View {
        ZStack {
            cardBackgroundColor.clipShape(RoundedRectangle(cornerRadius: 5))
            
            HStack {
                VStack(alignment: .leading) {
                    Text(type).font(infoFont)
                    
                    Text(values.joined(separator: ", "))
                        .foregroundStyle(Color(.lightGray))
                        .font(detailFont)
                }
                .padding(cardPadding)
                
                Spacer()
            }
        }
    }
}

// MARK: - Team Period By Period Row

struct TeamPeriodByPeriodRow: View {
    let boxScore: BoxScoreGame
    let team: BoxScoreTeam
    let width: CGFloat
    
    var body: some View {
        HStack {
            Image(String(team.teamId))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: width, height: 30)
            
            ForEach(0..<team.periods.count, id: \.id) { period in
                if period < boxScore.period {
                    Text(String(team.periods[period].score))
                } else {
                    Text("-")
                }
            }
            .frame(width: width)
            .font(Font.custom("Futura", size: 16))
            
            
            Text(String(team.score))
                .font(Font.custom("Futura-CondensedExtraBold", size: 24))
                .frame(width: width)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        GameSummaryView(gameId: "0042300302")
    }
}
