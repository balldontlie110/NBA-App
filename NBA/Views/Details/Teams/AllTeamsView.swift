//
//  AllTeamsView.swift
//  NBA
//
//  Created by Ali Earp on 06/05/2024.
//

import SwiftUI
import SDWebImageSwiftUI
import CoreData

struct AllTeamsView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \FavoriteTeam.teamId, ascending: true)],
        animation: .default)
    private var favoriteTeams: FetchedResults<FavoriteTeam>
    
    @StateObject private var viewModel: AllTeamsViewModel = AllTeamsViewModel()
    
    var body: some View {
        VStack {
            if let allTeams = viewModel.allTeams {
                ScrollView {
                    Spacer()
                        .frame(height: 5)
                    
                    if !favoriteTeams.isEmpty {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("FAVORITES")
                                .font(Font.custom("Futura-CondensedExtraBold", size: 24))
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal) {
                                LazyHStack(spacing: 10) {
                                    ForEach(favoriteTeams) { team in
                                        NavigationLink {
                                            if let teamId = team.teamId {
                                                TeamProfileView(teamId: teamId)
                                            }
                                        } label: {
                                            if let teamId = team.teamId {
                                                Image(teamId)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(height: 50)
                                            }
                                            
                                            if favoriteTeams.firstIndex(of: team) != favoriteTeams.count - 1 {
                                                Divider()
                                            }
                                        }
                                    }
                                }.padding(10)
                            }.background(Color(.systemGray6))
                        }
                    }
                    
                    LazyVStack(spacing: 5) {
                        ForEach(allTeams) { team in
                            NavigationLink {
                                TeamProfileView(teamId: String(team.teamId))
                            } label: {
                                ZStack {
                                    Color(.systemGray6)
                                    
                                    HStack {
                                        Text(team.teamName)
                                            .font(Font.custom("Futura-CondensedExtraBold", size: 20))
                                            .foregroundStyle(Color.primary)
                                            .lineLimit(1)
                                            .padding(.leading)
                                        
                                        Spacer()
                                        
                                        Image(String(team.teamId))
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(height: 50)
                                            .padding(.trailing, 10)
                                    }.padding(5)
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .padding(.horizontal, 5)
                            }
                        }
                    }
                    
                    Spacer()
                        .frame(height: 5)
                }
                .navigationTitle("Teams")
                .navigationBarTitleDisplayMode(.inline)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }.onAppear {
            viewModel.fetchAllTeams()
        }
    }
}

#Preview {
    NavigationStack {
        AllTeamsView()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
