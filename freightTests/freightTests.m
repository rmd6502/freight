//
//  freightTests.m
//  freightTests
//
//  Created by Robert Diamond on 5/30/15.
//  Copyright (c) 2015 Robert Diamond. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "EstimatorFactory.h"
#import "MovingAverageEstimator.h"

@interface freightTests : XCTestCase

@end

@implementation freightTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testEstimatorFactory {
    id<Estimator> estimator = [EstimatorFactory estimatorNamed:@"MovingAverage"];
    XCTAssert([estimator isKindOfClass:[MovingAverageEstimator class]], @"factory failed to create an estimator");
    estimator = [EstimatorFactory estimatorNamed:@"foo"];
    XCTAssert(estimator == nil, @"factory created a bad class");
}

@end
