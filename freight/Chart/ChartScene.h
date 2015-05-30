//
//  ChartScene.h
//  freight
//
//  Created by Robert Diamond on 5/30/15.
//  Copyright (c) 2015 Robert Diamond. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface ChartScene : SKScene

- (void)addDataPoint:(CGPoint)point atTime:(NSTimeInterval)observed;

@end
