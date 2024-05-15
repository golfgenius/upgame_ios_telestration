//
//  ViewController.swift
//  UpgameVideoFramework
//
//  Created by ArshAulakh59 on 03/31/2023.
//  Copyright (c) 2023 ArshAulakh59. All rights reserved.
//

import UIKit
import AVKit
import UpgameVideoFramework

let client = "upgame"

class ViewController: UIViewController {
    
    var picker: VideoPicker! = nil
    var analysisController: VideoAnalysisController!
    var pickerCompletionBlock: ((VideoAnalysisController.Object) -> ())? = nil
    
    lazy var configuration: VideoAnalysisConfiguration = {
        let theme = Theme(
            primaryColor: .random(),
            secondaryColor: .black,
            buttonsTintColor: .white,
            translucentViewsOpacity: 0.75
        )
        let iconsConfiguration = VideoAnalysisIconsConfiguration(
            closeButtonIcon: UIImage(systemName: "xmark"),
            recordButtonIcon: UIImage(systemName: "record.circle.fill"),
            syncLockButtonIcon: UIImage(systemName: "exclamationmark.arrow.triangle.2.circlepath"),
            comparisonButtonIcon: UIImage(named: "Compare"),
            syncUnlockButtonIcon: UIImage(systemName: "arrow.triangle.2.circlepath"),
            stopRecordingButtonIcon: UIImage(systemName: "stop.circle.fill")
        )
        let configuration = VideoAnalysisConfiguration(
            enableTimeBasedDrawings: true,
            defaultScrubbingDirection: true,
            iconsConfiguration: iconsConfiguration,
            themeConfiguration: theme,
            delegate: self
        )
        return configuration
    }()
    
    let videoUrls = [
        URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!,
        URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4")!,
        URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!,
        URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!,
        URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4")!,
        URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4")!,
        URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4")!,
        URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4")!,
        URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4")!,
        URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4")!,
        URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/VolkswagenGTIReview.mp4")!,
        URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4")!,
        URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WhatCarCanYouGetForAGrand.mp4")!
    ]
}

extension ViewController {
    
    @IBAction func initializeModule(_ sender: UIButton) {
        analysisController = VideoAnalysisController(configuration: configuration)
        analysisController.present(in: self)
    }
    
    @IBAction func initializeModuleWithMedia(_ sender: UIButton) {
        guard let view = view else { return }
        #if DEBUG
        didSelect(url: videoUrls.randomElement() ?? videoUrls[0])
        #else
        picker = VideoPicker(presentationController: self, delegate: self)
        picker.present(from: view)
        #endif
    }
}

extension ViewController: VideoPickerDelegate {
    
    func didSelect(url: URL?) {
        var urll = url
        #if DEBUG
        urll = videoUrls.randomElement() ?? videoUrls[0]
        #endif
        
        let videoUrls: [URL] = Array(repeating: urll, count: 1).compactMap({ $0 })
        
        guard pickerCompletionBlock != nil, let first = videoUrls.first else {

            guard pickerCompletionBlock != nil else {
                let media = videoUrls.map({ VideoAnalysisController.Object(url: $0) })
                analysisController = VideoAnalysisController(media: media, configuration: configuration)
                analysisController.present(in: self)
                
                return
            }
            
            pickerCompletionBlock = nil
            
            return
        }
        
        let medium = VideoAnalysisController.Object(url: first)
        pickerCompletionBlock?(medium)
        pickerCompletionBlock = nil
    }
}

extension ViewController: VideoAnalysisControllerDelegate {
    
    // MARK: Video analysis controller delegate methods
    
    var preferredOrientation: UIDeviceOrientation {
        return [.portrait, .landscapeLeft].randomElement() ?? .portrait
    }
    
    /**
     NOTE: Format of this out is as follows.
     1. First value will contain the final analysed video. THE STACK VALUE HERE WILL ALWAYS BE EMPTY.
     2. Values at subsequent indices will contain the videos being analysed along with their stacks.
     */
    func videoAnalysisDidFinish(output: [VideoAnalysisController.Object]?) {
        self.analysisController.dismiss(animated: true) { [self] in
            guard let output = output, !output.isEmpty else {
                self.analysisController = nil
                return
            }
            
            /// To get the final video with audio/video recording
            if let url = output.first?.url {
                let player = AVPlayer(url: url)
                let controller = AVPlayerViewController()
                controller.player = player
                self.present(controller, animated: true) { player.play() }
            }
            
            self.analysisController = nil
        }
    }
    
    func videoAnalysisController(
        _ controller: UIViewController,
        didRequestMediaForItemAtIndex index: Int,
        completion: @escaping (VideoAnalysisController.Object) -> ()
    ) {
        #if DEBUG
        let object = VideoAnalysisController.Object(url: videoUrls.randomElement() ?? videoUrls[0])
        completion(object)
        #else
        guard let view = controller.view  else { return }
        picker = VideoPicker(presentationController: controller, delegate: self)
        pickerCompletionBlock = completion
        picker.present(from: view)
        #endif
    }
    
    func videoAnalysisControllerDidRequestDiscardAndClose(
        in controller: UIViewController,
        completion: @escaping () -> ()
    ) {
        let confirmation = UIAlertController(
            title: "Discard changes",
            message: "You are about to discard your changes and exit out of video analysis section. Are you sure you want to continue?",
            preferredStyle: .alert
        )
        let yesAction = UIAlertAction(title: "Discard and exit", style: .destructive, handler: { _ in completion() })
        confirmation.addAction(yesAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { _ in })
        confirmation.addAction(cancelAction)
        
        controller.present(confirmation, animated: true, completion: nil)
    }
    
    func videoAnalysisControllerDidRequestToDeleteMedia(
        in controller: UIViewController,
        completion: @escaping () -> ()
    ) {
        let confirmation = UIAlertController(
            title: "Delete media",
            message: "You are about to delete this media. All drawings done on the media will be lost. Are you sure you want to continue?",
            preferredStyle: .alert
        )
        let yesAction = UIAlertAction(title: "Delete", style: .destructive, handler: { _ in completion() })
        confirmation.addAction(yesAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { _ in })
        confirmation.addAction(cancelAction)
        
        controller.present(confirmation, animated: true, completion: nil)
    }
}

extension CGFloat {
    
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    
    static func random() -> UIColor {
        return UIColor(
            red:   .random(),
            green: .random(),
            blue:  .random(),
            alpha: 1.0
        )
    }
}
