// MenuBarContentView.swift
import SwiftUI

struct MenuBarContentView: View {
    @StateObject private var viewModel = MainViewModel()

    // 1. Define an enum for your focusable fields
    enum Field: Hashable {
        case queryInput
    }

    // 2. Add a @FocusState variable
    @FocusState private var focusedField: Field?

    var body: some View {
        VStack(spacing: 12) { // Slightly adjusted spacing
            Text("Chatser Helper")
                .font(.headline) // Changed from .title to .headline for compactness
                // .padding(.bottom) // Consider if bottom padding here is needed or if spacing handles it

            // 3. Switched TextEditor to TextField
            TextField("Ask or type a command...", text: $viewModel.userQueryText, onCommit: {
                viewModel.submitQuery() // Submit when Enter is pressed
            })
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .focused($focusedField, equals: .queryInput) // 4. Bind the focus state
            .background(Color.yellow) // << TEMPORARY: ADD THIS
            .border(Color.red, width: 2)
            
            Button(action: {
                viewModel.submitQuery()
            }) {
                Text("Submit")
            }
            .disabled(viewModel.isLoading)
            // .padding(.bottom) // Spacing from VStack might be enough

            if viewModel.isLoading {
                ProgressView()
                    .padding(.vertical, 5) // Add some vertical padding for the ProgressView
            }

            ScrollView {
                Text(viewModel.displayOutput)
                    .font(.caption) // Using a smaller font for output in a compact view
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 5) // Add a little space above the output
            }
            .frame(maxHeight: .infinity) // Ensure ScrollView can expand

            // Spacer() // Might not be needed if content naturally fills the desired height
        }
        .padding() // Overall padding for the VStack content
        .frame(minWidth: 400, idealWidth: 400, minHeight: 300, idealHeight: 300) // Adjusted frame, made minWidth slightly larger
        .onAppear {
            // 5. Set focus when the view appears
            // A slight delay can sometimes be necessary for the field to be ready for focus.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { // Shortened delay
                focusedField = .queryInput
            }
        }
    }
}

#Preview { // Keep your preview for easy iteration
    MenuBarContentView()
}
