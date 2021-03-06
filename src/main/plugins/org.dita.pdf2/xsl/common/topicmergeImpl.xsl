<?xml version="1.0" encoding="UTF-8" ?>

<!--
Copyright © 2004-2005 by Idiom Technologies, Inc. All rights reserved.
IDIOM is a registered trademark of Idiom Technologies, Inc. and WORLDSERVER
and WORLDSTART are trademarks of Idiom Technologies, Inc. All other
trademarks are the property of their respective owners.

IDIOM TECHNOLOGIES, INC. IS DELIVERING THE SOFTWARE "AS IS," WITH
ABSOLUTELY NO WARRANTIES WHATSOEVER, WHETHER EXPRESS OR IMPLIED,  AND IDIOM
TECHNOLOGIES, INC. DISCLAIMS ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING
BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE AND WARRANTY OF NON-INFRINGEMENT. IDIOM TECHNOLOGIES, INC. SHALL NOT
BE LIABLE FOR INDIRECT, INCIDENTAL, SPECIAL, COVER, PUNITIVE, EXEMPLARY,
RELIANCE, OR CONSEQUENTIAL DAMAGES (INCLUDING BUT NOT LIMITED TO LOSS OF
ANTICIPATED PROFIT), ARISING FROM ANY CAUSE UNDER OR RELATED TO  OR ARISING
OUT OF THE USE OF OR INABILITY TO USE THE SOFTWARE, EVEN IF IDIOM
TECHNOLOGIES, INC. HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.

Idiom Technologies, Inc. and its licensors shall not be liable for any
damages suffered by any person as a result of using and/or modifying the
Software or its derivatives. In no event shall Idiom Technologies, Inc.'s
liability for any damages hereunder exceed the amounts received by Idiom
Technologies, Inc. as a result of this transaction.

These terms and conditions supersede the terms and conditions in any
licensing agreement to the extent that such terms and conditions conflict
with those set forth herein.

This file is part of the DITA Open Toolkit project hosted on Sourceforge.net.
See the accompanying license.txt file for applicable licenses.
-->

<!-- An adaptation of the Toolkit topicmerge.xsl for FO plugin use. -->

<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:ot-placeholder="http://suite-sol.com/namespaces/ot-placeholder"
                exclude-result-prefixes="xs">

    <xsl:output indent="no"/>

    <xsl:key name="topic" match="dita-merge/*[contains(@class,' topic/topic ')]" use="concat('#',@id)"/>
    <xsl:key name="topic" match="dita-merge/dita" use="concat('#',*[contains(@class, ' topic/topic ')][1]/@id)"/>
    <xsl:key name="topicref" match="//*[contains(@class,' map/topicref ')]" use="generate-id()"/>

<!--
	<xsl:template match="/">
		<xsl:copy-of select="."/>
	</xsl:template>
