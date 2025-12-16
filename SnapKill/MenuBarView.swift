import SwiftUI

struct MenuBarView: View {
    @StateObject private var processManager = ProcessManager()
    @StateObject private var launchManager = LaunchAtLoginManager()
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool
    @State private var contentHeight: CGFloat = 0
    @State private var showSettings = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Header / Search Area
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: Constants.UI.searchIcon)
                        .foregroundColor(.gray)
                    
                    TextField(Constants.Search.placeholder, text: $searchText)
                        .textFieldStyle(.plain)
                        .focused($isSearchFocused)
                        .onSubmit {
                            performSearch()
                        }
                    
                    if !searchText.isEmpty {
                        Button {
                            withAnimation {
                                searchText = ""
                                processManager.state = .idle
                            }
                        } label: {
                            Image(systemName: Constants.UI.clearIcon)
                                .foregroundColor(.gray)
                        }
                        .buttonStyle(.plain)
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(6)
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            }
            .padding(.horizontal)
            .padding(.top)
            
            Divider()
                .opacity(shouldShowContent ? 1 : 0)
            
            ZStack {
                switch processManager.state {
                case .idle:
                    EmptyView()
                    
                case .searching:
                    VStack {
                        ProgressView()
                            .controlSize(.small)
                        Text(Constants.Search.loadingText)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .background(
                        GeometryReader { geo in
                            Color.clear.preference(key: ViewHeightKey.self, value: geo.size.height)
                        }
                    )
                    .frame(maxWidth: .infinity, maxHeight: 400)
                    .transition(.opacity)
                    
                case .error(let error):
                    VStack {
                        Image(systemName: Constants.UI.errorIcon)
                            .font(.largeTitle)
                            .foregroundColor(.yellow)
                        Text(error)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .background(
                        GeometryReader { geo in
                            Color.clear.preference(key: ViewHeightKey.self, value: geo.size.height)
                        }
                    )
                    .frame(maxWidth: .infinity, maxHeight: 400)
                    .padding()
                    .transition(.opacity)
                    
                case .results(let processes):
                    VStack {
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(processes) { process in
                                    ProcessRowView(process: process) {
                                        processManager.killProcess(process)
                                    }
                                    .transition(.opacity.combined(with: .slide))
                                    
                                    Divider()
                                }
                            }
                            .background(
                                GeometryReader { geo in
                                    Color.clear.preference(key: ViewHeightKey.self, value: geo.size.height)
                                }
                            )
                            .padding(.horizontal)
                        }
                        
                        // Footer Actions
                        if !processes.isEmpty {
                            HStack {
                                Text(String(format: Constants.Search.resultsSummary, processes.count))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Button(Constants.UI.killAll) {
                                    processManager.killAll()
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.red)
                            }
                            .padding(.horizontal)
                            .padding(.bottom)
                        }
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }

            .onPreferenceChange(ViewHeightKey.self) { height in
                DispatchQueue.main.async {
                    contentHeight = height
                }
            }
            .frame(height: dynamicHeight)
            .clipped() // Ensure content doesn't overflow when height is 0
            .animation(.spring(response: Constants.Animation.springResponse, dampingFraction: Constants.Animation.springDamping), value: dynamicHeight)
            .animation(.spring(), value: processManager.state)
            
            // Settings Section
            if showSettings {
                Divider()
                HStack {
                    Toggle("Launch at Login", isOn: $launchManager.isEnabled)
                        .toggleStyle(.switch)
                        .controlSize(.small)
                }
                .padding(.horizontal)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
            
            // Always visible footer
            Divider()
            HStack {
                Button("Quit SnapKill") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.bordered)
                .font(.caption)
                .keyboardShortcut("q", modifiers: .command)
            }
            .padding(.horizontal)
            .padding(.bottom, 4)
        }
        .padding(.bottom)
        .frame(width: Constants.UI.width)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    withAnimation {
                        showSettings.toggle()
                    }
                } label: {
                    Image(systemName: "gearshape")
                }
            }
        }
        .contextMenu {
            Button("Quit SnapKill") {
                NSApplication.shared.terminate(nil)
            }
        }
        .onAppear {
            NSApplication.shared.activate(ignoringOtherApps: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isSearchFocused = true
            }
        }
    }
    
    private var shouldShowContent: Bool {
        if case .idle = processManager.state { return false }
        return true
    }
    
    private var dynamicHeight: CGFloat {
        if case .idle = processManager.state { return 0 }
        // Use measured content height, capped at max height.
        // If contentHeight is 0 (first render), give it a reasonable minimum to prevent collapse.
        let h = contentHeight > 0 ? contentHeight : 50
        return min(h, Constants.UI.maxHeight)
    }
    
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        
        // Smart Search Logic
        if let port = Int(searchText) {
            processManager.fetchProcesses(onPort: port)
        } else {
            processManager.searchProcesses(byName: searchText)
        }
    }
}

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
