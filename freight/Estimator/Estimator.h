//
//  Estimator.h
//  freight
//
//  Created by Robert Diamond on 5/30/15.
//  Copyright (c) 2015 Robert Diamond. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol Estimator <NSObject>

- (void)setAttributeNamed:(NSString *)attribute toValue:(id)value;
- (id)getAttributeNamed:(NSString *)attribute;
- (void)addSample:(CGPoint)point timeStamp:(NSTimeInterval)timeStamp;
- (double)speed;
- (NSArray *)path;

@end