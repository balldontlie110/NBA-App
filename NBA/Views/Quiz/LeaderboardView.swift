//
//  LeaderboardView.swift
//  NBA
//
//  Created by Ali Earp on 26/05/2024.
//

import SwiftUI
import FirebaseAuth
import SDWebImageSwiftUI

struct LeaderboardView: View {
    @StateObject var viewModel: LeaderboardModel = LeaderboardModel()
    
    @State var uid: String? = Auth.auth().currentUser?.uid
    
    @State var userVisible: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            if !userVisible {
                if let leader = viewModel.leaderboard.first(where: { leader in
                    leader.id == uid
                }) {
                    ZStack {
                        Color(.systemGray6)
                        
                        HStack(spacing: 10) {
                            WebImage(url: URL(string: leader.photoURL))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                            
                            Text("\(leader.rank).")
                            Text(leader.username)
                            
                            Spacer()
                            
                            Text("\(leader.totalCorrect)/\(leader.totalCorrect + leader.totalIncorrect)")
                        }
                        .frame(height: 50)
                        .font(Font.custom("Futura-CondensedExtraBold", size: 20))
                        .foregroundStyle(Color.primary)
                        .lineLimit(1)
                        .padding(5)
                        .padding(.horizontal, 5)
                    }.frame(height: 55)
                }
            }
            
            ScrollView {
                LazyVStack(spacing: 5) {
                    Spacer()
                        .frame(height: 5)
                    
                    ForEach(viewModel.leaderboard) { leader in
                        ZStack {
                            Color(.systemGray6)
                            
                            HStack(spacing: 10) {
                                WebImage(url: URL(string: leader.photoURL))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                
                                Text("\(leader.rank).")
                                Text(leader.username)
                                
                                Spacer()
                                
                                Text("\(leader.totalCorrect)/\(leader.totalCorrect + leader.totalIncorrect)")
                            }
                            .frame(height: 50)
                            .font(Font.custom("Futura-CondensedExtraBold", size: 20))
                            .foregroundStyle(Color.primary)
                            .lineLimit(1)
                            .padding(5)
                            .padding(.horizontal, 5)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .padding(.horizontal, 5)
                        .id(leader.id)
                        .onAppear {
                            if leader.id == uid {
                                withAnimation {
                                    self.userVisible = true
                                }
                            }
                        }
                        .onDisappear {
                            if leader.id == uid {
                                withAnimation {
                                    self.userVisible = false
                                }
                            }
                        }
                    }
                    
                    Spacer()
                        .frame(height: 5)
                }
            }.scrollPosition(id: $uid, anchor: .center)
        }.navigationTitle("Leaderboard")
    }
}

#Preview {
    LeaderboardView()
}