-->

	<xsl:template match="dita-merge">
        <xsl:element name="{name(*[contains(@class,' map/map ')])}">
            <xsl:copy-of select="*[contains(@class,' map/map ')]/@*"/>
            <xsl:apply-templates select="*[contains(@class,' map/map ')]" mode="build-tree"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="dita-merge/*[contains(@class,' map/map ')]" mode="build-tree">
        <opentopic:map xmlns:opentopic="http://www.idiominc.com/opentopic">
            <xsl:apply-templates/>
        </opentopic:map>
        <xsl:apply-templates mode="build-tree"/>
    </xsl:template>

    <xsl:template match="*[contains(@class,' map/topicref ')]" mode="build-tree">
		<xsl:choose>
		    <xsl:when test="not(normalize-space(@first_topic_id) = '')">
		        <xsl:apply-templates select="key('topic',@first_topic_id)">				    
		            <xsl:with-param name="parentId" select="generate-id()"/>
		        </xsl:apply-templates>
		        <xsl:if test="@first_topic_id != @href">
    		        <xsl:apply-templates select="key('topic',@href)">				    
    		            <xsl:with-param name="parentId" select="generate-id()"/>
    		        </xsl:apply-templates>
		        </xsl:if>
		    </xsl:when>
			<xsl:when test="not(normalize-space(@href) = '')">
				<xsl:apply-templates select="key('topic',@href)">				    
					<xsl:with-param name="parentId" select="generate-id()"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="contains(@class, ' bookmap/part ') or
			                (normalize-space(@navtitle) != '' or *[contains(@class,' map/topicmeta ')]/*[contains(@class,' topic/navtitle ')])">
          <xsl:variable name="isNotTopicRef" as="xs:boolean">
              <xsl:call-template name="isNotTopicRef"/>
          </xsl:variable>
          <xsl:if test="not($isNotTopicRef)">
              <topic id="{generate-id()}" class="+ topic/topic pdf2-d/placeholder ">
                  <title class="- topic/title ">
                      <xsl:choose>
                          <xsl:when test="*[contains(@class,' map/topicmeta ')]/*[contains(@class,' topic/navtitle ')]">
                              <xsl:copy-of select="*[contains(@class,' map/topicmeta ')]/*[contains(@class,' topic/navtitle ')]/node()"/>
                          </xsl:when>
                          <xsl:when test="@navtitle">
                              <xsl:value-of select="@navtitle"/>
                          </xsl:when>
                      </xsl:choose>
                  </title>
                  <!--body class=" topic/body "/-->
                  <xsl:apply-templates mode="build-tree"/>
              </topic>
          </xsl:if>
			</xsl:when>
			<xsl:otherwise>
          <xsl:apply-templates mode="build-tree"/>
			</xsl:otherwise>
		</xsl:choose>
    </xsl:template>

    <xsl:template match="*[@print = 'no']" priority="5" mode="build-tree"/>

    <xsl:template match="*[contains(@class,' bookmap/backmatter ')] |
                         *[contains(@class,' bookmap/booklists ')] |
                         *[contains(@class,' bookmap/frontmatter ')]" priority="2" mode="build-tree">
        <xsl:apply-templates mode="build-tree"/>
    </xsl:template>

    <xsl:template match="*[contains(@class,' bookmap/toc ')][not(@href)]" priority="2" mode="build-tree">
        <ot-placeholder:toc id="{generate-id()}">
            <xsl:apply-templates mode="build-tree"/>
        </ot-placeholder:toc>
    </xsl:template>
  
    <xsl:template match="*[contains(@class,' bookmap/indexlist ')][not(@href)]" priority="2" mode="build-tree">
        <ot-placeholder:indexlist id="{generate-id()}">
            <xsl:apply-templates mode="build-tree"/>
        </ot-placeholder:indexlist>
    </xsl:template>
  
    <xsl:template match="*[contains(@class,' bookmap/glossarylist ')][not(@href)]" priority="2" mode="build-tree">
        <ot-placeholder:glossarylist id="{generate-id()}">
            <xsl:apply-templates mode="build-tree"/>
        </ot-placeholder:glossarylist>
    </xsl:template>
  
    <xsl:template match="*[contains(@class,' bookmap/tablelist ')][not(@href)]" priority="2" mode="build-tree">
        <ot-placeholder:tablelist id="{generate-id()}">
            <xsl:apply-templates mode="build-tree"/>
        </ot-placeholder:tablelist>
    </xsl:template>
  
    <xsl:template match="*[contains(@class,' bookmap/figurelist ')][not(@href)]" priority="2" mode="build-tree">
        <ot-placeholder:figurelist id="{generate-id()}">
            <xsl:apply-templates mode="build-tree"/>
        </ot-placeholder:figurelist>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' map/topicref ') and @print='no']" priority="6"/>
    <xsl:template match="*[contains(@class,' topic/topic ')] | dita-merge/dita">

        <xsl:param name="parentId"/>
      <xsl:variable name="idcount">
        <!--for-each is used to change context.  There's only one entry with a key of $parentId-->
        <xsl:for-each select="key('topicref',$parentId)">
          <xsl:value-of select="count(preceding::*[@href = current()/@href][not(ancestor::*[contains(@class, ' map/reltable ')])]) + count(ancestor::*[@href = current()/@href])"/>
        </xsl:for-each>
      </xsl:variable>
        <xsl:copy>
            <xsl:apply-templates select="@*[name() != 'id']"/>
            <xsl:variable name="new_id">
                <xsl:choose>
                    <xsl:when test="number($idcount) &gt; 0">
                        <xsl:value-of select="concat(@id,'_ssol',$idcount)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@id"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:attribute name="id">
              <xsl:value-of select="$new_id"/>
            </xsl:attribute>
            <xsl:apply-templates>
                <xsl:with-param name="newid" select="$new_id"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="key('topicref',$parentId)/*" mode="build-tree"/>
        </xsl:copy>
    </xsl:template>
    
  <!-- Linkless topicref or topichead -->
  <xsl:template match="*[contains(@class,' map/topicref ')][not(@href)]" priority="5">
    <xsl:param name="newid"/>
    <xsl:copy>
      <xsl:attribute name="id">
        <xsl:value-of select="generate-id()"/>
      </xsl:attribute>
      <xsl:apply-templates select="@*">
        <xsl:with-param name="newid" select="$newid"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="*|text()|processing-instruction()">
        <xsl:with-param name="newid" select="$newid"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
    
    <xsl:template match="*[contains(@class,' map/topicref ')]/@id" priority="5"/>

    <xsl:template match="@href">
        <xsl:param name="newid"/>
        <xsl:variable name="topic-rest">
            <xsl:value-of select="substring-after(., '#')"/>
        </xsl:variable>

        <xsl:variable name="topic-id">
            <xsl:value-of select="if (contains($topic-rest, '/')) then substring-before($topic-rest, '/') else $topic-rest"/>
        </xsl:variable>

        <xsl:variable name="element-id">
            <xsl:value-of select="substring-after($topic-rest, '/')"/>
        </xsl:variable>

        <xsl:attribute name="href">
        <xsl:choose>
            <xsl:when test="$element-id = '' or not(starts-with(., '#unique'))">
                <xsl:value-of select="."/>
            </xsl:when>
            <xsl:when test="ancestor::*[contains(@class, ' topic/topic ')][1]/@id = $topic-id">
                <xsl:text>#</xsl:text>
                <xsl:value-of select="$newid"/>
                <xsl:text>/</xsl:text>
                <xsl:value-of select="$newid"/>
                <xsl:text>_Connect_42_</xsl:text>
                <xsl:value-of select="$element-id"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat('#',$topic-id,'/',$topic-id,'_Connect_42_',$element-id)"/>
            </xsl:otherwise>
        </xsl:choose>
        
            
        </xsl:attribute>
    </xsl:template>

	<xsl:template match="*[contains(@class,' map/topicref ')]/@href">
        <xsl:copy-of select="."/>
        <xsl:attribute name="id">
            <xsl:variable name="fragmentId">
            <xsl:value-of select="substring-after(.,'#')"/>
            </xsl:variable>
            <xsl:variable name="idcount">
                <xsl:value-of select="count(../preceding::*[@href = current()][not(ancestor::*[contains(@class, ' map/reltable ')])]) + count(../ancestor::*[@href = current()])"/>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="$idcount &gt; 0">
                        <xsl:value-of select="concat($fragmentId,'_ssol',$idcount)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$fragmentId"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>


    <xsl:template match="*" mode="build-tree" priority="-1">
        <xsl:apply-templates mode="build-tree"/>
    </xsl:template>

    <xsl:template match="text()" mode="build-tree" priority="-1"/>

    <xsl:template match="*" priority="-1">
        <xsl:param name="newid"/>
        <xsl:copy>
            <xsl:apply-templates select="@*">
                <xsl:with-param name="newid" select="$newid"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="*|text()|processing-instruction()">
                <xsl:with-param name="newid" select="$newid"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="@*" priority="-1">
        <xsl:copy-of select="."/>
    </xsl:template>

    <xsl:template match="processing-instruction()" priority="-1">
        <xsl:copy-of select="."/>
    </xsl:template>

    <xsl:key name="duplicate-id"
             match="*[not(contains(@class, ' topic/topic '))]/@id"
             use="concat(ancestor::*[contains(@class, ' topic/topic ')][1]/@id, '|', .)"/>

    <xsl:template match="@id[not(parent::*[contains(@class, ' topic/topic ')])]">
        <xsl:param name="newid"/>
        <xsl:attribute name="id">
            <xsl:value-of select="$newid"/>
            <xsl:text>_Connect_42_</xsl:text>
            <xsl:value-of select="."/>
            <xsl:variable name="current-id" select="concat(ancestor::*[contains(@class, ' topic/topic ')][1]/@id, '|', .)"/>
            <xsl:if test="not(generate-id(.) = generate-id(key('duplicate-id', $current-id)[1]))">
                <xsl:text>_</xsl:text>
                <xsl:value-of select="generate-id()"/>
            </xsl:if>
        </xsl:attribute>
    </xsl:template>

	<xsl:template name="isNotTopicRef" as="xs:boolean">
	  <xsl:param name="class" select="@class"/>
		<xsl:sequence select="contains($class,' bookmap/abbrevlist ')
    			             or contains($class,' bookmap/amendments ')
    			             or contains($class,' bookmap/bookabstract ')
    			             or contains($class,' bookmap/booklist ')
    			             or contains($class,' bookmap/colophon ')
    			             or contains($class,' bookmap/dedication ')
    			             or contains($class,' bookmap/tablelist ')
    			             or contains($class,' bookmap/trademarklist ')
    			             or contains($class,' bookmap/figurelist ')"/>
	</xsl:template>

    <xsl:template match="*[contains(@class, ' map/reltable ')]" mode="build-tree"/>

</xsl:stylesheet>
