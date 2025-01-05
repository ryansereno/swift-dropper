import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var selectedImage: UIImage?
    @State private var isImagePickerShown = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 20) {
                    if let image = selectedImage {
                        ZoomableImageView(image: image)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        Text("No image selected")
                            .foregroundColor(.gray)
                        Button("Select Image") {
                            isImagePickerShown = true
                        }
                        .padding()
                        .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
            }
            .toolbar {
                // Show menu only when an image is selected
                if selectedImage != nil {
                    Menu {
                        Button(role: .destructive) {
                            selectedImage = nil
                        } label: {
                            Label("Remove Photo", systemImage: "trash")
                        }
                    } label: {
                        Label("Options", systemImage: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $isImagePickerShown) {
                ImagePicker(selectedImage: $selectedImage)
            }
        }
    }
}

struct ColorBubble: View {
    let color: Color
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 60, height: 60)
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 2)
            )
            .shadow(radius: 3)
    }
}

struct ZoomableImageView: View {
    let image: UIImage
    
    @State private var scale: CGFloat = 1.0
    @State private var currentColor: Color = .clear
    @State private var touchLocation: CGPoint = .zero
    @State private var isColorPickerActive = false
    @State private var paintMixer = PaintMixerWrapper()
    @State private var currentMix: [PaintMix] = []
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                ZStack {
                    // Center the image, maintain aspect ratio
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .scaleEffect(scale)
                        // Gesture to pick color
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    touchLocation = value.location
                                    updateColor(at: value.location, in: geometry)
                                    isColorPickerActive = true
                                }
                                .onEnded { _ in
                                    isColorPickerActive = false
                                }
                        )
                        // Double tap to zoom
                        .onTapGesture(count: 2) {
                            withAnimation {
                                scale = scale > 1 ? 1 : 2
                            }
                        }
                    
                    // Show color bubble if active
                    if isColorPickerActive {
                        ColorBubble(color: currentColor)
                            .position(touchLocation)
                            .offset(y: -60)
                    }
                }
            }
            
            // Display paint mixing ratios
            VStack(alignment: .leading, spacing: 8) {
                if !currentMix.isEmpty {
                    Text("Paint Mixing Ratios:")
                        .font(.headline)
                        .padding(.top)
                    
                    ForEach(currentMix, id: \.paintName) { mix in
                        HStack {
                            Text(mix.paintName)
                            Spacer()
                            Text("\(Int(mix.ratio * 100))%")
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(0.9))
            .padding()
        }
    }
    
    private func updateColor(at point: CGPoint, in geometry: GeometryProxy) {
        // The displayed image's size (preserving aspect ratio)
        let displayedWidth = geometry.size.width
        let nativeAspectRatio = image.size.height / image.size.width
        let displayedHeight = displayedWidth * nativeAspectRatio
        
        let xOffset = (geometry.size.width - displayedWidth) / 2
        let yOffset = (geometry.size.height - displayedHeight) / 2
        
        let relativeX = (point.x - xOffset) / displayedWidth
        let relativeY = (point.y - yOffset) / displayedHeight
        
        if relativeX >= 0, relativeX < 1, relativeY >= 0, relativeY < 1 {
            let pixelX = relativeX * CGFloat(image.cgImage!.width)
            let pixelY = relativeY * CGFloat(image.cgImage!.height)
            if let uiColor = image.pixelColor(at: CGPoint(x: pixelX, y: pixelY)) {
                currentColor = Color(uiColor)
                currentMix = paintMixer.getMixForColor(uiColor)
            }
        }
    }
}

// UIImage extension for pixel color
extension UIImage {
    func pixelColor(at point: CGPoint) -> UIColor? {
        guard let cgImage = self.cgImage,
              let dataProvider = cgImage.dataProvider else { return nil }
        
        let pixelData = dataProvider.data
        guard let data = CFDataGetBytePtr(pixelData) else { return nil }
        
        let scale = self.scale
        let pixelPoint = CGPoint(x: point.x * scale, y: point.y * scale)
        
        // ensure the point is in the valid range
        guard pixelPoint.x >= 0, pixelPoint.x < CGFloat(cgImage.width),
              pixelPoint.y >= 0, pixelPoint.y < CGFloat(cgImage.height) else { return nil }
        
        let pixelInfo = ((Int(cgImage.width) * Int(pixelPoint.y)) + Int(pixelPoint.x)) * 4
        
        let r = CGFloat(data[pixelInfo]) / 255.0
        let g = CGFloat(data[pixelInfo + 1]) / 255.0
        let b = CGFloat(data[pixelInfo + 2]) / 255.0
        let a = CGFloat(data[pixelInfo + 3]) / 255.0
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}

// ImagePicker for selecting images
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.selectedImage = image as? UIImage
                    }
                }
            }
        }
    }
}
#Preview {
    ContentView()
}
