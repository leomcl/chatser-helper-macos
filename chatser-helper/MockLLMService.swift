// MockLLMService.swift
import Foundation

// Ensure UserQuery and LLMResponseData structs are defined (ideally in their own files)
// For context:
// struct UserQuery { var text: String }
// struct LLMResponseData {
//     var generatedCommand: String?
//     var instructionalSteps: [String]?
//     var errorMessage: String?
//     var anprPallett: String? // Example specific field
// }

struct MockLLMService {
    func process(query: UserQuery, completion: @escaping (LLMResponseData) -> Void) {
        let queryText = query.text.lowercased()

        // Simulate a delay to mimic real network/processing time
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            let response: LLMResponseData
            // --- Command Generation Scenarios ---
            if queryText.contains("list files detailed") {
                response = LLMResponseData(generatedCommand: "ls -la")
            } else if queryText.contains("c1") {
                response = LLMResponseData(generatedCommand: "pwd")
            } else if queryText.contains("who is logged in") {
                response = LLMResponseData(generatedCommand: "whoami")
            } else if queryText.contains("make a new folder testdir") {
                // Command that succeeds but might not have significant stdout
                response = LLMResponseData(generatedCommand: "mkdir testdir_mock")
            } else if queryText.contains("show spotify") {
                response = LLMResponseData(generatedCommand: "open -a Spotify")
            } else if queryText.contains("c2") {
                // Simulate a command that would likely fail if run by TerminalService
                response = LLMResponseData(generatedCommand: "thisisnotarealcommand -xyz")
            }

            // --- Instructional Steps Scenarios ---
            else if queryText.contains("i1") {
                response = LLMResponseData(instructionalSteps: [
                    "1. For the whole screen: Press Shift + Command + 3.",
                    "2. For a selection: Press Shift + Command + 4, then drag.",
                    "3. For a window: Press Shift + Command + 4, then Space, then click window.",
                    "4. Screenshots save to your Desktop by default."
                ])
            } else if queryText.contains("how to force quit") {
                response = LLMResponseData(instructionalSteps: [
                    "1. Press Option + Command + Escape (Esc).",
                    "2. Select the unresponsive app from the list.",
                    "3. Click 'Force Quit'."
                ])
            }

            // --- Error Message Scenario (from LLM) ---
            else if queryText.contains("tell me a joke") {
                // Simulate LLM unable/unwilling to fulfill a request
                response = LLMResponseData(errorMessage: "I am a command and instruction assistant, I don't tell jokes.")
            }

            // --- Empty/Unexpected LLM Response Scenario ---
            else if queryText.contains("give nothing") {
                response = LLMResponseData() // All fields will be nil
            }

            // --- Default Fallback ---
            else {
                response = LLMResponseData(errorMessage: "Mock: Unrecognized query. Try 'list files detailed', 'how to screenshot', etc.")
            }
            
            completion(response)
        }
    }
}
