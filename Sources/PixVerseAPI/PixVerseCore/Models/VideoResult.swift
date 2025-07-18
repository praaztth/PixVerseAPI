//
//  File.swift
//  PixVerseAPI
//
//  Created by катенька on 12.07.2025.
//

import Foundation

public struct VideoResult: Codable {
    public var status: String
    public var video_url: String?
    
    public init(status: String, video_url: String? = nil) {
        self.status = status
        self.video_url = video_url
    }
}
