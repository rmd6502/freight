//
//  EstimatorFactory.h
//  freight
//
//  Created by Robert Diamond on 5/31/15.
//  Copyright (c) 2015 Robert Diamond. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Estimator.h"

@interface EstimatorFactory : NSObject

+ (id<Estimator>)estimatorNamed:(NSString *)name;

@end
