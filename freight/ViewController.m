//
//  ViewController.m
//  freight
//
//  Created by Robert Diamond on 5/30/15.
//  Copyright (c) 2015 Robert Diamond. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

#import "ChartScene.h"
#import "ViewController.h"

@interface ViewController ()<SKSceneDelegate>
@property (weak) IBOutlet NSTextField *mapMinXField;
@property (weak) IBOutlet NSTextField *mapMinYField;
@property (weak) IBOutlet NSTextField *mapMaxXField;
@property (weak) IBOutlet NSTextField *mapMaxYField;
@property (weak) IBOutlet SKView *chartView;
@property (weak) IBOutlet NSButton *autoMapSize;
@property ChartScene *chartScene;
// index within the points in the represented object
@property NSUInteger index;
@property NSTimeInterval startTime;

@end

@implementation ViewController

#pragma mark View Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.chartView.showsDrawCount = YES;
    self.chartView.showsNodeCount = YES;
    self.chartView.showsFPS = YES;

    self.mapMinYField.editable = NO;
    self.mapMinYField.doubleValue = -100;
    self.mapMaxYField.editable = NO;
    self.mapMaxYField.doubleValue = 0;
    self.mapMinXField.editable = NO;
    self.mapMinXField.doubleValue = 0;
    self.mapMaxXField.editable = NO;
    self.mapMaxXField.doubleValue = 100;
}

- (void)viewWillAppear {
    self.chartScene = [[ChartScene alloc] initWithSize:self.chartView.bounds.size];
    self.startTime = -1;
    self.chartScene.delegate = self;
    [self.chartView presentScene: self.chartScene];
}

- (void)viewDidLayout
{
    [super viewDidLayout];
    self.chartScene.size = self.chartView.bounds.size;
}

#pragma mark - Document
- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    if (self.autoMapSize.state == NSOffState) {
        return;
    }

    CGFloat mapMinX = DBL_MAX;
    CGFloat mapMinY = DBL_MAX;
    CGFloat mapMaxX = -DBL_MAX;
    CGFloat mapMaxY = -DBL_MAX;

    NSArray *points = self.representedObject;
    for (NSDictionary *reading in points) {
        CGFloat xPos = [reading[@"x"] doubleValue];
        CGFloat yPos = [reading[@"y"] doubleValue];

        if (xPos > mapMaxX) {
            mapMaxX = xPos;
        }
        if (xPos < mapMinX) {
            mapMinX = xPos;
        }
        if (yPos > mapMaxY) {
            mapMaxY = yPos;
        }
        if (yPos < mapMinY) {
            mapMinY = yPos;
        }
    }
    self.mapMaxXField.doubleValue = mapMaxX;
    self.mapMinXField.doubleValue = mapMinX;
    self.mapMaxYField.doubleValue = mapMaxY;
    self.mapMinYField.doubleValue = mapMinY;
}

#pragma mark - Actions
- (IBAction)didSelectReticle:(NSButton *)sender {
}

- (IBAction)didSelectAutomaticMapSize:(NSButton *)sender {
    self.mapMinYField.editable = (sender.state == NSOffState);
    self.mapMaxYField.editable = (sender.state == NSOffState);
    self.mapMinXField.editable = (sender.state == NSOffState);
    self.mapMaxXField.editable = (sender.state == NSOffState);
}

#pragma mark - Data
- (void)update:(NSTimeInterval)currentTime forScene:(SKScene *)scene
{
    if (self.startTime == -1) {
        self.startTime = currentTime;
        return;
    }
    NSTimeInterval runTime = currentTime - self.startTime;
    NSArray *points = self.representedObject;
    CGFloat mapMinX = self.mapMinXField.doubleValue;
    CGFloat mapMinY = self.mapMinYField.doubleValue;
    CGFloat mapMaxX = self.mapMaxXField.doubleValue;
    CGFloat mapMaxY = self.mapMaxYField.doubleValue;

    CGFloat mapWidth = mapMaxX - mapMinX;
    CGFloat mapHeight = mapMaxY - mapMinY;

    while (self.index < points.count) {
        NSDictionary *observation = points[self.index];
        NSTimeInterval observationTime = [observation[@"timestamp"] doubleValue];
        if (observationTime > runTime) {
            break;
        }
        ++self.index;
        CGFloat xPos = [observation[@"x"] doubleValue];
        CGFloat yPos = [observation[@"y"] doubleValue];

        SKShapeNode *newNode = [SKShapeNode shapeNodeWithCircleOfRadius:5.0];
        newNode.fillColor = [SKColor blueColor];
        [scene addChild:newNode];
        newNode.position = CGPointMake((xPos - mapMinX) * scene.size.width / mapWidth, (yPos - mapMinY) * scene.size.height / mapHeight);
//        NSLog(@"adding node from %.0f,%.0f to %@", xPos, yPos, NSStringFromPoint(newNode.position));
        [newNode runAction:[SKAction sequence:@[[SKAction scaleBy:1.5 duration:0.125],[SKAction scaleBy:1.0 duration:0.125],[SKAction fadeOutWithDuration:1.5]]]];
    }
}

@end
