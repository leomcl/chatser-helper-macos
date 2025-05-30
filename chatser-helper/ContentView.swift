// ContentView.swift
import SwiftUI

struct ContentView: View {
    // Create an instance of your ViewModel.
    // @StateObject ensures it persists for the lifecycle of this view.
    @StateObject private var viewModel = MainViewModel()

    var body: some View {
        VStack {
            Text("Chatser Helper")
                .font(.title)
                .padding(.bottom)

            // Text editor for multi-line input or TextField for single line
            TextEditor(text: $viewModel.userQueryText)
                .frame(height: 100) // Give it some initial height
                .border(Color.gray)
                .padding(.bottom)

            Button(action: {
                viewModel.submitQuery()
            }) {
                Text("Submit")
            }
            .disabled(viewModel.isLoading) // Disable button while loading
            .padding(.bottom)

            if viewModel.isLoading {
                ProgressView() // Show a loading spinner
                    .padding(.bottom)
            }

            ScrollView { // To make sure long outputs are scrollable
                Text(viewModel.displayOutput)
                    .frame(maxWidth: .infinity, alignment: .leading) // Align text to left
            }

            Spacer() // Pushes everything to the top
        }
        .padding()
        .frame(minWidth: 400, minHeight: 300) // Give your window some initial size
    }
}

#Preview {
    ContentView()
}
