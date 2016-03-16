
Pod::Spec.new do |s|

  s.name         = "MLImagePickerController"
  s.version      = "0.1.0"
  s.summary      = "MLImagePickerController Swift written using PhotoKit easy to use multi album Library Based on."

  s.description  = <<-DESC
                   DESC

  s.homepage     = "http://github.com/MakeZL/MLImagePickerController"
  s.screenshots  = "https://github.com/MakeZL/MLImagePickerController/blob/master/DemoSketch/Demo1.png"

  s.license      = "MIT (example)"

  s.author             = { "Leo" => "120886865@qq.com" }
  s.social_media_url   = "http://weibo.com/MakeZL"

  s.platform     = :ios, "8.0"
  s.ios.deployment_target = "8.0"

  s.source       = { :git => "http://github.com/MakeZL/MLImagePickerController.git", :tag => s.version }

  s.source_files  = ["MLImagePickerController/Classes/*.swift"]
  s.resource = "MLImagePickerController/MLImagePickerController.bundle"

  s.requires_arc = true
  s.framework = "Photos"

end
