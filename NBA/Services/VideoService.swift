//
//  VideoService.swift
//  NBA
//
//  Created by Ali Earp on 05/05/2024.
//

import Foundation

class VideoModel: ObservableObject {
    
    @Published var videoId: String?
    @Published var error: Error?
    
    func fetchVideoId(videoTitle: String) {
        VideoService.fetchVideoId(videoTitle: videoTitle) { result in
            switch result {
            case .success(let videoId):
                DispatchQueue.main.async {
                    self.videoId = videoId
                }
            case.failure(let error):
                DispatchQueue.main.async {
                    self.error = error
                }
            }
        }
    }
    
}

struct VideoService {
    
    static func fetchVideoId(videoTitle: String, completion: @escaping (Result<String, Error>) -> Void) {
        let APIKey = "AIzaSyDrNVsGVw3Ua_ORYA2jg72gWOqMYCTLR9E"
        let scoresURL = URL(string: "https://youtube.googleapis.com/youtube/v3/search?channelId=UCLd4dSmXdrJykO_hgOzbfPw&order=date&q=\(videoTitle)&key=\(APIKey)")!
        
        let request = URLRequest(url: scoresURL)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print("HTTP status code: \(httpResponse.statusCode)")
                return
            }
            
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String : Any] {
                        if let items = json["items"] as? [AnyObject] {
                            if let first = items.first {
                                if let id = first["id"] as? AnyObject {
                                    let videoId = id["videoId"] as? String ?? ""
                                    completion(.success(videoId))
                                }
                            }
                        }
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
}
