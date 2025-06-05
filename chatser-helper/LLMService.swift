//
//  LLMService.swift
//  chatser-helper
//
//  Created by Leo Mclaughlin on 04/06/2025.
//
import Foundation

struct LLMService {
    private let apiKey = ""
    private let apiEndpointURL: URL
    
    init(endpoint: URL = URL(string: "https://api.openai.com/v1/responses")!) {
        self.apiEndpointURL = endpoint
    }
    
    func generateCommand(
        userNaturalLanguageQuery: String,
        systemMessageContent: String,
        userInstructionsContent: String,
        model: String
    ) async throws -> String {
        
        let fullUserContent = """
        User's natural language request: '\(userNaturalLanguageQuery)'
                
        \(userInstructionsContent)
        Commands:
        """
        
        let systemMessage = APIMessage(role: "system", content: systemMessageContent)
        let uaerMessage = APIMessage(role: "user", content: fullUserContent)
        
        let payload = APIRequestPayload(model: model, input: [systemMessage, uaerMessage])
        
        let jsonData: Data
        
        do {
            jsonData = try JSONEncoder().encode(payload)
        } catch {
            print("Error encoding payload: \(error.localizedDescription)")
            throw LLMError.encodingFailed("Could not encode API request. \(error.localizedDescription)")
        }
        
        var request = URLRequest(url: apiEndpointURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData

        
        let (data, response): (Data, URLResponse)
        
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            print("Network request error: \(error.localizedDescription)")
            throw LLMError.networkRequestFailed(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            // If response is not an HTTPURLResponse, it's an invalid response type.
            // We don't have the 'error' variable from the catch block above here.
            let details = "The server's response was not a valid HTTP response."
            print(details)
            throw LLMError.badResponse(statusCode: 0, details: details)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            var errorDetails: String?
            if let errorContent = String(data: data, encoding: .utf8), !errorContent.isEmpty {
                errorDetails = errorContent
            }
            print("API Error: Status \(httpResponse.statusCode). Details: \(errorDetails ?? "No additional details.")")
            throw LLMError.badResponse(statusCode: httpResponse.statusCode, details: errorDetails)
        }
        
        do {
            let decodedResponse = try JSONDecoder().decode(APIResponse.self, from: data)
            if let firstOutput = decodedResponse.output.first,
               let firstContent = firstOutput.content.first {
                return firstContent.text
            } else {
                print("Could not find 'text' in the expected API response structure.")
                throw LLMError.dataExtractionFailed("Required 'text' field not found in API response.")
            }
        } catch {
            print("Error decoding API response: \(error.localizedDescription)")
            throw LLMError.decodingFailed("Could not parse server response. \(error.localizedDescription)")
        }
    }
}

    
