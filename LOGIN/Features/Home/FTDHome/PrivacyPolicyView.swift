import SwiftUI
import WebKit

// MARK: - PrivacyPolicyView

struct PrivacyPolicyView: View {

    @State var viewModel: PrivacyPolicyViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                loadingView
            case .loaded(let data):
                contentView(data)
            case .failure(let msg):
                errorView(msg)
            }
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.ftdTextSecondary)
                }
            }
        }
        .task { await viewModel.load() }
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            ProgressView()
                .tint(Color.ftdAccentOrange)
                .scaleEffect(1.4)
            Text("Loading Privacy Policy…")
                .font(.custom("Poppins-Regular", size: 14))
                .foregroundStyle(Color.ftdTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Content

    private func contentView(_ data: PrivacyData) -> some View {
        VStack(spacing: 0) {
            // Header strip
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text("Privacy Policy")
                    .font(.custom("Poppins-Bold", size: 22))
                    .foregroundStyle(Color.ftdTextPrimary)
                if let title = data.pageTitle {
                    Text(title)
                        .font(.custom("Poppins-Regular", size: 13))
                        .foregroundStyle(Color.ftdAccentOrange)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)
            .padding(.vertical, DesignTokens.Spacing.lg)
            .background(Color.ftdCardBackground)

            Divider().overlay(Color.ftdBorder)

            // HTML content
            if let html = data.pageDescription {
                HTMLWebView(html: html)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    // MARK: - Error

    private func errorView(_ message: String) -> some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 44))
                .foregroundStyle(Color.ftdAccentOrange)

            Text("Couldn't Load Policy")
                .font(.custom("Poppins-SemiBold", size: 17))
                .foregroundStyle(Color.ftdTextPrimary)

            Text(message)
                .font(.custom("Poppins-Regular", size: 13))
                .foregroundStyle(Color.ftdTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)

            Button("Try Again") {
                Task { await viewModel.load() }
            }
            .font(.custom("Poppins-SemiBold", size: 15))
            .foregroundStyle(.white)
            .padding(.horizontal, DesignTokens.Spacing.xxxl)
            .padding(.vertical, 12)
            .background(Color.ftdAccentOrange)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.button))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - HTMLWebView

private struct HTMLWebView: UIViewRepresentable {

    let html: String

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .systemGroupedBackground
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(styledHTML, baseURL: nil)
    }

    private var styledHTML: String {
        """
        <!DOCTYPE html>
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
        <style>
          * { box-sizing: border-box; margin: 0; padding: 0; }

          body {
            font-family: -apple-system, 'Helvetica Neue', sans-serif;
            font-size: 15px;
            line-height: 1.7;
            color: #1a1a2e;
            background-color: #f2f2f7;
            padding: 16px;
          }

          p {
            margin-bottom: 14px;
            text-align: justify;
          }

          strong {
            display: block;
            font-size: 16px;
            font-weight: 700;
            color: #1a1a2e;
            margin-top: 24px;
            margin-bottom: 8px;
            padding-left: 10px;
            border-left: 3px solid #F26522;
          }

          p:has(strong) {
            margin-bottom: 0;
          }

          a { color: #F26522; text-decoration: none; }

          ul, ol { margin-left: 18px; margin-bottom: 14px; }
          li { margin-bottom: 6px; }
        </style>
        </head>
        <body>
        \(html)
        </body>
        </html>
        """
    }
}
