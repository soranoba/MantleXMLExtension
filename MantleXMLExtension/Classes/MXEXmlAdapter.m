//
//  MXEXmlAdapter.m
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/19.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//
// This module uses portions of code from the https://github.com/Mantle/Mantle
// (Please refer to `#pragma mark - License Github`)
//
// ---
// Copyright (c) GitHub, Inc.
// All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
// documentation files (the "Software"), to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
// and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions
// of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
// THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

#import <Mantle/EXTRuntimeExtensions.h>
#import <Mantle/EXTScope.h>
#import <Mantle/MTLReflection.h>
#import <Mantle/MTLValueTransformer.h>
#import <Mantle/NSValueTransformer+MTLPredefinedTransformerAdditions.h>
#import <objc/runtime.h>

#import "MXEXmlAdapter.h"
#import "MXEXmlArrayPath+Private.h"
#import "MXEXmlAttributePath+Private.h"
#import "MXEXmlNode.h"
#import "NSError+MantleXMLExtension.h"

static void setError(NSError* _Nullable* _Nullable error, MXEErrorCode code, NSString* _Nullable reason)
{
    if (error) {
        if (reason) {
            *error = [NSError mxe_errorWithMXEErrorCode:code reason:reason];
        } else {
            *error = [NSError mxe_errorWithMXEErrorCode:code];
        }
    }
}

NSString* _Nonnull const MXEXmlDeclarationDefault = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>";

@interface MXEXmlAdapter () <NSXMLParserDelegate>

@property (nonatomic, nonnull, strong) Class<MXEXmlSerializing> modelClass;
/// A cached copy of the return value of +XmlKeyPathsByPropertyKey
@property (nonatomic, nonnull, copy) NSDictionary* xmlKeyPathsByPropertyKey;
/// A cached copy of the return value of +propertyKeys
@property (nonatomic, nonnull, copy) NSSet<NSString*>* propertyKeys;
/// A cached copy of the return value of -valueTransforersForModelClass:
@property (nonatomic, nonnull, copy) NSDictionary* valueTransformersByPropertyKey;

/// A stack of MXEXmlNode to use when parsing XML.
/// First object is a top level node.
@property (nonatomic, nonnull, strong) NSMutableArray<MXEMutableXmlNode*>* xmlParseStack;
/// It is user error that occurred during parse XML.
@property (nonatomic, nullable, strong) NSError* parseError;

@end

@implementation MXEXmlAdapter

#pragma mark - Lifecycle

- (instancetype _Nullable)init
{
    NSAssert(NO, @"%@ MUST be initialized with initWithModelClass", self.class);
    return nil;
}

- (instancetype _Nullable)initWithModelClass:(Class _Nonnull)modelClass
{
    NSParameterAssert(modelClass != nil);

    if (self = [super init]) {
        self.modelClass = modelClass;
        self.xmlKeyPathsByPropertyKey = [modelClass xmlKeyPathsByPropertyKey];
        self.xmlParseStack = [NSMutableArray array];
        self.propertyKeys = [self.modelClass propertyKeys];

        for (NSString* key in self.xmlKeyPathsByPropertyKey) {
            NSAssert([self.propertyKeys containsObject:key], @"%@ is NOT a property of %@.", key, modelClass);

            id paths = self.xmlKeyPathsByPropertyKey[key];
            if (![paths isKindOfClass:NSArray.class]) {
                paths = @[ paths ];
            }

            for (id singlePath in paths) {
                if (!([singlePath isKindOfClass:NSString.class] || [singlePath isKindOfClass:MXEXmlPath.class])) {
                    NSAssert(NO, @"%@ MUST NSString, MXEXmlPath or NSArray. But got %@", key, singlePath);
                }
            }
        }
        self.valueTransformersByPropertyKey = [self.class valueTransformersForModelClass:modelClass];
    }
    return self;
}

#pragma mark - Conversion between XML and Model

+ (id _Nullable)modelOfClass:(Class _Nonnull)modelClass
                 fromXmlData:(NSData* _Nullable)xmlData
                       error:(NSError* _Nullable* _Nullable)error
{
    if (!xmlData) {
        setError(error, MXEErrorNil, nil);
        return nil;
    }
    MXEXmlAdapter* adapter = [[self alloc] initWithModelClass:modelClass];
    return [adapter modelFromXmlData:xmlData error:error];
}

+ (NSData* _Nullable)xmlDataFromModel:(id<MXEXmlSerializing> _Nullable)model
                                error:(NSError* _Nullable* _Nullable)error
{
    if (!model) {
        setError(error, MXEErrorNil, nil);
        return nil;
    }
    MXEXmlAdapter* adapter = [[self alloc] initWithModelClass:model.class];
    return [adapter xmlDataFromModel:model error:error];
}

