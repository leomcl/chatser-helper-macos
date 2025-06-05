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
            let text: String
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

enum LLMError: Error, LocalizedError {
    case encodingFailed(String)
    case invalidURL
    case networkRequestFailed(Error)
    case badResponse(statusCode: Int, details: String?)
    case decodingFailed(String)
    case dataExtractionFailed(String)

    var errorDescription: String? {
        switch self {
        case .encodingFailed(let reason): return "Failed to prepare request: \(reason)"
        case .invalidURL: return "The API endpoint URL was invalid."
        case .networkRequestFailed(let error): return "Network error: \(error.localizedDescription)"
        case .badResponse(let statusCode, let details):
            var message = "Bad API response with status code: \(statusCode)."
            if let details = details, !details.isEmpty { message += " Details: \(details)" }
            return message
        case .decodingFailed(let reason): return "Failed to understand server response: \(reason)"
        case .dataExtractionFailed(let reason): return "Could not get expected data from response: \(reason)"
        }
    }
}
