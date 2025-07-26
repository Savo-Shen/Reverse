//
//  GenerateVideoRequest.swift
//  Reverse
//
//  Created by 沈逸帆 on 2025/7/27.
//

import Foundation

struct GenerateVideoRequest {
    let year: String
    let sid: String
    
    init(year: String, sid: String) {
        self.year = year
        self.sid = sid
    }
    
    var url: URL? {
        return URL(string: "\(baseURL)/get_ai_image")
    }
    
    var postData: Data? {
        let parameters = [
            "year": year,
            "sid": sid,
        ]
        
        return try? JSONSerialization.data(withJSONObject: parameters)
    }
}
