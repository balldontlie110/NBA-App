//
//  ReauthenticateView.swift
//  NBA
//
//  Created by Ali Earp on 27/05/2024.
//

import SwiftUI

// MARK: - Reauthenticate View -
struct ReauthenticateView: View {
    // MARK: - Properties
    
    // Environment variable to manage view presentation mode
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    // Environment variable to access the current color scheme
    @Environment(\.colorScheme) var colorScheme
    
    // Environment object to access authentication state
    @EnvironmentObject var authModel: AuthModel
    
    // State variables for user input and view state
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    @State private var confirmEraseAllData: Bool = false
    
    // Constants for layout and appearance
    private let fieldPadding: CGFloat = 10
    private let buttonPadding: CGFloat = 16
    private let buttonCornerRadius: CGFloat = 10
    private let buttonFontSize: CGFloat = 18
    private let errorFontSize: CGFloat = 16
    private let eraseAllDataButtonColor: Color = .red
    private let backgroundColor = Color(.systemGray6)
    
    // MARK: - Main View
    
    var body: some View {
        VStack {
            // Text field for email input
            emailField
            
            // Text field or secure field for password input
            passwordField
            
            // Spacer to provide vertical space between fields and buttons
            Spacer().frame(height: 50)
            
            // Button to trigger data erase action
            eraseAllDataButton
            
            // Text view to display error messages
            errorMessage
            
            // Spacer to push content upwards
            Spacer()
        }
        .font(Font.custom("Futura-Bold", size: 18))
        .padding()
        .background(backgroundColor)
    }
    
    // MARK: - Sub Views
    
    // Text field for entering the email address
    private var emailField: some View {
        TextField("Email", text: $email)
            .padding()
            .background(colorScheme == .light ? Color.white : Color.black)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .keyboardType(.emailAddress)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
    }
    
    // Text field or secure field for entering the password
    private var passwordField: some View {
        HStack {
            if showPassword {
                TextField("Password", text: $password)
            } else {
                SecureField("Password", text: $password)
            }
            
            Spacer()
            
            // Button to toggle password visibility
            Button {
                self.showPassword.toggle()
            } label: {
                Image(systemName: showPassword ? "eye.slash" : "eye")
                    .foregroundStyle(Color(.darkGray))
            }.frame(width: 25)
        }
        .padding()
        .background(colorScheme == .light ? Color.white : Color.black)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)
    }
    
    // Button to trigger the confirmation dialog for erasing all data
    private var eraseAllDataButton: some View {
        Button(role: .destructive) {
            self.confirmEraseAllData.toggle()
        } label: {
            HStack {
                Text("Erase All Data")
                Spacer()
                Image(systemName: "trash")
            }
            .padding()
            .background(colorScheme == .light ? Color.white : Color.black)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        // Confirmation dialog for erasing all data
        .confirmationDialog("", isPresented: $confirmEraseAllData) {
            Button(role: .destructive) {
                Task {
                    await authModel.eraseAllData(email: email, password: password)
                    presentationMode.wrappedValue.dismiss()
                }
            } label: {
                Text("Erase")
                    .foregroundStyle(Color.red)
            }
        } message: {
            Text("Are you sure you want to delete all your data associated with your public account?\n\nThis action cannot be undone.")
        }
    }
    
    // Text view to display error messages from the auth model
    private var errorMessage: some View {
        Group {
            if !authModel.error.isEmpty {
                Text(authModel.error)
                    .foregroundStyle(Color.red)
                    .multilineTextAlignment(.center)
                    .font(Font.custom("Futura", size: 16))
            } else {
                EmptyView()
            }
        }
    }
}

// MARK: - Preview -

#Preview {
    ReauthenticateView()
        .environmentObject(AuthModel())
}
