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

#import <objc/runtime.h>
#import <Mantle/NSValueTransformer+MTLPredefinedTransformerAdditions.h>
#import <Mantle/EXTRuntimeExtensions.h>
#import <Mantle/MTLValueTransformer.h>
#import <Mantle/MTLReflection.h>
#import <Mantle/EXTRuntimeExtensions.h>
#import <Mantle/EXTScope.h>
#import <Mantle/MTLTransformerErrorHandling.h>

#import "MXEXmlAdapter.h"
#import "NSError+MantleXMLExtension.h"
#import "MXEXmlAttributePath+Private.h"
#import "MXEXmlDuplicateNodesPath+Private.h"
#import "MXEXmlNode.h"

static void setError(NSError* _Nullable * _Nullable error, MXEErrorCode code)
{
    if (error) {
        *error = [NSError errorWithMXEErrorCode:code];
    }
}

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
@property (nonatomic, nonnull, strong) NSMutableArray<MXEXmlNode*>* xmlParseStack;
@property (nonatomic, nullable, strong) NSError* parseError;


- (id<MXEXmlSerializing> _Nullable) modelFromMXEXmlNode:(MXEXmlNode* _Nonnull)xmlNode
                                                  error:(NSError* _Nullable * _Nullable)error;

- (MXEXmlNode* _Nullable) MXEXmlNodeFromModel:(id<MXEXmlSerializing> _Nonnull)model
                                        error:(NSError* _Nullable * _Nullable)error;

/**
 * Get NSStringEncoding from xmlDeclaration.
 */
+ (NSStringEncoding) xmlDeclarationToEncoding:(NSString*)xmlDeclaration;
@end

@implementation MXEXmlAdapter

#pragma mark - Life cycle

- (instancetype _Nullable) init {
    NSAssert(NO, @"%@ MUST be initialized with initWithModelClass", self.class);
    return nil;
}

- (instancetype _Nullable) initWithModelClass:(Class<MXEXmlSerializing> _Nonnull)modelClass
{
    NSParameterAssert(modelClass != nil);

    if (self = [super init]) {
        self.modelClass = modelClass;
        self.xmlKeyPathsByPropertyKey = [modelClass xmlKeyPathsByPropertyKey];
        self.xmlParseStack = [NSMutableArray array];
        self.propertyKeys = [self.modelClass propertyKeys];

        for (NSString* key in self.xmlKeyPathsByPropertyKey) {
            NSAssert([self.propertyKeys containsObject:key], @"%@ is NOT a property of %@.", key, modelClass);

            id value = self.xmlKeyPathsByPropertyKey[key];
            NSAssert([value isKindOfClass:NSString.class]
                     || [value isKindOfClass:MXEXmlAttributePath.class]
                     || [value isKindOfClass:MXEXmlDuplicateNodesPath.class],
                    @"%@ MUST NSString or MXEXmlAttributePath or MXEXmlDuplicateNodesPath. But got %@", key, value);
        }
        self.valueTransformersByPropertyKey = [self.class valueTransformersForModelClass:modelClass];
    }
    return self;
}

#pragma mark - Conversion between XML and Model

+ (id<MXEXmlSerializing> _Nullable) modelOfClass:(Class<MXEXmlSerializing> _Nonnull)modelClass
                                     fromXmlData:(NSData* _Nullable)xmlData
                                           error:(NSError* _Nullable * _Nullable)error
{
    NSParameterAssert(modelClass != nil);

    if (!xmlData) {
        setError(error, MXEErrorNil);
        return nil;
    }
    MXEXmlAdapter *adapter = [[self alloc] initWithModelClass:modelClass];
    return [adapter modelFromXmlData:xmlData error:error];
}

+ (NSData* _Nullable) xmlDataFromModel:(id<MXEXmlSerializing> _Nullable)model
                                 error:(NSError* _Nullable * _Nullable)error
{
    if (!model) {
        setError(error, MXEErrorNil);
        return nil;
    }
    MXEXmlAdapter *adapter = [[self alloc] initWithModelClass:model.class];
    return [adapter xmlDataFromModel:model error:error];
}

