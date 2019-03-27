# MODIS Overview

## Mosiac image of the first complete day of MODIS data.

The Moderate Resolution Imaging Spectroradiometer (MODIS) instrument is operating on both the Terra and Aqua spacecraft. It has a viewing swath width of 2,330 km and views the entire surface of the Earth every one to two days. Its detectors measure 36 spectral bands and it acquires data at three spatial resolutions: 250-m, 500-m, and 1,000-m.

## MODIS Naming Conventions

MODIS filenames (i.e., the local granule ID) follow a naming convention which gives useful information regarding the specific product. For example, the filename **MOD09A1.A2006001.h08v05.006.2015113045801.hdf** indicates:

* *MOD09A1* - Product Short Name
* *.A2006001* - Julian Date of Acquisition (A-YYYYDDD)
* *.h08v05* - Tile Identifier (horizontalXXverticalYY)
* *.006* - Collection Version
* *.2015113045801* - Julian Date of Production (YYYYDDDHHMMSS)
* *.hdf* - Data Format (HDF-EOS)

The MODIS Long Name (i.e., Collection-Level) convention also provides useful information. For example, all products belonging to the MODIS/Terra Surface Reflectance 8-Day L3 Global 500m SIN Grid V006 collection have the following characteristics:

## MODIS/Terra - Instrument/Sensor

* Surface Reflectance - Geophysical Parameter
* 8-Day - Temporal Resolution
* L3 - Processing Level
* Global - Global or Swath
* 500m - Spatial Resolution
* SIN Grid - Gridded or Not
* V006 - Collection Version

## MODIS Temporal Resolution

The high level MODIS Land products distributed from LP DAAC are produced at various temporal resolutions, based on the instruments' orbital cycle. These time steps are possible in the generation of MODIS Land products:

Daily, 8-Day, 16-Day, Monthly, Quarterly, Yearly

## MODIS Spatial Resolution

The MODIS instruments acquire data in three native spatial resolutions:

Bands 1–2 - 250-meter
Bands 3–7 - 500-meter
Bands 8–36 - 1000-meter

The high level MODIS Land Products distributed from LP DAAC are produced at four nominal spatial resolutions: 250-meter, 500-meter, 1000-meter, and 5600-meter (0.05 degrees).

## MODIS Sinusoidal Tiling System

### MODIS Sinusoidal Grid

Most standard MODIS Land products use this Sinusoidal grid tiling system. Tiles are 10 degrees by 10 degrees at the equator. The tile coordinate system starts at (0,0) (horizontal tile number, vertical tile number) in the upper left corner and proceeds right (horizontal) and downward (vertical). The tile in the bottom right corner is (35,17).

### MODIS Processing Levels

LP DAAC distributes MODIS Land data processed to level-2 or higher:

Level-2: derived geophysical variables at the same resolution and location as level-1 source data (swath products)
Level-2G: level-2 data mapped on a uniform space-time grid scale (Sinusoidal)
Level-3: gridded variables in derived spatial and/or temporal resolutions
Level-4: model output or results from analyses of lower-level data

### MODIS Spectral Bands

|BAND #|RANGE nm|RANGE um|KEY USE|
|--- |--- |--- |--- |
||Reflected|Emitted||
|1|620–670||Absolute Land Cover Transformation, Vegetation Chlorophyll|
|2|841–876||Cloud Amount, Vegetation Land Cover Transformation|
|3|459–479||Soil/Vegetation Differences|
|4|545–565||Green Vegetation|
|5|1230–1250||Leaf/Canopy Differences|
|6|1628–1652||Snow/Cloud Differences|
|7|2105–2155||Cloud Properties, Land Properties|
|8|405–420||Chlorophyll|
|9|438–448||Chlorophyll|
|10|483–493||Chlorophyll|
|11|526–536||Chlorophyll|
|12|546–556||Sediments|
|13h|662–672||Atmosphere, Sediments|
|13l|662–672||Atmosphere, Sediments|
|14h|673–683||Chlorophyll Fluorescence|
|14l|673–683||Chlorophyll Fluorescence|
|15|743–753||Aerosol Properties|
|16|862–877||Aerosol Properties, Atmospheric Properties|
|17|890–920||Atmospheric Properties, Cloud Properties|
|18|931–941||Atmospheric Properties, Cloud Properties|
|19|915–965||Atmospheric Properties, Cloud Properties|
|20||3.660–3.840|Sea Surface Temperature|
|21||3.929–3.989|Forest Fires & Volcanoes|
|22||3.929–3.989|Cloud Temperature, Surface Temperature|
|23||4.020–4.080|Cloud Temperature, Surface Temperature|
|24||4.433–4.498|Cloud Fraction, Troposphere Temperature|
|25||4.482–4.549|Cloud Fraction, Troposphere Temperature|
|26|1360–1390||Cloud Fraction (Thin Cirrus), Troposphere Temperature|
|27||6.535–6.895|Mid Troposphere Humidity|
|28||7.175–7.475|Upper Troposphere Humidity|
|29||8.400–8.700|Surface Temperature|
|30||9.580–9.880|Total Ozone|
|31||10.780–11.280|Cloud Temperature, Forest Fires & Volcanoes, Surface Temp.|
|32||11.770–12.270|Cloud Height, Forest Fires & Volcanoes, Surface Temperature|
|33||13.185–13.485|Cloud Fraction, Cloud Height|
|34||13.485–13.785|Cloud Fraction, Cloud Height|
|35||13.785–14.085|Cloud Fraction, Cloud Height|
|36||14.085–14.385|Cloud Fraction, Cloud Height|

