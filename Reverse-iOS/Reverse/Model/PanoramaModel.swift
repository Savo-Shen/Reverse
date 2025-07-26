//
//  PanoramaModel.swift
//  Reverse
//
//  Created by Damien on 2025/7/24.
//

import Foundation

struct PanoramaRequest {
    let x: String
    let y: String
    let year: String
    let sid: String
    
    init(x: String, y: String, year: String, sid: String) {
        self.x = x
        self.y = y
        self.year = year
        self.sid = sid
    }
    
    var url: URL? {
        return URL(string: "\(baseURL)/baidu_map_jailbreak")
    }
    
    var postData: Data? {
        let parameters = [
            "x": x,
            "y": y,
            "year": year,
            "sid": sid,
        ]
        
        return try? JSONSerialization.data(withJSONObject: parameters)
    }
}
