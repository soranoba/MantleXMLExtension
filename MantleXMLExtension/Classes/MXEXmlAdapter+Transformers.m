//
//  MXEXmlAdapter+Transformer.m
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2017/02/16.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MXEXmlAdapter.h"
#import "NSError+MantleXMLExtension.h"
#import <Mantle/MTLValueTransformer.h>
#import <Mantle/NSValueTransformer+MTLPredefinedTransformerAdditions.h>

@implementation MXEXmlAdapter (Transformers)

+ (NSValueTransformer<MTLTransformerErrorHandling>* _Nonnull)
    xmlNodeArrayTransformerWithModelClass:(Class _Nonnull)modelClass
{
    NSParameterAssert(modelClass != nil);
    NSParameterAssert([modelClass conformsToProtocol:@protocol(MTLModel)]);
    NSParameterAssert([modelClass conformsToProtocol:@protocol(MXEXmlSerializing)]);

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
            ^id<MXEXmlSerializing> _Nullable(MXEXmlNode* _Nullable xmlNode, BOOL* _Nonnull success,
                                             NSError* _Nullable* _Nullable error) {

                if (!xmlNode) {
                    return nil;
                }

                if (![xmlNode isKindOfClass:MXEXmlNode.class]) {
                    setError(error, MXEErrorInvalidInputData,
                             [NSString stringWithFormat:@"Expected a %@, but got %@", MXEXmlNode.class, [xmlNode class]],
                             @{ MXEErrorInputDataKey : xmlNode });
                    *success = NO;
                    return nil;
                }

                adapter = adapter ?: [[self alloc] initWithModelClass:modelClass];
                id model = [adapter modelFromXmlNode:xmlNode error:error];
                *success = model != nil;
                return model;
            }
        reverseBlock:
            ^MXEXmlNode* _Nullable(id<MXEXmlSerializing> _Nullable model, BOOL* _Nonnull success,
                                   NSError* _Nullable* _Nullable error) {
                if (!model) {
                    return nil;
                }

                if (!([model conformsToProtocol:@protocol(MTLModel)]
                      && [model conformsToProtocol:@protocol(MXEXmlSerializing)])) {
                    setError(error, MXEErrorInvalidInputData,
                             [NSString stringWithFormat:@"Expected a MXEXmlSerializing object, but got %@.", [model class]],
                             @{ MXEErrorInputDataKey : model });
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
    mappingDictionaryTransformerWithKeyPath:(id _Nonnull)keyPath
                                  valuePath:(id _Nonnull)valuePath
{
    NSParameterAssert(keyPath != nil && valuePath != nil);

    id accessibleKeyPath, accessibleValuePath;
    if ([keyPath isKindOfClass:NSString.class]) {
        accessibleKeyPath = MXEXmlValue(keyPath);
    } else {
        NSAssert([keyPath conformsToProtocol:@protocol(MXEXmlAccessible)],
                 @"The keyPath MUST be either NSString or MXEXmlAccessible");
        accessibleKeyPath = keyPath;
    }

    if ([valuePath isKindOfClass:NSString.class]) {
        accessibleValuePath = MXEXmlValue(valuePath);
    } else {
        NSAssert([valuePath conformsToProtocol:@protocol(MXEXmlAccessible)],
                 @"The valuePath MUST be either NSString or MXEXmlAccessible");
        accessibleValuePath = valuePath;
    }

    return [MTLValueTransformer
        transformerUsingForwardBlock:
            ^NSDictionary* _Nullable(MXEXmlNode* _Nullable node, BOOL* _Nonnull success, NSError* _Nullable* _Nullable error) {
                *success = YES;
                if (!node) {
                    return nil;
                }
                if (![node isKindOfClass:MXEXmlNode.class]) {
                    setError(error, MXEErrorInvalidInputData,
                             [NSString stringWithFormat:@"Expected a %@, but got %@.", MXEXmlNode.class, node.class],
                             @{ MXEErrorInputDataKey : node });
                    *success = NO;
                    return nil;
                }

                NSMutableDictionary* transformedDictionary = [NSMutableDictionary dictionary];
                for (MXEXmlNode* child in node.children) {
                    MXEMutableXmlNode* dummyNode = [[MXEMutableXmlNode alloc] initWithElementName:node.elementName
                                                                                       attributes:node.attributes
                                                                                         children:@[ child ]];

                    id key = [dummyNode getForXmlPath:accessibleKeyPath];
                    id value = [dummyNode getForXmlPath:accessibleValuePath];
                    if (key && !transformedDictionary[key]) {
                        transformedDictionary[key] = value ?: NSNull.null;
                    }
                }
                return transformedDictionary;
            }
        reverseBlock:
            ^MXEXmlNode* _Nullable(NSDictionary* _Nullable dict, BOOL* _Nonnull success, NSError* _Nullable* _Nullable error) {
                *success = YES;
                if (!dict) {
                    return nil;
                }
                if (![dict isKindOfClass:NSDictionary.class]) {
                    setError(error, MXEErrorInvalidInputData,
                             [NSString stringWithFormat:@"Expected a %@, but got %@.", NSDictionary.class, dict.class],
                             @{ MXEErrorInputDataKey : dict });
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
                    [node setValue:key forXmlPath:accessibleKeyPath];
                    [node setValue:value forXmlPath:accessibleValuePath];
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
            ^NSDictionary* _Nullable(MXEXmlNode* _Nullable node, BOOL* _Nonnull success, NSError* _Nullable* _Nullable error) {
                *success = YES;
                if (!node) {
                    return nil;
                }
                if (![node isKindOfClass:MXEXmlNode.class]) {
                    setError(error, MXEErrorInvalidInputData,
                             [NSString stringWithFormat:@"Expected a %@, but got %@.", MXEXmlNode.class, node.class],
                             @{ MXEErrorInputDataKey : node });
                    *success = NO;
                    return nil;
                }
                return [node toDictionary];
            }
        reverseBlock:
            ^MXEXmlNode* _Nullable(NSDictionary* _Nullable dict, BOOL* _Nonnull success, NSError* _Nullable* _Nullable error) {
                *success = YES;
                if (!dict) {
                    return nil;
                }
                if (![dict isKindOfClass:NSDictionary.class]) {

                    setError(error, MXEErrorInvalidInputData,
                             [NSString stringWithFormat:@"Expected a %@, but got %@.", NSDictionary.class, dict.class],
                             @{ MXEErrorInputDataKey : dict });
                    *success = NO;
                    return nil;
                }
                return [[MXEXmlNode alloc] initWithElementName:@"dummy" fromDictionary:dict];
            }];
}

+ (NSValueTransformer<MTLTransformerErrorHandling>* _Nonnull)numberTransformer
{
    return [MTLValueTransformer
        transformerUsingForwardBlock:
            ^NSNumber* _Nullable(NSString* _Nullable str, BOOL* _Nonnull success, NSError* _Nullable* _Nullable error) {
                *success = YES;
                if (!str) {
                    return nil;
                }
                if (![str isKindOfClass:NSString.class]) {
                    setError(error, MXEErrorInvalidInputData,
                             [NSString stringWithFormat:@"Expected a %@, but got %@.", NSString.class, str.class],
                             @{ MXEErrorInputDataKey : str });
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

                if (match) {
                    if ([match rangeAtIndex:2].location != NSNotFound) {
                        return [NSNumber numberWithFloat:[str floatValue]];
                    } else if ([match rangeAtIndex:1].location != NSNotFound) {
                        return [NSNumber numberWithDouble:[str doubleValue]];
                    } else if ([match rangeAtIndex:0].location != NSNotFound) {
                        return [NSNumber numberWithInteger:[str integerValue]];
                    }
                }

                setError(error, MXEErrorInvalidInputData, @"Could not convert String to Number",
                         @{ MXEErrorInputDataKey : str });
                *success = NO;
                return nil;
            }
        reverseBlock:
            ^NSString* _Nullable(NSNumber* _Nullable value, BOOL* _Nonnull success, NSError* _Nullable* _Nullable error) {
                *success = YES;
                if (!value) {
                    return nil;
                }
                if (![value isKindOfClass:NSNumber.class]) {
                    setError(error, MXEErrorInvalidInputData,
                             [NSString stringWithFormat:@"Expected a %@, but got %@.", NSNumber.class, value.class],
                             @{ MXEErrorInputDataKey : value });
                    *success = NO;
                    return nil;
                }
                return [value stringValue];
            }];
}

+ (NSValueTransformer<MTLTransformerErrorHandling>* _Nonnull)boolTransformer
{
    return [MTLValueTransformer
        transformerUsingForwardBlock:
            ^NSNumber* _Nullable(NSString* _Nullable str, BOOL* _Nonnull success, NSError* _Nullable* _Nullable error) {
                *success = YES;
                if (!str) {
                    return nil;
                }
                if (![str isKindOfClass:NSString.class]) {
                    setError(error, MXEErrorInvalidInputData,
                             [NSString stringWithFormat:@"Expected a numeric string, but got %@", str.class],
                             @{ MXEErrorInputDataKey : str });
                    *success = NO;
                    return nil;
                }
                return [NSNumber numberWithBool:[str boolValue]];
            }
        reverseBlock:
            ^NSString* _Nullable(NSNumber* _Nullable value, BOOL* _Nonnull success, NSError* _Nullable* _Nullable error) {
                *success = YES;
                if (!value) {
                    return nil;
                }
                if (![value isKindOfClass:NSNumber.class]) {
                    setError(error, MXEErrorInvalidInputData,
                             [NSString stringWithFormat:@"Expected a %@, but got %@.", NSNumber.class, value.class],
                             @{ MXEErrorInputDataKey : value });
                    *success = NO;
                    return nil;
                }
                return [value integerValue] ? @"true" : @"false";
            }];
}

@end
