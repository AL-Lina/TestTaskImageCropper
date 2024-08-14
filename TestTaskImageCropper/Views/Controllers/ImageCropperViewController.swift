import UIKit
import CoreImage

final class ImageCropperViewController: UIViewController {
    
    // MARK: List of views
    private var segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["Org", "B & W"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.selectedSegmentTintColor = .systemBlue
        return segmentedControl
    }()
    
    private var addImageButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("+", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 34)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        return button
    }()
    
    private var saveImageButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setImage(UIImage(named: "disk"), for: .normal)
        return button
    }()
    
    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var originalSelectedImage: UIImage?
    private var imageChangeAreaView: ImageChangeAreaView?
    private var changeAreaControllerView: UIView!
    
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: segmentedControl)
        segmentedControl.addTarget(self, action: #selector(chooseFilter), for: .valueChanged)
        setUpNavigationBar()
        addImagesButton()
    }
    
    
    // MARK: - Private
    private func setUpNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveImageButton)
        saveImageButton.addTarget(self, action: #selector(savePhoto), for: .touchUpInside)
    }
    
    
    private func addImagesButton() {
        view.addSubview(addImageButton)
        NSLayoutConstraint.activate([
            addImageButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            addImageButton.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            addImageButton.widthAnchor.constraint(equalToConstant: 70),
            addImageButton.heightAnchor.constraint(equalToConstant: 70)])
        
        addImageButton.addTarget(self, action: #selector(showPickerAlert), for: .primaryActionTriggered)
    }
    
    private func deleteAddImageButton() {
        addImageButton.removeFromSuperview()
    }
    
    private func addImageView(with image: UIImage) {
        view.addSubview(imageView)
        imageView.clipsToBounds = true
        imageView.frame = CGRect(
            x: (view.frame.width - image.size.width) / 2,
            y: (view.frame.height - image.size.height) / 2,
            width: image.size.width,
            height: image.size.height
        )
        
        imageView.image = image
        originalSelectedImage = image
        
        resizeImageViewToImageSize()
        addImageChangeAreaView()
        addChangeAreaControllerView()
        
    }
    
    @objc private func chooseFilter() {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            imageView.image = originalSelectedImage
        case 1:
            imageView.image = originalSelectedImage?.addFilter(filter: .Mono)
        default:
            break
        }
    }
    
    
    private func resizeImageViewToImageSize() {
        guard let image = imageView.image else { return }
        
        let imageSize = image.size
        
        imageView.frame.size = imageSize
        
        imageView.center = view.center
    }
    
    private func getChangeAreaParams() -> CGRect {
        let width: CGFloat = view.frame.width * 0.75
        let height: CGFloat = view.frame.height * 0.65
        
        let x: CGFloat = (view.frame.width - width) / 2
        let y: CGFloat = (view.frame.height - height) / 2
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    private func addImageChangeAreaView() {
        imageChangeAreaView = ImageChangeAreaView()
        guard let imageChangeAreaView else { return }
        imageChangeAreaView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        
        imageChangeAreaView.backgroundColor = .white
        imageChangeAreaView.alpha = 0.7
        
        imageChangeAreaView.cutoutRect = getChangeAreaParams()
        view.addSubview(imageChangeAreaView)
    }
    
    private func addChangeAreaControllerView() {
        changeAreaControllerView = UIView(frame: getChangeAreaParams())
        guard let changeAreaControllerView else { return }
        changeAreaControllerView.backgroundColor = .clear
        view.addSubview(changeAreaControllerView)
        setupChangeAreaControllerMethods()
    }
    
    private func setupChangeAreaControllerMethods() {
        guard let changeAreaControllerView else { return }
        
        changeAreaControllerView.isUserInteractionEnabled = true
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(imagePanGesture(_:)))
        changeAreaControllerView.addGestureRecognizer(panGesture)
        
        // TODO: To be continied...
        //        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(imageRotationGesture(_:)))
        //        changeAreaControllerView.addGestureRecognizer(rotationGesture)
        
        let resizeGesture = UIPinchGestureRecognizer(target: self, action: #selector(imageResizeGesture(_:)))
        changeAreaControllerView.addGestureRecognizer(resizeGesture)
    }
    
    
    private func showPicker(source: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = source
        present(imagePicker, animated: true)
    }
    
    @objc private func showPickerAlert() {
        let alert = UIAlertController(title: "Photo source", message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            self.showPicker(source: .camera)
        }
        
        let libraryAction = UIAlertAction(title: "Photo library", style: .default) { _ in
            self.showPicker(source: .photoLibrary)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(cameraAction)
        alert.addAction(libraryAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    @objc private func imageRotationGesture(_ gesture: UIRotationGestureRecognizer) {
        guard gesture.numberOfTouches == 2 else { return }
        
        switch gesture.state {
            
        case.changed:
            imageView.transform = imageView.transform.rotated(by: gesture.rotation)
            
            gesture.rotation = 0
            
            // TODO: isImageViewOutOfBounds
        default:
            break
        }
    }
    
    @objc private func imagePanGesture(_ gesture: UIPanGestureRecognizer) {
        
        switch gesture.state {
            
        case .changed:
            let translation = gesture.translation(in: view)
            
            imageView.transform = imageView.transform.translatedBy(x: translation.x, y: translation.y)
            
            if isImageViewOutOfBounds() {
                imageView.transform = imageView.transform.translatedBy(x: -translation.x, y: -translation.y)
            }
            
            gesture.setTranslation(.zero, in: view)
            
        default:
            break
        }
    }
    
    @objc private func imageResizeGesture(_ gesture: UIPinchGestureRecognizer) {
        guard gesture.numberOfTouches == 2 else { return }
        
        switch gesture.state {
            
        case .changed:
            let originalTransform = imageView.transform
            
            imageView.transform = imageView.transform.scaledBy(x: gesture.scale, y: gesture.scale)
            
            if isImageViewOutOfBounds() {
                imageView.transform = originalTransform
            }
            
            gesture.scale = 1.0
            
        default:
            break
        }
    }
    
    private func isImageViewOutOfBounds() -> Bool {
        
        let area = getChangeAreaParams()
        
        if imageView.frame.width < area.width || imageView.frame.height < area.height {
            return true
        }
        
        if imageView.frame.width > area.width || imageView.frame.height > area.height {
            
            if imageView.frame.minX > area.origin.x {
                imageView.frame.origin.x = area.origin.x
            }
            
            if imageView.frame.maxX < view.bounds.width - area.origin.x {
                imageView.frame.origin.x = view.bounds.width - imageView.frame.width - area.origin.x
            }
            
            if imageView.frame.minY > area.origin.y {
                imageView.frame.origin.y = area.origin.y
            }
            
            if imageView.frame.maxY < view.bounds.height - area.origin.y {
                imageView.frame.origin.y = view.bounds.height - imageView.frame.height - area.origin.y
            }
            
            return false
        }
        
        return false
    }
    
    
    @objc private func savePhoto() {
        guard let imageToCrop = imageView.image else { return }
        
        let cropRect = CGRect(x: abs(imageView.frame.origin.x - changeAreaControllerView.frame.origin.x),
                              y: abs(imageView.frame.origin.y - changeAreaControllerView.frame.origin.y),
                              width: changeAreaControllerView.frame.width,
                              height: changeAreaControllerView.frame.height)
        saveImage(image: imageToCrop, cropRect: cropRect)
    }
    
    private func saveImage(image: UIImage, cropRect: CGRect) {
        if let cropImage = cropImage(image: image, cropRect: cropRect) {
            UIImageWriteToSavedPhotosAlbum(cropImage, self, #selector(self.forImage(_:didFinishSavingWithError:contextInfo:)), nil)
        } else {
            showAlert(title: "Error", message: "Image can not been cropped")
        }
    }
    
    private func cropImage(image: UIImage, cropRect: CGRect) -> UIImage? {
        if let croppedImage = image.cropImage(toRect: cropRect, imageViewWidth: imageView.frame.width, imageViewHeight: imageView.frame.height) {
            return croppedImage
        }
        return nil
    }
    
    @objc private func forImage(_ image: UIImage, didFinishSavingWithError err: Error?, contextInfo: UnsafeRawPointer) {
        if let err = err {
            showAlert(title: "Error", message: err.localizedDescription)
        } else {
            showAlert(title: "Saved", message: "Image saved successfully")
        }
    }
}


// MARK: - Extensions
extension ImageCropperViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            deleteAddImageButton()
            addImageView(with: image)
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension ImageCropperViewController {
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}

