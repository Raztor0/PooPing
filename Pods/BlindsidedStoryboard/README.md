BlindsidedStoryboard
-----

Storyboards make dependency injection of view controllers challenging, because they insist on instantiating the view controllers internally. This restriction can be worked around by subclassing UIStoryboard and overriding the `-instantiateViewControllerWithIdentifier:` method to perform configuration work immediately following the instantiation. The same storyboard instance that is used to create the initial view controller will be used to instantiate further view controllers accessed via segues.

This repo contains a `BlindsidedStoryboard` subclass of UIStoryboard which exemplifies this technique, integrating with the [Blindside](https://github.com/jbsf/blindside) DI framework. It is a part of a small sample app demonstrating how this could be used.

The BlindsidedStoryboard(CrossStoryboardSegues) category can be included to allow for seamless integration with [Cross Storyboard Segues](https://github.com/pivotal-brian-croom/CrossStoryboardSegues)

## Usage

To run the example project; clone the repo, and run `pod install` from the Example directory first.

## Installation

BlindsidedStoryboard is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "BlindsidedStoryboard"

## Author

Brian Croom, bcroom@pivotallabs.com

## License

BlindsidedStoryboard is available under the MIT license. See the LICENSE file for more info.

