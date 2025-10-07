import Foundation

// MARK: - Heatmap Cell Data

enum HeatmapCellData {
    case logged   // Orange square
    case missed   // Dark square
    case future   // Empty with orange border
}

// MARK: - Milestone Model

struct Milestone {
    let days: Int
}
