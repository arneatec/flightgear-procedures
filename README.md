# flightgear-procedures

This repository contains SID and STAR procedures for some of the airports in Bulgaria:

- Sofia Airport (IATA: SOF, ICAO: LBSF)
- Burgas Airport (IATA: BOJ, ICAO: LBBG)
- Plovdiv Airport (IATA: PDV, ICAO: LBPD)

The procedures should work with any aircraft that uses the Autopilot/Route Manager (most of the FG aircraft) or a custom FMS(e.g. A320 uses its own FMGC and the Route Manager is disabled).
These procedures are based on publicly available sources such as charts published by BULATSA and others. They may or may not represent the current SIDs and STARs for the airports. 
The procedures are for recreational and educational purposes only in the Flightgear aircraft simulator. 

----
Install:
----

Put the contents of the repository in your Scenery/Airports folder and restart FG. SIDs and STARs will then be available in the Route manager for the supported airports. 
You can also use them in the Airbus FMGC.

SID and STAR procedures are found in the procedures.xml file for an airport. There is at most one procedures file per airport and it is located in the root of the airport directory:

[$FG_SCENERY](https://wiki.flightgear.org/$FG_SCENERY)/Airports/L/B/S/LBSF.procedures.xml

For more information:
https://wiki.flightgear.org/Howto:Add_procedures_to_the_route_manager


Have fun, fly safe!
