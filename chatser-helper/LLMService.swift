// LLMService.swift
import Foundation

struct LLMService {
    private let apiKey: String?
    private let apiEndpointURL: URL
    
    init(endpoint: URL = URL(string: "https://api.openai.com/v1/responses")!) {
        self.apiEndpointURL = endpoint
        let retrievedApiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"]
        
        if let key = retrievedApiKey, !key.isEmpty {
            print("LLMService Init: API Key loaded from environment variable: \(key)")
            self.apiKey = key
        } else if retrievedApiKey != nil {
            print("LLMService Init: WARNING - OPENAI_API_KEY environment variable is set but EMPTY.")
            self.apiKey = nil
        }
        else {
            print("LLMService Init: WARNING - OPENAI_API_KEY environment variable not found.")
            print("To fix: In Xcode, go to Product > Scheme > Edit Scheme... > Run (sidebar) > Arguments (tab) > Environment Variables, and add OPENAI_API_KEY with your key as its value.")
            self.apiKey = nil
        }
        // ------------------------------------
    }
    
    func generateCommand(
        userNaturalLanguageQuery: String,
        systemMessageContent: String,
        userInstructionsContent: String,
        model: String
    ) async throws -> String {
            guard let currentApiKey = self.apiKey, !currentApiKey.isEmpty else {
            print("LLMService Error: API Key is missing or empty.")
            throw LLMError.apiKeyMissing // Ensure LLMError has this case
        }
        
        let fullUserContent = """
        User's natural language request: '\(userNaturalLanguageQuery)'
        
        \(userInstructionsContent)
        Commands:
        """
        
        let systemMessage = APIMessage(role: "developer", content: systemMessageContent)
        let userMessage = APIMessage(role: "user", content: fullUserContent)
        
        let payload = APIRequestPayload(model: model, input: [systemMessage, userMessage])
        
        let jsonData: Data
        do {
            jsonData = try JSONEncoder().encode(payload)
        } catch {
            print("Error encoding payload: \(error.localizedDescription)")
            throw LLMError.encodingFailed("Could not encode API request. \(error.localizedDescription)" as! Error)
        }
        
        var request = URLRequest(url: apiEndpointURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(currentApiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            print("Network request error: \(error.localizedDescription)")
            throw LLMError.networkRequestFailed(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
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
        
        print("Raw JSON response for decoding: \(String(data: data, encoding: .utf8) ?? "Could not convert data to string")")
        
        do {
            let decodedResponse = try JSONDecoder().decode(APIResponse.self, from: data)
            if let firstOutput = decodedResponse.output?.first,
               let firstContent = firstOutput.content?.first {
                return firstContent.text
            } else {
                print("Could not find 'text' in the expected API response structure.")
                throw LLMError.dataExtractionFailed("Required 'text' field not found in API response.")
            }
        } catch {
            print("Error decoding API response: \(error.localizedDescription)")
            print("Detailed decoding error: \(error)")
            throw LLMError.decodingFailed("Could not parse server response. \(error.localizedDescription)" as! Error)
        }
    }
}
