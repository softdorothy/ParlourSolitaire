// =====================================================================================================================
//  Parlour Solitaire
//  Copyright 2011 Soft Dorothy LLC. All rights reserved.
// =====================================================================================================================


#import <UIKit/UIKit.h>


int main (int argc, char *argv[])
{    
    NSAutoreleasePool	*pool;
	int					retVal;
	
	pool = [[NSAutoreleasePool alloc] init];
    retVal = UIApplicationMain (argc, argv, nil, nil);
    [pool release];
	
    return retVal;
}
