// =====================================================================================================================
//  ParlourSolitaireAppDelegate.h
// =====================================================================================================================


#import <UIKit/UIKit.h>


@class ParlourSolitaireViewController;


@interface ParlourSolitaireAppDelegate : NSObject <UIApplicationDelegate>
{
	UIWindow						*_window;
	ParlourSolitaireViewController	*_viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow							*_window;
@property (nonatomic, retain) IBOutlet ParlourSolitaireViewController	*_viewController;

@end

