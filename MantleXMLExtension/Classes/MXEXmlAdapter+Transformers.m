//
//  MXEXmlAdapter+Transformer.m
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2017/02/16.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MXEXmlAdapter.h"
#import <Mantle/MTLValueTransformer.h>
#import <Mantle/NSValueTransformer+MTLPredefinedTransformerAdditions.h>
#import "NSError+MantleXMLExtension.h"

@implementation MXEXmlAdapter (Transformers)

+ (NSValueTransformer<MTLTransformerErrorHandling>* _Nonnull)
    xmlNodeArrayTransformerWithModelClass:(Class _Nonnull)modelClass
{
    NSParameterAssert(modelClass != nil);

    return [NSValueTransformer mtl_arrayMappingTransformerWithTransformer:[self xmlNodeTransformerWithModelClass:modelClass]];
}

+ (NSValueTransformer<MTLTransformerErrorHandling>* _Nonnull)
    xmlNodeTransformerWithModelClass:(Class _Nonnull)modelClass
{
    NSParameterAssert(modelClass != nil);
    NSParameterAssert([modelClass conformsToProtocol:@protocol(MTLModel)]);
    NSParameterAssert([modelClass conformsToProtocol:@protocol(MXEXmlSerializing)]);
    __block MXEXmlAdapter* adapter;

    return [MTLValueTransformer
            transformerUsingForwardBlock:
            ^id _Nullable(id _Nullable xmlNode, BOOL* _Nonnull success, NSError* _Nullable* _Nullable error) {

                if (!xmlNode) {
                    return nil;
                }

                if (![xmlNode isKindOfClass:MXEXmlNode.class]) {
                    setError(error, MXEErrorInvalidInputData,
                             [NSString stringWithFormat:@"Input data expected %@, but got %@.",
                              MXEXmlNode.class, [xmlNode class]]);
                    *success = NO;
                    return nil;
                }

                adapter = adapter ?: [[self alloc] initWithModelClass:modelClass];
                id model = [adapter modelFromXmlNode:xmlNode error:error];
                *success = model != nil;
                return model;

            }
            reverseBlock:
            ^MXEXmlNode* _Nullable(id _Nullable model, BOOL* _Nonnull success, NSError* _Nullable* _Nullable error) {
                if (!model) {
                    return nil;
                }

                if (!([model conformsToProtocol:@protocol(MTLModel)]
                      && [model conformsToProtocol:@protocol(MXEXmlSerializing)])) {
                    setError(error, MXEErrorInvalidInputData,
                             [NSString stringWithFormat:@"Input data expected MXEXmlSerializing object, but got %@.",
                              [model class]]);
                    *success = NO;
                    return nil;
                }

                adapter = adapter ?: [[self alloc] initWithModelClass:modelClass];
                MXEXmlNode* result = [adapter xmlNodeFromModel:model error:error];
                *success = result != nil;
                return result;
            }];
}

+ (NSValueTransformer<MTLTransformerErrorHandling>* _Nonnull)
    mappingDictionaryTransformerWithKeyPath:(id<MXEXmlAccessible> _Nonnull)keyPath
                                  valuePath:(id<MXEXmlAccessible> _Nonnull)valuePath
{
    NSParameterAssert(keyPath != nil && valuePath != nil);

    return [MTLValueTransformer
            transformerUsingForwardBlock:
            ^NSDictionary* _Nullable(MXEXmlNode* _Nullable node, BOOL* _Nonnull success, NSError *_Nullable *_Nullable error) {
                if (!node) {
                    return nil;
                }
                if (![node isKindOfClass:MXEXmlNode.class]) {
                    *success = NO;
                    return nil;
                }

                NSMutableDictionary* transformedDictionary = [NSMutableDictionary dictionary];
                for (MXEXmlNode* child in node.children) {
                    MXEMutableXmlNode* dummyNode;
                    if (child == [child.children firstObject]) {
                        dummyNode = [[MXEMutableXmlNode alloc] initWithElementName:node.elementName
                                                                        attributes:node.attributes
                                                                          children:@[child]];
                    } else {
                        dummyNode = [[MXEMutableXmlNode alloc] initWithElementName:node.elementName
                                                                        attributes:nil
                                                                          children:@[child]];
                    }

                    id key = [dummyNode getForXmlPath:keyPath];
                    id value = [dummyNode getForXmlPath:valuePath];
                    if (key && !transformedDictionary[key]) {
                        transformedDictionary[key] = value ?: NSNull.null;
                    }
                }
                *success = YES;
                return transformedDictionary;
            }
            reverseBlock:
            ^MXEXmlNode* _Nullable(NSDictionary* _Nullable dict, BOOL* _Nonnull success, NSError *_Nullable *_Nullable error) {
                if (!dict) {
                    return nil;
                }
                if (![dict isKindOfClass:NSDictionary.class]) {
                    *success = NO;
                    return nil;
                }

                MXEMutableXmlNode* root = [[MXEMutableXmlNode alloc] initWithElementName:@"root"];
                for (id key in dict) {
                    id value = dict[key];
                    if ([NSNull.null isEqual:value]) {
                        continue;
                    }

                    MXEMutableXmlNode* node = [[MXEMutableXmlNode alloc] initWithElementName:@"dummy"];
                    [node setValue:key forXmlPath:keyPath];
                    [node setValue:value forXmlPath:valuePath];
                    if (node.attributes) {
                        root.attributes = node.attributes;
                    }
                    if (node.children.count) {
                        [root addChild:node.children[0]];
                    }
                }
                return root;
            }];
}

