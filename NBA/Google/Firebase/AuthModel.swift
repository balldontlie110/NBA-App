//
//  AuthModel.swift
//  NBA
//
//  Created by Ali Earp on 26/05/2024.
//

import SwiftUI
import PhotosUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import CoreData

@MainActor
class AuthModel: ObservableObject {
    @Published var user: User?
    
    @Published var error: String = ""
    
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    
    @Published var photoItem: PhotosPickerItem?
    @Published var image: UIImage?
    
    init() {
        getUser()
    }
    
    func getUser() {
        self.username = ""
        self.email = ""
        self.password = ""
        self.image = nil
        self.photoItem = nil
        self.error = ""
        
        self.user = Auth.auth().currentUser
        
        if user != nil {
            if let photoUrl = user?.photoURL {
                if let username = user?.displayName {
                    URLSession.shared.dataTask(with: photoUrl) { (data, response, error) in
                        guard let data = data else { return }
                        
                        DispatchQueue.main.async {
                            self.image = UIImage(data: data)
                        }
                    }.resume()
                    
                    self.username = username
                } else {
                    self.error = "Failed to find username."
                }
            } else {
                self.error = "Failed to find profile photo."
            }
        }
    }
    
    func createUser() async {
        if emailIsValid(email) {
            if password.count >= 6 {
                if username != "" {
                    if image != nil {
                        do {
                            self.user = try await Auth.auth().createUser(withEmail: email, password: password).user
                            
                            if let uid = user?.uid {
                                await addData(uid)
                            }
                        } catch {
                            self.error = error.localizedDescription
                        }
                    } else {
                        self.error = "You must select a profile photo."
                    }
                } else {
                    self.error = "You must provide a username."
                }
            } else {
                self.error = "The password must be 6 characters or longer."
            }
        } else {
            self.error = "The email is not a valid email."
        }
    }
    
    private func addData(_ uid: String) async {
        do {
            guard let data = image?.jpegData(compressionQuality: 1) else {
                print("Failed to get image data.")
                return
            }
            
            let reference = Storage.storage().reference().child("users/\(uid)")
            let _ = try await reference.putDataAsync(data)
            let downloadURL = try await reference.downloadURL()
            
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.photoURL = downloadURL
            changeRequest?.displayName = username
            try await changeRequest?.commitChanges()
            
            try await Firestore.firestore().collection("users").document(uid).setData([
                "username" : username,
                "photoURL" : downloadURL.absoluteString,
                "totalCorrect" : 0,
                "totalIncorrect" : 0
            ])
            
            getUser()
        } catch {
            print(error)
        }
    }
    
    func signIn() async {
        do {
            self.user = try await Auth.auth().signIn(withEmail: email, password: password).user
            getUser()
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            getUser()
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func eraseAllData(email: String, password: String) async {
        if let uid = user?.uid {
            do {
                try await reauthenticate(email: email, password: password)
                try await deleteUserFromFirestore(uid)
                try await Storage.storage().reference().child("users/\(uid)").delete()
                try await self.user?.delete()
                
                getUser()
            } catch {
                self.error = "There was an error trying to delete your account."
                print(error)
            }
        }
    }
    
    private func reauthenticate(email: String, password: String) async throws {
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        try await self.user?.reauthenticate(with: credential)
    }
    
    private func deleteUserFromFirestore(_ uid: String) async throws {
        let userDocument = Firestore.firestore().collection("users").document(uid)
        
        let quizzesSnapshot = try await userDocument.collection("quizzes").getDocuments()
        quizzesSnapshot.documents.forEach { quizSnapshot in
            Task {
                let wrongAnswersSnapshot = try await userDocument.collection("quizzes").document(quizSnapshot.documentID).collection("wrongAnswers").getDocuments()
                wrongAnswersSnapshot.documents.forEach { wrongAnswerSnapshot in
                    userDocument.collection("quizzes").document(quizSnapshot.documentID).collection("wrongAnswers").document(wrongAnswerSnapshot.documentID).delete()
                }
            }
            
            userDocument.collection("quizzes").document(quizSnapshot.documentID).delete()
        }
        
        try await userDocument.delete()
    }
    
    private func emailIsValid(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}
