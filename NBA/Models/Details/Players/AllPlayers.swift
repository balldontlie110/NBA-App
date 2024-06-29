//
//  AllPlayers.swift
//  NBA
//
//  Created by Ali Earp on 05/05/2024.
//

import Foundation

class AllPlayersViewModel: ObservableObject {
    @Published var allPlayers: [[String : String]]?
    @Published var error: Error?
    
    func fetchAllPlayers() {
        NBAService.fetchAllPlayers() { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let allPlayers):
                    if let commonAllPlayers = allPlayers.resultSets.first(where: { $0.name == "CommonAllPlayers" }) {
                        let headers = commonAllPlayers.headers
                        
                        var dictionaries: [[String : String]] = [[:]]
                        
                        for rowSet in commonAllPlayers.rowSet {
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
                        
                        self.allPlayers = dictionaries
                    }
                case .failure(let error):
                    self.error = error
                }
            }
        }
    }
}

struct AllPlayersResponse: Decodable {
    
    let resultSets: [ResultSet]
    
}
