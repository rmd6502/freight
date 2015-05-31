//
//  ChartScene.h
//  freight
//
//  Created by Robert Diamond on 5/30/15.
//  Copyright (c) 2015 Robert Diamond. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface ChartScene : SKScene

@property SKShapeNode *pathNode;
@property BOOL showsReticle;
@property CGFloat minX, minY, maxX, maxY;
@property (readonly) CGFloat width, height;

- (void)addPoint:(NSPoint)point;
- (void)createReticle;

@end
