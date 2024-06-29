//
//  PlayByPlayView.swift
//  NBA
//
//  Created by Ali Earp on 13/05/2024.
//

import SwiftUI
import SDWebImageSwiftUI

struct PlayByPlayView: View {
    @StateObject var viewModel: PlayByPlayViewModel = PlayByPlayViewModel()
    
    let gameId: String
    let endPeriod: String
    let gameStatus: String
    
    @State var playerProfileView: String?
    
    var body: some View {
        VStack {
            if let playByPlay = viewModel.playByPlay {
                ScrollView {
                    LazyVStack(spacing: 7.5) {
                        ForEach(playByPlay.actions) { action in
                            HStack {
                                if action.actionType != "Timeout" && action.actionType != "period" {
                                    Image(String(action.teamId))
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 35)
                                }
                                
                                if action.actionType == "Timeout" || action.actionType == "period" {
                                    Text(action.description)
                                        .font(Font.custom("Futura-CondensedExtraBold", size: 20))
                                } else {
                                    Text(action.description)
                                        .font(Font.custom("Futura", size: 16))
                                }
                                
                                Spacer()
                                
                                if action.actionType != "period" {
                                    VStack {
                                        let minute = action.clock.prefix(4).suffix(2)
                                        let second = action.clock.prefix(7).suffix(2)
                                        Text("\(minute):\(second)")
                                    }
                                    .font(Font.custom("Futura", size: 10))
                                    .foregroundStyle(Color(.lightGray))
                                }
                                
                                if action.actionType != "Timeout" && action.actionType != "period" {
                                    WebImage(url: URL(string: "https://cdn.nba.com/headshots/nba/latest/260x190/\(action.personId).png"))
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50)
                                        .background(Color.black)
                                        .clipShape(Circle())
                                        .onTapGesture {
                                            self.playerProfileView = String(action.personId)
                                        }
                                }
                            }.padding(.horizontal, 10)
                            
                            if playByPlay.actions.firstIndex(where: { $0.actionId == action.actionId }) != playByPlay.actions.count - 1 {
                                Divider()
                            }
                        }
                    }.padding(.vertical, 7.5)
                }
                .defaultScrollAnchor(gameStatus == "2" ? .bottom : .top)
                .refreshable {
                    refresh()
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }.onAppear {
            viewModel.fetchPlayByPlay(gameId: gameId, endPeriod: endPeriod)
        }
        .sheet(item: $playerProfileView) { playerId in
            PlayerProfileView(playerId: playerId)
                .presentationDetents([.medium, .large])
        }
    }
    
    private func refresh() {
        DispatchQueue.main.async {
            viewModel.fetchPlayByPlay(gameId: gameId, endPeriod: endPeriod)
        }
    }
}

#Preview {
    PlayByPlayView(gameId: "0021700807", endPeriod: "4", gameStatus: "3")
}
