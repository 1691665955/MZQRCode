# MZQRCode
Swift二维码识别、生成、扫描、相册选择，使用简单，包含多码识别功能。

<div align=center>
<img src="1.gif" width="300px" />
</div>

#### Cocoapods 引入
```
pod 'MZQRCode', '~> 0.0.3'
```

#### 使用

- 扫码识别二维码
```
MZQRCodeManager.scanQRCode { value in
    print("扫码结果为:\(value)")
}
```

- 生成二维码
```
MZQRCodeManager.createQRCode(content: "zzz", size: 200.0, backgroundColor: .white, fillColor: .brown, logo: UIImage.init(named: "avatar")) { image in
    imageView.image = image
}
```

- 识别图片中二维码
```
MZQRCodeManager.identifyQRCode(imageView.image!) { content in
    print("识别结果为:\(content ?? "Null")")
}
```
