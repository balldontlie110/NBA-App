//
//  BoxScore.swift
//  NBA
//
//  Created by Ali Earp on 20/03/2024.
//

import Foundation

class BoxScoreViewModel: ObservableObject {
    @Published var boxScore: BoxScoreGame?
    @Published var error: String?
    
    func fetchBoxScore(gameId: String) {
        self.boxScore = nil
        
        NBAService.fetchBoxScore(gameId: gameId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let boxScore):
                    self.boxScore = boxScore
                case .failure(_):
                    self.error = "No game data available"
                }
            }
        }
    }
}

struct BoxScoreResponse: Decodable {
    let meta: Meta
    let game: BoxScoreGame
}

struct Meta: Decodable {
    let version: Int
    let request: String
    let time: String
    let code: Int
}

struct BoxScoreGame: Decodable {
    let gameId: String
    let gameTimeLocal, gameTimeUTC, gameTimeHome, gameTimeAway: String
    let gameEt: String
    let duration: Int
    let gameCode, gameStatusText: String
    let gameStatus, regulationPeriods, period: Int
    let gameClock: String
    let attendance: Int
    let sellout: String
    let arena: Arena
    let officials: [Official]
    let homeTeam, awayTeam: BoxScoreTeam
}

struct Arena: Decodable {
    let arenaId: Int
    let arenaName, arenaCity, arenaState, arenaCountry: String
    let arenaTimezone: String
}

struct BoxScoreTeam: Decodable {
    let teamId: Int
    let teamName, teamCity, teamTricode: String
    let score: Int
    let inBonus: String
    let timeoutsRemaining: Int
    let periods: [Period]
    let players: [Player]
    let statistics: TeamStatistics
}

struct Period: Decodable {
    let period: Int
    let periodType: String
    let score: Int
}

struct Player: Decodable, Identifiable {
    
    var id: Int { personId }
    
    let status: Status
    let order, personId: Int
    let jerseyNum: String
    let position: String?
    let starter, oncourt, played: String
    let statistics: PlayerStatistics
    let name, nameI, firstName, familyName: String
    let notPlayingReason, notPlayingDescription: String?
}

struct PlayerStatistics: Codable {
    let assists, blocks, blocksReceived, fieldGoalsAttempted: Int
    let fieldGoalsMade: Int
    let fieldGoalsPercentage: Double
    let foulsOffensive, foulsDrawn, foulsPersonal, foulsTechnical: Int
    let freeThrowsAttempted, freeThrowsMade: Int
    let freeThrowsPercentage: Double
    let minus: Int
    let minutes, minutesCalculated: String
    let plus, plusMinusPoints, points, pointsFastBreak: Int
    let pointsInThePaint, pointsSecondChance, reboundsDefensive, reboundsOffensive: Int
    let reboundsTotal, steals, threePointersAttempted, threePointersMade: Int
    let threePointersPercentage: Double
    let turnovers, twoPointersAttempted, twoPointersMade: Int
    let twoPointersPercentage: Double
}

enum Status: String, Decodable {
    case active = "ACTIVE"
    case inactive = "INACTIVE"
}

struct TeamStatistics: Decodable {
    let assists: Int
    let assistsTurnoverRatio: Double
    let benchPoints, biggestLead: Int
    let biggestLeadScore: String
    let biggestScoringRun: Int
    let biggestScoringRunScore: String
    let blocks, blocksReceived, fastBreakPointsAttempted, fastBreakPointsMade: Int
    let fastBreakPointsPercentage: Double
    let fieldGoalsAttempted: Int
    let fieldGoalsEffectiveAdjusted: Double
    let fieldGoalsMade: Int
    let fieldGoalsPercentage: Double
    let foulsOffensive, foulsDrawn, foulsPersonal, foulsTeam: Int
    let foulsTechnical, foulsTeamTechnical, freeThrowsAttempted, freeThrowsMade: Int
    let freeThrowsPercentage: Double
    let leadChanges: Int
    let minutes, minutesCalculated: String
    let points, pointsAgainst, pointsFastBreak, pointsFromTurnovers: Int
    let pointsInThePaint, pointsInThePaintAttempted, pointsInThePaintMade: Int
    let pointsInThePaintPercentage: Double
    let pointsSecondChance, reboundsDefensive, reboundsOffensive, reboundsPersonal: Int
    let reboundsTeam, reboundsTeamDefensive, reboundsTeamOffensive, reboundsTotal: Int
    let secondChancePointsAttempted, secondChancePointsMade: Int
    let secondChancePointsPercentage: Double
    let steals, threePointersAttempted, threePointersMade: Int
    let threePointersPercentage: Double
    let timeLeading: String
    let timesTied: Int
    let trueShootingAttempts, trueShootingPercentage: Double
    let turnovers, turnoversTeam, turnoversTotal, twoPointersAttempted: Int
    let twoPointersMade: Int
    let twoPointersPercentage: Double
}

struct Official: Decodable {
    let personId: Int
    let name, nameI, firstName, familyName: String
    let jerseyNum, assignment: String
}
