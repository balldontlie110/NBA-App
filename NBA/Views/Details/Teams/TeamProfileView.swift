//
//  TeamProfileView.swift
//  NBA
//
//  Created by Ali Earp on 08/05/2024.
//

import SwiftUI
import SDWebImageSwiftUI
import CoreData

struct TeamProfileView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \FavoriteTeam.teamId, ascending: true)],
        animation: .default)
    private var favoriteTeams: FetchedResults<FavoriteTeam>
    
    @StateObject private var viewModel: TeamProfileViewModel = TeamProfileViewModel()
    
    let teamId: String
    
    @State var showRetired: Bool = false
    @State var showHallOfFame: Bool = false
    
    @State var playerProfileView: String?
    
    var backgroundColor: UIColor {
        if let teamProfile = viewModel.teamProfile {
            if let teamBackground = teamProfile["TeamBackground"]?.first {
                if let teamId = teamBackground["TEAM_ID"] {
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
    }
    
    var body: some View {
        VStack {
            if let teamProfile = viewModel.teamProfile {
                ScrollView {
                    HStack {
                        Spacer()
                        
                        Button {
                            if favoriteTeams.contains(where: { $0.teamId == teamId }) {
                                deleteTeamFromFavorites()
                            } else {
                                addTeamToFavorites()
                            }
                        } label: {
                            Image(systemName: favoriteTeams.contains { $0.teamId == teamId } ? "star.fill" : "star")
                                .foregroundStyle(Color.yellow)
                        }
                    }.padding()
                    
                    if let teamBackground = teamProfile["TeamBackground"]?.first {
                        if let teamId = teamBackground["TEAM_ID"] {
                            HStack {
                                if let teamCity = teamBackground["CITY"], let teamName = teamBackground["NICKNAME"], let founded = teamBackground["YEARFOUNDED"] {
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("\(teamCity) \(teamName)")
                                            .font(Font.custom("Futura-CondensedExtraBold", size: 32))
                                        Text("Founded in \(founded)")
                                            .font(Font.custom("Futura", size: 16))
                                            .foregroundStyle(Color(.lightGray))
                                    }
                                }
                                
                                Spacer()
                                
                                Image(teamId)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 150)
                            }.padding(.horizontal)
                        }
                        
                        Divider()
                            .frame(height: 2.5)
                            .background(Color.white)
                        
                        if let arena = teamBackground["ARENA"], let owner = teamBackground["OWNER"], let generalManager = teamBackground["GENERALMANAGER"], let headCoach = teamBackground["HEADCOACH"] {
                            VStack {
                                HStack {
                                    Text("INFORMATION")
                                        .font(Font.custom("Futura-CondensedExtraBold", size: 24))
                                        .padding(.leading)
                                    
                                    Spacer()
                                }
                                
                                Group {
                                    if arena != "" {
                                        HStack {
                                            Text("Arena:")
                                            Spacer()
                                            Text(arena)
                                        }
                                    }
                                    
                                    if owner != "" {
                                        HStack {
                                            Text("Owner:")
                                            Spacer()
                                            Text(owner)
                                        }
                                    }
                                    
                                    if generalManager != "" {
                                        HStack {
                                            Text("General Manager:")
                                            Spacer()
                                            Text(generalManager)
                                        }
                                    }
                                    
                                    if headCoach != "" {
                                        HStack {
                                            Text("Head Coach:")
                                            Spacer()
                                            Text(headCoach)
                                        }
                                    }
                                }
                                .font(Font.custom("Futura", size: 18))
                                .padding(.horizontal, 10)
                            }
                        }
                    }
                    
                    if let championships = teamProfile["TeamAwardsChampionships"], let conferences = teamProfile["TeamAwardsConf"], let divisions = teamProfile["TeamAwardsDiv"] {
                        if championships != [] || conferences != [] || divisions != [] {
                            Divider()
                                .frame(height: 2.5)
                                .background(Color.white)
                        }
                        
                        if championships != [] {
                            TeamAwards(awards: championships, type: "NBA CHAMPIONS")
                        }
                        
                        if conferences != [] {
                            TeamAwards(awards: conferences, type: "CONFERENCE CHAMPIONS")
                        }
                        
                        if divisions != [] {
                            TeamAwards(awards: divisions, type: "DIVISION CHAMPIONS")
                        }
                    }
                    
                    Divider()
                        .frame(height: 2.5)
                        .background(Color.white)
                    
                    if let retired = teamProfile["TeamRetired"] {
                        if retired != [] {
                            TeamPlayers(players: retired, type: "RETIRED", playerProfileView: $playerProfileView)
                        }
                    }
                    
                    Divider()
                        .frame(height: 2.5)
                        .background(Color.white)
                    
                    if let hallOfFame = teamProfile["TeamHof"] {
                        if hallOfFame != [] {
                            TeamPlayers(players: hallOfFame, type: "HALL OF FAME", playerProfileView: $playerProfileView)
                        }
                    }
                    
                    Divider()
                        .frame(height: 2.5)
                        .background(Color.white)
                    
                    if let franchiseLeaders = viewModel.franchiseLeaders?.last {
                        if let pointsLeader = franchiseLeaders["PTS_PLAYER"], let pointsLeaderId = franchiseLeaders["PTS_PERSON_ID"], let points = franchiseLeaders["PTS"] {
                            FranchiseLeader(playerProfileView: $playerProfileView, leaderName: pointsLeader, leaderId: pointsLeaderId, leaderStat: points, statType: "Points", statTypeShort: "PTS")
                        }
                        
                        if let reboundsLeader = franchiseLeaders["REB_PLAYER"], let reboundsLeaderId = franchiseLeaders["REB_PERSON_ID"], let rebounds = franchiseLeaders["REB"] {
                            FranchiseLeader(playerProfileView: $playerProfileView, leaderName: reboundsLeader, leaderId: reboundsLeaderId, leaderStat: rebounds, statType: "Rebounds", statTypeShort: "REB")
                        }
                        
                        if let assistsLeader = franchiseLeaders["AST_PLAYER"], let assistsLeaderId = franchiseLeaders["AST_PERSON_ID"], let assists = franchiseLeaders["AST"] {
                            FranchiseLeader(playerProfileView: $playerProfileView, leaderName: assistsLeader, leaderId: assistsLeaderId, leaderStat: assists, statType: "Assists", statTypeShort: "AST")
                        }
                        
                        if let blocksLeader = franchiseLeaders["BLK_PLAYER"], let blocksLeaderId = franchiseLeaders["BLK_PERSON_ID"], let blocks = franchiseLeaders["BLK"] {
                            FranchiseLeader(playerProfileView: $playerProfileView, leaderName: blocksLeader, leaderId: blocksLeaderId, leaderStat: blocks, statType: "Blocks", statTypeShort: "BLK")
                        }
                        
                        if let stealsLeader = franchiseLeaders["STL_PLAYER"], let stealsLeaderId = franchiseLeaders["STL_PERSON_ID"], let steals = franchiseLeaders["STL"] {
                            FranchiseLeader(playerProfileView: $playerProfileView, leaderName: stealsLeader, leaderId: stealsLeaderId, leaderStat: steals, statType: "Steals", statTypeShort: "STL")
                        }
                    }
                    
                    Divider()
                        .frame(height: 2.5)
                        .background(Color.white)
                    
                    teamSocials
                    
                    Spacer()
                        .frame(height: 5)
                }
                .foregroundStyle(Color.white)
                .scrollIndicators(.hidden)
                .background(Color(uiColor: backgroundColor))
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color(.systemGray6))
        .onAppear {
            viewModel.fetchTeamProfile(teamId: teamId)
        }
        .sheet(item: $playerProfileView) { playerId in
            PlayerProfileView(playerId: playerId)
                .presentationDetents([.medium, .large])
        }
    }
    
    var teamSocials: some View {
        Group {
            if let teamProfile = viewModel.teamProfile {
                if let teamSocialSites = teamProfile["TeamSocialSites"] {
                    VStack {
                        HStack {
                            Text("SOCIALS")
                                .font(Font.custom("Futura-CondensedExtraBold", size: 24))
                                .padding(.leading)
                            
                            Spacer()
                        }
                        
                        ForEach(teamSocialSites, id: \.self) { social in
                            if let type = social["ACCOUNTTYPE"], let link = social["WEBSITE_LINK"] {
                                HStack(spacing: 15) {
                                    Image(type.lowercased())
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 25, height: 25)
                                    
                                    if let url = URL(string: link) {
                                        Link(destination: url) {
                                            Text(type)
                                                .underline()
                                                .font(Font.custom("Futura", size: 18))
                                        }
                                    }
                                    
                                    Spacer()
                                }.padding(.horizontal, 10)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func addTeamToFavorites() {
        let newFavoriteTeam = FavoriteTeam(context: viewContext)
        newFavoriteTeam.teamId = teamId

        do {
            try viewContext.save()
        } catch {
            print("Failed to add team to favorites in core data: \(error)")
        }
    }
    
    private func deleteTeamFromFavorites() {
        if let team = favoriteTeams.first(where: { $0.teamId == teamId }) {
            viewContext.delete(team)
        }
        
        do {
            try viewContext.save()
        } catch {
            print("Failed to remove team from favorites in core data: \(error)")
        }
    }
}

struct FranchiseLeader: View {
    @Binding var playerProfileView: String?
    
    let leaderName: String
    let leaderId: String
    let leaderStat: String
    let statType: String
    let statTypeShort: String
    
    var body: some View {
        HStack {
            Text("\(statType) Leader:")
                .font(Font.custom("Futura-CondensedExtraBold", size: 20))
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(leaderName)
                Text("\(Int(leaderStat) ?? 0) \(statTypeShort)")
                    .foregroundStyle(Color(.lightGray))
            }.font(Font.custom("Futura", size: 16))
            
            ZStack {
                Color.black
                
                WebImage(url: URL(string: "https://cdn.nba.com/headshots/nba/latest/260x190/\(leaderId).png"))
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .padding(-5)
            }
            .clipShape(Circle())
            .frame(width: 40, height: 40)
        }
        .padding(.leading, 5)
        .padding(.horizontal, 10)
        .onTapGesture {
            playerProfileView = leaderId
        }
    }
}

struct TeamAwards: View {
    let awards: [[String : String]]
    let type: String
    
    @State var showAwards: Bool = false
    
    var body: some View {
        VStack {
            Button {
                withAnimation {
                    showAwards.toggle()
                }
            } label: {
                HStack {
                    Text(type)
                        .font(Font.custom("Futura-CondensedExtraBold", size: 24))
                    Spacer()
                    Image(systemName: showAwards ? "chevron.up" : "chevron.down")
                        .bold()
                }.padding(.horizontal)
            }
            
            if showAwards {
                ForEach(awards, id: \.self) { award in
                    if let year = award["YEARAWARDED"] {
                        HStack {
                            Text(year)
                            if let opponent = award["OPPOSITETEAM"] {
                                if opponent != "" {
                                    Text("vs")
                                    Text(opponent)
                                }
                            }
                        }.font(Font.custom("Futura", size: 18))
                    }
                }
            }
        }.padding(.bottom, 10)
    }
}

struct TeamPlayers: View {
    let players: [[String : String]]
    let type: String
    
    @Binding var playerProfileView: String?
    
    @State var showPlayers: Bool = false
    
    var body: some View {
        VStack {
            Button {
                withAnimation {
                    showPlayers.toggle()
                }
            } label: {
                HStack {
                    Text(type)
                        .font(Font.custom("Futura-CondensedExtraBold", size: 24))
                    Spacer()
                    Image(systemName: showPlayers ? "chevron.up" : "chevron.down")
                        .bold()
                }.padding(.horizontal)
            }
            
            if showPlayers {
                ForEach(players, id: \.self) { player in
                    if let playerId = player["PLAYERID"], let name = player["PLAYER"], let position = player["POSITION"], let seasonsWithTeam = player["SEASONSWITHTEAM"] {
                        ZStack {
                            Color(.systemGray6)
                            
                            HStack {
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
                                
                                Group {
                                    Text(name)
                                    Text("|")
                                    Text(position)
                                }.foregroundStyle(Color.primary)
                                
                                Spacer()
                                Text(seasonsWithTeam)
                                    .foregroundStyle(Color(.lightGray))
                            }
                            .font(Font.custom("Futura", size: 16))
                            .lineLimit(1)
                            .padding(7.5)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .onTapGesture {
                            self.playerProfileView = playerId
                        }
                        .padding(.horizontal, 5)
                    }
                }
            }
        }
    }
}

#Preview {
    TeamProfileView(teamId: "1610612744")
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
