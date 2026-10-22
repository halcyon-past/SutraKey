import AppKit
import CoreGraphics
import Foundation
import os
import PDFKit
import WebKit

/// Offscreen WKWebView service that captures web pages asynchronously and formats them into
/// paginated, publication-quality A4 PDFs preserving original site design, typography, and images.
@MainActor
public final class WebToPDFService: NSObject, WKNavigationDelegate {
    private var webView: WKWebView?
    private var offscreenWindow: NSWindow?
    private var continuation: CheckedContinuation<URL, Error>?
    private var sourceURL: URL?
    private var onStageUpdate: ((String, Double) -> Void)?
    private var timeoutTask: Task<Void, Never>?
    private var isGenerating: Bool = false

    public override init() {
        super.init()
    }

    /// Renders a given URL into a full-fidelity, paginated A4 PDF in ~/Downloads.
    public func convertToPDF(
        url: URL,
        onStageUpdate: ((String, Double) -> Void)? = nil
    ) async throws -> URL {
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            self.sourceURL = url
            self.onStageUpdate = onStageUpdate
            self.isGenerating = false

            onStageUpdate?("Loading webpage...", 0.2)

            let config = WKWebViewConfiguration()
            config.mediaTypesRequiringUserActionForPlayback = .all

            // Inject CSS to suppress floating cookie consent popups and GDPR banners
            // while strictly preserving original typography, layout, colors, and graphics.
            let cleanOverlayCSS = """
            #cookie-banner, .cookie-banner, .cookie-notice, #onetrust-consent-sdk,
            .qc-cmp2-container, #CybotCookiebotDialog, [id*="cookie-banner"], [class*="cookie-banner"] {
                display: none !important;
            }
            """
            let userScript = WKUserScript(
                source: "var style = document.createElement('style'); style.innerHTML = `\(cleanOverlayCSS)`; document.head.appendChild(style);",
                injectionTime: .atDocumentEnd,
                forMainFrameOnly: true
            )
            config.userContentController.addUserScript(userScript)

            // Desktop viewport dimensions for full desktop layout fidelity
            let initialRect = CGRect(x: 0, y: 0, width: 1280, height: 900)
            let view = WKWebView(frame: initialRect, configuration: config)
            view.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Safari/605.1.15"
            view.navigationDelegate = self
            self.webView = view

            // Attach to an offscreen NSWindow so WebKit assigns a display link and RunningBoard does not throttle/suspend WebContent
            let window = NSWindow(
                contentRect: CGRect(x: -10000, y: -10000, width: 1280, height: 900),
                styleMask: [.borderless],
                backing: .buffered,
                defer: false
            )
            window.isReleasedWhenClosed = false
            window.contentView = view
            window.orderBack(nil)
            self.offscreenWindow = window

            // Safety timeout (25 seconds) in case of hanging scripts
            self.timeoutTask = Task { [weak self] in
                try? await Task.sleep(nanoseconds: 25_000_000_000)
                guard let self = self, self.continuation != nil, !self.isGenerating else { return }
                Logger.conversion.warning("WebToPDF navigation reached timeout. Generating PDF with currently loaded state.")
                self.measureAndCapture()
            }

            let request = URLRequest(url: url)
            view.load(request)
        }
    }

    // MARK: - WKNavigationDelegate

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard !isGenerating else { return }
        onStageUpdate?("Rendering layout & graphics...", 0.6)

        // Allow dynamic JavaScript hydration, web fonts, and graphics to settle
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            guard let self = self, self.continuation != nil, !self.isGenerating else { return }
            self.measureAndCapture()
        }
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        Logger.conversion.error("WebToPDF navigation failed: \(error.localizedDescription)")
        continuation?.resume(throwing: error)
        cleanup()
    }

    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        Logger.conversion.error("WebToPDF provisional navigation failed: \(error.localizedDescription)")
        continuation?.resume(throwing: error)
        cleanup()
    }

    // MARK: - Asynchronous Capture & Slicing

    private func measureAndCapture() {
        guard let webView = self.webView, self.continuation != nil, !isGenerating else { return }
        self.isGenerating = true

        self.timeoutTask?.cancel()
        self.timeoutTask = nil

        let measureJS = """
        (function() {
            var body = document.body;
            var html = document.documentElement;
            return Math.max(
                body ? body.scrollHeight : 0,
                body ? body.offsetHeight : 0,
                html ? html.clientHeight : 0,
                html ? html.scrollHeight : 0,
                html ? html.offsetHeight : 0,
                window.innerHeight
            );
        })();
        """

        webView.evaluateJavaScript(measureJS) { [weak self] result, error in
            guard let self = self else { return }
            let contentHeight: CGFloat
            if let h = result as? CGFloat, h > 100 {
                contentHeight = h
            } else if let num = result as? NSNumber, num.doubleValue > 100 {
                contentHeight = CGFloat(num.doubleValue)
            } else {
                contentHeight = 900
            }

            // Adjust webview and window to match true content height for full page rendering
            let fullRect = CGRect(x: 0, y: 0, width: 1280, height: contentHeight)
            webView.frame = fullRect
            self.offscreenWindow?.setContentSize(CGSize(width: 1280, height: contentHeight))

            // Allow layout pass at new dimensions before capturing PDF
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.performCapture(fullHeight: contentHeight)
            }
        }
    }

    private func performCapture(fullHeight: CGFloat) {
        guard let webView = self.webView, let continuation = self.continuation else { return }
        onStageUpdate?("Capturing document...", 0.75)

        // Resolve document title
        let docTitle = webView.title?.trimmingCharacters(in: .whitespacesAndNewlines)
        let resolvedTitle: String
        if let title = docTitle, !title.isEmpty {
            resolvedTitle = title
        } else if let host = self.sourceURL?.host, !host.isEmpty {
            resolvedTitle = "\(host) - Document"
        } else {
            resolvedTitle = "Web Document_\(Int(Date().timeIntervalSince1970))"
        }

        let destinationURL = URLSanitizer.resolveSafeDestinationURL(forTitle: resolvedTitle, extension: "pdf")

        // Use modern asynchronous WKPDFConfiguration (100% non-blocking)
        let pdfConfig = WKPDFConfiguration()
        pdfConfig.rect = CGRect(x: 0, y: 0, width: 1280, height: fullHeight)

        webView.createPDF(configuration: pdfConfig) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let rawPDFData):
                self.onStageUpdate?("Paginating to A4...", 0.9)
                let finalData = self.paginateToA4(pdfData: rawPDFData)

                do {
                    try finalData.write(to: destinationURL, options: .atomic)
                    Logger.conversion.info("Successfully generated paginated PDF at \(destinationURL.path)")
                    continuation.resume(returning: destinationURL)
                } catch {
                    continuation.resume(throwing: error)
                }

            case .failure(let error):
                Logger.conversion.error("createPDF failed: \(error.localizedDescription)")
                continuation.resume(throwing: error)
            }
            self.cleanup()
        }
    }

    // MARK: - CoreGraphics A4 Pagination

    /// Slices a continuous rendered PDF into standard A4 pages with high vector fidelity.
    private func paginateToA4(pdfData: Data) -> Data {
        guard let doc = PDFDocument(data: pdfData),
              let srcPage = doc.page(at: 0) else {
            return pdfData
        }

        let srcBounds = srcPage.bounds(for: .mediaBox)
        guard srcBounds.width > 0, srcBounds.height > 0 else {
            return pdfData
        }

        // Standard A4 dimensions in points: 595.0 x 842.0
        let a4Width: CGFloat = 595.0
        let a4Height: CGFloat = 842.0
        let scale = a4Width / srcBounds.width
        let sliceHeightInSrc = a4Height / scale

        let totalPages = max(1, Int(ceil(srcBounds.height / sliceHeightInSrc)))

        let outputData = NSMutableData()
        guard let consumer = CGDataConsumer(data: outputData as CFMutableData) else {
            return pdfData
        }

        var mediaBox = CGRect(x: 0, y: 0, width: a4Width, height: a4Height)
        guard let pdfContext = CGContext(consumer: consumer, mediaBox: &mediaBox, nil) else {
            return pdfData
        }

        for i in 0..<totalPages {
            pdfContext.beginPage(mediaBox: &mediaBox)
            pdfContext.saveGState()

            // Clip strictly to A4 page dimensions to prevent overflow leakage across page bounds
            pdfContext.clip(to: CGRect(x: 0, y: 0, width: a4Width, height: a4Height))

            // Scale coordinates to fit A4 width
            pdfContext.scaleBy(x: scale, y: scale)

            // Slices from top to bottom (PDF origin is bottom-left)
            let offsetY = srcBounds.height - CGFloat(i + 1) * sliceHeightInSrc
            pdfContext.translateBy(x: 0, y: -offsetY)

            srcPage.draw(with: .mediaBox, to: pdfContext)

            pdfContext.restoreGState()
            pdfContext.endPage()
        }

        pdfContext.closePDF()
        return outputData as Data
    }

    private func cleanup() {
        self.timeoutTask?.cancel()
        self.timeoutTask = nil
        self.continuation = nil
        self.onStageUpdate = nil
        self.webView?.navigationDelegate = nil
        self.webView = nil
        self.offscreenWindow?.orderOut(nil)
        self.offscreenWindow?.contentView = nil
        self.offscreenWindow = nil
        self.isGenerating = false
    }
}
