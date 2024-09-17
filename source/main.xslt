<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:math="http://exslt.org/math"
                xmlns:xls="http://www.w3.org/1999/XSL/Transform"
                extension-element-prefixes="math">
    <!-- imports -->
    <xsl:variable name="airport" select="document('LBSF_airport.xml')"/>
    <xsl:variable name="waypoints" select="document('LBSF_waypoints.xml')"/>
    <xsl:variable name="maplines" select="document('map_lines.xml')"/>

    <!-- page related constants -->
    <xsl:variable name="svg_size" select="1130"/>

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

    <xsl:variable name="map_offset_X" select="((/Chart/MapCenter/Longitude * $math_deg_to_rad * $geo_earth_radius) div $map_zoom) * -1 + ($svg_size div 2)"/>
    <xsl:variable name="map_offset_Y" select="(math:log(math:tan(/Chart/MapCenter/Latitude * $math_deg_to_rad div 2 + $math_PI div 4)) * $geo_earth_radius div ($map_zoom)) - ($svg_size div 2)"/>

    <xsl:variable name="map_offset_X_legacy" select="/Chart/Offset_X"/>
    <xsl:variable name="map_offset_Y_legacy" select="/Chart/Offset_Y"/>

    <xsl:variable name="map_base_airport_rwy" select="$airport/Airport/Runways/Runway[ID=/Chart/Chart_Object_ID]"/>
    <xsl:variable name="map_base_airport_rwy_latitude" select="$map_base_airport_rwy/RunwayThreshold/Latitude"/>
    <xsl:variable name="map_base_airport_rwy_longitude" select="$map_base_airport_rwy/RunwayThreshold/Longitude"/>
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
    <xsl:variable name="runwayX"><xsl:call-template name="pointToPixelX"><xsl:with-param name="coordX" select="$map_base_airport_rwy_longitude"/></xsl:call-template></xsl:variable>
    <xsl:variable name="runwayY"><xsl:call-template name="pointToPixelY"><xsl:with-param name="coordY" select="$map_base_airport_rwy_latitude"/></xsl:call-template></xsl:variable>
    <xsl:variable name="runway_length"><xsl:value-of select="((($map_base_airport_rwy_length) div $map_zoom)) div math:cos($map_base_airport_rwy_latitude * $math_deg_to_rad)"/></xsl:variable>
    <xsl:variable name="control_point_X"><xsl:call-template name="pointToPixelX"><xsl:with-param name="coordX" select="$airport/Airport/ControlPoint/Longitude"/></xsl:call-template></xsl:variable>
    <xsl:variable name="control_point_Y"><xsl:call-template name="pointToPixelY"><xsl:with-param name="coordY" select="$airport/Airport/ControlPoint/Latitude"/></xsl:call-template></xsl:variable>

    <xsl:template match="/">
        <html>
            <head>
                <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.0.0/dist/css/bootstrap.min.css" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous"/>
            </head>
            <body>

                <div class="container">
                        <div class="row">
                            <div class="col-6">
                                <xsl:value-of select="/Chart/Publisher_Local"/>
                            </div>
                            <div class="col-6 text-right font-weight-bold">
                                <xsl:value-of select="/Chart/ID"/>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-6">
                                <xsl:value-of select="/Chart/Publisher"/>
                            </div>
                            <div class="col-6 text-right font-weight-bold">
                                <xsl:value-of select="/Chart/Published_On"/>
                            </div>
                        </div>
                        <div class="row">
                            <div class="card border-dark">
                                <div class="card-body">
                                    <div class="row">
                                        <div class="col-12 text-right font-weight-bold"><xsl:value-of select="/Chart/Airport_Location"/></div>
                                    </div>
                                    <div class="row">
                                        <div class="col-3 font-weight-bold"><xsl:value-of select="/Chart/Name"/></div>
                                        <div class="col-3">
                                            <div class="row">
                                                <div class="col-12">
                                                    TRANSITION ALT <xsl:value-of select="$airport/Airport/Transition_Altitude_ft"/> FT
                                                </div>
                                            </div>
                                            <div class="row">
                                                <div class="col-12">
                                                    TRANSITION LEVEL <xsl:value-of select="$airport/Airport/Transition_Level"/>
                                                </div>
                                            </div>
                                        </div>
                                        <xsl:for-each select="$airport/Airport/Radio_Role">
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
                                            <xsl:for-each select="/Chart/Includes/SID_ID">
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
                                        <xsl:for-each select="/Chart/SID_Page/SID_Core">
                                            <!-- map center -->
                                            <!--
                                            <circle cx="500" cy="500" r="5" fill="red"/>
                                            -->
                                            <!-- temporary visual markers -->
                                            <!--
                                            <circle>
                                                <xsl:attribute name="cx"><xsl:value-of select="$runwayX"/></xsl:attribute>
                                                <xsl:attribute name="cy"><xsl:value-of select="$runwayY"/></xsl:attribute>
                                                <xsl:attribute name="r">4</xsl:attribute>
                                                <xsl:attribute name="fill">red</xsl:attribute>
                                            </circle>
                                            -->
                                            <!-- each SID starts with the runway threshold -->
                                            <path>
                                                <xsl:attribute name="fill">none</xsl:attribute>
                                                <xsl:attribute name="stroke">black</xsl:attribute>
                                                <xsl:attribute name="stroke-width">2</xsl:attribute>
                                                <xsl:attribute name="d">
                                                    <!-- runway termination coordinates -->
                                                    <!-- start drawing -->
                                                    M <xsl:value-of select="$runwayX"/><xsl:text> </xsl:text><xsl:value-of select="$runwayY"/>

                                                    <!-- and finally the waypoints -->
                                                    <xsl:for-each select="Waypoints/Waypoint">
                                                        <xsl:variable name="pointX"><xsl:call-template name="pointToPixelX"><xsl:with-param name="coordX" select="$waypoints/Waypoins/Waypoint[ID=current()/WPTID]/Longitude"/></xsl:call-template></xsl:variable>
                                                        <xsl:variable name="pointY"><xsl:call-template name="pointToPixelY"><xsl:with-param name="coordY" select="$waypoints/Waypoins/Waypoint[ID=current()/WPTID]/Latitude"/></xsl:call-template></xsl:variable>
                                                        <xsl:variable name="next_pointX"><xsl:call-template name="pointToPixelX"><xsl:with-param name="coordX" select="$waypoints/Waypoins/Waypoint[ID=current()/following-sibling::Waypoint[1]/WPTID]/Longitude"/></xsl:call-template></xsl:variable>
                                                        <xsl:variable name="next_pointY"><xsl:call-template name="pointToPixelY"><xsl:with-param name="coordY" select="$waypoints/Waypoins/Waypoint[ID=current()/following-sibling::Waypoint[1]/WPTID]/Latitude"/></xsl:call-template></xsl:variable>
                                                        <xsl:variable name="this_point_turn_direction"><xsl:value-of select="Turn"/></xsl:variable>
                                                        <!-- hacky:  the LBSF original charts shows unrealistic curves, probably for presentation purposes only, sooooo... thry to emulate them by introducing coeeficients and stuff  -->
                                                        <xsl:variable name="runway_climnout_correction_factor">0.7</xsl:variable>
                                                        <xsl:variable name="ca_length_meters">
                                                            <xsl:value-of select="(((number(translate(Altitude, '-+','')) - $airport/Airport/ElevationFeet) div ../../ClimbGradientFeetPerNM) * $geo_nm_in_meters) * $runway_climnout_correction_factor"/>
                                                        </xsl:variable>

                                                        <xsl:variable name="bank_angle_for_flight_phase">
                                                            <xsl:choose>
                                                                <xsl:when test="Flyover = 'Yes'">
                                                                    12.5
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    25
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                        </xsl:variable>

                                                        <xsl:variable name="turn_radius_meters">
                                                            <xsl:value-of select="(math:power((220 * $geo_nm_in_meters) div 3600, 2) div ($geo_one_g * math:tan($bank_angle_for_flight_phase * $math_deg_to_rad)))"/>
                                                        </xsl:variable>
                                                        <xsl:variable name="turn_radius_pixels">
                                                            <xsl:value-of select="$turn_radius_meters div $map_zoom"/>
                                                        </xsl:variable>
                                                        <xsl:variable name="track_geo">
                                                            <xsl:value-of select="substring-before(substring-after(Track, '('),'°')"/>
                                                        </xsl:variable>
                                                        <xsl:variable name="ca_end_x">
                                                            <xsl:value-of select="$runwayX + floor(((($ca_length_meters) div $map_zoom ) * math:cos((($track_geo - 90 ) * $math_deg_to_rad))) div math:cos($map_base_airport_rwy_longitude * $math_deg_to_rad))"/>
                                                        </xsl:variable>
                                                        <xsl:variable name="ca_end_y">
                                                            <xsl:value-of select="$runwayY + floor(($ca_length_meters div $map_zoom) * math:sin((($track_geo - 90 ) * $math_deg_to_rad)))"/>
                                                        </xsl:variable>
                                                        <xsl:variable name="next_track_geo">
                                                            <xsl:value-of select="substring-before(substring-after(current()/following-sibling::Waypoint[1]/Track, '('),'°')"/>
                                                        </xsl:variable>


                                                        <!-- CA waypoints have no coordinate, sue the extension termination coordinates instead to calculate the arc -->
                                                        <xsl:variable name="real_pointX">
                                                            <xsl:choose>
                                                                <xsl:when test="PT='CA'">
                                                                    <xsl:value-of select="$ca_end_x"/>
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    <xsl:value-of select="$pointX"/>
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                        </xsl:variable>
                                                        <xsl:variable name="real_pointY">
                                                            <xsl:choose>
                                                                <xsl:when test="PT='CA'">
                                                                    <xsl:value-of select="$ca_end_y"/>
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    <xsl:value-of select="$pointY"/>
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                        </xsl:variable>

                                                            <xsl:variable name="turn_circle_track">
                                                                <xsl:choose>
                                                                    <xsl:when test="$this_point_turn_direction='Right'">
                                                                        <xsl:value-of select="($track_geo) mod 360"/>
                                                                    </xsl:when>
                                                                    <xsl:when test="$this_point_turn_direction='Left'">
                                                                        <xsl:value-of select="($track_geo - 180) mod 360"/>
                                                                    </xsl:when>
                                                                    <xsl:otherwise>
                                                                        WARN : Unable to establish turn direction for <xsl:value-of select="WPTID"/>
                                                                    </xsl:otherwise>
                                                                </xsl:choose>
                                                            </xsl:variable>



                                                            <xsl:variable name="Cx">
                                                                <xsl:value-of select="$real_pointX + (($turn_radius_pixels * math:cos($turn_circle_track * $math_deg_to_rad)))"/>
                                                            </xsl:variable>
                                                            <xsl:variable name="Cy">
                                                                <xsl:value-of select="$real_pointY + (($turn_radius_pixels * math:sin($turn_circle_track * $math_deg_to_rad)))"/>
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
                                                            ca_length_meters: <xsl:value-of select="$ca_length_meters"/>
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

                                                                L <xsl:value-of select="$ca_end_x"/><xsl:text> </xsl:text><xsl:value-of select="$ca_end_y"/>
                                                                A <xsl:value-of select="$turn_radius_pixels"/><xsl:text> </xsl:text><xsl:value-of select="$turn_radius_pixels"/><xsl:text> </xsl:text>0<xsl:text> </xsl:text>0<xsl:text> </xsl:text><xsl:value-of select="$arch_clockwise_flag"/><xsl:text> </xsl:text><xsl:value-of select="$TtrueX"/><xsl:text> </xsl:text><xsl:value-of select="$TtrueY"/>
                                                            </xsl:when>
                                                            <xsl:when test="(Flyover='Yes') and not(Turn='-')">
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


                                                            <!-- if possible, terminate the present path by drawing a line before starting the arc -->

                                                                L <xsl:value-of select="$pointX"/><xsl:text> </xsl:text><xsl:value-of select="$pointY"/>
                                                                A <xsl:value-of select="$turn_radius_pixels"/><xsl:text> </xsl:text><xsl:value-of select="$turn_radius_pixels"/><xsl:text> </xsl:text>0<xsl:text> </xsl:text>0<xsl:text> </xsl:text><xsl:value-of select="$arch_clockwise_flag"/><xsl:text> </xsl:text><xsl:value-of select="$TtrueX"/><xsl:text> </xsl:text><xsl:value-of select="$TtrueY"/>
                                                        </xsl:when>
                                                            <xsl:otherwise>
                                                                L <xsl:value-of select="$pointX"/><xsl:text> </xsl:text><xsl:value-of select="$pointY"/>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </xsl:for-each>
                                                </xsl:attribute>
                                            </path>
                                            <!-- sid track -->
                                            <xsl:for-each select="Waypoints/Waypoint">
                                                <xsl:comment>track for waypoint <xsl:value-of select="WPTID"/></xsl:comment>
                                                <xsl:variable name="pointX"><xsl:call-template name="pointToPixelX"><xsl:with-param name="coordX" select="$waypoints/Waypoins/Waypoint[ID=current()/WPTID]/Longitude"/></xsl:call-template></xsl:variable>
                                                <xsl:variable name="pointY"><xsl:call-template name="pointToPixelY"><xsl:with-param name="coordY" select="$waypoints/Waypoins/Waypoint[ID=current()/WPTID]/Latitude"/></xsl:call-template></xsl:variable>

                                                <xsl:variable name="next_pointX"><xsl:call-template name="pointToPixelX"><xsl:with-param name="coordX" select="$waypoints/Waypoins/Waypoint[ID=current()/following-sibling::Waypoint[1]/WPTID]/Longitude"/></xsl:call-template></xsl:variable>
                                                <xsl:variable name="next_pointY"><xsl:call-template name="pointToPixelY"><xsl:with-param name="coordY" select="$waypoints/Waypoins/Waypoint[ID=current()/following-sibling::Waypoint[1]/WPTID]/Latitude"/></xsl:call-template></xsl:variable>

                                                <xsl:variable name="previous_pointX"><xsl:call-template name="pointToPixelX"><xsl:with-param name="coordX" select="$waypoints/Waypoins/Waypoint[ID=current()/preceding-sibling::Waypoint[1]/WPTID]/Longitude"/></xsl:call-template></xsl:variable>
                                                <xsl:variable name="previous_pointY"><xsl:call-template name="pointToPixelY"><xsl:with-param name="coordY" select="$waypoints/Waypoins/Waypoint[ID=current()/preceding-sibling::Waypoint[1]/WPTID]/Latitude"/></xsl:call-template></xsl:variable>

                                                <xsl:variable name="midway_distance_in_pixels">
                                                    <xsl:value-of select="(((DIST * $geo_nm_in_meters) div $map_zoom) div 2) div math:cos($waypoints/Waypoins/Waypoint[ID=current()/WPTID]/Latitude * $math_deg_to_rad)"/>
                                                </xsl:variable>
                                                <xsl:variable name="line_arrow_distance">
                                                    <xsl:value-of select="(((DIST * $geo_nm_in_meters) div $map_zoom) div 8) div math:cos($waypoints/Waypoins/Waypoint[ID=current()/WPTID]/Latitude * $math_deg_to_rad)"/>
                                                </xsl:variable>

                                                <xsl:variable name="this_point_turn_direction"><xsl:value-of select="Turn"/></xsl:variable>
                                                <!-- hacky:  the LBSF original charts shows unrealistic curves, probably for presentation purposes only, sooooo... thry to emulate them by introducing coeeficients and stuff  -->
                                                <xsl:variable name="runway_climnout_correction_factor">0.7</xsl:variable>
                                                <xsl:variable name="ca_length_meters">
                                                    <xsl:value-of select="(((number(translate(Altitude, '-+','')) - $airport/Airport/ElevationFeet) div ../../ClimbGradientFeetPerNM) * $geo_nm_in_meters) * $runway_climnout_correction_factor"/>
                                                </xsl:variable>

                                                <xsl:variable name="bank_angle_for_flight_phase">
                                                    <xsl:choose>
                                                        <xsl:when test="Flyover = 'Yes'">
                                                            12.5
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            25
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </xsl:variable>

                                                <xsl:variable name="turn_radius_meters">
                                                    <xsl:value-of select="(math:power((220 * $geo_nm_in_meters) div 3600, 2) div ($geo_one_g * math:tan($bank_angle_for_flight_phase * $math_deg_to_rad)))"/>
                                                </xsl:variable>
                                                <xsl:variable name="turn_radius_pixels">
                                                    <xsl:value-of select="$turn_radius_meters div $map_zoom"/>
                                                </xsl:variable>

                                                <xsl:variable name="track_geo">
                                                    <xsl:value-of select="substring-before(substring-after(Track, '('),'°')"/>
                                                </xsl:variable>
                                                <xsl:variable name="ca_end_x">
                                                    <xsl:value-of select="$runwayX + floor(((($ca_length_meters) div $map_zoom ) * math:cos((($track_geo - 90 ) * $math_deg_to_rad))) div math:cos($map_base_airport_rwy_longitude * $math_deg_to_rad))"/>
                                                </xsl:variable>
                                                <xsl:variable name="ca_end_y">
                                                    <xsl:value-of select="$runwayY + floor(($ca_length_meters div $map_zoom) * math:sin((($track_geo - 90 ) * $math_deg_to_rad)))"/>
                                                </xsl:variable>
                                                <xsl:variable name="next_track_geo">
                                                    <xsl:value-of select="substring-before(substring-after(current()/following-sibling::Waypoint[1]/Track, '('),'°')"/>
                                                </xsl:variable>


                                                <!-- CA waypoints have no coordinate, sue the extension termination coordinates instead to calculate the arc -->
                                                <xsl:variable name="real_pointX">
                                                    <xsl:choose>
                                                        <xsl:when test="PT='CA'">
                                                            <xsl:value-of select="$ca_end_x"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:value-of select="$pointX"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </xsl:variable>
                                                <xsl:variable name="real_pointY">
                                                    <xsl:choose>
                                                        <xsl:when test="PT='CA'">
                                                            <xsl:value-of select="$ca_end_y"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:value-of select="$pointY"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </xsl:variable>
                                                <xsl:variable name="turn_circle_track">
                                                    <xsl:choose>
                                                        <xsl:when test="$this_point_turn_direction='Right'">
                                                            <xsl:value-of select="($track_geo) mod 360"/>
                                                        </xsl:when>
                                                        <xsl:when test="$this_point_turn_direction='Left'">
                                                            <xsl:value-of select="($track_geo - 180) mod 360"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            WARN : Unable to establish turn direction for <xsl:value-of select="WPTID"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </xsl:variable>


                                                <xsl:variable name="Cx">
                                                    <xsl:value-of select="$real_pointX + (($turn_radius_pixels * math:cos($turn_circle_track * $math_deg_to_rad)))"/>
                                                </xsl:variable>
                                                <xsl:variable name="Cy">
                                                    <xsl:value-of select="$real_pointY + (($turn_radius_pixels * math:sin($turn_circle_track * $math_deg_to_rad)))"/>
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
                                                ca_length_meters: <xsl:value-of select="$ca_length_meters"/>
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

                                                <xsl:variable name="geo_track"><xsl:value-of select="substring-before(substring-after(Track, '('),'°')"/></xsl:variable>
                                                <!-- check that $geo_track contains a number (a valid track to this point) -->
                                                <xsl:if test="not(number($geo_track) = $geo_track)">
                                                    <!-- no geo_track, we are unable to use the point to print a direction over the path -->
                                                    <xsl:comment>WARN: No geotrack for waypoint <xsl:value-of select="WPTID"/> !</xsl:comment>
                                                </xsl:if>
                                                <xsl:if test="not(number($next_pointX) = $next_pointX)">
                                                    <xsl:comment>WARN: No next_pointX (<xsl:value-of select="$next_pointX"/>  ) for waypoint <xsl:value-of select="WPTID"/> , sibling is <xsl:value-of select="current()/following-sibling::Waypoint/WPTID"/>!</xsl:comment>
                                                </xsl:if>
                                                <xsl:if test="not(number($next_pointY) = $next_pointY)">
                                                    <xsl:comment>WARN: No next_pointY (<xsl:value-of select="$next_pointY"/>  ) for waypoint <xsl:value-of select="WPTID"/> , sibling is <xsl:value-of select="current()/following-sibling::Waypoint/WPTID"/>!</xsl:comment>
                                                </xsl:if>
                                                <xsl:variable name="oneX">
                                                    <xsl:value-of select="$pointX - floor($midway_distance_in_pixels * math:cos((($geo_track - 90 ) * $math_deg_to_rad)))"/>
                                                </xsl:variable>
                                                <xsl:variable name="oneY">
                                                    <xsl:value-of select="$pointY + floor($midway_distance_in_pixels * math:sin((($geo_track + 90 ) * $math_deg_to_rad)))"/>
                                                </xsl:variable>
                                                <xsl:variable name="line_arrowX">
                                                    <xsl:value-of select="$pointX - floor($line_arrow_distance * math:cos((($geo_track - 90 ) * $math_deg_to_rad)))"/>
                                                </xsl:variable>
                                                <xsl:variable name="line_arrowY">
                                                    <xsl:value-of select="$pointY + floor($line_arrow_distance * math:sin((($geo_track + 90 ) * $math_deg_to_rad)))"/>
                                                </xsl:variable>
                                                <xsl:variable name="distanceX">
                                                    <xsl:value-of select="$pointX - floor($midway_distance_in_pixels * math:cos((($geo_track - 90 - ($map_label_circle_radius div 2)) * $math_deg_to_rad)))"/>
                                                </xsl:variable>
                                                <xsl:variable name="distanceY">
                                                    <xsl:value-of select="$pointY  + floor($midway_distance_in_pixels * math:sin((($geo_track + 90 - ($map_label_circle_radius div 2)) * $math_deg_to_rad)))"/>
                                                </xsl:variable>

                                                <xsl:comment>
                                                    drawing debug turn circle for <xsl:value-of select="current()/WPTID"/>, next is <xsl:value-of select="current()/following-sibling::Waypoint[1]/WPTID"/>
                                                    turn is: <xsl:value-of select="current()/Turn"/>
                                                    turn_circle_track: <xsl:value-of select="$turn_circle_track"/>
                                                    turn_radius_pixels: <xsl:value-of select="$turn_radius_pixels"/>
                                                    Flyover is: <xsl:value-of select="current()/Flyover"/>
                                                    ----
                                                    pointX: <xsl:value-of select="$pointX"/>
                                                    pointY: <xsl:value-of select="$pointY"/>
                                                    Cx: <xsl:value-of select="$Cx"/>
                                                    Cy: <xsl:value-of select="$Cy"/>
                                                    Cx delta: <xsl:value-of select="$Cx - $pointX"/>
                                                    Cy delta: <xsl:value-of select="$Cy - $pointY"/>
                                                </xsl:comment>
                                                 <!-- draw the debug circles -->
                                                <!--
                                                <circle>
                                                    <xsl:attribute name="cx"><xsl:value-of select="$Cx"/></xsl:attribute>
                                                    <xsl:attribute name="cy"><xsl:value-of select="$Cy"/></xsl:attribute>
                                                    <xsl:attribute name="r"><xsl:value-of select="$turn_radius_pixels"/></xsl:attribute>
                                                    <xsl:attribute name="fill">none</xsl:attribute>
                                                    <xsl:attribute name="stroke">blue</xsl:attribute>
                                                </circle>
                                                <text>
                                                    <xsl:attribute name="x"><xsl:value-of select="$Cx"/></xsl:attribute>
                                                    <xsl:attribute name="y"><xsl:value-of select="$Cy"/></xsl:attribute>
                                                    <xsl:attribute name="fill">green</xsl:attribute>
                                                    <xsl:attribute name="stroke">none</xsl:attribute>
                                                    To <xsl:value-of select="current()/following-sibling::Waypoint[1]/WPTID"/> turn circle
                                                </text>
                                                -->

                                                <xsl:variable name="text_display_coord_x">
                                                    <xsl:choose>
                                                        <xsl:when test="number($oneX) = $oneX"><xsl:value-of select="$oneX"/></xsl:when>
                                                        <xsl:otherwise><xsl:value-of select="$pointX - (($pointX -$previous_pointX) div 2)"/></xsl:otherwise>
                                                    </xsl:choose>
                                                </xsl:variable>

                                                <xsl:variable name="text_display_coord_y">
                                                    <xsl:choose>
                                                        <xsl:when test="number($oneY) = $oneY"><xsl:value-of select="$oneY"/></xsl:when>
                                                        <xsl:otherwise><xsl:value-of select="$pointY - (($pointY - $previous_pointY) div 2)"/></xsl:otherwise>
                                                    </xsl:choose>
                                                </xsl:variable>
                                                <xsl:variable name="current_point_latitude">
                                                    <xsl:value-of select="number($waypoints/Waypoins/Waypoint[ID=current()/WPTID]/Latitude)"/>
                                                </xsl:variable>
                                                <xsl:variable name="current_point_longitude">
                                                    <xsl:value-of select="number($waypoints/Waypoins/Waypoint[ID=current()/WPTID]/Longitude)"/>
                                                </xsl:variable>
                                                <xsl:variable name="next_point_latitude">
                                                    <xsl:value-of select="number($waypoints/Waypoins/Waypoint[ID=current()/preceding-sibling::Waypoint[1]/WPTID]/Latitude)"/>
                                                </xsl:variable>
                                                <xsl:variable name="next_point_longitude">
                                                    <xsl:value-of select="number($waypoints/Waypoins/Waypoint[ID=current()/preceding-sibling::Waypoint[1]/WPTID]/Longitude)"/>
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

                                                <xsl:comment>
                                                    computed distance values when distance is not available in the chart for point: <xsl:value-of select="current()/WPTID"/>
                                                    current_point_latitude: <xsl:value-of select="$current_point_latitude"/>
                                                </xsl:comment>

                                                <!-- circle for direction -->
                                                 <circle>
                                                     <xsl:choose>
                                                         <!-- check if direction can be drawn using point, track and distance -->
                                                         <xsl:when test="number($geo_track) = $geo_track">
                                                            <xsl:attribute name="cx"><xsl:value-of select="$oneX"/></xsl:attribute>
                                                            <xsl:attribute name="cy"><xsl:value-of select="$oneY"/></xsl:attribute>
                                                         </xsl:when>
                                                         <xsl:otherwise>
                                                             <xsl:attribute name="cx"><xsl:value-of select="$pointX - (($pointX -$previous_pointX) div 2)"/></xsl:attribute>
                                                            <xsl:attribute name="cy"><xsl:value-of select="$pointY - (($pointY - $previous_pointY) div 2)"/></xsl:attribute>
                                                         </xsl:otherwise>
                                                     </xsl:choose>
                                                    <xsl:attribute name="r"><xsl:value-of select="$map_label_circle_radius"/></xsl:attribute>
                                                     <xsl:choose>
                                                         <xsl:when test="number($oneX) = $oneX">
                                                            <xsl:attribute name="fill">white</xsl:attribute>
                                                         </xsl:when>
                                                         <xsl:otherwise>
                                                             <xsl:attribute name="fill">white</xsl:attribute>
                                                         </xsl:otherwise>
                                                     </xsl:choose>

                                                    <xsl:attribute name="stroke">none</xsl:attribute>
                                                </circle>
                                                <xsl:comment>
                                                    text for track/dist for <xsl:value-of select="current()/WPTID"/>
                                                </xsl:comment>
                                                <!-- track and direction text -->
                                                <text>
                                                    <xsl:attribute name="text-anchor">middle</xsl:attribute>
                                                    <xsl:attribute name="alignment-baseline">middle</xsl:attribute>
                                                    <xsl:attribute name="transform">translate(<xsl:value-of select="$text_display_coord_x"/>, <xsl:value-of select="$text_display_coord_y"/>) rotate(
                                                        <xsl:choose>
                                                            <xsl:when test="number($geo_track) = $geo_track">
                                                                <xsl:choose>
                                                                    <xsl:when test="$geo_track > 180">
                                                                        <xsl:value-of select="$geo_track - 90 - 180"/>
                                                                    </xsl:when>
                                                                    <xsl:otherwise>
                                                                        <xsl:value-of select="$geo_track  -  90"/>
                                                                    </xsl:otherwise>
                                                                </xsl:choose>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                0
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                        )</xsl:attribute>
                                                    <xsl:attribute name="fill">black</xsl:attribute>
                                                        <!-- if there is track info, show it-->
                                                        <xsl:if test="not(Track='-')">
                                                            <tspan x="0" dy="0.3em">
                                                                <xsl:if test="$oneX &lt; ($svg_size div 2)">
                                                                    <xsl:text>&lt;</xsl:text>
                                                                </xsl:if>
                                                                <xsl:value-of select="substring-before(Track,'(')"/>
                                                                <xsl:if test="not($oneX &lt; ($svg_size div 2))">
                                                                    <xsl:text>&gt;</xsl:text>
                                                                </xsl:if>
                                                            </tspan>
                                                        </xsl:if>
                                                    <tspan>
                                                        <xsl:attribute name="x">0</xsl:attribute>
                                                        <xsl:attribute name="dy"><xsl:choose><xsl:when test="Track='-'">0.0em </xsl:when><xsl:otherwise>0.8em</xsl:otherwise></xsl:choose></xsl:attribute>
                                                        <xsl:choose>
                                                            <xsl:when test="number(DIST) = DIST">
                                                                <xsl:value-of select="DIST"/>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:value-of select="$result_NM"/>*
                                                            </xsl:otherwise>
                                                        </xsl:choose>

                                                    </tspan>
                                                 </text>
                                                <xsl:if test="number($line_arrowX) = $line_arrowX and (PT='DF' or PT='TF') and count(current()/following-sibling::Waypoint) = 0">
                                                    <xsl:comment>
                                                        drawing line arrows
                                                    </xsl:comment>
                                                    <polygon>
                                                        <xsl:attribute name="points">
                                                            <!--
                                                            <xsl:value-of select="0"/><xsl:text>, </xsl:text><xsl:value-of select="$line_arrowY"/><xsl:text> </xsl:text>
                                                            <xsl:value-of select="$line_arrowX + 10"/><xsl:text>,</xsl:text><xsl:value-of select="$line_arrowY + 15"/><xsl:text> </xsl:text>
                                                            <xsl:value-of select="$line_arrowX"/><xsl:text>,</xsl:text><xsl:value-of select="$line_arrowY - 15"/><xsl:text> </xsl:text>
                                                            <xsl:value-of select="$line_arrowX - 10"/><xsl:text> </xsl:text><xsl:value-of select="$line_arrowY + 15"/><xsl:text> </xsl:text>
                                                            -->
                                                            <xsl:value-of select="0 div $map_zoom"/>,<xsl:value-of select="0 div $map_zoom"/> <xsl:text> </xsl:text>
                                                            <xsl:value-of select="900 div $map_zoom"/>,<xsl:value-of select="1260 div $map_zoom"/> <xsl:text> </xsl:text>
                                                            <xsl:value-of select="0 div $map_zoom"/>,<xsl:value-of select="(1260 div $map_zoom) * -1"/> <xsl:text> </xsl:text>
                                                            <xsl:value-of select="(900 div $map_zoom) * -1"/>,<xsl:value-of select="1260 div $map_zoom"/> <xsl:text> </xsl:text>
                                                        </xsl:attribute>
                                                        <xsl:attribute name="transform">
                                                            translate(<xsl:value-of select="$line_arrowX"/>, <xsl:value-of select="$line_arrowY"/>) rotate(<xsl:value-of select="$geo_track"/>)
                                                        </xsl:attribute>
                                                        <xsl:attribute name="stroke">black</xsl:attribute>
                                                        <xsl:attribute name="fill">black</xsl:attribute>
                                                    </polygon>
                                                </xsl:if>
                                            </xsl:for-each>
                                        </xsl:for-each>
                                        <xsl:comment>
                                            map lines start
                                        </xsl:comment>
                                        <!-- map lines -->
                                        <xsl:for-each select="$maplines/MapLines/Lines/LatitudeLines/LatitudeLine">
                                            <xsl:variable name="pointX1"><xsl:call-template name="pointToPixelX"><xsl:with-param name="coordX" select="$maplines/MapLines/ZoneLimits/Longitude_Start"/></xsl:call-template></xsl:variable>
                                            <xsl:variable name="pointY1"><xsl:call-template name="pointToPixelY"><xsl:with-param name="coordY" select="text()"/></xsl:call-template></xsl:variable>
                                            <xsl:variable name="pointX2"><xsl:call-template name="pointToPixelX"><xsl:with-param name="coordX" select="$maplines/MapLines/ZoneLimits/Longitude_End"/></xsl:call-template></xsl:variable>
                                            <xsl:variable name="pointY2"><xsl:call-template name="pointToPixelY"><xsl:with-param name="coordY" select="text()"/></xsl:call-template></xsl:variable>
                                            <xsl:variable name="caption_new">
                                                <xsl:value-of select="format-number(number(text()), '00')"/>°<xsl:value-of select="format-number(((text() - floor(text())) * 60) , '00')"/>''
                                            </xsl:variable>

                                            <line>
                                                <xsl:attribute name="x1"><xsl:value-of select="$pointX1"/></xsl:attribute>
                                                <xsl:attribute name="y1"><xsl:value-of select="$pointY1"/></xsl:attribute>
                                                <xsl:attribute name="x2"><xsl:value-of select="$pointX2"/></xsl:attribute>
                                                <xsl:attribute name="y2"><xsl:value-of select="$pointY2"/></xsl:attribute>
                                                <xsl:attribute name="stroke">gray</xsl:attribute>
                                            </line>
                                            <text>
                                                <xsl:attribute name="text-anchor">middle</xsl:attribute>
                                                <xsl:attribute name="alignment-baseline">middle</xsl:attribute>
                                                <xsl:attribute name="transform">translate(<xsl:value-of select="20"/>, <xsl:value-of select="$pointY1"/>) rotate(270)</xsl:attribute>
                                                <xsl:attribute name="fill">gray</xsl:attribute>
                                                <xsl:value-of select="$caption_new"/>
                                             </text>
                                            <text>
                                                <xsl:attribute name="text-anchor">middle</xsl:attribute>
                                                <xsl:attribute name="alignment-baseline">middle</xsl:attribute>
                                                <xsl:attribute name="transform">translate(<xsl:value-of select="$svg_size - 20"/>, <xsl:value-of select="$pointY1"/>) rotate(270)</xsl:attribute>
                                                <xsl:attribute name="fill">gray</xsl:attribute>
                                                <xsl:value-of select="$caption_new"/>
                                             </text>
                                        </xsl:for-each>
                                        <xsl:for-each select="$maplines/MapLines/Lines/LongitudeLines/LongitudeLine">
                                            <xsl:variable name="pointX1"><xsl:call-template name="pointToPixelX"><xsl:with-param name="coordX" select="text()"/></xsl:call-template></xsl:variable>
                                            <xsl:variable name="pointY1"><xsl:call-template name="pointToPixelY"><xsl:with-param name="coordY" select="$maplines/MapLines/ZoneLimits/Latitude_Start"/></xsl:call-template></xsl:variable>
                                            <xsl:variable name="pointX2"><xsl:call-template name="pointToPixelX"><xsl:with-param name="coordX" select="text()"/></xsl:call-template></xsl:variable>
                                            <xsl:variable name="pointY2"><xsl:call-template name="pointToPixelY"><xsl:with-param name="coordY" select="$maplines/MapLines/ZoneLimits/Latitude_End"/></xsl:call-template></xsl:variable>

                                            <xsl:variable name="caption_new">
                                                <xsl:value-of select="format-number(number(text()), '00')"/>°<xsl:value-of select="format-number(((text() - floor(text())) * 60) , '00')"/>''
                                            </xsl:variable>
                                            <line>
                                                <xsl:attribute name="x1"><xsl:value-of select="$pointX1"/></xsl:attribute>
                                                <xsl:attribute name="y1"><xsl:value-of select="$pointY1"/></xsl:attribute>
                                                <xsl:attribute name="x2"><xsl:value-of select="$pointX2"/></xsl:attribute>
                                                <xsl:attribute name="y2"><xsl:value-of select="$pointY2"/></xsl:attribute>
                                                <xsl:attribute name="stroke">gray</xsl:attribute>
                                            </line>
                                            <text>
                                                <xsl:attribute name="text-anchor">middle</xsl:attribute>
                                                <xsl:attribute name="alignment-baseline">middle</xsl:attribute>
                                                <xsl:attribute name="transform">translate(<xsl:value-of select="$pointX1"/>, <xsl:value-of select="20"/>) rotate(0)</xsl:attribute>
                                                <xsl:attribute name="fill">gray</xsl:attribute>
                                                <xsl:value-of select="$caption_new"/>
                                             </text>
                                            <text>
                                                <xsl:attribute name="text-anchor">middle</xsl:attribute>
                                                <xsl:attribute name="alignment-baseline">middle</xsl:attribute>
                                                <xsl:attribute name="transform">translate(<xsl:value-of select="$pointX1"/>, <xsl:value-of select="$svg_size - 20"/>) rotate(0)</xsl:attribute>
                                                <xsl:attribute name="fill">gray</xsl:attribute>
                                                <xsl:value-of select="$caption_new"/>
                                             </text>
                                        </xsl:for-each>
                                        <xsl:comment>
                                            map lines end
                                        </xsl:comment>
                                        <!-- guide lines
                                        <line x1="1" y1="0" x2="1" y2="$svg_size" stroke="gray"></line>
                                        <line x1="200" y1="0" x2="200" y2="$svg_size" stroke="gray"></line>
                                        <line x1="400" y1="0" x2="400" y2="$svg_size" stroke="gray"></line>
                                        <line x1="600" y1="0" x2="600" y2="$svg_size" stroke="gray"></line>
                                        <line x1="800" y1="0" x2="800" y2="$svg_size" stroke="gray"></line>
                                        <line x1="999" y1="0" x2="999" y2="$svg_size" stroke="gray"></line>
                                        -->

                                        <!-- waypoints related to this chart (filtered )-->
                                        <xsl:for-each select="$waypoints/Waypoins/Waypoint[Charts/ChartSubType=/Chart/SubType]">
                                            <xsl:variable name="pointX"><xsl:call-template name="pointToPixelX"><xsl:with-param name="coordX" select="Longitude"/></xsl:call-template></xsl:variable>
                                            <xsl:variable name="pointY"><xsl:call-template name="pointToPixelY"><xsl:with-param name="coordY" select="Latitude"/></xsl:call-template></xsl:variable>
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
                                                <!-- Waypoint - On Request / FlyBy -->
                                                <xsl:when test="$pointType='WPT-OR-FO'">
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
                                                        <xsl:attribute name="fill">black</xsl:attribute>
                                                    </polygon>
                                                    <circle>
                                                        <xsl:attribute name="cx"><xsl:value-of select="$pointX"/></xsl:attribute>
                                                        <xsl:attribute name="cy"><xsl:value-of select="$pointY"/></xsl:attribute>
                                                        <xsl:attribute name="r">7</xsl:attribute>
                                                        <xsl:attribute name="fill">white</xsl:attribute>
                                                        <xsl:attribute name="stroke">black</xsl:attribute>
                                                    </circle>
                                                </xsl:when>
                                                <!-- VOR/DME - On Request / FlyBy -->
                                                <xsl:when test="$pointType='VOR-DME-OR-FB'">
                                                    <circle>
                                                        <xsl:attribute name="cx"><xsl:value-of select="$pointX"/></xsl:attribute>
                                                        <xsl:attribute name="cy"><xsl:value-of select="$pointY"/></xsl:attribute>
                                                        <xsl:attribute name="r">2</xsl:attribute>
                                                    </circle>
                                                    <!-- vor/dme rectangle -->
                                                    <polygon>
                                                        <xsl:attribute name="points">
                                                            <xsl:value-of select="$pointX - $element_vor_rectangle_x_side"/>,<xsl:value-of select="$pointY + $element_vor_rectangle_y_side"/>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX - $element_vor_rectangle_x_side"/>,<xsl:value-of select="$pointY - $element_vor_rectangle_y_side"/>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX + $element_vor_rectangle_x_side"/>,<xsl:value-of select="$pointY - $element_vor_rectangle_y_side"/>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX + $element_vor_rectangle_x_side"/>,<xsl:value-of select="$pointY + $element_vor_rectangle_y_side"/>
                                                        </xsl:attribute>
                                                        <xsl:attribute name="stroke">black</xsl:attribute>
                                                        <xsl:attribute name="fill">none</xsl:attribute>
                                                    </polygon>
                                                    <!-- polygon -->
                                                    <polygon>
                                                        <xsl:attribute name="points">
                                                            <xsl:value-of select="$pointX - 5"/>,<xsl:value-of select="$pointY + $element_vor_rectangle_y_side"/>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX - $element_vor_rectangle_x_side"/>,<xsl:value-of select="$pointY"/>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX - 5"/>,<xsl:value-of select="$pointY - $element_vor_rectangle_y_side"/>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX + 5"/>,<xsl:value-of select="$pointY - $element_vor_rectangle_y_side"/>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX + $element_vor_rectangle_x_side"/>,<xsl:value-of select="$pointY"/>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX + 5"/>,<xsl:value-of select="$pointY + $element_vor_rectangle_y_side"/>
                                                        </xsl:attribute>
                                                        <xsl:attribute name="stroke">black</xsl:attribute>
                                                        <xsl:attribute name="fill">none</xsl:attribute>
                                                    </polygon>
                                                    <text>
                                                        <xsl:attribute name="x"><xsl:value-of select="$pointX - 50"/></xsl:attribute>
                                                        <xsl:attribute name="y"><xsl:value-of select="$pointY - 60"/></xsl:attribute>
                                                        <xsl:value-of select="Name"/>
                                                    </text>
                                                    <text>
                                                        <xsl:attribute name="x"><xsl:value-of select="$pointX - 50"/></xsl:attribute>
                                                        <xsl:attribute name="y"><xsl:value-of select="$pointY - 47"/></xsl:attribute>
                                                        <xsl:value-of select="Frequency"/><xsl:text> </xsl:text><xsl:value-of select="ID"/><xsl:text> </xsl:text><xsl:value-of select="Additional"/>
                                                    </text>
                                                    <text>
                                                        <xsl:attribute name="x"><xsl:value-of select="$pointX - 50"/></xsl:attribute>
                                                        <xsl:attribute name="y"><xsl:value-of select="$pointY - 34"/></xsl:attribute>
                                                        <xsl:attribute name="fosnt-weight">bold</xsl:attribute>
                                                        <xsl:value-of select="MorseCodeSigns"/>
                                                    </text>
                                                    <text>
                                                        <xsl:attribute name="x"><xsl:value-of select="$pointX - 50"/></xsl:attribute>
                                                        <xsl:attribute name="y"><xsl:value-of select="$pointY - 22"/></xsl:attribute>
                                                        ELEV <xsl:value-of select="Elevation"/>
                                                    </text>
                                                </xsl:when>
                                                <!-- secondary airports -->
                                                <xsl:when test="$pointType='Airport'">
                                                    <xsl:variable name="seconday_runway_direction">
                                                        <xsl:value-of select="Runway * 10"/>
                                                    </xsl:variable>
                                                    <circle>
                                                        <xsl:attribute name="cx"><xsl:value-of select="$pointX"/></xsl:attribute>
                                                        <xsl:attribute name="cy"><xsl:value-of select="$pointY"/></xsl:attribute>
                                                        <xsl:attribute name="r"><xsl:value-of select="$map_secondary_airport_radius"/></xsl:attribute>
                                                        <xsl:attribute name="stroke">black</xsl:attribute>
                                                        <xsl:attribute name="fill">none</xsl:attribute>
                                                    </circle>
                                                   <line>
                                                        <xsl:attribute name="x1"><xsl:value-of select="$pointX - floor($map_secondary_airport_runway_length * math:cos(($seconday_runway_direction - 90) * $math_deg_to_rad))"/></xsl:attribute>
                                                        <xsl:attribute name="y1"><xsl:value-of select="$pointY + floor($map_secondary_airport_runway_length * math:sin(($seconday_runway_direction + 90) * $math_deg_to_rad))"/></xsl:attribute>
                                                        <xsl:attribute name="x2"><xsl:value-of select="$pointX + floor($map_secondary_airport_runway_length * math:cos(($seconday_runway_direction - 90) * $math_deg_to_rad))"/></xsl:attribute>
                                                        <xsl:attribute name="y2"><xsl:value-of select="$pointY - floor($map_secondary_airport_runway_length * math:sin(($seconday_runway_direction + 90) * $math_deg_to_rad))"/></xsl:attribute>
                                                        <xsl:attribute name="stroke">black</xsl:attribute>
                                                        <xsl:attribute name="stroke-width">2</xsl:attribute>
                                                   </line>
                                                </xsl:when>
                                                <!-- inactive secondary airports -->
                                                <xsl:when test="$pointType='Airport-Inactive'">
                                                    <circle>
                                                        <xsl:attribute name="cx"><xsl:value-of select="$pointX"/></xsl:attribute>
                                                        <xsl:attribute name="cy"><xsl:value-of select="$pointY"/></xsl:attribute>
                                                        <xsl:attribute name="r"><xsl:value-of select="$map_secondary_airport_radius"/></xsl:attribute>
                                                        <xsl:attribute name="stroke">black</xsl:attribute>
                                                        <xsl:attribute name="fill">none</xsl:attribute>
                                                    </circle>
                                                    <!-- text in the center of the circle (note div 2) -->
                                                   <text>
                                                       <xsl:attribute name="x"><xsl:value-of select="$pointX - ($map_secondary_airport_radius div 2)"/></xsl:attribute>
                                                       <xsl:attribute name="y"><xsl:value-of select="$pointY + ($map_secondary_airport_radius div 2)"/></xsl:attribute>
                                                       <xsl:text>x</xsl:text>
                                                   </text>
                                                </xsl:when>
                                                 <!-- inactive secondary airports -->
                                                <xsl:when test="$pointType='Helipad'">
                                                    <circle>
                                                        <xsl:attribute name="cx"><xsl:value-of select="$pointX"/></xsl:attribute>
                                                        <xsl:attribute name="cy"><xsl:value-of select="$pointY"/></xsl:attribute>
                                                        <xsl:attribute name="r"><xsl:value-of select="$map_secondary_airport_radius"/></xsl:attribute>
                                                        <xsl:attribute name="stroke">black</xsl:attribute>
                                                        <xsl:attribute name="fill">none</xsl:attribute>
                                                    </circle>
                                                    <!-- text in the center of rectangle (note the div 2) -->
                                                   <text>
                                                       <xsl:attribute name="x"><xsl:value-of select="$pointX - ($element_vor_rectangle_x_side div 2)"/></xsl:attribute>
                                                       <xsl:attribute name="y"><xsl:value-of select="$pointY + ($element_vor_rectangle_y_side div 2)"/></xsl:attribute>
                                                       <xsl:text>H</xsl:text>
                                                   </text>
                                                </xsl:when>
                                                <!-- base airport -->
                                                <xsl:when test="$pointType='BaseAirport'">
                                                    <polygon>
                                                        <xsl:attribute name="points">
                                                            <xsl:for-each select="PolygonPoints/PolygonPoint">
                                                                <xsl:variable name="base_airport_polygon_X"><xsl:call-template name="pointToPixelX"><xsl:with-param name="coordX" select="Longitude"/></xsl:call-template></xsl:variable>
                                                                <xsl:variable name="base_airport_polygon_Y"><xsl:call-template name="pointToPixelY"><xsl:with-param name="coordY" select="Latitude"/></xsl:call-template></xsl:variable>
                                                                <xsl:value-of select="$base_airport_polygon_X"/>,<xsl:value-of select="$base_airport_polygon_Y"/><xsl:text> </xsl:text>
                                                            </xsl:for-each>
                                                        </xsl:attribute>
                                                        <xsl:attribute name="fill">gray</xsl:attribute>
                                                        <xsl:attribute name="stroke">gray</xsl:attribute>
                                                    </polygon>

                                                   <line>
                                                        <xsl:attribute name="x1"><xsl:value-of select="$runwayX"/></xsl:attribute>
                                                        <xsl:attribute name="y1"><xsl:value-of select="$runwayY"/></xsl:attribute>

                                                        <xsl:attribute name="x2">
                                                            <xsl:value-of select="$runwayX - floor($runway_length * math:cos((($map_base_airport_rwy_direction - 90 ) * $math_deg_to_rad)))"/>
                                                        </xsl:attribute>
                                                       <!--
                                                        <xsl:attribute name="x2"><xsl:value-of select="$runwayX + floor((((($map_base_airport_rwy_length * $geo_nm_in_meters) div $map_zoom) div 2) div math:cos($waypoints/Waypoins/Waypoint[ID=current()/WPTID]/Latitude * $math_deg_to_rad))  * math:cos(($map_base_airport_rwy_direction + 90) * $math_deg_to_rad))"/></xsl:attribute>
                                                        -->
                                                        <xsl:attribute name="y2"><xsl:value-of select="$runwayY - floor(($map_base_airport_rwy_length  div $map_zoom )  * math:sin(($map_base_airport_rwy_direction - 90) * $math_deg_to_rad))"/></xsl:attribute>
                                                        <xsl:attribute name="stroke">pink</xsl:attribute>
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
                                                            <xsl:value-of select="$pointX - $element_vor_rectangle_x_side"/>,<xsl:value-of select="$pointY + $element_vor_rectangle_y_side"/>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX - $element_vor_rectangle_x_side"/>,<xsl:value-of select="$pointY - $element_vor_rectangle_y_side"/>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX + $element_vor_rectangle_x_side"/>,<xsl:value-of select="$pointY - $element_vor_rectangle_y_side"/>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX + $element_vor_rectangle_x_side"/>,<xsl:value-of select="$pointY + $element_vor_rectangle_y_side"/>
                                                        </xsl:attribute>
                                                        <xsl:attribute name="stroke">black</xsl:attribute>
                                                        <xsl:attribute name="fill">none</xsl:attribute>
                                                    </polygon>
                                                    <!-- polygon -->
                                                    <polygon>
                                                        <xsl:attribute name="points">
                                                            <xsl:value-of select="$pointX - 5"/>,<xsl:value-of select="$pointY + $element_vor_rectangle_y_side"/>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX - $element_vor_rectangle_x_side"/>,<xsl:value-of select="$pointY"/>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX - 5"/>,<xsl:value-of select="$pointY - $element_vor_rectangle_y_side"/>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX + 5"/>,<xsl:value-of select="$pointY - $element_vor_rectangle_y_side"/>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX + $element_vor_rectangle_x_side"/>,<xsl:value-of select="$pointY"/>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$pointX + 5"/>,<xsl:value-of select="$pointY + $element_vor_rectangle_y_side"/>
                                                        </xsl:attribute>
                                                        <xsl:attribute name="stroke">black</xsl:attribute>
                                                        <xsl:attribute name="fill">none</xsl:attribute>
                                                    </polygon>
                                                    <circle>
                                                        <xsl:attribute name="cx"><xsl:value-of select="$pointX"/></xsl:attribute>
                                                        <xsl:attribute name="cy"><xsl:value-of select="$pointY"/></xsl:attribute>
                                                        <xsl:attribute name="r"><xsl:value-of select="$element_msa_outer_circle"/></xsl:attribute>
                                                        <xsl:attribute name="fill">none</xsl:attribute>
                                                        <xsl:attribute name="stroke">black</xsl:attribute>
                                                    </circle>
                                                </xsl:when>
                                            </xsl:choose>
                                            <!-- do not output text for specific types that supply their own, non-generic captions) -->
                                            <xsl:if test="not($pointType='VOR-DME-OR-FB')">
                                                <!-- waypoint ID text -->
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
                                            </xsl:if>
                                        </xsl:for-each>
                                    </svg>
                                </div>
                            </div>
                        </div>

                        <xsl:for-each select="/Chart/SID_Page">
                            <xsl:choose>
                                <xsl:when test="(Page mod 2)">
                                    <div class="row">
                                        <div class="col-6 font-weight-bold"><xsl:value-of select="Publisher_Local"/></div>
                                        <div class="col-6 text-right font-weight-bold"><xsl:value-of select="ID"/></div>
                                    </div>
                                    <div class="row">
                                        <div class="col-6 font-weight-bold"><xsl:value-of select="Publisher"/></div>
                                        <div class="col-6 text-right font-weight-bold"><xsl:value-of select="Published_On"/></div>
                                    </div>
                                </xsl:when>
                                <xsl:otherwise>
                                    <div class="row">
                                        <div class="col-6 font-weight-bold"><xsl:value-of select="ID"/></div>
                                        <div class="col-6 text-right font-weight-bold"><xsl:value-of select="Publisher_Local"/> </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-6 font-weight-bold"><xsl:value-of select="Published_On"/></div>
                                        <div class="col-6 text-right font-weight-bold"><xsl:value-of select="Publisher"/></div>

                                    </div>
                                </xsl:otherwise>
                            </xsl:choose>

                            <div class="row">
                                <div class="col-12">
                                    <table class="table table-bordered text-center">
                                        <tr>
                                            <xsl:for-each select="Header_Columns/Header_Column">
                                                <th>
                                                    <xsl:attribute name="style">width:<xsl:value-of select="Percent"/>%;</xsl:attribute>
                                                    <xsl:value-of select="Caption"/>
                                                </th>
                                            </xsl:for-each>
                                        </tr>
                                        <xsl:for-each select="SID_Core">
                                            <tr>
                                                <td>
                                                    <xsl:attribute name="colspan"><xsl:value-of select="count(../Header_Columns/Header_Column)"/></xsl:attribute>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="font-weight-bold text-left">
                                                    <xsl:attribute name="colspan"><xsl:value-of select="count(../Header_Columns/Header_Column)"/></xsl:attribute>
                                                    <xsl:value-of select="ID"/>
                                                    <br/>
                                                    <span class="font-weight-normal">
                                                        <xsl:value-of select="Name"/>
                                                    </span>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="text-left">
                                                    <xsl:attribute name="colspan"><xsl:value-of select="count(../Header_Columns/Header_Column)"/></xsl:attribute>
                                                    MNM climb gradient of <xsl:value-of select="ClimbGradientPercent"/>% (<xsl:value-of select="ClimbGradientFeetPerNM"/> FT/NM) to <xsl:value-of select="ClimbGradientRestrictionsToFeet"/>FT AMSL due to <xsl:value-of select="ClimbGradientRestrictionsReason"/>.
                                                </td>
                                            </tr>
                                        <xsl:for-each select="Waypoints/Waypoint">
                                            <tr>
                                                <xsl:for-each select="*">
                                                    <td>
                                                        <xsl:value-of select="current()"/>
                                                    </td>
                                                </xsl:for-each>
                                            </tr>
                                        </xsl:for-each>
                                        </xsl:for-each>
                                    </table>
                                </div>
                            </div>
                        </xsl:for-each>

                </div>
            <script src="https://code.jquery.com/jquery-3.2.1.slim.min.js" integrity="sha384-KJ3o2DKtIkvYIK3UENzmM7KCkRr/rE9/Qpg6aAZGJwFDMVNA/GpGFF93hXpG5KkN" crossorigin="anonymous"/>
            <script src="https://cdn.jsdelivr.net/npm/popper.js@1.12.9/dist/umd/popper.min.js" integrity="sha384-ApNbgh9B+Y1QKtv3Rn7W3mgPxhU9K/ScQsAP7hUibX39j7fakFPskvXusvfa0b4Q" crossorigin="anonymous"/>
            <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.0.0/dist/js/bootstrap.min.js" integrity="sha384-JZR6Spejh4U02d8jOt6vLEHfe/JQGiRRSQQxSfFWpi1MquVdAyjUar5+76PVCmYl" crossorigin="anonymous"/>
            </body>
        </html>
    </xsl:template>

    <!--    GIS calculations templates
            All calculations are in the Web Mercator Projection
    -->

    <xsl:template name="pointToPixelX" match="/Chart">
        <xsl:param name="coordX"/>
        <xsl:value-of select="floor(($coordX * $math_deg_to_rad * $geo_earth_radius) div $map_zoom) + $map_offset_X"/>
    </xsl:template>

    <xsl:template name="pointToPixelY" match="/Chart">
        <xsl:param name="coordY"/>
        <xsl:value-of select="$svg_size - floor((math:log(math:tan($coordY * $math_deg_to_rad div 2 + $math_PI div 4)) * $geo_earth_radius) div ($map_zoom)) + $map_offset_Y"/>
    </xsl:template>
</xsl:stylesheet>