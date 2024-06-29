//
//  AllTeams.swift
//  NBA
//
//  Created by Ali Earp on 06/05/2024.
//

import Foundation

class AllTeamsViewModel: ObservableObject {
    @Published var allTeams: [Team]?
    @Published var error: Error?
    
    func fetchAllTeams() {
        if let path = Bundle.main.path(forResource: "AllTeams", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let decoder = JSONDecoder()
                self.allTeams = try decoder.decode([Team].self, from: data)
            } catch {
                self.error = error
            }
        }
    }
}

struct Team: Decodable, Identifiable, Equatable {
    
    var id: Int { teamId }
    
    let teamId: Int
    let abbreviation: String
    let teamName: String
    let simpleName: String
    let location: String
    
    static func ==(lhs: Team, rhs: Team) -> Bool {
        return lhs.id == rhs.id
    }
    
}
