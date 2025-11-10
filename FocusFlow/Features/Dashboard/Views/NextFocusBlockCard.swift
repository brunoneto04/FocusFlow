import SwiftUI

struct NextFocusBlockCard: View {
    let block: FocusBlock?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Next Focus Block", systemImage: "calendar.badge.clock")
                    .font(.headline)
                Spacer()
            }

            if let block {
                Text(block.title).font(.subheadline)
                Text("\(timeRange(block.start, block.end)) • \(block.durationMinutes) min")
                    .font(.footnote).foregroundStyle(.secondary)
            } else {
                Text("No upcoming focus blocks.")
                    .font(.subheadline).foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .accessibilityLabel(block != nil
            ? "Next focus block \(block!.title) at \(timeRange(block!.start, block!.end))"
            : "No upcoming focus blocks")
    }

    private func timeRange(_ start: Date, _ end: Date) -> String {
        let f = DateFormatter()
        f.timeStyle = .short
        return "\(f.string(from: start)) – \(f.string(from: end))"
    }
}