- (id _Nullable)modelFromXmlData:(NSData* _Nullable)xmlData
                           error:(NSError* _Nullable* _Nullable)error
{
    if (!xmlData) {
        setError(error, MXEErrorNil, nil);
        return nil;
    }

    NSXMLParser* parser = [[NSXMLParser alloc] initWithData:xmlData];
    parser.delegate = self;
    if (![parser parse]) {
        if (error) {
            if (parser.parserError.code == NSXMLParserDelegateAbortedParseError) {
                *error = self.parseError;
            } else {
                *error = parser.parserError;
            }
        }
        return nil;
    }

    NSAssert(self.xmlParseStack.count == 1, @"The number of elements of xmlParseStack MUST be 1");

    MXEXmlNode* root = [self.xmlParseStack lastObject];
    NSAssert([root.elementName isEqualToString:[self.modelClass xmlRootElementName]],
             @"Top level node MUST be specified element name (%@).",
             [self.modelClass xmlRootElementName]);

    return [self modelFromMXEXmlNode:root error:error];
}

- (NSData* _Nullable)xmlDataFromModel:(id<MXEXmlSerializing> _Nullable)model
                                error:(NSError* _Nullable* _Nullable)error
{
    NSParameterAssert(model == nil || [model isKindOfClass:self.modelClass]);

    if (!model) {
        setError(error, MXEErrorNil, nil);
        return nil;
    }

    if (self.modelClass != model.class) {
        return [self.class xmlDataFromModel:model error:error];
    }

    MXEXmlNode* root = [self MXEXmlNodeFromModel:model error:error];
    if (!root) {
        NSAssert(!error || *error, @"It is expected that there stored details of Error, but it is nil.");
        return nil;
    }

    NSString* xmlDeclaration = nil;
    if ([model.class respondsToSelector:@selector(xmlDeclaration)]) {
        xmlDeclaration = [model.class xmlDeclaration];
    } else {
        xmlDeclaration = MXEXmlDeclarationDefault;
    }

    NSString* responseStr = [xmlDeclaration stringByAppendingString:[root toString]];
    return [responseStr dataUsingEncoding:[self.class xmlDeclarationToEncoding:xmlDeclaration]];
}

#pragma mark - Transformer

+ (NSValueTransformer<MTLTransformerErrorHandling>* _Nonnull)numberStringTransformer
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

+ (NSValueTransformer<MTLTransformerErrorHandling>* _Nonnull)boolStringTransformer
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

+ (NSValueTransformer<MTLTransformerErrorHandling>* _Nonnull)
    xmlNodeArrayTransformerWithModelClass:(Class _Nonnull)modelClass
{
    NSParameterAssert([modelClass conformsToProtocol:@protocol(MTLModel)]);
    NSParameterAssert([modelClass conformsToProtocol:@protocol(MXEXmlSerializing)]);

    __block id<MTLTransformerErrorHandling> transformer = [self xmlNodeTransformerWithModelClass:modelClass];

    return [MTLValueTransformer
        transformerUsingForwardBlock:
            ^NSArray* _Nullable(id _Nullable xmlNodes, BOOL* _Nonnull success, NSError* _Nullable* _Nullable error) {

                if (!xmlNodes) {
                    return nil;
                }

                if (![xmlNodes isKindOfClass:NSArray.class]) {
                    setError(error, MXEErrorInvalidInputData,
                             [NSString stringWithFormat:@"Input data expected a array, but got %@.",
                                                        [xmlNodes class]]);
                    *success = NO;
                    return nil;
                }

                NSMutableArray* models = [NSMutableArray array];
                for (id xmlNode in (NSArray*)xmlNodes) {
                    id model = [transformer transformedValue:xmlNode success:success error:error];
                    if (!model) {
                        return nil;
                    }
                    [models addObject:model];
                }
                return models;
            }
        reverseBlock:
            ^NSArray* _Nullable(id _Nullable models, BOOL* _Nonnull success, NSError* _Nullable* _Nullable error) {

                if (!models) {
                    return nil;
                }

                if (![models isKindOfClass:NSArray.class]) {
                    setError(error, MXEErrorInvalidInputData,
                             [NSString stringWithFormat:@"Input data expected a array, but got %@.",
                                                        [models class]]);
                    *success = NO;
                    return nil;
                }

                NSMutableArray* xmlNodes = [NSMutableArray array];
                for (id model in models) {
                    id xmlNode = [transformer reverseTransformedValue:model success:success error:error];
                    if (!xmlNode) {
                        return nil;
                    }
                    [xmlNodes addObject:xmlNode];
                }
                return xmlNodes;
            }];
}

