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
@property NSTimeInterval timeIndex;
@property NSTimeInterval lastRunTime;
@property (weak) IBOutlet NSTextField *simulationSpeedTextBox;
@property (weak) IBOutlet NSSlider *simulationSpeedSlider;

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

    self.simulationSpeedTextBox.doubleValue = self.simulationSpeedSlider.doubleValue;
}

- (void)viewWillAppear {
    self.chartScene = [[ChartScene alloc] initWithSize:self.chartView.bounds.size];
    self.timeIndex = 0;
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
    self.mapMaxXField.doubleValue = mapMaxX + 5;
    self.mapMinXField.doubleValue = mapMinX - 5;
    self.mapMaxYField.doubleValue = mapMaxY + 5;
    self.mapMinYField.doubleValue = mapMinY - 5;
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

- (IBAction)didChangeSimulationSpeed:(NSSlider *)sender
{
    self.chartScene.speed = sender.doubleValue;
    self.simulationSpeedTextBox.doubleValue = sender.doubleValue;
}
- (IBAction)didChangeSimulationSpeedValue:(NSTextField *)sender {
    self.chartScene.speed = sender.doubleValue;
    self.simulationSpeedSlider.doubleValue = sender.doubleValue;
}

#pragma mark - Data
// TODO: handle negative speed and manually setting time index
- (void)update:(NSTimeInterval)currentTime forScene:(SKScene *)scene
{
    NSTimeInterval runTime = currentTime - self.lastRunTime;
    self.lastRunTime = currentTime;
    if (self.index > 0) {
        self.timeIndex += runTime * self.chartScene.speed;
    }
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
        if (observationTime > self.timeIndex) {
            if (self.index == 0) {
                self.timeIndex = observationTime;
            } else {
                break;
            }
        }
        ++self.index;
        CGFloat xPos = [observation[@"x"] doubleValue];
        CGFloat yPos = [observation[@"y"] doubleValue];

        SKShapeNode *newNode = [SKShapeNode shapeNodeWithCircleOfRadius:5.0];
        newNode.fillColor = [SKColor blueColor];
        [scene addChild:newNode];
        newNode.position = CGPointMake((xPos - mapMinX) * scene.size.width / mapWidth, (yPos - mapMinY) * scene.size.height / mapHeight);
//        NSLog(@"adding node from %.0f,%.0f to %@", xPos, yPos, NSStringFromPoint(newNode.position));
        [newNode runAction:[SKAction sequence:@[[SKAction scaleBy:1.5 duration:0.25],[SKAction scaleBy:(2.0/3.0) duration:0.25],[SKAction fadeOutWithDuration:1.5]]] completion:^{
            [scene removeChildrenInArray:@[newNode]];
        }];
    }
}

@end
