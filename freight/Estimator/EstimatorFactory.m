//
//  EstimatorFactory.m
//  freight
//
//  Created by Robert Diamond on 5/31/15.
//  Copyright (c) 2015 Robert Diamond. All rights reserved.
//

#import "EstimatorFactory.h"
#import "MovingAverageEstimator.h"

@implementation Sample

@end

@implementation EstimatorFactory

+ (id<Estimator>)estimatorNamed:(NSString *)name
{
    if ([name isEqualToString:@"MovingAverage"]) {
        return [[MovingAverageEstimator alloc] init];
    } else {
        return nil;
    }
}

@end