+ (NSValueTransformer<MTLTransformerErrorHandling>* _Nonnull)
    xmlNodeTransformerWithModelClass:(Class _Nonnull)modelClass
{
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
                id model = [adapter modelFromMXEXmlNode:xmlNode error:error];
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
                MXEXmlNode* result = [adapter MXEXmlNodeFromModel:model error:error];
                *success = result != nil;
                return result;
            }];
}

#pragma mark - Utility

/**
 * Sort according to orderedKey.
 */
+ (NSArray<NSString*>* _Nonnull)sortProperties:(NSArray<NSString*>*)propertyKeys
                                         order:(NSArray<NSString*>*)orderedKeys
{
    return [propertyKeys sortedArrayUsingComparator:^NSComparisonResult(NSString* obj1, NSString* obj2) {
        NSUInteger index1 = [orderedKeys indexOfObject:obj1];
        NSUInteger index2 = [orderedKeys indexOfObject:obj2];
        index1 = index1 == NSNotFound ? 0 : index1 + 1;
        index2 = index2 == NSNotFound ? 0 : index2 + 1;
        if (index1 < index2) {
            return NSOrderedAscending;
        } else if (index1 == index2) {
            return NSOrderedSame;
        } else {
            return NSOrderedDescending;
        }
    }];
}

/**
 * Get NSStringEncoding from xmlDeclaration.
 *
 * @param xmlDeclaration string of XML declaration
 * @return Encoding setting written in XML declaration
 */
+ (NSStringEncoding)xmlDeclarationToEncoding:(NSString*)xmlDeclaration
{
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"encoding=[\"'](.*)[\"']"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    NSTextCheckingResult* match = [regex firstMatchInString:xmlDeclaration
                                                    options:0
                                                      range:NSMakeRange(0, xmlDeclaration.length)];

    NSRange range = [match rangeAtIndex:1];
    NSString* encoding = [[xmlDeclaration substringWithRange:range] lowercaseString];

    if ([encoding isEqualToString:@"shift_jis"]) {
        return NSShiftJISStringEncoding;
    } else if ([encoding isEqualToString:@"euc-jp"]) {
        return NSJapaneseEUCStringEncoding;
    } else if ([encoding isEqualToString:@"utf-16"]) {
        return NSUTF16StringEncoding;
    } else {
        return NSUTF8StringEncoding; // default.
    }
}

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser*)parser
    didStartElement:(NSString*)elementName
       namespaceURI:(NSString* _Nullable)namespaceURI
      qualifiedName:(NSString* _Nullable)qName
         attributes:(NSDictionary<NSString*, NSString*>*)attributeDict
{
    if (self.xmlParseStack.count == 0) {
        if (![[self.modelClass xmlRootElementName] isEqualToString:elementName]) {
            NSString* reason = [NSString stringWithFormat:@"Root node expect %@, but got %@",
                                                          [self.modelClass xmlRootElementName], elementName];
            self.parseError = [NSError mxe_errorWithMXEErrorCode:MXEErrorInvalidRootNode
                                                          reason:reason];
            [parser abortParsing];
        }
    }
    MXEMutableXmlNode* node = [[MXEMutableXmlNode alloc] initWithElementName:elementName];
    if (node) {
        node.attributes = [attributeDict mutableCopy];
        [self.xmlParseStack addObject:node];
    }
}

