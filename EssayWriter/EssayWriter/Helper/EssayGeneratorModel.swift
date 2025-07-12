//
//  EssayGeneratorModel.swift
//  EssayWriter
//
//  Created by Ruchi Sancheti on 12/07/25.
//

import Foundation

/// Model for basic mode essay generator request.
struct BasicModeEssayRequest: Codable {
    var length: String
    var essayTitle: String
    var prompt: String
    var academicLevel: String
    var mode: String

    enum CodingKeys: String, CodingKey {
        case length
        case essayTitle
        case prompt
        case academicLevel = "academic_level"
        case mode
    }
}

/// Model for guide mode essay generator request.
struct GuideModeEssayRequest: Codable {
    let length: String
    let essayTitle: String
    let prompt: String
    let academicLevel: String
    let numberOfParagraphs: String
    let tone: String
    let writingStyle: String
    let citation: String
    let addReferences: String

    enum CodingKeys: String, CodingKey {
        case length
        case essayTitle
        case prompt
        case academicLevel = "academic_level"
        case numberOfParagraphs = "no_of_paras"
        case tone
        case writingStyle = "writing_style"
        case citation
        case addReferences = "add_ref"
    }
}

/// Model for essay generator API response.
struct EssayGeneratorResponse: Codable {
    let success: Bool
    let message: String
    let data: EssayDetails
}

/// Model for detailed essay data in API response.
struct EssayDetails: Codable {
    let uuid: String
    let essay: String
    let title: String
    let category: String
    let image: String
}


// MARK: - Default Essay Category Model

/// Represents a category containing default essays.
struct DefaultEssayCategory: Codable, Identifiable {
    let id = UUID()
    let categoryName: String
    let categoryImage: String
    let isPopular: Bool
    let essays: [DefaultEssayDetail]

    enum CodingKeys: String, CodingKey {
        case categoryName
        case categoryImage
        case isPopular = "is_popular"
        case essays
    }
}

/// Represents details of a single default essay.
struct DefaultEssayDetail: Codable {
    let isPopular: Bool
    let title: String
    let img: String
    let text: String

    enum CodingKeys: String, CodingKey {
        case isPopular = "is_popular"
        case title
        case img
        case text
    }
}
