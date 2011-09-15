//
//  YLContextualMenuManager.h
//  Nally
//
//  Created by Yung-Luen Lan on 11/28/07.
//  Copyright 2007 yllan.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface YLContextualMenuManager : NSObject
{
    NSArray *_urlsToOpen;
}
+ (YLContextualMenuManager *) sharedInstance ;
- (id) init ;
- (NSArray *) availableMenuItemForSelectionString: (NSString *)selectedString;

@end
