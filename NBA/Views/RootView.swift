//
//  RootView.swift
//  NBA
//
//  Created by Ali Earp on 22/05/2024.
//

import SwiftUI
import FirebaseAuth

// A model representing a card, conforming to Identifiable for use in SwiftUI lists
struct Card: Identifiable {
    let id = UUID().uuidString
    let title: String
    let subtitle: String
    let view: AnyView
}

// MARK: - Root View -
struct RootView: View {
    // MARK: - Properties
    
    // Environment object to access authentication state
    @EnvironmentObject var authModel: AuthModel
    
    @Namespace var namespace
    
    // State variable to track whether the settings view is shown
    @State private var showSettings = false
    
    // State variable to track which card, if any, has been tapped
    @State private var cardTapped: String?
    
    // Constants for layout and appearance
    private let width: CGFloat = UIScreen.main.bounds.width - 15
    private let height: CGFloat = 200
    private let cardSpacing: CGFloat = 15
    private let bottomSpacing: CGFloat = 60
    private let fontSize: CGFloat = 25
    private let padding: CGFloat = 10
    private let gearIcon = "gear"
    private let houseIcon = "house"
    
    // Array of cards to display in the view
    private let cards: [Card] = [
        Card(title: "Season", subtitle: "2023-24", view: AnyView(SeasonRootView())),
        Card(title: "Details", subtitle: "Players and Teams", view: AnyView(DetailsRootView())),
        Card(title: "Quiz", subtitle: "", view: AnyView(QuizRootView()))
    ]
    
    // MARK: - Main View
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if cardTapped == nil {
                    header
                }
                
                cardScrollView
            }
            // Show settings view when showSettings is true
            .sheet(isPresented: $showSettings) {
                SettingsView(showSettings: $showSettings)
            }
        }
    }
    
    // MARK: - Sub Views
    
    // Header view containing the home icon, title, and settings button
    private var header: some View {
        Group {
            HStack(spacing: padding) {
                Image(systemName: houseIcon)
                
                Text("Home")
                    .font(Font.custom("Futura-CondensedExtraBold", size: fontSize))
                
                Spacer()
                
                Button {
                    self.showSettings.toggle()
                } label: {
                    Image(systemName: gearIcon)
                        .foregroundStyle(Color.primary)
                }
            }
            .font(.system(size: fontSize))
            .frame(width: width)
            .padding(.bottom, padding)
            
            Divider()
        }
    }
    
    // Scroll view containing the cards
    private var cardScrollView: some View {
        ScrollView {
            Spacer().frame(height: cardSpacing)
            
            VStack(spacing: cardSpacing) {
                if cardTapped == nil {
                    ForEach(filteredCards) { card in
                        if #available(iOS 18.0, *) {
                            NavigationLink {
                                AnyView(card.view)
                                    .navigationTransition(
                                        .zoom(
                                            sourceID: card.id,
                                            in: namespace
                                        )
                                    )
                                    .toolbarVisibility(.hidden, for: .navigationBar)
                            } label: {
                                ViewCard(card: card, width: width, height: height)
                            }.matchedTransitionSource(id: card.id, in: namespace)
                        } else {
                            NavigationLink {
                                AnyView(card.view)
                            } label: {
                                ViewCard(card: card, width: width, height: height)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            
            Spacer().frame(height: bottomSpacing)
        }
    }
    
    // MARK: - Computed Properties
    
    // Filtered cards based on the tapped card
    private var filteredCards: [Card] {
        if let cardTapped = cardTapped {
            return cards.filter { $0.title == cardTapped }
        }
        
        return cards
    }
}

// MARK: - View Card -
struct ViewCard: View {
    // MARK: - Properties
    
    // Environment variable to access the current color scheme
    @Environment(\.colorScheme) var colorScheme
    
    // State variable to track whether the popover is shown
    @State private var showPopover = false
    
    // Constants for layout and appearance
    private let cardTitleFont = "Futura-CondensedExtraBold"
    private let cardSubtitleFont = "Futura"
    private let imageBlurRadius: CGFloat = 2
    private let cornerRadius: CGFloat = 15
    private let shadowRadius: CGFloat = 5
    private let shadowColor = Color(.lightGray)
    private let popoverTextFontSize: CGFloat = 14
    private let quizTitle = "Quiz"
    private let dateFormatStyle: DateFormatter.Style = .long
    
    // Properties for the card, width, and height
    let card: Card
    let width: CGFloat
    let height: CGFloat
    
    // MARK: - Main View
    
    // Main view layout for the card
    var body: some View {
        ZStack {
            backgroundImage
            cardContent
        }
        .cornerRadius(cornerRadius)
        .popover(isPresented: $showPopover) { popoverContent }
        .shadow(color: colorScheme == .light ? shadowColor : .clear, radius: shadowRadius)
    }
    
    // MARK: - Sub Views
    
    // Background image for the card
    private var backgroundImage: some View {
        Image(card.title.lowercased())
            .resizable()
            .scaledToFill()
            .frame(width: width, height: height)
            .blur(radius: imageBlurRadius)
            .clipped()
            .background(Color.black)
    }
    
    // Content of the card, including title and subtitle
    private var cardContent: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(card.subtitle.isEmpty ? dateString() : card.subtitle)
                        .foregroundStyle(Color(.lightGray))
                        .font(Font.custom(cardSubtitleFont, size: 14))
                        .bold()
                    
                    Text(card.title)
                        .font(Font.custom(cardTitleFont, size: 36))
                        .foregroundStyle(Color.white)
                }
                .padding()
                
                Spacer()
            }
            
            Spacer()
        }.frame(width: width, height: height)
    }
    
    // Content of the popover shown for the quiz card when the user is not logged in
    private var popoverContent: some View {
        Text("You need to be logged in to access the quiz")
            .font(Font.custom(cardSubtitleFont, size: popoverTextFontSize))
            .padding(.horizontal)
            .presentationCompactAdaptation(.popover)
    }
    
    // MARK: - Functions
    
    // Generate a formatted date string for the card subtitle
    private func dateString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = dateFormatStyle
        return formatter.string(from: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date())
    }
}

// MARK: - Preview -
#Preview {
    RootView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
        .environmentObject(AuthModel())
}
