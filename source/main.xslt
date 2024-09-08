<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:math="http://exslt.org/math"
                xmlns:xls="http://www.w3.org/1999/XSL/Transform"
                extension-element-prefixes="math">
    <xsl:variable name="svg_size" select="1000"/>
    <xsl:variable name="geo_nm_in_km" select="1.852"/>
    <xsl:variable name="math_PI" select="3.14159265"/>
    <xsl:variable name="web_mercator_earth_radius" select="6378137" />
    <xsl:variable name="geo_magnetic_variation" select="/Airport/Chart/MagneticVariation"/>

    <xsl:variable name="waypoints" select="document('LBSF_waypoints.xml')"/>
    <xsl:variable name="maplines" select="document('map_lines.xml')"/>
    <xsl:template match="/">
        <html>
            <head>
                <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.0.0/dist/css/bootstrap.min.css" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous"/>
            </head>
            <body>
                <div class="container">
                        <div class="row">
                            <div class="col-6">
                                <xsl:value-of select="/Airport/Chart/Publisher_Local"/>
                            </div>
                            <div class="col-6 text-right font-weight-bold">
                                <xsl:value-of select="/Airport/Chart/ID"/>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-6">
                                <xsl:value-of select="/Airport/Chart/Publisher"/>
                            </div>
                            <div class="col-6 text-right font-weight-bold">
                                <xsl:value-of select="/Airport/Chart/Published_On"/>
                            </div>
                        </div>
                        <div class="row">
                            <div class="card border-dark">
                                <div class="card-body">
                                    <div class="row">
                                        <div class="col-12 text-right font-weight-bold"><xsl:value-of select="/Airport/Chart/Airport_Location"/></div>
                                    </div>
                                    <div class="row">
                                        <div class="col-3 font-weight-bold"><xsl:value-of select="/Airport/Chart/Name"/></div>
                                        <div class="col-3">
                                            <div class="row">
                                                <div class="col-12">
                                                    TRANSITION ALT <xsl:value-of select="/Airport/Chart/Transition_Altitude_ft"/> FT
                                                </div>
                                            </div>
                                            <div class="row">
                                                <div class="col-12">
                                                    TRANSITION LEVEL <xsl:value-of select="/Airport/Chart/Transition_Level"/>
                                                </div>
                                            </div>
                                        </div>
                                        <xsl:for-each select="/Airport/Chart/Radio_Role">
                                            <div class="col-1 text-right">
                                                <span class="text-left">
                                                <xsl:value-of select="ID"/></span>
                                                <ul class="list-group">
                                                    <xsl:for-each select="Radio_Frequencies/Radio_Frequency">
                                                      <li class="border-0 p-0 m-0 list-group-item"><xsl:value-of select="current()"/></li>
                                                    </xsl:for-each>
                                                </ul>
                                            </div>
                                        </xsl:for-each>
                                        <div rowspan='3' class="col-3 text-right "><br/><br/>
                                            <xsl:for-each select="/Airport/Chart/Includes/SID_ID">
                                                <xsl:if test="position() > 1">, </xsl:if>
                                                <xsl:value-of select="current()"/>
                                            </xsl:for-each>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="card border-dark">
                                <div class="card-body  p-0 m-0">
                                    <svg>
                                        <xsl:attribute name="width"><xsl:value-of select="$svg_size"/></xsl:attribute>
                                        <xsl:attribute name="height"><xsl:value-of select="$svg_size"/></xsl:attribute>

                                        <!-- SID -->
                                        <xsl:for-each select="/Airport/Chart/SID_Page/SID_Core">
                                            <!-- each SID starts with the runway threshold -->
                                            <path>
                                                <xsl:attribute name="fill">none</xsl:attribute>
                                                <xsl:attribute name="stroke">black</xsl:attribute>
                                                <xsl:attribute name="stroke-width">2</xsl:attribute>
                                                <xsl:attribute name="d">
                                                    <!-- runway termination coordinates -->
                                                    <xsl:variable name="startX"><xsl:value-of select="floor((/Airport/Chart/RunwayThreshold/Longitude * ($math_PI div 180) * $web_mercator_earth_radius) div //Airport/Chart/Zoom) + //Airport/Chart/Offset_X"/></xsl:variable>
                                                    <xsl:variable name="startY"><xsl:value-of select="$svg_size - floor((math:log(math:tan(/Airport/Chart/RunwayThreshold/Latitude * ($math_PI div 180) div 2 + $math_PI div 4)) * $web_mercator_earth_radius) div (//Airport/Chart/Zoom)) + //Airport/Chart/Offset_Y"/></xsl:variable>
                                                    <!-- lenght of the runway 'fly away extension' -->
                                                    <xsl:variable name="takeOffExtension"><xsl:value-of select="/Airport/Chart/TakeOffFlyRunwayHeadingDistance"/></xsl:variable>
                                                    <!-- extension end coordinates -->
                                                    <xsl:variable name="endExtensionX"><xsl:value-of select="$startX + floor($takeOffExtension * math:cos((/Airport/Chart/RunwayDirection - 90) * ($math_PI div 180)))"/></xsl:variable>
                                                    <xsl:variable name="endExtensionY"><xsl:value-of select="$startY + floor($takeOffExtension * math:sin((/Airport/Chart/RunwayDirection + 90) * ($math_PI div 180)))"/></xsl:variable>
                                                    <!-- start drawing -->
                                                    M <xsl:value-of select="$startX"/><xsl:text> </xsl:text><xsl:value-of select="$startY"/>
                                                    L <xsl:value-of select="$endExtensionX"/><xsl:text> </xsl:text><xsl:value-of select="$endExtensionY"/>
                                                    <xsl:if test="count(Waypoints/Waypoint[PT='CA']) > 0">
                                                        <xsl:choose>
                                                             <xsl:when test="count(Waypoints/Waypoint[PT='CA' and Turn='Left']) > 0">
                                                                Q <xsl:value-of select="$endExtensionX +  floor($takeOffExtension* 0.923)"/><xsl:text> </xsl:text><xsl:value-of select="$endExtensionY"/> <xsl:text> </xsl:text> <xsl:value-of select="$endExtensionX + 45"/><xsl:text> </xsl:text> <xsl:value-of select="$endExtensionY - 45"/>
                                                             </xsl:when>
                                                            <xsl:otherwise>
                                                                Q <xsl:value-of select="$endExtensionX +  floor($takeOffExtension* 0.923)"/><xsl:text> </xsl:text><xsl:value-of select="$endExtensionY"/> <xsl:text> </xsl:text> <xsl:value-of select="$endExtensionX + 45"/><xsl:text> </xsl:text> <xsl:value-of select="$endExtensionY + 45"/>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </xsl:if>
                                                    <!-- and finally the waypoints -->
                                                    <xsl:for-each select="Waypoints/Waypoint[not(WPTID='-')]">
                                                        <xsl:variable name="pointX"><xsl:value-of select="floor(($waypoints/Waypoins/Waypoint[ID=current()/WPTID]/Longitude * ($math_PI div 180) * $web_mercator_earth_radius) div //Airport/Chart/Zoom) + //Airport/Chart/Offset_X"/></xsl:variable>
                                                        <xsl:variable name="pointY"><xsl:value-of select="$svg_size - floor((math:log(math:tan($waypoints/Waypoins/Waypoint[ID=current()/WPTID]/Latitude * ($math_PI div 180) div 2 + $math_PI div 4)) * $web_mercator_earth_radius) div (//Airport/Chart/Zoom)) + //Airport/Chart/Offset_Y"/></xsl:variable>
                                                        L <xsl:value-of select="$pointX"/><xsl:text> </xsl:text><xsl:value-of select="$pointY"/><xsl:text> </xsl:text>
                                                    </xsl:for-each>
                                                </xsl:attribute>
                                            </path>
                                                                                    <!-- sid track -->
                                            <xsl:for-each select="Waypoints/Waypoint[not(Track='-') and not(WPTID='-')]">
                                                <xsl:variable name="pointX"><xsl:value-of select="floor(($waypoints/Waypoins/Waypoint[ID=current()/WPTID]/Longitude * ($math_PI div 180) * $web_mercator_earth_radius) div //Airport/Chart/Zoom) + //Airport/Chart/Offset_X"/></xsl:variable>
                                                <xsl:variable name="pointY"><xsl:value-of select="$svg_size - floor((math:log(math:tan($waypoints/Waypoins/Waypoint[ID=current()/WPTID]/Latitude * ($math_PI div 180) div 2 + $math_PI div 4)) * $web_mercator_earth_radius) div (//Airport/Chart/Zoom)) + //Airport/Chart/Offset_Y"/></xsl:variable>
                                                <xsl:variable name="geo_track"><xsl:value-of select="substring-before(substring-after(Track, '('),'°')"/></xsl:variable>
                                                <xsl:variable name="oneX"><xsl:value-of select="$pointX - floor(DIST * $geo_nm_in_km * 100000 * (/Airport/Chart/Zoom div $web_mercator_earth_radius ) * math:cos((($geo_track - 90 ) * ($math_PI div 180))))"/></xsl:variable>
                                                <xsl:variable name="oneY"><xsl:value-of select="$pointY + floor(DIST * $geo_nm_in_km * 100000 * ( /Airport/Chart/Zoom div $web_mercator_earth_radius ) * math:sin((($geo_track + 90 ) * ($math_PI div 180))))"/></xsl:variable>
                                                <xsl:variable name="distanceX"><xsl:value-of select="$pointX - floor((DIST) * $geo_nm_in_km * 100000 * (/Airport/Chart/Zoom div $web_mercator_earth_radius ) * math:cos((($geo_track - 90  - 12) * ($math_PI div 180))))"/></xsl:variable>
                                                <xsl:variable name="distanceY"><xsl:value-of select="$pointY + floor((DIST) * $geo_nm_in_km * 100000 * ( /Airport/Chart/Zoom div $web_mercator_earth_radius ) * math:sin((($geo_track + 90 - 12 ) * ($math_PI div 180))))"/></xsl:variable>

                                                <xsl:variable name="text-rotate"><xsl:value-of select="substring-before(Track,'°')"/></xsl:variable>
                                                 <circle>
                                                    <xsl:attribute name="cx"><xsl:value-of select="$oneX"/></xsl:attribute>
                                                    <xsl:attribute name="cy"><xsl:value-of select="$oneY"/></xsl:attribute>
                                                    <xsl:attribute name="r">22</xsl:attribute>
                                                    <xsl:attribute name="fill">white</xsl:attribute>
                                                    <xsl:attribute name="stroke">none</xsl:attribute>
                                                </circle>
                                                <text>
                                                    <xsl:attribute name="text-anchor">middle</xsl:attribute>
                                                    <xsl:attribute name="alignment-baseline">middle</xsl:attribute>
                                                    <xsl:attribute name="transform">translate(<xsl:value-of select="$oneX"/>, <xsl:value-of select="$oneY"/>) rotate(
                                                        <xsl:choose>
                                                            <xsl:when test="$text-rotate > 180">
                                                                <xsl:value-of select="substring-before(Track,'°') -  90 - 180"/>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:value-of select="substring-before(Track,'°') -  90"/>
                                                            </xsl:otherwise>
                                                        </xsl:choose>

                                                        )</xsl:attribute>
                                                    <xsl:attribute name="fill">green</xsl:attribute>
                                                    <xsl:if test="$oneX &lt; ($svg_size div 2)">
                                                        <xsl:text>&lt;</xsl:text>
                                                    </xsl:if>
                                                    <xsl:value-of select="substring-before(Track,'(')"/>
                                                    <xsl:if test="not($oneX &lt; ($svg_size div 2))">
                                                        <xsl:text>&gt;</xsl:text>
                                                    </xsl:if>
                                                 </text>
                                                <!-- distance -->
                                                <text>
                                                    <xsl:attribute name="text-anchor">middle</xsl:attribute>
                                                    <xsl:attribute name="alignment-baseline">middle</xsl:attribute>
                                                    <xsl:attribute name="transform">translate(<xsl:value-of select="$distanceX"/>, <xsl:value-of select="$distanceY"/>) rotate(
                                                        <xsl:choose>
                                                            <xsl:when test="$text-rotate > 180">
                                                                <xsl:value-of select="substring-before(Track,'°') -  90 - 180"/>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:value-of select="substring-before(Track,'°') -  90"/>
                                                            </xsl:otherwise>
                                                        </xsl:choose>

                                                        )</xsl:attribute>
                                                    <xsl:attribute name="fill">green</xsl:attribute>
                                                    <xsl:value-of select="DIST"/>
                                                 </text>
                                            </xsl:for-each>
                                        </xsl:for-each>

                            <!-- map lines -->
                                        <xsl:for-each select="$maplines/MapLines/MapLine">
                                            <xsl:variable name="pointX1"><xsl:value-of select="floor((Longitude_Start * ($math_PI div 180) * $web_mercator_earth_radius) div //Airport/Chart/Zoom) + //Airport/Chart/Offset_X"/></xsl:variable>
                                            <xsl:variable name="pointY1"><xsl:value-of select="$svg_size - floor((math:log(math:tan(Latitude_Start * ($math_PI div 180) div 2 + $math_PI div 4)) * $web_mercator_earth_radius) div (//Airport/Chart/Zoom)) + //Airport/Chart/Offset_Y"/></xsl:variable>
                                            <xsl:variable name="pointX2"><xsl:value-of select="floor((Longitude_End * ($math_PI div 180) * $web_mercator_earth_radius) div //Airport/Chart/Zoom) + //Airport/Chart/Offset_X"/></xsl:variable>
                                            <xsl:variable name="pointY2"><xsl:value-of select="$svg_size - floor((math:log(math:tan(Latitude_End * ($math_PI div 180) div 2 + $math_PI div 4)) * $web_mercator_earth_radius) div (//Airport/Chart/Zoom)) + //Airport/Chart/Offset_Y"/></xsl:variable>
                                            <line>
                                                <xsl:attribute name="x1"><xsl:value-of select="$pointX1"/></xsl:attribute>
                                                <xsl:attribute name="y1"><xsl:value-of select="$pointY1"/></xsl:attribute>
                                                <xsl:attribute name="x2"><xsl:value-of select="$pointX2"/></xsl:attribute>
                                                <xsl:attribute name="y2"><xsl:value-of select="$pointY2"/></xsl:attribute>
                                                <xsl:attribute name="stroke">gray</xsl:attribute>
                                            </line>

                                        </xsl:for-each>
                                        <!-- map line captions -->
                                        <xsl:for-each select="$maplines/MapLines/Caption">
                                            <xsl:variable name="pointX"><xsl:value-of select="floor((Longitude * ($math_PI div 180) * $web_mercator_earth_radius) div //Airport/Chart/Zoom) + //Airport/Chart/Offset_X"/></xsl:variable>
                                            <xsl:variable name="pointY"><xsl:value-of select="$svg_size - floor((math:log(math:tan(Latitude * ($math_PI div 180) div 2 + $math_PI div 4)) * $web_mercator_earth_radius) div (//Airport/Chart/Zoom)) + //Airport/Chart/Offset_Y"/></xsl:variable>
                                            <text>
                                                <xsl:attribute name="text-anchor">middle</xsl:attribute>
                                                <xsl:attribute name="alignment-baseline">middle</xsl:attribute>
                                                <xsl:attribute name="transform">translate(<xsl:value-of select="$pointX"/>, <xsl:value-of select="$pointY"/>) rotate(<xsl:value-of select="Rotate"/>)</xsl:attribute>
                                                <xsl:attribute name="fill">gray</xsl:attribute>
                                                <xsl:value-of select="Text"/>
                                             </text>
                                        </xsl:for-each>
                                        <!-- guide lines
                                        <line x1="1" y1="0" x2="1" y2="$svg_size" stroke="gray"></line>
                                        <line x1="200" y1="0" x2="200" y2="$svg_size" stroke="gray"></line>
                                        <line x1="400" y1="0" x2="400" y2="$svg_size" stroke="gray"></line>
                                        <line x1="600" y1="0" x2="600" y2="$svg_size" stroke="gray"></line>
                                        <line x1="800" y1="0" x2="800" y2="$svg_size" stroke="gray"></line>
                                        <line x1="999" y1="0" x2="999" y2="$svg_size" stroke="gray"></line>
                                        -->
                                        <!-- waypoints -->
                                        <xsl:for-each select="$waypoints/Waypoins/Waypoint">
                                            <xsl:variable name="pointX"><xsl:value-of select="floor((Longitude * ($math_PI div 180) * $web_mercator_earth_radius) div //Airport/Chart/Zoom) + //Airport/Chart/Offset_X"/></xsl:variable>
                                            <xsl:variable name="pointY"><xsl:value-of select="$svg_size - floor((math:log(math:tan(Latitude * ($math_PI div 180) div 2 + $math_PI div 4)) * $web_mercator_earth_radius) div (//Airport/Chart/Zoom)) + //Airport/Chart/Offset_Y"/></xsl:variable>
                                            <xsl:variable name="pointType"><xsl:value-of select="Type"/></xsl:variable>

                                            <xsl:choose>
                                                <!-- Waypoint - Compulsory / FlyBy -->
                                                <xsl:when test="$pointType='WPT-C-FB'">
                                                    <polygon>
                                                        <xsl:attribute name="points">
                                                            <xsl:value-of select="$pointX - 10"/>,<xsl:value-of select="$pointY + 10">
                                                            </xsl:value-of><xsl:text>
                                                            </xsl:text><xsl:value-of select="$pointX"/>,<xsl:value-of select="$pointY - 10"/>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX + 10"/>,<xsl:value-of select="$pointY + 10"/>
                                                        </xsl:attribute>
                                                    </polygon>
                                                </xsl:when>
                                                <!-- Waypoint - On Request / FlyBy -->
                                                <xsl:when test="$pointType='WPT-OR-FB'">
                                                    <circle>
                                                        <xsl:attribute name="cx"><xsl:value-of select="$pointX"/></xsl:attribute>
                                                        <xsl:attribute name="cy"><xsl:value-of select="$pointY"/></xsl:attribute>
                                                        <xsl:attribute name="r">7</xsl:attribute>
                                                        <xsl:attribute name="fill">white</xsl:attribute>
                                                        <xsl:attribute name="stroke">black</xsl:attribute>
                                                    </circle>
                                                    <!-- polygon -->
                                                    <polygon>
                                                        <xsl:attribute name="points">
                                                            <xsl:value-of select="$pointX"/>,<xsl:value-of select="$pointY + 15"/>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX - 5"/>,<xsl:value-of select="$pointY + 5"/>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX - 15"/>,<xsl:value-of select="$pointY"/>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX - 5"/>,<xsl:value-of select="$pointY - 5"/>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX"/>,<xsl:value-of select="$pointY - 15"/>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX + 5"/>,<xsl:value-of select="$pointY - 5"/>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX + 15"/>,<xsl:value-of select="$pointY"/>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX + 5"/>,<xsl:value-of select="$pointY + 5"/>
                                                        </xsl:attribute>
                                                        <xsl:attribute name="stroke">black</xsl:attribute>
                                                        <xsl:attribute name="fill">none</xsl:attribute>
                                                    </polygon>
                                                </xsl:when>
                                                <!-- VOR/DME - On Request / FlyBy -->
                                                <xsl:when test="$pointType='VOR-DME-OR-FB'">
                                                    <circle>
                                                        <xsl:attribute name="cx"><xsl:value-of select="$pointX"/></xsl:attribute>
                                                        <xsl:attribute name="cy"><xsl:value-of select="$pointY"/></xsl:attribute>
                                                        <xsl:attribute name="r">2</xsl:attribute>
                                                    </circle>
                                                    <!-- square -->
                                                    <polygon>
                                                        <xsl:attribute name="points">
                                                            <xsl:value-of select="$pointX - 12"/>,<xsl:value-of select="$pointY + 10"/>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX - 12"/>,<xsl:value-of select="$pointY - 10"/>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX + 12"/>,<xsl:value-of select="$pointY - 10"/>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX + 12"/>,<xsl:value-of select="$pointY + 10"/>
                                                        </xsl:attribute>
                                                        <xsl:attribute name="stroke">black</xsl:attribute>
                                                        <xsl:attribute name="fill">none</xsl:attribute>
                                                    </polygon>
                                                    <!-- polygon -->
                                                    <polygon>
                                                        <xsl:attribute name="points">
                                                            <xsl:value-of select="$pointX - 5"/>,<xsl:value-of select="$pointY + 10"/>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX - 12"/>,<xsl:value-of select="$pointY"/>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX - 5"/>,<xsl:value-of select="$pointY - 10"/>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX + 5"/>,<xsl:value-of select="$pointY - 10"/>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX + 12"/>,<xsl:value-of select="$pointY"/>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX + 5"/>,<xsl:value-of select="$pointY + 10"/>
                                                        </xsl:attribute>
                                                        <xsl:attribute name="stroke">black</xsl:attribute>
                                                        <xsl:attribute name="fill">none</xsl:attribute>
                                                    </polygon>
                                                </xsl:when>
                                                <!-- secondary airports -->
                                                <xsl:when test="$pointType='Airport'">
                                                    <circle>
                                                        <xsl:attribute name="cx"><xsl:value-of select="$pointX"/></xsl:attribute>
                                                        <xsl:attribute name="cy"><xsl:value-of select="$pointY"/></xsl:attribute>
                                                        <xsl:attribute name="r">15</xsl:attribute>
                                                        <xsl:attribute name="stroke">black</xsl:attribute>
                                                        <xsl:attribute name="fill">none</xsl:attribute>
                                                    </circle>
                                                   <line>
                                                        <xsl:attribute name="x1"><xsl:value-of select="$pointX - floor(18 * math:cos(((Runway * 10) - 90) * ($math_PI div 180)))"/></xsl:attribute>
                                                        <xsl:attribute name="y1"><xsl:value-of select="$pointY + floor(18 * math:sin(((Runway * 10) + 90) * ($math_PI div 180)))"/></xsl:attribute>
                                                        <xsl:attribute name="x2"><xsl:value-of select="$pointX + floor(18 * math:cos(((Runway * 10) - 90) * ($math_PI div 180)))"/></xsl:attribute>
                                                        <xsl:attribute name="y2"><xsl:value-of select="$pointY - floor(18 * math:sin(((Runway * 10) + 90) * ($math_PI div 180)))"/></xsl:attribute>
                                                        <xsl:attribute name="stroke">black</xsl:attribute>
                                                        <xsl:attribute name="stroke-width">3</xsl:attribute>
                                                   </line>
                                                </xsl:when>
                                                <!-- base airport -->
                                                <xsl:when test="$pointType='BaseAirport'">
                                                    <polygon>
                                                        <xsl:attribute name="points">
                                                            <xsl:for-each select="PolygonPoints/PolygonPoint">
                                                                <xsl:value-of select="$pointX + X"/>,<xsl:value-of select="$pointY + Y"/><xsl:text> </xsl:text>
                                                            </xsl:for-each>
                                                        </xsl:attribute>
                                                        <xsl:attribute name="fill">gray</xsl:attribute>
                                                        <xsl:attribute name="stroke">gray</xsl:attribute>
                                                    </polygon>
                                                   <line>
                                                        <xsl:attribute name="x1"><xsl:value-of select="$pointX - floor(RunwayLenght * math:cos((RunwayDirection - 90) * ($math_PI div 180)))"/></xsl:attribute>
                                                        <xsl:attribute name="y1"><xsl:value-of select="$pointY + floor(RunwayLenght * math:sin((RunwayDirection + 90) * ($math_PI div 180)))"/></xsl:attribute>
                                                        <xsl:attribute name="x2"><xsl:value-of select="$pointX + floor(RunwayLenght * math:cos((RunwayDirection - 90) * ($math_PI div 180)))"/></xsl:attribute>
                                                        <xsl:attribute name="y2"><xsl:value-of select="$pointY - floor(RunwayLenght * math:sin((RunwayDirection + 90) * ($math_PI div 180)))"/></xsl:attribute>
                                                        <xsl:attribute name="stroke">white</xsl:attribute>
                                                        <xsl:attribute name="stroke-width">2</xsl:attribute>
                                                   </line>
                                                </xsl:when>
                                                <!-- MSA -->
                                                <xsl:when test="$pointType='MSA'">
                                                    <circle>
                                                        <xsl:attribute name="cx"><xsl:value-of select="$pointX"/></xsl:attribute>
                                                        <xsl:attribute name="cy"><xsl:value-of select="$pointY"/></xsl:attribute>
                                                        <xsl:attribute name="r">2</xsl:attribute>
                                                    </circle>
                                                    <!-- square -->
                                                    <polygon>
                                                        <xsl:attribute name="points">
                                                            <xsl:value-of select="$pointX - 12"/>,<xsl:value-of select="$pointY + 10"/>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX - 12"/>,<xsl:value-of select="$pointY - 10"/>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX + 12"/>,<xsl:value-of select="$pointY - 10"/>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX + 12"/>,<xsl:value-of select="$pointY + 10"/>
                                                        </xsl:attribute>
                                                        <xsl:attribute name="stroke">black</xsl:attribute>
                                                        <xsl:attribute name="fill">none</xsl:attribute>
                                                    </polygon>
                                                    <!-- polygon -->
                                                    <polygon>
                                                        <xsl:attribute name="points">
                                                            <xsl:value-of select="$pointX - 5"/>,<xsl:value-of select="$pointY + 10"/>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX - 12"/>,<xsl:value-of select="$pointY"/>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX - 5"/>,<xsl:value-of select="$pointY - 10"/>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX + 5"/>,<xsl:value-of select="$pointY - 10"/>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX + 12"/>,<xsl:value-of select="$pointY"/>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX + 5"/>,<xsl:value-of select="$pointY + 10"/>
                                                        </xsl:attribute>
                                                        <xsl:attribute name="stroke">black</xsl:attribute>
                                                        <xsl:attribute name="fill">none</xsl:attribute>
                                                    </polygon>
                                                    <circle>
                                                        <xsl:attribute name="cx"><xsl:value-of select="$pointX"/></xsl:attribute>
                                                        <xsl:attribute name="cy"><xsl:value-of select="$pointY"/></xsl:attribute>
                                                        <xsl:attribute name="r">65</xsl:attribute>
                                                        <xsl:attribute name="fill">none</xsl:attribute>
                                                        <xsl:attribute name="stroke">black</xsl:attribute>
                                                    </circle>
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
                                                <xsl:value-of select="ID"/>
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
            <script src="https://code.jquery.com/jquery-3.2.1.slim.min.js" integrity="sha384-KJ3o2DKtIkvYIK3UENzmM7KCkRr/rE9/Qpg6aAZGJwFDMVNA/GpGFF93hXpG5KkN" crossorigin="anonymous"/>
            <script src="https://cdn.jsdelivr.net/npm/popper.js@1.12.9/dist/umd/popper.min.js" integrity="sha384-ApNbgh9B+Y1QKtv3Rn7W3mgPxhU9K/ScQsAP7hUibX39j7fakFPskvXusvfa0b4Q" crossorigin="anonymous"/>
            <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.0.0/dist/js/bootstrap.min.js" integrity="sha384-JZR6Spejh4U02d8jOt6vLEHfe/JQGiRRSQQxSfFWpi1MquVdAyjUar5+76PVCmYl" crossorigin="anonymous"/>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>