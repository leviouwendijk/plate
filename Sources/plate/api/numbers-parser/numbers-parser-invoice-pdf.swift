import Foundation
import PDFKit

public struct NumbersParserInvoicePDF {
    public let invoiceRaw: String
    public let invoiceOut: String

    public init(
        invoiceRaw: String? = nil,
        invoiceOut: String? = nil,
    ) throws {
        self.invoiceRaw      = try invoiceRaw      ?? NumbersParserEnvironment.require(.invoiceRaw)
        self.invoiceOut      = try invoiceOut      ?? NumbersParserEnvironment.require(.invoice)
    }

    public func convertRawNumbersPdfToInvoice(selectedPages: [Int] = [12, 13]) throws {
        guard FileManager.default.fileExists(atPath: invoiceRaw) else {
            throw NumbersParserError.fileNotFound("Raw invoice PDF not found at \(invoiceRaw)")
        }

        guard let pdfDocument = PDFDocument(url: URL(fileURLWithPath: invoiceRaw)) else {
            throw NumbersParserError.pdfDocumentCreationFailed("Cannot open PDF at \(invoiceRaw)")
        }

        let newPDF = PDFDocument()
        for (insertIndex, pageIndex) in selectedPages.enumerated() {
            guard let page = pdfDocument.page(at: pageIndex) else {
                throw NumbersParserError.pageNotFound(pageIndex)
            }
            newPDF.insert(page, at: insertIndex)
        }

        guard let outputData = newPDF.dataRepresentation() else {
            throw NumbersParserError.cannotGenerateOutput("Failed to create PDF data for \(invoiceOut)")
        }

        do {
            try outputData.write(to: URL(fileURLWithPath: invoiceOut))
        } catch {
            throw NumbersParserError.writeFailed(file: invoiceOut, underlying: error)
        }
    }
}
