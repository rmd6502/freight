//
//  ChartScene.h
//  freight
//
//  Created by Robert Diamond on 5/30/15.
//  Copyright (c) 2015 Robert Diamond. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class Sample;
@interface ChartScene : SKScene

@property SKNode *pathNode;
@property BOOL showsReticle;
@property CGFloat minX, minY, maxX, maxY;
@property (readonly) CGFloat width, height;

- (void)addSample:(Sample *)sample;
- (void)createReticle;

@end
