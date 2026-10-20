import Foundation
import os

public extension Logger {
    private static let subsystem = "cloud.aritro.sutrakey"

    static let app = Logger(subsystem: subsystem, category: "App")
    static let events = Logger(subsystem: subsystem, category: "EventTap")
    static let accessibility = Logger(subsystem: subsystem, category: "Accessibility")
    static let conversion = Logger(subsystem: subsystem, category: "ConversionEngine")
    static let menuBar = Logger(subsystem: subsystem, category: "MenuBar")
    static let radial = Logger(subsystem: subsystem, category: "RadialMenu")
    static let toast = Logger(subsystem: subsystem, category: "Toast")
}
