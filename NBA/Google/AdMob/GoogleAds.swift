//
//  GoogleAds.swift
//  NBA
//
//  Created by Ali Earp on 30/05/2024.
//

import SwiftUI
import GoogleMobileAds
import FirebaseAuth
import FirebaseFirestore

struct BannerView: UIViewControllerRepresentable {
    @State private var viewWidth: CGFloat = .zero
    private let bannerView = GADBannerView()
    private let adUnitID = "ca-app-pub-3940256099942544/2435281174"
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let bannerViewController = BannerViewController()
        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = bannerViewController
        bannerView.delegate = context.coordinator
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerViewController.view.addSubview(bannerView)
        
        NSLayoutConstraint.activate([
            bannerView.bottomAnchor.constraint(
                equalTo: bannerViewController.view.safeAreaLayoutGuide.bottomAnchor),
            bannerView.centerXAnchor.constraint(equalTo: bannerViewController.view.centerXAnchor),
        ])
        bannerViewController.delegate = context.coordinator
        
        return bannerViewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        guard viewWidth != .zero else { return }
        
        bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        bannerView.load(GADRequest())
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, BannerViewControllerWidthDelegate, GADBannerViewDelegate {
        let parent: BannerView
        
        init(_ parent: BannerView) {
            self.parent = parent
        }
        func bannerViewController(
            _ bannerViewController: BannerViewController, didUpdate width: CGFloat
        ) {
            parent.viewWidth = width
        }
    }
}

protocol BannerViewControllerWidthDelegate: AnyObject {
    func bannerViewController(_ bannerViewController: BannerViewController, didUpdate width: CGFloat)
}

class BannerViewController: UIViewController {
    
    weak var delegate: BannerViewControllerWidthDelegate?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        delegate?.bannerViewController(
            self, didUpdate: view.frame.inset(by: view.safeAreaInsets).size.width)
    }
    
    override func viewWillTransition(
        to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator
    ) {
        coordinator.animate { _ in
            
        } completion: { _ in
            self.delegate?.bannerViewController(
                self, didUpdate: self.view.frame.inset(by: self.view.safeAreaInsets).size.width)
        }
    }
}

class RewardedViewModel: NSObject, ObservableObject, GADFullScreenContentDelegate {
    @Published var rewardClaimed: Bool = false
    
    private var rewardedAd: GADRewardedAd?
    
    func loadAd() async {
        do {
            rewardedAd = try await GADRewardedAd.load(withAdUnitID: "ca-app-pub-3940256099942544/1712485313", request: GADRequest())
            rewardedAd?.fullScreenContentDelegate = self
        } catch {
            print("Failed to load rewarded ad with error: \(error.localizedDescription)")
        }
    }
    
    func showAd(date: Date, correct: Int, incorrect: Int) {
        guard let rewardedAd = rewardedAd else {
            return print("Ad wasn't ready.")
        }
        
        rewardedAd.present(fromRootViewController: nil) {
            Task {
                await self.retryQuiz(date: date, correct: correct, incorrect: incorrect)
                await self.loadAd()
            }
        }
    }
    
    func retryQuiz(date: Date, correct: Int, incorrect: Int) async {
        if let uid = Auth.auth().currentUser?.uid {
            do {
                let documentsSnapshot = try await Firestore.firestore().collection("users").document(uid).collection("quizzes").getDocuments()
                documentsSnapshot.documents.forEach { documentSnapshot in
                    if let timestamp = documentSnapshot.data()["date"] as? Timestamp {
                        let checkDate = Calendar.current.dateComponents([.year, .month, .day], from: timestamp.dateValue())
                        let realDate = Calendar.current.dateComponents([.year, .month, .day], from: date)
                        
                        if let checkYear = checkDate.year, let checkMonth = checkDate.month, let checkDay = checkDate.day, let realYear = realDate.year, let realMonth = realDate.month, let realDay = realDate.day {
                            
                            if checkYear == realYear && checkMonth == realMonth && checkDay == realDay {
                                Task {
                                    let quizSnapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
                                    
                                    if var totalCorrect = quizSnapshot.data()?["totalCorrect"] as? Int, var totalIncorrect = quizSnapshot.data()?["totalIncorrect"] as? Int {
                                        totalCorrect -= correct
                                        totalIncorrect -= incorrect
                                        
                                        try await Firestore.firestore().collection("users").document(uid).updateData([
                                            "totalCorrect" : totalCorrect,
                                            "totalIncorrect" : totalIncorrect
                                        ])
                                        
                                        try await Firestore.firestore().collection("users").document(uid).collection("quizzes").document(documentSnapshot.documentID).delete()
                                        self.rewardClaimed = true
                                    }
                                }
                            }
                        }
                    }
                }
            } catch {
                print(error)
            }
        }
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        rewardedAd = nil
    }
}
