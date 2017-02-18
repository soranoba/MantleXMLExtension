## 1.0.0  Stable Release

### Major changes

- Some method names changed. Please fix your code according to compile error.

### Additional functions

- MXEXmlNode changed to public from private.
- It support to convert between NSDictionary and MXEXmlNode.
  (See: MXEXmlNode # toDictionary and MXEXmlNode # initWithElementName:fromDictionary:)
- New transformers has been added.

### Minor changes

- It changed MXEXmlNode to immutable and added MXEMutableXmlNode.
- MXEXmlPath that is base class has been deleted. Instead, MXEAccessible protocol was added.