+ (NSValueTransformer<MTLTransformerErrorHandling>* _Nonnull)dictionaryTransformer
{
    return [MTLValueTransformer
            transformerUsingForwardBlock:
            ^NSDictionary* _Nullable(MXEXmlNode* _Nullable value, BOOL* _Nonnull success, NSError *_Nullable *_Nullable error) {
                if (!value) {
                    return nil;
                }
                if (![value isKindOfClass:MXEXmlNode.class]) {
                    *success = NO;
                    return nil;
                }
                return [value toDictionary];
            }
            reverseBlock:
            ^MXEXmlNode* _Nullable(NSDictionary* _Nullable value, BOOL* _Nonnull success, NSError *_Nullable *_Nullable error) {
                if (!value) {
                    return nil;
                }
                if (![value isKindOfClass:NSDictionary.class]) {
                    *success = NO;
                    return nil;
                }
                return [[MXEXmlNode alloc] initWithElementName:@"dummy" fromDictionary:value];
            }];
}

+ (NSValueTransformer<MTLTransformerErrorHandling>* _Nonnull)numberTransformer
{
    return [MTLValueTransformer
            transformerUsingForwardBlock:
            ^NSNumber* _Nullable(id _Nullable str, BOOL* _Nonnull success, NSError* _Nullable* _Nullable error) {

                if (!str) {
                    return nil;
                }
                if (![str isKindOfClass:NSString.class]) {
                    setError(error, MXEErrorInvalidInputData,
                             [NSString stringWithFormat:@"Input data expected a numeric string, but got %@.",
                              [str class]]);
                    *success = NO;
                    return nil;
                }

                NSString* pattern = @"^[\\-\\+]?[0-9]*(\\.[0-9]*)?(f)?$";
                NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                                       options:0
                                                                                         error:nil];
                NSTextCheckingResult* match = [regex firstMatchInString:str
                                                                options:0
                                                                  range:NSMakeRange(0, [str length])];
                NSAssert([match numberOfRanges] == 3, @"The number of elements of match MUST be 3");

                if ([match rangeAtIndex:2].location != NSNotFound) {
                    *success = YES;
                    return [NSNumber numberWithFloat:[str floatValue]];
                } else if ([match rangeAtIndex:1].location != NSNotFound) {
                    *success = YES;
                    return [NSNumber numberWithDouble:[str doubleValue]];
                } else if ([match rangeAtIndex:0].location != NSNotFound) {
                    *success = YES;
                    return [NSNumber numberWithInteger:[str integerValue]];
                } else {
                    setError(error, MXEErrorInvalidInputData,
                             [NSString stringWithFormat:@"Could not convert String to Number. Got %@", str]);
                    *success = NO;
                    return nil;
                }
            }
            reverseBlock:
            ^NSString* _Nullable(id _Nullable value, BOOL* _Nonnull success, NSError* _Nullable* _Nullable error) {
                if (!value) {
                    return nil;
                }
                if (![value isKindOfClass:NSNumber.class]) {
                    setError(error, MXEErrorInvalidInputData,
                             [NSString stringWithFormat:@"Input data expected NSNumber, but got %@", [value class]]);
                    *success = NO;
                    return nil;
                }
                *success = YES;
                return [(NSNumber*)value stringValue];
            }];
}

+ (NSValueTransformer<MTLTransformerErrorHandling>* _Nonnull)boolTransformer
{
    return [MTLValueTransformer
            transformerUsingForwardBlock:
            ^NSNumber* _Nullable(id _Nullable str, BOOL* _Nonnull success, NSError* _Nullable* _Nullable error) {

                if (!str) {
                    return nil;
                }
                if (![str isKindOfClass:NSString.class]) {
                    setError(error, MXEErrorInvalidInputData,
                             [NSString stringWithFormat:@"Input data expected a numeric string, but got %@.",
                              [str class]]);
                    *success = NO;
                    return nil;
                }

                *success = YES;
                return [NSNumber numberWithBool:[str boolValue]];
            }
            reverseBlock:
            ^NSString* _Nullable(id _Nullable value, BOOL* _Nonnull success, NSError* _Nullable* _Nullable error) {
                if (!value) {
                    return nil;
                }
                if (![value isKindOfClass:NSNumber.class]) {
                    setError(error, MXEErrorInvalidInputData,
                             [NSString stringWithFormat:@"Input data expected NSNumber, but got %@", [value class]]);
                    *success = NO;
                    return nil;
                }
                *success = YES;
                return [(NSNumber*)value integerValue] ? @"true" : @"false";
            }];
}

@end
