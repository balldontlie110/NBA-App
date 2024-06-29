//
//  Scoreboard.swift
//  NBA
//
//  Created by Ali Earp on 20/03/2024.
//

import Foundation

class ScoreboardViewModel: ObservableObject {
    @Published var gameHeaders: [[String : String]]?
    @Published var lineScore: [[String : String]]?
    @Published var teamLeaders: [[String : String]]?
    @Published var error: String?
    
    func fetchGames(date: Date) {
        self.gameHeaders = nil
        self.lineScore = nil
        
        NBAService.fetchGames(date: date) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let scoreboard):
                    if let gameHeader = scoreboard.resultSets.first(where: { $0.name == "GameHeader" }) {
                        let headers = gameHeader.headers
                        
                        var dictionaries: [[String : String]] = [[:]]
                        
                        for rowSet in gameHeader.rowSet {
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
                        
                        self.gameHeaders = dictionaries
                    }
                    
                    if let lineScore = scoreboard.resultSets.first(where: { $0.name == "LineScore" }) {
                        let headers = lineScore.headers
                        
                        var dictionaries: [[String : String]] = [[:]]
                        
                        for rowSet in lineScore.rowSet {
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
                        
                        self.lineScore = dictionaries
                    }
                    
                    if let teamLeaders = scoreboard.resultSets.first(where: { $0.name == "TeamLeaders" }) {
                        let headers = teamLeaders.headers
                        
                        var dictionaries: [[String : String]] = [[:]]
                        
                        for rowSet in teamLeaders.rowSet {
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
                        
                        self.teamLeaders = dictionaries
                    }
                case .failure(_):
                    self.error = "No games available"
                }
            }
        }
    }
}

struct ScoreboardResponse: Decodable {
    
    let resultSets: [ResultSet]
    
}
