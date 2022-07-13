//
//  MZQRCodeScanController.swift
//  MZQRCode
//
//  Created by 曾龙 on 2022/7/11.
//

import UIKit
import AVKit
import AVFoundation
import MZAuthorization
import PhotosUI

/// 屏幕宽度
let MZ_SCREEN_WIDTH = UIScreen.main.bounds.size.width

/// 屏幕高度
let MZ_SCREEN_HEIGHT = UIScreen.main.bounds.size.height

/// 状态栏高度
let MZ_STATUS_BAR_HEIGHT = UIApplication.shared.statusBarFrame.size.height

/// 底部安全区域高度
let MZ_SAFE_BOTTOM: CGFloat = {
    if #available(iOS 11.0, *) {
        return UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
    }
    return 0
}()

class MZQRCodeScanController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var completionHandler: ((String) -> Void)?
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 20, y: MZ_STATUS_BAR_HEIGHT + 10, width: 50, height: 50)
        button.setImage(UIImage(named: "back", in: .current, compatibleWith: nil), for: .normal)
        button.addTarget(self, action: #selector(back), for: .touchUpInside)
        return button
    }()
    
    private lazy var albumView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: MZ_SCREEN_WIDTH - 20 - 64, y: MZ_SCREEN_HEIGHT - MZ_SAFE_BOTTOM - 20 - 64, width: 64, height: 64))
        imageView.image = UIImage(named: "album", in: .current, compatibleWith: nil)
        imageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(showAlbum))
        imageView.addGestureRecognizer(tap)
        return imageView
    }()
    
    private lazy var line: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 20, y: MZ_STATUS_BAR_HEIGHT + 90, width: MZ_SCREEN_WIDTH - 40, height: 20))
        imageView.contentMode = .scaleToFill
        imageView.image = UIImage.init(named: "scan", in: .current, compatibleWith: nil)
        return imageView
    }()
    
    private var device: AVCaptureDevice?
    private var input: AVCaptureDeviceInput?
    private var output: AVCaptureMetadataOutput?
    private var session: AVCaptureSession?
    private var preview: AVCaptureVideoPreviewLayer?
    private var isScaning: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        
        self.initPreview()
        
        self.view.addSubview(self.backButton)
        self.view.addSubview(self.albumView)
        self.view.addSubview(self.line)
    }
    
    func initPreview() {
        self.device = AVCaptureDevice.default(for: .video)
        try! self.input = AVCaptureDeviceInput.init(device: self.device!)
        self.output = AVCaptureMetadataOutput.init()
        self.output?.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        self.session = AVCaptureSession.init()
        self.session?.sessionPreset = .hd1280x720
        if (self.session!.canAddInput(self.input!)) {
            self.session?.addInput(self.input!)
        }
        if (self.session!.canAddOutput(self.output!)) {
            self.session?.addOutput(self.output!)
        }
        self.output?.metadataObjectTypes = [.qr]
        self.output?.rectOfInterest = CGRect(x: 0, y: 0, width: 1, height: 1)
        
        self.preview = AVCaptureVideoPreviewLayer.init(session: self.session!)
        self.preview?.videoGravity = .resizeAspectFill
        self.preview?.frame = self.view.bounds
        self.view.layer.insertSublayer(self.preview!, at: 0)
    }
    
    //MARK: - AVCaptureMetadataOutputObjectsDelegate
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        DispatchQueue.main.async {
            if !self.isScaning {
                return
            }
            self.stopScan()
            MZAudioPlayTool.vibrate()
            MZAudioPlayTool.playAudio("scan.wav")
            
            if metadataObjects.count == 1 {
                let result = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
                self.dismiss(animated: true) {
                    self.completionHandler?(result.stringValue ?? "")
                }
            } else if (metadataObjects.count > 1) {
                var muchList = [Dictionary<String, Any>]()
                for item in metadataObjects {
                    let result = item as! AVMetadataMachineReadableCodeObject
                    var dic = Dictionary<String, Any>.init()
                    let code = result.stringValue
                    dic["code"] = code
                    
                    let frame = self.makeFrame(objc: result)
                    let frameStr = NSCoder.string(for: frame)
                    dic["frame"] = frameStr
                    muchList.append(dic)
                }
                self.drawMuchList(muchList)
            } else {
                self.startScan()
            }
        }
    }
    
    // 计算按钮位置
    func makeFrame(objc: AVMetadataMachineReadableCodeObject) -> CGRect {
        let isize = CGSize(width: 720.0, height: 1280.0)
        var Wout: CGFloat = 0
        var Hout: CGFloat = 0
        var wMore: Bool = true
        
        let previewSize = self.preview?.bounds.size ?? self.view.bounds.size
        
        if isize.width / isize.height > previewSize.width / previewSize.height {
            wMore = true
            Wout = (isize.width / isize.height) * previewSize.height
            Wout = Wout - previewSize.width
            Wout = Wout / 2
        } else {
            wMore = false
            Hout = (isize.height / isize.width) * previewSize.width
            Hout = Hout - previewSize.height
            Hout = Hout / 2
        }
        
        var point1: CGPoint = CGPoint.zero
        var point2: CGPoint = CGPoint.zero
        var point3: CGPoint = CGPoint.zero
        var point4: CGPoint = CGPoint.zero
        
        let array = objc.corners
        
        // 获取点
        for i in 0..<array.count {
            var point = array[i]
            
            point.x = point.y + point.x
            point.y = point.x - point.y
            point.x = point.x - point.y
            
            point.x = 1 - point.x
            
            if wMore {
                point.x = (point.x * (isize.width / isize.height) * previewSize.height) - Wout
                point.y = previewSize.height * point.y
            } else {
                point.x = previewSize.width * point.x
                point.y = (point.y * (isize.height / isize.width) * previewSize.width) - Hout
            }
            
            if i == 0 {
                point1 = point
            }
            if i == 1 {
                point2 = point
            }
            if i == 2 {
                point3 = point
            }
            if i == 3 {
                point4 = point
            }
        }
        
        let minX = min(point1.x, point2.x, point3.x, point4.x)
        let minY = min(point1.y, point2.y, point3.y, point4.y)
        let maxX = max(point1.x, point2.x, point3.x, point4.x)
        let maxY = max(point1.y, point2.y, point3.y, point4.y)
        
        let qrFrame = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
        return qrFrame
    }
    
    func drawMuchList(_ muchList: [Dictionary<String, Any>]) {
        self.backButton.isHidden = true
        self.line.isHidden = true
        self.albumView.isHidden = true
        
        let maskView = UIView.init(frame: self.view.bounds)
        maskView.backgroundColor = .gray.withAlphaComponent(0.5)
        self.view.addSubview(maskView)
        
        let cancelBtn = UIButton(type: .custom)
        cancelBtn.frame = CGRect(x: 20, y: MZ_STATUS_BAR_HEIGHT + 10, width: 50, height: 50)
        cancelBtn.setTitle("取消", for: .normal)
        cancelBtn.addTarget(self, action: #selector(cancel(sender:)), for: .touchUpInside)
        maskView.addSubview(cancelBtn)
        
        for dic in muchList {
            let button = UIButton(type: .custom)
            button.frame = NSCoder.cgRect(for: dic["frame"] as! String)
            button.setImage(UIImage.init(named: "arrow", in: .current, compatibleWith: nil), for: .normal)
            button.setTitle(dic["code"] as? String, for: .reserved)
            button.addTarget(self, action: #selector(selectQRCode(sender:)), for: .touchUpInside)
            button.layer.add(self.scaleAnimation(), forKey: "basic")
            maskView.addSubview(button)
        }
        
        let tip = UILabel.init(frame: CGRect(x: 0, y: MZ_SCREEN_HEIGHT - MZ_SAFE_BOTTOM - 20 - 30, width: MZ_SCREEN_WIDTH, height: 30))
        tip.text = "轻触小绿点，选择要识别的二维码"
        tip.textColor = .white
        tip.font = .systemFont(ofSize: 16)
        tip.textAlignment = .center
        maskView.addSubview(tip)
    }
    
    // 取消
    @objc func cancel(sender: UIButton) {
        sender.superview?.removeFromSuperview()
        self.backButton.isHidden = false
        self.line.isHidden = false
        self.albumView.isHidden = false
        self.startScan()
    }
    
    // 选择二维码
    @objc func selectQRCode(sender: UIButton) {
        let value = sender.title(for: .reserved)
        self.dismiss(animated: true) {
            self.completionHandler?(value ?? "")
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.startScan()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.stopScan()
    }
    
    @objc func back() {
        self.dismiss(animated: true)
    }
    
    @objc func showAlbum() {
        MZAuthorization.requestAuth(type: .photoReadWrite) {
            if #available(iOS 14, *) {
                var configuration = PHPickerConfiguration()
                configuration.filter = .images
                configuration.selectionLimit = 1
                let picker = PHPickerViewController(configuration: configuration)
                picker.delegate = self
                self.present(picker, animated: true)
            } else {
                let picker = UIImagePickerController()
                picker.sourceType = .photoLibrary
                picker.delegate = self
                self.present(picker, animated: true)
            }
        }
    }
    
    func startScan() {
        self.isScaning = true
        self.preview?.session?.startRunning()
        self.startLineAnimation()
    }
    
    func stopScan() {
        self.isScaning = false
        self.preview?.session?.stopRunning()
        self.stopLineAnimation()
    }
    
    func startLineAnimation() {
        self.stopLineAnimation()
        
        let group = CAAnimationGroup.init()
        let scanAnimation = CABasicAnimation.init(keyPath: "position.y")
        scanAnimation.fromValue = NSNumber.init(value: MZ_STATUS_BAR_HEIGHT + 20)
        scanAnimation.toValue = NSNumber(value: MZ_SCREEN_HEIGHT - MZ_SAFE_BOTTOM - 20 - 64 - 20)
        scanAnimation.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.linear)
        
        let opacityAnimation = CABasicAnimation.init(keyPath: "opacity")
        opacityAnimation.fromValue = 1
        opacityAnimation.toValue = 0
        opacityAnimation.repeatCount = MAXFLOAT
        opacityAnimation.duration = 0.5
        opacityAnimation.beginTime = 2
        
        group.animations = [scanAnimation, opacityAnimation]
        group.isRemovedOnCompletion = false
        group.fillMode = .forwards
        group.duration = 2.5
        group.repeatCount = MAXFLOAT
        
        self.line.layer.add(group, forKey: "basic")
    }
    
    // 小绿点缩放动画
    func scaleAnimation() -> CABasicAnimation {
        let animation = CABasicAnimation.init(keyPath: "transform.scale")
        animation.fromValue = NSNumber.init(value: 1.0)
        animation.toValue = NSNumber.init(value: 0.7)
        animation.autoreverses = true
        animation.duration = 1.0
        animation.repeatCount = MAXFLOAT
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        animation.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeIn)
        return animation
    }
    
    func stopLineAnimation() {
        self.line.layer.removeAllAnimations()
    }
    
    
    //MARK: - PHPickerViewControllerDelegate
    @available(iOS 14, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true) {
            for result in results {
                result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                    if let image = object as? UIImage {
                        DispatchQueue.main.async {
                            MZQRCodeManager.identifyQRCode(image) { content in
                                if let message = content {
                                    self.dismiss(animated: true) {
                                        self.completionHandler?(message)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            if let image = info[.originalImage] as? UIImage {
                DispatchQueue.main.async {
                    MZQRCodeManager.identifyQRCode(image) { content in
                        if let message = content {
                            self.dismiss(animated: true) {
                                self.completionHandler?(message)
                            }
                        }
                    }
                }
            }
        }
    }
}

extension Bundle {
    static let current: Bundle? = {
        guard let resourcePath = Bundle(for: MZQRCodeScanController.self).resourcePath else { return nil }
        return Bundle(path: "\(resourcePath)/MZQRCode.bundle") ?? .main
    }()
}
