//
//  File.swift
//  PixVerseAPI
//
//  Created by катенька on 12.07.2025.
//

import Foundation

public struct Template: Codable {
    public let prompt: String
    public let name: String
    public let category: String
    public let is_active: Bool
    public let preview_small: String
    public let preview_large: String
    public let id: Int
    public let template_id: Int
}
