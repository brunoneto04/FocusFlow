import SwiftUI

struct UsageSummaryCard: View {
    let usage: UsageSummary
    let onOpenReport: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Screen Time (Today)", systemImage: "hourglass")
                    .font(.headline)
                Spacer()
                Button("View details", action: onOpenReport)
                    .font(.footnote)
            }

            ProgressView(value: progressValue)
                .progressViewStyle(.linear)

            HStack {
                Text(summaryLine).font(.subheadline)
                Spacer()
                if let app = usage.topAppName, let min = usage.topAppMinutes {
                    Text("Top: \(app) · \(min)m").font(.footnote).foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Screen Time today \(summaryLine)")
    }

    private var progressValue: Double {
        guard let limit = usage.limitMinutes, limit > 0 else { return 0 }
        return min(1.0, Double(usage.usedMinutes) / Double(limit))
    }

    private var summaryLine: String {
        if let limit = usage.limitMinutes {
            return "\(usage.usedMinutes)m / \(limit)m"
        }
        return "\(usage.usedMinutes)m"
    }
}
