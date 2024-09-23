<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:math="http://exslt.org/math"
                xmlns:xls="http://www.w3.org/1999/XSL/Transform" xmlns:csl="http://www.w3.org/1999/XSL/Transform"
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
    <xsl:variable name="math_deg_to_radians"><xsl:value-of select="$math_PI div 180"/></xsl:variable>
    <xsl:variable name="math_radians_to_degrees"><xsl:value-of select="180 div $math_PI"/></xsl:variable>
    <xsl:variable name="hour_in_seconds">3600</xsl:variable>

    <!-- geodesic constants -->
    <xsl:variable name="geo_nm_in_meters" select="1852"/>
    <xsl:variable name="geo_feet_in_meters" select="3.2808"/>
    <xsl:variable name="geo_earth_radius" select="6378137" />
    <xsl:variable name="geo_magnetic_variation" select="$airport/Airport/MagneticVariation"/>
    <xsl:variable name="geo_one_g" select="9.80665"/>

    <!-- major map constants -->
    <xsl:variable name="map_zoom" select="number(/Chart/Zoom)"/>
    <xsl:variable name="standard_turn_speed" select="250"/>

    <xsl:variable name="chart_type" select="substring-before(/Chart/SubType ,'-')"/>

    <xsl:variable name="map_offset_X" select="((/Chart/MapCenter/Longitude * $math_deg_to_radians * $geo_earth_radius) div $map_zoom) * -1 + ($svg_size_X div 2)"/>
    <xsl:variable name="map_offset_Y" select="(math:log(math:tan(/Chart/MapCenter/Latitude * $math_deg_to_radians div 2 + $math_PI div 4)) * $geo_earth_radius div ($map_zoom)) - ($svg_size_Y div 2)"/>

    <xsl:variable name="map_offset_X_legacy" select="/Chart/Offset_X"/>
    <xsl:variable name="map_offset_Y_legacy" select="/Chart/Offset_Y"/>

    <xsl:variable name="map_base_airport_rwy" select="$airport/Airport/Runways/Runway[ID=current()/Chart/Chart_Object_ID]"/>
    <xsl:variable name="map_base_airport_rwy_latitude" select="$map_base_airport_rwy/RunwayThreshold/Latitude"/>
    <xsl:variable name="map_base_airport_rwy_longitude" select="$map_base_airport_rwy/RunwayThreshold/Longitude"/>
    <xsl:variable name="map_base_airport_rwy_length" select="$map_base_airport_rwy/RunwayLenght"/>
    <xsl:variable name="map_base_airport_rwy_direction" select="$map_base_airport_rwy/RunwayDirection"/>

    <!-- minor map constants -->
    <xsl:variable name="map_label_circle_radius" select="20"/>
    <!-- circle when only dist is shon should be smaller -->
    <xsl:variable name="map_label_dist_circle_radius" select="17"/>

    <xsl:variable name="map_secondary_airport_radius" select="8"/>
    <xsl:variable name="map_secondary_airport_runway_length" select="10"/>

    <!-- waypoint elements constants -->
    <xsl:variable name="element_vor_rectangle_x_side" select="12"/>
    <xsl:variable name="element_vor_rectangle_y_side" select="10"/>
    <xsl:variable name="element_msa_outer_circle" select="65"/>

    <!-- major calculated values -->
    <xsl:variable name="runwayX"><xsl:call-template name="pointToPixelX"><xsl:with-param name="coordX" select="$map_base_airport_rwy_longitude"/></xsl:call-template></xsl:variable>
    <xsl:variable name="runwayY"><xsl:call-template name="pointToPixelY"><xsl:with-param name="coordY" select="$map_base_airport_rwy_latitude"/></xsl:call-template></xsl:variable>
    <xsl:variable name="runway_length"><xsl:value-of select="((($map_base_airport_rwy_length) div $map_zoom)) div math:cos($map_base_airport_rwy_latitude * $math_deg_to_radians)"/></xsl:variable>
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
                                            <xsl:call-template name="svg_path_or_text_for_sid_star">
                                                    <xsl:with-param name="sid_star_node" select="current()"/>
                                                    <xsl:with-param name="return_type" select="'Path'"/>
                                            </xsl:call-template>

                                            <!-- LAYER 3 : SID/STAR text -->
                                            <xsl:call-template name="svg_path_or_text_for_sid_star">
                                                    <xsl:with-param name="sid_star_node" select="current()"/>
                                                    <xsl:with-param name="return_type" select="'Text'"/>
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
        <xsl:value-of select="floor(($coordX * $math_deg_to_radians * $geo_earth_radius) div $map_zoom) + $map_offset_X"/>
    </xsl:template>

    <xsl:template name="pointToPixelY" match="/Chart">
        <xsl:param name="coordY"/>
        <xsl:value-of select="$svg_size_Y - floor((math:log(math:tan($coordY * $math_deg_to_radians div 2 + $math_PI div 4)) * $geo_earth_radius) div ($map_zoom)) + $map_offset_Y"/>
    </xsl:template>

    <xsl:template name="svg_path_or_text_for_sid_star" match="/Chart">
        <xsl:param name="sid_star_node"/>
        <xsl:param name="return_type"/>

        <xsl:choose>
            <xsl:when test="$return_type='Path'">
                <path>
                    <xsl:attribute name="fill">none</xsl:attribute>
                    <xsl:attribute name="stroke">black</xsl:attribute>
                    <xsl:attribute name="stroke-width">2</xsl:attribute>
                    <xsl:attribute name="d">
                        <xsl:for-each select="$sid_star_node/Waypoints/Waypoint">
                            <xsl:call-template name="svg_point_to_objects">
                                <xsl:with-param name="sid_star_node" select="current()"/>
                                <xsl:with-param name="return_type" select="'Path'"/>
                            </xsl:call-template>
                        </xsl:for-each>
                        <!--
                        L 100 100
                        L 200 200
                        -->
                    </xsl:attribute>
                </path>
            </xsl:when>
            <xsl:when test="$return_type='Text'">
                <xsl:for-each select="$sid_star_node/Waypoints/Waypoint">
                    <xsl:call-template name="svg_point_to_objects">
                        <xsl:with-param name="sid_star_node" select="current()"/>
                        <xsl:with-param name="return_type" select="'Text'"/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                WARNING : Unknown return type '<xsl:value-of select="$return_type"/>' in svg_path_or_text_for_sid_star
            </xsl:otherwise>
        </xsl:choose>


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
        <xsl:variable name="caption_offset_X">
            <xsl:choose>
                <xsl:when test="$waypoint_node/CaptionOffset">
                    <xsl:value-of select="$waypoint_node/CaptionOffset/X"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="0"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="caption_offset_Y">
            <xsl:choose>
                <xsl:when test="$waypoint_node/CaptionOffset">
                    <xsl:value-of select="$waypoint_node/CaptionOffset/Y"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="0"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

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
                    <xsl:attribute name="x"><xsl:value-of select="$pointX + $caption_offset_X - 50"/></xsl:attribute>
                    <xsl:attribute name="y"><xsl:value-of select="$pointY + $caption_offset_Y - 60"/></xsl:attribute>
                    <xsl:value-of select="Name"/>
                </text>
                <text>
                    <xsl:attribute name="x"><xsl:value-of select="$pointX + $caption_offset_X - 50"/></xsl:attribute>
                    <xsl:attribute name="y"><xsl:value-of select="$pointY + $caption_offset_Y - 47"/></xsl:attribute>
                    <xsl:value-of select="Frequency"/><xsl:text> </xsl:text><xsl:value-of select="ID"/><xsl:text> </xsl:text><xsl:value-of select="Additional"/>
                </text>
                <text>
                    <xsl:attribute name="x"><xsl:value-of select="$pointX + $caption_offset_X - 50"/></xsl:attribute>
                    <xsl:attribute name="y"><xsl:value-of select="$pointY + $caption_offset_Y - 34"/></xsl:attribute>
                    <xsl:attribute name="fosnt-weight">bold</xsl:attribute>
                    <xsl:value-of select="MorseCodeSigns"/>
                </text>
                <text>
                    <xsl:attribute name="x"><xsl:value-of select="$pointX + $caption_offset_X - 50"/></xsl:attribute>
                    <xsl:attribute name="y"><xsl:value-of select="$pointY + $caption_offset_Y - 22"/></xsl:attribute>
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
                    <xsl:attribute name="x1"><xsl:value-of select="$pointX - floor($map_secondary_airport_runway_length * math:cos(($seconday_runway_direction - 90) * $math_deg_to_radians))"/></xsl:attribute>
                    <xsl:attribute name="y1"><xsl:value-of select="$pointY + floor($map_secondary_airport_runway_length * math:sin(($seconday_runway_direction + 90) * $math_deg_to_radians))"/></xsl:attribute>
                    <xsl:attribute name="x2"><xsl:value-of select="$pointX + floor($map_secondary_airport_runway_length * math:cos(($seconday_runway_direction - 90) * $math_deg_to_radians))"/></xsl:attribute>
                    <xsl:attribute name="y2"><xsl:value-of select="$pointY - floor($map_secondary_airport_runway_length * math:sin(($seconday_runway_direction + 90) * $math_deg_to_radians))"/></xsl:attribute>
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
                        <xsl:value-of select="$runwayX - floor($runway_length * math:cos((($map_base_airport_rwy_direction - 90 ) * $math_deg_to_radians)))"/>
                    </xsl:attribute>
                   <!--
                    <xsl:attribute name="x2"><xsl:value-of select="$runwayX + floor((((($map_base_airport_rwy_length * $geo_nm_in_meters) div $map_zoom) div 2) div math:cos($waypoints/Waypoins/Waypoint[ID=current()/WPTID]/Latitude * $math_deg_to_rad))  * math:cos(($map_base_airport_rwy_direction + 90) * $math_deg_to_rad))"/></xsl:attribute>
                    -->
                    <xsl:attribute name="y2"><xsl:value-of select="$runwayY - floor(($map_base_airport_rwy_length  div $map_zoom )  * math:sin(($map_base_airport_rwy_direction - 90) * $math_deg_to_radians))"/></xsl:attribute>
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
                <xsl:attribute name="font-size">smaller</xsl:attribute>
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

    <xsl:template name="svg_point_to_objects" match="/Chart">
        <!-- returns a properly formated svg path or a set of svg object representing the required property of the waypoint -->
        <!-- the return can be :
            * Path - a path describing the SID
            * Text - a set of objects describing the track and distance

          -->
        <xsl:param name="sid_star_node"/>
        <xsl:param name="return_type"/>

        <xsl:variable name="pointX"><xsl:call-template name="pointToPixelX"><xsl:with-param name="coordX" select="$waypoints/Waypoins/Waypoint[ID=current()/WPTID]/Longitude"/></xsl:call-template></xsl:variable>
        <xsl:variable name="pointY"><xsl:call-template name="pointToPixelY"><xsl:with-param name="coordY" select="$waypoints/Waypoins/Waypoint[ID=current()/WPTID]/Latitude"/></xsl:call-template></xsl:variable>
        <xsl:variable name="next_pointX"><xsl:call-template name="pointToPixelX"><xsl:with-param name="coordX" select="$waypoints/Waypoins/Waypoint[ID=current()/following-sibling::Waypoint[1]/WPTID]/Longitude"/></xsl:call-template></xsl:variable>
        <xsl:variable name="next_pointY"><xsl:call-template name="pointToPixelY"><xsl:with-param name="coordY" select="$waypoints/Waypoins/Waypoint[ID=current()/following-sibling::Waypoint[1]/WPTID]/Latitude"/></xsl:call-template></xsl:variable>
        <xsl:variable name="previous_pointX"><xsl:call-template name="pointToPixelX"><xsl:with-param name="coordX" select="$waypoints/Waypoins/Waypoint[ID=current()/preceding-sibling::Waypoint[1]/WPTID]/Longitude"/></xsl:call-template></xsl:variable>
        <xsl:variable name="previous_pointY"><xsl:call-template name="pointToPixelY"><xsl:with-param name="coordY" select="$waypoints/Waypoins/Waypoint[ID=current()/preceding-sibling::Waypoint[1]/WPTID]/Latitude"/></xsl:call-template></xsl:variable>

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
            <xsl:value-of select="(math:power(($standard_turn_speed * $geo_nm_in_meters) div $hour_in_seconds, 2) div ($geo_one_g * math:tan($bank_angle_for_flight_phase * $math_deg_to_radians)))"/>
        </xsl:variable>
        <xsl:variable name="turn_radius_pixels">
            <xsl:value-of select="$turn_radius_meters div $map_zoom"/>
        </xsl:variable>
        <xsl:variable name="track_geo">
            <xsl:value-of select="substring-before(substring-after(Track, '('),'°')"/>
        </xsl:variable>
        <xsl:variable name="ca_end_x">
            <xsl:value-of select="$runwayX + floor(((($ca_length_meters) div $map_zoom ) * math:cos((($track_geo - 90 ) * $math_deg_to_radians))) div math:cos($map_base_airport_rwy_longitude * $math_deg_to_radians))"/>
        </xsl:variable>
        <xsl:variable name="ca_end_y">
            <xsl:value-of select="$runwayY + floor(($ca_length_meters div $map_zoom) * math:sin((($track_geo - 90 ) * $math_deg_to_radians)))"/>
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
                <xsl:otherwise>
                    <xsl:value-of select="($track_geo - 180) mod 360"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="Cx">
            <xsl:value-of select="$real_pointX + (($turn_radius_pixels * math:cos($turn_circle_track * $math_deg_to_radians)))"/>
        </xsl:variable>
        <xsl:variable name="Cy">
            <xsl:value-of select="$real_pointY + (($turn_radius_pixels * math:sin($turn_circle_track * $math_deg_to_radians)))"/>
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
                <xsl:otherwise>
                    0
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="TtrueX">
            <xsl:choose>
                <xsl:when test="$this_point_turn_direction='Left'">
                    <xsl:value-of select="$T1x"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$T2x"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="TtrueY">
            <xsl:choose>
                <xsl:when test="$this_point_turn_direction='Left'">
                    <xsl:value-of select="$T1y"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$T2y"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- calculate the climb-out circle and text coordinates here
             we calculate in reverse - from the next point (!!!) back to the start of the tangent line
          -->
        <xsl:variable name="curved_line_circle_X">
            <xsl:value-of select="$next_pointX - (($next_pointX - $TtrueX) div 2)"/>
        </xsl:variable>

        <xsl:variable name="curved_line_circle_Y">
            <xsl:value-of select="$next_pointY - (($next_pointY - $TtrueY) div 2)"/>
        </xsl:variable>


        <xsl:variable name="point_has_curve">
            <xsl:choose>
                <xsl:when test="($chart_type='SID' and not($sid_star_node/preceding-sibling::Waypoint[1])) or (($sid_star_node/Flyover='Yes'))">Yes</xsl:when>
                <xsl:otherwise>No</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="previous_point_has_curve">
            <xsl:choose>
                <xsl:when test="($chart_type='SID' and ($sid_star_node/preceding-sibling::Waypoint[1]))">
                    <!-- this is not a first node (a first node has no previous node) -->
                    <xsl:choose>
                        <xsl:when test="$sid_star_node/preceding-sibling::Waypoint[1]/PT='CA'">Yes</xsl:when>
                        <xsl:when test="$sid_star_node/preceding-sibling::Waypoint[1]/Flyover='Yes'">Yes</xsl:when>
                        <xsl:otherwise>No</xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>No</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- main <xsl:choose> for the  return type, decide what to return -->
        <xsl:choose>
            <xsl:when test="$return_type='Path'">
                <xsl:choose>
                    <xsl:when test="$chart_type='SID' and not($sid_star_node/preceding-sibling::Waypoint[1])">
                        <!-- this is a SID chart and this is the first waypoint

                            1. we need to start with an M at the runway threshold coordinates
                            2. then draw the climb to altitude
                            3. then draw the arc for the turn
                        -->
                        M <xsl:value-of select="$runwayX"/><xsl:text> </xsl:text><xsl:value-of select="$runwayY"/>
                        <xsl:choose>
                            <xsl:when test="$sid_star_node/PT='CA'">
                                <!-- create the line that is the climbout -->
                                L <xsl:text> </xsl:text><xsl:value-of select="$ca_end_x"/><xsl:text> </xsl:text><xsl:value-of select="$ca_end_y"/>


                                L <xsl:value-of select="$ca_end_x"/><xsl:text> </xsl:text><xsl:value-of select="$ca_end_y"/>
                                A <xsl:value-of select="$turn_radius_pixels"/><xsl:text> </xsl:text><xsl:value-of select="$turn_radius_pixels"/><xsl:text> </xsl:text>0<xsl:text> </xsl:text>0<xsl:text> </xsl:text><xsl:value-of select="$arch_clockwise_flag"/><xsl:text> </xsl:text><xsl:value-of select="$TtrueX"/><xsl:text> </xsl:text><xsl:value-of select="$TtrueY"/>

                            </xsl:when>
                            <xsl:otherwise>
                                L <xsl:value-of select="$pointX"/><xsl:text> </xsl:text><xsl:value-of select="$pointY"/>
                            </xsl:otherwise>
                        </xsl:choose>

                    </xsl:when>
                    <xsl:when test="$chart_type='STAR' and $sid_star_node/PT='IF' and not($sid_star_node/preceding-sibling::Waypoint[1])">
                        <!-- this is a STAR chart and this is the first waypoint, and it is an IF type waypoint (as expected)
                            1. we need to start with an M at the point coordinates
                        -->
                        M <xsl:value-of select="$pointX"/><xsl:text> </xsl:text><xsl:value-of select="$pointY"/>
                    </xsl:when>
                    <xsl:when test="$chart_type='STAR' and not($sid_star_node/PT='IF') and not($sid_star_node/preceding-sibling::Waypoint[1])">
                        <!-- this is a STAR chart and this is the first waypoint, but it is not an IF type waypoint (this is sus) -->
                        WARNING : Unexpected point type '<xsl:value-of select="$sid_star_node/PT"/>' for waypoint '<xsl:value-of select="$sid_star_node/WPTID"/>'
                    </xsl:when>
                    <xsl:when test="(Flyover='Yes')">
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
                            5. we assume the Vt is something like 220 knots (standard_turn_speed)
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
                        <!-- all other options exhausted, return a generic line to the point-->
                        L <xsl:value-of select="$pointX"/><xsl:text> </xsl:text><xsl:value-of select="$pointY"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$return_type='Text'">
                <xsl:variable name="midway_distance_in_pixels">
                    <xsl:value-of select="(((DIST * $geo_nm_in_meters) div $map_zoom) div 2) div math:cos($waypoints/Waypoins/Waypoint[ID=current()/WPTID]/Latitude * $math_deg_to_radians)"/>
                </xsl:variable>
                <xsl:variable name="line_arrow_distance">
                    <xsl:value-of select="(((DIST * $geo_nm_in_meters) div $map_zoom) div 8) div math:cos($waypoints/Waypoins/Waypoint[ID=current()/WPTID]/Latitude * $math_deg_to_radians)"/>
                </xsl:variable>
                <xsl:variable name="oneX">
                    <xsl:value-of select="$pointX - floor($midway_distance_in_pixels * math:cos((($track_geo - 90 ) * $math_deg_to_radians)))"/>
                </xsl:variable>
                <xsl:variable name="oneY">
                    <xsl:value-of select="$pointY + floor($midway_distance_in_pixels * math:sin((($track_geo + 90 ) * $math_deg_to_radians)))"/>
                </xsl:variable>
                <xsl:variable name="other_point_X">
                    <xsl:choose>
                        <xsl:when test="$chart_type='SID'">
                            <xsl:value-of select="$previous_pointX"/>
                        </xsl:when>
                        <xsl:when test="$chart_type='STAR'">
                            <xsl:value-of select="$next_pointX"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="other_point_Y">
                    <xsl:choose>
                        <xsl:when test="$chart_type='SID'">
                            <xsl:value-of select="$previous_pointY"/>
                        </xsl:when>
                        <xsl:when test="$chart_type='STAR'">
                            <xsl:value-of select="$next_pointY"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:variable>

                   <xsl:variable name="current_point_latitude">
                       <xsl:choose>
                           <xsl:when test="$chart_type='SID' and $sid_star_node/PT='CA'">
                               <xsl:value-of select="$map_base_airport_rwy_latitude"/>
                           </xsl:when>
                           <xsl:otherwise>
                                <xsl:value-of select="number($waypoints/Waypoins/Waypoint[ID=$sid_star_node/WPTID]/Latitude)"/>
                           </xsl:otherwise>
                       </xsl:choose>

                    </xsl:variable>
                    <xsl:variable name="current_point_longitude">
                       <xsl:choose>
                           <xsl:when test="$chart_type='SID' and $sid_star_node/PT='CA'">
                               <xsl:value-of select="$map_base_airport_rwy_longitude"/>
                           </xsl:when>
                           <xsl:otherwise>
                                <xsl:value-of select="number($waypoints/Waypoins/Waypoint[ID=$sid_star_node/WPTID]/Longitude)"/>
                           </xsl:otherwise>
                       </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="next_point_latitude">
                        <xsl:choose>
                            <xsl:when test="$chart_type='SID'">
                                <xsl:value-of select="number($waypoints/Waypoins/Waypoint[ID=$sid_star_node/following-sibling::Waypoint[1]/WPTID]/Latitude)"/>
                            </xsl:when>
                            <xsl:when test="$chart_type='STAR'">
                                <xsl:value-of select="number($waypoints/Waypoins/Waypoint[ID=$sid_star_node/preceding-sibling::Waypoint[1]/WPTID]/Latitude)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                WARN : Unknown chart type <xsl:value-of select="$chart_type"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>

                    <xsl:variable name="next_point_longitude">
                        <xsl:choose>
                            <xsl:when test="$chart_type='SID'">
                                <xsl:value-of select="number($waypoints/Waypoins/Waypoint[ID=$sid_star_node/following-sibling::Waypoint[1]/WPTID]/Longitude)"/>
                            </xsl:when>
                            <xsl:when test="$chart_type='STAR'">
                                <xsl:value-of select="number($waypoints/Waypoins/Waypoint[ID=$sid_star_node/preceding-sibling::Waypoint[1]/WPTID]/Longitude)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                WARN : Unknown chart type <xsl:value-of select="$chart_type"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>

                    <xsl:variable name="squared_sin_latitude_delta">
                        <xsl:value-of select="number(math:power(math:sin((($next_point_latitude - $current_point_latitude) * $math_deg_to_radians ) div 2), 2))"/>
                    </xsl:variable>
                    <xsl:variable name="squared_sin_longitude_delta">
                        <xsl:value-of select="number(math:power(math:sin((($next_point_longitude - $current_point_longitude) * $math_deg_to_radians) div 2), 2))"/>
                    </xsl:variable>

                    <xsl:variable name="square_root_inside_brackets">
                        <xsl:value-of select="number(math:sqrt($squared_sin_latitude_delta + number(math:cos($next_point_latitude * $math_deg_to_radians)) * number(math:cos($current_point_latitude * $math_deg_to_radians)) * $squared_sin_longitude_delta))"/>
                    </xsl:variable>

                    <xsl:variable name="next_point_true_angle">
                        <xsl:choose>
                            <xsl:when test="$d1 &gt; 0">
                                <xsl:value-of select="$d1 * $math_radians_to_degrees "/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="360 + ($d1 * $math_radians_to_degrees)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="delta_current_next_angle">
                        <xsl:value-of select="$track_geo - $next_point_true_angle"/>
                    </xsl:variable>

                    <xsl:variable name="arc_full_length">
                        <xsl:value-of select="2 * $math_PI * $turn_radius_meters"/>
                    </xsl:variable>
                    <xsl:variable name="semi_arc_length">
                        <xsl:value-of select="($arc_full_length * ($delta_current_next_angle div 360)) div 2"/>
                    </xsl:variable>

                    <xsl:variable name="arc_line_part_length">
                        <xsl:value-of select="2 * $geo_earth_radius * math:asin(number($square_root_inside_brackets))"/>
                    </xsl:variable>

                <xsl:variable name="arc_length">
                    <xsl:value-of select="((($track_geo + ($d1 * $math_radians_to_degrees)) mod 360) div 360) * 2 * $math_PI * $turn_radius_meters"/>
                </xsl:variable>

                 <xsl:variable name="result">
                    <xsl:value-of select="$arc_line_part_length"/>
                </xsl:variable>
                <xsl:variable name="result_NM">
                    <xsl:value-of select="round(($result div $geo_nm_in_meters ) * 10) div 10"/>
                </xsl:variable>
                <!--
                <xsl:comment>
                    sid_star_node WPTID: <xsl:value-of select="$sid_star_node/WPTID"></xsl:value-of>
                    result_NM: <xsl:value-of select="$result_NM"/>
                    result: <xsl:value-of select="$result"/>
                    square_root_inside_brackets: <xsl:value-of select="$square_root_inside_brackets"/>
                    squared_sin_longitude_delta: <xsl:value-of select="$squared_sin_longitude_delta"/>
                    squared_sin_latitude_delta: <xsl:value-of select="$squared_sin_latitude_delta"/>
                    next_point_longitude: <xsl:value-of select="$next_point_longitude"/>
                    next_point_latitude: <xsl:value-of select="$next_point_latitude"/>
                    current_point_longitude: <xsl:value-of select="$current_point_longitude"/>
                    current_point_latitude: <xsl:value-of select="$current_point_latitude"/>
                </xsl:comment>
                -->
                <xsl:variable name="circle_point_X">
                    <xsl:choose>
                        <!-- simplest case - both points have known coordinates - point to point -->
                        <xsl:when test="number($track_geo) = $track_geo and not($track_geo='-') and number($oneX) = $oneX and not(DIST='-')">
                            <xsl:value-of select="$oneX"/>
                        </xsl:when>
                        <xsl:otherwise>
                             <xsl:choose>
                                <!-- curved point (arc and line) - circle and text must be in the center of the line part  -->
                                <xsl:when test="$point_has_curve='Yes'">
                                    <xsl:value-of select="$curved_line_circle_X"/>
                                </xsl:when>
                                 <!-- point to point, but had to use 'poor man's' coordinates deltas instead   -->
                                <xsl:otherwise>
                                    <xsl:value-of select="$pointX - (($pointX - $other_point_X) div 2)"/>
                              </xsl:otherwise>
                             </xsl:choose>
                         </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>

                <xsl:variable name="circle_point_Y">
                    <xsl:choose>
                        <!-- simplest case - both points have known coordinates - point to point -->
                        <xsl:when test="number($track_geo) = $track_geo and not($track_geo='-') and number($oneY) = $oneY and not(DIST='-')">
                            <xsl:value-of select="$oneY"/>
                        </xsl:when>
                        <xsl:otherwise>
                             <xsl:choose>
                                <!-- curved point (arc and line) - circle and text must be in the center of the line part  -->
                                <xsl:when test="$point_has_curve='Yes'">
                                    <xsl:value-of select="$curved_line_circle_Y"/>
                                </xsl:when>
                                 <!-- point to point, but had to use 'poor man's' coordinates deltas instead   -->
                                <xsl:otherwise>
                                    <xsl:value-of select="$pointY - (($pointY - $other_point_Y) div 2)"/>
                              </xsl:otherwise>
                             </xsl:choose>
                         </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>


                <!-- only draw if the info has not previously been drawn -->
                <!-- always draw if this itself is a curved point -->
                <xsl:if test="$point_has_curve='Yes' or ($previous_point_has_curve='No')">
                    <circle>
                        <xsl:attribute name="cx"><xsl:value-of select="$circle_point_X"/></xsl:attribute>
                        <xsl:attribute name="cy"><xsl:value-of select="$circle_point_Y"/></xsl:attribute>
                        <xsl:attribute name="r">
                            <xsl:choose>
                                <xsl:when test="$point_has_curve = 'Yes'">
                                    <xsl:value-of select="$map_label_dist_circle_radius"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$map_label_circle_radius"/>
                                </xsl:otherwise>
                            </xsl:choose>

                        </xsl:attribute>
                         <xsl:choose>
                             <xsl:when test="$point_has_curve = 'Yes'">
                                <xsl:attribute name="fill">white</xsl:attribute>
                             </xsl:when>
                             <xsl:otherwise>
                                 <xsl:attribute name="fill">white</xsl:attribute>
                             </xsl:otherwise>
                         </xsl:choose>

                        <xsl:attribute name="stroke">none</xsl:attribute>
                    </circle>

                    <xsl:variable name="text_rotate">
                        <xsl:choose>
                            <xsl:when test="$point_has_curve='Yes'">
                                <xsl:choose>
                                    <xsl:when test="$this_point_turn_direction='Left'">
                                        <xsl:value-of select="$d1 * $math_radians_to_degrees"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="$d2 * $math_radians_to_degrees"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$track_geo"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>

                    <xsl:comment>
                        before text_track
                        current node: '<xsl:value-of select="$sid_star_node/WPTID"/>'
                    </xsl:comment>
                    <xsl:variable name="text_track">
                        <xsl:choose>
                            <xsl:when test="$point_has_curve='Yes'">-</xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="substring-before(Track,'(')"></xsl:value-of>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="text_dist">
                        <xsl:choose>
                            <xsl:when test="$point_has_curve='Yes'">
                                <xsl:value-of select="$result_NM"></xsl:value-of>*
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="DIST"></xsl:value-of>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="text_rotate_normalized">
                        <xsl:choose>
                            <xsl:when test="$text_rotate &gt; 360">
                                <xsl:value-of select="$text_rotate mod 360"/>
                            </xsl:when>
                            <xsl:when test="$text_rotate &lt; 0">
                                <xsl:value-of select=" (($text_rotate + 360 ) mod 360)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$text_rotate mod 360"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>

                    <xsl:variable name="text_rotate_true">
                        <xsl:choose>
                            <xsl:when test="$text_rotate_normalized &lt; 0">
                                <xsl:value-of select="180 + $text_rotate_normalized"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$text_rotate_normalized"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>

                    <text>
                        <xsl:attribute name="text-anchor">middle</xsl:attribute>
                        <xsl:attribute name="font-size">smaller</xsl:attribute>
                        <xsl:attribute name="alignment-baseline">middle</xsl:attribute>
                        <xsl:attribute name="transform">translate(<xsl:value-of select="$circle_point_X"/>, <xsl:value-of select="$circle_point_Y"/>) rotate(
                            <xsl:choose>
                                <xsl:when test="$track_geo > 180">
                                    <xsl:value-of select="$text_rotate_true + 90"/>)
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$text_rotate_true  - 90"/>)
                                </xsl:otherwise>

                            </xsl:choose>

                            </xsl:attribute>

                        <xsl:attribute name="fill">black</xsl:attribute>
                            <!-- if there is track info, show it-->
                            <xsl:if test="not($text_track='-')">
                                <tspan x="0" dy="0.3em">
                                    <xsl:if test="not($circle_point_X &lt; $pointX)">
                                        <xsl:text>&lt;</xsl:text>
                                    </xsl:if>
                                    <xsl:value-of select="$text_track"/>
                                    <xsl:if test="$circle_point_X &lt; $pointX">
                                        <xsl:text>&gt;</xsl:text>
                                    </xsl:if>
                                </tspan>
                            </xsl:if>
                        <tspan>
                            <xsl:attribute name="x">0</xsl:attribute>
                            <xsl:attribute name="dy"><xsl:choose><xsl:when test="$text_track='-'">0.0em </xsl:when><xsl:otherwise>0.8em</xsl:otherwise></xsl:choose></xsl:attribute>
                            <xsl:value-of select="$text_dist"/>
                        </tspan>
                        <!--
                        <tspan>
                            <xsl:attribute name="x">0</xsl:attribute>
                            <xsl:attribute name="dy">0.8em</xsl:attribute>
                            <xsl:value-of select="$sid_star_node/WPTID"/>
                        </tspan>
                        -->
                     </text>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                WARNING : Unknown return type '<xsl:value-of select="$return_type"/>' for '<xsl:value-of select="current()/WPTID"/>'
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>