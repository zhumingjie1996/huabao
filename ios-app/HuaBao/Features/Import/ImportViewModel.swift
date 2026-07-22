import Foundation
import SwiftData

@Observable
final class ImportViewModel {
    var showPicker = false
    var isImporting = false
    var resultText: String?
    var errorMessage: String?

    var exportURLs: [URL] = []
    var showExporter = false

    /// 导出为与云开发格式一致的两个 JSONL 文件，并调出分享面板
    func export(products: [Product], records: [OperationRecord]) {
        do {
            exportURLs = try CloudDataExporter.exportFiles(products: products, records: records)
            showExporter = true
        } catch {
            errorMessage = "导出失败：\(error.localizedDescription)"
        }
    }

    func importFiles(_ urls: [URL], context: ModelContext) {
        guard !urls.isEmpty else { return }
        isImporting = true
        resultText = nil
        errorMessage = nil

        var total = ImportReport()
        var importedFileNames: [String] = []
        var failedFileNames: [String] = []

        for url in urls {
            do {
                let report = try CloudDataImporter.importFile(at: url, into: context)
                total.productsAdded += report.productsAdded
                total.productsSkipped += report.productsSkipped
                total.recordsAdded += report.recordsAdded
                total.recordsSkipped += report.recordsSkipped
                total.badLines += report.badLines
                importedFileNames.append(url.lastPathComponent)
            } catch {
                failedFileNames.append(url.lastPathComponent)
            }
        }

        isImporting = false
        if importedFileNames.isEmpty {
            errorMessage = "导入失败，请确认选择的是云数据库导出的 JSON 文件"
        } else {
            var text = "已导入 \(importedFileNames.joined(separator: "、"))\n\n" + total.summary
            if !failedFileNames.isEmpty {
                text += "\n以下文件导入失败：\(failedFileNames.joined(separator: "、"))"
            }
            resultText = text
        }
    }
}
