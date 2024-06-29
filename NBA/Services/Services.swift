//
//  Services.swift
//  NBA
//
//  Created by Ali Earp on 03/05/2024.
//

import Foundation
import SwiftUI
import UserNotifications


func getGameTime(gameStatusText: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "hh:mm a"
    dateFormatter.defaultDate = Date()
    dateFormatter.timeZone = TimeZone(abbreviation: "EST")
    
    if let date = dateFormatter.date(from: String(gameStatusText.dropLast(3))) {
        return date
    } else {
        return Date()
    }
}

func getGameTimeString(date: Date) -> String {
    let components = Calendar.current.dateComponents([.hour, .minute], from: date)
    if let hour = components.hour, let minute = components.minute {
        return "\(String(hour).count == 1 ? "0" : "")\(hour):\(minute)\(String(minute).count == 1 ? "0" : "")"
    } else {
        return ""
    }
}

func getDate(dateString: String, est: Bool = false) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = est ? "yyyy-MM-dd'T'HH:mm:ss" : "yyyy-MM-dd'T'HH:mm:ssZ"
    dateFormatter.timeZone = TimeZone.autoupdatingCurrent

    let date = dateFormatter.date(from: dateString) ?? Date()
    dateFormatter.dateFormat = "HH:mm"
    let localTime = dateFormatter.string(from: date)
    
    return localTime
}

func getPercentage(_ decimal: Double) -> Double {
    return round(decimal * 1000) / 10
}

func alreadyNotifying(gameId: String) async -> Bool {
    let pending = await UNUserNotificationCenter.current().pendingNotificationRequests()
    return pending.contains { $0.identifier == gameId }
}

extension String: Identifiable {
    public typealias ID = Int
    public var id: Int {
        return hash
    }
}

extension Int: Identifiable {
    public typealias ID = String
    public var id: String {
        return UUID().uuidString
    }
}
