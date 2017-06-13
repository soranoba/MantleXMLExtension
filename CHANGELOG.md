## 1.1.0

### Additional functions

- `MXEXmlAdapter # trimingCharactersTransformerWithCharacterSet:`
- `MXEXmlAdapter # trimingCharactersTransformerWithDefaultCharacterSet`

### Minor changes

- `MXEXmlParser` has changed to **NOT** remove any characters from text nodes.

   If your API request or response contains spaces, CRs, LFs, and tabs at edge of the text node, **it become to incompatible**.  
   In order to get the same behavior as 1.0.x, you need to set the transformer to property of `NSString`.
   
   ```objc
   + (NSValueTransformer* _Nonnull)<key>XmlTransformer
   {
       return [MXEXmlAdapter trimingCharactersTransformerWithDefaultCharacterSet];
   }
   ```

## 1.0.3

### Bug fixes

- Fix to delete of "Ideographic-space" at edge.

## 1.0.2

### Bug fixes

- Fix that default transformer did not correspond to unsigned int.

## 1.0.1

### Bug fixes

- Fix to become warning when import `MXEXmlNode.h` on MRC.

## 1.0.0

### Major changes

- Some method names changed. Please fix your code according to compile error.

### Additional functions

- `MXEXmlNode` changed to public from private.
- It support to convert between `NSDictionary` and `MXEXmlNode`.
  (See: `MXEXmlNode # toDictionary` and `MXEXmlNode # initWithElementName:fromDictionary:`)
- New transformers has been added.
  (See: [MXEXmlAdapter+Transformers.m](MantleXMLExtension/Classes/MXEXmlAdapter+Transformers.m) )
- It become possible to judge a class from the structure of `MXEXmlNode`
  (See: `MXEXmlSerializing # classForParsingXmlNode:`)
- It become possible to separate that conversion to `MXEXmlNode` and conversion to model.
  (See: [MXEXmlParser](MantleXMLExtension/Classes/MXEXmlParser.h) )
- It support Carthage.
- Support some primitive types and `NSNumber` with default transformer.

### Minor changes

- It changed `MXEXmlNode` to immutable and added `MXEMutableXmlNode`.
- `MXEXmlPath` that is base class has been deleted. Instead, `MXEAccessible` protocol was added.
