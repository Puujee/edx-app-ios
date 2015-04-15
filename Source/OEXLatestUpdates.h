//
//  OEXLatestUpdates.h
//  edXVideoLocker
//
//  Created by Rahul Varma on 05/06/14.
//  Copyright (c) 2014 edX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OEXLatestUpdates : NSObject

- (id)initWithDictionary:(NSDictionary*)info;

@property (nonatomic, strong) NSString* video;

@end
