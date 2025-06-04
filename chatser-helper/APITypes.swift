//
//  APITypes.swift
//  chatser-helper
//
//  Created by Leo Mclaughlin on 04/06/2025.
//

import Foundation

struct APIRequestPayload: Codable {
    let model: String
    let input: [APIMessage]
    
}

struct APIMessage: Codable {
    let role: String
    let content: String
}

struct APIResponse: Codable {
    struct OutputItem: Codable {
        struct ContentItem: Codable {
            let tect: String
        }
        let content: [ContentItem]
    }
    let output: [OutputItem]
    let usage: UsageStats
}

struct UsageStats: Codable {
    let inputTokens: Int
    let OutputTokens: Int
    let TotalTOkens: Int
}
