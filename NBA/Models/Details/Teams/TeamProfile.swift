//
//  TeamProfile.swift
//  NBA
//
//  Created by Ali Earp on 08/05/2024.
//

import Foundation

class TeamProfileViewModel: ObservableObject {
    @Published var teamProfile: [String : [[String : String]]]?
    @Published var franchiseLeaders: [[String : String]]?
    @Published var error: Error?
    
    func fetchTeamProfile(teamId: String) {
        NBAService.fetchTeamProfile(teamId: teamId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let teamProfile):
                    var sets: [String : [[String : String]]] = [:]
                    
                    for resultSet in teamProfile.resultSets {
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
                    
                    self.teamProfile = sets
                case .failure(let error):
                    self.error = error
                }
            }
        }
        
        NBAService.fetchFranchiseLeaders(teamId: teamId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let franchiseLeaders):
                    if let franchiseLeaders = franchiseLeaders.resultSets.first(where: { $0.name == "FranchiseLeaders" }) {
                        let headers = franchiseLeaders.headers
                        
                        var dictionaries: [[String : String]] = [[:]]
                        
                        for rowSet in franchiseLeaders.rowSet {
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
                        
                        self.franchiseLeaders = dictionaries
                    }
                case .failure(let error):
                    self.error = error
                }
            }
        }
    }
}

struct TeamProfileResponse: Decodable {
    
    let resultSets: [ResultSet]
    
}

struct FranchiseLeadersResponse: Decodable {
    
    let resultSets: [ResultSet]
    
}
