original data source: https://data.noaa.gov//metaview/page?xml=NOAA/NESDIS/NGDC/MGG/DEM/iso/xml/biscayne_bay_S200_2018.xml&view=getDataView&header=none#OnlineAccess
Title: Biscayne Bay (S200) Bathymetric Digital Elevation Model - NOAA/NOS Estuarine Bathymetry: A 1/3 arc-second Mean Lower Low Water bathymetric DEM of NOS hydrographic survey data in Biscayne Bay.

NetCDF file from NOAA/NCEI, converted to raster in ArcMap 10.5.1.

Dataset Point of Contact	DEM Information
DOC/NOAA/NESDIS/NCEI > National Centers for Environmental Information, NESDIS, NOAA, U.S. Department of Commerce
dem.info@noaa.gov


What are vertical datum and units?? Could be meters relative to mean lower low water (mentioned in title) or NAD83 (found in attributes of data viewer), but I can't access solid metadata

Attribute info from NOAA/NCEI data viewer (indicate vertical datum is NAVD88):
Digital Elevation Model: Miami
Name: Miami
Cell Size: 1/3 arc-second
Vertical Datum: NAVD 88
Horizontal Datum: WGS84
Completion Date: 2015-10-01


XML details from web search (indicate z units = meters):
https://www.ngdc.noaa.gov/thredds/ncss/regional/biscayne_bay_S200_2018.nc/dataset.xml

<gridDataset location="/thredds/ncss/regional/biscayne_bay_S200_2018.nc" path="path">
<axis name="lat" shape="8132" type="double" axisType="Lat">
<attribute name="standard_name" value="latitude"/>
<attribute name="long_name" value="latitude"/>
<attribute name="units" value="degrees_north"/>
<attribute name="actual_range" type="double" value="25.177175943365 25.930138885245004"/>
<attribute name="_CoordinateAxisType" value="Lat"/>
<values start="25.17722223966" increment="9.259259000060638E-5" npts="8132"/>
</axis>
<axis name="lon" shape="3365" type="double" axisType="Lon">
<attribute name="standard_name" value="longitude"/>
<attribute name="long_name" value="longitude"/>
<attribute name="units" value="degrees_east"/>
<attribute name="actual_range" type="double" value="-80.432361166465 -80.120787101115"/>
<attribute name="_CoordinateAxisType" value="Lon"/>
<values start="-80.43231487017" increment="9.25925900077118E-5" npts="3365"/>
</axis>
<gridSet name="lat lon">
<projectionBox>
<minx>-80.432361166465</minx>
<maxx>-80.120787101115</maxx>
<miny>25.177175943365</miny>
<maxy>25.930138885245004</maxy>
</projectionBox>
<axisRef name="lat"/>
<axisRef name="lon"/>
<grid name="Band1" desc="GDAL Band Number 1" shape="lat lon" type="float">
<attribute name="long_name" value="GDAL Band Number 1"/>
<attribute name="_FillValue" type="float" value="-3.4028235E38"/>
<attribute name="RepresentationType" value="ATHEMATIC"/>
<attribute name="grid_mapping" value="crs"/>
<attribute name="actual_range" type="double" value="0.0 0.0"/>
<attribute name="units" value="meters"/>
</grid>
</gridSet>
<LatLonBox>
<west>-80.4323</west>
<east>-80.1208</east>
<south>25.1772</south>
<north>25.9300</north>
</LatLonBox>
<AcceptList>
<GridAsPoint>
<accept displayName="xml">xml</accept>
<accept displayName="xml (file)">xml_file</accept>
<accept displayName="csv">csv</accept>
<accept displayName="csv (file)">csv_file</accept>
<accept displayName="geocsv">geocsv</accept>
<accept displayName="geocsv (file)">geocsv_file</accept>
<accept displayName="netcdf">netcdf</accept>
</GridAsPoint>
<Grid>
<accept displayName="netcdf">netcdf</accept>
</Grid>
</AcceptList>