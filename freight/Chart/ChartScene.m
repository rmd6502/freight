//
//  ChartScene.m
//  freight
//
//  Created by Robert Diamond on 5/30/15.
//  Copyright (c) 2015 Robert Diamond. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "ChartNode.h"
#import "ChartScene.h"

@interface ChartScene ()
@property BOOL contentCreated;
@property CGMutablePathRef path;
@property BOOL showsReticleInternal;
@property SKNode *reticleNode;
@end

@implementation ChartScene

- (void)didMoveToView: (SKView *) view
{
    if (!self.contentCreated)
    {
        [self createSceneContents];
        self.contentCreated = YES;
        self.path = CGPathCreateMutable();
    }
}


- (void)createSceneContents
{
    // TODO: allow chooser
    self.backgroundColor = [SKColor whiteColor];
    self.scaleMode = SKSceneScaleModeAspectFit;
    self.pathNode = [[SKShapeNode alloc] init];
    self.pathNode.strokeColor = [SKColor darkGrayColor];
    self.pathNode.lineWidth = 7.0;
    self.pathNode.lineJoin = kCGLineJoinRound;
    self.pathNode.lineCap = kCGLineCapRound;
    self.pathNode.antialiased = YES;
    [self addChild:self.pathNode];
}

- (void)addPoint:(NSPoint)point
{
    //NSLog(@"adding point %@", NSStringFromPoint(point));
    if (CGPathIsEmpty(self.path)) {
        CGPathMoveToPoint(self.path, NULL, point.x, point.y);
    } else {
        CGPathAddLineToPoint(self.path, NULL, point.x, point.y);
    }
    SKAction *changePath = [SKAction runBlock:^{
        self.pathNode.path = self.path;
    }];
    changePath.duration = 0.75;
    [self.pathNode runAction:changePath];
}

- (BOOL)showsReticle
{
    return self.showsReticleInternal;
}

- (void)setShowsReticle:(BOOL)showsReticle
{
    if (self.showsReticleInternal != showsReticle) {
        self.showsReticleInternal = showsReticle;

    }
}

- (void)createReticle
{
    self.reticleNode = [[SKNode alloc] init];

}

@end