- (id<MXEXmlSerializing> _Nullable) modelFromXmlData:(NSData* _Nullable)xmlData
                                               error:(NSError* _Nullable * _Nullable)error
{
    if (!xmlData) {
        setError(error, MXEErrorNil);
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
             @"Top level node MUST be specified element name (%@).", [self.modelClass xmlRootElementName]);
    return [self modelFromMXEXmlNode:root error:error];
}

- (NSData* _Nullable) xmlDataFromModel:(id<MXEXmlSerializing> _Nullable)model
                                 error:(NSError* _Nullable * _Nullable)error
{
    NSParameterAssert(model == nil || [model isKindOfClass:self.modelClass]);

    if (!model) {
        setError(error, MXEErrorNil);
        return nil;
    }

    if (self.modelClass != model.class) {
        return [self.class xmlDataFromModel:model error:error];
    }

    MXEXmlNode* root = [self MXEXmlNodeFromModel:model error:error];
    if (!root) {
        return nil;
    }

    NSString* xmlDeclaration = nil;
    if ([model.class respondsToSelector:@selector(xmlDeclaration)]) {
        xmlDeclaration = [model.class xmlDeclaration];
    } else {
        xmlDeclaration = MXEXmlDeclarationDefault;
    }
    NSString* responseStr = [NSString stringWithFormat:@"%@%@", xmlDeclaration, [root toString]];
    return [responseStr dataUsingEncoding:[self.class xmlDeclarationToEncoding:xmlDeclaration]];
}

#pragma mark - NSXMLParserDelegate

- (void) parser:(NSXMLParser*)parser
didStartElement:(NSString*)elementName
   namespaceURI:(NSString* _Nullable)namespaceURI
  qualifiedName:(NSString* _Nullable)qName
     attributes:(NSDictionary<NSString*, NSString*>*)attributeDict
{
    if (self.xmlParseStack.count == 0) {
        if (![[self.modelClass xmlRootElementName] isEqualToString:elementName]) {
            NSString* reason = [NSString stringWithFormat:@"Root node expect %@, but got %@",
                                [self.modelClass xmlRootElementName], elementName];
            self.parseError = [NSError errorWithMXEErrorCode:MXEErrorRootNodeInvalid
                                                      reason:reason];
            [parser abortParsing];
        }
    }
    MXEXmlNode* node = [[MXEXmlNode alloc] initWithElementName:elementName];
    if (node) {
        node.attributes  = attributeDict;
        [self.xmlParseStack addObject:node];
    }
}

