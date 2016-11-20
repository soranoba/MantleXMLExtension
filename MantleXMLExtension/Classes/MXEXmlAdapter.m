//
//  MXEXmlAdapter.m
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2016/11/19.
//  Copyright © 2016年 Hinagiku Soranoba. All rights reserved.
//

#import <objc/runtime.h>
#import <Mantle/NSValueTransformer+MTLPredefinedTransformerAdditions.h>
#import <Mantle/EXTRuntimeExtensions.h>
#import <Mantle/MTLValueTransformer.h>
#import <Mantle/MTLReflection.h>

#import "MXEXmlAdapter.h"
#import "NSError+MantleXMLExtension.h"
#import "MXEXmlAttributePath+Private.h"
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
            if ([value isKindOfClass:NSArray.class]) {
                NSArray* pathFragments = (NSArray*)value;
                NSAssert(pathFragments.count, @"%@ MUST NOT empty key fragments.", key);
                for (id pathFragment in pathFragments) {
                    NSAssert([pathFragment isKindOfClass:NSString.class],
                             @"%@ MUST either map to a XML key path or a XML array of key paths. got: %@.", key, value);
                }
            } else {
                NSAssert([value isKindOfClass:NSString.class] || [value isKindOfClass:MXEXmlAttributePath.class],
                         @"%@ MUST either map to a XML key path or a XML array of key paths. got: %@.", key, value);
            }
        }
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

- (id<MXEXmlSerializing> _Nullable) modelFromMXEXmlNode:(MXEXmlNode* _Nonnull)xmlNode
                                                  error:(NSError* _Nullable * _Nullable)error
{
    return nil;
}

- (MXEXmlNode* _Nullable) MXEXmlNodeFromModel:(id<MXEXmlSerializing> _Nonnull)model
                                        error:(NSError* _Nullable * _Nullable)error
{
    return nil;
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
    node.attributes  = attributeDict;
    [self.xmlParseStack addObject:node];
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

@end
