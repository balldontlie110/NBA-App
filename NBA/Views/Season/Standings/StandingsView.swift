//
//  StandingsView.swift
//  NBA
//
//  Created by Ali Earp on 11/05/2024.
//

import SwiftUI

struct StandingsView: View {
    // MARK: - State Variables
    @StateObject private var viewModel: StandingsViewModel = StandingsViewModel()
    
    // MARK: - Constants
    private let spacingHeight: CGFloat = 10
    private let paddingHorizontal: CGFloat = 10
    private let rankFontSize: CGFloat = 24
    private let rankText = "#"
    private let teamRowHeight: CGFloat = 55
    private let maxProgressFrame: CGFloat = .infinity
    
    var body: some View {
        VStack {
            if let standings = viewModel.standings {
                standingsContent(standings: standings)
            } else {
                ProgressView()
                    .frame(maxWidth: maxProgressFrame, maxHeight: maxProgressFrame)
            }
        }
        .onAppear {
            viewModel.fetchStandings()
        }
    }
    
    // MARK: - Standings Content
    
    private func standingsContent(standings: [[String : String]]) -> some View {
        ScrollView {
            Spacer().frame(height: spacingHeight)
            
            HStack {
                let western = standings.filter { $0["Conference"] == "West" && $0["PlayoffRank"] != "" }
                let eastern = standings.filter { $0["Conference"] == "East" && $0["PlayoffRank"] != "" }
                
                rankColumn
                
                Divider()
                
                ConferenceStandings(conferenceName: "WEST", conference: western)
                
                Spacer()
                
                ConferenceStandings(conferenceName: "EAST", conference: eastern)
            }
            .padding(.horizontal, paddingHorizontal)
            
            Spacer().frame(height: spacingHeight)
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Standings")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Rank Column
    
    private var rankColumn: some View {
        VStack(alignment: .center, spacing: 5) {
            Text(rankText)
                .font(Font.custom("Futura-CondensedExtraBold", size: rankFontSize))
            
            ForEach(1...15, id: \.self) { rank in
                Text(String(rank))
                    .foregroundStyle(Color(.lightGray))
                    .frame(height: teamRowHeight)
            }
        }
    }
}

struct ConferenceStandings: View {
    // MARK: - Constants
    private let titleFontSize: CGFloat = 24
    private let teamFontSize: CGFloat = 16
    private let recordFontSize: CGFloat = 12
    private let rowHeight: CGFloat = 55
    private let primaryColor = Color.primary
    private let lightGrayColor = Color(.lightGray)
    
    let conferenceName: String
    let conference: [[String : String]]
    
    var body: some View {
        VStack(alignment: conferenceName == "WEST" ? .leading : .trailing, spacing: 5) {
            Text(conferenceName)
                .font(Font.custom("Futura-CondensedExtraBold", size: titleFontSize))
            
            ForEach(sortedConference, id: \.self) { team in
                NavigationLink {
                    if let teamId = team["TeamID"] {
                        TeamProfileView(teamId: teamId)
                    }
                } label: {
                    teamRow(team: team)
                }
            }
        }
    }
    
    // MARK: - Sorted Conference
    
    private var sortedConference: [[String : String]] {
        conference.sorted { team1, team2 in
            Int(team1["PlayoffRank"] ?? "0") ?? 0 < Int(team2["PlayoffRank"] ?? "0") ?? 0
        }
    }
    
    // MARK: - Team Row
    
    private func teamRow(team: [String : String]) -> some View {
        HStack {
            if conferenceName == "WEST" {
                teamImage(team: team)
            }
            
            VStack(alignment: conferenceName == "WEST" ? .leading : .trailing) {
                teamName(team: team)
                teamRecord(team: team)
            }
            
            if conferenceName == "EAST" {
                teamImage(team: team)
            }
        }
        .lineLimit(1)
        .frame(height: rowHeight)
    }
    
    // MARK: - Team Image
    
    private func teamImage(team: [String : String]) -> some View {
        if let teamId = team["TeamID"] {
            return Image(teamId)
                .resizable()
                .scaledToFit()
                .eraseToAnyView()
        } else {
            return EmptyView().eraseToAnyView()
        }
    }
    
    // MARK: - Team Name
    
    private func teamName(team: [String : String]) -> some View {
        if let teamName = team["TeamName"] {
            return Text(teamName)
                .font(Font.custom("Futura", size: teamFontSize))
                .foregroundStyle(primaryColor)
                .eraseToAnyView()
        } else {
            return EmptyView().eraseToAnyView()
        }
    }
    
    // MARK: - Team Record
    
    private func teamRecord(team: [String : String]) -> some View {
        if let wins = team["WINS"], let losses = team["LOSSES"] {
            return Text("\(wins) - \(losses)")
                .foregroundStyle(lightGrayColor)
                .font(Font.custom("Futura", size: recordFontSize))
                .eraseToAnyView()
        } else {
            return EmptyView().eraseToAnyView()
        }
    }
}

// MARK: - Erase View Modifier

extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}

#Preview {
    StandingsView()
}












