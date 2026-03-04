<?xml version='1.0' encoding='UTF-8'?>
<Project Type="Project" LVVersion="19008000">
	<Property Name="NI.LV.All.SaveVersion" Type="Str">19.0</Property>
	<Property Name="NI.LV.All.SourceOnly" Type="Bool">true</Property>
	<Property Name="NI.Project.Description" Type="Str"></Property>
	<Item Name="My Computer" Type="My Computer">
		<Property Name="NI.SortType" Type="Int">3</Property>
		<Property Name="server.app.propertiesEnabled" Type="Bool">true</Property>
		<Property Name="server.control.propertiesEnabled" Type="Bool">true</Property>
		<Property Name="server.tcp.enabled" Type="Bool">false</Property>
		<Property Name="server.tcp.port" Type="Int">0</Property>
		<Property Name="server.tcp.serviceName" Type="Str">My Computer/VI Server</Property>
		<Property Name="server.tcp.serviceName.default" Type="Str">My Computer/VI Server</Property>
		<Property Name="server.vi.callsEnabled" Type="Bool">true</Property>
		<Property Name="server.vi.propertiesEnabled" Type="Bool">true</Property>
		<Property Name="specify.custom.address" Type="Bool">false</Property>
		<Item Name="build support" Type="Folder">
			<Item Name="build tests" Type="Folder">
				<Item Name="Build Test EXE.vi" Type="VI" URL="../build support/build tests/Build Test EXE.vi"/>
				<Item Name="Test EXE.vi" Type="VI" URL="../build support/build tests/Test EXE.vi"/>
				<Item Name="CheckForCpp2013Redist.vi" Type="VI" URL="../build support/build tests/CheckForCpp2013Redist.vi"/>
			</Item>
			<Item Name="Lockin-Multichannel.ico" Type="Document" URL="../build support/Lockin-Multichannel.ico"/>
			<Item Name="Lockin-Multichannel-64.ico" Type="Document" URL="../build support/Lockin-Multichannel-64.ico"/>
			<Item Name="Multichannel Lockin.vipb" Type="Document" URL="../build support/Multichannel Lockin.vipb"/>
			<Item Name="Multichannel Lockin.vipc" Type="Document" URL="../build support/Multichannel Lockin.vipc"/>
			<Item Name="Pre-Build Custom Action.vi" Type="VI" URL="../build support/Pre-Build Custom Action.vi"/>
			<Item Name="Post-Build Custom Action.vi" Type="VI" URL="../build support/Post-Build Custom Action.vi"/>
			<Item Name="Manual Post Build.vi" Type="VI" URL="../build support/Manual Post Build.vi"/>
		</Item>
		<Item Name="Examples" Type="Folder">
			<Item Name="Example_Sweep.vi" Type="VI" URL="../src/Examples/Example_Sweep.vi"/>
			<Item Name="Example_Lockin.vi" Type="VI" URL="../src/Examples/Example_Lockin.vi"/>
			<Item Name="Lockin API State Machine.vi" Type="VI" URL="../src/Examples/Lockin API State Machine.vi"/>
		</Item>
		<Item Name="Instrument.Lockin.lvlib" Type="Library" URL="../src/Instrument.Lockin.lvlib"/>
		<Item Name="DAQ.lvclass" Type="LVClass" URL="../src/DAQ/DAQ.lvclass"/>
		<Item Name="DAQmx.lvclass" Type="LVClass" URL="../src/DAQmx/DAQmx.lvclass"/>
		<Item Name="Generator.lvclass" Type="LVClass" URL="../src/Generator/Generator.lvclass"/>
		<Item Name="DSP.lvclass" Type="LVClass" URL="../src/DSP/DSP.lvclass"/>
		<Item Name="Package Dependencies" Type="IIO Ladder Diagram">
			<Property Name="NI.SortType" Type="Int">0</Property>
		</Item>
		<Item Name="Dependencies" Type="Dependencies"/>
		<Item Name="Build Specifications" Type="Build">
			<Item Name="Multichannel Lock-In (x64) Application" Type="EXE">
				<Property Name="App_copyErrors" Type="Bool">true</Property>
				<Property Name="App_INI_aliasGUID" Type="Str">{31EF0C73-E777-4F70-87A7-D9EF15F3186C}</Property>
				<Property Name="App_INI_GUID" Type="Str">{3F9B6D2B-F7F0-4A86-BFE3-074A8EA488AD}</Property>
				<Property Name="App_serverConfig.httpPort" Type="Int">8002</Property>
				<Property Name="Bld_buildCacheID" Type="Str">{68ABFC83-8948-4562-A2C4-134E82696611}</Property>
				<Property Name="Bld_buildSpecName" Type="Str">Multichannel Lock-In (x64) Application</Property>
				<Property Name="Bld_excludeInlineSubVIs" Type="Bool">true</Property>
				<Property Name="Bld_excludeLibraryItems" Type="Bool">true</Property>
				<Property Name="Bld_excludePolymorphicVIs" Type="Bool">true</Property>
				<Property Name="Bld_localDestDir" Type="Path">../builds/Application (x64)</Property>
				<Property Name="Bld_localDestDirType" Type="Str">relativeToProject</Property>
				<Property Name="Bld_modifyLibraryFile" Type="Bool">true</Property>
				<Property Name="Bld_previewCacheID" Type="Str">{BE714A7E-B7D4-4888-A1F2-966F210EC573}</Property>
				<Property Name="Bld_version.build" Type="Int">72</Property>
				<Property Name="Bld_version.major" Type="Int">3</Property>
				<Property Name="Bld_version.minor" Type="Int">3</Property>
				<Property Name="Bld_version.patch" Type="Int">3</Property>
				<Property Name="Destination[0].destName" Type="Str">Multichannel Lockin.exe</Property>
				<Property Name="Destination[0].path" Type="Path">../builds/Application (x64)/NI_AB_PROJECTNAME.exe</Property>
				<Property Name="Destination[0].path.type" Type="Str">relativeToProject</Property>
				<Property Name="Destination[0].preserveHierarchy" Type="Bool">true</Property>
				<Property Name="Destination[0].type" Type="Str">App</Property>
				<Property Name="Destination[1].destName" Type="Str">Support Directory</Property>
				<Property Name="Destination[1].path" Type="Path">../builds/Application (x64)/data</Property>
				<Property Name="Destination[1].path.type" Type="Str">relativeToProject</Property>
				<Property Name="DestinationCount" Type="Int">2</Property>
				<Property Name="Exe_iconItemID" Type="Ref">/My Computer/build support/Lockin-Multichannel-64.ico</Property>
				<Property Name="Source[0].itemID" Type="Str">{AEACD548-BD35-42E5-ADE1-988C04F1717D}</Property>
				<Property Name="Source[0].type" Type="Str">Container</Property>
				<Property Name="Source[1].destinationIndex" Type="Int">0</Property>
				<Property Name="Source[1].itemID" Type="Ref">/My Computer/Instrument.Lockin.lvlib/Instrument.Lockin.lvclass/Instrument.Lockin.AppLauncher.vi</Property>
				<Property Name="Source[1].sourceInclusion" Type="Str">TopLevel</Property>
				<Property Name="Source[1].type" Type="Str">VI</Property>
				<Property Name="Source[2].destinationIndex" Type="Int">0</Property>
				<Property Name="Source[2].itemID" Type="Ref">/My Computer/Instrument.Lockin.lvlib</Property>
				<Property Name="Source[2].Library.allowMissingMembers" Type="Bool">true</Property>
				<Property Name="Source[2].sourceInclusion" Type="Str">Include</Property>
				<Property Name="Source[2].type" Type="Str">Library</Property>
				<Property Name="SourceCount" Type="Int">3</Property>
				<Property Name="TgtF_companyName" Type="Str">LevyLab</Property>
				<Property Name="TgtF_fileDescription" Type="Str">Multichannel Lockin for National Instrument Dynamic Signal Acquisition hardware (4431, 4461, 4462). This version is configured to handle multiple cards for simultaneous, synchronized AI/AO. You can configure a number of analog outputs (8 or more) to output sine, square, sawtooth, or triangle functions with DC offsets. Each of the analog inputs (8 or more) can be demodulated at multiple frequencies.</Property>
				<Property Name="TgtF_internalName" Type="Str">Multichannel Lock-In (x64) Application</Property>
				<Property Name="TgtF_legalCopyright" Type="Str">Copyright © 2025 Levylab</Property>
				<Property Name="TgtF_productName" Type="Str">Multichannel Lock-In (x64)</Property>
				<Property Name="TgtF_targetfileGUID" Type="Str">{F79A4A16-E3DA-45EF-AF6E-CE1DFAF4A4BE}</Property>
				<Property Name="TgtF_targetfileName" Type="Str">Multichannel Lockin.exe</Property>
			</Item>
			<Item Name="Multichannel Lock-In (x64) Installer" Type="Installer">
				<Property Name="Destination[0].name" Type="Str">LevyLab</Property>
				<Property Name="Destination[0].parent" Type="Str">{3912416A-D2E5-411B-AFEE-B63654D690C0}</Property>
				<Property Name="Destination[0].tag" Type="Str">{EEB31542-591B-4849-BFCC-C3FF49F7132E}</Property>
				<Property Name="Destination[0].type" Type="Str">userFolder</Property>
				<Property Name="Destination[1].name" Type="Str">Multichannel Lockin</Property>
				<Property Name="Destination[1].parent" Type="Str">{EEB31542-591B-4849-BFCC-C3FF49F7132E}</Property>
				<Property Name="Destination[1].tag" Type="Str">{A127CC0D-3099-41C3-8104-2245C476C6E9}</Property>
				<Property Name="Destination[1].type" Type="Str">userFolder</Property>
				<Property Name="DestinationCount" Type="Int">2</Property>
				<Property Name="DistPart[0].flavorID" Type="Str">DefaultFull</Property>
				<Property Name="DistPart[0].productID" Type="Str">{76D46C45-F70E-4086-8C78-A30B9CA1CE88}</Property>
				<Property Name="DistPart[0].productName" Type="Str">NI System Configuration Runtime 21.0.0</Property>
				<Property Name="DistPart[0].upgradeCode" Type="Str">{0E192465-CC28-4C84-BE81-710B71C595A3}</Property>
				<Property Name="DistPart[1].flavorID" Type="Str">_full_</Property>
				<Property Name="DistPart[1].productID" Type="Str">{5FD5066E-48F9-4CD6-A2E5-2B3C08CF51F0}</Property>
				<Property Name="DistPart[1].productName" Type="Str">NI-DAQmx Runtime 19.6</Property>
				<Property Name="DistPart[1].upgradeCode" Type="Str">{923C9CD5-A0D8-4147-9A8D-998780E30763}</Property>
				<Property Name="DistPart[2].flavorID" Type="Str"></Property>
				<Property Name="DistPart[2].productID" Type="Str"></Property>
				<Property Name="DistPart[2].productName" Type="Str">NI LabVIEW Run-Time Engine 2019 (64-bit)</Property>
				<Property Name="DistPart[2].upgradeCode" Type="Str">{0F4FB023-A713-40CF-AC56-843EEEB44133}</Property>
				<Property Name="DistPartCount" Type="Int">3</Property>
				<Property Name="INST_author" Type="Str">University of Pittsburgh</Property>
				<Property Name="INST_buildLocation" Type="Path">../builds/Installer</Property>
				<Property Name="INST_buildLocation.type" Type="Str">relativeToProject</Property>
				<Property Name="INST_buildSpecName" Type="Str">Multichannel Lock-In (x64) Installer</Property>
				<Property Name="INST_defaultDir" Type="Str">{A127CC0D-3099-41C3-8104-2245C476C6E9}</Property>
				<Property Name="INST_installerName" Type="Str">setup.exe</Property>
				<Property Name="INST_productName" Type="Str">Multichannel Lock-In (x64)</Property>
				<Property Name="INST_productVersion" Type="Str">3.3.3</Property>
				<Property Name="InstSpecBitness" Type="Str">64-bit</Property>
				<Property Name="InstSpecVersion" Type="Str">19000000</Property>
				<Property Name="MSI_arpCompany" Type="Str">University of Pittsburgh</Property>
				<Property Name="MSI_arpContact" Type="Str">Patrick Irvin</Property>
				<Property Name="MSI_arpURL" Type="Str">levylab.org</Property>
				<Property Name="MSI_autoselectDrivers" Type="Bool">true</Property>
				<Property Name="MSI_distID" Type="Str">{FF838FBA-15E2-45B7-886E-3DD04A62FF20}</Property>
				<Property Name="MSI_hideNonRuntimes" Type="Bool">true</Property>
				<Property Name="MSI_osCheck" Type="Int">0</Property>
				<Property Name="MSI_upgradeCode" Type="Str">{18CB5FA2-13A6-48A6-AEBB-99544A0FD4D4}</Property>
				<Property Name="RegDest[0].dirName" Type="Str">Software</Property>
				<Property Name="RegDest[0].dirTag" Type="Str">{DDFAFC8B-E728-4AC8-96DE-B920EBB97A86}</Property>
				<Property Name="RegDest[0].parentTag" Type="Str">2</Property>
				<Property Name="RegDest[1].dirName" Type="Str">LevyLab</Property>
				<Property Name="RegDest[1].dirTag" Type="Str">{896DBA56-F2A2-46F7-9651-AB8C692BAF56}</Property>
				<Property Name="RegDest[1].parentTag" Type="Str">{DDFAFC8B-E728-4AC8-96DE-B920EBB97A86}</Property>
				<Property Name="RegDestCount" Type="Int">2</Property>
				<Property Name="RegGroup[0].dirTag" Type="Str">{896DBA56-F2A2-46F7-9651-AB8C692BAF56}</Property>
				<Property Name="RegGroup[0].RegData[0].name" Type="Str">Version</Property>
				<Property Name="RegGroup[0].RegData[0].type" Type="Str">String</Property>
				<Property Name="RegGroup[0].RegDataCount" Type="Int">1</Property>
				<Property Name="RegGroupCount" Type="Int">1</Property>
				<Property Name="Source[0].dest" Type="Str">{A127CC0D-3099-41C3-8104-2245C476C6E9}</Property>
				<Property Name="Source[0].File[0].dest" Type="Str">{A127CC0D-3099-41C3-8104-2245C476C6E9}</Property>
				<Property Name="Source[0].File[0].name" Type="Str">Multichannel Lockin.exe</Property>
				<Property Name="Source[0].File[0].Shortcut[0].destIndex" Type="Int">0</Property>
				<Property Name="Source[0].File[0].Shortcut[0].name" Type="Str">Multichannel Lock-In (x64)</Property>
				<Property Name="Source[0].File[0].Shortcut[0].subDir" Type="Str">Multichannel Lock-In (x64)</Property>
				<Property Name="Source[0].File[0].ShortcutCount" Type="Int">1</Property>
				<Property Name="Source[0].File[0].tag" Type="Str">{F79A4A16-E3DA-45EF-AF6E-CE1DFAF4A4BE}</Property>
				<Property Name="Source[0].FileCount" Type="Int">1</Property>
				<Property Name="Source[0].name" Type="Str">Multichannel Lock-In (x64) Application</Property>
				<Property Name="Source[0].tag" Type="Ref">/My Computer/Build Specifications/Multichannel Lock-In (x64) Application</Property>
				<Property Name="Source[0].type" Type="Str">EXE</Property>
				<Property Name="SourceCount" Type="Int">1</Property>
			</Item>
			<Item Name="Test EXE" Type="EXE">
				<Property Name="App_copyErrors" Type="Bool">true</Property>
				<Property Name="App_INI_aliasGUID" Type="Str">{5BC92D9A-000C-4F70-8A45-158CECA69FF3}</Property>
				<Property Name="App_INI_GUID" Type="Str">{9791886C-59BA-4071-A40F-A04F8713A703}</Property>
				<Property Name="App_serverConfig.httpPort" Type="Int">8002</Property>
				<Property Name="Bld_buildCacheID" Type="Str">{F0022AB0-4626-4666-A2AB-63346EC6034F}</Property>
				<Property Name="Bld_buildSpecName" Type="Str">Test EXE</Property>
				<Property Name="Bld_excludeInlineSubVIs" Type="Bool">true</Property>
				<Property Name="Bld_excludeLibraryItems" Type="Bool">true</Property>
				<Property Name="Bld_excludePolymorphicVIs" Type="Bool">true</Property>
				<Property Name="Bld_localDestDir" Type="Path">../builds/NI_AB_PROJECTNAME/Test EXE</Property>
				<Property Name="Bld_localDestDirType" Type="Str">relativeToCommon</Property>
				<Property Name="Bld_modifyLibraryFile" Type="Bool">true</Property>
				<Property Name="Bld_previewCacheID" Type="Str">{B9598F00-F716-434C-A425-8642AB405148}</Property>
				<Property Name="Bld_version.build" Type="Int">25</Property>
				<Property Name="Bld_version.major" Type="Int">8</Property>
				<Property Name="Bld_version.minor" Type="Int">11</Property>
				<Property Name="Bld_version.patch" Type="Int">1</Property>
				<Property Name="Destination[0].destName" Type="Str">Test.exe</Property>
				<Property Name="Destination[0].path" Type="Path">../builds/NI_AB_PROJECTNAME/Test EXE/Test.exe</Property>
				<Property Name="Destination[0].preserveHierarchy" Type="Bool">true</Property>
				<Property Name="Destination[0].type" Type="Str">App</Property>
				<Property Name="Destination[1].destName" Type="Str">Support Directory</Property>
				<Property Name="Destination[1].path" Type="Path">../builds/NI_AB_PROJECTNAME/Test EXE/data</Property>
				<Property Name="DestinationCount" Type="Int">2</Property>
				<Property Name="Source[0].itemID" Type="Str">{225AE409-5E84-4BEF-A130-9CC3E6BFF118}</Property>
				<Property Name="Source[0].type" Type="Str">Container</Property>
				<Property Name="Source[1].destinationIndex" Type="Int">0</Property>
				<Property Name="Source[1].itemID" Type="Ref">/</Property>
				<Property Name="Source[1].sourceInclusion" Type="Str">TopLevel</Property>
				<Property Name="Source[1].type" Type="Str">VI</Property>
				<Property Name="SourceCount" Type="Int">2</Property>
				<Property Name="TgtF_companyName" Type="Str">University of Pittsburgh</Property>
				<Property Name="TgtF_fileDescription" Type="Str">Test EXE</Property>
				<Property Name="TgtF_internalName" Type="Str">Test EXE</Property>
				<Property Name="TgtF_legalCopyright" Type="Str">Copyright © 2020 University of Pittsburgh</Property>
				<Property Name="TgtF_productName" Type="Str">Test EXE</Property>
				<Property Name="TgtF_targetfileGUID" Type="Str">{FF0A5DB1-62F3-4507-B01D-8778356D77C8}</Property>
				<Property Name="TgtF_targetfileName" Type="Str">Test.exe</Property>
			</Item>
		</Item>
	</Item>
</Project>
