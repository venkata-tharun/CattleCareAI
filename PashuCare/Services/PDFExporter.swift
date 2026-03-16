import SwiftUI

class PDFExporter {
    @MainActor
    static func render<Content: View>(view: Content, to url: URL) {
        print("🛠 PDFExporter: Starting render to \(url.path)")
        
        // A4 proportions basically
        let width: CGFloat = 8.5 * 72
        let height: CGFloat = 11 * 72
        
        let renderer = ImageRenderer(content: view)
        renderer.scale = 2.0 // High res
        renderer.proposedSize = ProposedViewSize(width: width, height: height)
        
        renderer.render { size, context in
            print("🛠 PDFExporter: View size rendered as \(size)")
            var box = CGRect(x: 0, y: 0, width: width, height: height)
            
            guard let pdf = CGContext(url as CFURL, mediaBox: &box, nil) else {
                print("❌ PDFExporter: Failed to create CGContext")
                return
            }

            pdf.beginPDFPage(nil)
            // Center the content in the PDF page
            // If size is 0, this might be why it fails
            if size.width > 0 && size.height > 0 {
                pdf.translateBy(x: (width - size.width) / 2.0, y: height - size.height - 50)
            } else {
                print("⚠️ PDFExporter: Rendered size is zero, check view constraints")
            }
            
            context(pdf)
            pdf.endPDFPage()
            pdf.closePDF()
            print("✅ PDFExporter: PDF generation complete")
        }
    }
}

// Share sheet wrapper
struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
