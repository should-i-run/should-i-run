//
//  XMLReader.h
//  Should I Run
//
//  Created by Roger Goldfinger on 7/16/14.
//  Copyright (c) 2014 Should I Run. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface XMLReader : NSObject
{
    NSMutableArray *dictionaryStack;
    NSMutableString *textInProgress;
    NSError *errorPointer;
}

+ (NSDictionary *)dictionaryForXMLData:(NSData *)data error:(NSError **)errorPointer;
+ (NSDictionary *)dictionaryForXMLString:(NSString *)string error:(NSError **)errorPointer;

@end