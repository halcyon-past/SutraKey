import Foundation
import SwiftUI

/// The 5 supported radial menu conversion actions.
public enum ConversionAction: String, CaseIterable, Identifiable, Sendable {
    case video = "video"
    case audio = "audio"
    case subtitles = "subtitles"
    case gallery = "gallery"
    case pdf = "pdf"

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .video:
            return "Video (MP4)"
        case .audio:
            return "Audio (MP3)"
        case .subtitles:
            return "Subtitles (SRT)"
        case .gallery:
            return "Images / Gallery"
        case .pdf:
            return "Save as PDF"
        }
    }

    public var shortBadge: String {
        switch self {
        case .video:
            return "MP4"
        case .audio:
            return "MP3"
        case .subtitles:
            return "SRT"
        case .gallery:
            return "IMG"
        case .pdf:
            return "PDF"
        }
    }

    public var sfSymbol: String {
        switch self {
        case .video:
            return "film"
        case .audio:
            return "music.note"
        case .subtitles:
            return "doc.text"
        case .gallery:
            return "photo"
        case .pdf:
            return "book"
        }
    }

    public var accentColor: Color {
        switch self {
        case .video:
            return Color(red: 1.0, green: 0.42, blue: 0.24) // Sutra Vermilion
        case .audio:
            return Color(red: 0.22, green: 0.74, blue: 0.98) // Cyan Blue
        case .subtitles:
            return Color(red: 0.98, green: 0.76, blue: 0.20) // Amber Gold
        case .gallery:
            return Color(red: 0.68, green: 0.44, blue: 0.98) // Violet Purple
        case .pdf:
            return Color(red: 0.30, green: 0.85, blue: 0.56) // Emerald Green
        }
    }
}
