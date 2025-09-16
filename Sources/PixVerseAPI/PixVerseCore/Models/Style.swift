//
//  File.swift
//  PixVerseAPI
//
//  Created by катенька on 13.09.2025.
//

public struct Style: Codable {
    public let prompt: String
    public let name: String
    public let is_active: Bool
    public let preview_small: String
    public let preview_large: String
    public let id: Int
    public let template_id: Int
}
