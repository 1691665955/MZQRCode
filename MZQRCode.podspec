Pod::Spec.new do |spec|
  spec.name         = "MZQRCode"
  spec.version      = "0.0.3"
  spec.summary      = "Swift二维码识别、生成、扫描、相册选择"
  spec.homepage     = "https://github.com/1691665955/MZQRCode"
  spec.authors         = { 'MZ' => '1691665955@qq.com' }
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.source = { :git => "https://github.com/1691665955/MZQRCode.git", :tag => spec.version}
  spec.platform     = :ios, "9.0"
  spec.swift_version = '5.0'
  spec.source_files  = "MZQRCode/MZQRCode/*"
  spec.resource_bundles = {
    'MZQRCode' => ['MZQRCode/MZQRCode/Resources/*']
  }
  spec.dependency 'MZAuthorization'
end
