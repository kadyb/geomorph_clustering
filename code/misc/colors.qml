<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis hasScaleBasedVisibilityFlag="0" version="3.24.0-Tisler" styleCategories="AllStyleCategories" maxScale="0" minScale="1e+08">
  <flags>
    <Identifiable>1</Identifiable>
    <Removable>1</Removable>
    <Searchable>1</Searchable>
    <Private>0</Private>
  </flags>
  <temporal fetchMode="0" mode="0" enabled="0">
    <fixedRange>
      <start></start>
      <end></end>
    </fixedRange>
  </temporal>
  <customproperties>
    <Option type="Map">
      <Option type="QString" value="false" name="WMSBackgroundLayer"/>
      <Option type="QString" value="false" name="WMSPublishDataSourceUrl"/>
      <Option type="QString" value="0" name="embeddedWidgets/count"/>
    </Option>
  </customproperties>
  <pipe-data-defined-properties>
    <Option type="Map">
      <Option type="QString" value="" name="name"/>
      <Option name="properties"/>
      <Option type="QString" value="collection" name="type"/>
    </Option>
  </pipe-data-defined-properties>
  <pipe>
    <provider>
      <resampling zoomedInResamplingMethod="nearestNeighbour" zoomedOutResamplingMethod="nearestNeighbour" maxOversampling="2" enabled="false"/>
    </provider>
    <rasterrenderer nodataColor="" alphaBand="-1" band="1" type="paletted" opacity="1">
      <rasterTransparency/>
      <minMaxOrigin>
        <limits>None</limits>
        <extent>WholeRaster</extent>
        <statAccuracy>Estimated</statAccuracy>
        <cumulativeCutLower>0.02</cumulativeCutLower>
        <cumulativeCutUpper>0.98</cumulativeCutUpper>
        <stdDevFactor>2</stdDevFactor>
      </minMaxOrigin>
      <colorPalette>
        <paletteEntry alpha="255" color="#cab443" value="1" label="PRMu"/>
        <paletteEntry alpha="255" color="#cdde8b" value="2" label="PRLl"/>
        <paletteEntry alpha="255" color="#b78958" value="3" label="UMS"/>
        <paletteEntry alpha="255" color="#b6bfc1" value="4" label="PDEu"/>
        <paletteEntry alpha="255" color="#c7c6cc" value="5" label="PSF"/>
        <paletteEntry alpha="255" color="#91c0b9" value="6" label="PFSu"/>
        <paletteEntry alpha="255" color="#e1cff1" value="7" label="PSG"/>
        <paletteEntry alpha="255" color="#81a2ac" value="8" label="PDV"/>
        <paletteEntry alpha="255" color="#da9e13" value="9" label="PRH"/>
        <paletteEntry alpha="255" color="#b9d7c7" value="10" label="PFR"/>
        <paletteEntry alpha="255" color="#d0ec89" value="11" label="PRMl"/>
        <paletteEntry alpha="255" color="#d9e1c3" value="12" label="PRLu"/>
        <paletteEntry alpha="255" color="#96b69d" value="13" label="PFD"/>
        <paletteEntry alpha="255" color="#9b8c6b" value="14" label="UHE"/>
        <paletteEntry alpha="255" color="#8ca59c" value="15" label="PDEl"/>
        <paletteEntry alpha="255" color="#9fd8e7" value="16" label="PFSl"/>
        <paletteEntry alpha="255" color="#859381" value="17" label="UMV"/>
        <paletteEntry alpha="255" color="#b7a0c0" value="18" label="PSI"/>
        <paletteEntry alpha="255" color="#9c6e6c" value="19" label="UMI"/>
        <paletteEntry alpha="255" color="#490005" value="20" label="UME"/>
      </colorPalette>
      <colorramp type="randomcolors" name="[source]">
        <Option/>
      </colorramp>
    </rasterrenderer>
    <brightnesscontrast brightness="0" gamma="1" contrast="0"/>
    <huesaturation grayscaleMode="0" colorizeOn="0" colorizeStrength="100" colorizeRed="255" invertColors="0" colorizeBlue="128" colorizeGreen="128" saturation="0"/>
    <rasterresampler maxOversampling="2"/>
    <resamplingStage>resamplingFilter</resamplingStage>
  </pipe>
  <blendMode>6</blendMode>
</qgis>
