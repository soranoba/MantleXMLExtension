//
//  MXEXmlParser.m
//  MantleXMLExtension
//
//  Created by Hinagiku Soranoba on 2017/02/25.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MXEXmlParser.h"
#import "NSError+MantleXMLExtension.h"

NSString* _Nonnull const MXEXmlDeclarationDefault = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>";

@interface MXEXmlParser () <NSXMLParserDelegate>

/// A stack of MXEXmlNode to use when parsing XML.
/// First object is a top level node.
@property (nonatomic, nonnull, strong) NSMutableArray<MXEMutableXmlNode*>* xmlParseStack;

@end

@implementation MXEXmlParser

#pragma mark - Lifecycle

- (instancetype _Nonnull)init
{
    if (self = [super init]) {
        self.xmlParseStack = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Public Methods

+ (NSData* _Nonnull)dataWithXmlNode:(MXEXmlNode* _Nonnull)xmlNode
                              error:(NSError* _Nullable* _Nullable)error
{
    return [self dataWithXmlNode:xmlNode declaration:MXEXmlDeclarationDefault error:error];
}

+ (NSData* _Nonnull)dataWithXmlNode:(MXEXmlNode* _Nonnull)xmlNode
                        declaration:(NSString* _Nonnull)xmlDeclaration
                              error:(NSError* _Nullable* _Nullable)error
{
    NSStringEncoding encoding = [self xmlDeclarationToEncoding:xmlDeclaration error:error];
    NSString* xmlString = [xmlDeclaration stringByAppendingString:xmlNode.toString];
    return [xmlString dataUsingEncoding:encoding];
}

+ (MXEXmlNode* _Nullable)xmlNodeWithData:(NSData* _Nonnull)xmlData
                                   error:(NSError* _Nullable* _Nullable)error
{
    MXEXmlParser* xmlParser = [MXEXmlParser new];

    NSXMLParser* parser = [[NSXMLParser alloc] initWithData:xmlData];
    parser.delegate = xmlParser;

    if (![parser parse]) {
        if (error) {
            *error = parser.parserError;
        }
        return nil;
    }

    NSAssert(xmlParser.xmlParseStack.count == 1, @"The number of elements of xmlParseStack MUST be 1");
    return [xmlParser.xmlParseStack lastObject];
}

#pragma mark - Private Methods

/**
 * Get NSStringEncoding from xmlDeclaration.
 *
 * @param xmlDeclaration string of XML declaration
 * @param error
 * @return If the xmlDeclaration is invalid, it returns 0.
 *         Otherwise, it returns encoding setting written in XML declaration
 */
+ (NSStringEncoding)xmlDeclarationToEncoding:(NSString* _Nonnull)xmlDeclaration
                                       error:(NSError* _Nullable* _Nullable)error
{
    NSParameterAssert(xmlDeclaration != nil);

    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"\\<\\?xml(.*)\\?\\>"
                                                                           options:0
                                                                             error:nil];
    NSTextCheckingResult* match = [regex firstMatchInString:xmlDeclaration
                                                    options:0
                                                      range:NSMakeRange(0, xmlDeclaration.length)];
    if ([match numberOfRanges] < 2) {
        // NOTE: The xmlDeclaration is invalid declaration.
        setError(error, MXEErrorInvalidXmlDeclaration,
                 @{ NSLocalizedFailureReasonErrorKey : format(@"Xml declaration MUST has prefix '<?xml' and suffix '?>'"),
                    MXEErrorInputDataKey : xmlDeclaration });
        return 0;
    }

    NSRange declAttributeListRange = [match rangeAtIndex:1];
    regex = [NSRegularExpression regularExpressionWithPattern:@"encoding=[\"'](.*)[\"']"
                                                      options:NSRegularExpressionCaseInsensitive
                                                        error:nil];
    match = [regex firstMatchInString:xmlDeclaration
                              options:0
                                range:declAttributeListRange];

    if ([match numberOfRanges] < 2) {
        // NOTE: Encoding attribute is not exist. So, it returns default encoding.
        return NSUTF8StringEncoding;
    }

    NSString* encoding = [[xmlDeclaration substringWithRange:[match rangeAtIndex:1]] lowercaseString];

    if ([encoding isEqualToString:@"shift_jis"]) {
        return NSShiftJISStringEncoding;
    } else if ([encoding isEqualToString:@"euc-jp"]) {
        return NSJapaneseEUCStringEncoding;
    } else if ([encoding isEqualToString:@"utf-16"]) {
        return NSUTF16StringEncoding;
    } else if ([encoding isEqualToString:@"utf-8"]) {
        return NSUTF8StringEncoding;
    } else {
        setError(error, MXEErrorNotSupportedEncoding,
                 @{ NSLocalizedFailureReasonErrorKey :
                        format(@"The xml declaration is valid, but MantleXMLExtension does not support the encoding"),
                    MXEErrorInputDataKey : xmlDeclaration });
        return 0;
    }
}

#pragma mark - NSXMLParserDelegate

- (void)parserDidStartDocument:(NSXMLParser* _Nonnull)parser
{
    [self.xmlParseStack removeAllObjects];
}

- (void)parser:(NSXMLParser* _Nonnull)parser
    didStartElement:(NSString* _Nonnull)elementName
       namespaceURI:(NSString* _Nullable)namespaceURI
      qualifiedName:(NSString* _Nullable)qName
         attributes:(NSDictionary<NSString*, NSString*>* _Nonnull)attributeDict
{
    MXEMutableXmlNode* node = [[MXEMutableXmlNode alloc] initWithElementName:elementName
                                                                  attributes:attributeDict
                                                                       value:nil];
    [self.xmlParseStack addObject:node];
}

- (void)parser:(NSXMLParser* _Nonnull)parser foundCharacters:(NSString* _Nonnull)string
{
    MXEMutableXmlNode* node = [self.xmlParseStack lastObject];

    // NOTE: Ignore character string when child node and character string are mixed.
    if (!node.hasChildren) {
        node.value = node.value ? [node.value stringByAppendingString:string] : string;
    }
}

- (void)parser:(NSXMLParser* _Nonnull)parser
    didEndElement:(NSString* _Nonnull)elementName
     namespaceURI:(NSString* _Nullable)namespaceURI
    qualifiedName:(NSString* _Nullable)qName
{
    MXEMutableXmlNode* node = [self.xmlParseStack lastObject];
    if (!node.hasChildren) {
        node.value = [node.value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }

    if (self.xmlParseStack.count > 1) {
        [self.xmlParseStack removeLastObject];

        MXEMutableXmlNode* parentNode = [self.xmlParseStack lastObject];
        [parentNode addChild:node];
    }
}

@end
