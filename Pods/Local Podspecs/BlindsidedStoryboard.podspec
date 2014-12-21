Pod::Spec.new do |s|
  s.name             = "BlindsidedStoryboard"
  s.version          = '0.1.0'
  s.summary          = "Sublcasses UIStoryboard to inject Blindside dependencies."
  s.description      = <<-DESC
                       Storyboards make dependency injection of view controllers challenging, because they insist on instantiating the view controllers internally. This restriction can be worked around by subclassing UIStoryboard and overriding the `-instantiateViewControllerWithIdentifier:` method to perform configuration work immediately following the instantiation. The same storyboard instance that is used to create the initial view controller will be used to instantiate further view controllers accessed via segues.

                       This repo contains a `BlindsidedStoryboard` subclass of UIStoryboard which exemplifies this technique, integrating with the [Blindside](https://github.com/jbsf/blindside) DI framework. It is a part of a small sample app demonstrating how this could be used.

                       The BlindsidedStoryboard(CrossStoryboardSegues) category can be included to allow for seamless integration with [Cross Storyboard Segues](https://github.com/pivotal-brian-croom/CrossStoryboardSegues)
                       DESC
  s.homepage         = "https://github.com/pivotal-brian-croom/BlindsidedStoryboard"
  s.license          = 'MIT'
  s.author           = { "Brian Croom" => "bcroom@pivotallabs.com" }
  s.source           = { :git => "https://github.com/Raztor0/BlindsidedStoryboard.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.ios.deployment_target = '7.0'
  s.requires_arc = true

  s.source_files = 'Classes/*.{h,m}'
  s.public_header_files = 'Classes/**/*.h'
end
