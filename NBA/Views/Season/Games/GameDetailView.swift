//
//  GameDetailView.swift
//  NBA
//
//  Created by Ali Earp on 03/05/2024.
//

import SwiftUI
import YouTubePlayerKit

struct GameDetailView: View {
    // MARK: - Environment Variables
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    // MARK: - State Objects
    @StateObject private var videoViewModel = VideoModel()
    
    // MARK: - State Variables
    @State private var alreadyNotifying: Bool = false
    @State private var informationType: String = "Box Score"
    
    // MARK: - Constants
    private let columns: [GridItem] = [
        GridItem(.fixed(35)),
        GridItem(.flexible()),
        GridItem(.fixed(50)),
        GridItem(.flexible()),
        GridItem(.fixed(35))
    ]
    private let fontName = "Futura"
    private let gameRecapTitlePrefix = "Game%20Recap%3A%20"
    private let pregametimeInterval: TimeInterval = 300
    
    let gameId: String
    let gameHeader: [String : String]
    let homeTeamLineScore: [String : String]
    let awayTeamLineScore: [String : String]
    let date: Date
    
    private var dividerColor: Color { colorScheme == .light ? .black : .white }
    
    // MARK: - Initializer
    init(gameId: String, gameHeader: [String : String], homeTeamLineScore: [String : String], awayTeamLineScore: [String : String], date: Date) {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        self.gameId = gameId
        self.gameHeader = gameHeader
        self.homeTeamLineScore = homeTeamLineScore
        self.awayTeamLineScore = awayTeamLineScore
        self.date = date
    }
    
    var body: some View {
        VStack(spacing: 0) {
            videoPlayer
            gameContent
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                backButton
            }
            
            ToolbarItem(placement: .principal) {
                gameScore
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                placeholderButton
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            fetchGameVideo()
        }
    }
    
    // MARK: - Video Player
    
    private var videoPlayer: some View {
        Group {
            if let videoId = videoViewModel.videoId {
                YouTubePlayerView(YouTubePlayer(stringLiteral: "https://youtube.com/watch?v=\(videoId)"))
                    .frame(maxHeight: UIScreen.main.bounds.size.width * (9/16))
                
                Divider()
                    .background(dividerColor)
            }
        }
    }
    
    // MARK: - Game Content
    
    private var gameContent: some View {
        Group {
            if let gameStatus = gameHeader["GAME_STATUS_ID"] {
                if gameStatus == "1" {
                    pregameNotificationButton
                } else {
                    gameInformationTabs
                }
            }
        }
    }
    
    // MARK: - Pre-Game Notification Button
    
