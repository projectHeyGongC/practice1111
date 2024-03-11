import Foundation

class PCMDataProcessor {
    static func calculateAverageOfTopTenPercent(from data: [Float]) -> Double {
        guard !data.isEmpty else { return 0.0 }
        let sortedData = data.sorted()
        let topTenPercentIndex = Int(Double(sortedData.count) * 0.9)
        let topTenPercentValues = Array(sortedData[topTenPercentIndex..<sortedData.count])
        return Double(topTenPercentValues.reduce(0, +)) / Double(topTenPercentValues.count)
    }
}

