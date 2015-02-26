#! /usr/bin/make -f

include configure.mk

schema:=public

layers:=delta_service_area detaw_subareas
geojson:=$(patsubst %,%.geojson,${layers})

DEFAULT: ${geojson} shp

# Converting to WGS84 is a more accepted GEOJSON format.
# In this case our source data is in WGS84.
${geojson}:%.geojson:src/delta.vrt src/DeltaServiceArea_WGS84.shp src/DETAW_Subareas_WGS84.shp
	ogr2ogr -f GEOJSON -t_srs WGS84 $@ $< $*

# Materializing our VRT file, to shapefile format
shp: src/delta.vrt src/DeltaServiceArea_WGS84.shp src/DETAW_Subareas_WGS84.shp
	ogr2ogr $@ $<

delta.kml:

# While we may store the original data in the GITHUB repository, we
# also want to show how we got the data.  These data were sent to us
# 2015-02-20 from the DWR Bay-Delta Office

# Additionally, we may want to show alternative import strateigies.
# This rule will create a PostGIS version in ${schema}
.PHONY: postgis
postgis: src/daus.vrt src/dau_v2_105.shp 
	${OGR} src/daus.vrt

# In order to use our PostGIS import, we include some standard
# configuration file.  This is pulled from a specific version, as a
# github GIST.  This, we probably don't save in our repo.  Want users
# to see where it came from.  Update to newer version if required.
configure.mk:gist:=https://gist.githubusercontent.com/qjhart/052c63d3b1a8b48e4d4f
configure.mk:
	wget ${gist}/raw/e30543c3b8d8ff18a950750a0f340788cc8c1931/configure.mk

# Some convience functions for testing and repreoducing
clean:
	rm -rf configure.mk shp *.geojson

