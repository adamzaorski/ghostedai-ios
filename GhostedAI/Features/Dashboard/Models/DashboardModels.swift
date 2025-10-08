import Foundation

// MARK: - Heatmap Cell Data

enum HeatmapCellData {
    case logged   // Orange square
    case missed   // Dark square
    case future   // Empty with orange border
}

// MARK: - Milestone Model

struct Milestone: Identifiable {
    let id = UUID()
    let value: Int
    let type: MilestoneType

    enum MilestoneType {
        case totalDays
        case streak
    }

    /// Get icon based on achievement state and type
    func icon(isAchieved: Bool) -> String {
        if !isAchieved {
            return "🎯" // Target for locked/not achieved
        } else {
            switch type {
            case .totalDays:
                return "🏆" // Trophy for achieved total days
            case .streak:
                return "🔥" // Fire for achieved streaks
            }
        }
    }

    /// Get icon opacity based on achievement state
    func iconOpacity(isAchieved: Bool) -> Double {
        return isAchieved ? 1.0 : 0.4
    }

    /// Get label text
    var label: String {
        switch type {
        case .totalDays:
            return "\(value) days"
        case .streak:
            return "\(value) day streak"
        }
    }

    /// Get status text if achieved
    func statusText(isAchieved: Bool) -> String? {
        return isAchieved ? "Completed" : nil
    }

    /// Legacy compatibility
    var days: Int { value }
    var isStreak: Bool { type == .streak }
}
