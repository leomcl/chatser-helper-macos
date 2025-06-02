// MainViewModel.swift
import Foundation
import SwiftUI // For @Published etc.

class MainViewModel: ObservableObject {
    @Published var userQueryText: String = ""
    @Published var displayOutput: String = "Ask me something or tell me what to do..."
    @Published var isLoading: Bool = false
    @Published var generatedCommandForReview: String? = nil

    private var llmService = MockLLMService() // Your mock service instance
    private let terminalService = TerminalService() // Assuming you still have this

    func submitQuery() {
        guard !userQueryText.isEmpty else {
            displayOutput = "Please enter a command or question."
            return
        }

        isLoading = true
        displayOutput = "Thinking..."
        generatedCommandForReview = nil

        let currentQuery = UserQuery(text: userQueryText) // Create the UserQuery object

        // --- Calling your MockLLMService and using the completion handler ---
        llmService.process(query: currentQuery) { [weak self] responseData in
            // This block of code is the completion handler.
            // It receives 'responseData' of type LLMResponseData.
            // '[weak self]' is important to prevent potential retain cycles,
            // especially since your MockLLMService uses asyncAfter.

            // Since MockLLMService's completion might be on a background thread
            // (due to DispatchQueue.global().asyncAfter),
            // ensure UI updates are dispatched to the main thread.
            DispatchQueue.main.async {
                guard let self = self else { return } // Safely unwrap self

                self.isLoading = false // Update loading state

                if let command = responseData.generatedCommand, !command.isEmpty {
                    self.generatedCommandForReview = command
                    // Update displayOutput to prompt for review.
                    // You might want a more structured way to show this in the UI
                    // rather than just one displayOutput string for everything.
                    self.displayOutput = "Review Command:\n\"\(command)\""
                } else if let steps = responseData.instructionalSteps, !steps.isEmpty {
                    self.generatedCommandForReview = nil // No command if we have steps
                    self.displayOutput = "Instructions:\n" + steps.joined(separator: "\n")
                } else if let errorMsg = responseData.errorMessage, !errorMsg.isEmpty {
                    self.generatedCommandForReview = nil
                    self.displayOutput = "Error: \(errorMsg)"
                } else {
                    self.generatedCommandForReview = nil
                    self.displayOutput = "Sorry, I couldn't process that or the response was empty."
                }
            }
        }
    }

    func executeReviewedCommand() {
        // ... (your existing executeReviewedCommand logic using terminalService) ...
        // This part remains largely the same as it operates on generatedCommandForReview
        guard let commandToExecute = generatedCommandForReview, !commandToExecute.isEmpty else {
            displayOutput = "No command to execute or command is empty."
            return
        }

        isLoading = true
        displayOutput = "Executing: \"\(commandToExecute)\"..."

        DispatchQueue.global(qos: .userInitiated).async {
            let result = self.terminalService.executeCommand(command: commandToExecute)
            
            DispatchQueue.main.async {
                self.isLoading = false
                let commandOutput = result.output
                let commandError = result.error
                var finalDisplayMessage = ""

                if let err = commandError, !err.isEmpty {
                    finalDisplayMessage = "Command Error:\n\(err)"
                } else if let out = commandOutput {
                    finalDisplayMessage = "Command Output:\n\(out.isEmpty ? "[No output]" : out)"
                } else {
                    finalDisplayMessage = "Command executed. No specific output/error."
                }
                self.displayOutput = finalDisplayMessage
                self.generatedCommandForReview = nil
            }
        }
    }
}