- (void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    MXEXmlNode* node = [self.xmlParseStack lastObject];

    // NOTE: Ignore character string when child node and character string are mixed.
    if (!node.children) {
        node.children = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
}

- (void) parser:(NSXMLParser*)parser
  didEndElement:(NSString*)elementName
   namespaceURI:(NSString* _Nullable)namespaceURI
  qualifiedName:(NSString* _Nullable)qName
{
    if (self.xmlParseStack.count > 1) {
        MXEXmlNode* node = [self.xmlParseStack lastObject];
        [self.xmlParseStack removeLastObject];

        MXEXmlNode* parentNode = [self.xmlParseStack lastObject];
        if ([parentNode.children isKindOfClass:NSArray.class]) {
            [parentNode.children addObject:node];
        } else if (!parentNode.children || [parentNode.children isKindOfClass:NSString.class]) {
            // NOTE: Ignore character string when child node and character string are mixed.
            parentNode.children = [NSMutableArray array];
            [parentNode.children addObject:node];
        } else {
            NSAssert(NO, @"Children MUST be array of %@ or NSArray. But got %@", node.class, parentNode.children);
        }
    }
}

#pragma mark - Utility

+ (NSStringEncoding) xmlDeclarationToEncoding:(NSString*)xmlDeclaration
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

#pragma mark - License Github

- (id<MXEXmlSerializing> _Nullable) modelFromMXEXmlNode:(MXEXmlNode* _Nonnull)xmlNode
                                                  error:(NSError* _Nullable * _Nullable)error
{
    NSMutableDictionary* dictionaryValue = [NSMutableDictionary dictionary];

    for (NSString *propertyKey in [self.modelClass propertyKeys]) {
        id xmlKeyPaths = self.xmlKeyPathsByPropertyKey[propertyKey];

        if (!xmlKeyPaths) {
            continue;
        }

        id value = [xmlNode getChildForKeyPath:xmlKeyPaths];
        if (!value) {
            continue;
        }

        @try {
            NSValueTransformer *transformer = self.valueTransformersByPropertyKey[propertyKey];
            if (transformer != nil) {
                if ([transformer respondsToSelector:@selector(transformedValue:success:error:)]) {
                    id<MTLTransformerErrorHandling> errorHandlingTransformer = (id)transformer;

                    BOOL success;
                    value = [errorHandlingTransformer transformedValue:value success:&success error:error];
                    if (!success) {
                        return nil;
                    }
                } else {
                    value = [transformer transformedValue:value];
                }
            }
            dictionaryValue[propertyKey] = value;
        } @catch (NSException *ex) {

        }
    }
    id model = [self.modelClass modelWithDictionary:dictionaryValue error:error];
    return [model validate:error] ? model : nil;
}

- (MXEXmlNode* _Nullable) MXEXmlNodeFromModel:(id<MXEXmlSerializing> _Nonnull)model
                                        error:(NSError* _Nullable * _Nullable)error
{
    NSParameterAssert(model != nil);
    NSParameterAssert([model isKindOfClass:self.modelClass]);

    NSSet *propertyKeysToSerialize = [NSSet setWithArray:self.xmlKeyPathsByPropertyKey.allKeys];

    NSDictionary *dictionaryValue
        = [model.dictionaryValue dictionaryWithValuesForKeys:propertyKeysToSerialize.allObjects];
    MXEXmlNode* node = [[MXEXmlNode alloc] initWithElementName:[model.class xmlRootElementName]];

    __block BOOL success = YES;
    __block NSError *tmpError = nil;

    [dictionaryValue enumerateKeysAndObjectsUsingBlock:^(NSString *propertyKey, id value, BOOL *stop) {
        id xmlKeyPaths = self.xmlKeyPathsByPropertyKey[propertyKey];
        if (!xmlKeyPaths) {
            return;
        }

        NSValueTransformer *transformer = self.valueTransformersByPropertyKey[propertyKey];
        if ([transformer.class allowsReverseTransformation]) {
            if ([transformer respondsToSelector:@selector(reverseTransformedValue:success:error:)]) {
                id<MTLTransformerErrorHandling> errorHandlingTransformer = (id)transformer;

                value = [errorHandlingTransformer reverseTransformedValue:value success:&success error:&tmpError];

                if (!success) {
                    *stop = YES;
                    return;
                }
            } else {
                value = [transformer reverseTransformedValue:value];
            }
        }
        [node setChild:value forKeyPath:xmlKeyPaths];
    }];

    if (success) {
        return node;
    } else {
        if (error) {
            *error = tmpError;
        }
        return nil;
    }

}

+ (NSValueTransformer<MTLTransformerErrorHandling> *)dictionaryTransformerWithModelClass:(Class)modelClass {
    NSParameterAssert([modelClass conformsToProtocol:@protocol(MTLModel)]);
    NSParameterAssert([modelClass conformsToProtocol:@protocol(MXEXmlSerializing)]);
    __block MXEXmlAdapter *adapter;

    return [MTLValueTransformer
            transformerUsingForwardBlock:^ id (id xmlData, BOOL *success, NSError **error) {
                if (xmlData == nil) return nil;

                if (![xmlData isKindOfClass:NSData.class]) {
                    if (error != NULL) {
                        *error = [NSError errorWithMXEErrorCode:MXEErrorInputDataInvalid
                                                         reason:@""];
                    }
                    *success = NO;
                    return nil;
                }

                if (!adapter) {
                    adapter = [[self alloc] initWithModelClass:modelClass];
                }
                id model = [adapter modelFromXmlData:xmlData error:error];
                if (model == nil) {
                    *success = NO;
                }
                return model;
            }
            reverseBlock:^ NSData * (id model, BOOL *success, NSError **error) {
                if (model == nil) return nil;

                if (![model conformsToProtocol:@protocol(MTLModel)]
                    || ![model conformsToProtocol:@protocol(MXEXmlSerializing)]) {
                    if (error != NULL) {
                        *error = [NSError errorWithMXEErrorCode:MXEErrorInputDataInvalid
                                                         reason:@""];
                    }
                    *success = NO;
                    return nil;
                }

                if (!adapter) {
                    adapter = [[self alloc] initWithModelClass:modelClass];
                }
                NSData *result = [adapter xmlDataFromModel:model error:error];
                if (result == nil) {
                    *success = NO;
                }
                return result;
            }];
}

+ (NSDictionary *)valueTransformersForModelClass:(Class)modelClass {
    NSParameterAssert(modelClass != nil);
    NSParameterAssert([modelClass conformsToProtocol:@protocol(MXEXmlSerializing)]);

    NSMutableDictionary *result = [NSMutableDictionary dictionary];

    for (NSString *key in [modelClass propertyKeys]) {
        SEL selector = MTLSelectorWithKeyPattern(key, "XmlTransformer");
        if ([modelClass respondsToSelector:selector]) {
            IMP imp = [modelClass methodForSelector:selector];
            NSValueTransformer * (*function)(id, SEL) = (__typeof__(function))imp;
            NSValueTransformer *transformer = function(modelClass, selector);

            if (transformer != nil) result[key] = transformer;

            continue;
        }

        if ([modelClass respondsToSelector:@selector(xmlTransformerForKey:)]) {
            NSValueTransformer *transformer = [modelClass xmlTransformerForKey:key];

            if (transformer != nil) {
                result[key] = transformer;
                continue;
            }
        }

        objc_property_t property = class_getProperty(modelClass, key.UTF8String);

        if (property == NULL) continue;

        mtl_propertyAttributes *attributes = mtl_copyPropertyAttributes(property);
        @onExit {
            free(attributes);
        };

        NSValueTransformer *transformer = nil;

        if (*(attributes->type) == *(@encode(id))) {
            Class propertyClass = attributes->objectClass;

            if (propertyClass != nil) {
                transformer = [self transformerForModelPropertiesOfClass:propertyClass];
            }


            // For user-defined MTLModel, try parse it with dictionaryTransformer.
            if (nil == transformer && [propertyClass conformsToProtocol:@protocol(MXEXmlSerializing)]) {
                transformer = [self dictionaryTransformerWithModelClass:propertyClass];
            }

            if (transformer == nil) transformer = [NSValueTransformer mtl_validatingTransformerForClass:propertyClass ?: NSObject.class];
        } else {
            transformer = [self transformerForModelPropertiesOfObjCType:attributes->type] ?: [NSValueTransformer mtl_validatingTransformerForClass:NSValue.class];
        }

        if (transformer != nil) result[key] = transformer;
    }

    return result;
}

+ (NSValueTransformer *)transformerForModelPropertiesOfClass:(Class)modelClass {
    NSParameterAssert(modelClass != nil);

    SEL selector = MTLSelectorWithKeyPattern(NSStringFromClass(modelClass), "XmlTransformer");
    if (![self respondsToSelector:selector]) return nil;

    IMP imp = [self methodForSelector:selector];
    NSValueTransformer * (*function)(id, SEL) = (__typeof__(function))imp;
    NSValueTransformer *result = function(self, selector);

    return result;
}

+ (NSValueTransformer *)transformerForModelPropertiesOfObjCType:(const char *)objCType {
    NSParameterAssert(objCType != NULL);

    if (strcmp(objCType, @encode(BOOL)) == 0) {
        return [NSValueTransformer valueTransformerForName:MTLBooleanValueTransformerName];
    }

    return nil;
}

@end
