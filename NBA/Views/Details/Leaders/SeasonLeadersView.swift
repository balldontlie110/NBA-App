//
//  SeasonLeadersView.swift
//  NBA
//
//  Created by Ali Earp on 15/05/2024.
//

import SwiftUI
import SDWebImageSwiftUI

struct SeasonLeadersView: View {
    @StateObject private var viewModel: SeasonLeadersViewModel = SeasonLeadersViewModel()
    
    @State var playerProfileView: String?
    
    @State var date: Int = 0
    
    var currentYear: Int {
        let components = Calendar.current.dateComponents([.year, .month], from: Date())
        if let year = components.year, let month = components.month {
            return month < 7 ? year - 1 : year
        } else {
            return 1951
        }
    }
    
    @State var statType: String = "PTS"
    
    let statTypesShort: [String] = [
        "PTS",
        "REB",
        "AST",
        "BLK",
        "STL",
        "MIN",
        "OREB",
        "DREB",
        "TOV",
        "PF",
        "FGM",
        "FGA",
        "FG_PCT",
        "FG3M",
        "FG3A",
        "FG3_PCT",
        "FTM",
        "FTA",
        "FT_PCT"
    ]
    
    let statTypesLong: [String : String] = [
        "PTS" : "Points",
        "REB" : "Rebounds",
        "AST" : "Assists",
        "BLK" : "Blocks",
        "STL" : "Steals",
        "MIN" : "Minutes",
        "OREB" : "Offensive Rebounds",
        "DREB" : "Defensive Rebounds",
        "TOV" : "Turnovers",
        "PF" : "Fouls",
        "FGM" : "Field Goal Makes",
        "FGA" : "Field Goal Attempts",
        "FG_PCT" : "Field Goal Percentage",
        "FG3M" : "Three Point Makes",
        "FG3A" : "Three Point Attempts",
        "FG3_PCT" : "Three Point Percentage",
        "FTM" : "Free Throw Makes",
        "FTA" : "Free Throw Attempts",
        "FT_PCT" : "Free Throw Percentage"
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Picker("", selection: $date) {
                    ForEach(1949...currentYear) { year in
                        Text("\(String(year)) - \(String(year + 1))")
                            .font(Font.custom("Futura", size: 14))
                            .tag(year)
                    }
                }.pickerStyle(.wheel)
                
                Menu {
                    ForEach(statTypesShort) { statType in
                        Button {
                            self.statType = statType
                        } label: {
                            HStack {
                                if let statTypeLong = statTypesLong[statType] {
                                    Text(statTypeLong)
                                }
                                
                                Spacer()
                                
                                if self.statType == statType {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundStyle(Color.primary)
                        .font(.system(size: 20))
                }
            }
            .frame(height: 100)
            .padding(.horizontal)
            
            Divider()
            
            if viewModel.seasonLeaders != nil {
                VStack(spacing: 0) {
                    ScrollView {
                        LazyVStack(spacing: 5) {
                            Spacer()
                                .frame(height: 5)
                            
                            if let seasonLeaders = viewModel.seasonLeaders {
                                ForEach(seasonLeaders, id: \.self) { player in
                                    if let rank = player["RANK"], let name = player["PLAYER"], let playerId = player["PLAYER_ID"], let statValue = player[statType] {
                                        ZStack {
                                            Color(.systemGray6)
                                            
                                            HStack(spacing: 0) {
                                                ZStack {
                                                    Color.black
                                                    
                                                    WebImage(url: URL(string: "https://cdn.nba.com/headshots/nba/latest/260x190/\(playerId).png"))
                                                        .resizable()
                                                        .scaledToFit()
                                                        .clipShape(Circle())
                                                        .padding(-5)
                                                }
                                                .clipShape(Circle())
                                                .frame(width: 40, height: 40)
                                                .padding(.leading, 5)
                                                
                                                Text("\(rank). \(name)")
                                                    .font(Font.custom("Futura-CondensedExtraBold", size: 20))
                                                    .foregroundStyle(Color.primary)
                                                    .lineLimit(1)
                                                    .padding(.leading)
                                                
                                                Spacer()
                                                
                                                Group {
                                                    if !statType.contains("PCT") {
                                                        Text("\(Int(statValue) ?? 0) \(statType)")
                                                    } else {
                                                        if let statValue = Double(statValue) {
                                                            let percentage = String(round(statValue * 1000) / 10.0)
                                                            Text("\(percentage)\(statType.dropLast(3))%")
                                                        }
                                                    }
                                                }
                                                .font(Font.custom("Futura", size: 16))
                                                .foregroundStyle(Color(.lightGray))
                                            }
                                            .frame(height: 50)
                                            .padding(.horizontal, 5)
                                            .padding(5)
                                        }
                                        .clipShape(RoundedRectangle(cornerRadius: 5))
                                        .padding(.horizontal, 5)
                                        .onTapGesture {
                                            self.playerProfileView = playerId
                                        }
                                    }
                                }
                            }
                            
                            Spacer()
                                .frame(height: 55)
                        }
                    }
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            self.date = currentYear
            viewModel.fetchSeasonLeaders(statType: statType, date: date)
        }
        .onChange(of: statType) { _, _ in
            viewModel.fetchSeasonLeaders(statType: statType, date: date)
        }
        .onChange(of: date) { _, _ in
            viewModel.fetchSeasonLeaders(statType: statType, date: date)
        }
        .sheet(item: $playerProfileView) { playerId in
            PlayerProfileView(playerId: playerId)
                .presentationDetents([.medium, .large])
        }
    }
}

#Preview {
    NavigationStack {
        SeasonLeadersView()
    }
}
