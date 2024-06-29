//
//  PlayerProfileView.swift
//  NBA
//
//  Created by Ali Earp on 05/05/2024.
//

import SwiftUI
import SDWebImageSwiftUI
import UIImageColors
import CoreData

struct PlayerProfileView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \FavoritePlayer.playerId, ascending: true)],
        animation: .default)
    private var favoritePlayers: FetchedResults<FavoritePlayer>
    
    @StateObject private var viewModel = PlayerInfoViewModel()
    
    let playerId: String
    
    @State var showAllSeasonStats: Bool = false
    
    var backgroundColor: UIColor {
        if let playerInfo = viewModel.playerInfo {
            let calendar = Calendar.current.dateComponents([.year], from: Date())
            if let year = calendar.year {
                if let toYear = playerInfo["TO_YEAR"] {
                    if toYear >= String(year - 1) {
                        if let teamId = playerInfo["TEAM_ID"] {
                            return UIImage(named: teamId)?.getColors()?.background ?? UIColor.systemGray6
                        } else {
                            return UIColor.systemGray6
                        }
                    } else {
                        return UIColor.systemGray6
                    }
                } else {
                    return UIColor.systemGray6
                }
            } else {
                return UIColor.systemGray6
            }
        } else {
            return UIColor.systemGray6
        }
    }
    
    var isRetired: Bool {
        let calendar = Calendar.current.dateComponents([.year], from: Date())
        if let year = calendar.year {
            if let playerInfo = viewModel.playerInfo {
                if let toYear = playerInfo["TO_YEAR"] {
                    return toYear < String(year - 1)
                } else {
                    return false
                }
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let playerAwards = viewModel.playerAwards, let playerInfo = viewModel.playerInfo {
                    ScrollView {
                        VStack(spacing: 0) {
                            HStack {
                                Spacer()
                                
                                Button {
                                    if favoritePlayers.contains(where: { $0.playerId == playerId }) {
                                        deletePlayerFromFavorites()
                                    } else {
                                        addPlayerToFavorites()
                                    }
                                } label: {
                                    Image(systemName: favoritePlayers.contains { $0.playerId == playerId } ? "star.fill" : "star")
                                        .foregroundStyle(Color.yellow)
                                }
                            }.padding([.horizontal, .top])
                            
                            ZStack {
                                if !isRetired {
                                    if let teamId = playerInfo["TEAM_ID"] {
                                        Image(teamId)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .offset(x: 30, y: 50)
                                            .mask {
                                                Rectangle()
                                                    .offset(x: 30)
                                            }
                                            .opacity(0.05)
                                    }
                                }
                                
                                HStack {
                                    VStack {
                                        Spacer()
                                        
                                        ZStack {
                                            WebImage(url: URL(string: "https://cdn.nba.com/headshots/nba/latest/260x190/\(playerId).png")) { image in
                                                image
                                                    .resizable()
                                                    .scaledToFit()
                                            } placeholder: {
                                                Spacer()
                                            }.frame(width: 150)
                                            
                                            
                                            if !isRetired {
                                                if let teamId = playerInfo["TEAM_ID"] {
                                                    NavigationLink {
                                                        TeamProfileView(teamId: teamId)
                                                    } label: {
                                                        Image(teamId)
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fit)
                                                            .frame(width: 50)
                                                    }.offset(x: -75, y: -50)
                                                }
                                            }
                                        }
                                        .padding(.leading, 25)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .leading, spacing: 0) {
                                        Group {
                                            if let firstName = playerInfo["FIRST_NAME"], let lastName = playerInfo["LAST_NAME"] {
                                                Text(firstName)
                                                Text(lastName)
                                            }
                                        }
                                        .font(Font.custom("Futura-CondensedExtraBold", size: 24))
                                        .multilineTextAlignment(.leading)
                                        
                                        HStack {
                                            if let teamName = playerInfo["TEAM_NAME"] {
                                                Text(teamName)
                                            }
                                            
                                            Text("|")
                                            
                                            if let jerseyNum = playerInfo["JERSEY"] {
                                                Text("#\(jerseyNum)")
                                            }
                                            
                                            Text("|")
                                            
                                            if let position = playerInfo["POSITION"] {
                                                Text(position)
                                            }
                                        }
                                        .font(Font.custom("Futura", size: 12))
                                        .foregroundStyle(Color(.lightGray))
                                        .padding(.top, 10)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }.frame(height: 200)
                            
                            Divider()
                                .frame(height: 2.5)
                                .background(Color.white)
                            
                            if let playerStats = viewModel.playerStats?[isRetired ? "CareerTotalsRegularSeason" :  "SeasonTotalsRegularSeason"]?.last {
                                ZStack(alignment: .top) {
                                    StatsRow(playerStats: playerStats)
                                    
                                    HStack {
                                        Spacer()
                                        
                                        Button {
                                            withAnimation {
                                                self.showAllSeasonStats.toggle()
                                            }
                                        } label: {
                                            Image(systemName: self.showAllSeasonStats ? "chevron.up" : "chevron.down")
                                        }.padding()
                                    }
                                }
                            }
                            
                            if showAllSeasonStats {
                                if let seasons = viewModel.playerStats?["SeasonTotalsRegularSeason"]?.dropLast(isRetired ? 0 : 1) {
                                    Divider()
                                        .frame(height: 0.5)
                                        .background(Color.white)
                                    
                                    ForEach(seasons, id: \.self) { season in
                                        HStack {
                                            if let year = season["SEASON_ID"], let teamTricode = season["TEAM_ABBREVIATION"] {
                                                VStack {
                                                    Text(String(year.dropFirst(2)))
                                                        .font(Font.custom("Futura", size: 14))
                                                    Text(teamTricode)
                                                        .font(Font.custom("Futura", size: 12))
                                                        .foregroundStyle(Color(.lightGray))
                                                }
                                            }
                                            
                                            Spacer()
                                            
                                            StatsRow(playerStats: season)
                                        }.padding(.horizontal, 30)
                                    }
                                }
                                
                                if !isRetired, let career = viewModel.playerStats?["CareerTotalsRegularSeason"]?.first {
                                    Divider()
                                    
                                    HStack {
                                        Text("Career")
                                            .font(Font.custom("Futura", size: 14))
                                        
                                        Spacer()
                                        
                                        StatsRow(playerStats: career)
                                    }.padding(.horizontal, 30)
                                }
                            }
                            
                            Divider()
                                .frame(height: 2.5)
                                .background(Color.white)
                            
                            VStack(spacing: 0) {
                                HStack {
                                    HStack {
                                        if let height = playerInfo["HEIGHT"] {
                                            if height != "" {
                                                let feet = height.split(separator: "-")[0]
                                                let inches = height.split(separator: "-")[1]
                                                Text("\(feet)'\(inches)\"")
                                            }
                                        }
                                        
                                        Text("|")
                                        
                                        if let weight = playerInfo["WEIGHT"] {
                                            Text("\(weight)lb")
                                        }
                                        
                                        Text("|")
                                        
                                        if let birthdate = playerInfo["BIRTHDATE"] {
                                            Text("\(getAge(birthdate)) years")
                                        }
                                    }.frame(width: UIScreen.main.bounds.width / 2)
                                    
                                    VStack {
                                        Text("DRAFT")
                                            .font(Font.custom("Futura", size: 12))
                                            .foregroundStyle(Color(.lightGray))
                                        
                                        if let year = playerInfo["DRAFT_YEAR"], let round = playerInfo["DRAFT_ROUND"], let number = playerInfo["DRAFT_NUMBER"] {
                                            if year == "Undrafted" {
                                                Text("Undrafted")
                                            } else {
                                                Text("\(year) R\(round) Pick \(number)")
                                            }
                                        }
                                    }.frame(width: UIScreen.main.bounds.width / 2)
                                }.padding(.vertical, 10)
                                
                                Divider()
                                    .frame(height: 2.5)
                                    .background(Color.white)
                                
                                HStack {
                                    VStack {
                                        Text("DATE OF BIRTH")
                                            .font(Font.custom("Futura", size: 12))
                                            .foregroundStyle(Color(.lightGray))
                                        
                                        if let birthdate = playerInfo["BIRTHDATE"] {
                                            Text(getBirthdateString(birthdate))
                                        }
                                    }.frame(width: UIScreen.main.bounds.width / 2)
                                    
                                    VStack {
                                        Text("COUNTRY")
                                            .font(Font.custom("Futura", size: 12))
                                            .foregroundStyle(Color(.lightGray))
                                        
                                        if let country = playerInfo["COUNTRY"] {
                                            Text(country)
                                        }
                                    }.frame(width: UIScreen.main.bounds.width / 2)
                                }.padding(.vertical, 10)
                                
                                Divider()
                                    .frame(height: 2.5)
                                    .background(Color.white)
                                
                                HStack {
                                    VStack {
                                        Text("LAST ATTENDED")
                                            .font(Font.custom("Futura", size: 12))
                                            .foregroundStyle(Color(.lightGray))
                                        
                                        if let school = playerInfo["SCHOOL"] {
                                            Text(school.split(separator: "/")[0])
                                        }
                                    }.frame(width: UIScreen.main.bounds.width / 2)
                                    
                                    VStack {
                                        Text("EXPERIENCE")
                                            .font(Font.custom("Futura", size: 12))
                                            .foregroundStyle(Color(.lightGray))
                                        
                                        if let experience = playerInfo["SEASON_EXP"] {
                                            Text("\(experience) years")
                                        }
                                    }.frame(width: UIScreen.main.bounds.width / 2)
                                }.padding(.vertical, 10)
                            }.font(Font.custom("Futura", size: 14))
                                .padding(.horizontal, 5)
                            
                            Divider()
                                .frame(height: 2.5)
                                .background(Color.white)
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    let awardsCount = playerAwards.sorted().reduce(into: [:]) { count, award in
                                        count[award, default: 0] += 1
                                    }
                                    
                                    ForEach(awardsCount.sorted { $0.key < $1.key }, id: \.key) { award, count in
                                        Text("\u{2022} \(count)x \(award)")
                                            .font(Font.custom("Futura-Medium", size: 16))
                                            .multilineTextAlignment(.leading)
                                    }
                                }
                                
                                Spacer()
                            }.padding()
                        }
                        .foregroundStyle(Color.white)
                        .multilineTextAlignment(.center)
                    }
                    .scrollIndicators(.hidden)
                    .background(Color(uiColor: backgroundColor))
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .background(Color(.systemGray6))
            .onAppear {
                viewModel.fetchPlayerInformation(playerId: playerId)
            }
        }
    }
    
    private func getAge(_ birthdate: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let date = dateFormatter.date(from: birthdate) ?? Date()
        let years = Calendar.current.dateComponents([.year], from: date, to: Date())
        return String(years.year ?? 0)
    }
    
    private func getBirthdateString(_ birthdate: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let date = dateFormatter.date(from: birthdate) ?? Date()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        return dateFormatter.string(from: date)
    }
    
    private func addPlayerToFavorites() {
        let newFavoritePlayer = FavoritePlayer(context: viewContext)
        newFavoritePlayer.playerId = playerId
        
        if let playerInfo = viewModel.playerInfo {
            if let firstName = playerInfo["FIRST_NAME"], let lastName = playerInfo["LAST_NAME"], let teamId = playerInfo["TEAM_ID"] {
                newFavoritePlayer.firstName = firstName
                newFavoritePlayer.lastName = lastName
                newFavoritePlayer.teamId = teamId
            }
        }

        do {
            try viewContext.save()
        } catch {
            print("Failed to add player to favorites in core data: \(error)")
        }
    }
    
    private func deletePlayerFromFavorites() {
        if let player = favoritePlayers.first(where: { $0.playerId == playerId }) {
            viewContext.delete(player)
        }
        
        do {
            try viewContext.save()
        } catch {
            print("Failed to remove player from favorites in core data: \(error)")
        }
    }
}

