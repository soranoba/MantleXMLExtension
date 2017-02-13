### 1.0.0  Stable Release

**HIGHLIGHT**
- The MXEXmlNode which was kept private has changed significantly. So, if you used it, your code to correct is necessary.
- The method name of MXEXmlXXXPath has been changed.If you are not using Short syntax, you need to modify it.
  It is perfectly compatible (that is, just the name has been changed), so you only change method name.

**Details**
- MXEXmlNode changed to public from private.
- It changed MXEXmlNode to immutable and added MXEMutableXmlNode.
- MXEXmlPath that is base class has been deleted. Instead, MXEAccessible protocol was added.
