//
//  TimeLine.swift
//  Reverse
//
//  Created by Damien on 2025/7/26.
//

import Foundation

struct TimeLine: Identifiable, Codable{
    var id: String = UUID().uuidString
    var years: [String]
    var sid: String
}
