//
//  CreationEssayViewModel.swift
//  EssayWriter
//
//  Created by Ruchi Sancheti on 12/07/25.
//

import Foundation
import SwiftUI

// MARK: - Basic Mode Model
struct BasicModeModel {
    var text: String
    var essayDescription: String
    var length: String
    var academicLevel: String
}

// MARK: - Generated Essay Data Model
final class GenerateEssayModel: ObservableObject {
    @Published var id: String
    @Published var url: String
    @Published var title: String
    @Published var category: String
    @Published var essay: String

    @Published var prompt: String
    @Published var length: String
    @Published var academicLevel: String
    @Published var noOfParagraph: String
    @Published var writingStyle: String
    @Published var tone: String
    @Published var citation: String
    @Published var addReferences: String
    @Published var isFromBasicMode: Bool

    init(
        id: String = "",
        url: String = "",
        title: String = "",
        category: String = "",
        essay: String = "",
        prompt: String = "",
        length: String = "",
        academicLevel: String = "",
        noOfParagraph: String = "",
        writingStyle: String = "",
        tone: String = "",
        citation: String = "",
        addReferences: String = "",
        isFromBasicMode: Bool = false
    ) {
        self.id = id
        self.url = url
        self.title = title
        self.category = category
        self.essay = essay
        self.prompt = prompt
        self.length = length
        self.academicLevel = academicLevel
        self.noOfParagraph = noOfParagraph
        self.writingStyle = writingStyle
        self.tone = tone
        self.citation = citation
        self.addReferences = addReferences
        self.isFromBasicMode = isFromBasicMode
    }
}

// MARK: - Essay Creation ViewModel
final class EssayCreationViewModel: ObservableObject {
    @Published var selectedTab: EssayGeneratorMode = .basic

    // Status flags
    @Published var isLoading = false
    @Published var isEssayGeneratingError = false
    @Published var isEssayGenerated = false

    // Generated essay result
    @Published var generatedEssayTitle = ""
    @Published var generatedEssay = ""

    // IDs for regeneration
    @Published var regenerateEssayBasicModeId: String? = nil
    @Published var regenerateEssayGuideModeId: String? = nil

    @Published var citation: String? = nil

    // Current generated essay model
    @Published var generatedEssayModel: GenerateEssayModel? = nil
    @Published var isFromBasicMode = false

    // Basic Mode Form Inputs
    @Published var basicModeEssayTitle = ""
    @Published var basicModePrompt = ""
    @Published var basicModeEssayLength = "Short"
    @Published var basicModeEssayAcademicLevel = "High School"

    // Guided Mode Form Inputs
    @Published var guideModeText = ""
    @Published var guideModeDescription = ""
    @Published var guideModeLength = "Short"
    @Published var guideModeAcademicLevel = "High School"
    @Published var numberOfParagraph = "2"
    @Published var writingStyle = "Argumentative"
    @Published var tone = "Friendly"
    @Published var guideModecitation = "Non Specific"
}

// MARK: - Networking
extension EssayCreationViewModel {

    /// Generate essay in Basic Mode
    @MainActor
    func basicModeGenerateEssay(
        essayTitle: String,
        prompt: String,
        length: String,
        academicLevel: String,
        generatedEssaySaveAction: @escaping (GenerateEssayModel) -> Void
    ) async throws -> EssayGeneratorResponse {
        self.isLoading = true
        self.isFromBasicMode = true

        defer {
            self.isLoading = false
        }

        let urlString = "https://api.quillpen.app/api/write-essay-basic"

        guard let url = URL(string: urlString) else {
            self.isEssayGeneratingError = true
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

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            let responseBody = String(data: data, encoding: .utf8) ?? "No response body"
            print("Error Response Body:", responseBody)
            self.isEssayGeneratingError = true
            throw URLError(.badServerResponse)
        }

        if let jsonString = String(data: data, encoding: .utf8) {
            print("Generate Raw JSON Response:", jsonString)
        }

        let result = try JSONDecoder().decode(EssayGeneratorResponse.self, from: data)

        if generatedEssayModel == nil {
            generatedEssayModel = GenerateEssayModel()
        }

        // Save image locally
        let imageURLString = result.data.image
        if let imageURL = URL(string: imageURLString) {
            let localURL = await EssayLocalStorageManager.shared.saveImageFromURL(
                imageURL,
                withName: "\(result.data.uuid).jpg",
                in: "GeneratedEssay"
            )
            generatedEssayModel?.url = localURL?.absoluteString ?? imageURLString
        }

        // Populate model
        generatedEssayModel?.id = result.data.uuid
        generatedEssayModel?.title = result.data.title
        generatedEssayModel?.category = result.data.category
        generatedEssayModel?.essay = result.data.essay
        generatedEssayModel?.prompt = prompt
        generatedEssayModel?.length = length
        generatedEssayModel?.academicLevel = academicLevel
        generatedEssayModel?.citation = ""
        generatedEssayModel?.isFromBasicMode = true

        if let generatedEssayModel {
            generatedEssaySaveAction(generatedEssayModel)
        }

        self.isEssayGenerated = true
        print("\(self.isEssayGenerated) isEssayGenerated")

        return result
    }

    /// Generate essay in Guided Mode
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
        generatedEssaySaveAction: @escaping (GenerateEssayModel) -> Void
    ) async throws -> EssayGeneratorResponse {
        self.isLoading = true

        defer {
            self.isLoading = false
        }

        let urlString = "https://api.quillpen.app/api/write-essay-guided"

        guard let url = URL(string: urlString) else {
            self.isEssayGeneratingError = true
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

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            let responseBody = String(data: data, encoding: .utf8) ?? "No response body"
            print("Error Response Body:", responseBody)
            self.isEssayGeneratingError = true
            throw URLError(.badServerResponse)
        }

        if let jsonString = String(data: data, encoding: .utf8) {
            print("Generate Raw JSON Response:", jsonString)
        }

        let result = try JSONDecoder().decode(EssayGeneratorResponse.self, from: data)

        if generatedEssayModel == nil {
            generatedEssayModel = GenerateEssayModel()
        }

        // Save image locally
        let imageURLString = result.data.image
        if let imageURL = URL(string: imageURLString) {
            let localURL = await EssayLocalStorageManager.shared.saveImageFromURL(
                imageURL,
                withName: "\(result.data.uuid).jpg",
                in: "GeneratedEssay"
            )
            generatedEssayModel?.url = localURL?.absoluteString ?? imageURLString
        }

        // Populate model
        generatedEssayModel?.id = result.data.uuid
        generatedEssayModel?.title = result.data.title
        generatedEssayModel?.category = result.data.category
        generatedEssayModel?.essay = result.data.essay
        generatedEssayModel?.prompt = prompt
        generatedEssayModel?.length = length
        generatedEssayModel?.academicLevel = academicLevel
        generatedEssayModel?.noOfParagraph = noOfParagraph
        generatedEssayModel?.writingStyle = writingStyle
        generatedEssayModel?.tone = tone
        generatedEssayModel?.citation = citation
        generatedEssayModel?.addReferences = addRef
        generatedEssayModel?.isFromBasicMode = false

        if let generatedEssayModel {
            generatedEssaySaveAction(generatedEssayModel)
        }

        self.isEssayGenerated = true
        print("\(self.isEssayGenerated) isEssayGenerated")

        return result
    }
}
