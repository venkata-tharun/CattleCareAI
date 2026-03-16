import SwiftUI
import TensorFlowLite

class AIPredictionService {
    static let shared = AIPredictionService()
    
    private var interpreter: Interpreter?
    private let modelFilename = "model"
    private let modelExtension = "tflite"
    
    // Constants matching standard TFLite models
    private let batchSize = 1
    private let inputChannels = 3
    private let inputWidth = 224
    private let inputHeight = 224
    
    private init() {
        loadModel()
    }
    
    private func loadModel() {
        guard let modelPath = Bundle.main.path(forResource: modelFilename, ofType: modelExtension) else {
            print("Failed to load model file.")
            return
        }
        
        do {
            interpreter = try Interpreter(modelPath: modelPath)
            try interpreter?.allocateTensors()
        } catch {
            print("Failed to create interpreter: \(error)")
        }
    }
    
    func predict(image: UIImage) async -> DiseasePrediction? {
        guard let interpreter = interpreter else { return nil }
        
        // 1. Preprocess image: Resize & Pixel Data
        guard let pixelBuffer = image.pixelBuffer(width: inputWidth, height: inputHeight) else {
            return nil
        }
        
        do {
            // 2. Copy image data to input tensor
            try interpreter.copy(pixelBuffer, toInputAt: 0)
            
            // 3. Run inference
            try interpreter.invoke()
            
            // 4. Get output tensor
            let outputTensor = try interpreter.output(at: 0)
            // 5. Process results
            let probabilities = [Float32](unsafeData: outputTensor.data) ?? []
            guard let maxIndex = probabilities.enumerated().max(by: { $0.element < $1.element })?.offset else {
                return nil
            }
            
            let confidenceValue = probabilities[maxIndex]
            let confidence = String(format: "%.0f%%", (confidenceValue * 100))
            
            // 6. Cow-only Restriction (Confidence Threshold)
            // If the model is not confident about any of its cattle classes, it's likely not a cow.
            if confidenceValue < 0.4 {
                return DiseasePrediction(
                    diseaseName: "Non-Cattle Detected",
                    confidence: confidence,
                    status: "Warning",
                    symptoms: ["The uploaded image does not appear to be a cow or is too unclear for AI analysis."],
                    precautions: ["Please upload a clear, focused image of the cattle's affected area.", "Ensure proper lighting and avoid background clutter."]
                )
            }
            
            // Map index to disease
            return mapResult(index: maxIndex, confidence: confidence)
            
        } catch {
            print("Inference error: \(error)")
            return nil
        }
    }
    
    private func mapResult(index: Int, confidence: String) -> DiseasePrediction {
        // Model labels: 0 = foot-and-mouth, 1 = healthy, 2 = lumpy
        switch index {
        case 0:
            return DiseasePrediction(
                diseaseName: "Foot and Mouth Disease (FMD)",
                confidence: confidence,
                status: "Critical",
                symptoms: ["Blisters on mouth & hooves", "Lameness", "Fever", "Excessive salivation"],
                precautions: ["Strict isolation", "Report to local authorities", "Do not move animals", "Disinfect premises"]
            )
        case 1:
            return DiseasePrediction(
                diseaseName: "Healthy",
                confidence: confidence,
                status: "Normal",
                symptoms: ["No symptoms detected"],
                precautions: ["Continue regular health checks", "Maintain vaccination schedule"]
            )
        case 2:
            return DiseasePrediction(
                diseaseName: "Lumpy Skin Disease",
                confidence: confidence,
                status: "Critical",
                symptoms: ["High fever", "Nodules on skin", "Reduced milk yield", "Loss of appetite"],
                precautions: ["Isolate the affected animal immediately", "Contact your veterinarian", "Vaccinate healthy cattle in the herd", "Disinfect the shed and equipment"]
            )
        default:
            return DiseasePrediction(
                diseaseName: "Unknown",
                confidence: confidence,
                status: "Unknown",
                symptoms: ["Could not determine symptoms"],
                precautions: ["Contact your veterinarian for manual diagnosis"]
            )
        }
    }
}

// MARK: - Image Helpers
extension UIImage {
    func pixelBuffer(width: Int, height: Int) -> Data? {
        guard self.cgImage != nil else { return nil }
        
        // Simple resizing and pixel data extraction
        // In a real app, use CoreImage or Accelerate for better performance
        let size = CGSize(width: width, height: height)
        UIGraphicsBeginImageContext(size)
        self.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let finalCgImage = resizedImage?.cgImage else { return nil }
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        var rawData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
        
        let context = CGContext(data: &rawData,
                                width: width,
                                height: height,
                                bitsPerComponent: bitsPerComponent,
                                bytesPerRow: bytesPerRow,
                                space: CGColorSpaceCreateDeviceRGB(),
                                bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
        
        context?.draw(finalCgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        // Convert RGBA to Float32 array (standard for many TFLite models)
        var floatData = [Float32]()
        for i in 0..<(width * height) {
            let r = Float32(rawData[i * 4]) / 255.0
            let g = Float32(rawData[i * 4 + 1]) / 255.0
            let b = Float32(rawData[i * 4 + 2]) / 255.0
            floatData.append(r)
            floatData.append(g)
            floatData.append(b)
        }
        
        return Data(copyingBufferOf: floatData)
    }
}

extension Data {
    init<T>(copyingBufferOf array: [T]) {
        self = array.withUnsafeBufferPointer(Data.init)
    }
}

extension Array {
    init?(unsafeData: Data) {
        guard unsafeData.count % MemoryLayout<Element>.stride == 0 else { return nil }
        self = unsafeData.withUnsafeBytes { .init($0.bindMemory(to: Element.self)) }
    }
}
