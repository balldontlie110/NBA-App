//
//  PlayerInfo.swift
//  NBA
//
//  Created by Ali Earp on 05/05/2024.
//

import Foundation

class PlayerInfoViewModel: ObservableObject {
    @Published var playerStats: [String : [[String : String]]]?
    @Published var playerAwards: [String]?
    @Published var playerInfo: [String : String]?
    @Published var error: Error?
    
    func fetchPlayerInformation(playerId: String) {
        NBAService.fetchPlayerStats(playerId: playerId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let playerStats):
                    var sets: [String : [[String : String]]] = [:]
                    
                    for resultSet in playerStats.resultSets {
                        let name = resultSet.name
                        let headers = resultSet.headers
                        
                        var dictionaries: [[String : String]] = []
                        
                        for rowSet in resultSet.rowSet {
                            var values: [String] = []
                            for row in rowSet {
                                if case let .int(i) = row {
                                    values.append(String(i))
                                } else if case let .double(i) = row {
                                    values.append(String(i))
                                } else if case let .string(i) = row {
                                    values.append(i)
                                } else {
                                    values.append("")
                                }
                            }
                            
                            let dictionary = Dictionary(uniqueKeysWithValues: zip(headers, values))
                            dictionaries.append(dictionary)
                        }
                        
                        sets[name] = dictionaries
                    }
                    
                    self.playerStats = sets
                case .failure(let error):
                    self.error = error
                }
            }
        }
        
        NBAService.fetchPlayerAwards(playerId: playerId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let playerAwards):
                    if let playerAwards = playerAwards.resultSets.first(where: { $0.name == "PlayerAwards" }) {
                        var descriptions: [String] = []
                        for rowSet in playerAwards.rowSet {
                            if case let .string(i) = rowSet[4] {
                                descriptions.append(String(i))
                            }
                        }
                        
                        self.playerAwards = descriptions
                    }
                case .failure(let error):
                    self.error = error
                }
            }
        }
        
        NBAService.fetchPlayerInfo(playerId: playerId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let playerInfo):
                    if let commonPlayerInfo = playerInfo.resultSets.first(where: { $0.name == "CommonPlayerInfo" }) {
                        let headers = commonPlayerInfo.headers
                        if let rowSet = commonPlayerInfo.rowSet.last {
                            var values: [String] = []
                            for row in rowSet {
                                if case let .int(i) = row {
                                    values.append(String(i))
                                } else if case let .double(i) = row {
                                    values.append(String(i))
                                } else if case let .string(i) = row {
                                    values.append(i)
                                } else {
                                    values.append("")
                                }
                            }
                            
                            let dictionary = Dictionary(uniqueKeysWithValues: zip(headers, values))
                            self.playerInfo = dictionary
                        }
                    }
                case .failure(let error):
                    self.error = error
                }
            }
        }
    }
}

struct PlayerStatsResponse: Decodable {
    
    let resultSets: [ResultSet]
    
}

struct PlayerAwardsResponse: Decodable {
    
    let resultSets: [ResultSet]
    
}

struct PlayerInfoResponse: Decodable {
    
    let resultSets: [ResultSet]
    
}
