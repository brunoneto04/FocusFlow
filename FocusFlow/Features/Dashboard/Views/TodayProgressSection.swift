import SwiftUI

struct TodayProgressSection: View {
    let health: HealthProgress

    var body: some View {
        HStack(spacing: 16) {
            ProgressRing(progress: health.progress) {
                AnyView(
                    VStack(spacing: 2) {
                        Text("\(Int(health.progress * 100))%")
                            .font(.title2).bold()
                        Text("today").font(.caption).foregroundStyle(.secondary)
                    }
                )
            }
            .frame(width: 120, height: 120)

            VStack(alignment: .leading, spacing: 6) {
                Text(health.title).font(.headline)
                Text(health.detail).font(.subheadline).foregroundStyle(.secondary)
                Text("Keep going — you’re close!")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(health.title). \(health.detail).")
    }
}
