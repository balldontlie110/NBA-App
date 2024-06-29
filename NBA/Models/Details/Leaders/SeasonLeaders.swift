//
//  SeasonLeaders.swift
//  NBA
//
//  Created by Ali Earp on 15/05/2024.
//

import Foundation

class SeasonLeadersViewModel: ObservableObject {
    @Published var seasonLeaders: [[String : String]]?
    @Published var error: Error?
    
    func fetchSeasonLeaders(statType: String, date: Int) {
        self.seasonLeaders = nil
        
        NBAService.fetchSeasonLeaders(statType: statType, date: date) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let currentLeaders):
                    let leagueLeaders = currentLeaders.resultSet
                    let headers = leagueLeaders.headers
                    
                    var dictionaries: [[String : String]] = [[:]]
                    
                    for rowSet in leagueLeaders.rowSet {
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
                    
                    self.seasonLeaders = dictionaries
                case .failure(let error):
                    self.error = error
                    print(error)
                }
            }
        }
    }
}

struct SeasonLeadersResponse: Decodable {
    let resultSet: ResultSet
}
