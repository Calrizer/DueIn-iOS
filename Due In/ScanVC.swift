//
//  ScanVC.swift
//  Due In
//
//  Created by Callum Drain on 14/12/2016.
//  Copyright © 2016 Due In. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox

class ScanVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    struct Task {
        var id : String
        var title : String
        var description : String
        var set : String
        var due : String
        var owner : String
    }
    
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var bottomBar: UIView!
    @IBOutlet var topBar: UIView!
    @IBOutlet var closeImg: UIImageView!
    @IBOutlet var imgFlash: UIImageView!
    @IBOutlet var lblFlash: UILabel!
    
    var taskID : String!
    public var scanned : Bool = false
    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    
    let supportedCodeTypes = [AVMetadataObjectTypeUPCECode,
                              AVMetadataObjectTypeCode39Code,
                              AVMetadataObjectTypeCode39Mod43Code,
                              AVMetadataObjectTypeCode93Code,
                              AVMetadataObjectTypeCode128Code,
                              AVMetadataObjectTypeEAN8Code,
                              AVMetadataObjectTypeEAN13Code,
                              AVMetadataObjectTypeAztecCode,
                              AVMetadataObjectTypePDF417Code,
                              AVMetadataObjectTypeQRCode]
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video as the media type parameter.
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            
            // Set the input device on the capture session.
            captureSession?.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            // Start video capture.
            captureSession?.startRunning()
            
            self.view.bringSubview(toFront: bottomBar)
            self.view.bringSubview(toFront: topBar)
            
            // Initialize QR Code Frame to highlight the QR code
            qrCodeFrameView = UIView()
            
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.red.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubview(toFront: qrCodeFrameView)
            }
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        
        var tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(closeScanner))
        closeImg.isUserInteractionEnabled = true
        closeImg.addGestureRecognizer(tapGestureRecognizer)
        
        tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(toggleFlash))
        imgFlash.isUserInteractionEnabled = true
        imgFlash.addGestureRecognizer(tapGestureRecognizer)
        lblFlash.isUserInteractionEnabled = true
        lblFlash.addGestureRecognizer(tapGestureRecognizer)
        
        lblFlash.tag = 0
        
        statusLabel.text = "Scan a task to add it."
        
        let swipedown = UISwipeGestureRecognizer(target: self, action: #selector(closeScanner))
        swipedown.direction = UISwipeGestureRecognizerDirection.down

        self.view.addGestureRecognizer(swipedown)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print(scanned)
        if scanned == true {
            scanned = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func closeScanner() {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func toggleFlash(){
        
        guard let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) else { return }
        
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                
                if lblFlash.tag == 0 {
                    lblFlash.tag = 1
                    lblFlash.text = "On"
                    device.torchMode = .on
                    
                }else{
                    lblFlash.tag = 0
                    lblFlash.text = "Off"
                    device.torchMode = .off
                }
                
                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate Methods
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            
            statusLabel.text = "Scan a task to add it."
            
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                
                if metadataObj.stringValue.range(of: "http://www.duein.net/task/") != nil {
                    
                    if scanned == false {
                        
                        let contents = metadataObj.stringValue!
                        
                        let start = contents.index(contents.startIndex, offsetBy: 26)
                        let end = contents.index(contents.endIndex, offsetBy: -1)
                        let range = start..<end
                        
                        taskID = contents.substring(with: range)
                        
                        let user = UserDefaults.standard.dictionary(forKey: "authUser")
                        
                        let due = user?["due"] as! String
                        
                        let tasks = due.characters.split{$0 == "."}.map(String.init)
                        
                        if tasks.contains(taskID) {
                            
                            bottomBar.isHidden = false
                            statusLabel.text = "You already have this task."
                            
                        }else{
                        
                            scanned = true
                            print(taskID)
                            performSegue(withIdentifier: "sendTask", sender: taskID)
                        
                        }
                        
                    }
                    
                }else{
                    
                    statusLabel.text = "This is not a Due In code."
                    
                }
            }
        }
    }
    
    var player: AVAudioPlayer?
    
    func playSound() {
        let url = Bundle.main.url(forResource: "beep", withExtension: "mp3")!
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            
            player.prepareToPlay()
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "sendTask" {
            
            if let destination = segue.destination as? AddVC {
                
                print("test")
                destination.taskID = sender as! String
                
            }
        }
    }
}

