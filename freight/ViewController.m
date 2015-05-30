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

@interface ViewController ()
@property (weak) IBOutlet NSTextField *mapWidthField;
@property (weak) IBOutlet NSTextField *mapHeightField;
@property (weak) IBOutlet SKView *chartView;
@property (nonatomic) ChartScene *chartScene;

@end

@implementation ViewController

#pragma mark View Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.chartView.showsDrawCount = YES;
    self.chartView.showsNodeCount = YES;
    self.chartView.showsFPS = YES;

    self.mapHeightField.editable = NO;
    self.mapWidthField.editable = NO;
}

- (void)viewWillAppear {
    self.chartScene = [[ChartScene alloc] initWithSize:self.chartView.bounds.size];
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
}

#pragma mark - Actions
- (IBAction)didSelectReticle:(NSButton *)sender {
}

- (IBAction)didSelectAutomaticMapSize:(NSButton *)sender {
    self.mapHeightField.editable = (sender.state == NSOffState);
}

#pragma mark - Data
@end
