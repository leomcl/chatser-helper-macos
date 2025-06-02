// MenuBarContentView.swift
import SwiftUI

struct MenuBarContentView: View {
    @StateObject private var viewModel = MainViewModel()

    enum Field: Hashable {
        case queryInput
    }
    @FocusState private var focusedField: Field?

    var body: some View {
        VStack(spacing: 10) {
            Text("Chatser Helper")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.top, 8)

            TextField("Type 'list files', 'who am i', 'help'...", text: $viewModel.userQueryText, onCommit: {
                viewModel.submitQuery() // Gets command for review or shows instructions
            })
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .font(.system(size: 14))
            .focused($focusedField, equals: .queryInput)
            .padding(.horizontal)

            // --- Review and Execute Section ---
            if let commandToReview = viewModel.generatedCommandForReview, !commandToReview.isEmpty {
                VStack(alignment: .leading) { // Group review text and button
                    Text("Review Command:") // This line was part of displayOutput before, now more structured
                        .font(.caption.bold())
                    Text("\"\(commandToReview)\"")
                        .font(.caption.monospaced()) // Monospaced for commands
                        .padding(.vertical, 2)
                        .frame(maxWidth: .infinity, alignment: .leading) // Ensure it takes width
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(4)


                    Button(action: {
                        viewModel.executeReviewedCommand() // Calls the new execute function
                    }) {
                        Text("Execute This Command")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .buttonStyle(.bordered) // A less prominent style than .borderedProminent for this action
                    .tint(.orange) // Make it distinct
                    .padding(.top, 5)
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
            }

            // "Submit" button could be hidden or disabled if a command is awaiting review,
            // or its action could change. For simplicity, we leave it as is for now
            // (it triggers submitQuery which gets a new command for review).
            Button(action: {
                viewModel.submitQuery()
            }) {
                Text("Get Command / Show Instructions") // Clarified button purpose
                    .font(.system(size: 13, weight: .medium))
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoading && viewModel.generatedCommandForReview == nil) // Disable if loading AND no command to review yet
            .padding(.bottom, 5)


            if viewModel.isLoading {
                ProgressView()
                    .padding(.vertical, 5)
            }

            ScrollView {
                Text(viewModel.displayOutput) // This will show all messages from ViewModel
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(5)
            }
            .frame(maxHeight: .infinity)
            .padding(.horizontal)
            .padding(.bottom, 10)

        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .frame(minWidth: 380, idealWidth: 450, minHeight: 300, idealHeight: 400) // Increased height slightly
        .background(.ultraThinMaterial)
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
