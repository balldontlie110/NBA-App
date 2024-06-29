//
//  PlayByPlay.swift
//  NBA
//
//  Created by Ali Earp on 13/05/2024.
//

import Foundation

class PlayByPlayViewModel: ObservableObject {
    @Published var playByPlay: PlayByPlayGame?
    @Published var error: Error?
    
    func fetchPlayByPlay(gameId: String, endPeriod: String) {
        self.playByPlay = nil
        
        NBAService.fetchPlayByPlay(gameId: gameId, endPeriod: endPeriod) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let playByPlay):
                    self.playByPlay = playByPlay
                case .failure(let error):
                    self.error = error
                }
            }
        }
    }
}

struct PlayByPlay: Decodable {
    let game: PlayByPlayGame
}

struct PlayByPlayGame: Decodable {
    let actions: [Action]
}

struct Action: Decodable, Identifiable {
    
    var id: Int { actionId }
    
    let actionNumber: Int
    let clock: String
    let period, teamId: Int
    let teamTricode: String
    let personId: Int
    let playerName, playerNameI: String
    let xLegacy, yLegacy, shotDistance: Int
    let shotResult: String
    let isFieldGoal: Int
    let scoreHome, scoreAway: String
    let pointsTotal: Int
    let location, description, actionType, subType: String
    let videoAvailable, actionId: Int
    
}
