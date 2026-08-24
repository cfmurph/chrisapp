import UIKit

/// Renders a simple, clean one-page PDF for an invoice so it can be shared
/// (Mail, Messages, AirDrop, etc.) via the system share sheet.
enum InvoicePDFGenerator {
    static func makePDF(
        for invoice: Invoice,
        businessName: String,
        businessEmail: String,
        currencyCode: String
    ) -> Data {
        let pageWidth: CGFloat = 612 // US Letter @ 72dpi
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 48
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        return renderer.pdfData { context in
            context.beginPage()

            var y: CGFloat = margin

            func draw(_ text: String, font: UIFont, color: UIColor = .black, x: CGFloat = margin, gap: CGFloat = 6) {
                let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
                let attributed = NSAttributedString(string: text, attributes: attrs)
                let size = attributed.boundingRect(
                    with: CGSize(width: pageWidth - margin * 2, height: .greatestFiniteMagnitude),
                    options: .usesLineFragmentOrigin,
                    context: nil
                ).size
                attributed.draw(in: CGRect(x: x, y: y, width: pageWidth - margin * 2, height: size.height))
                y += size.height + gap
            }

            func drawRule() {
                let path = UIBezierPath()
                path.move(to: CGPoint(x: margin, y: y))
                path.addLine(to: CGPoint(x: pageWidth - margin, y: y))
                UIColor.lightGray.setStroke()
                path.lineWidth = 0.5
                path.stroke()
                y += 12
            }

            let titleFont = UIFont.boldSystemFont(ofSize: 24)
            let headingFont = UIFont.boldSystemFont(ofSize: 13)
            let bodyFont = UIFont.systemFont(ofSize: 12)
            let smallFont = UIFont.systemFont(ofSize: 11)

            draw(businessName.isEmpty ? "Invoice" : businessName, font: titleFont)
            if !businessEmail.isEmpty {
                draw(businessEmail, font: smallFont, color: .darkGray)
            }
            draw("INVOICE #\(invoice.invoiceNumber)", font: headingFont, gap: 2)
            draw("Issued: \(Formatters.mediumDate.string(from: invoice.issueDate))", font: smallFont, color: .darkGray, gap: 2)
            draw("Due: \(Formatters.mediumDate.string(from: invoice.dueDate))", font: smallFont, color: .darkGray, gap: 2)
            draw("Status: \(invoice.effectiveStatus.label)", font: smallFont, color: .darkGray)

            drawRule()

            if let client = invoice.client {
                draw("Bill To", font: headingFont, gap: 2)
                draw(client.name, font: bodyFont, gap: 2)
                if !client.email.isEmpty { draw(client.email, font: smallFont, color: .darkGray, gap: 2) }
                if !client.address.isEmpty { draw(client.address, font: smallFont, color: .darkGray, gap: 2) }
            }

            y += 8
            drawRule()

            draw("Description", font: headingFont, gap: 10)
            for item in invoice.sortedLineItems {
                let qty = item.quantity == item.quantity.rounded() ? String(format: "%.0f", item.quantity) : String(format: "%.2f", item.quantity)
                let line = "\(item.itemDescription)   —   \(qty) x \(Formatters.currency(item.unitPrice, code: currencyCode))   =   \(Formatters.currency(item.total, code: currencyCode))"
                draw(line, font: bodyFont, gap: 6)
            }

            drawRule()
            draw("Total: \(Formatters.currency(invoice.subtotal, code: currencyCode))", font: UIFont.boldSystemFont(ofSize: 16), gap: 6)

            if invoice.status == .paid, let paidDate = invoice.paidDate {
                draw("Paid on \(Formatters.mediumDate.string(from: paidDate))", font: smallFont, color: .systemGreen)
            }

            if !invoice.notes.isEmpty {
                y += 8
                drawRule()
                draw("Notes", font: headingFont, gap: 2)
                draw(invoice.notes, font: bodyFont)
            }
        }
    }

    /// Writes the PDF to a temporary file so it can be shared with a proper
    /// filename/extension via `ShareLink`.
    static func writeTempFile(for invoice: Invoice, data: Data) -> URL {
        let fileName = "Invoice-\(invoice.invoiceNumber.replacingOccurrences(of: "/", with: "-")).pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try? data.write(to: url, options: .atomic)
        return url
    }
}