    private var pregameNotificationButton: some View {
        Group {
            if let gameStatusText = gameHeader["GAME_STATUS_TEXT"], let gameId = gameHeader["GAME_ID"] {
                let gameTime = getGameTime(gameStatusText: gameStatusText)
                
                if date == Date() && gameTime.timeIntervalSince(Date()) <= pregametimeInterval {
                    Text("PREGAME")
                } else {
                    Button {
                        toggleGameNotification(gameId: gameId)
                    } label: {
                        notificationButtonContent
                    }
                    .onAppear {
                        Task {
                            alreadyNotifying = await NBA.alreadyNotifying(gameId: gameId)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Notification Button Content
    
    private var notificationButtonContent: some View {
        VStack(spacing: 20) {
            if alreadyNotifying {
                Image(systemName: "bell.and.waves.left.and.right.fill")
                    .font(.title)
                    .foregroundStyle(Color.red)
                Text("Notifications on")
                    .font(Font.custom(fontName, size: 16))
                    .foregroundStyle(Color.primary)
            } else {
                Image(systemName: "bell.slash")
                    .font(.title)
                    .foregroundStyle(Color.red)
                Text("Notifications off")
                    .font(Font.custom(fontName, size: 16))
                    .foregroundStyle(Color.primary)
            }
        }
    }
    
    // MARK: - Game Information Tabs
    
    private var gameInformationTabs: some View {
        TabView(selection: $informationType) {
            BoxScoreView(gameId: gameId)
                .tabItem {
                    Label("Box Score", systemImage: "plus.forwardslash.minus")
                }
                .tag("Box Score")
            
            GameSummaryView(gameId: gameId)
                .tabItem {
                    Label("Game Summary", systemImage: "doc.plaintext")
                }
                .tag("Game Summary")
            
            if let gameStatus = gameHeader["GAME_STATUS_ID"], let endPeriod = gameHeader["LIVE_PERIOD"] {
                PlayByPlayView(gameId: gameId, endPeriod: endPeriod, gameStatus: gameStatus)
                    .tabItem {
                        Label("Play by Play", systemImage: "play.circle")
                    }
                    .tag("Play by Play")
            }
        }
    }
    
    // MARK: - Game Score
    
    private var gameScore: some View {
        LazyVGrid(columns: columns) {
            VStack(spacing: 0) {
                if let teamId = homeTeamLineScore["TEAM_ID"] {
                    NavigationLink {
                        TeamProfileView(teamId: teamId)
                    } label: {
                        Image(teamId)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30)
                            .padding(.top, -10)
                    }
                }
                
                if let winLoss = homeTeamLineScore["TEAM_WINS_LOSSES"] {
                    Text(winLoss)
                        .foregroundStyle(Color(.lightGray))
                        .font(Font.custom("Futura", size: 10))
                        .padding(.top, -2.5)
                }
            }
            
            if let homeTeamScore = homeTeamLineScore["PTS"], let awayTeamScore = awayTeamLineScore["PTS"], let gameStatusText = gameHeader["GAME_STATUS_TEXT"], let gameStatus = gameHeader["GAME_STATUS_ID"] {
                Text(homeTeamScore)
                    .font(Font.custom("Futura-CondensedExtraBold", size: 24))
                    .foregroundStyle(gameStatus == "3" ? Int(homeTeamScore) ?? 0 > Int(awayTeamScore) ?? 0 ? Color.primary : Color(.lightGray) : Color.primary)
                
                Group {
                    let gameTime = getGameTime(gameStatusText: gameStatusText)
                    if gameTime.timeIntervalSince(Date()) <= 300 && gameStatus == "1" {
                        Text("PREGAME")
                    } else {
                        let gameTimeString = getGameTimeString(date: gameTime)
                        Text(gameStatus == "1" ? gameTimeString : gameStatusText.uppercased())
                    }
                }
                .font(Font.custom("Futura-CondensedMedium", size: 14))
                .multilineTextAlignment(.center)
                
                Text(awayTeamScore)
                    .font(Font.custom("Futura-CondensedExtraBold", size: 24))
                    .foregroundStyle(gameStatus == "3" ? Int(awayTeamScore) ?? 0 > Int(homeTeamScore) ?? 0 ? Color.primary : Color(.lightGray) : Color.primary)
            }
            
            VStack(spacing: 0) {
                if let teamId = awayTeamLineScore["TEAM_ID"] {
                    NavigationLink {
                        TeamProfileView(teamId: teamId)
                    } label: {
                        Image(teamId)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30)
                            .padding(.top, -10)
                    }
                }
                
                if let winLoss = awayTeamLineScore["TEAM_WINS_LOSSES"] {
                    Text(winLoss)
                        .foregroundStyle(Color(.lightGray))
                        .font(Font.custom("Futura", size: 10))
                        .padding(.top, -2.5)
                }
            }
        }
    }
    
    // MARK: - Back Button
    
    private var backButton: some View {
        Button {
            presentationMode.wrappedValue.dismiss()
        } label: {
            Image(systemName: "chevron.left")
                .bold()
        }
    }
    
    // MARK: - Placeholder Button
    
    private var placeholderButton: some View {
        Button {
            
        } label: {
            Image(systemName: "chevron.right")
                .bold()
        }
        .opacity(0)
        .disabled(true)
    }
    
    // MARK: - Helper Functions
    
    private func fetchGameVideo() {
        if let gameStatus = gameHeader["GAME_STATUS_ID"], let homeTeamName = homeTeamLineScore["TEAM_NAME"], let awayTeamName = awayTeamLineScore["TEAM_NAME"], let homeTeamScore = homeTeamLineScore["PTS"], let awayTeamScore = awayTeamLineScore["PTS"] {
            
            let winningTeamHome = Int(homeTeamScore) ?? 0 > Int(awayTeamScore) ?? 0 ? true : false
            let losingTeamHome = Int(homeTeamScore) ?? 0 < Int(awayTeamScore) ?? 0 ? true : false
            
            let winningTeamName = winningTeamHome ? homeTeamName : awayTeamName
            let winningTeamScore = winningTeamHome ? homeTeamScore : awayTeamScore
            let losingTeamName = losingTeamHome ? homeTeamName : awayTeamName
            let losingTeamScore = losingTeamHome ? homeTeamScore : awayTeamScore
            
            let videoTitle = gameStatus == "3" ?
                "Game%20Recap%3A%20\(winningTeamName)%20\(winningTeamScore)%2C%20\(losingTeamName)%20\(losingTeamScore)" :
                "Game%20Recap%3A%20\(homeTeamName)%2C%20\(awayTeamName)"
            
            videoViewModel.fetchVideoId(videoTitle: videoTitle)
        }
    }
    
    private func toggleGameNotification(gameId: String) {
        if !alreadyNotifying {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm a"
            dateFormatter.defaultDate = Date()
            dateFormatter.timeZone = TimeZone(abbreviation: "EST")
            
            if let gameStatusText = gameHeader["GAME_STATUS_TEXT"], let homeTeamName = homeTeamLineScore["TEAM_NAME"], let awayTeamName = awayTeamLineScore["TEAM_NAME"],
               let date = dateFormatter.date(from: String(gameStatusText.dropLast(3))) {
                
                let fiveMinutesBefore = Calendar.current.date(byAdding: .minute, value: -5, to: date)
                if let fiveMinutesBefore = fiveMinutesBefore {
                    let timeComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fiveMinutesBefore)
                    let subtitleComponents = Calendar.current.dateComponents([.hour, .minute], from: date)
                    
                    if let year = timeComponents.year,
                       let month = timeComponents.month,
                       let day = timeComponents.day,
                       let hour = timeComponents.hour,
                       let minute = timeComponents.minute,
                       let subtitleHour = subtitleComponents.hour,
                       let subtitleMinute = subtitleComponents.minute {
                        
                        let content = UNMutableNotificationContent()
                        content.title = "\(awayTeamName) @ \(homeTeamName) in 5 minutes"
                        
                        let hourText = "\(String(subtitleHour).count < 2 ? "0\(subtitleHour)" : "\(subtitleHour)")"
                        let minuteText = "\(String(subtitleMinute).count < 2 ? "0\(subtitleMinute)" : "\(subtitleMinute)")"
                        content.subtitle = "\(hourText):\(minuteText)"
                        content.sound = UNNotificationSound.default
                        
                        let trigger = UNCalendarNotificationTrigger(dateMatching: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute), repeats: false)
                        
                        let request = UNNotificationRequest(identifier: gameId, content: content, trigger: trigger)
                        
                        UNUserNotificationCenter.current().add(request)
                        alreadyNotifying = true
                    }
                }
            }
        } else {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [gameId])
            alreadyNotifying = false
        }
    }
}

// MARK: - Preview

#Preview {
    GameDetailView(gameId: "", gameHeader: [:], homeTeamLineScore: [:], awayTeamLineScore: [:], date: Date())
}
