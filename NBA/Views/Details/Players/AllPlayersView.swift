//
//  AllPlayersView.swift
//  NBA
//
//  Created by Ali Earp on 05/05/2024.
//

import SwiftUI
import SDWebImageSwiftUI
import CoreData

struct AllPlayersView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \FavoritePlayer.lastName, ascending: true)],
        animation: .default)
    private var favoritePlayers: FetchedResults<FavoritePlayer>
    
    @StateObject private var viewModel = AllPlayersViewModel()
    @StateObject private var allTeamsViewModel: AllTeamsViewModel = AllTeamsViewModel()
    
    @Environment(\.dismissSearch) var dismissSearch
    
    @State var searchTerm: String = ""
    @State var filterTeam: String?
    
    @State var playerProfileView: String?
    @State var showKeyboard: Bool = false
    
    var body: some View {
        VStack {
            if viewModel.allPlayers != nil {
                ScrollView {
                    Spacer()
                        .frame(height: 5)
                    
                    if !filteredFavoritePlayers.isEmpty {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("FAVORITES")
                                .font(Font.custom("Futura-CondensedExtraBold", size: 24))
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal) {
                                LazyHStack(spacing: 10) {
                                    ForEach(filteredFavoritePlayers) { player in
                                        VStack {
                                            ZStack {
                                                Color.black
                                                
                                                if let playerId = player.playerId {
                                                    WebImage(url: URL(string: "https://cdn.nba.com/headshots/nba/latest/260x190/\(playerId).png"))
                                                        .resizable()
                                                        .scaledToFit()
                                                        .clipShape(Circle())
                                                        .padding(-10)
                                                }
                                            }
                                            .clipShape(Circle())
                                            .frame(width: 50, height: 50)
                                            
                                            if let firstName = player.firstName, let lastName = player.lastName {
                                                Text("\(firstName) \(lastName)")
                                                    .font(Font.custom("Futura", size: 14))
                                                    .multilineTextAlignment(.center)
                                                    .frame(height: 40)
                                            }
                                        }
                                        .frame(width: 75)
                                        .onTapGesture {
                                            if let playerId = player.playerId {
                                                self.playerProfileView = playerId
                                            }
                                        }
                                        
                                        if favoritePlayers.firstIndex(of: player) != favoritePlayers.count - 1 {
                                            Divider()
                                        }
                                    }
                                }.padding(10)
                            }.background(Color(.systemGray6))
                        }
                    }
                    
                    LazyVStack(spacing: 5) {
                        ForEach(filteredPlayers, id: \.self) { player in
                            if let teamId = player["TEAM_ID"], let playerId = player["PERSON_ID"], let name = player["DISPLAY_FIRST_LAST"] {
                                if player["ROSTERSTATUS"] == "1" {
                                    ZStack {
                                        Color(.systemGray6)
                                        
                                        HStack(spacing: 0) {
                                            ZStack {
                                                Color.black
                                                
                                                WebImage(url: URL(string: "https://cdn.nba.com/headshots/nba/latest/260x190/\(playerId).png"))
                                                    .resizable()
                                                    .scaledToFit()
                                                    .clipShape(Circle())
                                                    .padding(0 - ((10 / 3) * 2))
                                            }
                                            .clipShape(Circle())
                                            .frame(width: 40, height: 40)
                                            .padding(.leading, 5)
                                            
                                            Text(name)
                                                .font(Font.custom("Futura-CondensedExtraBold", size: 20))
                                                .foregroundStyle(Color.primary)
                                                .lineLimit(1)
                                                .padding(.leading)
                                            
                                            Spacer()
                                            
                                            if filterTeam == nil {
                                                Image(teamId)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(height: 50)
                                                    .padding(.trailing, 10)
                                            }
                                        }.padding(5)
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                    .padding(.horizontal, 5)
                                    .onTapGesture {
                                        if let playerId = player["PERSON_ID"] {
                                            self.playerProfileView = playerId
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    Spacer()
                        .frame(height: 5)
                }
                .searchable(text: $searchTerm, isPresented: $showKeyboard, placement: .navigationBarDrawer(displayMode: .always))
                .autocorrectionDisabled()
                .navigationTitle("Players")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        if let allTeams = allTeamsViewModel.allTeams {
                            Menu {
                                ForEach(allTeams) { team in
                                    Button {
                                        self.filterTeam = self.filterTeam == String(team.teamId) ? nil : String(team.teamId)
                                    } label: {
                                        HStack {
                                            Text(team.teamName)
                                            
                                            Spacer()
                                            
                                            if String(team.teamId) == filterTeam {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                if let filterTeam = filterTeam {
                                    Image(filterTeam)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 40, height: 40)
                                } else {
                                    Image(systemName: "slider.horizontal.3")
                                        .foregroundStyle(Color.primary)
                                }
                            }
                        }
                    }
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            viewModel.fetchAllPlayers()
            allTeamsViewModel.fetchAllTeams()
        }
        .sheet(item: $playerProfileView) { playerId in
            PlayerProfileView(playerId: playerId)
                .presentationDetents([.medium, .large])
                .onAppear {
                    showKeyboard = false
                }
        }
    }
    
    var filteredPlayers: [[String : String]] {
        if let allPlayers = viewModel.allPlayers {
            if searchTerm == "" {
                if let filterTeam = filterTeam {
                    return allPlayers.filter { $0["TEAM_ID"] == filterTeam }
                } else {
                    return allPlayers
                }
            } else {
                let filteredPlayers = allPlayers.filter { $0["DISPLAY_FIRST_LAST"]?.lowercased().contains(searchTerm.lowercased()) ?? true }
                
                if let filterTeam = filterTeam {
                    return filteredPlayers.filter { $0["TEAM_ID"] == filterTeam }
                } else {
                    return filteredPlayers
                }
            }
        } else {
            return []
        }
    }
    
    var filteredFavoritePlayers: Array<FavoritePlayer> {
        if searchTerm == "" {
            if let filterTeam = filterTeam {
                return favoritePlayers.filter { $0.teamId == filterTeam }
            } else {
                return Array(favoritePlayers)
            }
        } else {
            let filteredFavoritePlayers = favoritePlayers.filter { player in
                if let firstName = player.firstName, let lastName = player.lastName {
                    let name = "\(firstName) \(lastName)"
                    return name.lowercased().contains(searchTerm.lowercased())
                } else {
                    return false
                }
            }
            
            if let filterTeam = filterTeam {
                return filteredFavoritePlayers.filter { $0.teamId == filterTeam }
            } else {
                return filteredFavoritePlayers
            }
        }
    }
}

#Preview {
    NavigationStack {
        AllPlayersView()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