////
////  StandingsView.swift
////  NBA
////
////  Created by Ali Earp on 11/05/2024.
////
//
//import SwiftUI
//
//struct StandingsView: View {
//    @StateObject var viewModel: StandingsViewModel = StandingsViewModel()
//    
//    var body: some View {
//        VStack {
//            if let standings = viewModel.standings {
//                ScrollView {
//                    Spacer()
//                        .frame(height: 10)
//                    
//                    HStack {
//                        let western = standings.filter { $0["Conference"] == "West" && $0["PlayoffRank"] != "" }
//                        let eastern = standings.filter { $0["Conference"] == "East" && $0["PlayoffRank"] != "" }
//                        
//                        VStack(alignment: .center, spacing: 5) {
//                            Text("#")
//                                .font(Font.custom("Futura-CondensedExtraBold", size: 24))
//                            
//                            ForEach(1...15) { rank in
//                                Text(String(rank))
//                                    .foregroundStyle(Color(.lightGray))
//                                    .frame(height: 50)
//                            }
//                        }
//                        
//                        Divider()
//                        
//                        ConferenceStandings(conferenceName: "WEST", conference: western)
//                        
//                        Spacer()
//                        
//                        ConferenceStandings(conferenceName: "EAST", conference: eastern)
//                    }.padding(.horizontal, 10)
//                    
//                    Spacer()
//                        .frame(height: 10)
//                }
//                .scrollIndicators(.hidden)
//                .navigationTitle("Standings")
//                .navigationBarTitleDisplayMode(.inline)
//            } else {
//                ProgressView()
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//            }
//        }
//        .onAppear {
//            viewModel.fetchStandings()
//        }
//    }
//}
//
//struct ConferenceStandings: View {
//    let conferenceName: String
//    let conference: [[String : String]]
//    
//    var body: some View {
//        VStack(alignment: conferenceName == "WEST" ? .leading : .trailing, spacing: 5) {
//            Text(conferenceName)
//                .font(Font.custom("Futura-CondensedExtraBold", size: 24))
//            
//            ForEach(conference.sorted { team1, team2 in
//                Int(team1["PlayoffRank"] ?? "0") ?? 0 < Int(team2["PlayoffRank"] ?? "0") ?? 0
//            }, id: \.self) { team in
//                NavigationLink {
//                    if let teamId = team["TeamID"] {
//                        TeamProfileView(teamId: teamId)
//                    }
//                } label: {
//                    HStack {
//                        if conferenceName == "WEST" {
//                            if let teamId = team["TeamID"] {
//                                Image(teamId)
//                                    .resizable()
//                                    .scaledToFit()
//                            }
//                        }
//                        
//                        VStack(alignment: conferenceName == "WEST" ? .leading : .trailing) {
//                            if let teamName = team["TeamName"] {
//                                Text(teamName)
//                                    .font(Font.custom("Futura", size: 16))
//                                    .foregroundStyle(Color.primary)
//                            }
//                            
//                            if let wins = team["WINS"], let losses = team["LOSSES"] {
//                                Text("\(wins) - \(losses)")
//                                    .foregroundStyle(Color(.lightGray))
//                                    .font(Font.custom("Futura", size: 12))
//                            }
//                        }
//                        
//                        if conferenceName == "EAST" {
//                            if let teamId = team["TeamID"] {
//                                Image(teamId)
//                                    .resizable()
//                                    .scaledToFit()
//                            }
//                        }
//                    }
//                    .lineLimit(1)
//                    .frame(height: 50)
//                }
//            }
//        }
//    }
//}
//
//#Preview {
//    StandingsView()
//}
