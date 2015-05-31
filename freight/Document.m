//
//  Document.m
//  freight
//
//  Created by Robert Diamond on 5/30/15.
//  Copyright (c) 2015 Robert Diamond. All rights reserved.
//

#import "Document.h"

@interface Document ()

@property (nonatomic) NSArray *readings;
@property (strong) NSComparator cmp;

@end

@implementation Document

- (instancetype)init {
    self = [super init];
    if (self) {
        self.cmp = ^NSComparisonResult(id obj1, id obj2) {
            NSDictionary *d1 = (NSDictionary *)obj1;
            NSDictionary *d2 = (NSDictionary *)obj2;
            if (![d1 isKindOfClass:[NSDictionary class]] || ![d2 isKindOfClass:[NSDictionary class]]) {
                return NSOrderedSame;
            }
            // nils will have a doublevalue of 0.  Other types may throw
            double db1 = [d1[@"timestamp"] doubleValue];
            double db2 = [d2[@"timestamp"] doubleValue];
            if (db1 == db2) {
                return NSOrderedSame;
            } else {
                return (db1 < db2) ? NSOrderedAscending : NSOrderedDescending;
            }
        };
    }
    return self;
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController {
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}

+ (BOOL)autosavesInPlace {
    return YES;
}

- (void)makeWindowControllers {
    // Override to return the Storyboard file name of the document.
    [self addWindowController:[[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"Document Window Controller"]];
    NSViewController *vc = ((NSWindowController *)self.windowControllers[0]).window.contentViewController;
    [vc setRepresentedObject:self];
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    [NSException raise:@"UnimplementedMethod" format:@"%@ is unimplemented", NSStringFromSelector(_cmd)];
    return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
    NSError *error = nil;
    NSDictionary *observeData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error) {
        *outError = error;
        return NO;
    }
    if (![observeData isKindOfClass:[NSDictionary class]]) {
        *outError = [NSError errorWithDomain:@"DataError" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"root isn't a dictionary"}];
        return NO;
    }
    if (![observeData[@"target"] isEqualToString:@"train"]) {
        *outError = [NSError errorWithDomain:@"DataError" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"not train data"}];
        return NO;
    }
    if (![observeData[@"reports"] isKindOfClass:[NSArray class]]) {
        *outError = [NSError errorWithDomain:@"DataError" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"no readings"}];
        return NO;
    }

    // readonly shallow copy sorted by time
    self.readings = [observeData[@"reports"] sortedArrayUsingComparator:self.cmp];
    
    return YES;
}

#pragma mark - Query method
- (NSArray *)dataFromTimeInterval:(NSTimeInterval)start toInterval:(NSTimeInterval)end
{
    NSUInteger startIndex = [self.readings indexOfObject:@{@"timestamp": @(start)} inSortedRange:NSMakeRange(0, self.readings.count) options:NSBinarySearchingInsertionIndex|NSBinarySearchingFirstEqual usingComparator:self.cmp];
    if (startIndex == self.readings.count) {
        return nil;
    }
    NSUInteger endIndex = [self.readings indexOfObject:@{@"timestamp": @(end)} inSortedRange:NSMakeRange(0, self.readings.count) options:NSBinarySearchingInsertionIndex|NSBinarySearchingFirstEqual usingComparator:self.cmp];
    if (endIndex == 0 && [self.readings[0][@"timestamp"] doubleValue] > end) {
        return nil;
    }
    NSLog(@"start %f end %f startindex %lu endindex %lu", start, end, startIndex, endIndex);
    return [self.readings subarrayWithRange:NSMakeRange(startIndex, endIndex - startIndex)];
}

@end
