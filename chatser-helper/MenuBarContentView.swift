// MenuBarContentView.swift
import SwiftUI

struct MenuBarContentView: View {
    @StateObject private var viewModel = MainViewModel()

    enum Field: Hashable {
        case queryInput
    }
    @FocusState private var focusedField: Field?

    var body: some View {
        VStack(spacing: 12) { // Keep reasonable spacing
            Text("Chatser Helper")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.top, 10) // Keep some top padding

            // --- Simplified TextField Styling ---
            TextField("Ask or type a command...", text: $viewModel.userQueryText, onCommit: {
                viewModel.submitQuery()
            })
            .textFieldStyle(RoundedBorderTextFieldStyle()) // Reverted to standard bordered style for simplicity
            .font(.system(size: 14))
            .focused($focusedField, equals: .queryInput)
            .padding(.horizontal) // Padding around the TextField

            // --- Simplified Button Styling ---
            Button(action: {
                viewModel.submitQuery()
            }) {
                Text("Submit")
                    .font(.system(size: 13, weight: .medium))

            }
            .buttonStyle(.borderedProminent) // Use a standard prominent style. Clear and simple.
            .disabled(viewModel.isLoading)
            .padding(.bottom, 8) // Add some space below the button

            if viewModel.isLoading {
                ProgressView()
                    .padding(.vertical, 5)
            }

            // --- Simplified Output Area ---
            ScrollView {
                Text(viewModel.displayOutput)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(5) // Simple padding inside the scroll view content
            }
            .frame(maxHeight: .infinity)
            // .background(Color(NSColor.textBackgroundColor)) // Optional: remove if material background is enough
            // .cornerRadius(6) // Optional: remove if you prefer sharper edges for the scroll area
            .padding(.horizontal)
            .padding(.bottom, 10) // Keep some bottom padding

        }
        .padding(.horizontal, 10) // Overall horizontal padding for the VStack
        .padding(.vertical, 5)   // Added a little vertical padding for breathing room
        .frame(minWidth: 350, idealWidth: 400, minHeight: 250, idealHeight: 300) // Adjusted frame
        .background(.ultraThinMaterial) // Changed to ultraThinMaterial for a slightly less intense effect,
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                focusedField = .queryInput
            }
        }
    }
}

#Preview {
    MenuBarContentView()
        .environmentObject(MainViewModel())
}
