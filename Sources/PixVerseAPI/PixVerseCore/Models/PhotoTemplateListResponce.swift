//
//  PhotoTemplateListResponce.swift
//  PixVerseAPI
//
//  Created by катенька on 19.08.2025.
//

import Foundation

public struct PhotoTemplateListResponce: Codable {
    public let app_id: String
    public let templates: [PhotoTemplate]
    public let id: Int
}
