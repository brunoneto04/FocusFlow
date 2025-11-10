import SwiftUI

struct PermissionBanner: View {
    let missing: [PermissionKind]
    let onGrant: () -> Void

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Image(systemName: "exclamationmark.triangle.fill")
            VStack(alignment: .leading) {
                Text("Permissions needed").bold()
                Text(missing.map { $0.displayName }.joined(separator: ", "))
                    .font(.footnote)
            }
            Spacer()
            Button("Grant", action: onGrant).buttonStyle(.borderedProminent)
        }
        .padding()
        .background(Color.yellow.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
        .accessibilityLabel("Permissions needed: \(missing.map{$0.displayName}.joined(separator: ", "))")
    }
}
