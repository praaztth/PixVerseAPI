//
//  File.swift
//  PixVerseAPI
//
//  Created by катенька on 12.07.2025.
//

import Foundation

public struct VideoGenerationTask: Codable {
    public let video_id: Int
    public let detail: String
    
    public init(video_id: Int, detail: String) {
        self.video_id = video_id
        self.detail = detail
    }
}
