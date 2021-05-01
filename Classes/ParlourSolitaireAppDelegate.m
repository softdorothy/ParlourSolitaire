// =====================================================================================================================
//  ParlourSolitaireAppDelegate.m
// =====================================================================================================================


#import "ParlourSolitaireAppDelegate.h"
#import "ParlourSolitaireViewController.h"


@implementation ParlourSolitaireAppDelegate
// ========================================================================================= ParlourSolitaireAppDelegate
// ---------------------------------------------------------------------------------------------------------- synthesize

@synthesize _window;
@synthesize _viewController;

// --------------------------------------------------------------------------- application:didFinishLaunchingWithOptions

- (BOOL) application: (UIApplication *) application didFinishLaunchingWithOptions: (NSDictionary *) launchOptions
{        
	// Override point for customization after app launch. 
	[_window addSubview: _viewController.view];
	[_window makeKeyAndVisible];
	
	// Create stacks.
	[_viewController createCardTableLayout];
	
	// Restore card layout.
	[_viewController restoreState];
	
	// Display splash (info) view.
	[_viewController openSplashAfterDelay];
	
	return YES;
}

// --------------------------------------------------------------------------------------- applicationDidEnterBackground

- (void) applicationDidEnterBackground: (UIApplication *) application
{
	// Store away game state.
	[_viewController saveState];
}

// -------------------------------------------------------------------------------------------- applicationWillTerminate

- (void) applicationWillTerminate: (UIApplication *) application
{
	// Store away game state.
	[_viewController saveState];
}

// ---------------------------------------------------------------------------------- applicationDidReceiveMemoryWarning

- (void) applicationDidReceiveMemoryWarning: (UIApplication *) application
{
	printf ("applicationDidReceiveMemoryWarning\n");
}

// ------------------------------------------------------------------------------------------------------------- dealloc

- (void) dealloc
{
	[_viewController release];
	[_window release];
	[super dealloc];
}

@end
