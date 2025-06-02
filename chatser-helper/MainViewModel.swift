//
//  MainViewModel.swift
//  chatser-helper
//
//  Created by Leo Mclaughlin on 30/05/2025.
//


//
//  MainViewModel.swift.swift
//  chatser-helper
//
//  Created by Leo Mclaughlin on 30/05/2025.
//

// MainViewModel.swift
import Foundation
import SwiftUI // For @Published

class MainViewModel: ObservableObject { // Conforms to ObservableObject to be usable by SwiftUI views

    // --- Properties the View will bind to ---
    @Published var userQueryText: String = "" // For the TextField
    @Published var displayOutput: String = "Ask me something or tell me what to do..." // For showing results/instructions
    @Published var isLoading: Bool = false // To show a progress indicator

    // --- Placeholder for your LLM Service --
    private var llmService = MockLLMService() // We'll define this next

    // --- Intentions / Actions from the View ---
    func submitQuery() {
        guard !userQueryText.isEmpty else {
            displayOutput = "Please enter a command or question."
            return
        }

        isLoading = true
        displayOutput = "Thinking..."

        // Simulate LLM call for now
        llmService.process(query: UserQuery(text: userQueryText)) { [weak self] response in
            DispatchQueue.main.async { // Ensure UI updates are on the main thread
                self?.isLoading = false
                if let command = response.generatedCommand {
                    self?.displayOutput = "Generated Command:\n\(command)"
                    // Later, you'll add logic to show this for review and execution
                } else if let steps = response.instructionalSteps, !steps.isEmpty {
                    self?.displayOutput = "Instructions:\n" + steps.joined(separator: "\n")
                } else if let error = response.errorMessage {
                    self?.displayOutput = "Error: \(error)"
                } else {
                    self?.displayOutput = "Sorry, I couldn't process that."
                }
            }
        }
    }
}
