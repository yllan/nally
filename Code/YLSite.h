//
//  YLSite.h
//  Nally
//
//  Created by Lan Yung-Luen on 11/20/07.
//  Copyright 2007 yllan.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CommonType.h"

@interface YLSite : NSObject {
    NSString *_name;
    NSString *_address;
    NSString *_account;
    NSString *_password;

    YLEncoding _encoding;
    YLANSIColorKey _ansiColorKey;
    BOOL _detectDoubleByte;
}

+ (YLSite *) site;
+ (YLSite *) siteWithDictionary: (NSDictionary *)d;
- (NSDictionary *) dictionaryOfSite;

@property (copy) NSString *name;
@property (copy) NSString *address;
@property (copy) NSString *account;
@property (copy) NSString *password;
@property YLEncoding encoding;
@property YLANSIColorKey ansiColorKey;
@property BOOL detectDoubleByte;

@end
