Pod::Spec.new do |s|

  s.name          = "GUITabPagerViewController"
  s.version       = "0.1.3"
  s.summary       = "GUITabPagerViewController is a simple paged view controller with tabs."
  s.homepage      = "https://github.com/guilhermearaujo/GUITabPagerViewController"
  s.license       = { :type => "MIT", :file => "LICENSE" }
  s.author        = { "Guilherme Araújo" => "guilhermeama@gmail.com" }
  s.platform      = :ios, "8.0"
  s.source        = { :git => "https://github.com/guilhermearaujo/GUITabPagerViewController.git", :tag => "0.1.3" }
  s.source_files  = "GUITabPagerViewController/Classes", "GUITabPagerViewController/Classes/**/*.{h,m}"
  s.requires_arc  = true

end
