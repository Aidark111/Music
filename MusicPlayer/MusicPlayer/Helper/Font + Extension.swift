import SwiftUI

struct DurationFontModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundStyle(.white)
            .font(.system(size: 14, weight: .light, design: .rounded))
    }
}

extension View {   // applies duration font style
    func durationFont() -> some View {
        self.modifier(DurationFontModifier())
    }
}

extension Text {
    func nameFont() -> some View {
        self
            .foregroundStyle(.white)
            .font(.system(size: 16, weight: .semibold, design: .rounded))
    }
    func artistFont() -> some View {
        self
            .foregroundStyle(.white)
            .font(.system(size: 14, weight: .light, design: .rounded))
    }
}

struct FontsView: View {
    var body: some View {
        VStack {
            Text("Name Font")
                .nameFont()
            Text("Artist Font")
                .artistFont()
            HStack {
                Text("00:00")
                Spacer()
                Text("03:27")
            }
            .durationFont()
        }
    }
}

#Preview {
    FontsView()
}
