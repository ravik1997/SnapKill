import SwiftUI

struct ProcessRowView: View {
    let process: RunningProcess
    let onKill: () -> Void
    @State private var isHovering = false
    @State private var showDetails = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(process.name)
                    .font(.headline)

                    .fixedSize(horizontal: false, vertical: true) // Allow wrapping
                HStack {
                    Text("PID: \(process.pid)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if let port = process.port {
                        Text("Port: \(port)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.leading, 4)
                    }
                }
                
                if showDetails, let path = process.fullPath {
                    Text(path)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .transition(.opacity)
                }
            }
            
            Spacer()
            
            Button(action: onKill) {
                Image(systemName: Constants.UI.killIcon)
                    .foregroundColor(isHovering ? .red : .gray)
                    .font(.title2)
            }
            .buttonStyle(.plain)
        }

        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(isHovering ? Color.secondary.opacity(0.1) : Color.clear)
        .cornerRadius(6)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: Constants.Animation.hoverDuration)) {
                isHovering = hovering
            }
        }
        .onTapGesture {
            withAnimation {
                showDetails.toggle()
            }
        }
        .contextMenu {
            Button {
                copyToClipboard(String(process.pid))
            } label: {
                Text("Copy PID")
                Image(systemName: "number")
            }
            
            if let path = process.fullPath {
                Button {
                    copyToClipboard(path)
                } label: {
                    Text("Copy Path")
                    Image(systemName: "folder")
                }
            }
            
            if let port = process.port {
                Button {
                    copyToClipboard(String(port))
                } label: {
                    Text("Copy Port")
                    Image(systemName: "network")
                }
            }
        }
    }
    
    private func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
}
