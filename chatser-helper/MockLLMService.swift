//
//  MockLLMService.swift
//  chatser-helper
//
//  Created by Leo Mclaughlin on 30/05/2025.
//

// MockLLMService.swift
import Foundation

struct MockLLMService {
    func process(query: UserQuery, completion: @escaping (LLMResponseData) -> Void) {
        // Simulate a delay
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.5) {
            // Simulate different responses based on input for testing
            if query.text.lowercased().contains("open spotify") {
                completion(LLMResponseData(generatedCommand: "open -a Spotify"))
            } else if query.text.lowercased().contains("how to take a screenshot") {
                completion(LLMResponseData(instructionalSteps: [
                    "1. Press Shift + Command + 3 to capture the entire screen.",
                    "2. Press Shift + Command + 4 to select an area to capture.",
                    "3. The screenshot will be saved to your Desktop."
                ]))
            } else if query.text.lowercased().contains("anpr") {
                completion(LLMResponseData(anprPallett: "PALLETT123")) // Example for ANPR
            } else {
                completion(LLMResponseData(errorMessage: "I'm not sure how to handle that yet."))
            }
        }
    }
}
