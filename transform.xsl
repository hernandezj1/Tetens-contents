<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei">

    <xsl:output method="html" indent="yes" />
    
    <xsl:template match="tei:pb">
        <div class="page" data-page="{@n}"></div>
    </xsl:template>


    <xsl:template match="/">
        <html>
            <head>
                <title>
                    <xsl:value-of select="//tei:title"/>
                </title>
                <style>
                    body {
                            display: flex;
                            margin: 0;
                        }

                        #text {
                            width: 50%;
                            height: 100vh;
                            overflow-y: auto;
                            scroll-padding-top: 0;
                        }

                        .page {
                            scroll-snap-align: start;
                            height: 100vh;
                            box-sizing: border-box;
                            border-top: 1px dashed #aaa;
                            padding: 2em;     
                        }

                        #pdf {
                            width: 50%;
                            height: 100vh;
                            border: none;
                        }
                    
                        .with-note {
                            border-bottom: 1px dotted #666;
                            cursor: help;
                        }
                    
                        .hidden-word {
                            position: absolute;
                            height: 0;
                            width: 0;
                            overflow: hidden;
                            white-space: nowrap;
                        }

                </style>
            </head>
            <body>
                <div id="text">
                    <xsl:apply-templates select="//tei:body"/>
                </div>
            </body>
        </html>
    </xsl:template>


    <!-- Paragraphs -->
    <xsl:template match="tei:p">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <!-- Line breaks -->
    <xsl:template match="tei:lb">
        <br/>
    </xsl:template>

    <!-- Emphasis -->
    <xsl:template match="tei:emph">
        <span style="font-weight: bold;">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <!-- Notes hover-->
    <xsl:template match="text()">
        <xsl:analyze-string select="." regex="(.*?)\[\[note: (.*?)\]\]">
            <xsl:matching-substring>
                <span class="with-note" title="{regex-group(2)}">
                    <xsl:value-of select="regex-group(1)"/>
                </span>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <!-- Uniting broken words through lines -->
    <xsl:template match="tei:lb">
        <xsl:choose>
            <!-- Checking if previous text has - "-" -->
            <xsl:when test="preceding-sibling::text()[last()][matches(., '-$')] and following-sibling::text()[1]">
                <!-- Constructing complete word -->
                <span class="hidden-word">
                    <xsl:value-of select="concat(
                    replace(preceding-sibling::text()[last()], '-$', ''), 
                    replace(following-sibling::text()[1], '^(\S+).*', '$1')
                )"/>
                </span>
                
                <br/>
            </xsl:when>
            
            <xsl:otherwise>
                <br/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- Fallback: pass through everything else -->
    <xsl:template match="text()|@*">
        <xsl:copy/>
    </xsl:template>

</xsl:stylesheet>
