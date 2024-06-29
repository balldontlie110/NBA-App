//
//  AllTimeLeaders.swift
//  NBA
//
//  Created by Ali Earp on 13/05/2024.
//

import Foundation

class AllTimeLeadersViewModel: ObservableObject {
    @Published var allTimeLeaders: [String : [[String : String]]]?
    @Published var error: Error?
    
    func fetchAllTimeLeaders() {
        self.allTimeLeaders = nil
        
        NBAService.fetchAllTimeLeaders() { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let allTimeLeaders):
                    var sets: [String : [[String : String]]] = [:]
                    
                    for resultSet in allTimeLeaders.resultSets {
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
                    
                    self.allTimeLeaders = sets
                case .failure(let error):
                    self.error = error
                }
            }
        }
    }
}

struct AllTimeLeadersResponse: Decodable {
    let resultSets: [ResultSet]
}
