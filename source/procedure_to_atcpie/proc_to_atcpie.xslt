<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method='text'/>
    <xsl:template match="/">
        <xsl:text># files for atc-pie, minimum version is 1.8.8</xsl:text><xsl:text>&#xd;</xsl:text>
        <xsl:text># ------------------------------------------------</xsl:text><xsl:text>&#xd;</xsl:text>
        <!-- get the distinct runway numbers by distincting the STARs-->
        <xsl:for-each select="/ProceduresDB/Airport/Star[not(@Runways=preceding-sibling::Star/@Runways)]/@Runways">
            <xsl:text># Runway: </xsl:text><xsl:value-of select="current()"/><xsl:text>&#xd;</xsl:text>

            <xsl:text># ------------------------------------------------</xsl:text><xsl:text>&#xd;</xsl:text>
            <xsl:text># APPROACHES </xsl:text><xsl:text>&#xd;</xsl:text>
            <xsl:text># ------------------------------------------------</xsl:text><xsl:text>&#xd;</xsl:text>

            <xsl:for-each select="/ProceduresDB/Airport/Approach[substring(@Name,4,2)=current()]">
                <xsl:text># ------------------------------------------------</xsl:text><xsl:text>&#xd;</xsl:text>
                <xsl:text># APPROACH: START</xsl:text><xsl:text>&#xd;</xsl:text>
                <xsl:text># APPROACH Name: </xsl:text><xsl:value-of select="@Name"/><xsl:text>&#xd;</xsl:text>
                <xsl:text># APPROACH Runway number: </xsl:text><xsl:value-of select="substring(@Name,4,2)"/><xsl:text>&#xd;</xsl:text>
                <xsl:text>YELLOW</xsl:text><xsl:text>&#xd;</xsl:text>
                <!-- first to generate the lines -->
                <xsl:for-each select="App_Waypoint">
                    <xsl:value-of select="Latitude"/><xsl:text>,</xsl:text><xsl:value-of select="Longitude"/>
                    <xsl:text> </xsl:text>
                    <xsl:text># </xsl:text><xsl:value-of select="Name"/><xsl:text>&#xd;</xsl:text>
                    <xsl:if test="not(position() = last())">
                        <xsl:text>:label </xsl:text>
                        <xsl:value-of select="following-sibling::App_Waypoint[1]/Altitude"/>
                        <xsl:text>&#xd;</xsl:text>
                    </xsl:if>
                </xsl:for-each>
                <!-- next to generate the point x-marks  -->
                <xsl:for-each select="App_Waypoint">
                    <xsl:text>&#xd;</xsl:text>
                    <xsl:text>Chartreuse</xsl:text><xsl:text>&#xd;</xsl:text>
                    <xsl:value-of select="Latitude"/><xsl:text>,</xsl:text><xsl:value-of select="Longitude"/>
                    <xsl:text> </xsl:text>
                    <xsl:text>#  </xsl:text><xsl:value-of select="Name"/>
                    <xsl:text>&#xd;</xsl:text>
                </xsl:for-each>

                <!-- next to generate the point names offset to the top and left  -->
                <xsl:for-each select="App_Waypoint">
                    <xsl:text>&#xd;</xsl:text>
                    <xsl:text>Chartreuse</xsl:text><xsl:text>&#xd;</xsl:text>
                    <xsl:value-of select="Latitude"/><xsl:text>,</xsl:text><xsl:value-of select="Longitude"/><xsl:text>&gt;315,0.1</xsl:text><xsl:text>&#xd;</xsl:text>
                    <xsl:text>:label </xsl:text><xsl:value-of select="Name"/><xsl:text>&#xd;</xsl:text>
                    <xsl:value-of select="Latitude"/><xsl:text>,</xsl:text><xsl:value-of select="Longitude"/><xsl:text>&gt;315,0.1</xsl:text><xsl:text>&#xd;</xsl:text>
                </xsl:for-each>
                <xsl:text># APPROACH END</xsl:text><xsl:text>&#xd;</xsl:text>
                <xsl:text># ------------------------------------------------</xsl:text><xsl:text>&#xd;</xsl:text>
            </xsl:for-each>

            <!-- STARS -->
            <xsl:text># ------------------------------------------------</xsl:text><xsl:text>&#xd;</xsl:text>
            <xsl:text># STARS for runway </xsl:text><xsl:value-of select="current()"/><xsl:text>&#xd;</xsl:text>
            <xsl:text># ------------------------------------------------</xsl:text><xsl:text>&#xd;</xsl:text>

            <xsl:for-each select="/ProceduresDB/Airport/Star[@Runways=current()]">
                <xsl:text># ------------------------------------------------</xsl:text><xsl:text>&#xd;</xsl:text>
                <xsl:text># STAR: START</xsl:text><xsl:text>&#xd;</xsl:text>
                <xsl:text># STAR Name: </xsl:text><xsl:value-of select="Runways"/><xsl:text>&#xd;</xsl:text>
                <xsl:text># STAR Runway: </xsl:text><xsl:value-of select="@Runways"/><xsl:text>&#xd;</xsl:text>
                <xsl:text>&#xd;</xsl:text>
                <xsl:text>WHITE</xsl:text><xsl:text>&#xd;</xsl:text>
                <!-- first to generate the lines -->
                <xsl:for-each select="Star_Waypoint">
                    <xsl:value-of select="Latitude"/><xsl:text>,</xsl:text><xsl:value-of select="Longitude"/>
                    <xsl:text> </xsl:text>
                    <xsl:text># </xsl:text><xsl:value-of select="Name"/><xsl:text>&#xd;</xsl:text>
                    <xsl:if test="not(position() = last()) and string-length(following-sibling::Star_Waypoint[1]/Altitude/text())>0">
                        <xsl:text>:label </xsl:text>
                        <xsl:value-of select="following-sibling::Star_Waypoint[1]/Altitude"/>
                        <xsl:text>&#xd;</xsl:text>
                    </xsl:if>
                </xsl:for-each>
                <!-- next to generate the point x-marks  -->
                <xsl:for-each select="Star_Waypoint">
                    <xsl:text>&#xd;</xsl:text>
                    <xsl:text>Chartreuse</xsl:text><xsl:text>&#xd;</xsl:text>
                    <xsl:value-of select="Latitude"/><xsl:text>,</xsl:text><xsl:value-of select="Longitude"/>
                    <xsl:text> </xsl:text>
                    <xsl:text>#  </xsl:text><xsl:value-of select="Name"/>
                    <xsl:text>&#xd;</xsl:text>
                </xsl:for-each>

                <!-- next to generate the point names offset to the top and left  -->
                <xsl:for-each select="Star_Waypoint">
                    <xsl:text>&#xd;</xsl:text>
                    <xsl:text>Chartreuse</xsl:text><xsl:text>&#xd;</xsl:text>
                    <xsl:value-of select="Latitude"/><xsl:text>,</xsl:text><xsl:value-of select="Longitude"/><xsl:text>&gt;315,0.1</xsl:text><xsl:text>&#xd;</xsl:text>
                    <xsl:text>:label </xsl:text><xsl:value-of select="Name"/><xsl:text>&#xd;</xsl:text>
                    <xsl:value-of select="Latitude"/><xsl:text>,</xsl:text><xsl:value-of select="Longitude"/><xsl:text>&gt;315,0.1</xsl:text><xsl:text>&#xd;</xsl:text>
                </xsl:for-each>
                <xsl:text># STAR END</xsl:text><xsl:text>&#xd;</xsl:text>
                <xsl:text># ------------------------------------------------</xsl:text><xsl:text>&#xd;</xsl:text>
            </xsl:for-each>

        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>