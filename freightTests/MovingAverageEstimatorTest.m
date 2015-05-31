//
//  MovingAverageEstimatorTest.m
//  freight
//
//  Created by Robert Diamond on 5/31/15.
//  Copyright (c) 2015 Robert Diamond. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "EstimatorFactory.h"
#import "MovingAverageEstimator.h"

@interface MovingAverageEstimatorTest : XCTestCase
@property (strong) MovingAverageEstimator *estimator;
@end

@implementation MovingAverageEstimatorTest

- (void)setUp {
    [super setUp];

    self.estimator = [EstimatorFactory estimatorNamed:@"MovingAverage"];
}

- (void)tearDown {
    self.estimator = nil;

    [super tearDown];
}

- (void)testAveraging {
    [self.estimator addSample:CGPointMake(0, 0) timeStamp:1.0];
    [self.estimator addSample:CGPointMake(2, 2) timeStamp:3.0];
    [self.estimator addSample:CGPointMake(4, 4) timeStamp:5.0];
    [self.estimator addSample:CGPointMake(6, 6) timeStamp:7.0];
    [self.estimator addSample:CGPointMake(8, 8) timeStamp:9.0];
    NSArray *path = [self.estimator path];
    XCTAssert(path.count == 5, @"Estimator didn't create 5 positions: %lu", path.count);
    Sample *lastSample = [path lastObject];
    XCTAssert(lastSample.xPos == 4, @"Estimator didn't average properly: %.2f", lastSample.xPos);
    // from (3,3) at timestamp 7 to (4,4) at timestamp 9
    XCTAssert([self.estimator speed] == sqrt(2)/2, @"Speed calculation not correct: %.2f", [self.estimator speed]);
    // test that only the first sample is dropped, since the 11 sample will be exactly 10 seconds
    [self.estimator addSample:CGPointMake(10, 9) timeStamp:11.0];
    [self.estimator addSample:CGPointMake(12, 10) timeStamp:13.0];
    double xSum = [[self.estimator getAttributeNamed:@"xsum"] doubleValue];
    XCTAssert(xSum == 42, @"Estimator didn't drop first sample: %.2f", xSum);
    path = [self.estimator path];
    lastSample = [path lastObject];
    XCTAssert(lastSample.xPos == 7, @"estimator didn't count properly: %.2f", lastSample.xPos);
}

- (void)testAttributes {
    [self.estimator setAttributeNamed:@"backtime" toValue:@5];
    NSTimeInterval backTime = [[self.estimator getAttributeNamed:@"backtime"] doubleValue];
    XCTAssert(backTime == 5, @"failed to set or get backtime attribute: %.2f", backTime);
}

@end
