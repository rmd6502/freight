//
//  ViewController.h
//  freight
//
//  Created by Robert Diamond on 5/30/15.
//  Copyright (c) 2015 Robert Diamond. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "Estimator.h"

@interface ViewController : NSViewController

@property id<Estimator> estimator;

@end

