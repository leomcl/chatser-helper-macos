// APITypes.swift
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
        let content: [ContentItem]?
    }
    let output: [OutputItem]?
    let usage: UsageStats?
}

struct UsageStats: Codable {
    let inputTokens: Int
    let outputTokens: Int
    let totalTokens: Int

    enum CodingKeys: String, CodingKey {
        case inputTokens = "input_tokens"
        case outputTokens = "output_tokens"
        case totalTokens = "total_tokens"
    }
}

enum LLMError: Error, LocalizedError {
    case encodingFailed(Error)
    case invalidURL
    case networkRequestFailed(Error)
    case badResponse(statusCode: Int, details: String?)
    case decodingFailed(Error)
    case dataExtractionFailed(String)
    case apiKeyMissing

    var errorDescription: String? {
        switch self {
        case .encodingFailed(let underlyingError):
            return "Failed to prepare request: \(underlyingError.localizedDescription)"
        case .invalidURL:
            return "The API endpoint URL was invalid."
        case .networkRequestFailed(let underlyingError):
            return "Network error: \(underlyingError.localizedDescription)"
        case .badResponse(let statusCode, let details):
            var message = "Bad API response with status code: \(statusCode)."
            if let details = details, !details.isEmpty { message += " Details: \(details)" }
            return message
        case .decodingFailed(let underlyingError):
            return "Failed to understand server response: \(underlyingError.localizedDescription)"
        case .dataExtractionFailed(let reason):
            return "Could not get expected data from response: \(reason)"
        case .apiKeyMissing:
            return "API Key is missing. Please configure it in the app or its environment."
        }
    }
}
