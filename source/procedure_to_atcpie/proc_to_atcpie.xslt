<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method='text'/>
    <xsl:template match="/">
        <xsl:text># files for atc-pie, minimum version is 1.8.8</xsl:text><xsl:text>&#xd;</xsl:text>
        <xsl:text># ------------------------------------------------</xsl:text><xsl:text>&#xd;</xsl:text>
        <xsl:text># APPROACHES </xsl:text><xsl:text>&#xd;</xsl:text>
        <xsl:text># ------------------------------------------------</xsl:text><xsl:text>&#xd;</xsl:text>

        <xsl:for-each select="/ProceduresDB/Airport/Approach">
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

    </xsl:template>
</xsl:stylesheet>