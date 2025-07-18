//
//  File.swift
//  PixVerseAPI
//
//  Created by катенька on 12.07.2025.
//

import Foundation

public struct TemplateListResponce: Codable {
    public let app_id: String
    public let templates: [Template]
    public let id: Int
}
