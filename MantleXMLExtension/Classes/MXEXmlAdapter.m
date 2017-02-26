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
#import <Mantle/NSValueTransformer+MTLPredefinedTransformerAdditions.h>
#import <objc/runtime.h>

#import "MXEXmlAdapter.h"
#import "MXEXmlParser.h"
#import "NSError+MantleXMLExtension.h"

@interface MXEXmlAdapter ()

@property (nonatomic, nonnull, strong) Class modelClass;
/// A cached copy of the return value of +XmlKeyPathsByPropertyKey
@property (nonatomic, nonnull, copy) NSDictionary* xmlKeyPathsByPropertyKey;
/// A cached copy of the return value of +propertyKeys
@property (nonatomic, nonnull, copy) NSSet<NSString*>* propertyKeys;
/// A cached copy of the return value of -valueTransforersForModelClass:
@property (nonatomic, nonnull, copy) NSDictionary* valueTransformersByPropertyKey;

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
        self.propertyKeys = [self.modelClass propertyKeys];
        self.valueTransformersByPropertyKey = [self.class valueTransformersForModelClass:modelClass];

#if !defined(NS_BLOCK_ASSERTIONS)
        for (NSString* key in self.xmlKeyPathsByPropertyKey) {
            NSAssert([self.propertyKeys containsObject:key], @"%@ is NOT a property of %@.", key, modelClass);

            id paths = self.xmlKeyPathsByPropertyKey[key];
            if (![paths isKindOfClass:NSArray.class]) {
                paths = @[ paths ];
            }

            for (id singlePath in paths) {
                if (!([singlePath isKindOfClass:NSString.class]
                      || [singlePath conformsToProtocol:@protocol(MXEXmlAccessible)])) {
                    NSAssert(NO, @"%@ MUST NSString, id<MXEXmlAccessible> or NSArray. But got %@", key, singlePath);
                }
            }
        }
#endif
    }
    return self;
}

#pragma mark - Public Methods

#pragma mark Conversion between XML and Model (Class Methods)

+ (id _Nullable)modelOfClass:(Class _Nonnull)modelClass
                 fromXmlData:(NSData* _Nullable)xmlData
                       error:(NSError* _Nullable* _Nullable)error
{
    NSParameterAssert(modelClass != nil);

    if (!xmlData) {
        setError(error, MXEErrorNilInputData, nil);
        return nil;
    }
    MXEXmlAdapter* adapter = [[self alloc] initWithModelClass:modelClass];
    return [adapter modelFromXmlData:xmlData error:error];
}

+ (id _Nullable)modelOfClass:(Class _Nonnull)modelClass
                 fromXmlNode:(MXEXmlNode* _Nullable)rootXmlNode
                       error:(NSError* _Nullable* _Nullable)error
{
    NSParameterAssert(modelClass != nil);

    if (!rootXmlNode) {
        setError(error, MXEErrorNilInputData, nil);
        return nil;
    }
    MXEXmlAdapter* adapter = [[self alloc] initWithModelClass:modelClass];
    return [adapter modelFromXmlNode:rootXmlNode error:error];
}

+ (NSData* _Nullable)xmlDataFromModel:(id<MXEXmlSerializing> _Nullable)model
                                error:(NSError* _Nullable* _Nullable)error
{
    if (!model) {
        setError(error, MXEErrorNilInputData, nil);
        return nil;
    }
    MXEXmlAdapter* adapter = [[self alloc] initWithModelClass:model.class];
    return [adapter xmlDataFromModel:model error:error];
}

+ (MXEXmlNode* _Nullable)xmlNodeFromModel:(id<MXEXmlSerializing> _Nullable)model
                                    error:(NSError* _Nullable* _Nullable)error
{
    if (!model) {
        setError(error, MXEErrorNilInputData, nil);
        return nil;
    }
    MXEXmlAdapter* adapter = [[self alloc] initWithModelClass:model.class];
    return [adapter xmlNodeFromModel:model error:error];
}

#pragma mark Conversion between XML and Model (Instance Methods)

- (id _Nullable)modelFromXmlData:(NSData* _Nullable)xmlData
                           error:(NSError* _Nullable* _Nullable)error
{
    if (!xmlData) {
        setError(error, MXEErrorNilInputData, nil);
        return nil;
    }

    MXEXmlNode* rootNode = [MXEXmlParser xmlNodeWithData:xmlData error:error];
    if (!rootNode) {
        return nil;
    }
    return [self modelFromXmlNode:rootNode error:error];
}

