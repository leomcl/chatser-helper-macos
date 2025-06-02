//
//  TerminalService.swift
//  chatser-helper
//
//  Created by Leo Mclaughlin on 02/06/2025.
//

import Foundation

struct TerminalService {
    func executeCommand(command: String) -> (output: String?, error: String?) {
        let task = Process()
        
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")
        task.arguments = ["-c", command]
        
        // pipes
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        
        var outputString: String?
        var errorString: String?
        
        // TODO: handle errors
        do {
            try task.run()
            
            task.waitUntilExit()
            
            // read std output
            let outputColletedData = try outputPipe.fileHandleForReading.readToEnd()
            if let outputData = outputColletedData, !outputData.isEmpty {
                outputString = String(data: outputData, encoding: .utf8)
            } else {
                outputString = "" // no output
            }
            
            // read std error
            let errorCollectedData = try errorPipe.fileHandleForReading.readToEnd()
            if let errorData = errorCollectedData, !errorData.isEmpty {
                errorString = String(data: errorData, encoding: .utf8)
            } else {
                errorString = "" // no error
            }
            
            // print and return for meantime
            print("Output:\n\(outputString ?? "No output")")
            if let errStr = errorString, !errStr.isEmpty {
                print("Error Output:\n\(errStr)")
            }
                        
            if task.terminationStatus != 0 && (errorString == nil || errorString!.isEmpty) {
                // If there was a non-zero exit status but no specific error message on stderr,
                // capture a generic error.
                errorString = "Command failed with exit code: \(task.terminationStatus)"
                print(errorString!)
            }
            
        } catch {
            // handle error
            print("Error executing command: \(error.localizedDescription)")
            errorString = "Error executing command: \(error.localizedDescription)"
        }
    
        return (output: outputString?.trimmingCharacters(in: .whitespacesAndNewlines),
                error: errorString?.trimmingCharacters(in: .whitespacesAndNewlines))
    }
}

