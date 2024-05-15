//
//  VideoPicker.swift
//  VideoAnalysisExample
//
//  Created by Arsh Aulakh on 19/07/21.
//

import UIKit
import MobileCoreServices

public protocol VideoPickerDelegate: AnyObject {
    func didSelect(url: URL?)
}

open class VideoPicker: NSObject {
    
    private var alertController: UIAlertController
    private weak var delegate: VideoPickerDelegate?
    private let pickerController = UIImagePickerController()
    private weak var presentationController: UIViewController?
    
    public init(presentationController: UIViewController, delegate: VideoPickerDelegate) {
        self.delegate = delegate
        self.presentationController = presentationController
        self.alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        super.init()
        
        self.pickerController.delegate = self
        self.pickerController.videoQuality = .typeHigh
        self.pickerController.mediaTypes = [kUTTypeMovie, kUTTypeVideo] as [String]
        self.pickerController.sourceType = .savedPhotosAlbum
        
        if let action = self.action(for: .camera, title: "Take video") {
            alertController.addAction(action)
        }
        if let action = self.action(for: .savedPhotosAlbum, title: "Camera roll") {
            alertController.addAction(action)
        }
        if let action = self.action(for: .photoLibrary, title: "Video library") {
            alertController.addAction(action)
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    }
    
    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }
        
        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            self.pickerController.sourceType = type
            self.presentationController?.present(self.pickerController, animated: true)
        }
    }
    
    public func present(from sourceView: UIView) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = CGRect(x: sourceView.bounds.midX, y: sourceView.bounds.midY, width: 0, height: 0)
            alertController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
        }
        
        self.presentationController?.present(alertController, animated: true)
    }
    
    private func pickerController(_ controller: UIImagePickerController, didSelect url: URL?) {
        controller.dismiss(animated: true, completion: nil)
        self.delegate?.didSelect(url: url)
    }
}

extension VideoPicker: UIImagePickerControllerDelegate {
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerController(picker, didSelect: nil)
    }
    
    public func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        /*
        guard let url = info[.mediaURL] as? URL else {
            return self.pickerController(picker, didSelect: nil)
        }
        
        // Uncomment this if you want to save the video file to the media library
        // if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path) {
        //      UISaveVideoAtPathToSavedPhotosAlbum(url.path, self, nil, nil)
        // }
        self.pickerController(picker, didSelect: url)
        */
    }
}

extension VideoPicker: UINavigationControllerDelegate {
}
