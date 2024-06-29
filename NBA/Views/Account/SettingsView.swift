//
//  SettingsView.swift
//  NBA
//
//  Created by Ali Earp on 25/05/2024.
//

import SwiftUI
import PhotosUI

// MARK: - Settings View -
struct SettingsView: View {
    // MARK: - Properties
    
    // Environment variable to access the current color scheme
    @Environment(\.colorScheme) var colorScheme
    
    // Environment object to access authentication state
    @EnvironmentObject var authModel: AuthModel
    
    // Binding to control the visibility of the settings view
    @Binding var showSettings: Bool
    
    // State variables to control UI interactions
    @State private var showUsernamePopover: Bool = false
    @State private var showPassword: Bool = false
    @State private var showLinkEmail: Bool = false
    @State private var createAccount: Bool = true
    @State private var confirmSignOut: Bool = false
    
    // Constants for layout and appearance
    private let imageSize: CGFloat = 150
    private let paddingSize: CGFloat = 25
    private let buttonCornerRadius: CGFloat = 10
    private let shadowRadius: CGFloat = 10
    private let fontFuturaBold = "Futura-Bold"
    private let fontFuturaCondensedExtraBold = "Futura-CondensedExtraBold"
    private let fontFutura = "Futura"
    private let fontSize: CGFloat = 18
    private let largeFontSize: CGFloat = 30
    private let errorFontSize: CGFloat = 16
    private let topPadding: CGFloat = 10
    
    // MARK: - Main View
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    // Close button to dismiss the settings view
                    closeButton
                    
                    // Profile image picker for users without an account
                    if authModel.user == nil && createAccount {
                        profileImagePicker
                    // Profile image and username for logged-in users
                    } else if authModel.user != nil {
                        profileImageView
                        usernameText
                    }
                    
                    // Account creation or sign-in fields for unauthenticated users
                    if authModel.user == nil {
                        Spacer().frame(height: 20)
                        
                        // Cancel button and form fields for linking an email
                        if showLinkEmail {
                            cancelButton
                            
                            if createAccount {
                                usernameTextField
                            }
                            
                            emailTextField
                            passwordTextField
                            createAccountPicker
                        }
                        
                        // Button to start linking an email
                        linkEmailButton
                    }
                    
                    // Error message display
                    if authModel.error != "" {
                        errorMessage
                    }
                    
                    Spacer().frame(height: 50)
                    
