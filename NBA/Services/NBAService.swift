//
//  NBAService.swift
//  NBA
//
//  Created by Ali Earp on 20/03/2024.
//

import Foundation

struct NBAService {
    static func fetchGames(date: Date, completion: @escaping (Result<ScoreboardResponse, Error>) -> Void) {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        
        if let year = components.year, let month = components.month, let day = components.day {
            let scoresURL = URL(string: "https://stats.nba.com/stats/scoreboardv2?DayOffset=0&GameDate=\(year)-\(month)-\(day)&LeagueID=00")!
            
            var request = URLRequest(url: scoresURL)
            let headers = [
                "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:72.0) Gecko/20100101 Firefox/72.0",
                "Referer": "https://stats.nba.com/"
            ]
            
            request.allHTTPHeaderFields = headers
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error: \(error)")
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid response")
                    completion(.failure(""))
                    return
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    print("HTTP status code: \(httpResponse.statusCode)")
                    completion(.failure(""))
                    return
                }
                
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        let scoreboardResponse = try decoder.decode(ScoreboardResponse.self, from: data)
                        completion(.success(scoreboardResponse))
                    } catch {
                        print("Error decoding JSON: \(error)")
                        completion(.failure(""))
                    }
                }
            }.resume()
        }
    }

    static func fetchBoxScore(gameId: String, completion: @escaping (Result<BoxScoreGame, Error>) -> Void) {
        let boxScoreURL = URL(string: "https://cdn.nba.com/static/json/liveData/boxscore/boxscore_\(gameId).json")!
        
        var request = URLRequest(url: boxScoreURL)
        request.setValue("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36", forHTTPHeaderField: "User-Agent")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                completion(.failure(""))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print("HTTP status code: \(httpResponse.statusCode)")
                completion(.failure(""))
                return
            }

            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let boxScoreResponse = try decoder.decode(BoxScoreResponse.self, from: data)
                    completion(.success(boxScoreResponse.game))
                } catch {
                    print("Error decoding JSON: \(error)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    static func fetchPlayerStats(playerId: String, completion: @escaping (Result<PlayerStatsResponse, Error>) -> Void) {
        let playerStatsURL = URL(string: "https://stats.nba.com/stats/playercareerstats?LeagueID=&PerMode=Totals&PlayerID=\(playerId)")!
        
        var request = URLRequest(url: playerStatsURL)
        let headers = [
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:72.0) Gecko/20100101 Firefox/72.0",
            "Referer": "https://stats.nba.com/"
        ]
        
        request.allHTTPHeaderFields = headers
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
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
                    let decoder = JSONDecoder()
                    let playerStatsResponse = try decoder.decode(PlayerStatsResponse.self, from: data)
                    completion(.success(playerStatsResponse))
                } catch {
                    print("Error decoding JSON: \(error)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    static func fetchPlayerAwards(playerId: String, completion: @escaping (Result<PlayerAwardsResponse, Error>) -> Void) {
        let playerAwardsURL = URL(string: "https://stats.nba.com/stats/playerawards?PlayerID=\(playerId)")!
        
        var request = URLRequest(url: playerAwardsURL)
        let headers = [
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:72.0) Gecko/20100101 Firefox/72.0",
            "Referer": "https://stats.nba.com/"
        ]
        
        request.allHTTPHeaderFields = headers
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
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
                    let decoder = JSONDecoder()
                    let playerAwardsResponse = try decoder.decode(PlayerAwardsResponse.self, from: data)
                    completion(.success(playerAwardsResponse))
                } catch {
                    print("Error decoding JSON: \(error)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    static func fetchPlayerInfo(playerId: String, completion: @escaping (Result<PlayerInfoResponse, Error>) -> Void) {
        let playerInfoURL = URL(string: "https://stats.nba.com/stats/commonplayerinfo?LeagueID=&PlayerID=\(playerId)")!
        
        var request = URLRequest(url: playerInfoURL)
        let headers = [
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:72.0) Gecko/20100101 Firefox/72.0",
            "Referer": "https://stats.nba.com/"
        ]
        
        request.allHTTPHeaderFields = headers
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
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
                    let decoder = JSONDecoder()
                    let playerInfoResponse = try decoder.decode(PlayerInfoResponse.self, from: data)
                    completion(.success(playerInfoResponse))
                } catch {
                    print("Error decoding JSON: \(error)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    static func fetchAllPlayers(completion: @escaping (Result<AllPlayersResponse, Error>) -> Void) {
        let components = Calendar.current.dateComponents([.year, .month], from: Date())
        if let year = components.year, let month = components.month {
            let season = month < 7 ? year - 1 : year
            
            let allPlayersURL = URL(string: "https://stats.nba.com/stats/commonallplayers?IsOnlyCurrentSeason=1&LeagueID=00&Season=\(String(season))-\(String(season + 1).dropFirst(2))")!
            
            var request = URLRequest(url: allPlayersURL)
            let headers = [
                "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:72.0) Gecko/20100101 Firefox/72.0",
                "Referer": "https://stats.nba.com/"
            ]
            
            request.allHTTPHeaderFields = headers
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
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
                        let decoder = JSONDecoder()
                        let allPlayersResponse = try decoder.decode(AllPlayersResponse.self, from: data)
                        completion(.success(allPlayersResponse))
                    } catch {
                        print("Error decoding JSON: \(error)")
                        completion(.failure(error))
                    }
                }
            }.resume()
        }
    }
    
    static func fetchTeamProfile(teamId: String, completion: @escaping (Result<TeamProfileResponse, Error>) -> Void) {
        let teamProfileURL = URL(string: "https://stats.nba.com/stats/teamdetails?TeamID=\(teamId)")!
        
        var request = URLRequest(url: teamProfileURL)
        let headers = [
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:72.0) Gecko/20100101 Firefox/72.0",
            "Referer": "https://stats.nba.com/"
        ]
        
        request.allHTTPHeaderFields = headers
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
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
                    let decoder = JSONDecoder()
                    let teamProfileResponse = try decoder.decode(TeamProfileResponse.self, from: data)
                    completion(.success(teamProfileResponse))
                } catch {
                    print("Error decoding JSON: \(error)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    static func fetchFranchiseLeaders(teamId: String, completion: @escaping (Result<FranchiseLeadersResponse, Error>) -> Void) {
        let franchiseLeadersURL = URL(string: "https://stats.nba.com/stats/franchiseleaders?LeagueID=&TeamID=\(teamId)")!
        
        var request = URLRequest(url: franchiseLeadersURL)
        let headers = [
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:72.0) Gecko/20100101 Firefox/72.0",
            "Referer": "https://stats.nba.com/"
        ]
        
        request.allHTTPHeaderFields = headers
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
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
                    let decoder = JSONDecoder()
                    let franchiseLeadersResponse = try decoder.decode(FranchiseLeadersResponse.self, from: data)
                    completion(.success(franchiseLeadersResponse))
                } catch {
                    print("Error decoding JSON: \(error)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    static func fetchStandings(completion: @escaping (Result<StandingsResponse, Error>) -> Void) {
        let components = Calendar.current.dateComponents([.year, .month], from: Date())
        if let year = components.year, let month = components.month {
            let season = month < 7 ? year - 1 : year
            
            let standingsURL = URL(string: "https://stats.nba.com/stats/leaguestandingsv3?LeagueID=00&Season=\(String(season))-\(String(season + 1).dropFirst(2))&SeasonType=Regular+Season&SeasonYear=")!
            
            var request = URLRequest(url: standingsURL)
            let headers = [
                "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:72.0) Gecko/20100101 Firefox/72.0",
                "Referer": "https://stats.nba.com/"
            ]
            
            request.allHTTPHeaderFields = headers
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
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
                        let decoder = JSONDecoder()
                        let standingsResponse = try decoder.decode(StandingsResponse.self, from: data)
                        completion(.success(standingsResponse))
                    } catch {
                        print("Error decoding JSON: \(error)")
                        completion(.failure(error))
                    }
                }
            }.resume()
        }
    }
    
    static func fetchPlayByPlay(gameId: String, endPeriod: String, completion: @escaping (Result<PlayByPlayGame, Error>) -> Void) {
        let playByPlayURL = URL(string: "https://stats.nba.com/stats/playbyplayv3?EndPeriod=\(endPeriod)&GameID=\(gameId)&StartPeriod=1")!
        
        var request = URLRequest(url: playByPlayURL)
        let headers = [
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:72.0) Gecko/20100101 Firefox/72.0",
            "Referer": "https://stats.nba.com/"
        ]
        
        request.allHTTPHeaderFields = headers

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                completion(.failure(""))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print("HTTP status code: \(httpResponse.statusCode)")
                completion(.failure(""))
                return
            }

            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let playByPlayResponse = try decoder.decode(PlayByPlay.self, from: data)
                    completion(.success(playByPlayResponse.game))
                } catch {
                    print("Error decoding JSON: \(error)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    static func fetchAllTimeLeaders(completion: @escaping (Result<AllTimeLeadersResponse, Error>) -> Void) {
        let allTimeLeadersURL = URL(string: "https://stats.nba.com/stats/alltimeleadersgrids?LeagueID=00&PerMode=Totals&SeasonType=Regular+Season&TopX=10")!
        
        var request = URLRequest(url: allTimeLeadersURL)
        let headers = [
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:72.0) Gecko/20100101 Firefox/72.0",
            "Referer": "https://stats.nba.com/"
        ]
        
        request.allHTTPHeaderFields = headers

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                completion(.failure(""))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print("HTTP status code: \(httpResponse.statusCode)")
                completion(.failure(""))
                return
            }

            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let allTimeLeadersResponse = try decoder.decode(AllTimeLeadersResponse.self, from: data)
                    completion(.success(allTimeLeadersResponse))
                } catch {
                    print("Error decoding JSON: \(error)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    static func fetchSeasonLeaders(statType: String, date: Int, completion: @escaping (Result<SeasonLeadersResponse, Error>) -> Void) {
        let seasonLeadersURL = URL(string: "https://stats.nba.com/stats/leagueleaders?ActiveFlag=&LeagueID=00&PerMode=Totals&Scope=S&Season=\(date)-\(String(date + 1).dropFirst(2))&SeasonType=Regular+Season&StatCategory=\(statType)")!
        
        var request = URLRequest(url: seasonLeadersURL)
        let headers = [
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:72.0) Gecko/20100101 Firefox/72.0",
            "Referer": "https://stats.nba.com/"
        ]
        
        request.allHTTPHeaderFields = headers

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                completion(.failure(""))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print("HTTP status code: \(httpResponse.statusCode)")
                completion(.failure(""))
                return
            }

            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let seasonLeadersResponse = try decoder.decode(SeasonLeadersResponse.self, from: data)
                    completion(.success(seasonLeadersResponse))
                } catch {
                    print("Error decoding JSON: \(error)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
}

extension String: Error {}
