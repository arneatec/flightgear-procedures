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

    <!-- length of the runway 'fly away extension' -->
    <xsl:variable name="takeOffExtension"><xsl:value-of select="/Chart/TakeOffFlyRunwayHeadingDistance"/></xsl:variable>
    <!-- extension end coordinates -->
    <xsl:variable name="endExtensionX"><xsl:value-of select="$runwayX + floor($takeOffExtension * math:cos(($map_base_airport_rwy_direction - 90) * $math_deg_to_rad))"/></xsl:variable>
    <xsl:variable name="endExtensionY"><xsl:value-of select="$runwayY + floor($takeOffExtension * math:sin(($map_base_airport_rwy_direction - 90) * $math_deg_to_rad))"/></xsl:variable>

    <xsl:template match="/">
        runwayX : <xsl:value-of select="$runwayX"/>
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
                                            <circle>
                                                <xsl:attribute name="cx"><xsl:value-of select="$runwayX"/></xsl:attribute>
                                                <xsl:attribute name="cy"><xsl:value-of select="$runwayY"/></xsl:attribute>
                                                <xsl:attribute name="r">4</xsl:attribute>
                                                <xsl:attribute name="fill">red</xsl:attribute>
                                            </circle>
                                            <circle>
                                                <xsl:attribute name="cx"><xsl:value-of select="$endExtensionX"/></xsl:attribute>
                                                <xsl:attribute name="cy"><xsl:value-of select="$endExtensionY"/></xsl:attribute>
                                                <xsl:attribute name="r">4</xsl:attribute>
                                                <xsl:attribute name="fill">green</xsl:attribute>
                                            </circle>
                                            <!-- each SID starts with the runway threshold -->
                                            <path>
                                                <xsl:attribute name="fill">none</xsl:attribute>
                                                <xsl:attribute name="stroke">black</xsl:attribute>
                                                <xsl:attribute name="stroke-width">2</xsl:attribute>
                                                <xsl:attribute name="d">
                                                    <!-- runway termination coordinates -->
                                                    <!-- start drawing -->
                                                    M <xsl:value-of select="$runwayX"/><xsl:text> </xsl:text><xsl:value-of select="$runwayY"/>
                                                    L <xsl:value-of select="$endExtensionX"/><xsl:text> </xsl:text><xsl:value-of select="$endExtensionY"/>
                                                    <xsl:if test="count(Waypoints/Waypoint[PT='CA']) > 0">
                                                        <!-- this is a climb-out sid  -->
                                                        <!-- you climb runway heading and turn as indicated in SID Turn (use runway direction and turn direction to work out the actual turn)  -->
                                                        <!-- also you need to calculate the heading delta that the turn will execute, the less delta the less turn -->
                                                        <xsl:variable name="geo_track_next"><xsl:value-of select="substring-before(substring-after(Waypoints/Waypoint[PT='CA']/following-sibling::Waypoint/Track, '('),'°')"/></xsl:variable>
                                                        <xsl:variable name="turn_delta"><xsl:value-of select="$map_base_airport_rwy_direction - $geo_track_next"/> </xsl:variable>
                                                        <!--
                                                        Q <xsl:value-of select="$endExtensionX +  floor($turn_delta)"/><xsl:text> </xsl:text><xsl:value-of select="$endExtensionY + floor($turn_delta)"/> <xsl:text> </xsl:text> <xsl:value-of select="$endExtensionX + ($turn_delta div 2)"/><xsl:text> </xsl:text> <xsl:value-of select="$endExtensionY + ($turn_delta div 2)"/>
                                                        -->
                                                        <xsl:choose>
                                                            <xsl:when test="number($geo_track_next) = $geo_track_next">
                                                                Q <xsl:value-of select="$endExtensionX + floor($turn_delta div 5)"/><xsl:text> </xsl:text><xsl:value-of select="$endExtensionY"/><xsl:text> </xsl:text><xsl:value-of select="$endExtensionX + floor($turn_delta div 5) "/><xsl:text> </xsl:text><xsl:value-of select="$endExtensionY + floor($turn_delta div 5)"/>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:if test="count(Waypoints/Waypoint[PT='CA']) > 0">
                                                                    <xsl:choose>
                                                                         <xsl:when test="count(Waypoints/Waypoint[PT='CA' and Turn='Left']) > 0">
                                                                            Q <xsl:value-of select="$endExtensionX +  floor($takeOffExtension* 0.75)"/><xsl:text> </xsl:text><xsl:value-of select="$endExtensionY"/> <xsl:text> </xsl:text> <xsl:value-of select="$endExtensionX + 45"/><xsl:text> </xsl:text> <xsl:value-of select="$endExtensionY - 25"/>
                                                                         </xsl:when>
                                                                        <xsl:otherwise>
                                                                            Q <xsl:value-of select="$endExtensionX +  floor($takeOffExtension* 0.75)"/><xsl:text> </xsl:text><xsl:value-of select="$endExtensionY"/> <xsl:text> </xsl:text> <xsl:value-of select="$endExtensionX + 45"/><xsl:text> </xsl:text> <xsl:value-of select="$endExtensionY + 25"/>
                                                                        </xsl:otherwise>
                                                                    </xsl:choose>
                                                                </xsl:if>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </xsl:if>
                                                    <!-- and finally the waypoints -->
                                                    <xsl:for-each select="Waypoints/Waypoint[not(WPTID='-')] ">
                                                        <xsl:variable name="pointX">
                                                            <xsl:value-of select="floor(($waypoints/Waypoins/Waypoint[ID=current()/WPTID]/Longitude * $math_deg_to_rad * $geo_earth_radius) div $map_zoom) + $map_offset_X"/>
                                                        </xsl:variable>
                                                        <xsl:variable name="pointY">
                                                            <xsl:value-of select="$svg_size - floor((math:log(math:tan($waypoints/Waypoins/Waypoint[ID=current()/WPTID]/Latitude * $math_deg_to_rad div 2 + $math_PI div 4)) * $geo_earth_radius) div ($map_zoom)) + $map_offset_Y"/>
                                                        </xsl:variable>
                                                        L <xsl:value-of select="$pointX"/><xsl:text> </xsl:text><xsl:value-of select="$pointY"/><xsl:text> </xsl:text>
                                                    </xsl:for-each>
                                                </xsl:attribute>
                                            </path>
                                            <!-- sid track -->
                                            <xsl:for-each select="Waypoints/Waypoint">
                                                <xsl:comment>track for waypoint <xsl:value-of select="WPTID"/></xsl:comment>
                                                <xsl:variable name="pointX"><xsl:value-of select="floor(($waypoints/Waypoins/Waypoint[ID=current()/WPTID]/Longitude * $math_deg_to_rad * $geo_earth_radius) div $map_zoom) + $map_offset_X"/></xsl:variable>
                                                <xsl:variable name="pointY"><xsl:value-of select="$svg_size - floor((math:log(math:tan($waypoints/Waypoins/Waypoint[ID=current()/WPTID]/Latitude * $math_deg_to_rad div 2 + $math_PI div 4)) * $geo_earth_radius) div ($map_zoom)) + $map_offset_Y"/></xsl:variable>
                                                <xsl:variable name="next_pointX"><xsl:value-of select="floor(($waypoints/Waypoins/Waypoint[ID=current()/following-sibling::Waypoint/WPTID]/Longitude * $math_deg_to_rad * $geo_earth_radius) div $map_zoom) + $map_offset_X"/></xsl:variable>
                                                <xsl:variable name="next_pointY"><xsl:value-of select="$svg_size - floor((math:log(math:tan($waypoints/Waypoins/Waypoint[ID=current()/following-sibling::Waypoint/WPTID]/Latitude * $math_deg_to_rad div 2 + $math_PI div 4)) * $geo_earth_radius) div ($map_zoom)) + $map_offset_Y"/></xsl:variable>
                                                <xsl:variable name="previous_pointX"><xsl:value-of select="floor(($waypoints/Waypoins/Waypoint[ID=current()/preceding-sibling::Waypoint/WPTID]/Longitude * $math_deg_to_rad * $geo_earth_radius) div $map_zoom) + $map_offset_X"/></xsl:variable>
                                                <xsl:variable name="previous_pointY"><xsl:value-of select="$svg_size - floor((math:log(math:tan($waypoints/Waypoins/Waypoint[ID=current()/preceding-sibling::Waypoint/WPTID]/Latitude * $math_deg_to_rad div 2 + $math_PI div 4)) * $geo_earth_radius) div ($map_zoom)) + $map_offset_Y"/></xsl:variable>
                                                <xsl:variable name="midway_distance_in_pixels">
                                                    <xsl:value-of select="(((DIST * $geo_nm_in_meters) div $map_zoom) div 2) div math:cos($waypoints/Waypoins/Waypoint[ID=current()/WPTID]/Latitude * $math_deg_to_rad)"/>
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
                                                <xsl:variable name="distanceX">
                                                    <xsl:value-of select="$pointX - floor($midway_distance_in_pixels * math:cos((($geo_track - 90 - ($map_label_circle_radius div 2)) * $math_deg_to_rad)))"/></xsl:variable>
                                                <xsl:variable name="distanceY">
                                                    <xsl:value-of select="$pointY  + floor($midway_distance_in_pixels * math:sin((($geo_track + 90 - ($map_label_circle_radius div 2)) * $math_deg_to_rad)))"/></xsl:variable>
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
                                                             <xsl:attribute name="fill">red</xsl:attribute>
                                                         </xsl:otherwise>
                                                     </xsl:choose>

                                                    <xsl:attribute name="stroke">none</xsl:attribute>
                                                </circle>
                                                <text>
                                                    <xsl:attribute name="text-anchor">middle</xsl:attribute>
                                                    <xsl:attribute name="alignment-baseline">middle</xsl:attribute>
                                                    <xsl:attribute name="transform">translate(<xsl:value-of select="$oneX"/>, <xsl:value-of select="$oneY"/>) rotate(
                                                        <xsl:choose>
                                                            <xsl:when test="$geo_track > 180">
                                                                <xsl:value-of select="$geo_track - 90 - 180"/>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:value-of select="$geo_track  -  90"/>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                        )</xsl:attribute>
                                                    <xsl:attribute name="fill">black</xsl:attribute>
                                                    <tspan x="0" dy="0em">
                                                        <xsl:if test="$oneX &lt; ($svg_size div 2)">
                                                            <xsl:text>&lt;</xsl:text>
                                                        </xsl:if>
                                                        <xsl:value-of select="substring-before(Track,'(')"/>
                                                        <xsl:if test="not($oneX &lt; ($svg_size div 2))">
                                                            <xsl:text>&gt;</xsl:text>
                                                        </xsl:if>
                                                    </tspan>
                                                    <tspan x="0" dy="0.8em">
                                                        <xsl:value-of select="DIST"/>
                                                    </tspan>
                                                 </text>
                                            </xsl:for-each>
                                        </xsl:for-each>

                                        <!-- map lines -->
                                        <xsl:for-each select="$maplines/MapLines/MapLine">
                                            <xsl:variable name="pointX1"><xsl:value-of select="floor((Longitude_Start * $math_deg_to_rad * $geo_earth_radius) div $map_zoom) + $map_offset_X"/></xsl:variable>
                                            <xsl:variable name="pointY1"><xsl:value-of select="$svg_size - floor((math:log(math:tan(Latitude_Start * $math_deg_to_rad div 2 + $math_PI div 4)) * $geo_earth_radius) div ($map_zoom)) + $map_offset_Y"/></xsl:variable>
                                            <xsl:variable name="pointX2"><xsl:value-of select="floor((Longitude_End * $math_deg_to_rad * $geo_earth_radius) div $map_zoom) + $map_offset_X"/></xsl:variable>
                                            <xsl:variable name="pointY2"><xsl:value-of select="$svg_size - floor((math:log(math:tan(Latitude_End * $math_deg_to_rad div 2 + $math_PI div 4)) * $geo_earth_radius) div ($map_zoom)) + $map_offset_Y"/></xsl:variable>
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
                                            <xsl:variable name="pointX"><xsl:value-of select="floor((Longitude * $math_deg_to_rad * $geo_earth_radius) div $map_zoom) + $map_offset_X"/></xsl:variable>
                                            <xsl:variable name="pointY"><xsl:value-of select="$svg_size - floor((math:log(math:tan(Latitude * $math_deg_to_rad div 2 + $math_PI div 4)) * $geo_earth_radius) div ($map_zoom)) + $map_offset_Y"/></xsl:variable>
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

                                        <!-- waypoints related to this chart (filtered )-->
                                        <xsl:for-each select="$waypoints/Waypoins/Waypoint[Charts/ChartSubType=/Chart/SubType]">
                                            <xsl:variable name="pointX"><xsl:value-of select="floor((Longitude * $math_deg_to_rad * $geo_earth_radius) div $map_zoom) + $map_offset_X"/></xsl:variable>
                                            <xsl:variable name="pointY"><xsl:value-of select="$svg_size - floor((math:log(math:tan(Latitude * $math_deg_to_rad div 2 + $math_PI div 4)) * $geo_earth_radius) div ($map_zoom)) + $map_offset_Y"/></xsl:variable>
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
                                                        <xsl:value-of select="Runway * 10"></xsl:value-of>
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
                                                                <xsl:value-of select="$pointX + X"/>,<xsl:value-of select="$pointY + Y"/><xsl:text> </xsl:text>
                                                            </xsl:for-each>
                                                        </xsl:attribute>
                                                        <xsl:attribute name="fill">gray</xsl:attribute>
                                                        <xsl:attribute name="stroke">gray</xsl:attribute>
                                                    </polygon>
                                                    <xsl:variable name="runway_length">
                                                        <xsl:value-of select="((($map_base_airport_rwy_length) div $map_zoom)) div math:cos($map_base_airport_rwy/Latitude * $math_deg_to_rad)"/>
                                                    </xsl:variable>
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
                                                    <xsl:value-of select="Description"/>
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
</xsl:stylesheet>