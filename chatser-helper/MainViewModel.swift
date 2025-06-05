// MainViewModel.swift
import Foundation

@MainActor
class MainViewModel: ObservableObject {
    @Published var userQueryText: String = ""
    @Published var displayOutput: String = "Ask me something or tell me what to do..."
    @Published var isLoading: Bool = false
    @Published var generatedCommandForReview: String? = nil

    private let llmService: LLMService
    private let terminalService = TerminalService()

    init(llmService: LLMService = LLMService()) {
        self.llmService = llmService
    }
    
    func submitQueryToLLM() {
        guard !userQueryText.isEmpty else {
            self.displayOutput = "Please send a message"
            return
        }
        
        self.isLoading = true
        self.displayOutput = "Thinking..."
        self.generatedCommandForReview = nil
        
        let currentUserQuery = userQueryText
        
        Task { // This Task will inherit the MainActor context from the class
            do {
                let systemPrompt = """
                You are an expert macOS terminal assistant. Your sole purpose is to provide precise and safe macOS terminal commands.
                - If multiple commands are required, output each on a new line.
                - Output ONLY the command(s), with no explanations or conversational text.
                - If the request directly asks for clearly destructive operations without specific, narrow targets (e.g., `rm -rf /`), OR if it explicitly requires `sudo` for tasks that don't typically need it, OR if the request is so vague that any generated command would be a pure guess, then output ONLY 'ERROR: Cannot generate command(s).'
                """

                let userInstructions = """
                Your specific instructions for this request:
                1. Analyze the user's request for macOS to understand the complete goal they want to achieve.
                2. Determine the sequence of the most appropriate and safe terminal command(s) required to fully achieve this goal.- Crucially, consider and include any necessary prerequisite commands. For example, ensure a target directory is created (e.g., using `mkdir -p`) before attempting to write, move, or extract files into it if that directory might not already exist.
                3. Generate ONLY the precise macOS terminal command(s). - If multiple commands are required for a single request, output each command on a NEW LINE.- Do NOT include any explanations, comments, conversational text, apologies, or any characters before or after the command(s) themselves, other than the necessary newlines to separate multiple commands.
                4. Prioritize using common and appropriate macOS utilities (e.g., `curl`, `unzip`, `tar`, `mkdir -p`, `mv`, `cp`, `rm` (with caution and for specific targets), `open`, `find`, `grep`, `mdfind`, `osascript`).
                5. Your primary goal is to provide the command(s) to achieve the user's request. If, and only if, the request is fundamentally impossible for you to translate into a sequence of typical macOS terminal commands (e.g., it's not a computer task, it's extremely vague despite attempts to interpret common intentions, or it asks for actions that are inherently and exceptionally high-risk without specific, interactive user confirmations which you cannot provide), then as a last resort, output ONLY the exact text: 'ERROR: Cannot generate command(s).'
                """
                
                let llmOutput = try await llmService.generateCommand(
                    userNaturalLanguageQuery: currentUserQuery,
                    systemMessageContent: systemPrompt,
                    userInstructionsContent: userInstructions,
                    model: "gpt-4.1-nano"
                )
                
                self.isLoading = false
                if llmOutput.starts(with: "ERROR:") {
                    self.displayOutput = llmOutput
                    self.generatedCommandForReview = nil
                } else {
                    self.generatedCommandForReview = llmOutput
                    self.displayOutput = "Review Command(s):\n\(llmOutput)"
                }

            } catch let specificError as LLMError {
                // Ensure UI updates are on the main actor
                // Although with @MainActor on the class, this should be safe,
                // being explicit with await MainActor.run can sometimes help if issues persist.
                    self.isLoading = false
                    self.displayOutput = "Service Error: \(specificError.localizedDescription)"
                    self.generatedCommandForReview = nil
            } catch {
                    self.isLoading = false
                    self.displayOutput = "An unexpected error occurred: \(error.localizedDescription)"
                    self.generatedCommandForReview = nil
                // }
            }
        }
    }

    func executeReviewedCommand() {
        guard let commandToExecute = generatedCommandForReview, !commandToExecute.isEmpty else {
            displayOutput = "No command to execute or command is empty."
            return
        }

        isLoading = true
        displayOutput = "Executing: \"\(commandToExecute)\"..."

        // This DispatchQueue.global sends work to a background thread
        DispatchQueue.global(qos: .userInitiated).async {
            let result = self.terminalService.executeCommand(command: commandToExecute)
            
            // This block is now on a background thread. MUST dispatch to main.
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