struct StatsColumn: View {
    let title: String
    let stat: String?
    let gamesPlayed: Double
    
    var body: some View {
        VStack {
            Text(title)
                .font(Font.custom("Futura", size: 14))
            
            if let stat = Double(stat ?? "") {
                Text(String(round(stat / gamesPlayed * 10) / 10.0))
                    .font(Font.custom("Futura-Bold", size: 20))
            }
        }
        .frame(width: 65)
    }
}

struct StatsRow: View {
    let playerStats: [String : String]
    
    var body: some View {
        HStack(spacing: 5) {
            if let gamesPlayed = Double(playerStats["GP"] ?? "") {
                StatsColumn(title: "PPG", stat: playerStats["PTS"], gamesPlayed: gamesPlayed)
                
                Divider()
                    .frame(width: 1)
                    .background(Color.white)
                
                StatsColumn(title: "RPG", stat: playerStats["REB"], gamesPlayed: gamesPlayed)
                
                Divider()
                    .frame(width: 1)
                    .background(Color.white)
                
                StatsColumn(title: "APG", stat: playerStats["AST"], gamesPlayed: gamesPlayed)
                
                Divider()
                    .frame(width: 1)
                    .background(Color.white)
                
                VStack {
                    Text("FG%")
                        .font(Font.custom("Futura", size: 14))
                    
                    if let fgPct = Double(playerStats["FG_PCT"] ?? "") {
                        Text(String(round(fgPct * 1000) / 10.0))
                            .font(Font.custom("Futura-Bold", size: 20))
                    }
                }.frame(width: 65)
            }
        }.padding(.vertical, 10)
    }
}

#Preview {
    NavigationStack {
        PlayerProfileView(playerId: "201939")
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
