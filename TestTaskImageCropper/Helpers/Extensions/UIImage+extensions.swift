import UIKit
import CoreImage

extension UIImage {
    func addFilter(filter : FilterType) -> UIImage {
        let filter = CIFilter(name: filter.rawValue)
        let ciInput = CIImage(image: self)
        filter?.setValue(ciInput, forKey: "inputImage")
        let ciOutput = filter?.outputImage
        let ciContext = CIContext()
        let cgImage = ciContext.createCGImage(ciOutput!, from: (ciOutput?.extent)!)
        return UIImage(cgImage: cgImage!)
    }
    
    func cropImage(toRect cropRect: CGRect, imageViewWidth: CGFloat, imageViewHeight: CGFloat) -> UIImage? {
        let inputImage = self
        let imageViewScale = max(inputImage.size.width / imageViewWidth, inputImage.size.height / imageViewHeight)
        
        let cropeZone = CGRect(x: cropRect.origin.x * imageViewScale,
                               y: cropRect.origin.y * imageViewScale,
                               width: cropRect.size.width * imageViewScale,
                               height: cropRect.size.height * imageViewScale)
        
        guard let cutImageRef: CGImage = inputImage.cgImage?.cropping(to: cropeZone) else { return nil }
        
        let croppedImage: UIImage = UIImage(cgImage: cutImageRef)
        return croppedImage
    }
    
}
