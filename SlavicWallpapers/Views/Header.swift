import SwiftUI

struct Header: View {
    @State private var isRotating = false
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: "photo.circle")
                .font(.system(size: 32))
                .symbolEffect(.bounce, value: isRotating)
                .onAppear {
                    isRotating.toggle()
                }
            
            Text(Localizable.General.appName)
                .font(.headline)
                .transition(.move(edge: .top).combined(with: .opacity))
            
            Text(Localizable.General.version)
                .font(.caption)
                .foregroundColor(.secondary)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        .padding(.bottom, 8)
    }
} 