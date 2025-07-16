//
//  RegenerateEssayViewModel.swift
//  EssayWriter
//
//  Created by Ruchi Sancheti on 16/07/25.
//

import Foundation
import SwiftUI

class RegenerateEssayViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var isEssayGeneratingError = false
    @Published var isEssayGenerated = false

    @Published var regenerateBasicModeLocalURL = ""
    @Published var regenerateGuidedModeLocalURL = ""
    
    // MARK: - Basic Mode Generate Essay
    
    @MainActor
    func basicModeGenerateEssay(
        essayTitle: String,
        prompt: String,
        length: String,
        academicLevel: String,
        generatedEssaySaveAction: @escaping (EssayGeneratorResponse) -> Void
    ) async throws -> EssayGeneratorResponse {
        
        isLoading = true
        defer { isLoading = false }
        
        guard let url = URL(string: AdConstants.basicModeAPIURL) else {
            isEssayGeneratingError = true
            throw URLError(.badURL)
        }
        
        let parameters = BasicModeEssayRequest(
            length: length,
            essayTitle: essayTitle,
            prompt: prompt,
            academicLevel: academicLevel,
            mode: "basic"
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(parameters)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            print("❗️ Error Response Body:", String(data: data, encoding: .utf8) ?? "No response body")
            isEssayGeneratingError = true
            throw URLError(.badServerResponse)
        }
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("✅ Generate Raw JSON Response:", jsonString)
        }
        
        let result = try JSONDecoder().decode(EssayGeneratorResponse.self, from: data)
        
        if let imageURL = URL(string: result.data.image) {
            let localURL = await EssayLocalStorageManager.shared.saveImageFromURL(
                imageURL,
                withName: "\(result.data.uuid).jpg",
                in: "GeneratedEssay"
            )
            regenerateBasicModeLocalURL = localURL?.absoluteString ?? result.data.image
        }
        
        generatedEssaySaveAction(result)
        isEssayGenerated = true
        print("✅ isEssayGenerated: \(isEssayGenerated)")
        
        return result
    }
    
    // MARK: - Guide Mode Generate Essay
    
    @MainActor
    func guideModeGenerateEssay(
        title: String,
        prompt: String,
        length: String,
        academicLevel: String,
        noOfParagraph: String,
        tone: String,
        writingStyle: String,
        citation: String,
        addRef: String,
        generatedEssaySaveAction: @escaping (EssayGeneratorResponse) -> Void
    ) async throws -> EssayGeneratorResponse {
        
        isLoading = true
        defer { isLoading = false }
        
        guard let url = URL(string: AdConstants.advanceModeAPIURL) else {
            isEssayGeneratingError = true
            throw URLError(.badURL)
        }
        
        let parameters = GuideModeEssayRequest(
            length: length,
            essayTitle: title,
            prompt: prompt,
            academicLevel: academicLevel,
            numberOfParagraphs: noOfParagraph,
            tone: tone,
            writingStyle: writingStyle,
            citation: citation,
            addReferences: addRef
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(parameters)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            print("❗️ Error Response Body:", String(data: data, encoding: .utf8) ?? "No response body")
            isEssayGeneratingError = true
            throw URLError(.badServerResponse)
        }
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("✅ Generate Raw JSON Response:", jsonString)
        }
        
        let result = try JSONDecoder().decode(EssayGeneratorResponse.self, from: data)
        
        if let imageURL = URL(string: result.data.image) {
            let localURL = await EssayLocalStorageManager.shared.saveImageFromURL(
                imageURL,
                withName: "\(result.data.uuid).jpg",
                in: "GeneratedEssay"
            )
            regenerateGuidedModeLocalURL = localURL?.absoluteString ?? result.data.image
        }
        
        generatedEssaySaveAction(result)
        isEssayGenerated = true
        print("✅ isEssayGenerated: \(isEssayGenerated)")
        
        return result
    }
}
