//
//  TokensBalanceResponse.swift
//  PixVerseAPI
//
//  Created by катенька on 15.09.2025.
//



public struct TokensBalanceResponse: Decodable {
    public let user_id: String
    public let app_id: String
    public let balance: Int
}
