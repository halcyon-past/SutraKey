import AppKit
import Foundation
import os
import WebKit

/// Offscreen WKWebView service that captures web articles and generates clean reader PDFs.
@MainActor
public final class WebToPDFService: NSObject, WKNavigationDelegate {
    private var webView: WKWebView?
    private var continuation: CheckedContinuation<URL, Error>?
    private var targetDestinationURL: URL?

    public override init() {
        super.init()
    }

    /// Renders a given URL into a clean, ad-free reader PDF in ~/Downloads.
    public func convertToPDF(url: URL) async throws -> URL {
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation

            let config = WKWebViewConfiguration()
            config.suppressesIncrementalRendering = true

            // Clean reader styling injection
            let readerCSS = """
            header, footer, nav, aside, .ad, .ads, .advertisement, #cookie-banner, .cookie-notice, .popup, .sidebar {
                display: none !important;
            }
            body {
                font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif !important;
                line-height: 1.6 !important;
                max-width: 820px !important;
                margin: 0 auto !important;
                padding: 40px 20px !important;
                color: #111 !important;
                background: #fff !important;
            }
            img {
                max-width: 100% !important;
                height: auto !important;
            }
            """
            let userScript = WKUserScript(
                source: "var style = document.createElement('style'); style.innerHTML = `\(readerCSS)`; document.head.appendChild(style);",
                injectionTime: .atDocumentEnd,
                forMainFrameOnly: true
            )
            config.userContentController.addUserScript(userScript)

            let view = WKWebView(frame: CGRect(x: 0, y: 0, width: 1200, height: 1600), configuration: config)
            view.navigationDelegate = self
            self.webView = view

            let host = url.host ?? "Article"
            let title = "\(host)_\(Int(Date().timeIntervalSince1970))"
            self.targetDestinationURL = URLSanitizer.resolveSafeDestinationURL(forTitle: title, extension: "pdf")

            let request = URLRequest(url: url)
            view.load(request)
        }
    }

    // MARK: - WKNavigationDelegate

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Allow dynamic content to finish loading, then generate PDF
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            let pdfConfig = WKPDFConfiguration()

            webView.createPDF(configuration: pdfConfig) { result in
                switch result {
                case .success(let data):
                    do {
                        guard let dest = self.targetDestinationURL else {
                            throw NSError(
                                domain: "cloud.aritro.sutrakey",
                                code: 500,
                                userInfo: [NSLocalizedDescriptionKey: "Destination URL not prepared"]
                            )
                        }
                        try data.write(to: dest, options: .atomic)
                        Logger.conversion.info("Successfully generated Clean PDF at \(dest.path)")
                        self.continuation?.resume(returning: dest)
                    } catch {
                        self.continuation?.resume(throwing: error)
                    }
                case .failure(let error):
                    self.continuation?.resume(throwing: error)
                }
                self.cleanup()
            }
        }
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        continuation?.resume(throwing: error)
        cleanup()
    }

    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        continuation?.resume(throwing: error)
        cleanup()
    }

    private func cleanup() {
        self.continuation = nil
        self.webView?.navigationDelegate = nil
        self.webView = nil
    }
}
