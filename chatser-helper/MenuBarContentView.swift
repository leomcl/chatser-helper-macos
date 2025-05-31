// MenuBarContentView.swift
import SwiftUI

struct MenuBarContentView: View {
    @StateObject private var viewModel = MainViewModel()

    enum Field: Hashable {
        case queryInput
    }
    @FocusState private var focusedField: Field?

    var body: some View {
        VStack(spacing: 10) { // Slightly reduced spacing from 12
            Text("Chatser Helper")
                .font(.headline)
                .foregroundColor(.primary) // Ensures it adapts to light/dark mode
                .padding(.top, 8) // Add a little padding at the top

            // --- TextField Styling ---
            HStack { // Use HStack to add padding specifically for the TextField's text
                TextField("Ask or type a command...", text: $viewModel.userQueryText, onCommit: {
                    viewModel.submitQuery()
                })
                .textFieldStyle(PlainTextFieldStyle()) // Removes default border
                .font(.system(size: 14)) // Slightly larger, clean font
                .focused($focusedField, equals: .queryInput)
                
                // Optional: Clear button for the TextField
                if !viewModel.userQueryText.isEmpty {
                    Button {
                        viewModel.userQueryText = ""
                        focusedField = .queryInput // Re-focus after clearing
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.leading, -20) // Pull it slightly into the TextField's padding area
                }
            }
            .padding(.horizontal, 10) // Horizontal padding for the text input area
            .padding(.vertical, 8)    // Vertical padding for the text input area
            .background(Color(NSColor.controlBackgroundColor)) // Subtle background, adapts to light/dark
            .cornerRadius(6) // Rounded corners for the input area
            .overlay( // Add a subtle border, more prominent when focused
                RoundedRectangle(cornerRadius: 6)
                    .stroke(focusedField == .queryInput ? Color.accentColor : Color(NSColor.separatorColor), lineWidth: focusedField == .queryInput ? 1.5 : 0.5)
            )
            .padding(.horizontal) // Padding around the whole input group

            // --- Button Styling ---
            Button(action: {
                viewModel.submitQuery()
            }) {
                Text("Submit")
                    .font(.system(size: 13, weight: .medium))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent) // A modern macOS button style
            // Or for a more minimal button:
            // .buttonStyle(PlainButtonStyle())
            // .background(Color.accentColor)
            // .foregroundColor(.white)
            // .cornerRadius(6)
            .disabled(viewModel.isLoading)
            .padding(.bottom, 5)


            if viewModel.isLoading {
                ProgressView()
                    .padding(.vertical, 5)
            }

            // --- Output Area ---
            ScrollView {
                Text(viewModel.displayOutput)
                    .font(.system(size: 12)) // Slightly more readable than .caption sometimes
                    .foregroundColor(.secondary) // Softer color for output text
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 5) // Indent output text slightly
            }
            .frame(maxHeight: .infinity)
            .background(Color(NSColor.textBackgroundColor)) // Background for the scroll area
            .cornerRadius(6)
            .padding(.horizontal) // Padding around the scroll view
            .padding(.bottom, 8) // Padding at the very bottom

        }
        .padding(.horizontal, 8) // Reduced overall horizontal padding for the VStack
        .padding(.vertical, 0) // Remove vertical padding if top/bottom elements handle it
        .frame(minWidth: 380, idealWidth: 450, minHeight: 280, idealHeight: 350) // Adjusted frame
        .background(.ultraThickMaterial) // Use a system material for the background of the popover
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { // Keep the delay
                focusedField = .queryInput
            }
        }
    }
}

#Preview {
    MenuBarContentView()
        .environmentObject(MainViewModel()) // Ensure preview has the ViewModel
}
