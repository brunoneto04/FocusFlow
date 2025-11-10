import SwiftUI

struct QuickActionsBar: View {
    let isFocusing: Bool
    let onFocus: () -> Void
    let onStop: () -> Void
    let onBreak: () -> Void
    let onPlanner: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            if isFocusing {
                Button {
                    onBreak()
                } label: {
                    Label("Break 5m", systemImage: "pause.circle")
                }
                .buttonStyle(.bordered)

                Button(role: .destructive) {
                    onStop()
                } label: {
                    Label("Stop Focus", systemImage: "stop.circle")
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button {
                    onFocus()
                } label: {
                    Label("Focus Now", systemImage: "bolt.fill")
                }
                .buttonStyle(.borderedProminent)
            }

            Button {
                onPlanner()
            } label: {
                Label("Open Planner", systemImage: "calendar")
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .contain)
    }
}
