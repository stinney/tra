<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:strip-space elements="q"/>
  <xsl:output method="text" encoding="UTF-8"/>
  <xsl:template match="p">
    <xsl:text>@(</xsl:text>
    <xsl:value-of select="@n"/>
    <xsl:text>=</xsl:text>
    <xsl:value-of select="@corresp"/>
    <xsl:text>) </xsl:text>
    <xsl:apply-templates/>
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>
  <xsl:template match="addSpan">
    <xsl:text>{</xsl:text>
  </xsl:template>
  <xsl:template match="anchor">
    <xsl:text>} </xsl:text>
  </xsl:template>
  <xsl:template match="ref">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="note">
    <xsl:variable name="targ" select="id(@target)"/>
    <xsl:value-of select="concat('@note',local-name($targ),'{')"/>
    <xsl:apply-templates/>
    <xsl:text>}</xsl:text>
  </xsl:template>
  <xsl:template match="w">
    <xsl:value-of select="concat('@w',@type,'{')"/>
    <xsl:apply-templates/>
    <xsl:text>}</xsl:text>
  </xsl:template>
  <xsl:template match="q">
    <xsl:text>@q</xsl:text>
    <xsl:if test="string-length(@who)>0 or string-length(@toWhom)>0">
      <xsl:value-of select="concat('[',@who,',',@toWhom,']')"/>
    </xsl:if>
    <xsl:text>{“</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>”}</xsl:text>
  </xsl:template>
  <xsl:template match="foreign">
    <xsl:value-of select="concat('@f',@lang,'{')"/>
    <xsl:apply-templates/>
    <xsl:text>}</xsl:text>
  </xsl:template>
  <xsl:template match="gap">
    <xsl:choose>
      <xsl:when test="count(preceding-sibling::*)=0">
	<xsl:text>&#xa;</xsl:text>
      </xsl:when>
      <xsl:when test="preceding-sibling::*[1][local-name()='q']">
	<xsl:text>&#xa;</xsl:text>
      </xsl:when>
    </xsl:choose>
    <xsl:value-of select="concat('$ (',@extent,')')"/>
  </xsl:template>
  <xsl:template match="head">
    <xsl:value-of select="concat('@h ', text(), '&#xa;')"/>
  </xsl:template>
  <xsl:template match="trailer">
    <xsl:text>#trailer </xsl:text>
    <xsl:value-of select="@place"/>
    <xsl:text>&#x9;</xsl:text>
    <xsl:value-of select="@type"/>
    <xsl:text>&#xa;&#xa;</xsl:text>
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="lg">
    <xsl:text>#lg </xsl:text>
    <xsl:value-of select="@n"/>
    <xsl:text>&#x9;</xsl:text>
    <xsl:value-of select="@type"/>
    <xsl:text>&#xa;&#xa;</xsl:text>
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="xref">
    <xsl:value-of select="concat('@xref[',@doc,',',@from,']{')"/>
    <xsl:apply-templates/>
    <xsl:text>}</xsl:text>
  </xsl:template>
  <xsl:template match="altGrp"/>
  <xsl:template match="TEI.2|teiHeader|text|group|body|div1">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="fileDesc|revisionDesc|linkGrp"/>
  <xsl:template match="*">
    <xsl:message>tra.xsl: unhandled element <xsl:value-of select="local-name(.)"/></xsl:message>
  </xsl:template>
</xsl:transform>