- (void)parser:(NSXMLParser*)parser foundCharacters:(NSString*)string
{
    MXEMutableXmlNode* node = [self.xmlParseStack lastObject];

    // NOTE: Ignore character string when child node and character string are mixed.
    if (!node.hasChildren) {
        node.value = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
}

- (void)parser:(NSXMLParser*)parser
    didEndElement:(NSString*)elementName
     namespaceURI:(NSString* _Nullable)namespaceURI
    qualifiedName:(NSString* _Nullable)qName
{
    if (self.xmlParseStack.count > 1) {
        MXEMutableXmlNode* node = [self.xmlParseStack lastObject];
        [self.xmlParseStack removeLastObject];

        MXEMutableXmlNode* parentNode = [self.xmlParseStack lastObject];
        if ([parentNode.children isKindOfClass:NSArray.class]) {
            [parentNode.children addObject:node];
        } else if (!parentNode.children || [parentNode.children isKindOfClass:NSString.class]) {
            // NOTE: Ignore character string when child node and character string are mixed.
            parentNode.children = [NSMutableArray array];
            [parentNode.children addObject:node];
        } else {
            NSAssert(NO, @"Children MUST be array of %@ or NSArray. But got %@", MXEXmlNode.class, parentNode.children);
        }
    }
}

#pragma mark - License Github

- (id<MXEXmlSerializing> _Nullable)modelFromMXEXmlNode:(MXEXmlNode* _Nonnull)topXmlNode
                                                 error:(NSError* _Nullable* _Nullable)error
{
    NSMutableDictionary* dictionaryValue = [NSMutableDictionary dictionary];

    for (NSString* propertyKey in [self.modelClass propertyKeys]) {
        id xmlKeyPaths = self.xmlKeyPathsByPropertyKey[propertyKey];

        if (!xmlKeyPaths) {
            continue;
        }

        id value = nil;
        if ([xmlKeyPaths isKindOfClass:NSArray.class]) {
            MXEMutableXmlNode* currentXmlNode = [[MXEMutableXmlNode alloc] initWithElementName:topXmlNode.elementName];
            for (id __strong singleXmlKeyPath in xmlKeyPaths) {
                if (![singleXmlKeyPath isKindOfClass:MXEXmlPath.class]) {
                    singleXmlKeyPath = [MXEXmlPath pathWithNodePath:singleXmlKeyPath];
                }
                id v = [topXmlNode getForXmlPath:singleXmlKeyPath];
                if (v) {
                    [currentXmlNode setValue:v forXmlPath:singleXmlKeyPath];
                }
            }
            if (currentXmlNode.isEmpty) {
                continue;
            }
            value = currentXmlNode;
        } else {
            if (![xmlKeyPaths isKindOfClass:MXEXmlPath.class]) {
                xmlKeyPaths = [MXEXmlPath pathWithNodePath:xmlKeyPaths];
            }
            value = [topXmlNode getForXmlPath:xmlKeyPaths];
            if (!value) {
                continue;
            }
        }

        @try {
            NSValueTransformer* transformer = self.valueTransformersByPropertyKey[propertyKey];
            if (transformer != nil) {
                if ([transformer respondsToSelector:@selector(transformedValue:success:error:)]) {
                    id<MTLTransformerErrorHandling> errorHandlingTransformer = (id)transformer;

                    BOOL success = YES;
                    value = [errorHandlingTransformer transformedValue:value success:&success error:error];
                    if (!success) {
                        return nil;
                    }
                } else {
                    value = [transformer transformedValue:value];
                }
            }
            dictionaryValue[propertyKey] = value;
        } @catch (NSException* ex) {
        }
    }
    id model = [self.modelClass modelWithDictionary:dictionaryValue error:error];
    return [model validate:error] ? model : nil;
}

- (MXEXmlNode* _Nullable)MXEXmlNodeFromModel:(id<MXEXmlSerializing> _Nonnull)model
                                       error:(NSError* _Nullable* _Nullable)error
{
    NSParameterAssert(model != nil);
    NSParameterAssert([model isKindOfClass:self.modelClass]);

    NSArray* order;
    if ([model.class respondsToSelector:@selector(xmlChildNodeOrder)]) {
        order = [model.class xmlChildNodeOrder];
    } else {
        order = [NSArray array];
    }
    NSArray* orderedPropertyKeys = [self.class sortProperties:self.xmlKeyPathsByPropertyKey.allKeys
                                                        order:order];

    NSDictionary* dictionaryValue = [model.dictionaryValue dictionaryWithValuesForKeys:orderedPropertyKeys];
    MXEMutableXmlNode* node = [[MXEMutableXmlNode alloc] initWithElementName:[model.class xmlRootElementName]];

    BOOL success = YES;
    NSError* tmpError = nil;

    for (NSString* propertyKey in orderedPropertyKeys) {
        id value = dictionaryValue[propertyKey];

        if ([value isEqual:NSNull.null]) {
            value = nil;
        }

        id xmlKeyPaths = self.xmlKeyPathsByPropertyKey[propertyKey];
        if (!xmlKeyPaths) {
            continue;
        }

        NSValueTransformer* transformer = self.valueTransformersByPropertyKey[propertyKey];
        if ([transformer.class allowsReverseTransformation]) {
            if ([transformer respondsToSelector:@selector(reverseTransformedValue:success:error:)]) {
                id<MTLTransformerErrorHandling> errorHandlingTransformer = (id)transformer;

                value = [errorHandlingTransformer reverseTransformedValue:value success:&success error:&tmpError];

                if (!success) {
                    break;
                }
            } else {
                value = [transformer reverseTransformedValue:value];
            }
        }

        if (!value) {
            continue;
        }

        if ([xmlKeyPaths isKindOfClass:NSArray.class]) {
            if (![value isKindOfClass:MXEXmlNode.class]) {
                success = NO;
                tmpError = [NSError mxe_errorWithMXEErrorCode:MXEErrorInvalidInputData
                                                       reason:[NSString stringWithFormat:@"input data expected MXEXmlNode, but got %@",
                                                                                         [value class]]];
                break;
            }

            for (id __strong singleXmlPath in xmlKeyPaths) {
                if (![singleXmlPath isKindOfClass:MXEXmlPath.class]) {
                    singleXmlPath = [MXEXmlPath pathWithNodePath:singleXmlPath];
                }
                id v = [value getForXmlPath:singleXmlPath];
                if (v) {
                    [node setValue:v forXmlPath:singleXmlPath];
                }
            }
        } else {
            if (![xmlKeyPaths isKindOfClass:MXEXmlPath.class]) {
                xmlKeyPaths = [MXEXmlPath pathWithNodePath:xmlKeyPaths];
            }
            [node setValue:value forXmlPath:(MXEXmlPath*)xmlKeyPaths];
        }
    }

    if (success) {
        return node;
    } else {
        if (error) {
            *error = tmpError;
        }
        return nil;
    }
}

+ (NSDictionary*)valueTransformersForModelClass:(Class)modelClass
{
    NSParameterAssert(modelClass != nil);
    NSParameterAssert([modelClass conformsToProtocol:@protocol(MXEXmlSerializing)]);

    NSMutableDictionary* result = [NSMutableDictionary dictionary];

    for (NSString* key in [modelClass propertyKeys]) {
        SEL selector = MTLSelectorWithKeyPattern(key, "XmlTransformer");
        if ([modelClass respondsToSelector:selector]) {
            IMP imp = [modelClass methodForSelector:selector];
            NSValueTransformer* (*function)(id, SEL) = (__typeof__(function))imp;
            NSValueTransformer* transformer = function(modelClass, selector);

            if (transformer != nil)
                result[key] = transformer;

            continue;
        }

        if ([modelClass respondsToSelector:@selector(xmlTransformerForKey:)]) {
            NSValueTransformer* transformer = [modelClass xmlTransformerForKey:key];

            if (transformer != nil) {
                result[key] = transformer;
                continue;
            }
        }

        objc_property_t property = class_getProperty(modelClass, key.UTF8String);

        if (property == NULL)
            continue;

        mtl_propertyAttributes* attributes = mtl_copyPropertyAttributes(property);
        @onExit
        {
            free(attributes);
        };

        NSValueTransformer* transformer = nil;

        if (*(attributes->type) == *(@encode(id))) {
            Class propertyClass = attributes->objectClass;

            if (propertyClass != nil) {
                transformer = [self transformerForModelPropertiesOfClass:propertyClass];
            }

            // For user-defined MTLModel, try parse it with xmlNodeTransformer.
            if (!transformer && [propertyClass conformsToProtocol:@protocol(MXEXmlSerializing)]) {
                transformer = [self xmlNodeTransformerWithModelClass:propertyClass];
            }

            if (transformer == nil) {
                transformer = [NSValueTransformer mtl_validatingTransformerForClass:propertyClass ?: NSObject.class];
            }
        } else {
            transformer = [self transformerForModelPropertiesOfObjCType:attributes->type] ?: [NSValueTransformer mtl_validatingTransformerForClass:NSValue.class];
        }

        if (transformer != nil)
            result[key] = transformer;
    }

    return result;
}

+ (NSValueTransformer*)transformerForModelPropertiesOfClass:(Class)modelClass
{
    NSParameterAssert(modelClass != nil);

    SEL selector = MTLSelectorWithKeyPattern(NSStringFromClass(modelClass), "XmlTransformer");
    if (![self respondsToSelector:selector])
        return nil;

    IMP imp = [self methodForSelector:selector];
    NSValueTransformer* (*function)(id, SEL) = (__typeof__(function))imp;
    NSValueTransformer* result = function(self, selector);

    return result;
}

+ (NSValueTransformer*)transformerForModelPropertiesOfObjCType:(const char*)objCType
{
    NSParameterAssert(objCType != NULL);

    if (strcmp(objCType, @encode(NSInteger)) == 0
        || strcmp(objCType, @encode(NSUInteger)) == 0
        || strcmp(objCType, @encode(NSNumber)) == 0
        || strcmp(objCType, @encode(float)) == 0
        || strcmp(objCType, @encode(double)) == 0) {
        return [self.class numberStringTransformer];
    }
    if (strcmp(objCType, @encode(BOOL)) == 0) {
        return [self.class boolStringTransformer];
    }

    return nil;
}

@end
