//
//  Document.h
//  freight
//
//  Created by Robert Diamond on 5/30/15.
//  Copyright (c) 2015 Robert Diamond. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Document : NSDocument

@property (nonatomic,readonly) NSArray *readings;

// Returns data between start and end.
// If the start point is later than the last reading time, or the end
// is before the first, returns nil.
// May return an empty array if there is no data between the two points,
// but said points are not off a boundary.
- (NSArray *)dataFromTimeInterval:(NSTimeInterval)start toInterval:(NSTimeInterval)end;
@end

