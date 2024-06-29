//
//  Standings.swift
//  NBA
//
//  Created by Ali Earp on 11/05/2024.
//

import Foundation

class StandingsViewModel: ObservableObject {
    @Published var standings: [[String : String]]?
    @Published var error: Error?
    
    func fetchStandings() {
        NBAService.fetchStandings { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let standingsResponse):
                    if let standings = standingsResponse.resultSets.first(where: { $0.name == "Standings" }) {
                        let headers = standings.headers
                        
                        var dictionaries: [[String : String]] = [[:]]
                        
                        for rowSet in standings.rowSet {
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
                        
                        self.standings = dictionaries
                    }
                case .failure(let error):
                    self.error = error
                }
            }
        }
    }
}

struct StandingsResponse: Decodable {
    
    let resultSets: [ResultSet]
    
}
