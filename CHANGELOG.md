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
- Support some primitive types and NSNumber with default transformer.

### Minor changes

- It changed MXEXmlNode to immutable and added MXEMutableXmlNode.
- MXEXmlPath that is base class has been deleted. Instead, MXEAccessible protocol was added.
