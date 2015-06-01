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
#import "Sample.h"

@interface ChartScene ()
@property BOOL contentCreated;
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
    }
}


- (void)createSceneContents
{
    // TODO: allow chooser
    self.backgroundColor = [SKColor whiteColor];
    self.scaleMode = SKSceneScaleModeAspectFit;
    self.pathNode = [[SKNode alloc] init];
    [self addChild:self.pathNode];
}

- (CGPoint)adjustedPoint:(CGPoint)point
{
    return CGPointMake((point.x - self.minX) * self.size.width / self.width, (point.y - self.minY) * self.size.height / self.height);
}

- (void)addSample:(Sample *)sample
{
    Sample *lastSample = [self.pathPoints lastObject];

    [self.pathPoints addObject:sample];

    if (lastSample) {
        CGPoint point = [self adjustedPoint:CGPointMake(sample.xPos, sample.yPos)];
        CGPoint lastPoint = [self adjustedPoint:CGPointMake(lastSample.xPos, lastSample.yPos)];

        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, lastPoint.x, lastPoint.y);
        CGPathAddLineToPoint(path, NULL, point.x, point.y);

        SKShapeNode *pathNode = [SKShapeNode shapeNodeWithPath:path];
        pathNode.strokeColor = [SKColor darkGrayColor];
        pathNode.lineWidth = 7.0;
        pathNode.lineJoin = kCGLineJoinRound;
        pathNode.lineCap = kCGLineCapRound;
        pathNode.antialiased = YES;
        pathNode.alpha = 0;
        pathNode.userData = [@{@"sample": sample} mutableCopy];
        pathNode.userInteractionEnabled = YES;
        SKLabelNode *label = [SKLabelNode labelNodeWithText:[NSString stringWithFormat:@"%.2f", sample.offset]];
        label.fontSize = 14.0;
        label.fontColor = [SKColor blackColor];
        label.position = lastPoint;
        label.hidden = YES;
        [pathNode addChild:label];

        [self.pathNode addChild:pathNode];

        [pathNode runAction:[SKAction fadeInWithDuration:0.5]];
    }
}

- (void)didChangeSize:(CGSize)oldSize
{
    [super didChangeSize:oldSize];
    if (self.reticleNode) {
        [self removeChildrenInArray:@[self.reticleNode]];
        [self createReticle];
    }
    if (self.pathNode) {
        [self.pathNode removeAllChildren];
        NSArray *pathPoints = self.pathPoints;
        self.pathPoints = [NSMutableArray new];
        for (Sample *sample in pathPoints) {
            [self addSample:sample];
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

- (void)mouseDown:(NSEvent *)theEvent
{
    NSPoint point = [[self view] convertPoint:[theEvent locationInWindow] fromView:nil];
    SKNode *clickedNode = [self nodeAtPoint:point];
    NSLog(@"touch %@ converted %@ clickedNode: %@", theEvent, NSStringFromPoint(point), clickedNode);
}

- (void)mouseUp:(NSEvent *)theEvent
{

}

- (void)mouseDragged:(NSEvent *)theEvent
{

}

@end
