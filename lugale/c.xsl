<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
	       xmlns:h="http://www/w3.org/1999/xhtml">
  <xsl:strip-space elements="*"/>
  <xsl:template match="a"><xsl:apply-templates/></xsl:template>
  <xsl:template match="*|text()">
    <xsl:copy>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
</xsl:transform>
