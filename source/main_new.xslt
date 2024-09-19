<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:math="http://exslt.org/math"
                xmlns:xls="http://www.w3.org/1999/XSL/Transform"
                extension-element-prefixes="math">
    <!-- imports -->
    <xsl:variable name="airport" select="document('LBSF_airport.xml')"/>
    <xsl:variable name="waypoints" select="document('LBSF_waypoints.xml')"/>
    <xsl:variable name="maplines" select="document('map_lines.xml')"/>

    <!-- page related constants -->
    <xsl:variable name="svg_size_X" select="/Chart/ImageSizePixels/X"/>
    <xsl:variable name="svg_size_Y" select="/Chart/ImageSizePixels/Y"/>

    <!-- math constants -->
    <xsl:variable name="math_PI" select="math:constant('PI', 9)"/>
    <xsl:variable name="math_deg_to_rad"><xsl:value-of select="$math_PI div 180"/></xsl:variable>
    <xsl:variable name="hour_in_seconds">3600</xsl:variable>

    <!-- geodesic constants -->
    <xsl:variable name="geo_nm_in_meters" select="1852"/>
    <xsl:variable name="geo_feet_in_meters" select="3.2808"/>
    <xsl:variable name="geo_earth_radius" select="6378137" />
    <xsl:variable name="geo_magnetic_variation" select="$airport/Airport/MagneticVariation"/>
    <xsl:variable name="geo_one_g" select="9.80665"/>

    <!-- major map constants -->
    <xsl:variable name="map_zoom" select="/Chart/Zoom"/>
    <xsl:variable name="standard_turn_speed" select="220"/>

    <xsl:variable name="chart_type" select="substring-before(/Chart/SubType ,'-')"/>

    <xsl:variable name="map_offset_X" select="((/Chart/MapCenter/Longitude * $math_deg_to_rad * $geo_earth_radius) div $map_zoom) * -1 + ($svg_size_X div 2)"/>
    <xsl:variable name="map_offset_Y" select="(math:log(math:tan(/Chart/MapCenter/Latitude * $math_deg_to_rad div 2 + $math_PI div 4)) * $geo_earth_radius div ($map_zoom)) - ($svg_size_Y div 2)"/>

    <xsl:variable name="map_offset_X_legacy" select="/Chart/Offset_X"/>
    <xsl:variable name="map_offset_Y_legacy" select="/Chart/Offset_Y"/>

    <xsl:variable name="map_base_airport_rwy" select="$airport/Airport/Runways/Runway[ID=current()/Chart/Chart_Object_ID]"/>
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
                                        <div class="col-3 font-weight-bold text-right">
                                            <xsl:value-of select="/Chart/Chart_Type"/><xsl:text> </xsl:text>
                                            <xsl:value-of select="/Chart/Chart_Object"/><xsl:text> </xsl:text>
                                            <xsl:value-of select="/Chart/Chart_Object_ID"/><xsl:text> </xsl:text>

                                            <div rowspan='3' class="text-right font-weight-normal"><br/><br/>
                                                <xsl:for-each select="/Chart/Includes/SID_ID">
                                                    <xsl:if test="position() > 1">, </xsl:if>
                                                    <xsl:value-of select="current()"/>
                                                </xsl:for-each>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="card border-dark">
                                <div class="card-body  p-0 m-0">
                                    <svg>
                                        <xsl:attribute name="width"><xsl:value-of select="$svg_size_X"/></xsl:attribute>
                                        <xsl:attribute name="height"><xsl:value-of select="$svg_size_Y"/></xsl:attribute>

                                        <!-- LAYER 1 : Map lines and text-->
                                        <xsl:call-template name="draw_map_lines"/>

                                        <!-- LAYER 2 : SID/STAR paths -->
                                        <xsl:for-each select="/Chart/SID_Page/SID_Core">
                                            <xsl:call-template name="svg_path_for_sid_star">
                                                    <xsl:with-param name="sid_star_node" select="current()"/>
                                            </xsl:call-template>

                                            <!-- LAYER 3 : SID/STAR text -->
                                            <xsl:call-template name="svg_text_for_sid_star">
                                                    <xsl:with-param name="sid_star_node" select="current()"/>
                                            </xsl:call-template>
                                        </xsl:for-each>

                                        <!-- LAYER 4 : Waypoints (with captions) for this chart -->
                                        <xsl:for-each select="$waypoints/Waypoins/Waypoint[Charts/ChartSubType=current()/Chart/SubType]">
                                            <xsl:call-template name="svg_waypoint_and_text">
                                                    <xsl:with-param name="waypoint_node" select="current()"/>
                                            </xsl:call-template>
                                        </xsl:for-each>


                                    </svg>
                                </div>
                            </div>
                        </div>
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
        <xsl:value-of select="$svg_size_Y - floor((math:log(math:tan($coordY * $math_deg_to_rad div 2 + $math_PI div 4)) * $geo_earth_radius) div ($map_zoom)) + $map_offset_Y"/>
    </xsl:template>

    <xsl:template name="svg_path_for_sid_star" match="/Chart">
        <xsl:param name="sid_star_node"/>
        <path>
            <xsl:attribute name="fill">none</xsl:attribute>
            <xsl:attribute name="stroke">black</xsl:attribute>
            <xsl:attribute name="stroke-width">2</xsl:attribute>
            <xsl:attribute name="d">
                M 500 500
                L 100 100
                L 200 200
            </xsl:attribute>
        </path>
    </xsl:template>

    <xsl:template name="svg_text_for_sid_star" match="/Chart">
        <xsl:param name="sid_star_node"/>
        <circle>
            <xsl:attribute name="cx">100</xsl:attribute>
            <xsl:attribute name="cy">150</xsl:attribute>
            <xsl:attribute name="r">50</xsl:attribute>
            <xsl:attribute name="fill">pink</xsl:attribute>
            <xsl:attribute name="stroke">none</xsl:attribute>
        </circle>
        <text>
            <xsl:attribute name="x">120</xsl:attribute>
            <xsl:attribute name="y">140</xsl:attribute>
            <xsl:attribute name="fill">black</xsl:attribute>
            <xsl:attribute name="stroke">black</xsl:attribute>
            Track/Dist
        </text>
    </xsl:template>

    <xsl:template name="svg_waypoint_and_text" match="/Chart">
        <xsl:param name="waypoint_node"/>

        <xsl:variable name="pointX"><xsl:call-template name="pointToPixelX"><xsl:with-param name="coordX" select="$waypoint_node/Longitude"/></xsl:call-template></xsl:variable>
        <xsl:variable name="pointY"><xsl:call-template name="pointToPixelY"><xsl:with-param name="coordY" select="$waypoint_node/Latitude"/></xsl:call-template></xsl:variable>
        <xsl:variable name="pointType"><xsl:value-of select="current()/Type"/></xsl:variable>

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
            <!-- Waypoint - On Request / (FlyBy or Flyover) -->
            <xsl:when test="$pointType='WPT-OR-FB' or $pointType='WPT-OR-FO'">
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
                    <xsl:attribute name="fill">
                        <xsl:choose>
                            <xsl:when test="$pointType='WPT-OR-FB'">
                                <!-- fly-by nodes are transparent -->
                                none
                            </xsl:when>
                            <xsl:when test="$pointType='WPT-OR-FO'">
                                <!-- fly-over nodes are black -->
                                black
                            </xsl:when>
                        </xsl:choose>
                    </xsl:attribute>

                </polygon>
                <circle>
                    <xsl:attribute name="cx"><xsl:value-of select="$pointX"/></xsl:attribute>
                    <xsl:attribute name="cy"><xsl:value-of select="$pointY"/></xsl:attribute>
                    <xsl:attribute name="r">7</xsl:attribute>
                    <xsl:attribute name="fill">white</xsl:attribute>
                    <xsl:attribute name="stroke">black</xsl:attribute>
                </circle>
                <xsl:if test="$pointType='WPT-OR-FO'">
                    <circle>
                        <xsl:attribute name="cx"><xsl:value-of select="$pointX"/></xsl:attribute>
                        <xsl:attribute name="cy"><xsl:value-of select="$pointY"/></xsl:attribute>
                        <xsl:attribute name="r">15</xsl:attribute>
                        <xsl:attribute name="fill">none</xsl:attribute>
                        <xsl:attribute name="stroke">black</xsl:attribute>
                    </circle>
                </xsl:if>
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
            <xsl:otherwise>
                WARNING : Unknown waypoint type '<xsl:value-of select="$pointType"/>' for waypoint '<xsl:value-of select="WPTID"/>'
            </xsl:otherwise>
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
    </xsl:template>


    <xsl:template name="draw_map_lines" match="/Chart">
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
                <xsl:attribute name="transform">translate(<xsl:value-of select="$svg_size_X - 20"/>, <xsl:value-of select="$pointY1"/>) rotate(270)</xsl:attribute>
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
                <xsl:attribute name="transform">translate(<xsl:value-of select="$pointX1"/>, <xsl:value-of select="$svg_size_Y - 20"/>) rotate(0)</xsl:attribute>
                <xsl:attribute name="fill">gray</xsl:attribute>
                <xsl:value-of select="$caption_new"/>
             </text>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>