//
//  MZQRCodeIndentifyController.swift
//  MZQRCode
//
//  Created by 曾龙 on 2022/7/12.
//

import UIKit

class MZQRCodeIndentifyController: UIViewController {
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: self.view.bounds)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    var qrCodeImage: UIImage?
    var features: [CIQRCodeFeature]?
    var completionHandler: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        
        self.view.addSubview(self.imageView)
        self.imageView.image = qrCodeImage
        self.drawFeatures(features!)
    }
    
    func drawFeatures(_ features: [CIQRCodeFeature]) {
        
        let maskView = UIView.init(frame: self.view.bounds)
        maskView.backgroundColor = .gray.withAlphaComponent(0.5)
        self.view.addSubview(maskView)
        
        let cancelBtn = UIButton(type: .custom)
        cancelBtn.frame = CGRect(x: 10, y: MZ_STATUS_BAR_HEIGHT, width: 90, height: 50)
        cancelBtn.setTitle("Cancel".localized(), for: .normal)
        cancelBtn.addTarget(self, action: #selector(cancel(sender:)), for: .touchUpInside)
        cancelBtn.contentHorizontalAlignment = .left
        maskView.addSubview(cancelBtn)
        
        for feature in features {
            let button = UIButton(type: .custom)
            button.frame = self.makeFrame(feature: feature)
            button.setImage(UIImage.init(named: "arrow", in: .qrBundle, compatibleWith: nil), for: .normal)
            button.setTitle(feature.messageString, for: .reserved)
            button.addTarget(self, action: #selector(selectQRCode(sender:)), for: .touchUpInside)
            button.layer.add(self.scaleAnimation(), forKey: "basic")
            maskView.addSubview(button)
        }
        
        let tip = UILabel.init(frame: CGRect(x: 0, y: MZ_SCREEN_HEIGHT - MZ_SAFE_BOTTOM - 20 - 50, width: MZ_SCREEN_WIDTH, height: 50))
        tip.text = "Tip".localized()
        tip.textColor = .white
        tip.font = .systemFont(ofSize: 16)
        tip.textAlignment = .center
        tip.adjustsFontSizeToFitWidth = true
        tip.numberOfLines = 0
        maskView.addSubview(tip)
    }
    
    // 获取二维码在整个界面中的位置
    func makeFrame(feature: CIQRCodeFeature) -> CGRect {
        let startImageSize = self.getSize(self.qrCodeImage!)
        var fixelW: CGFloat = startImageSize.width
        var fixelH: CGFloat = startImageSize.height
        var topSpace = 0.0
        var leftSpace = 0.0
        let viewSize = self.view.bounds.size
        if fixelH / fixelW > viewSize.height / viewSize.width {
            fixelW = (fixelW / fixelH) * viewSize.height
            fixelH = viewSize.height
            leftSpace = (MZ_SCREEN_WIDTH - fixelW) / 2
        } else {
            fixelH = (fixelH / fixelW) * viewSize.width
            fixelW = viewSize.width
            topSpace = (MZ_SCREEN_HEIGHT - fixelH) / 2
        }
        let scale = fixelW / startImageSize.width
        
        var btnFrame = feature.bounds
        
        btnFrame = self.exchangeFrame(frame: btnFrame, image: self.qrCodeImage!)
        
        btnFrame = CGRect(x: btnFrame.origin.x * scale + leftSpace, y: btnFrame.origin.y * scale + topSpace, width: btnFrame.width * scale, height: btnFrame.height * scale)
        
        return btnFrame
    }
    
    // 获取图片尺寸
    func getSize(_ image: UIImage) -> CGSize {
        var fixelW = CGFloat(image.cgImage?.width ?? 0)
        var fixelH = CGFloat(image.cgImage?.height ?? 0)
        
        if image.imageOrientation == .left || image.imageOrientation == .right || image.imageOrientation == .leftMirrored || image.imageOrientation == .rightMirrored {
            fixelW = CGFloat(image.cgImage?.height ?? 0)
            fixelH = CGFloat(image.cgImage?.width ?? 0)
        }
        return CGSize(width: fixelW, height: fixelH)
    }
    
    // 获取二维码照片在图片中的位置
    func exchangeFrame(frame: CGRect, image: UIImage) -> CGRect {
        var newFrame = frame
        
        let fixelW: CGFloat = CGFloat(image.cgImage?.width ?? 0)
        let fixelH: CGFloat = CGFloat(image.cgImage?.height ?? 0)
        
        let x = frame.origin.x
        let y = frame.origin.y
        let w = frame.width
        let h = frame.height
        
        if image.imageOrientation == .up {
            newFrame.origin.y = fixelH - y - h
        } else if image.imageOrientation == .left {
            newFrame.origin.x = fixelH - y - h;
            newFrame.origin.y = fixelW - x - w;
        } else if image.imageOrientation == .right {
            newFrame.origin.x = y;
            newFrame.origin.y = x;
        } else if image.imageOrientation == .down {
            newFrame.origin.x = fixelW - x - w;
            newFrame.origin.y = y;
        } else if image.imageOrientation == .upMirrored {
            newFrame.origin.x = fixelW - x - w;
            newFrame.origin.y = fixelH - y - h;
        } else if image.imageOrientation == .downMirrored {
            newFrame.origin.y = y;
            newFrame.origin.x = x;
        } else if image.imageOrientation == .rightMirrored {
            newFrame.origin.x = fixelH - y - h;
            newFrame.origin.y = x;
        } else if image.imageOrientation == .leftMirrored {
            newFrame.origin.x = y;
            newFrame.origin.y = fixelW - x - w;
        }
        return newFrame
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
    
    // 取消
    @objc func cancel(sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    // 选择二维码
    @objc func selectQRCode(sender: UIButton) {
        let value = sender.title(for: .reserved)
        self.dismiss(animated: true) {
            self.completionHandler?(value ?? "")
        }
    }
    
}
