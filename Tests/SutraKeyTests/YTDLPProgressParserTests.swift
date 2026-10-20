import Testing
@testable import SutraKey

@Suite("YTDLPProgressParserTests")
struct YTDLPProgressParserTests {

    @Test("Parses standard progress line")
    func testParsesStandardProgressLine() {
        let line = "[download]  45.2% of  120.50MiB at    8.40MiB/s ETA 00:07"
        let parsed = YTDLPProgressParser.parseLine(line)

        #expect(parsed != nil)
        if let result = parsed {
            #expect(result.progress == 0.452)
            #expect(result.speed == "8.40 MiB/s")
            #expect(result.eta == "00:07")
            #expect(result.isPostProcessing == false)
        }
    }

    @Test("Handles post processing line")
    func testHandlesPostProcessingLine() {
        let line = "[ExtractAudio] Destination: /Users/aritrosaha/Downloads/sample.mp3"
        let parsed = YTDLPProgressParser.parseLine(line)

        #expect(parsed != nil)
        if let result = parsed {
            #expect(result.isPostProcessing == true)
            #expect(result.progress == 0.99)
            #expect(result.destinationPath == "/Users/aritrosaha/Downloads/sample.mp3")
        }

        // Additional ffmpeg / merger post-processing lines
        let mergerLine = "[Merger] Merging formats into \"sample.mp4\""
        let parsedMerger = YTDLPProgressParser.parseLine(mergerLine)
        #expect(parsedMerger != nil)
        #expect(parsedMerger?.isPostProcessing == true)
    }

    @Test("Handles 100% completion line")
    func testHandlesCompletionLine() {
        let line = "[download] 100% of 50.00MiB"
        let parsed = YTDLPProgressParser.parseLine(line)

        #expect(parsed != nil)
        #expect(parsed?.progress == 1.0)
    }

    @Test("Ignores empty or non-matching lines")
    func testIgnoresIrrelevantLines() {
        #expect(YTDLPProgressParser.parseLine("") == nil)
        #expect(YTDLPProgressParser.parseLine("   \n  ") == nil)
        #expect(YTDLPProgressParser.parseLine("[debug] Encoders available: ...") == nil)
    }
}
