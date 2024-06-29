//
//  ResultSet.swift
//  NBA
//
//  Created by Ali Earp on 06/05/2024.
//

import Foundation

struct ResultSet: Decodable {
    
    let name: String
    let headers: [String]
    let rowSet: [[RowSet]]
    
}

enum RowSet: Codable {
    case int(Int)
    case double(Double)
    case string(String)
    case null

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let x = try? container.decode(Int.self) {
            self = .int(x)
            return
        } else if let x = try? container.decode(Double.self) {
            self = .double(x)
            return
        } else if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        } else if container.decodeNil() {
            self = .null
            return
        }
        
        throw DecodingError.typeMismatch(RowSet.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for RowSet"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .int(let x):
            try container.encode(x)
        case .double(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        case.null:
            try container.encodeNil()
        }
    }
}