- (NSData* _Nullable)xmlDataFromModel:(id<MXEXmlSerializing> _Nullable)model
                                error:(NSError* _Nullable* _Nullable)error
{
    NSParameterAssert(model == nil || [model isKindOfClass:self.modelClass]);

    if (!model) {
        setError(error, MXEErrorNilInputData, nil);
        return nil;
    }

    if (self.modelClass != model.class) {
        return [self.class xmlDataFromModel:model error:error];
    }

    MXEXmlNode* root = [self xmlNodeFromModel:model error:error];
    if (!root) {
        return nil;
    }

    if ([model.class respondsToSelector:@selector(xmlDeclaration)]) {
        NSString* xmlDeclaration = [model.class xmlDeclaration];
        return [MXEXmlParser dataWithXmlNode:root declaration:xmlDeclaration error:error];
    } else {
        return [MXEXmlParser dataWithXmlNode:root error:error];
    }
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

#pragma mark - License Github

- (id<MXEXmlSerializing> _Nullable)modelFromXmlNode:(MXEXmlNode* _Nullable)rootXmlNode
                                              error:(NSError* _Nullable* _Nullable)error
{
    if (!rootXmlNode) {
        setError(error, MXEErrorNilInputData, nil);
        return nil;
    }

    if (![[self.modelClass xmlRootElementName] isEqualToString:rootXmlNode.elementName]) {
        setError(error, MXEErrorElementNameDoesNotMatch,
                 @{ NSLocalizedFailureReasonErrorKey :
                        format(@"%@ expected elementName to be %@, but got %@",
                               self.modelClass, [self.modelClass xmlRootElementName], rootXmlNode.elementName) });
        return nil;
    }

    if ([self.modelClass respondsToSelector:@selector(classForParsingXmlNode:)]) {
        Class class = [self.modelClass classForParsingXmlNode:rootXmlNode];
        if (class == nil) {
            setError(error, MXEErrorNoConversionTarget,
                     @{ NSLocalizedFailureReasonErrorKey :
                            format(@"%@ # classForParsingXmlNode returns nil", self.modelClass) });
            return nil;
        }

        if (class != self.modelClass) {
            NSAssert([class conformsToProtocol:@protocol(MXEXmlSerializing)],
                     (format(@"classForParsingXmlNode MUST return MAEArraySerializing MTLModel class. but got %@", class)));

            MXEXmlAdapter* otherAdapter = [[self.class alloc] initWithModelClass:class];
            return [otherAdapter modelFromXmlNode:rootXmlNode error:error];
        }
    }

    NSMutableDictionary* dictionaryValue = [NSMutableDictionary dictionary];
    for (NSString* propertyKey in [self.modelClass propertyKeys]) {
        id xmlKeyPaths = self.xmlKeyPathsByPropertyKey[propertyKey];

        if (!xmlKeyPaths) {
            continue;
        }

        id value = nil;
        if ([xmlKeyPaths isKindOfClass:NSArray.class]) {
            MXEMutableXmlNode* currentXmlNode = [[MXEMutableXmlNode alloc] initWithElementName:rootXmlNode.elementName];
            for (id __strong singleXmlKeyPath in xmlKeyPaths) {
                if ([singleXmlKeyPath isKindOfClass:NSString.class]) {
                    singleXmlKeyPath = MXEXmlValue(singleXmlKeyPath);
                }
                id v = [rootXmlNode getForXmlPath:singleXmlKeyPath];
                if (v) {
                    [currentXmlNode setValue:v forXmlPath:singleXmlKeyPath];
                }
            }
            if (currentXmlNode.isEmpty) {
                continue;
            }
            value = currentXmlNode;
        } else {
            if ([xmlKeyPaths isKindOfClass:NSString.class]) {
                xmlKeyPaths = MXEXmlValue(xmlKeyPaths);
            }
            value = [rootXmlNode getForXmlPath:xmlKeyPaths];
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

- (MXEXmlNode* _Nullable)xmlNodeFromModel:(id<MXEXmlSerializing> _Nullable)model
                                    error:(NSError* _Nullable* _Nullable)error
{
    NSParameterAssert(model == nil || [model isKindOfClass:self.modelClass]);

    if (!model) {
        setError(error, MXEErrorNilInputData, nil);
        return nil;
    }

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

                value = [errorHandlingTransformer reverseTransformedValue:value success:&success error:error];
                if (!success) {
                    return nil;
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
                setError(error, MXEErrorInvalidInputData,
                         @{ NSLocalizedFailureReasonErrorKey :
                                format(@"input data expected MXEXmlNode, but got %@", [value class]) });
                return nil;
            }

            for (id __strong singleXmlPath in xmlKeyPaths) {
                if ([singleXmlPath isKindOfClass:NSString.class]) {
                    singleXmlPath = MXEXmlValue(singleXmlPath);
                }
                id v = [value getForXmlPath:singleXmlPath];
                if (v) {
                    [node setValue:v forXmlPath:singleXmlPath];
                }
            }
        } else {
            if ([xmlKeyPaths isKindOfClass:NSString.class]) {
                xmlKeyPaths = MXEXmlValue(xmlKeyPaths);
            }
            [node setValue:value forXmlPath:(id<MXEXmlAccessible>)xmlKeyPaths];
        }
    }

    return node;
}

+ (NSDictionary<NSString*, NSValueTransformer*>* _Nonnull)valueTransformersForModelClass:(Class _Nonnull)modelClass
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

            if (transformer != nil) {
                result[key] = transformer;
            }
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

        if (property == NULL) {
            continue;
        }

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

        if (transformer != nil) {
            result[key] = transformer;
        }
    }

    return result;
}

+ (NSValueTransformer* _Nullable)transformerForModelPropertiesOfClass:(Class _Nonnull)modelClass
{
    NSParameterAssert(modelClass != nil);

    SEL selector = MTLSelectorWithKeyPattern(NSStringFromClass(modelClass), "XmlTransformer");
    if (![self respondsToSelector:selector]) {
        return nil;
    }

    IMP imp = [self methodForSelector:selector];
    NSValueTransformer* (*function)(id, SEL) = (__typeof__(function))imp;
    NSValueTransformer* result = function(self, selector);

    return result;
}

+ (NSValueTransformer* _Nullable)transformerForModelPropertiesOfObjCType:(const char* _Nonnull)objCType
{
    NSParameterAssert(objCType != NULL);

    if (strcmp(objCType, @encode(NSInteger)) == 0
        || strcmp(objCType, @encode(NSUInteger)) == 0
        || strcmp(objCType, @encode(NSNumber)) == 0
        || strcmp(objCType, @encode(float)) == 0
        || strcmp(objCType, @encode(double)) == 0) {
        return [self.class numberTransformer];
    }
    if (strcmp(objCType, @encode(BOOL)) == 0) {
        return [self.class boolTransformer];
    }

    return nil;
}

@end
