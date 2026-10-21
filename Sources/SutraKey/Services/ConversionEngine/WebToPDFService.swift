import AppKit
import Foundation
import os
import WebKit

/// Offscreen WKWebView service that captures web pages using macOS native Print-to-PDF pagination.
@MainActor
public final class WebToPDFService: NSObject, WKNavigationDelegate {
    private var webView: WKWebView?
    private var continuation: CheckedContinuation<URL, Error>?
    private var sourceURL: URL?
    private var timeoutTask: Task<Void, Never>?

    public override init() {
        super.init()
    }

    /// Renders a given URL into a full-fidelity, paginated print PDF in ~/Downloads.
    public func convertToPDF(url: URL) async throws -> URL {
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            self.sourceURL = url

            let config = WKWebViewConfiguration()
            config.suppressesIncrementalRendering = true
            config.mediaTypesRequiringUserActionForPlayback = .all

            // Inject CSS to ensure background colors/graphics print cleanly
            // and suppress intrusive cookie banners while preserving the page's original layout and fonts.
            let printEnhanceCSS = """
            @media print {
                * {
                    -webkit-print-color-adjust: exact !important;
                    print-color-adjust: exact !important;
                }
            }
            #cookie-banner, .cookie-banner, .cookie-notice, #onetrust-consent-sdk,
            .qc-cmp2-container, #CybotCookiebotDialog, [id*="cookie-banner"], [class*="cookie-banner"] {
                display: none !important;
            }
            """
            let userScript = WKUserScript(
                source: "var style = document.createElement('style'); style.innerHTML = `\(printEnhanceCSS)`; document.head.appendChild(style);",
                injectionTime: .atDocumentEnd,
                forMainFrameOnly: true
            )
            config.userContentController.addUserScript(userScript)

            // Desktop viewport for full layout fidelity
            let view = WKWebView(frame: CGRect(x: 0, y: 0, width: 1280, height: 900), configuration: config)
            view.navigationDelegate = self
            self.webView = view

            // Timeout safety (20 seconds)
            self.timeoutTask = Task { [weak self] in
                try? await Task.sleep(nanoseconds: 20_000_000_000)
                guard let self = self, self.continuation != nil else { return }
                Logger.conversion.warning("WebToPDF navigation timed out for \(url). Attempting to print current state.")
                self.generatePrintPDF()
            }

            let request = URLRequest(url: url)
            view.load(request)
        }
    }

    // MARK: - WKNavigationDelegate

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Allow dynamic layout, fonts, and scripts to settle
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self, self.continuation != nil else { return }
            self.generatePrintPDF()
        }
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        Logger.conversion.error("WebToPDF failed navigation: \(error.localizedDescription)")
        continuation?.resume(throwing: error)
        cleanup()
    }

    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        Logger.conversion.error("WebToPDF provisional navigation failed: \(error.localizedDescription)")
        continuation?.resume(throwing: error)
        cleanup()
    }

    // MARK: - Native Print to PDF Generation

    private func generatePrintPDF() {
        guard let webView = self.webView, let continuation = self.continuation else { return }

        // Cancel timeout task
        self.timeoutTask?.cancel()
        self.timeoutTask = nil

        // Determine destination file URL from actual document title
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

        // Configure native macOS PrintInfo for standard A4 paginated printing
        let printInfo = NSPrintInfo()
        printInfo.paperSize = NSSize(width: 595.28, height: 841.89) // Standard A4 (points)
        printInfo.topMargin = 36.0
        printInfo.bottomMargin = 36.0
        printInfo.leftMargin = 36.0
        printInfo.rightMargin = 36.0
        printInfo.horizontalPagination = .fit
        printInfo.verticalPagination = .automatic
        printInfo.jobDisposition = .save
        printInfo.dictionary()[NSPrintInfo.AttributeKey.jobSavingURL] = destinationURL

        let printOperation = webView.printOperation(with: printInfo)
        printOperation.showsPrintPanel = false
        printOperation.showsProgressPanel = false

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let success = printOperation.run()

            if success && FileManager.default.fileExists(atPath: destinationURL.path) {
                Logger.conversion.info("Successfully generated paginated print PDF at \(destinationURL.path)")
                continuation.resume(returning: destinationURL)
                self.cleanup()
            } else {
                // Fallback to WKPDFConfiguration if printOperation didn't output file
                Logger.conversion.warning("PrintOperation did not output file; falling back to WKPDFConfiguration.")
                let fallbackConfig = WKPDFConfiguration()
                webView.createPDF(configuration: fallbackConfig) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success(let data):
                        do {
                            try data.write(to: destinationURL, options: .atomic)
                            Logger.conversion.info("Fallback PDF generated at \(destinationURL.path)")
                            continuation.resume(returning: destinationURL)
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                    self.cleanup()
                }
            }
        }
    }

    private func cleanup() {
        self.timeoutTask?.cancel()
        self.timeoutTask = nil
        self.continuation = nil
        self.webView?.navigationDelegate = nil
        self.webView = nil
    }
}