### MODIS Metadata

MODIS products have two sources of metadata: the embedded HDF metadata, and the external ECS metadata. The HDF metadata contains valuable information including global attributes and dataset specific attributes pertaining to the granule. The structure of this metadata is broadly similar to that of an ASTER HDF file. The ECS (generated by the EOSDIS Core System) .met file is the external metadata file in XML format, which is delivered to the user along with the MODIS product. It provides a subset of the HDF metadata. Some key features of certain MODIS metadata attributes include the following:

• The Xdim and Ydim represent the rows and columns of the data, respectively
• The Projection and ProjParams identify the projection and its corresponding projection parameters
• The Sinusoidal Projection is used for most of the gridded MODIS land products, and has a unique sphere measuring 6371007.181 meters.
• The UpperLeftPointMtrs is in projection coordinates, and identifies the very upper left corner of the upper left pixel of the image data
• The LowerRightMtrs identifies the very lower right corner of the lower right pixel of the image data. These projection coordinates are the only metadata that accurately reflect the extreme corners of the gridded image
• There are additional BOUNDINGRECTANGLE and GRINGPOINT fields within the metadata, which represent the latitude and longitude coordinates of the geographic tile corresponding to the data

The Data Set attributes contain specific SDS information such as the data range and applicable scaling factors for the data. The LP DAAC data products page provides these details within a concise document for each of the products. An HDF-EOS file also contains EOS core metadata essential for EOS search services. Any tool that processes standard HDF files can read an HDF-EOS file. However, it is difficult for a standard HDF call to interpret HDF-EOS geolocation or temporal information without further knowledge of the file structure.

### MODIS Data Processing

Along with all the data from other instruments on board the Terra and Aqua platforms, MODIS data are transferred to ground stations in White Sands, New Mexico, via the Tracking and Data Relay Satellite System (TDRSS). The data are then sent to the EOS Data and Operations System (EDOS) at the Goddard Space Flight Center. After Level-0 processing at EDOS, the Goddard Space Flight Center Earth Sciences Distributed Active Archive Center (GES DAAC) produces the Level 1A, Level 1B, geolocation and cloud mask products.

Higher-level MODIS land and atmosphere products are produced by the MODIS Adaptive Processing System (MODAPS), and then are parceled out among three DAACs for distribution. Ocean color products are produced by the Ocean Color Data Processing System (OCDPS) and distributed to the science and applications community.

### MODIS Golden Month Products

The MODIS Science Team decided, early in the mission, to maintain a record of multiple data versions of Aqua- and Terra-derived MODIS products from a unique temporal bracket.  Called the “Golden Month,” it covers 40 days of acquired data and all derived products from August 29, 2002 to October 7, 2002 (2002-241 to 2002-280).  Several reasons define this choice of acquisition window, which include the following:

This acquisition window provides the first interval when both Terra and Aqua MODIS data were collected uninterrupted
Previous (V003, V004, V005) and subsequent (V006) data versions are available
It avoids the end of July 2002 Aqua safe-hold incident
It includes the end of the Northern Hemisphere growing season
The period contains the fall equinox, which ensures that both hemispheres are illuminated
It includes two full 16-day periods (2002-241 to 2002-272)
It includes all 8-day periods, which overlap September 2002
Please contact the LP DAAC User Services if you are interested in acquiring the Golden Month products.

### Other MODIS Product Sources

The many data products derived from MODIS observations describe features of the land, oceans and the atmosphere that can be used for studies of processes and trends on local to global scales. As just noted, MODIS products are available from several sources.

#### Product Distributed By

MODIS Level-1 and atmosphere products	L1 and Atmosphere Archive and Distribution System (LAADS)
Land products	Land Processes Distributed Active Archive Center (LP DAAC)
Cryosphere data products	National Snow and Ice Data Center Distributed Active Archive Center (NSIDC DAAC)
Ocean color and sea surface temperature products	Ocean Color Web
Users with an appropriate x-band receiving system may capture regional data directly from the spacecraft using the MODIS Direct Broadcast signal.