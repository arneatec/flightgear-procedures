<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:math="http://exslt.org/math"
                xmlns:xls="http://www.w3.org/1999/XSL/Transform"
                extension-element-prefixes="math">

    <xsl:variable name="waypoints" select="document('LBSF_waypoints.xml')"/>
    <xsl:variable name="maplines" select="document('map_lines.xml')"/>
    <xsl:template match="/">
        <html>
            <head>
                <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.0.0/dist/css/bootstrap.min.css" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous"></link>
            </head>
            <body>
                <div class="container">
                        <div class="row">
                            <div class="col-6">
                                <xsl:value-of select="/Airport/Chart/Publisher_Local"></xsl:value-of>
                            </div>
                            <div class="col-6 text-right font-weight-bold">
                                <xsl:value-of select="/Airport/Chart/ID"></xsl:value-of>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-6">
                                <xsl:value-of select="/Airport/Chart/Publisher"></xsl:value-of>
                            </div>
                            <div class="col-6 text-right font-weight-bold">
                                <xsl:value-of select="/Airport/Chart/Published_On"></xsl:value-of>
                            </div>
                        </div>
                        <div class="row">
                            <div class="card border-dark">
                                <div class="card-body">
                                    <div class="row">
                                        <div class="col-12 text-right font-weight-bold"><xsl:value-of select="/Airport/Chart/Airport_Location"></xsl:value-of></div>
                                    </div>
                                    <div class="row">
                                        <div class="col-3 font-weight-bold"><xsl:value-of select="/Airport/Chart/Name"></xsl:value-of></div>
                                        <div class="col-3">
                                            <div class="row">
                                                <div class="col-12">
                                                    TRANSITION ALT <xsl:value-of select="/Airport/Chart/Transition_Altitude_ft"></xsl:value-of> FT
                                                </div>
                                            </div>
                                            <div class="row">
                                                <div class="col-12">
                                                    TRANSITION LEVEL <xsl:value-of select="/Airport/Chart/Transition_Level"></xsl:value-of>
                                                </div>
                                            </div>
                                        </div>
                                        <xsl:for-each select="/Airport/Chart/Radio_Role">
                                            <div class="col-1 text-right">
                                                <span class="text-left">
                                                <xsl:value-of select="ID"></xsl:value-of></span>
                                                <ul class="list-group">
                                                    <xsl:for-each select="Radio_Frequencies/Radio_Frequency">
                                                      <li class="border-0 p-0 m-0 list-group-item"><xsl:value-of select="current()"></xsl:value-of></li>
                                                    </xsl:for-each>
                                                </ul>
                                            </div>
                                        </xsl:for-each>
                                        <div rowspan='3' class="col-3 text-right "><br/><br/>
                                            <xsl:for-each select="/Airport/Chart/Includes/SID_ID">
                                                <xsl:if test="position() > 1">, </xsl:if>
                                                <xsl:value-of select="current()"></xsl:value-of>
                                            </xsl:for-each>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="card border-dark">
                                <div class="card-body">
                                    <svg width="1000" height="1000" xmlns="http://www.w3.org/2000/svg">
                                        <xsl:for-each select="$maplines/MapLines/MapLine">
                                            <xsl:variable name="pointX1"><xsl:value-of select="floor((Longitude_Start * (3.1415926534 div 180) * 6378137) div //Airport/Chart/Zoom) + //Airport/Chart/Offset_X"/></xsl:variable>
                                            <xsl:variable name="pointY1"><xsl:value-of select="1000-floor((math:log(math:tan(Latitude_Start * (3.1415926534 div 180) div 2 + 3.1415926534 div 4)) * 6378137) div (//Airport/Chart/Zoom)) + //Airport/Chart/Offset_Y"/></xsl:variable>
                                            <xsl:variable name="pointX2"><xsl:value-of select="floor((Longitude_End * (3.1415926534 div 180) * 6378137) div //Airport/Chart/Zoom) + //Airport/Chart/Offset_X"/></xsl:variable>
                                            <xsl:variable name="pointY2"><xsl:value-of select="1000-floor((math:log(math:tan(Latitude_End * (3.1415926534 div 180) div 2 + 3.1415926534 div 4)) * 6378137) div (//Airport/Chart/Zoom)) + //Airport/Chart/Offset_Y"/></xsl:variable>
                                            <line>
                                                <xsl:attribute name="x1"><xsl:value-of select="$pointX1"></xsl:value-of></xsl:attribute>
                                                <xsl:attribute name="y1"><xsl:value-of select="$pointY1"></xsl:value-of></xsl:attribute>
                                                <xsl:attribute name="x2"><xsl:value-of select="$pointX2"></xsl:value-of></xsl:attribute>
                                                <xsl:attribute name="y2"><xsl:value-of select="$pointY2"></xsl:value-of></xsl:attribute>
                                                <xsl:attribute name="stroke">pink</xsl:attribute>
                                            </line>
                                        </xsl:for-each>

                                        <line x1="1" y1="0" x2="1" y2="1000" stroke="gray"></line>
                                        <line x1="200" y1="0" x2="200" y2="1000" stroke="gray"></line>
                                        <line x1="400" y1="0" x2="400" y2="1000" stroke="gray"></line>
                                        <line x1="600" y1="0" x2="600" y2="1000" stroke="gray"></line>
                                        <line x1="800" y1="0" x2="800" y2="1000" stroke="gray"></line>
                                        <line x1="999" y1="0" x2="999" y2="1000" stroke="gray"></line>
                                        <xsl:for-each select="$waypoints/Waypoins/Waypoint">
                                            <xsl:variable name="pointX"><xsl:value-of select="floor((Longitude * (3.1415926534 div 180) * 6378137) div //Airport/Chart/Zoom) + //Airport/Chart/Offset_X"/></xsl:variable>
                                            <xsl:variable name="pointY"><xsl:value-of select="1000-floor((math:log(math:tan(Latitude * (3.1415926534 div 180) div 2 + 3.1415926534 div 4)) * 6378137) div (//Airport/Chart/Zoom)) + //Airport/Chart/Offset_Y"/></xsl:variable>
                                            <xsl:variable name="pointType"><xsl:value-of select="Type"></xsl:value-of></xsl:variable>

                                            <xsl:choose>
                                                <!-- Waypoint - Compulsory / FlyBy -->
                                                <xsl:when test="$pointType='WPT-C-FB'">
                                                    <polygon>
                                                        <xsl:attribute name="points">
                                                            <xsl:value-of select="$pointX - 10"></xsl:value-of>,<xsl:value-of select="$pointY + 10">
                                                            </xsl:value-of><xsl:text>
                                                            </xsl:text><xsl:value-of select="$pointX"></xsl:value-of>,<xsl:value-of select="$pointY - 10"></xsl:value-of>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX + 10"></xsl:value-of>,<xsl:value-of select="$pointY + 10"></xsl:value-of>
                                                        </xsl:attribute>
                                                    </polygon>
                                                </xsl:when>
                                                <!-- Waypoint - On Request / FlyBy -->
                                                <xsl:when test="$pointType='WPT-OR-FB'">
                                                    <circle>
                                                        <xsl:attribute name="cx"><xsl:value-of select="$pointX"></xsl:value-of></xsl:attribute>
                                                        <xsl:attribute name="cy"><xsl:value-of select="$pointY"></xsl:value-of></xsl:attribute>
                                                        <xsl:attribute name="r">7</xsl:attribute>
                                                        <xsl:attribute name="fill">white</xsl:attribute>
                                                        <xsl:attribute name="stroke">black</xsl:attribute>
                                                    </circle>
                                                    <!-- polygon -->
                                                    <polygon>
                                                        <xsl:attribute name="points">
                                                            <xsl:value-of select="$pointX"></xsl:value-of>,<xsl:value-of select="$pointY + 15"></xsl:value-of>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX - 5"></xsl:value-of>,<xsl:value-of select="$pointY + 5"></xsl:value-of>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX - 15"></xsl:value-of>,<xsl:value-of select="$pointY"></xsl:value-of>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX - 5"></xsl:value-of>,<xsl:value-of select="$pointY - 5"></xsl:value-of>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX"></xsl:value-of>,<xsl:value-of select="$pointY - 15"></xsl:value-of>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX + 5"></xsl:value-of>,<xsl:value-of select="$pointY - 5"></xsl:value-of>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX + 15"></xsl:value-of>,<xsl:value-of select="$pointY"></xsl:value-of>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX + 5"></xsl:value-of>,<xsl:value-of select="$pointY + 5"></xsl:value-of>
                                                        </xsl:attribute>
                                                        <xsl:attribute name="stroke">black</xsl:attribute>
                                                        <xsl:attribute name="fill">none</xsl:attribute>
                                                    </polygon>
                                                </xsl:when>
                                                <!-- VOR/DME - On Request / FlyBy -->
                                                <xsl:when test="$pointType='VOR-DME-OR-FB'">
                                                    <circle>
                                                        <xsl:attribute name="cx"><xsl:value-of select="$pointX"></xsl:value-of></xsl:attribute>
                                                        <xsl:attribute name="cy"><xsl:value-of select="$pointY"></xsl:value-of></xsl:attribute>
                                                        <xsl:attribute name="r">2</xsl:attribute>
                                                    </circle>
                                                    <!-- square -->
                                                    <polygon>
                                                        <xsl:attribute name="points">
                                                            <xsl:value-of select="$pointX - 12"></xsl:value-of>,<xsl:value-of select="$pointY + 10"></xsl:value-of>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX - 12"></xsl:value-of>,<xsl:value-of select="$pointY - 10"></xsl:value-of>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX + 12"></xsl:value-of>,<xsl:value-of select="$pointY - 10"></xsl:value-of>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX + 12"></xsl:value-of>,<xsl:value-of select="$pointY + 10"></xsl:value-of>
                                                        </xsl:attribute>
                                                        <xsl:attribute name="stroke">black</xsl:attribute>
                                                        <xsl:attribute name="fill">none</xsl:attribute>
                                                    </polygon>
                                                    <!-- polygon -->
                                                    <polygon>
                                                        <xsl:attribute name="points">
                                                            <xsl:value-of select="$pointX - 5"></xsl:value-of>,<xsl:value-of select="$pointY + 10"></xsl:value-of>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX - 12"></xsl:value-of>,<xsl:value-of select="$pointY"></xsl:value-of>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX - 5"></xsl:value-of>,<xsl:value-of select="$pointY - 10"></xsl:value-of>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX + 5"></xsl:value-of>,<xsl:value-of select="$pointY - 10"></xsl:value-of>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX + 12"></xsl:value-of>,<xsl:value-of select="$pointY"></xsl:value-of>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX + 5"></xsl:value-of>,<xsl:value-of select="$pointY + 10"></xsl:value-of>
                                                        </xsl:attribute>
                                                        <xsl:attribute name="stroke">black</xsl:attribute>
                                                        <xsl:attribute name="fill">none</xsl:attribute>
                                                    </polygon>
                                                </xsl:when>
                                                <!-- VOR/DME - On Request / FlyBy -->
                                                <xsl:when test="$pointType='Airport'">
                                                    <circle>
                                                        <xsl:attribute name="cx"><xsl:value-of select="$pointX"></xsl:value-of></xsl:attribute>
                                                        <xsl:attribute name="cy"><xsl:value-of select="$pointY"></xsl:value-of></xsl:attribute>
                                                        <xsl:attribute name="r">15</xsl:attribute>
                                                        <xsl:attribute name="stroke">black</xsl:attribute>
                                                        <xsl:attribute name="fill">none</xsl:attribute>
                                                    </circle>
                                                   <line>
                                                        <xsl:attribute name="x1"><xsl:value-of select="$pointX - floor(18 * math:cos(((Runway * 10) - 90) * (3.1415926534 div 180)))"></xsl:value-of></xsl:attribute>
                                                        <xsl:attribute name="y1"><xsl:value-of select="$pointY + floor(18 * math:sin(((Runway * 10) + 90) * (3.1415926534 div 180)))"></xsl:value-of></xsl:attribute>
                                                        <xsl:attribute name="x2"><xsl:value-of select="$pointX + floor(18 * math:cos(((Runway * 10) - 90) * (3.1415926534 div 180)))"></xsl:value-of></xsl:attribute>
                                                        <xsl:attribute name="y2"><xsl:value-of select="$pointY - floor(18 * math:sin(((Runway * 10) + 90) * (3.1415926534 div 180)))"></xsl:value-of></xsl:attribute>
                                                        <xsl:attribute name="stroke">black</xsl:attribute>
                                                        <xsl:attribute name="stroke-width">3</xsl:attribute>
                                                   </line>
                                                </xsl:when>
                                            </xsl:choose>
                                            <text>
                                                <xsl:attribute name="x">
                                                    <xsl:choose>
                                                        <xls:when test="CaptionOffset">
                                                            <xsl:value-of select="$pointX  + CaptionOffset/X"/>
                                                        </xls:when>
                                                        <xsl:otherwise>
                                                            <xsl:value-of select="$pointX + 15"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </xsl:attribute>
                                                <xsl:attribute name="y">
                                                    <xsl:choose>
                                                        <xls:when test="CaptionOffset">
                                                            <xsl:value-of select="$pointY  + CaptionOffset/Y"/>
                                                        </xls:when>
                                                        <xsl:otherwise>
                                                            <xsl:value-of select="$pointY + 15"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </xsl:attribute>
                                                <xsl:value-of select="ID"></xsl:value-of>
                                            </text>
                                        </xsl:for-each>
                                    </svg>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-12">
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
                        </div>
                </div>
            <script src="https://code.jquery.com/jquery-3.2.1.slim.min.js" integrity="sha384-KJ3o2DKtIkvYIK3UENzmM7KCkRr/rE9/Qpg6aAZGJwFDMVNA/GpGFF93hXpG5KkN" crossorigin="anonymous"></script>
            <script src="https://cdn.jsdelivr.net/npm/popper.js@1.12.9/dist/umd/popper.min.js" integrity="sha384-ApNbgh9B+Y1QKtv3Rn7W3mgPxhU9K/ScQsAP7hUibX39j7fakFPskvXusvfa0b4Q" crossorigin="anonymous"></script>
            <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.0.0/dist/js/bootstrap.min.js" integrity="sha384-JZR6Spejh4U02d8jOt6vLEHfe/JQGiRRSQQxSfFWpi1MquVdAyjUar5+76PVCmYl" crossorigin="anonymous"></script>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>