<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:math="http://exslt.org/math"
                xmlns:xls="http://www.w3.org/1999/XSL/Transform"
                extension-element-prefixes="math">
        <!-- imports -->
    <xsl:variable name="airport" select="document('LBSF_airport.xml')"/>
    <xsl:variable name="waypoints" select="document('LBSF_waypoints.xml')"/>
    <xsl:variable name="maplines" select="document('map_lines.xml')"/>

    <!-- page related constants -->
    <xsl:variable name="svg_size" select="1000"/>

    <!-- math constants -->
    <xsl:variable name="math_PI" select="3.14159265"/>
    <xsl:variable name="math_deg_to_rad"><xsl:value-of select="$math_PI div 180"/></xsl:variable>

    <!-- geodesic constants -->
    <xsl:variable name="geo_nm_in_meters" select="1852"/>
    <xsl:variable name="geo_feet_in_meters" select="3.2808"/>
    <xsl:variable name="geo_earth_radius" select="6378137" />
    <xsl:variable name="geo_magnetic_variation" select="$airport/Airport/MagneticVariation"/>
    <xsl:variable name="geo_one_g" select="9.80665"/>

    <!-- major map constants -->
    <xsl:variable name="map_zoom" select="/Chart/Zoom"/>
    <xsl:variable name="map_offset_X" select="/Chart/Offset_X"/>
    <xsl:variable name="map_offset_Y" select="/Chart/Offset_Y"/>

    <xsl:variable name="map_base_airport_rwy" select="$airport/Airport/Runways/Runway[ID=/Chart/Chart_Object_ID]"/>
    <xsl:variable name="map_base_airport_rwy_length" select="$map_base_airport_rwy/RunwayLenght"/>
    <xsl:variable name="map_base_airport_rwy_direction" select="$map_base_airport_rwy/RunwayDirection"/>

    <!-- minor map constants -->
    <xsl:variable name="map_label_circle_radius" select="24"/>
    <xsl:variable name="map_secondary_airport_radius" select="8"/>
    <xsl:variable name="map_secondary_airport_runway_length" select="10"/>

    <!-- waypoint elements constants -->
    <xsl:variable name="element_vor_rectangle_x_side" select="12"/>
    <xsl:variable name="element_vor_rectangle_y_side" select="10"/>
    <xsl:variable name="element_msa_outer_circle" select="65"/>


    <!-- major calculated values -->
    <xsl:variable name="runwayX">
        <xsl:value-of select="floor(($map_base_airport_rwy/RunwayThreshold/Longitude * $math_deg_to_rad * $geo_earth_radius) div $map_zoom) + $map_offset_X"/>
    </xsl:variable>
    <xsl:variable name="runwayY">
        <xsl:value-of select="$svg_size - floor((math:log(math:tan($map_base_airport_rwy/RunwayThreshold/Latitude * $math_deg_to_rad div 2 + $math_PI div 4)) * $geo_earth_radius) div ($map_zoom)) + $map_offset_Y"/>
    </xsl:variable>

    <xsl:variable name="control_point_X">
        <xsl:value-of select="floor(($airport/Airport/ControlPoint/Longitude * $math_deg_to_rad * $geo_earth_radius) div $map_zoom) + $map_offset_X"/>
    </xsl:variable>
    <xsl:variable name="control_point_Y">
        <xsl:value-of select="$svg_size - floor((math:log(math:tan($airport/Airport/ControlPoint/Latitude * $math_deg_to_rad div 2 + $math_PI div 4)) * $geo_earth_radius) div ($map_zoom)) + $map_offset_Y"/>
    </xsl:variable>

    <xsl:template match="/">
        <html>
            <xsl:comment>
                map_base_airport_rwy : <xsl:value-of select="$map_base_airport_rwy"/>
            </xsl:comment>
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
                            <xsl:for-each select="/Chart/SID_Page/SID_Core">
                                <path>
                                    <xsl:attribute name="d">
                                    M <xsl:value-of select="$runwayX"/><xsl:text> </xsl:text><xsl:value-of select="$runwayY"/>
                                    <xsl:for-each select="Waypoints/Waypoint">
                                        <xsl:variable name="pointX"><xsl:value-of select="floor(($waypoints/Waypoins/Waypoint[ID=current()/WPTID]/Longitude * $math_deg_to_rad * $geo_earth_radius) div $map_zoom) + $map_offset_X"/></xsl:variable>
                                        <xsl:variable name="pointY"><xsl:value-of select="$svg_size - floor((math:log(math:tan($waypoints/Waypoins/Waypoint[ID=current()/WPTID]/Latitude * $math_deg_to_rad div 2 + $math_PI div 4)) * $geo_earth_radius) div ($map_zoom)) + $map_offset_Y"/></xsl:variable>
                                        <xsl:variable name="next_pointX"><xsl:value-of select="floor(($waypoints/Waypoins/Waypoint[ID=current()/following-sibling::Waypoint[1]/WPTID]/Longitude * $math_deg_to_rad * $geo_earth_radius) div $map_zoom) + $map_offset_X"/></xsl:variable>
                                        <xsl:variable name="next_pointY"><xsl:value-of select="$svg_size - floor((math:log(math:tan($waypoints/Waypoins/Waypoint[ID=current()/following-sibling::Waypoint[1]/WPTID]/Latitude * $math_deg_to_rad div 2 + $math_PI div 4)) * $geo_earth_radius) div ($map_zoom)) + $map_offset_Y"/></xsl:variable>
                                        <xsl:variable name="previous_pointX"><xsl:value-of select="floor(($waypoints/Waypoins/Waypoint[ID=current()/preceding-sibling::Waypoint[1]/WPTID]/Longitude * $math_deg_to_rad * $geo_earth_radius) div $map_zoom) + $map_offset_X"/></xsl:variable>
                                        <xsl:variable name="previous_pointY"><xsl:value-of select="$svg_size - floor((math:log(math:tan($waypoints/Waypoins/Waypoint[ID=current()/preceding-sibling::Waypoint[1]/WPTID]/Latitude * $math_deg_to_rad div 2 + $math_PI div 4)) * $geo_earth_radius) div ($map_zoom)) + $map_offset_Y"/></xsl:variable>
                                        <xsl:variable name="this_point_turn_direction"><xsl:value-of select="Turn"/></xsl:variable>

                                        <xsl:variable name="turn_radius_meters">
                                            <xsl:value-of select="(math:power((220 * $geo_nm_in_meters) div 3600, 2) div ($geo_one_g * math:tan(12.5 * $math_deg_to_rad)))"/>
                                        </xsl:variable>
                                        <xsl:variable name="turn_radius_pixels">
                                            <xsl:value-of select="$turn_radius_meters div $map_zoom"/>
                                        </xsl:variable>
                                        <xsl:variable name="turn_radius_pixels_signed">
                                        <xsl:choose>
                                            <xsl:when test="$this_point_turn_direction='Right'">
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


                                        <xsl:variable name="track_geo">
                                            <xsl:value-of select="substring-before(substring-after(Track, '('),'°')"/>
                                        </xsl:variable>
                                        <xsl:variable name="next_track_geo">
                                            <xsl:value-of select="substring-before(substring-after(current()/following-sibling::Waypoint[1]/Track, '('),'°')"/>
                                        </xsl:variable>
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
                                                <xsl:variable name="ca_length_meters">
                                                    <xsl:value-of select="((number(translate(Altitude, '-+','')) - $airport/Airport/ElevationFeet) div ../../ClimbGradientFeetPerNauticalMile) * $geo_nm_in_meters"/>
                                                </xsl:variable>
                                                <xsl:variable name="ca_end_x">
                                                    <xsl:value-of select="$runwayX + floor(($ca_length_meters div $map_zoom) * math:cos((($track_geo - 90 ) * $math_deg_to_rad)))"/>
                                                </xsl:variable>
                                                <xsl:variable name="ca_end_y">
                                                    <xsl:value-of select="$runwayY + floor(($ca_length_meters div $map_zoom) * math:sin((($track_geo + 90 ) * $math_deg_to_rad)))"/>
                                                </xsl:variable>
                                                Q <xsl:value-of select="$ca_end_x"/><xsl:text> </xsl:text><xsl:value-of select="$ca_end_y"/><xsl:text> </xsl:text><xsl:value-of select="$next_pointX"/><xsl:text> </xsl:text><xsl:value-of select="$next_pointY"/>
                                            </xsl:when>
                                            <xsl:when test="Flyover='Yes' and not(Turn='-')">
                                                <!-- a point that needs to draw a Bézier curve (calculated rather randomly on the chart it looks at first glance)
                                                    let's try to unravel:
                                                     1. the aircraft will always continue on the previous_point:track and make the left/right turn
                                                     2. the aircraft goes into a new track when done with the turn, this  new track will take it to the current_point:location

                                                    https://en.wikipedia.org/wiki/Standard_rate_turn
                                                    the angle of the curve has several constraint:
                                                    1. the aircraft has a standard turn rate; normally it does not exceed it (making it a max turn rate)
                                                    2. the aircraft has a half turn rate, and also an arbitrary turn rate, none of which exceed the standard turn rate
                                                    3. we can assume that the pilot/autopilot will do a standard turn for any course change, especially on climb-out
                                                        when the passengers are secured by seatbelts
                                                    4. so the formula for the radius, if given velocity and the angle of bank are given. is:
                                                    r = (Vt.Vt/g*tan(phi)
                                                    where g is the gravitational acceleration, Vt is the speed in m/sec, angle of bank is in .. what, degrees, rads?
                                                    5. we assume the Vt is something like 220 knots
                                                    6. turn radius is thus 2800+ m, sounds reasonable
                                                -->
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
                                                    <xsl:when test="$this_point_turn_direction='Right'">
                                                        1
                                                    </xsl:when>
                                                    <xsl:when test="$this_point_turn_direction='Left'">
                                                        0
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        WARN : Unable to establish turn direction for <xsl:value-of select="WPTID"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:variable>

                                            <xsl:variable name="TtrueX">
                                                <xsl:choose>
                                                    <xsl:when test="$this_point_turn_direction='Left'">
                                                        <xsl:value-of select="$T1x"/>
                                                    </xsl:when>
                                                    <xsl:when test="$this_point_turn_direction='Right'">
                                                        <xsl:value-of select="$T2x"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        WARN : Unable to establish turn direction for <xsl:value-of select="WPTID"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:variable>

                                            <xsl:variable name="TtrueY">
                                                <xsl:choose>
                                                    <xsl:when test="$this_point_turn_direction='Left'">
                                                        <xsl:value-of select="$T1y"/>
                                                    </xsl:when>
                                                    <xsl:when test="$this_point_turn_direction='Right'">
                                                        <xsl:value-of select="$T2y"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        WARN : Unable to establish turn direction for <xsl:value-of select="WPTID"/>
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
                                                L <xsl:value-of select="$pointX"/><xsl:text> </xsl:text><xsl:value-of select="$pointY"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:for-each>
                                    </xsl:attribute>
                                    <xsl:attribute name="stroke">black</xsl:attribute>
                                    <xsl:attribute name="fill">none</xsl:attribute>
                                </path>
                                <!-- track circle -->
                                <xsl:for-each select="Waypoints/Waypoint">

                                    <xsl:choose>
                                    <xsl:when test="PT='CA'">
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <!-- generic case - point has track and distance -->
                                        <xsl:variable name="pointX">
                                            <xsl:value-of select="floor(($waypoints/Waypoins/Waypoint[ID=current()/WPTID]/Longitude * $math_deg_to_rad * $geo_earth_radius) div $map_zoom) + $map_offset_X"/>
                                        </xsl:variable>
                                        <xsl:variable name="pointY">
                                            <xsl:value-of select="$svg_size - floor((math:log(math:tan($waypoints/Waypoins/Waypoint[ID=current()/WPTID]/Latitude * $math_deg_to_rad div 2 + $math_PI div 4)) * $geo_earth_radius) div ($map_zoom)) + $map_offset_Y"/>
                                        </xsl:variable>
                                        <xsl:variable name="track_geo">
                                            <xsl:value-of select="substring-before(substring-after(current()/Track, '('),'°')"/>
                                        </xsl:variable>
                                        <circle>
                                            <xsl:attribute name="cx"><xsl:value-of select="$pointX"/></xsl:attribute>
                                            <xsl:attribute name="cy"><xsl:value-of select="$pointY"/></xsl:attribute>
                                            <xsl:attribute name="r">3</xsl:attribute>
                                            <xsl:attribute name="fill">green</xsl:attribute>
                                        </circle>
                                        <xsl:if test="WPTID='GOL'">
                                            <circle>
                                                <xsl:attribute name="cx"><xsl:value-of select="$pointX"/></xsl:attribute>
                                                <xsl:attribute name="cy"><xsl:value-of select="$pointY"/></xsl:attribute>
                                                <xsl:attribute name="r"><xsl:value-of select="(80530 div $map_zoom) div math:cos($waypoints/Waypoins/Waypoint[ID=current()/WPTID]/Latitude * $math_deg_to_rad)"/></xsl:attribute>
                                                <xsl:attribute name="stroke">blue</xsl:attribute>
                                                <xsl:attribute name="fill">none</xsl:attribute>
                                            </circle>
                                        </xsl:if>
                                        <!-- check that there is a point -->
                                        <xsl:choose>
                                            <xsl:when test="number($pointX) = $pointX and number(DIST) = DIST and not(Track='-')">
                                                <!--
                                                SUCCESS : Point <xsl:value-of select="WPTID"/> has X, DIST and Track
                                                -->
                                                <!-- understand this formula and make it generic
                                                    1. to draw lines of the x,y, distance type, you need to understand that the web Mercator projection has different lengths at different latitudes!
                                                    2. NB : To calculate in meters (or nm, ft) for X coordinate, to need to divide the distance by the cosine of the latitude of the local area in which you are drawing
                                                        (normally this will be the pointY, etc.)
                                                        so the formula is:
                                                        x=(distance_in_meters / map_zoom) / cos(y_in_radians)

                                                        see how midway_distance_in_pixels is calculated below, note that this is half the distance (div 2)

                                                        GREAT SUCCESS!
                                                -->
                                                <xsl:variable name="midway_distance_in_pixels">
                                                    <xsl:value-of select="(((DIST * $geo_nm_in_meters) div $map_zoom) div 2) div math:cos($waypoints/Waypoins/Waypoint[ID=current()/WPTID]/Latitude * $math_deg_to_rad)"/>
                                                </xsl:variable>

                                                <xsl:variable name="track_circle_X">
                                                    <xsl:value-of select="$pointX - floor($midway_distance_in_pixels * math:cos((($track_geo - 90 ) * $math_deg_to_rad)))"/>
                                                </xsl:variable>
                                                <!-- debug circle that should intersect at the halfway line
                                                <circle>
                                                    <xsl:attribute name="cx"><xsl:value-of select="$pointX"/></xsl:attribute>
                                                    <xsl:attribute name="cy"><xsl:value-of select="$pointY"/></xsl:attribute>
                                                    <xsl:attribute name="r"><xsl:value-of select="floor($midway_distance_in_pixels)"/></xsl:attribute>
                                                    <xsl:attribute name="fill">none</xsl:attribute>
                                                    <xsl:attribute name="stroke">red</xsl:attribute>
                                                </circle>

                                                <text>
                                                    <xsl:attribute name="x"><xsl:value-of select="$pointX"/></xsl:attribute>
                                                    <xsl:attribute name="y"><xsl:value-of select="$pointY + 20"/></xsl:attribute>
                                                    pixels : <xsl:value-of select="$midway_distance_in_pixels"/>
                                                </text>
                                                <text>
                                                    <xsl:attribute name="x"><xsl:value-of select="$pointX"/></xsl:attribute>
                                                    <xsl:attribute name="y"><xsl:value-of select="$pointY + 40"/></xsl:attribute>
                                                    NM : <xsl:value-of select="DIST"/>
                                                </text>
                                                <text>
                                                    <xsl:attribute name="x"><xsl:value-of select="$pointX"/></xsl:attribute>
                                                    <xsl:attribute name="y"><xsl:value-of select="$pointY + 60"/></xsl:attribute>
                                                    meters : <xsl:value-of select="DIST * $geo_nm_in_meters"/>
                                                </text>
                                                -->
                                                <xsl:variable name="track_circle_Y">
                                                    <xsl:value-of select="$pointY + floor($midway_distance_in_pixels * math:sin((($track_geo + 90 ) * $math_deg_to_rad)))"/>
                                                </xsl:variable>
                                                <circle>
                                                    <xsl:attribute name="cx"><xsl:value-of select="$track_circle_X"/></xsl:attribute>
                                                    <xsl:attribute name="cy"><xsl:value-of select="$track_circle_Y"/></xsl:attribute>
                                                    <xsl:attribute name="r"><xsl:value-of select="$map_label_circle_radius"/></xsl:attribute>
                                                    <xsl:attribute name="fill">white</xsl:attribute>
                                                    <xsl:attribute name="stroke">none</xsl:attribute>
                                                </circle>
                                                <!-- the track text -->
                                                <text>
                                                    <xsl:attribute name="text-anchor">middle</xsl:attribute>
                                                    <xsl:attribute name="alignment-baseline">middle</xsl:attribute>
                                                    <xsl:attribute name="transform">translate(<xsl:value-of select="$track_circle_X"/>, <xsl:value-of select="$track_circle_Y"/>) rotate(
                                                        <xsl:choose>
                                                            <xsl:when test="$track_geo > 180">
                                                                <xsl:value-of select="$track_geo - 90 - 180"/>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:value-of select="$track_geo  -  90"/>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                        )</xsl:attribute>
                                                    <xsl:attribute name="fill">black</xsl:attribute>
                                                    <tspan x="0" dy="0em">
                                                        <xsl:if test="$track_circle_X &lt; ($svg_size div 2)">
                                                            <xsl:text>&lt;</xsl:text>
                                                        </xsl:if>
                                                        <xsl:value-of select="substring-before(Track,'(')"/>
                                                        <xsl:if test="not($track_circle_X &lt; ($svg_size div 2))">
                                                            <xsl:text>&gt;</xsl:text>
                                                        </xsl:if>
                                                    </tspan>
                                                    <tspan x="0" dy="0.8em">
                                                        <xsl:value-of select="DIST"/>
                                                    </tspan>
                                                 </text>

                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:comment>
                                                    WARN : Waypoint <xsl:value-of select="WPTID"/> has no numeric $pointX variable or numeric DIST attribute or Track attribute
                                                    $pointX is : <xsl:value-of select="$pointX"/>
                                                    DIST is : <xsl:value-of select="DIST"/>
                                                    Track is : <xsl:value-of select="Track"/>
                                                </xsl:comment>
                                                <xsl:if test="number($pointX) = $pointX">
                                                    <!-- this has a point but is missing dist or track -->
                                                    <xsl:if test="not(number(current()/DIST) = current()/DIST)">
                                                        <!-- no distance, so the calculation should be based on next point data -->
                                                        <xsl:variable name="next_pointX">
                                                            <xsl:value-of select="floor(($waypoints/Waypoins/Waypoint[ID=current()/following-sibling::Waypoint[1]/WPTID]/Longitude * $math_deg_to_rad * $geo_earth_radius) div $map_zoom) + $map_offset_X"/>
                                                        </xsl:variable>
                                                        <xsl:variable name="next_pointY">
                                                            <xsl:value-of select="$svg_size - floor((math:log(math:tan($waypoints/Waypoins/Waypoint[ID=current()/following-sibling::Waypoint[1]/WPTID]/Latitude * $math_deg_to_rad div 2 + $math_PI div 4)) * $geo_earth_radius) div ($map_zoom)) + $map_offset_Y"/>
                                                        </xsl:variable>
                                                        <!-- distance calculation
                                                            we need to calculate the distance between two coordinates, using the Haversine formula
                                                            d = 2r * arcsin(sqrt(sin²(Δφ/2) + cos(φ1) * cos(φ2) * sin²(Δλ/2)))

                                                            Where:
                                                            - d is the distance between the two points
                                                            - r is the radius of the Earth (6,371 km)
                                                            - Δφ is the difference in latitude between the two points
                                                            - Δλ is the difference in longitude between the two points
                                                            - φ1 and φ2 are the latitudes of the two points
                                                        -->
                                                        <xsl:variable name="current_point_latitude">
                                                            <xsl:value-of select="number($waypoints/Waypoins/Waypoint[ID=current()/WPTID]/Latitude)"/>
                                                        </xsl:variable>
                                                        <xsl:variable name="current_point_longitude">
                                                            <xsl:value-of select="number($waypoints/Waypoins/Waypoint[ID=current()/WPTID]/Longitude)"/>
                                                        </xsl:variable>
                                                        <xsl:variable name="next_point_latitude">
                                                            <xsl:value-of select="number($waypoints/Waypoins/Waypoint[ID=current()/following-sibling::Waypoint[1]/WPTID]/Latitude)"/>
                                                        </xsl:variable>
                                                        <xsl:variable name="next_point_longitude">
                                                            <xsl:value-of select="number($waypoints/Waypoins/Waypoint[ID=current()/following-sibling::Waypoint[1]/WPTID]/Longitude)"/>
                                                        </xsl:variable>
                                                        <xsl:variable name="squared_sin_latitude_delta">
                                                            <xsl:value-of select="number(math:power(math:sin((($next_point_latitude - $current_point_latitude) * $math_deg_to_rad ) div 2), 2))"/>
                                                        </xsl:variable>
                                                        <xsl:variable name="squared_sin_longitude_delta">
                                                            <xsl:value-of select="number(math:power(math:sin((($next_point_longitude - $current_point_longitude) * $math_deg_to_rad) div 2), 2))"/>
                                                        </xsl:variable>

                                                        <xsl:variable name="square_root_inside_brackets">
                                                            <xsl:value-of select="number(math:sqrt($squared_sin_latitude_delta + number(math:cos($next_point_latitude * $math_deg_to_rad)) * number(math:cos($current_point_latitude * $math_deg_to_rad)) * $squared_sin_longitude_delta))"/>
                                                        </xsl:variable>

                                                        <xsl:variable name="result">
                                                            <xsl:value-of select="2 * $geo_earth_radius * math:asin(number($square_root_inside_brackets))"/>
                                                        </xsl:variable>
                                                        <xsl:variable name="result_NM">
                                                            <xsl:value-of select="round(($result div $geo_nm_in_meters ) * 10) div 10"/>
                                                        </xsl:variable>
                                                        <!--
                                                        <debug>
                                                            squared_sin_latitude_delta: <xsl:value-of select="$squared_sin_latitude_delta"/>
                                                            squared_sin_longitude_delta: <xsl:value-of select="$squared_sin_longitude_delta"/>
                                                            current_point_latitude:<xsl:value-of select="$current_point_latitude"/>
                                                            current_point_longitude:<xsl:value-of select="$current_point_longitude"/>
                                                            next_point_latitude:<xsl:value-of select="$next_point_latitude"/>
                                                            next_point_longitude:<xsl:value-of select="$next_point_longitude"/>
                                                            square_root_inside_brackets:<xsl:value-of select="$square_root_inside_brackets"/>
                                                            result:<xsl:value-of select="$result"/>
                                                            result_NM: <xsl:value-of select="$result_NM"/>

                                                        </debug>
                                                        -->
                                                        <!--
                                                        <xsl:variable name="test">
                                                            <xsl:value-of select="math:sqrt(number($squared_sin_latitude_delta))"/>
                                                        </xsl:variable>
                                                        -->
                                                        <circle>
                                                            <xsl:attribute name="cx"><xsl:value-of select="$pointX - (($pointX - $next_pointX) div 2)"/></xsl:attribute>
                                                            <xsl:attribute name="cy"><xsl:value-of select="$pointY - (($pointY - $next_pointY) div 2)"/></xsl:attribute>
                                                            <xsl:attribute name="r"><xsl:value-of select="$map_label_circle_radius - 7"/></xsl:attribute>
                                                            <xsl:attribute name="fill">white</xsl:attribute>
                                                            <xsl:attribute name="stroke">none</xsl:attribute>
                                                        </circle>
                                                        <text>
                                                            <xsl:attribute name="text-anchor">middle</xsl:attribute>
                                                            <xsl:attribute name="alignment-baseline">middle</xsl:attribute>
                                                            <xsl:attribute name="transform">translate(<xsl:value-of select="$pointX - (($pointX - $next_pointX) div 2)"/>, <xsl:value-of select="$pointY - (($pointY - $next_pointY) div 2)"/>) rotate(
                                                                <xsl:choose>
                                                                    <xsl:when test="$track_geo > 180">
                                                                        <xsl:value-of select="0"/>
                                                                    </xsl:when>
                                                                    <xsl:otherwise>
                                                                        <xsl:value-of select="0"/>
                                                                    </xsl:otherwise>
                                                                </xsl:choose>
                                                                )</xsl:attribute>
                                                            <xsl:attribute name="fill">black</xsl:attribute>
                                                               <xsl:value-of select="$result_NM"/>*
                                                         </text>

                                                    </xsl:if>
                                                </xsl:if>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:otherwise>
                                </xsl:choose>
                                </xsl:for-each>
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