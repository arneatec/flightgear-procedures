<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:math="http://exslt.org/math"
                xmlns:xls="http://www.w3.org/1999/XSL/Transform"
                extension-element-prefixes="math">
    <xsl:variable name="airport" select="document('LBSF_airport.xml')"/>
        <!-- page related constants -->
    <xsl:variable name="svg_size" select="1000"/>

    <xsl:variable name="math_PI" select="3.14159265"/>
    <xsl:variable name="math_deg_to_rad"><xsl:value-of select="$math_PI div 180"/></xsl:variable>

    <xsl:variable name="geo_earth_radius" select="6378137" />
    <xsl:variable name="geo_nm_in_meters" select="1852"/>
    <xsl:variable name="geo_one_g" select="9.80665"/>

        <!-- major map constants -->
    <xsl:variable name="map_zoom" select="/Chart/Zoom"/>
    <xsl:variable name="map_offset_X" select="/Chart/Offset_X"/>
    <xsl:variable name="map_offset_Y" select="/Chart/Offset_Y"/>
    
    <xsl:template match="/">
        
        <html>
            <body>
                <svg>
                    <xsl:attribute name="width"><xsl:value-of select="$svg_size"/></xsl:attribute>
                    <xsl:attribute name="height"><xsl:value-of select="$svg_size"/></xsl:attribute>

                    <!-- draw points and lines -->
                    <xsl:for-each select="/Chart/Arc/Point">
                        <xsl:variable name="pointX"><xsl:value-of select="floor((Longitude * $math_deg_to_rad * $geo_earth_radius) div $map_zoom) + $map_offset_X"/></xsl:variable>
                        <xsl:variable name="pointY"><xsl:value-of select="$svg_size - floor((math:log(math:tan(Latitude * $math_deg_to_rad div 2 + $math_PI div 4)) * $geo_earth_radius) div ($map_zoom)) + $map_offset_Y"/></xsl:variable>
                        <xsl:variable name="next_pointX"><xsl:value-of select="floor((current()/following-sibling::Point[1]/Longitude * $math_deg_to_rad * $geo_earth_radius) div $map_zoom) + $map_offset_X"/></xsl:variable>
                        <xsl:variable name="next_pointY"><xsl:value-of select="$svg_size - floor((math:log(math:tan(current()/following-sibling::Point[1]/Latitude * $math_deg_to_rad div 2 + $math_PI div 4)) * $geo_earth_radius) div ($map_zoom)) + $map_offset_Y"/></xsl:variable>
                        <xsl:variable name="turn_radius_meters">
                            <xsl:value-of select="(math:power((220 * $geo_nm_in_meters) div 3600, 2) div ($geo_one_g * math:tan(25 * $math_deg_to_rad)))"/>
                        </xsl:variable>
                        <xsl:variable name="turn_radius_pixels">
                            <xsl:value-of select="$turn_radius_meters div $map_zoom"/>
                        </xsl:variable>

                        <!-- draw the points -->
                        <circle>
                                <xsl:attribute name="cx"><xsl:value-of select="$pointX"/></xsl:attribute>
                                <xsl:attribute name="cy"><xsl:value-of select="$pointY"/></xsl:attribute>
                                <xsl:attribute name="r">3</xsl:attribute>
                                <xsl:attribute name="fill"><xsl:value-of select="fill"/></xsl:attribute>
                        </circle>

                        <xsl:if test="number($next_pointX) = $next_pointX">
                            <!-- draw a straight line to the points -->
                            <line>
                                <xsl:attribute name="x1"><xsl:value-of select="$pointX"/></xsl:attribute>
                                <xsl:attribute name="x2"><xsl:value-of select="$next_pointX"/></xsl:attribute>
                                <xsl:attribute name="y1"><xsl:value-of select="$pointY"/></xsl:attribute>
                                <xsl:attribute name="y2"><xsl:value-of select="$next_pointY"/></xsl:attribute>
                                <xsl:attribute name="stroke">gray</xsl:attribute>
                            </line>
                            <!-- draw a circle to left/right -->
                            <circle>
                                <xsl:attribute name="cx">
                                    <xsl:choose>
                                        <xsl:when test="Turn='Right'">
                                            <xsl:value-of select="$pointX + $turn_radius_pixels"/>
                                        </xsl:when>
                                        <xsl:when test="Turn='Left'">
                                            <xsl:value-of select="$pointX - $turn_radius_pixels"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            WARN : Unexpected turn direction
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:attribute>
                                <xsl:attribute name="cy"><xsl:value-of select="$pointY"/></xsl:attribute>
                                <xsl:attribute name="r"><xsl:value-of select="$turn_radius_pixels"/></xsl:attribute>
                                <xsl:attribute name="stroke">blue</xsl:attribute>
                                <xsl:attribute name="fill">none</xsl:attribute>
                            </circle>
                        </xsl:if>
                    </xsl:for-each>
                    <!-- path -->
                    <path>
                        <xsl:attribute name="d">
                            M <xsl:value-of select="200"/><xsl:text> </xsl:text><xsl:value-of select="200"/>
                                <xsl:for-each select="/Chart/Arc/Point">
                                    <xsl:variable name="pointX"><xsl:value-of select="floor((Longitude * $math_deg_to_rad * $geo_earth_radius) div $map_zoom) + $map_offset_X"/></xsl:variable>
                                    <xsl:variable name="pointY"><xsl:value-of select="$svg_size - floor((math:log(math:tan(Latitude * $math_deg_to_rad div 2 + $math_PI div 4)) * $geo_earth_radius) div ($map_zoom)) + $map_offset_Y"/></xsl:variable>
                                    <xsl:variable name="next_pointX"><xsl:value-of select="floor((current()/following-sibling::Point[1]/Longitude * $math_deg_to_rad * $geo_earth_radius) div $map_zoom) + $map_offset_X"/></xsl:variable>
                                    <xsl:variable name="next_pointY"><xsl:value-of select="$svg_size - floor((math:log(math:tan(current()/following-sibling::Point[1]/Latitude * $math_deg_to_rad div 2 + $math_PI div 4)) * $geo_earth_radius) div ($map_zoom)) + $map_offset_Y"/></xsl:variable>
                                    <xsl:variable name="turn_radius_meters">
                                        <xsl:value-of select="(math:power((220 * $geo_nm_in_meters) div 3600, 2) div ($geo_one_g * math:tan(25 * $math_deg_to_rad)))"/>
                                    </xsl:variable>
                                    <xsl:variable name="turn_radius_pixels">
                                        <xsl:value-of select="$turn_radius_meters div $map_zoom"/>
                                    </xsl:variable>
                                    <xsl:variable name="turn_radius_pixels_signed">
                                        <xsl:choose>
                                            <xsl:when test="Turn='Right'">
                                                <xsl:value-of select="$turn_radius_pixels"/>
                                            </xsl:when>
                                            <xsl:when test="Turn='Left'">
                                                <xsl:value-of select="$turn_radius_pixels * -1"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                WARN : Unexpected turn direction
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:variable>


                                    <xsl:choose>
                                        <xsl:when test="number($next_pointX) = $next_pointX">
                                            M <xsl:value-of select="$pointX"/><xsl:text> </xsl:text><xsl:value-of select="$pointY"/>

                                            <!-- thanks to https://stackoverflow.com/questions/49968720/find-tangent-points-in-a-circle-from-a-point -->

                                            <!-- now we need to get to the tangential point on the circle
                                            center of arc circle : <xsl:value-of select="$pointX + $turn_radius_pixels"/><xsl:text>, </xsl:text><xsl:value-of select="$pointY"/>
                                            next point: <xsl:value-of select="$next_pointX"/><xsl:text>, </xsl:text><xsl:value-of select="$next_pointY"/>
                                            tangent point:
                                            -->

                                            <xsl:variable name="Cx">
                                                <xsl:value-of select="$pointX + (($turn_radius_pixels_signed) div math:cos($pointY * $math_deg_to_rad) )"/>
                                            </xsl:variable>
                                            <xsl:variable name="Cy">
                                                <xsl:value-of select="$pointY"/>
                                            </xsl:variable>
                                            <xsl:variable name="Px">
                                                <xsl:value-of select="$next_pointX"/>
                                            </xsl:variable>
                                            <xsl:variable name="Py">
                                                <xsl:value-of select="$next_pointY"/>
                                            </xsl:variable>
                                            <xsl:variable name="a">
                                                <xsl:value-of select="$turn_radius_pixels"/>
                                            </xsl:variable>
                                            <xsl:variable name="b">
                                                <xsl:value-of select="math:sqrt(math:power($Px - $Cx, 2) + math:power($Py - $Cy, 2))"/>
                                            </xsl:variable>
                                            <xsl:variable name="th">
                                                <xsl:value-of select="math:acos($a div $b)"/>
                                            </xsl:variable>

                                            <!--
                                            d = atan2(Py - Cy, Px - Cx)  # direction angle of point P from C
                                            -->
                                            <xsl:variable name="d">
                                                <xsl:value-of select="math:atan2($Py - $Cy, $Px - $Cx)"/>
                                            </xsl:variable>

                                            <!--
                                            d1 = d + th  # direction angle of point T1 from C
                                            -->
                                            <xsl:variable name="d1">
                                                <xsl:value-of select="$d + $th"/>
                                            </xsl:variable>

                                            <!--
                                            d2 = d - th  # direction angle of point T2 from C
                                            -->
                                            <xsl:variable name="d2">
                                                <xsl:value-of select="$d - $th"/>
                                            </xsl:variable>

                                            <!--
                                            T1x = Cx + a * cos(d1)
                                            -->
                                            <xsl:variable name="T1x">
                                                <xsl:value-of select="$Cx + $a * math:cos(number($d1))"/>
                                            </xsl:variable>

                                            <!--
                                            T1y = Cy + a * sin(d1)
                                            -->
                                            <xsl:variable name="T1y">
                                                <xsl:value-of select="$Cy + $a * math:sin(number($d1))"/>
                                            </xsl:variable>

                                            <!--
                                            T2x = Cx + a * cos(d1)
                                            -->
                                            <xsl:variable name="T2x">
                                                <xsl:value-of select="$Cx + $a * math:cos(number($d2))"/>
                                            </xsl:variable>

                                            <!--
                                            T2y = Cy + a * sin(d1)
                                            -->
                                            <xsl:variable name="T2y">
                                                <xsl:value-of select="$Cy + $a * math:sin(number($d2))"/>
                                            </xsl:variable>



                                            <!--
                                            center_of_arc_circle_x : <xsl:value-of select="$Cx"/>
                                            center_of_arc_circle_y : <xsl:value-of select="$Cy"/>
                                            radius : <xsl:value-of select="$a"/>
                                            direction angle of point P from C : <xsl:value-of select="$d"/>
                                            direction angle of point T1 from C : <xsl:value-of select="$d1"/>
                                            direction angle of point T2 from C <xsl:value-of select="$d2"/>

                                            tangent point 1 x: <xsl:value-of select="$T1x"/>
                                            tangent point 1 y: <xsl:value-of select="$T1y"/>
                                            -->

                                            <xsl:variable name="arch_clockwise_flag">
                                                <xsl:choose>
                                                    <xsl:when test="Turn='Right'">
                                                        1
                                                    </xsl:when>
                                                    <xsl:when test="Turn='Left'">
                                                        0
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        WARN : Unable to establish turn direction
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:variable>

                                            <xsl:variable name="TtrueX">
                                                <xsl:choose>
                                                    <xsl:when test="Turn='Left'">
                                                        <xsl:value-of select="$T1x"/>
                                                    </xsl:when>
                                                    <xsl:when test="Turn='Right'">
                                                        <xsl:value-of select="$T2x"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        WARN : Unable to establish turn direction
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:variable>

                                            <xsl:variable name="TtrueY">
                                                <xsl:choose>
                                                    <xsl:when test="Turn='Left'">
                                                        <xsl:value-of select="$T1y"/>
                                                    </xsl:when>
                                                    <xsl:when test="Turn='Right'">
                                                        <xsl:value-of select="$T2y"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        WARN : Unable to establish turn direction
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:variable>

                                            A <xsl:value-of select="$turn_radius_pixels"/><xsl:text> </xsl:text><xsl:value-of select="$turn_radius_pixels"/><xsl:text> </xsl:text>0<xsl:text> </xsl:text>0<xsl:text> </xsl:text><xsl:value-of select="$arch_clockwise_flag"/><xsl:text> </xsl:text><xsl:value-of select="$TtrueX"/><xsl:text> </xsl:text><xsl:value-of select="$TtrueY"/>


                                            <!--
                                            L <xsl:value-of select="$T2x"/><xsl:text> </xsl:text><xsl:value-of select="$T2y"/>
                                            -->
                                            L <xsl:value-of select="$next_pointX"/><xsl:text> </xsl:text><xsl:value-of select="$next_pointY"/>
                                        </xsl:when>
                                        <xsl:otherwise>

                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:for-each>
                        </xsl:attribute>
                        <xsl:attribute name="fill">none</xsl:attribute>
                        <xsl:attribute name="stroke">red</xsl:attribute>
                    </path>
                </svg>
            </body>
        </html>
        
    </xsl:template>
</xsl:stylesheet>