<!-- This XSL Stylesheet shows how to create an XML document. -->

<root xsl:version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:for-each select="breakfast_menu/food">
    <Item>
      <Name><xsl:value-of select="name"/></Name>
    </Item>
  </xsl:for-each>
</root>
