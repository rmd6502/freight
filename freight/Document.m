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

@end

@implementation Document

- (instancetype)init {
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
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
    [vc setRepresentedObject:self.readings];
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

    // readonly shallow copy
    self.readings = [observeData[@"reports"] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDictionary *d1 = (NSDictionary *)obj1;
        NSDictionary *d2 = (NSDictionary *)obj2;
        if (![d1 isKindOfClass:[NSDictionary class]] || ![d2 isKindOfClass:[NSDictionary class]]) {
            return NSOrderedSame;
        }
        // nils will have a doublevalue of 0.  Other types may throw
        return [d1[@"timestamp"] doubleValue] - [d2[@"timestamp"] doubleValue];
    }];
    
    return YES;
}

@end
