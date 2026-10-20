import Foundation
import Testing
@testable import SutraKey

@Suite("URLSanitizerTests")
struct URLSanitizerTests {

    @Test("Extracts clean URL from raw URL string")
    func testExtractsCleanURL() {
        let input = "https://youtube.com/watch?v=2u19wN1tDT4"
        let url = URLSanitizer.extractURL(from: input)
        #expect(url?.absoluteString == "https://youtube.com/watch?v=2u19wN1tDT4")
    }

    @Test("Strips surrounding quotes and brackets")
    func testStripsQuotesAndBrackets() {
        let testCases = [
            "<https://vimeo.com/123456>": "https://vimeo.com/123456",
            "\"https://soundcloud.com/artist/track\"": "https://soundcloud.com/artist/track",
            "'https://news.ycombinator.com/item?id=1'": "https://news.ycombinator.com/item?id=1",
            "(https://github.com/aritrosaha/sutrakey)": "https://github.com/aritrosaha/sutrakey",
            "[https://sutrakey.aritro.cloud]": "https://sutrakey.aritro.cloud"
        ]

        for (input, expected) in testCases {
            let extracted = URLSanitizer.extractURL(from: input)
            #expect(extracted?.absoluteString == expected, "Failed for input: \(input)")
        }
    }

    @Test("Strips trailing punctuation from sentence selection")
    func testStripsTrailingPunctuation() {
        let input = "Check out this lecture: https://youtube.com/watch?v=12345, it is great!"
        let extracted = URLSanitizer.extractURL(from: input)
        #expect(extracted != nil)
        #expect(extracted?.host == "youtube.com")
        #expect(extracted?.absoluteString.contains(",") == false)
    }

    @Test("Rejects invalid schemes and non-URLs")
    func testRejectsInvalidURLs() {
        let invalidInputs = [
            "file:///Users/aritrosaha/secret.txt",
            "ftp://ftp.example.com/file.zip",
            "just plain selected text without a url",
            "mailto:user@example.com",
            "",
            "   \n  "
        ]

        for input in invalidInputs {
            let extracted = URLSanitizer.extractURL(from: input)
            #expect(extracted == nil, "Expected nil for invalid input: \(input)")
        }
    }

    @Test("Normalizes Instagram reel URLs and strips tracking parameters")
    func testInstagramReelNormalization() {
        let reelsInput = "https://www.instagram.com/reels/Dc_U1XRpWEI/?hl=en&igsh=abcdef123"
        let extracted = URLSanitizer.extractURL(from: reelsInput)
        #expect(extracted != nil)
        #expect(extracted?.absoluteString == "https://www.instagram.com/reel/Dc_U1XRpWEI/")

        let pInput = "https://www.instagram.com/p/Dc_U1XRpWEI/?hl=en"
        let pExtracted = URLSanitizer.extractURL(from: pInput)
        #expect(pExtracted != nil)
        #expect(pExtracted?.absoluteString == "https://www.instagram.com/p/Dc_U1XRpWEI/")
    }
}
