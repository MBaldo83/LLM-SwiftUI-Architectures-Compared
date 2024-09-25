import SwiftUI

struct MultiThumbSelectionView: View {
    @Binding var selectedThumb: Recipe.Rating?
    
    var body: some View {
        HStack {
            // Thumbs Up Button
            SingleThumbSelectorView(
                selectedThumb: $selectedThumb,
                thumbType: .thumbsUp,
                selectedColor: .green
            )
            
            // Thumbs Down Button
            SingleThumbSelectorView(
                selectedThumb: $selectedThumb,
                thumbType: .thumbsDown,
                selectedColor: .red
            )
        }
        .padding()
    }
}

struct SingleThumbSelectorView: View {
    @Binding var selectedThumb: Recipe.Rating?
    let thumbType: Recipe.Rating
    let selectedColor: Color
    
    var body: some View {
        Button(action: {
            selectedThumb = selectedThumb == thumbType ? nil : thumbType
        }) {
            Image(systemName: selectedThumb == thumbType ? "\(imageName).fill" : imageName)
                .foregroundColor(selectedThumb == thumbType ? selectedColor : .gray)
                .font(.system(size: 30))
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var imageName: String {
        thumbType == .thumbsUp ? "hand.thumbsup" : "hand.thumbsdown"
    }
}
