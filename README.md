MantleXMLExtension
=======
[![CI Status](http://img.shields.io/travis/soranoba/MantleXMLExtension.svg?style=flat)](https://travis-ci.org/soranoba/MantleXMLExtension)
[![Version](https://img.shields.io/cocoapods/v/MantleXMLExtension.svg?style=flat)](http://cocoapods.org/pods/MantleXMLExtension)
[![License](https://img.shields.io/cocoapods/l/MantleXMLExtension.svg?style=flat)](http://cocoapods.org/pods/MantleXMLExtension)
[![Platform](https://img.shields.io/cocoapods/p/MantleXMLExtension.svg?style=flat)](http://cocoapods.org/pods/MantleXMLExtension)

MantleXMLExtension support mutual conversion between Model object and XML with Mantle.

## Overview

Mantle support the Json, but doesn't support XML.

This application is an extension for handling xml with Mantle.

- Support these
 - Attributes
 - Child nodes, Nested child nodes, Array of child nodes
 - Customizable order of child nodes
 - Customizable XML declaration
 - Customizable transformer

### What is Mantle ?
Model framework for Cocoa and Cocoa Touch

- [Mantle](https://github.com/Mantle/Mantle)

## Installation

MantleXMLExtension is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'MantleXMLExtension'
```

## How to use functions of MantleXMLExtension

### Conversion between Model object and XML

```objc
// XML to Model
id<MTLModel> model = [MXEXmlAdapter modelOfClass:model.class
                                     fromXmlData:xmlData
                                           error:&error];

// Model to XML
NSData* data = [MXEXmlAdapter xmlDataFromModel:model error:&error];
```

### Model definition

Just add some to [MTLModel](https://github.com/Mantle/Mantle#mtlmodel) for MXEXmlAdapter.

```objc
#pragma mark - MXEXmlSerializing

+ (NSDictionary<NSString*, id>* _Nonnull)xmlKeyPathsByPropertyKey
{
    return @{ @"status" : MXEXmlAttribute(@"", @"status"),
              @"userCount" : @"summary.count",
              @"users" : MXEXmlArray(@"", MXEXmlChildNode(@"user")) };
}

+ (NSString* _Nonnull)xmlRootElementName
{
    return @"response";
}
```

### Path type

MXEXmlAdapter support 5 types of paths.

**MXEXmlPath**

For example:

```
<parent>
  <child>value</child>
</parent>
```

```objc
@"parent.child"
```

If you get `value`, please use this. Value doesn't support MXEXmlSerializing object.

**MXEAttributePath**

For example:

```
<parent>
  <child key="value" />
</parent>
```

```objc
MXEXmlAttribute(@"parent.child", @"key")
```

If you get value of specified attribute, please use this.

**MXEChildNodePath**

For example:

```
<parent>
  <child>
    <id>1</id>
    <name>Alice</name>
  </child>
</parent>
```

```objc
MXEXmlChildNode(@"parent.child")
```

If you get nested MXEXmlSerializing object, please use this. This path only support MXEXmlSerializing object.

**MXEArrayPath**

For example:

```
<parent>
  <children>
    <child>...</child>
    <child>...</child>
    <child>...</child>
  </children>
</parent>
```

```objc
MXEXmlArray(@"parent.children", MXEXmlChildNode(@"child"))
```

If you get array of value, please use this. This path can be used in combination with other path.

If you use this, you **MUST** use `MXEXmlAdapter # xmlNodeArrayTransformerWithModelClass:`.


```objc
+ (NSValueTransformer* _Nonnull)childrenXmlTransformer
{
    return [MXEXmlAdapter xmlNodeArrayTransformerWithModelClass:ChildModel.class];
}
```

**Multiple elements of XML**

For example:

```
<parent>
  <element_a>....</element_a>
  <element_b title=\"....\" />
</parent>
```

```objc
@[@"parent.element_a", MXEXmlAttribute(@"parent.element_b", @"title")]
```

It is used when you want to transfer multiple elements of XML to another model.
Please notice that root element of XML does not change.

### Transformer
You can use these transformer for MXEXmlSerializing object.

- `MXEXmlAdapter # xmlNodeArrayTransformerWithModelClass:`
- `MXEXmlAdapter # xmlNodeTransformerWithModelClass:`
- `MXEXmlAdapter # mappingDictionaryTransformerWithKeyPath:valuePath:`

You can use these transformer for primitive type.

- `MXEXmlAdapter # numberTransformer`
- `MXEXmlAdapter # boolTransformer`

### Other information

Please refer to documentation, [unit tests](MantleXMLExtensionTests) and [Mantle](https://github.com/Mantle/Mantle).

## Contribute

Pull request is welcome =D

## License

[MIT License](LICENSE)