                    // Sign out button for authenticated users
                    if authModel.user != nil {
                        signOutButton
                        eraseAllDataLink
                    }
                }
                // Animate view changes when the createAccount state changes
                .animation(.default, value: createAccount)
            }
            // Set the font for the entire view
            .font(Font.custom(fontFuturaBold, size: fontSize))
            .padding(.horizontal)
            .background(Color(.systemGray6))
            .scrollIndicators(.hidden)
            // Fetch user data when the view appears
            .onAppear {
                authModel.getUser()
            }
        }
    }
    
    // MARK: - Sub Views
    
    // Close button to dismiss the settings view
    private var closeButton: some View {
        HStack {
            Spacer()
            
            Button {
                self.showSettings.toggle()
            } label: {
                Image(systemName: "xmark.circle")
                    .foregroundStyle(Color.primary)
                    .font(.system(size: paddingSize))
            }
        }
        .padding(.top)
    }
    
    // Profile image picker for users creating an account
    private var profileImagePicker: some View {
        PhotosPicker(selection: $authModel.photoItem, matching: .images, preferredItemEncoding: .automatic) {
            ZStack {
                Image(uiImage: authModel.image ?? UIImage(named: "0")!)
                    .resizable()
                    .scaledToFill()
                    .padding(2.5)
                    .frame(width: imageSize, height: imageSize)
                    .clipShape(Circle())
                
                Circle()
                    .stroke(lineWidth: 5)
                    .foregroundStyle(Color.primary)
                    .frame(width: imageSize, height: imageSize)
            }
            .shadow(radius: shadowRadius)
        }
        // Load the selected image into the authModel
        .onChange(of: authModel.photoItem) { _, _ in
            Task {
                if let data = try await authModel.photoItem?.loadTransferable(type: Data.self) {
                    authModel.image = UIImage(data: data)
                }
            }
        }
    }
    
    // Profile image view for authenticated users
    private var profileImageView: some View {
        ZStack {
            Image(uiImage: authModel.image ?? UIImage(named: "0")!)
                .resizable()
                .scaledToFill()
                .padding(2.5)
                .frame(width: imageSize, height: imageSize)
                .clipShape(Circle())
            
            Circle()
                .stroke(lineWidth: 5)
                .foregroundStyle(Color.primary)
                .frame(width: imageSize, height: imageSize)
        }
        .shadow(radius: shadowRadius)
    }
    
    // Display the username for authenticated users
    private var usernameText: some View {
        Text(authModel.username)
            .font(Font.custom(fontFuturaCondensedExtraBold, size: largeFontSize))
            .multilineTextAlignment(.center)
    }
    
    // Cancel button to hide the email linking form
    private var cancelButton: some View {
        Button(role: .destructive) {
            withAnimation {
                self.showLinkEmail = false
            }
        } label: {
            HStack {
                Spacer()
                Text("Cancel")
                Spacer()
            }
            .padding()
            .background(colorScheme == .light ? Color.white : Color.black)
            .clipShape(RoundedRectangle(cornerRadius: buttonCornerRadius))
        }
    }
    
    // Text field for entering a username when creating an account
    private var usernameTextField: some View {
        HStack {
            TextField("Username", text: $authModel.username)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            
            Spacer()
            
            Button {
                self.showUsernamePopover.toggle()
            } label: {
                Image(systemName: "info.circle")
            }
            .frame(width: 25)
            .popover(isPresented: $showUsernamePopover) {
                Text("This will be visible to everyone and cannot be changed later")
                    .font(Font.custom(fontFutura, size: 14))
                    .padding(.horizontal)
                    .presentationCompactAdaptation(.popover)
            }
        }
        .padding()
        .background(colorScheme == .light ? Color.white : Color.black)
        .clipShape(RoundedRectangle(cornerRadius: buttonCornerRadius))
        // Limit the username to 16 characters
        .onChange(of: authModel.username) { _, _ in
            authModel.username.removeLast(authModel.username.count > 16 ? 1 : 0)
        }
    }
    
    // Text field for entering an email address
    private var emailTextField: some View {
        TextField("Email", text: $authModel.email)
            .padding()
            .background(colorScheme == .light ? Color.white : Color.black)
            .clipShape(RoundedRectangle(cornerRadius: buttonCornerRadius))
            .keyboardType(.emailAddress)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
    }
    
    // Password field with a toggle for showing the password
    private var passwordTextField: some View {
        HStack {
            Group {
                if showPassword {
                    TextField("Password", text: $authModel.password)
                } else {
                    SecureField("Password", text: $authModel.password)
                }
            }
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            
            Spacer()
            
            Button {
                self.showPassword.toggle()
            } label: {
                Image(systemName: showPassword ? "eye.slash" : "eye")
                    .foregroundStyle(Color(.darkGray))
            }.frame(width: 25)
        }
        .padding()
        .background(colorScheme == .light ? Color.white : Color.black)
        .clipShape(RoundedRectangle(cornerRadius: buttonCornerRadius))
    }
    
    // Picker to switch between creating an account and signing in
    private var createAccountPicker: some View {
        Picker("", selection: $createAccount) {
            Text("Create").tag(true)
            Text("Sign In").tag(false)
        }.pickerStyle(.segmented)
    }
    
    // Button to start the email linking process
    private var linkEmailButton: some View {
        Button {
            if showLinkEmail {
                Task {
                    if createAccount {
                        await authModel.createUser()
                    } else {
                        await authModel.signIn()
                    }
                }
            } else {
                withAnimation {
                    self.showLinkEmail = true
                }
            }
        } label: {
            HStack {
                Spacer()
                Text(showLinkEmail ? (createAccount ? "Create Public Account" : "Sign In to Public Account") : "Link Email")
                Spacer()
            }
            .foregroundStyle(Color.primary)
            .padding()
            .background(colorScheme == .light ? Color.white : Color.black)
            .clipShape(RoundedRectangle(cornerRadius: buttonCornerRadius))
        }
    }
    
    // Display an error message if there's an authentication error
    private var errorMessage: some View {
        Text(authModel.error)
            .foregroundStyle(Color.red)
            .multilineTextAlignment(.center)
            .font(Font.custom(fontFutura, size: errorFontSize))
    }
    
    // Button to sign out of the current account
    private var signOutButton: some View {
        Button(role: .destructive) {
            self.confirmSignOut.toggle()
        } label: {
            HStack {
                Spacer()
                Text("Sign Out")
                Spacer()
            }
            .padding()
            .background(colorScheme == .light ? Color.white : Color.black)
            .clipShape(RoundedRectangle(cornerRadius: buttonCornerRadius))
        }
        // Confirmation dialog to confirm signing out
        .confirmationDialog("", isPresented: $confirmSignOut) {
            Button(role: .destructive) {
                authModel.signOut()
            } label: {
                Text("Sign Out")
            }
        } message: {
            Text("Are you sure you want to sign out of your public account?")
        }
    }
    
    // Navigation link to erase all user data
    private var eraseAllDataLink: some View {
        NavigationLink {
            ReauthenticateView()
        } label: {
            HStack {
                Text("Erase All Data")
                Spacer()
                Image(systemName: "trash")
            }
            .padding()
            .foregroundStyle(Color.red)
            .background(colorScheme == .light ? Color.white : Color.black)
            .clipShape(RoundedRectangle(cornerRadius: buttonCornerRadius))
        }
    }
}

// MARK: - Preview -

#Preview {
    SettingsView(showSettings: .constant(true))
        .environmentObject(AuthModel())
}

