<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:math="http://exslt.org/math"
                xmlns:xls="http://www.w3.org/1999/XSL/Transform"
                extension-element-prefixes="math">

    <!-- page related constants -->
    <xsl:variable name="svg_size" select="1000"/>

    <!-- math constants -->
    <xsl:variable name="math_PI" select="3.14159265"/>
    <xsl:variable name="math_deg_to_rad"><xsl:value-of select="$math_PI div 180"/></xsl:variable>

    <!-- geodesic constants -->
    <xsl:variable name="geo_nm_in_meters" select="1852"/>
    <xsl:variable name="geo_feet_in_meters" select="3.2808"/>
    <xsl:variable name="geo_earth_radius" select="6378137" />
    <xsl:variable name="geo_magnetic_variation" select="/Airport/Chart/MagneticVariation"/>

    <!-- major map constants -->
    <xsl:variable name="map_zoom" select="/Airport/Chart/Zoom"/>
    <xsl:variable name="map_offset_X" select="/Airport/Chart/Offset_X"/>
    <xsl:variable name="map_offset_Y" select="/Airport/Chart/Offset_Y"/>
    <xsl:variable name="map_base_airport_rwy_length" select="/Airport/Chart/RunwayLenght"/>
    <xsl:variable name="map_base_airport_rwy_direction" select="/Airport/Chart/RunwayDirection"/>

    <!-- minor map constants -->
    <xsl:variable name="map_label_circle_radius" select="22"/>
    <xsl:variable name="map_secondary_airport_radius" select="8"/>
    <xsl:variable name="map_secondary_airport_runway_length" select="10"/>

    <!-- waypoint elements constants -->
    <xsl:variable name="element_vor_rectangle_x_side" select="12"/>
    <xsl:variable name="element_vor_rectangle_y_side" select="10"/>
    <xsl:variable name="element_msa_outer_circle" select="65"/>


    <!-- major calculated values -->
    <xsl:variable name="runwayX">
        <xsl:value-of select="floor((/Airport/Chart/RunwayThreshold/Longitude * $math_deg_to_rad * $geo_earth_radius) div $map_zoom) + $map_offset_X"/>
    </xsl:variable>
    <xsl:variable name="runwayY">
        <xsl:value-of select="$svg_size - floor((math:log(math:tan(/Airport/Chart/RunwayThreshold/Latitude * $math_deg_to_rad div 2 + $math_PI div 4)) * $geo_earth_radius) div ($map_zoom)) + $map_offset_Y"/>
    </xsl:variable>

    <xsl:variable name="control_point_X">
        <xsl:value-of select="floor((/Airport/ControlPoint/Longitude * $math_deg_to_rad * $geo_earth_radius) div $map_zoom) + $map_offset_X"/>
    </xsl:variable>
    <xsl:variable name="control_point_Y">
        <xsl:value-of select="$svg_size - floor((math:log(math:tan(/Airport/ControlPoint/Latitude * $math_deg_to_rad div 2 + $math_PI div 4)) * $geo_earth_radius) div ($map_zoom)) + $map_offset_Y"/>
    </xsl:variable>

    <!-- length of the runway 'fly away extension' -->
    <xsl:variable name="takeOffExtension"><xsl:value-of select="/Airport/Chart/TakeOffFlyRunwayHeadingDistance"/></xsl:variable>
    <!-- extension end coordinates -->
    <xsl:variable name="endExtensionX"><xsl:value-of select="$runwayX + floor($takeOffExtension * math:cos(($map_base_airport_rwy_direction - 90) * $math_deg_to_rad))"/></xsl:variable>
    <xsl:variable name="endExtensionY"><xsl:value-of select="$runwayY + floor($takeOffExtension * math:sin(($map_base_airport_rwy_direction - 90) * $math_deg_to_rad))"/></xsl:variable>

    <!-- imports -->
    <xsl:variable name="waypoints" select="document('LBSF_waypoints.xml')"/>
    <xsl:variable name="maplines" select="document('map_lines.xml')"/>

    <xsl:template match="/">
        <html>
            <head>
                <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.0.0/dist/css/bootstrap.min.css" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous"/>
            </head>
            <body>
                <div class="container">
                        <svg>
                            <xsl:attribute name="width"><xsl:value-of select="$svg_size"/></xsl:attribute>
                            <xsl:attribute name="height"><xsl:value-of select="$svg_size"/></xsl:attribute>
                            <!-- control point -->
                            <circle>
                                <xsl:attribute name="cx"><xsl:value-of select="$runwayX"/></xsl:attribute>
                                <xsl:attribute name="cy"><xsl:value-of select="$runwayY"/></xsl:attribute>
                                <xsl:attribute name="r">3</xsl:attribute>
                                <xsl:attribute name="fill">red</xsl:attribute>
                            </circle>
                            <!-- runway threshold -->
                            <circle>
                                <xsl:attribute name="cx"><xsl:value-of select="$control_point_X"/></xsl:attribute>
                                <xsl:attribute name="cy"><xsl:value-of select="$control_point_Y"/></xsl:attribute>
                                <xsl:attribute name="r">3</xsl:attribute>
                                <xsl:attribute name="fill">green</xsl:attribute>
                            </circle>
                            <xsl:for-each select="/Airport/Chart/SID_Page/SID_Core">


                                <path>
                                    <xsl:attribute name="d">
                                    M <xsl:value-of select="$runwayX"/><xsl:text> </xsl:text><xsl:value-of select="$runwayY"/>
                                    <xsl:for-each select="Waypoints/Waypoint">
                                        <xsl:variable name="pointX"><xsl:value-of select="floor(($waypoints/Waypoins/Waypoint[ID=current()/WPTID]/Longitude * $math_deg_to_rad * $geo_earth_radius) div $map_zoom) + $map_offset_X"/></xsl:variable>
                                        <xsl:variable name="pointY"><xsl:value-of select="$svg_size - floor((math:log(math:tan($waypoints/Waypoins/Waypoint[ID=current()/WPTID]/Latitude * $math_deg_to_rad div 2 + $math_PI div 4)) * $geo_earth_radius) div ($map_zoom)) + //Airport/Chart/Offset_Y"/></xsl:variable>
                                        <xsl:variable name="next_pointX"><xsl:value-of select="floor(($waypoints/Waypoins/Waypoint[ID=current()/following-sibling::Waypoint[1]/WPTID]/Longitude * $math_deg_to_rad * $geo_earth_radius) div $map_zoom) + $map_offset_X"/></xsl:variable>
                                        <xsl:variable name="next_pointY"><xsl:value-of select="$svg_size - floor((math:log(math:tan($waypoints/Waypoins/Waypoint[ID=current()/following-sibling::Waypoint[1]/WPTID]/Latitude * $math_deg_to_rad div 2 + $math_PI div 4)) * $geo_earth_radius) div ($map_zoom)) + //Airport/Chart/Offset_Y"/></xsl:variable>

                                        <xsl:choose>
                                            <xsl:when test="PT='CA'">
                                                <!-- CA - climb to altitude, cannot use pointX, pointX
                                                    to calculate:
                                                    1. starting point is the runway threshold
                                                    2. then continue on self:track_geo until self:altitude
                                                    3. the distance from threshold to turn is the delta between the self:altitude and the runway elevation, divided vy the average takeoff climb rate
                                                        e.g. (alt - runway_elev) / average_climbo_out_rate  in ft and
                                                        example for LBSF Runway 27, SID GODEK 2T:
                                                          (2300 ft - 1745 ft) / 304 ft/NM = 1.8256 NM
                                                        however, the original chart has an exaggerated curve that implies that the takeoff is at 200 tf/NM
                                                        the exagerated value is used in this chart also (see ClimbGradientFeetPerNauticalMile node in SID)
                                                    4. so the first leg is:
                                                        M threshold_x threshold_y
                                                        Q climboutX climboutY nextpointX nextpointY (to have the correct curve)
                                                        note that the nextpoint variables use the first of the following-siblings, which is the next waypoint
                                                        on the next iterration of the <xsl:for-each waypoint , the next point is drawn again for simplicity:
                                                            Q 339 476 328 348
                                                            L 328 348
                                                        this is harmless and requires a lot of xslt coding to prevent, so it is left as is, as it does not visually change anything
                                                        FUTURE: the turn calculation left/right (sin,cos, whatever) is somewhat arbitrary, we need to test with the 09 SIDs to be sure it works generically
                                                -->
                                                <xsl:variable name="track_geo">
                                                    <xsl:value-of select="substring-before(substring-after(Track, '('),'°')"/>
                                                </xsl:variable>
                                                <xsl:variable name="ca_length_meters">
                                                    <xsl:value-of select="((number(translate(Altitude, '-+','')) - /Airport/ElevationFeet) div ../../ClimbGradientFeetPerNauticalMile) * $geo_nm_in_meters"/>
                                                </xsl:variable>
                                                <xsl:variable name="ca_end_x">
                                                    <xsl:value-of select="$runwayX + floor(($ca_length_meters div $map_zoom) * math:cos((($track_geo - 90 ) * $math_deg_to_rad)))"/>
                                                </xsl:variable>
                                                <xsl:variable name="ca_end_y">
                                                    <xsl:value-of select="$runwayY + floor(($ca_length_meters div $map_zoom) * math:sin((($track_geo + 90 ) * $math_deg_to_rad)))"/>
                                                </xsl:variable>
                                                Q <xsl:value-of select="$ca_end_x"/><xsl:text> </xsl:text><xsl:value-of select="$ca_end_y"/><xsl:text> </xsl:text><xsl:value-of select="$next_pointX"/><xsl:text> </xsl:text><xsl:value-of select="$next_pointY"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                L <xsl:value-of select="$pointX"/><xsl:text> </xsl:text><xsl:value-of select="$pointY"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:for-each>
                                    </xsl:attribute>
                                    <xsl:attribute name="stroke">black</xsl:attribute>
                                    <xsl:attribute name="fill">none</xsl:attribute>
                                </path>
                            </xsl:for-each>
                        </svg>
                </div>
                <script src="https://code.jquery.com/jquery-3.2.1.slim.min.js" integrity="sha384-KJ3o2DKtIkvYIK3UENzmM7KCkRr/rE9/Qpg6aAZGJwFDMVNA/GpGFF93hXpG5KkN" crossorigin="anonymous"/>
                <script src="https://cdn.jsdelivr.net/npm/popper.js@1.12.9/dist/umd/popper.min.js" integrity="sha384-ApNbgh9B+Y1QKtv3Rn7W3mgPxhU9K/ScQsAP7hUibX39j7fakFPskvXusvfa0b4Q" crossorigin="anonymous"/>
                <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.0.0/dist/js/bootstrap.min.js" integrity="sha384-JZR6Spejh4U02d8jOt6vLEHfe/JQGiRRSQQxSfFWpi1MquVdAyjUar5+76PVCmYl" crossorigin="anonymous"/>

            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>