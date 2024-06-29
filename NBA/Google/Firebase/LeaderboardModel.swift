//
//  LeaderboardModel.swift
//  NBA
//
//  Created by Ali Earp on 26/05/2024.
//

import Foundation
import FirebaseFirestore

struct Leader: Identifiable {
    var id: String { uid }
    
    let uid: String
    let username: String
    let photoURL: String
    let totalCorrect: Int
    let totalIncorrect: Int
    let rank: Int
    
    init(data: [String : Any], rank: Int, documentID: String) {
        self.uid = documentID
        self.rank = rank
        self.username = data["username"] as? String ?? ""
        self.photoURL = data["photoURL"] as? String ?? ""
        self.totalCorrect = data["totalCorrect"] as? Int ?? 0
        self.totalIncorrect = data["totalIncorrect"] as? Int ?? 0
    }
    
    static func == (lhs: Leader, rhs: Leader) -> Bool {
        return lhs.id == rhs.id
    }
}

class LeaderboardModel: ObservableObject {
    @Published var leaderboard: [Leader] = []
    
    init() {
        Task {
            try await getLeaderboard()
        }
    }
    
    @MainActor
    func getLeaderboard() async throws {
        let usersSnapshot = try await Firestore.firestore().collection("users").order(by: "totalCorrect", descending: true).getDocuments()
        
        var rank: Int = 1
        usersSnapshot.documents.forEach { userSnapshot in
            let leader = Leader(data: userSnapshot.data(), rank: rank, documentID: userSnapshot.documentID)
            self.leaderboard.append(leader)
            
            rank += 1
        }
    }
}
