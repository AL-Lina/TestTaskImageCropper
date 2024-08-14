import UIKit

final class ImageChangeAreaView: UIView {
    
    var cutoutRect: CGRect = .zero {
        didSet {
            setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = bounds
        
        let mainPath = UIBezierPath(rect: bounds)
        let cutoutPath = UIBezierPath(roundedRect: cutoutRect, cornerRadius: 6)
        
        mainPath.append(cutoutPath.reversing())
        
        shapeLayer.path = mainPath.cgPath
        
        shapeLayer.fillColor = UIColor.white.cgColor
        layer.mask = shapeLayer
        
        // Add border around the cutout area
        let borderLayer = CAShapeLayer()
        borderLayer.path = cutoutPath.cgPath
        borderLayer.strokeColor = UIColor.yellow.cgColor
        borderLayer.lineWidth = 5
        borderLayer.fillColor = UIColor.clear.cgColor
        
        layer.addSublayer(borderLayer)
    }
}
