<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:variable name="waypoints" select="document('LBSF_waypoints.xml')"/>
    <xsl:template match="/">
        <html>
            <head>
                <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.0.0/dist/css/bootstrap.min.css" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous"></link>
            </head>
            <body>
                <div class="container">
                        <div class="row">
                            <div class="col-1"></div>
                            <div class="col-10">
                                <xsl:for-each select="/Airport/Chart/SID_Page">
                                    <table class="table table-bordered text-center">
                                        <tr>
                                            <xsl:for-each select="Header_Columns/Header_Column">
                                                <th>
                                                    <xsl:attribute name="style">width:<xsl:value-of select="Percent"/>%;</xsl:attribute>
                                                    <xsl:value-of select="Caption"/>
                                                </th>
                                            </xsl:for-each>
                                        </tr>
                                        <tr>
                                            <td>
                                                <xsl:attribute name="colspan"><xsl:value-of select="count(Header_Columns/Header_Column)"/></xsl:attribute>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="font-weight-bold text-left">
                                                <xsl:attribute name="colspan"><xsl:value-of select="count(Header_Columns/Header_Column)"/></xsl:attribute>
                                                <xsl:value-of select="SID_Core/ID"/>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="text-left">
                                                <xsl:attribute name="colspan"><xsl:value-of select="count(Header_Columns/Header_Column)"/></xsl:attribute>
                                                <xsl:value-of select="SID_Core/Name"/>
                                            </td>
                                        </tr>
                                        <xsl:for-each select="SID_Core/Waypoints/Waypoint">
                                            <tr>
                                                <xsl:for-each select="*">
                                                    <td>
                                                        <xsl:value-of select="current()"/>
                                                    </td>
                                                </xsl:for-each>
                                            </tr>
                                        </xsl:for-each>
                                    </table>
                                </xsl:for-each>
                            </div>
                            <div class="col-1"></div>
                        </div>
                </div>
            <script src="https://code.jquery.com/jquery-3.2.1.slim.min.js" integrity="sha384-KJ3o2DKtIkvYIK3UENzmM7KCkRr/rE9/Qpg6aAZGJwFDMVNA/GpGFF93hXpG5KkN" crossorigin="anonymous"></script>
            <script src="https://cdn.jsdelivr.net/npm/popper.js@1.12.9/dist/umd/popper.min.js" integrity="sha384-ApNbgh9B+Y1QKtv3Rn7W3mgPxhU9K/ScQsAP7hUibX39j7fakFPskvXusvfa0b4Q" crossorigin="anonymous"></script>
            <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.0.0/dist/js/bootstrap.min.js" integrity="sha384-JZR6Spejh4U02d8jOt6vLEHfe/JQGiRRSQQxSfFWpi1MquVdAyjUar5+76PVCmYl" crossorigin="anonymous"></script>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>