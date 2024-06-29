//
//  AllTimeLeadersView.swift
//  NBA
//
//  Created by Ali Earp on 13/05/2024.
//

import SwiftUI
import SDWebImageSwiftUI

struct AllTimeLeadersView: View {
    @StateObject var viewModel: AllTimeLeadersViewModel = AllTimeLeadersViewModel()
    
    @State var playerProfileView: String?
    
    var body: some View {
        VStack {
            if viewModel.allTimeLeaders != nil {
                ScrollView {
                    LazyVStack(spacing: 5) {
                        Spacer()
                            .frame(height: 5)
                        
                        if let allTimeLeaders = viewModel.allTimeLeaders {
                            CategoryLeaders(allTimeLeaders: allTimeLeaders, type: "PTS", typeLong: "Points", playerProfileView: $playerProfileView)
                            CategoryLeaders(allTimeLeaders: allTimeLeaders, type: "REB", typeLong: "Rebounds", playerProfileView: $playerProfileView)
                            CategoryLeaders(allTimeLeaders: allTimeLeaders, type: "AST", typeLong: "Assists", playerProfileView: $playerProfileView)
                            CategoryLeaders(allTimeLeaders: allTimeLeaders, type: "BLK", typeLong: "Blocks", playerProfileView: $playerProfileView)
                            CategoryLeaders(allTimeLeaders: allTimeLeaders, type: "STL", typeLong: "Steals", playerProfileView: $playerProfileView)
                            CategoryLeaders(allTimeLeaders: allTimeLeaders, type: "TOV", typeLong: "Turnovers", playerProfileView: $playerProfileView)
                            CategoryLeaders(allTimeLeaders: allTimeLeaders, type: "FLS", typeLong: "Fouls", playerProfileView: $playerProfileView)
                            CategoryLeaders(allTimeLeaders: allTimeLeaders, type: "OREB", typeLong: "Offensive Rebounds", playerProfileView: $playerProfileView)
                            CategoryLeaders(allTimeLeaders: allTimeLeaders, type: "DREB", typeLong: "Defensive Rebounds", playerProfileView: $playerProfileView)
                            CategoryLeaders(allTimeLeaders: allTimeLeaders, type: "FGM", typeLong: "Field Goal Makes", playerProfileView: $playerProfileView)
                            CategoryLeaders(allTimeLeaders: allTimeLeaders, type: "FGA", typeLong: "Field Goal Attempts", playerProfileView: $playerProfileView)
                            CategoryLeaders(allTimeLeaders: allTimeLeaders, type: "FG_PCT", typeLong: "Field Goal Percentage", playerProfileView: $playerProfileView)
                            CategoryLeaders(allTimeLeaders: allTimeLeaders, type: "FG3M", typeLong: "Three Point Makes", playerProfileView: $playerProfileView)
                            CategoryLeaders(allTimeLeaders: allTimeLeaders, type: "FG3A", typeLong: "Three Point Attempts", playerProfileView: $playerProfileView)
                            CategoryLeaders(allTimeLeaders: allTimeLeaders, type: "FG3_PCT", typeLong: "Three Point Percentage", playerProfileView: $playerProfileView)
                            CategoryLeaders(allTimeLeaders: allTimeLeaders, type: "FTM", typeLong: "Free Throw Makes", playerProfileView: $playerProfileView)
                            CategoryLeaders(allTimeLeaders: allTimeLeaders, type: "FTA", typeLong: "Free Throw Attempts", playerProfileView: $playerProfileView)
                            CategoryLeaders(allTimeLeaders: allTimeLeaders, type: "FT_PCT", typeLong: "Free Throw Percentage", playerProfileView: $playerProfileView)
                        }
                        
                        Spacer()
                            .frame(height: 55)
                    }
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            viewModel.fetchAllTimeLeaders()
        }
        .sheet(item: $playerProfileView) { playerId in
            PlayerProfileView(playerId: playerId)
                .presentationDetents([.medium, .large])
        }
    }
}

struct CategoryLeaders: View {
    let allTimeLeaders: [String : [[String : String]]]
    
    let type: String
    let typeLong: String
    
    @Binding var playerProfileView: String?
    
    var body: some View {
        Group {
            if let category = allTimeLeaders["\(type)Leaders"] {
                HStack {
                    Text(typeLong)
                        .font(Font.custom("Futura-CondensedExtraBold", size: 24))
                    
                    Spacer()
                }.padding(.horizontal)
                
                LazyVStack(spacing: 5) {
                    ForEach(category, id: \.self) { player in
                        if let name = player["PLAYER_NAME"], let playerId = player["PLAYER_ID"], let statValue = player[type], let rank = player["\(type)_RANK"] {
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
                                        if !type.contains("PCT") {
                                            Text("\(Int(statValue) ?? 0) \(type)")
                                        } else {
                                            if let statValue = Double(statValue) {
                                                let percentage = String(round(statValue * 1000) / 10.0)
                                                Text("\(percentage)%")
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
                
                if type != "FT_PCT" {
                    Divider()
                        .frame(height: 2.5)
                        .background(Color.primary)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AllTimeLeadersView()
    }
}
