//
//  File.swift
//  PixVerseAPI
//
//  Created by катенька on 12.07.2025.
//

import Foundation

public struct PhotoResult: Codable {
    public let url: String
    public let detail: String
    
    public init(url: String, detail: String) {
        self.url = url
        self.detail = detail
    }
}
