//
//  MovingAverageEstimator.m
//  freight
//
//  Created by Robert Diamond on 5/31/15.
//  Copyright (c) 2015 Robert Diamond. All rights reserved.
//

#import "MovingAverageEstimator.h"
#import "Sample.h"

@interface MovingAverageEstimator ()
// appended with our estimated positions
@property (strong) NSMutableArray *positions;
// samples indexed by time
@property (strong) NSMutableArray *samples;
// Time in seconds to consider a single reading
@property NSTimeInterval backTime;
// running x sum
@property CGFloat xSum;
// runniny y sum
@property CGFloat ySum;
// index of first sample in running sums
@property NSUInteger firstSample;
@end

@implementation MovingAverageEstimator

- (instancetype)init
{
    if (self = [super init]) {
        self.samples = [NSMutableArray new];
        self.positions = [NSMutableArray new];
        self.backTime = 60;
    }
    return self;
}

#pragma mark - Estimator Protocol
- (void)addSample:(CGPoint)point timeStamp:(NSTimeInterval)timeStamp
{
    Sample *newSample = [[Sample alloc] init];
    newSample.xPos = point.x;
    newSample.yPos = point.y;
    newSample.offset = timeStamp;
    [self.samples addObject:newSample];
    self.xSum += newSample.xPos;
    self.ySum += newSample.yPos;
    [self _recalculatePositions];
    NSUInteger sampleCount = self.samples.count - self.firstSample;
    if (sampleCount > 0) {
        Sample *newPathItem = [[Sample alloc] init];
        newPathItem.xPos = self.xSum / sampleCount;
        newPathItem.yPos = self.ySum / sampleCount;
        newPathItem.offset = newSample.offset;
        [self.positions addObject:newPathItem];
    }
}

- (double)speed
{
    // estimate the speed as the distance between the last two points / the time between the
    // last two points.
    if (self.positions.count > 1) {
        Sample *lastSample = [self.positions lastObject];
        Sample *secondLastSample = self.positions[self.positions.count - 2];
        double xdiff = lastSample.xPos - secondLastSample.xPos;
        double ydiff = lastSample.yPos - secondLastSample.yPos;
        double distance = sqrt(xdiff*xdiff + ydiff*ydiff);
        double timediff = lastSample.offset - secondLastSample.offset;
        if (timediff > 0) {
            return distance / timediff;
        }
    }
    // can't calculate or error above
    return 0;
}

- (NSArray *)path
{
    return [self.positions copy];
}

- (void)setAttributeNamed:(NSString *)attribute toValue:(id)value
{
    if ([attribute isEqualToString:@"backtime"]) {
        self.backTime = [value doubleValue];
        [self readdSamples];
    }
}

- (id)getAttributeNamed:(NSString *)attribute
{
    if ([attribute isEqualToString:@"name"]) {
        return @"MovingAverage";
    } else if ([attribute isEqualToString:@"backtime"]) {
        return @(self.backTime);
    } else if ([attribute isEqualToString:@"samplecount"]) {
        return @(self.samples.count);
    } else if ([attribute isEqualToString:@"xsum"]) {
        return @(self.xSum);
    } else if ([attribute isEqualToString:@"ysum"]) {
        return @(self.ySum);
    } else {
        return nil;
    }
}

#pragma mark - Private Methods
// ugly, but not intended for production
- (void)readdSamples
{
    NSArray *newsamples = self.samples;
    self.samples = [NSMutableArray new];
    self.positions = [NSMutableArray new];
    self.xSum = 0;
    self.ySum = 0;
    for (Sample *sample in newsamples) {
        [self addSample:CGPointMake(sample.xPos, sample.yPos) timeStamp:sample.offset];
    }
}

- (void)_recalculatePositions
{
    // 0 or 1 samples means there's nothing to do
    if (self.samples.count < 2) {
        return;
    }
    NSTimeInterval latestTime = [(Sample *)[self.samples lastObject] offset];
    while (self.firstSample < self.samples.count) {
        Sample *current = self.samples[self.firstSample];
        if (latestTime - current.offset > self.backTime) {
            self.xSum -= current.xPos;
            self.ySum -= current.yPos;
            ++self.firstSample;
        } else {
            break;
        }
    }
}

@end
