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

@interface PathPoint : NSObject
@property CGFloat x, y;
@end
@implementation PathPoint
- (NSString *)description
{
    return [NSString stringWithFormat:@"PathPoint at %.2f,%.2f", self.x, self.y];
}
@end

@interface ChartScene ()
@property BOOL contentCreated;
@property CGMutablePathRef path;
@property BOOL showsReticleInternal;
@property SKNode *reticleNode;
@property (strong) NSMutableArray *pathPoints;
@end

@implementation ChartScene
- (instancetype)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        self.pathPoints = [NSMutableArray new];
    }
    return self;
}

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

- (void)addPoint:(NSPoint)nodePoint
{
    //NSLog(@"adding point %@", NSStringFromPoint(nodePoint));
    PathPoint *newPoint = [PathPoint new];
    newPoint.x = nodePoint.x;
    newPoint.y = nodePoint.y;
    [self.pathPoints addObject:newPoint];
    [self _internalAddPoint:newPoint];
}

- (void)_internalAddPoint:(PathPoint *)nodePoint
{
    CGPoint point = CGPointMake((nodePoint.x - self.minX) * self.size.width / self.width, (nodePoint.y - self.minY) * self.size.height / self.height);

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

- (void)didChangeSize:(CGSize)oldSize
{
    [super didChangeSize:oldSize];
    if (self.reticleNode) {
        [self removeChildrenInArray:@[self.reticleNode]];
        [self createReticle];
    }
    if (self.pathNode) {
        self.path = CGPathCreateMutable();
        for (PathPoint *point in self.pathPoints) {
            [self _internalAddPoint:point];
        }
    }
}

- (BOOL)showsReticle
{
    return self.showsReticleInternal;
}

- (void)setShowsReticle:(BOOL)showsReticle
{
    if (self.showsReticleInternal != showsReticle) {
        self.showsReticleInternal = showsReticle;
        self.reticleNode.hidden = !showsReticle;
    }
}

- (CGFloat)width
{
    return self.maxX - self.minX;
}

- (CGFloat)height
{
    return self.maxY - self.minY;
}

- (void)createReticle
{
    self.reticleNode = [[SKNode alloc] init];

    for (CGFloat yCoord = self.minY; yCoord < self.maxY; yCoord += self.height/10) {
        SKLabelNode *tickNode = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue"];
        tickNode.fontColor = [SKColor blackColor];
        tickNode.fontSize = 12.0;
        tickNode.text = [NSString stringWithFormat:@"%.2f", yCoord];
        tickNode.position = CGPointMake(22, (yCoord - self.minY)*self.size.height/self.height+5);
        [self.reticleNode addChild:tickNode];
    }
    for (CGFloat xCoord = self.minX + 10; xCoord < self.maxX; xCoord += self.width/10) {
        SKLabelNode *tickNode = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue"];
        tickNode.fontColor = [SKColor blackColor];
        tickNode.fontSize = 12.0;
        tickNode.text = [NSString stringWithFormat:@"%.2f", xCoord];
        tickNode.position = CGPointMake((xCoord - self.minX)*self.size.width/self.width+5, 10);
        [self.reticleNode addChild:tickNode];
    }

    [self addChild:self.reticleNode];
}

@end
