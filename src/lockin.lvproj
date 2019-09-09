<?xml version='1.0' encoding='UTF-8'?>
<Project Type="Project" LVVersion="16008000">
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
		<Item Name="build_support" Type="Folder">
			<Item Name="Lockin-Multichannel.vipb" Type="Document" URL="../Lockin-Multichannel.vipb"/>
			<Item Name="Lockin-Multichannel.vipc" Type="Document" URL="../Lockin-Multichannel.vipc"/>
			<Item Name="Pre-Build Custom Action.vi" Type="VI" URL="../../build_support/Pre-Build Custom Action.vi"/>
			<Item Name="Pre-Install Custom Action.vi" Type="VI" URL="../../build_support/Pre-Install Custom Action.vi"/>
		</Item>
		<Item Name="Examples" Type="Folder">
			<Item Name="Example_IV_Curves.vi" Type="VI" URL="../Examples/Example_IV_Curves.vi"/>
			<Item Name="Example_Lockin.vi" Type="VI" URL="../Examples/Example_Lockin.vi"/>
		</Item>
		<Item Name="Tests" Type="Folder">
			<Item Name="Test API" Type="Folder">
				<Item Name="Test Lockin API.vi" Type="VI" URL="../../Tests/Test API/Test Lockin API.vi"/>
				<Item Name="Test Modes.vi" Type="VI" URL="../../Tests/Test API/Test Modes.vi"/>
				<Item Name="Test AO Configuration.vi" Type="VI" URL="../../Tests/Test API/Test AO Configuration.vi"/>
				<Item Name="Test Gain.vi" Type="VI" URL="../../Tests/Test API/Test Gain.vi"/>
				<Item Name="Test REF Configuration.vi" Type="VI" URL="../../Tests/Test API/Test REF Configuration.vi"/>
				<Item Name="Test Sampling.vi" Type="VI" URL="../../Tests/Test API/Test Sampling.vi"/>
				<Item Name="Test Data.vi" Type="VI" URL="../../Tests/Test API/Test Data.vi"/>
				<Item Name="Test Data 2.vi" Type="VI" URL="../../Tests/Test API/Test Data 2.vi"/>
			</Item>
			<Item Name="Metrics" Type="Folder">
				<Item Name="Lockin_Metrics.vi" Type="VI" URL="../../Tests/Expt/Lockin_Metrics.vi"/>
				<Item Name="Lockin_Metrics_Results.vi" Type="VI" URL="../../Tests/Expt/Lockin_Metrics_Results.vi"/>
				<Item Name="446xAntiAliasSimulator.vi" Type="VI" URL="../../Tests/Expt/446xAntiAliasSimulator.vi"/>
				<Item Name="Lockin Noise Measurement.vi" Type="VI" URL="../../Tests/Expt/Lockin Noise Measurement.vi"/>
				<Item Name="serialize_test.vi" Type="VI" URL="../../Tests/Expt/serialize_test.vi"/>
			</Item>
			<Item Name="Test Lockin API State Machine.vi" Type="VI" URL="../../Tests/Test Lockin API State Machine.vi"/>
		</Item>
		<Item Name="formatSweepResults.vi" Type="VI" URL="../Instrument.Lockin/API/formatSweepResults.vi"/>
		<Item Name="Dependencies" Type="Dependencies">
			<Item Name="user.lib" Type="Folder">
				<Item Name="1D Array to String__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/string/string.llb/1D Array to String__ogtk.vi"/>
				<Item Name="Array Size(s)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/lvdata/lvdata.llb/Array Size(s)__ogtk.vi"/>
				<Item Name="Build Error Cluster__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/error/error.llb/Build Error Cluster__ogtk.vi"/>
				<Item Name="Clear All Errors__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/error/error.llb/Clear All Errors__ogtk.vi"/>
				<Item Name="Current VIs Parents Ref__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/appcontrol/appcontrol.llb/Current VIs Parents Ref__ogtk.vi"/>
				<Item Name="DirExists-NoThenCreate.vi" Type="VI" URL="/&lt;userlib&gt;/LevyLab/FileUtilities/DirExists-NoThenCreate.vi"/>
				<Item Name="Empty 1D Array (Boolean)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Empty 1D Array (Boolean)__ogtk.vi"/>
				<Item Name="Empty 1D Array (CDB)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Empty 1D Array (CDB)__ogtk.vi"/>
				<Item Name="Empty 1D Array (CSG)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Empty 1D Array (CSG)__ogtk.vi"/>
				<Item Name="Empty 1D Array (CXT)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Empty 1D Array (CXT)__ogtk.vi"/>
				<Item Name="Empty 1D Array (DBL)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Empty 1D Array (DBL)__ogtk.vi"/>
				<Item Name="Empty 1D Array (EXT)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Empty 1D Array (EXT)__ogtk.vi"/>
				<Item Name="Empty 1D Array (I8)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Empty 1D Array (I8)__ogtk.vi"/>
				<Item Name="Empty 1D Array (I16)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Empty 1D Array (I16)__ogtk.vi"/>
				<Item Name="Empty 1D Array (I32)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Empty 1D Array (I32)__ogtk.vi"/>
				<Item Name="Empty 1D Array (I64)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Empty 1D Array (I64)__ogtk.vi"/>
				<Item Name="Empty 1D Array (LVObject)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Empty 1D Array (LVObject)__ogtk.vi"/>
				<Item Name="Empty 1D Array (Path)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Empty 1D Array (Path)__ogtk.vi"/>
				<Item Name="Empty 1D Array (SGL)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Empty 1D Array (SGL)__ogtk.vi"/>
				<Item Name="Empty 1D Array (String)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Empty 1D Array (String)__ogtk.vi"/>
				<Item Name="Empty 1D Array (U8)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Empty 1D Array (U8)__ogtk.vi"/>
				<Item Name="Empty 1D Array (U16)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Empty 1D Array (U16)__ogtk.vi"/>
				<Item Name="Empty 1D Array (U32)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Empty 1D Array (U32)__ogtk.vi"/>
				<Item Name="Empty 1D Array (U64)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Empty 1D Array (U64)__ogtk.vi"/>
				<Item Name="Empty 1D Array (Variant)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Empty 1D Array (Variant)__ogtk.vi"/>
				<Item Name="Empty 2D Array (Boolean)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Empty 2D Array (Boolean)__ogtk.vi"/>
				<Item Name="Empty 2D Array (CDB)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Empty 2D Array (CDB)__ogtk.vi"/>
				<Item Name="Empty 2D Array (CSG)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Empty 2D Array (CSG)__ogtk.vi"/>
				<Item Name="Empty 2D Array (CXT)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Empty 2D Array (CXT)__ogtk.vi"/>
				<Item Name="Empty 2D Array (DBL)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Empty 2D Array (DBL)__ogtk.vi"/>
				<Item Name="Empty 2D Array (EXT)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Empty 2D Array (EXT)__ogtk.vi"/>
				<Item Name="Empty 2D Array (I8)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Empty 2D Array (I8)__ogtk.vi"/>
				<Item Name="Empty 2D Array (I16)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Empty 2D Array (I16)__ogtk.vi"/>
				<Item Name="Empty 2D Array (I32)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Empty 2D Array (I32)__ogtk.vi"/>
				<Item Name="Empty 2D Array (I64)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Empty 2D Array (I64)__ogtk.vi"/>
				<Item Name="Empty 2D Array (LVObject)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Empty 2D Array (LVObject)__ogtk.vi"/>
				<Item Name="Empty 2D Array (Path)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Empty 2D Array (Path)__ogtk.vi"/>
				<Item Name="Empty 2D Array (SGL)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Empty 2D Array (SGL)__ogtk.vi"/>
				<Item Name="Empty 2D Array (String)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Empty 2D Array (String)__ogtk.vi"/>
				<Item Name="Empty 2D Array (U8)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Empty 2D Array (U8)__ogtk.vi"/>
				<Item Name="Empty 2D Array (U16)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Empty 2D Array (U16)__ogtk.vi"/>
				<Item Name="Empty 2D Array (U32)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Empty 2D Array (U32)__ogtk.vi"/>
				<Item Name="Empty 2D Array (U64)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Empty 2D Array (U64)__ogtk.vi"/>
				<Item Name="Empty 2D Array (Variant)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Empty 2D Array (Variant)__ogtk.vi"/>
				<Item Name="Empty Array (Variant)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Empty Array (Variant)__ogtk.vi"/>
				<Item Name="Empty Array__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Empty Array__ogtk.vi"/>
				<Item Name="FilePath.glb.vi" Type="VI" URL="/&lt;userlib&gt;/LevyLab/FileUtilities/FilePath.glb.vi"/>
				<Item Name="Filter Error Codes (Array)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/error/error.llb/Filter Error Codes (Array)__ogtk.vi"/>
				<Item Name="Filter Error Codes (Scalar)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/error/error.llb/Filter Error Codes (Scalar)__ogtk.vi"/>
				<Item Name="Filter Error Codes__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/error/error.llb/Filter Error Codes__ogtk.vi"/>
				<Item Name="Filtered Error Details - Cluster__ogtk.ctl" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/error/error.llb/Filtered Error Details - Cluster__ogtk.ctl"/>
				<Item Name="Fit VI window to Largest Dec__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/appcontrol/appcontrol.llb/Fit VI window to Largest Dec__ogtk.vi"/>
				<Item Name="Get Header from TD__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/lvdata/lvdata.llb/Get Header from TD__ogtk.vi"/>
				<Item Name="increment filename.vi" Type="VI" URL="/&lt;userlib&gt;/LevyLab/FileUtilities/increment filename.vi"/>
				<Item Name="MGI Create Directory Chain Behavior Enum.ctl" Type="VI" URL="/&lt;userlib&gt;/_MGI/File/MGI Create Directory Chain Behavior Enum.ctl"/>
				<Item Name="MGI Create Directory Chain.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/File/MGI Create Directory Chain.vi"/>
				<Item Name="MGI Get Cluster Elements.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/Cluster/MGI Get Cluster Elements.vi"/>
				<Item Name="MGI Hex Str to U8 Data.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/String/MGI Hex Str to U8 Data.vi"/>
				<Item Name="MGI Insert Reserved Error.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/Error Handling/MGI Insert Reserved Error.vi"/>
				<Item Name="MGI Read Anything.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/Read Write Anything/MGI Read Anything.vi"/>
				<Item Name="MGI RWA Anything to String.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/Read Write Anything/MGI RWA Anything to String.vi"/>
				<Item Name="MGI RWA Build Array Name.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/Read Write Anything/MGI RWA Build Array Name.vi"/>
				<Item Name="MGI RWA Build Line.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/Read Write Anything/MGI RWA Build Line.vi"/>
				<Item Name="MGI RWA Convertion Direction Enum.ctl" Type="VI" URL="/&lt;userlib&gt;/_MGI/Read Write Anything/MGI RWA Convertion Direction Enum.ctl"/>
				<Item Name="MGI RWA Enque Top Level Data.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/Read Write Anything/MGI RWA Enque Top Level Data.vi"/>
				<Item Name="MGI RWA Get Type Info.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/Read Write Anything/MGI RWA Get Type Info.vi"/>
				<Item Name="MGI RWA Handle Tag or Refnum.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/Read Write Anything/MGI RWA Handle Tag or Refnum.vi"/>
				<Item Name="MGI RWA INI Tag Lookup.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/Read Write Anything/MGI RWA INI Tag Lookup.vi"/>
				<Item Name="MGI RWA Options Cluster.ctl" Type="VI" URL="/&lt;userlib&gt;/_MGI/Read Write Anything/MGI RWA Options Cluster.ctl"/>
				<Item Name="MGI RWA Process Array Elements.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/Read Write Anything/MGI RWA Process Array Elements.vi"/>
				<Item Name="MGI RWA Read Strings from File.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/Read Write Anything/MGI RWA Read Strings from File.vi"/>
				<Item Name="MGI RWA Remove EOLs and Slashes.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/Read Write Anything/MGI RWA Remove EOLs and Slashes.vi"/>
				<Item Name="MGI RWA Replace Characters.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/Read Write Anything/MGI RWA Replace Characters.vi"/>
				<Item Name="MGI RWA String To Anything.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/Read Write Anything/MGI RWA String To Anything.vi"/>
				<Item Name="MGI RWA Tag Lookup Cluster.ctl" Type="VI" URL="/&lt;userlib&gt;/_MGI/Read Write Anything/MGI RWA Tag Lookup Cluster.ctl"/>
				<Item Name="MGI RWA Unprocess Array Elements.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/Read Write Anything/MGI RWA Unprocess Array Elements.vi"/>
				<Item Name="MGI RWA Unreplace Characters.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/Read Write Anything/MGI RWA Unreplace Characters.vi"/>
				<Item Name="MGI RWA Write Strings to File.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/Read Write Anything/MGI RWA Write Strings to File.vi"/>
				<Item Name="MGI Scan From String (CDB).vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/String/MGI Scan From String/MGI Scan From String (CDB).vi"/>
				<Item Name="MGI Scan From String (CDB[]).vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/String/MGI Scan From String/MGI Scan From String (CDB[]).vi"/>
				<Item Name="MGI Scan From String (CSG).vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/String/MGI Scan From String/MGI Scan From String (CSG).vi"/>
				<Item Name="MGI Scan From String (CSG[]).vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/String/MGI Scan From String/MGI Scan From String (CSG[]).vi"/>
				<Item Name="MGI Scan From String (CXT).vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/String/MGI Scan From String/MGI Scan From String (CXT).vi"/>
				<Item Name="MGI Scan From String (CXT[]).vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/String/MGI Scan From String/MGI Scan From String (CXT[]).vi"/>
				<Item Name="MGI Scan From String (DBL[]).vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/String/MGI Scan From String/MGI Scan From String (DBL[]).vi"/>
				<Item Name="MGI Scan From String.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/String/MGI Scan From String.vi"/>
				<Item Name="MGI Suppress Error Code (Array).vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/Error Handling/MGI Suppress Error Code/MGI Suppress Error Code (Array).vi"/>
				<Item Name="MGI Suppress Error Code (Scalar).vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/Error Handling/MGI Suppress Error Code/MGI Suppress Error Code (Scalar).vi"/>
				<Item Name="MGI Suppress Error Code.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/Error Handling/MGI Suppress Error Code.vi"/>
				<Item Name="MGI U8 Data to Hex Str.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/String/MGI U8 Data to Hex Str.vi"/>
				<Item Name="MGI Windows Get Regional String.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/String/MGI Windows Get Regional String.vi"/>
				<Item Name="MGI Windows Regional Ring.ctl" Type="VI" URL="/&lt;userlib&gt;/_MGI/String/MGI Windows Get Regional String/MGI Windows Regional Ring.ctl"/>
				<Item Name="MGI Write Anything.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/Read Write Anything/MGI Write Anything.vi"/>
				<Item Name="Ramp_SubVI.vi" Type="VI" URL="/&lt;userlib&gt;/LevyLab/Control VI/Other/Ramp_SubVI.vi"/>
				<Item Name="Remove Duplicates from 1D Array (Boolean)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Remove Duplicates from 1D Array (Boolean)__ogtk.vi"/>
				<Item Name="Remove Duplicates from 1D Array (CDB)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Remove Duplicates from 1D Array (CDB)__ogtk.vi"/>
				<Item Name="Remove Duplicates from 1D Array (CSG)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Remove Duplicates from 1D Array (CSG)__ogtk.vi"/>
				<Item Name="Remove Duplicates from 1D Array (CXT)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Remove Duplicates from 1D Array (CXT)__ogtk.vi"/>
				<Item Name="Remove Duplicates from 1D Array (DBL)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Remove Duplicates from 1D Array (DBL)__ogtk.vi"/>
				<Item Name="Remove Duplicates from 1D Array (EXT)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Remove Duplicates from 1D Array (EXT)__ogtk.vi"/>
				<Item Name="Remove Duplicates from 1D Array (I8)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Remove Duplicates from 1D Array (I8)__ogtk.vi"/>
				<Item Name="Remove Duplicates from 1D Array (I16)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Remove Duplicates from 1D Array (I16)__ogtk.vi"/>
				<Item Name="Remove Duplicates from 1D Array (I32)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Remove Duplicates from 1D Array (I32)__ogtk.vi"/>
				<Item Name="Remove Duplicates from 1D Array (I64)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Remove Duplicates from 1D Array (I64)__ogtk.vi"/>
				<Item Name="Remove Duplicates from 1D Array (LVObject)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Remove Duplicates from 1D Array (LVObject)__ogtk.vi"/>
				<Item Name="Remove Duplicates from 1D Array (Path)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Remove Duplicates from 1D Array (Path)__ogtk.vi"/>
				<Item Name="Remove Duplicates from 1D Array (SGL)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Remove Duplicates from 1D Array (SGL)__ogtk.vi"/>
				<Item Name="Remove Duplicates from 1D Array (String)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Remove Duplicates from 1D Array (String)__ogtk.vi"/>
				<Item Name="Remove Duplicates from 1D Array (U8)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Remove Duplicates from 1D Array (U8)__ogtk.vi"/>
				<Item Name="Remove Duplicates from 1D Array (U16)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Remove Duplicates from 1D Array (U16)__ogtk.vi"/>
				<Item Name="Remove Duplicates from 1D Array (U32)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Remove Duplicates from 1D Array (U32)__ogtk.vi"/>
				<Item Name="Remove Duplicates from 1D Array (U64)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Remove Duplicates from 1D Array (U64)__ogtk.vi"/>
				<Item Name="Remove Duplicates from 1D Array (Variant)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Remove Duplicates from 1D Array (Variant)__ogtk.vi"/>
				<Item Name="Remove Duplicates from 1D Array__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/array/array.llb/Remove Duplicates from 1D Array__ogtk.vi"/>
				<Item Name="Strip Path - Arrays__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/file/file.llb/Strip Path - Arrays__ogtk.vi"/>
				<Item Name="Strip Path - Traditional__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/file/file.llb/Strip Path - Traditional__ogtk.vi"/>
				<Item Name="Strip Path__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/file/file.llb/Strip Path__ogtk.vi"/>
				<Item Name="Type Descriptor Enumeration__ogtk.ctl" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/lvdata/lvdata.llb/Type Descriptor Enumeration__ogtk.ctl"/>
				<Item Name="Type Descriptor Header__ogtk.ctl" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/lvdata/lvdata.llb/Type Descriptor Header__ogtk.ctl"/>
				<Item Name="Type Descriptor__ogtk.ctl" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/lvdata/lvdata.llb/Type Descriptor__ogtk.ctl"/>
				<Item Name="Variant to Header Info__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/lvdata/lvdata.llb/Variant to Header Info__ogtk.vi"/>
				<Item Name="Wait (ms)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/time/time.llb/Wait (ms)__ogtk.vi"/>
				<Item Name="Tick Count (ms)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/time/time.llb/Tick Count (ms)__ogtk.vi"/>
				<Item Name="MGI Milliseconds Since Last Call.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/Timing/MGI Milliseconds Since Last Call.vi"/>
				<Item Name="Get Last PString__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/lvdata/lvdata.llb/Get Last PString__ogtk.vi"/>
				<Item Name="Get PString__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/lvdata/lvdata.llb/Get PString__ogtk.vi"/>
				<Item Name="Get Variant Attributes__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/lvdata/lvdata.llb/Get Variant Attributes__ogtk.vi"/>
				<Item Name="Set Data Name__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/lvdata/lvdata.llb/Set Data Name__ogtk.vi"/>
				<Item Name="Get Data Name from TD__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/lvdata/lvdata.llb/Get Data Name from TD__ogtk.vi"/>
				<Item Name="Get Data Name__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/lvdata/lvdata.llb/Get Data Name__ogtk.vi"/>
				<Item Name="Get Element TD from Array TD__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/lvdata/lvdata.llb/Get Element TD from Array TD__ogtk.vi"/>
				<Item Name="Get Array Element TD__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/lvdata/lvdata.llb/Get Array Element TD__ogtk.vi"/>
				<Item Name="Reshape 1D Array__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/lvdata/lvdata.llb/Reshape 1D Array__ogtk.vi"/>
				<Item Name="Reshape Array to 1D VArray__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/lvdata/lvdata.llb/Reshape Array to 1D VArray__ogtk.vi"/>
				<Item Name="Parse String with TDs__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/lvdata/lvdata.llb/Parse String with TDs__ogtk.vi"/>
				<Item Name="Split Cluster TD__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/lvdata/lvdata.llb/Split Cluster TD__ogtk.vi"/>
				<Item Name="Cluster to Array of VData__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/lvdata/lvdata.llb/Cluster to Array of VData__ogtk.vi"/>
				<Item Name="Array to Array of VData__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/lvdata/lvdata.llb/Array to Array of VData__ogtk.vi"/>
				<Item Name="Get TDEnum from Data__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/lvdata/lvdata.llb/Get TDEnum from Data__ogtk.vi"/>
				<Item Name="Array of VData to VArray__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/lvdata/lvdata.llb/Array of VData to VArray__ogtk.vi"/>
				<Item Name="Array of VData to VCluster__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/lvdata/lvdata.llb/Array of VData to VCluster__ogtk.vi"/>
				<Item Name="MGI Remove All Whitespace.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/String/MGI Remove All Whitespace.vi"/>
				<Item Name="LVtoITX.lvclass" Type="LVClass" URL="/&lt;userlib&gt;/LevyLab/LV to ITX/LVtoITX.lvclass"/>
				<Item Name="IBW to Labview Array 2.2.vi" Type="VI" URL="/&lt;userlib&gt;/LevyLab/IBWtoLV/IBW to Labview Array 2.2.vi"/>
				<Item Name="sgl-wordswap.vi" Type="VI" URL="/&lt;userlib&gt;/LevyLab/IBWtoLV/utl/sgl-wordswap.vi"/>
				<Item Name="Make Color Table.vi" Type="VI" URL="/&lt;userlib&gt;/LevyLab/Graph Utilities/Make Color Table.vi"/>
				<Item Name="Ramp.vi" Type="VI" URL="/&lt;userlib&gt;/LevyLab/Control VI/Ramp.vi"/>
				<Item Name="Max_Min_conversion.vi" Type="VI" URL="/&lt;userlib&gt;/LevyLab/Control VI/SubVIs/Max_Min_conversion.vi"/>
				<Item Name="MGI ERD LB Row Base.lvclass" Type="LVClass" URL="/&lt;userlib&gt;/_MGI/Error Reporter/MGI Error Reporter Dialog/MGI ERD LB Row Base/MGI ERD LB Row Base.lvclass"/>
				<Item Name="MGI Error Reporter Dialog.lvclass" Type="LVClass" URL="/&lt;userlib&gt;/_MGI/Error Reporter/MGI Error Reporter Dialog/MGI Error Reporter Dialog.lvclass"/>
				<Item Name="MGI Error Reporter Base.lvclass" Type="LVClass" URL="/&lt;userlib&gt;/_MGI/Error Reporter/MGI Error Reporter Base/MGI Error Reporter Base.lvclass"/>
				<Item Name="MGI Windows Folder Enum.ctl" Type="VI" URL="/&lt;userlib&gt;/_MGI/File/MGI Windows Folder Enum.ctl"/>
				<Item Name="MGI Windows Folder Path.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/File/MGI Windows Folder Path.vi"/>
				<Item Name="MGI Top Level VI Reference.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/Application Control/MGI VI Reference/MGI Top Level VI Reference.vi"/>
				<Item Name="MGI Level&apos;s VI Reference.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/Application Control/MGI VI Reference/MGI Level&apos;s VI Reference.vi"/>
				<Item Name="MGI Current VI&apos;s Reference.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/Application Control/MGI VI Reference/MGI Current VI&apos;s Reference.vi"/>
				<Item Name="MGI Caller&apos;s VI Reference.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/Application Control/MGI VI Reference/MGI Caller&apos;s VI Reference.vi"/>
				<Item Name="MGI VI Reference.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/Application Control/MGI VI Reference.vi"/>
				<Item Name="MGI ERD LB Row Time and Count.lvclass" Type="LVClass" URL="/&lt;userlib&gt;/_MGI/Error Reporter/MGI Error Reporter Dialog/MGI ERD LB Row Time and Count/MGI ERD LB Row Time and Count.lvclass"/>
				<Item Name="MGI Open Explorer Window.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/File/MGI Open Explorer Window.vi"/>
				<Item Name="MGI Is Runtime.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/Application Control/MGI Is Runtime.vi"/>
				<Item Name="MGI Set String Scrollbar.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/Application Control/MGI Set Scrollbar/MGI Set String Scrollbar.vi"/>
				<Item Name="MGI Set Table Scrollbar.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/Application Control/MGI Set Scrollbar/MGI Set Table Scrollbar.vi"/>
				<Item Name="MGI Set Multicolumn Listbox Scrollbar.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/Application Control/MGI Set Scrollbar/MGI Set Multicolumn Listbox Scrollbar.vi"/>
				<Item Name="MGI Set Listbox Scrollbar.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/Application Control/MGI Set Scrollbar/MGI Set Listbox Scrollbar.vi"/>
				<Item Name="MGI Set Scrollbar.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/Application Control/MGI Set Scrollbar.vi"/>
				<Item Name="MGI Gray if True.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/Application Control/MGI Gray if/MGI Gray if True.vi"/>
				<Item Name="MGI Gray if Error.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/Application Control/MGI Gray if/MGI Gray if Error.vi"/>
				<Item Name="MGI Gray if Empty String.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/Application Control/MGI Gray if/MGI Gray if Empty String.vi"/>
				<Item Name="MGI Gray if Zero.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/Application Control/MGI Gray if/MGI Gray if Zero.vi"/>
				<Item Name="MGI Gray if False.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/Application Control/MGI Gray if/MGI Gray if False.vi"/>
				<Item Name="MGI Gray if(PolyVI).vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/Application Control/MGI Gray if(PolyVI).vi"/>
				<Item Name="MGI Coerce Rect into Bounds.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/Picture &amp; Image/MGI Coerce Rect into Bounds.vi"/>
				<Item Name="MGI Coerce Panel Bounds to Viewable Area.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/Application Control/MGI Coerce Panel Bounds to Viewable Area.vi"/>
				<Item Name="MGI SRS Command Enum.ctl" Type="VI" URL="/&lt;userlib&gt;/_MGI/Application Control/MGI Save &amp; Restore Settings/MGI SRS Command Enum.ctl"/>
				<Item Name="MGI SRS MCLB Setting Cluster.ctl" Type="VI" URL="/&lt;userlib&gt;/_MGI/Application Control/MGI Save &amp; Restore Settings/MGI SRS MCLB Setting Cluster.ctl"/>
				<Item Name="MGI SRS Table Settings.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/Application Control/MGI Save &amp; Restore Settings/MGI SRS Table Settings.vi"/>
				<Item Name="MGI SRS Graph Cursor Cluster.ctl" Type="VI" URL="/&lt;userlib&gt;/_MGI/Application Control/MGI Save &amp; Restore Settings/MGI SRS Graph Cursor Cluster.ctl"/>
				<Item Name="MGI SRS Graph Plot Cluster.ctl" Type="VI" URL="/&lt;userlib&gt;/_MGI/Application Control/MGI Save &amp; Restore Settings/MGI SRS Graph Plot Cluster.ctl"/>
				<Item Name="MGI SRS Graph Setting Cluster.ctl" Type="VI" URL="/&lt;userlib&gt;/_MGI/Application Control/MGI Save &amp; Restore Settings/MGI SRS Graph Setting Cluster.ctl"/>
				<Item Name="MGI SRS Graph Settings.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/Application Control/MGI Save &amp; Restore Settings/MGI SRS Graph Settings.vi"/>
				<Item Name="Save Restore Settings.lvclass" Type="LVClass" URL="/&lt;userlib&gt;/_MGI/Application Control/MGI Save Restore Settings/Save Restore Settings.lvclass"/>
				<Item Name="MGI Defer Panel Updates.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/Application Control/MGI Defer Panel Updates.vi"/>
				<Item Name="MGI Save &amp; Restore Settings.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/Application Control/MGI Save &amp; Restore Settings.vi"/>
				<Item Name="MGI Origin at Top Left.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/Application Control/MGI Origin at Top Left.vi"/>
				<Item Name="MGI Default ini Path.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/File/MGI Default ini Path.vi"/>
				<Item Name="MGI Mac Documents Path.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/File/MGI Mac Documents Path.vi"/>
				<Item Name="Multi-line String to Array__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/string/string.llb/Multi-line String to Array__ogtk.vi"/>
				<Item Name="Convert EOLs__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/string/string.llb/Convert EOLs__ogtk.vi"/>
				<Item Name="Convert EOLs (String)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/string/string.llb/Convert EOLs (String)__ogtk.vi"/>
				<Item Name="Convert EOLs (String Array)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/string/string.llb/Convert EOLs (String Array)__ogtk.vi"/>
				<Item Name="String to 1D Array__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/string/string.llb/String to 1D Array__ogtk.vi"/>
				<Item Name="Format number_123456.vi" Type="VI" URL="/&lt;userlib&gt;/LevyLab/FileUtilities/Format number_123456.vi"/>
				<Item Name="RemoteControl.lvclass" Type="LVClass" URL="/&lt;userlib&gt;/LevyLab/Levylab Instruments/SMOs/RemoteControl/RemoteControl.lvclass"/>
				<Item Name="LevyLab.lvclass" Type="LVClass" URL="/&lt;userlib&gt;/LevyLab/Levylab Instruments/SMOs/LevyLab/LevyLab.lvclass"/>
				<Item Name="Logger.Error.lvclass" Type="LVClass" URL="/&lt;userlib&gt;/LevyLab/Levylab Instruments/SMOs/Logger.Error/Logger.Error.lvclass"/>
				<Item Name="Logger.lvclass" Type="LVClass" URL="/&lt;userlib&gt;/LevyLab/Levylab Instruments/SMOs/Logger/Logger.lvclass"/>
				<Item Name="Build Path - Traditional__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/file/file.llb/Build Path - Traditional__ogtk.vi"/>
				<Item Name="Build Path - File Names and Paths Arrays - path__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/file/file.llb/Build Path - File Names and Paths Arrays - path__ogtk.vi"/>
				<Item Name="Build Path - File Names Array - path__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/file/file.llb/Build Path - File Names Array - path__ogtk.vi"/>
				<Item Name="Build Path - Traditional - path__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/file/file.llb/Build Path - Traditional - path__ogtk.vi"/>
				<Item Name="Build Path - File Names and Paths Arrays__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/file/file.llb/Build Path - File Names and Paths Arrays__ogtk.vi"/>
				<Item Name="Build Path - File Names Array__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/file/file.llb/Build Path - File Names Array__ogtk.vi"/>
				<Item Name="Build Path__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/file/file.llb/Build Path__ogtk.vi"/>
				<Item Name="Create Dir if Non-Existant__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/file/file.llb/Create Dir if Non-Existant__ogtk.vi"/>
				<Item Name="Random Number - Within Range__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/numeric/numeric.llb/Random Number - Within Range__ogtk.vi"/>
				<Item Name="Random Number Within Range - I32__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/numeric/numeric.llb/Random Number Within Range - I32__ogtk.vi"/>
				<Item Name="Random Number Within Range - DBL__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/numeric/numeric.llb/Random Number Within Range - DBL__ogtk.vi"/>
				<Item Name="Random Number Within Range__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/numeric/numeric.llb/Random Number Within Range__ogtk.vi"/>
				<Item Name="RemoteControl.STM.lvclass" Type="LVClass" URL="/&lt;userlib&gt;/LevyLab/Levylab Instruments/SMOs/RemoteControl.STM/RemoteControl.STM.lvclass"/>
				<Item Name="Configuration.lvclass" Type="LVClass" URL="/&lt;userlib&gt;/LevyLab/Levylab Instruments/SMOs/Configuration/Configuration.lvclass"/>
				<Item Name="Instrument.lvclass" Type="LVClass" URL="/&lt;userlib&gt;/LevyLab/Levylab Instruments/SMOs/Instrument/Instrument.lvclass"/>
				<Item Name="Encode Section and Key Names__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/variantconfig/variantconfig.llb/Encode Section and Key Names__ogtk.vi"/>
				<Item Name="Trim Whitespace (String)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/string/string.llb/Trim Whitespace (String)__ogtk.vi"/>
				<Item Name="Trim Whitespace (String Array)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/string/string.llb/Trim Whitespace (String Array)__ogtk.vi"/>
				<Item Name="Trim Whitespace__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/string/string.llb/Trim Whitespace__ogtk.vi"/>
				<Item Name="Resolve Timestamp Format__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/string/string.llb/Resolve Timestamp Format__ogtk.vi"/>
				<Item Name="Waveform Subtype Enum__ogtk.ctl" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/lvdata/lvdata.llb/Waveform Subtype Enum__ogtk.ctl"/>
				<Item Name="Get Waveform Type Enum from TD__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/lvdata/lvdata.llb/Get Waveform Type Enum from TD__ogtk.vi"/>
				<Item Name="Get Waveform Type Enum from Data__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/lvdata/lvdata.llb/Get Waveform Type Enum from Data__ogtk.vi"/>
				<Item Name="Get Strings from Enum TD__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/lvdata/lvdata.llb/Get Strings from Enum TD__ogtk.vi"/>
				<Item Name="Get Strings from Enum__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/lvdata/lvdata.llb/Get Strings from Enum__ogtk.vi"/>
				<Item Name="Get Array Element TDEnum__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/lvdata/lvdata.llb/Get Array Element TDEnum__ogtk.vi"/>
				<Item Name="Strip Units__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/lvdata/lvdata.llb/Strip Units__ogtk.vi"/>
				<Item Name="Refnum Subtype Enum__ogtk.ctl" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/lvdata/lvdata.llb/Refnum Subtype Enum__ogtk.ctl"/>
				<Item Name="Get Refnum Type Enum from TD__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/lvdata/lvdata.llb/Get Refnum Type Enum from TD__ogtk.vi"/>
				<Item Name="Get Refnum Type Enum from Data__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/lvdata/lvdata.llb/Get Refnum Type Enum from Data__ogtk.vi"/>
				<Item Name="Format Variant Into String__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/string/string.llb/Format Variant Into String__ogtk.vi"/>
				<Item Name="Format Numeric Array__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/variantconfig/variantconfig.llb/Format Numeric Array__ogtk.vi"/>
				<Item Name="Write Key (Variant)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/variantconfig/variantconfig.llb/Write Key (Variant)__ogtk.vi"/>
				<Item Name="Write Section Cluster__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/variantconfig/variantconfig.llb/Write Section Cluster__ogtk.vi"/>
				<Item Name="Set Enum String Value__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/lvdata/lvdata.llb/Set Enum String Value__ogtk.vi"/>
				<Item Name="Get Default Data from TD__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/lvdata/lvdata.llb/Get Default Data from TD__ogtk.vi"/>
				<Item Name="Read Key (Variant)__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/variantconfig/variantconfig.llb/Read Key (Variant)__ogtk.vi"/>
				<Item Name="Read Section Cluster__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/variantconfig/variantconfig.llb/Read Section Cluster__ogtk.vi"/>
				<Item Name="Logger.DSC.lvclass" Type="LVClass" URL="/&lt;userlib&gt;/LevyLab/Levylab Instruments/SMOs/Logger.DSC/Logger.DSC.lvclass"/>
				<Item Name="Periodic Trigger__ogtk.vi" Type="VI" URL="/&lt;userlib&gt;/_OpenG.lib/time/time.llb/Periodic Trigger__ogtk.vi"/>
				<Item Name="MGI Append String to Error Source.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/Error Handling/MGI Append String to Error Source.vi"/>
				<Item Name="MGI Make String Filesafe.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/String/MGI Make String Filesafe.vi"/>
				<Item Name="Get Terminal Name with Device Prefix.vi" Type="VI" URL="/&lt;userlib&gt;/LevyLab/Lockin-Multichannel/subVIs - DAQ/Get Terminal Name with Device Prefix.vi"/>
				<Item Name="MGI Milliseconds Since Last Reset.vi" Type="VI" URL="/&lt;userlib&gt;/_MGI/Timing/MGI Milliseconds Since Last Reset.vi"/>
				<Item Name="Instrument.Lockin.lvclass" Type="LVClass" URL="/&lt;userlib&gt;/LevyLab/Lockin-Multichannel/Instrument.Lockin/Instrument.Lockin.lvclass"/>
				<Item Name="getTimeWithError.vi" Type="VI" URL="/&lt;userlib&gt;/LevyLab/Lockin-Multichannel/SubVIs/getTimeWithError.vi"/>
				<Item Name="StateHistory.vi" Type="VI" URL="/&lt;userlib&gt;/LevyLab/Lockin-Multichannel/SubVIs/StateHistory.vi"/>
				<Item Name="Spinner.vi" Type="VI" URL="/&lt;userlib&gt;/LevyLab/Lockin-Multichannel/SubVIs/Spinner.vi"/>
				<Item Name="Channel String to Number of Channels.vi" Type="VI" URL="/&lt;userlib&gt;/LevyLab/Lockin-Multichannel/SubVIs/Channel String to Number of Channels.vi"/>
				<Item Name="LegendWaveformChart.vi" Type="VI" URL="/&lt;userlib&gt;/LevyLab/Lockin-Multichannel/SubVIs/LegendWaveformChart.vi"/>
				<Item Name="LegendXYGraph.vi" Type="VI" URL="/&lt;userlib&gt;/LevyLab/Lockin-Multichannel/SubVIs/LegendXYGraph.vi"/>
				<Item Name="FloatApproxPoint1Percent.vi" Type="VI" URL="/&lt;userlib&gt;/LevyLab/Lockin-Multichannel/SubVIs/FloatApproxPoint1Percent.vi"/>
				<Item Name="Fs and Ns for integer periods.vi" Type="VI" URL="/&lt;userlib&gt;/LevyLab/Lockin-Multichannel/SubVIs/Fs and Ns for integer periods.vi"/>
				<Item Name="FloatApprox.vi" Type="VI" URL="/&lt;userlib&gt;/LevyLab/Lockin-Multichannel/SubVIs/FloatApprox.vi"/>
				<Item Name="4461 - Cal Info.vi" Type="VI" URL="/&lt;userlib&gt;/LevyLab/Lockin-Multichannel/subVIs - DAQ/4461 - Cal Info.vi"/>
				<Item Name="4461 - Create Reference Waveforms.vi" Type="VI" URL="/&lt;userlib&gt;/LevyLab/Lockin-Multichannel/subVIs - DAQ/4461 - Create Reference Waveforms.vi"/>
				<Item Name="decimate_waveforms.vi" Type="VI" URL="/&lt;userlib&gt;/LevyLab/Lockin-Multichannel/SubVIs/decimate_waveforms.vi"/>
				<Item Name="4461 - Create AO waveforms.vi" Type="VI" URL="/&lt;userlib&gt;/LevyLab/Lockin-Multichannel/subVIs - DAQ/4461 - Create AO waveforms.vi"/>
				<Item Name="4461 - Create IO Channels Parallel Uneven.vi" Type="VI" URL="/&lt;userlib&gt;/LevyLab/Lockin-Multichannel/subVIs - DAQ/4461 - Create IO Channels Parallel Uneven.vi"/>
				<Item Name="AI.Coupling.enum.convert.vi" Type="VI" URL="/&lt;userlib&gt;/LevyLab/Lockin-Multichannel/SubVIs/AI.Coupling.enum.convert.vi"/>
				<Item Name="44xx_AI_MinMax.vi" Type="VI" URL="/&lt;userlib&gt;/LevyLab/Lockin-Multichannel/subVIs - DAQ/44xx_AI_MinMax.vi"/>
				<Item Name="Fs_to_FilterDelay.vi" Type="VI" URL="/&lt;userlib&gt;/LevyLab/Lockin-Multichannel/SubVIs/Fs_to_FilterDelay.vi"/>
				<Item Name="Get Dev Product Type.vi" Type="VI" URL="/&lt;userlib&gt;/LevyLab/Lockin-Multichannel/subVIs - DAQ/Get Dev Product Type.vi"/>
				<Item Name="44xxRefClk.vi" Type="VI" URL="/&lt;userlib&gt;/LevyLab/Lockin-Multichannel/subVIs - DAQ/44xxRefClk.vi"/>
				<Item Name="44xx_AO_MinMax.vi" Type="VI" URL="/&lt;userlib&gt;/LevyLab/Lockin-Multichannel/subVIs - DAQ/44xx_AO_MinMax.vi"/>
				<Item Name="4461 - AI AND AI - Read AND Write Uneven.vi" Type="VI" URL="/&lt;userlib&gt;/LevyLab/Lockin-Multichannel/subVIs - DAQ/4461 - AI AND AI - Read AND Write Uneven.vi"/>
				<Item Name="4461 Sim - Noise.vi" Type="VI" URL="/&lt;userlib&gt;/LevyLab/Lockin-Multichannel/subVIs - DAQ/4461 Sim - Noise.vi"/>
				<Item Name="Prefilter_60Hz_Notch.vi" Type="VI" URL="/&lt;userlib&gt;/LevyLab/Lockin-Multichannel/SubVIs/Prefilter_60Hz_Notch.vi"/>
				<Item Name="Prefilter_LP.vi" Type="VI" URL="/&lt;userlib&gt;/LevyLab/Lockin-Multichannel/SubVIs/Prefilter_LP.vi"/>
				<Item Name="lockin - add phase element.vi" Type="VI" URL="/&lt;userlib&gt;/LevyLab/Lockin-Multichannel/SubVIs/lockin - add phase element.vi"/>
				<Item Name="lockin - Set all f same.vi" Type="VI" URL="/&lt;userlib&gt;/LevyLab/Lockin-Multichannel/SubVIs/lockin - Set all f same.vi"/>
				<Item Name="lockin - Set REF phase equals zero.vi" Type="VI" URL="/&lt;userlib&gt;/LevyLab/Lockin-Multichannel/SubVIs/lockin - Set REF phase equals zero.vi"/>
				<Item Name="Simple PID Array.vi" Type="VI" URL="/&lt;userlib&gt;/LevyLab/Lockin-Multichannel/SubVIs/Simple PID Array.vi"/>
				<Item Name="4461 - Lockin Engine.vi" Type="VI" URL="/&lt;userlib&gt;/LevyLab/Lockin-Multichannel/subVIs - DAQ/4461 - Lockin Engine.vi"/>
				<Item Name="Replace timestamp.vi" Type="VI" URL="/&lt;userlib&gt;/LevyLab/Lockin-Multichannel/SubVIs/Replace timestamp.vi"/>
				<Item Name="Waveform 64-128 channels LP pt by pt.vi" Type="VI" URL="/&lt;userlib&gt;/LevyLab/Lockin-Multichannel/SubVIs/Waveform 64-128 channels LP pt by pt.vi"/>
				<Item Name="Split 1D ARRAY in half.vi" Type="VI" URL="/&lt;userlib&gt;/LevyLab/Lockin-Multichannel/SubVIs/Split 1D ARRAY in half.vi"/>
				<Item Name="format display.vi" Type="VI" URL="/&lt;userlib&gt;/LevyLab/Lockin-Multichannel/SubVIs/format display.vi"/>
				<Item Name="Display n or dt.vi" Type="VI" URL="/&lt;userlib&gt;/LevyLab/Lockin-Multichannel/SubVIs/Display n or dt.vi"/>
				<Item Name="LegendWaveformGraph.vi" Type="VI" URL="/&lt;userlib&gt;/LevyLab/Lockin-Multichannel/SubVIs/LegendWaveformGraph.vi"/>
				<Item Name="4461 - Stop Tasks.vi" Type="VI" URL="/&lt;userlib&gt;/LevyLab/Lockin-Multichannel/subVIs - DAQ/4461 - Stop Tasks.vi"/>
				<Item Name="write_lockin_FP_DSC.vi" Type="VI" URL="/&lt;userlib&gt;/LevyLab/Lockin-Multichannel/SubVIs/write_lockin_FP_DSC.vi"/>
				<Item Name="FPDAQtoDAQstrings.vi" Type="VI" URL="/&lt;userlib&gt;/LevyLab/Lockin-Multichannel/SubVIs/FPDAQtoDAQstrings.vi"/>
				<Item Name="read_lockin_FP_DSC.vi" Type="VI" URL="/&lt;userlib&gt;/LevyLab/Lockin-Multichannel/SubVIs/read_lockin_FP_DSC.vi"/>
				<Item Name="Instrument.Lockin.UI.lvclass" Type="LVClass" URL="/&lt;userlib&gt;/LevyLab/Lockin-Multichannel/Instrument.Lockinl.UI/Instrument.Lockin.UI.lvclass"/>
			</Item>
			<Item Name="vi.lib" Type="Folder">
				<Item Name="8.6CompatibleGlobalVar.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/config.llb/8.6CompatibleGlobalVar.vi"/>
				<Item Name="Add State(s) to Queue__jki_lib_state_machine.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/State Machine/_JKI_lib_State_Machine.llb/Add State(s) to Queue__jki_lib_state_machine.vi"/>
				<Item Name="BuildHelpPath.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/BuildHelpPath.vi"/>
				<Item Name="Check if File or Folder Exists.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/libraryn.llb/Check if File or Folder Exists.vi"/>
				<Item Name="Check Special Tags.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Check Special Tags.vi"/>
				<Item Name="Clear Errors.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Clear Errors.vi"/>
				<Item Name="Close File+.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/file.llb/Close File+.vi"/>
				<Item Name="Color to RGB.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/colorconv.llb/Color to RGB.vi"/>
				<Item Name="compatReadText.vi" Type="VI" URL="/&lt;vilib&gt;/_oldvers/_oldvers.llb/compatReadText.vi"/>
				<Item Name="Convert property node font to graphics font.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Convert property node font to graphics font.vi"/>
				<Item Name="DAQmx Advance Trigger (Digital Edge).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/configure/trigger.llb/DAQmx Advance Trigger (Digital Edge).vi"/>
				<Item Name="DAQmx Advance Trigger (None).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/configure/trigger.llb/DAQmx Advance Trigger (None).vi"/>
				<Item Name="DAQmx Clear Task.vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/configure/task.llb/DAQmx Clear Task.vi"/>
				<Item Name="DAQmx Configure Input Buffer.vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/configure/buffer.llb/DAQmx Configure Input Buffer.vi"/>
				<Item Name="DAQmx Create Channel (AI-Acceleration-Accelerometer).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Acceleration-Accelerometer).vi"/>
				<Item Name="DAQmx Create Channel (AI-Bridge).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Bridge).vi"/>
				<Item Name="DAQmx Create Channel (AI-Current-Basic).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Current-Basic).vi"/>
				<Item Name="DAQmx Create Channel (AI-Current-RMS).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Current-RMS).vi"/>
				<Item Name="DAQmx Create Channel (AI-Force-Bridge-Polynomial).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Force-Bridge-Polynomial).vi"/>
				<Item Name="DAQmx Create Channel (AI-Force-Bridge-Table).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Force-Bridge-Table).vi"/>
				<Item Name="DAQmx Create Channel (AI-Force-Bridge-Two-Point-Linear).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Force-Bridge-Two-Point-Linear).vi"/>
				<Item Name="DAQmx Create Channel (AI-Force-IEPE Sensor).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Force-IEPE Sensor).vi"/>
				<Item Name="DAQmx Create Channel (AI-Frequency-Voltage).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Frequency-Voltage).vi"/>
				<Item Name="DAQmx Create Channel (AI-Position-EddyCurrentProxProbe).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Position-EddyCurrentProxProbe).vi"/>
				<Item Name="DAQmx Create Channel (AI-Position-LVDT).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Position-LVDT).vi"/>
				<Item Name="DAQmx Create Channel (AI-Position-RVDT).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Position-RVDT).vi"/>
				<Item Name="DAQmx Create Channel (AI-Pressure-Bridge-Polynomial).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Pressure-Bridge-Polynomial).vi"/>
				<Item Name="DAQmx Create Channel (AI-Pressure-Bridge-Table).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Pressure-Bridge-Table).vi"/>
				<Item Name="DAQmx Create Channel (AI-Pressure-Bridge-Two-Point-Linear).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Pressure-Bridge-Two-Point-Linear).vi"/>
				<Item Name="DAQmx Create Channel (AI-Resistance).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Resistance).vi"/>
				<Item Name="DAQmx Create Channel (AI-Sound Pressure-Microphone).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Sound Pressure-Microphone).vi"/>
				<Item Name="DAQmx Create Channel (AI-Strain-Rosette Strain Gage).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Strain-Rosette Strain Gage).vi"/>
				<Item Name="DAQmx Create Channel (AI-Strain-Strain Gage).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Strain-Strain Gage).vi"/>
				<Item Name="DAQmx Create Channel (AI-Temperature-Built-in Sensor).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Temperature-Built-in Sensor).vi"/>
				<Item Name="DAQmx Create Channel (AI-Temperature-RTD).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Temperature-RTD).vi"/>
				<Item Name="DAQmx Create Channel (AI-Temperature-Thermistor-Iex).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Temperature-Thermistor-Iex).vi"/>
				<Item Name="DAQmx Create Channel (AI-Temperature-Thermistor-Vex).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Temperature-Thermistor-Vex).vi"/>
				<Item Name="DAQmx Create Channel (AI-Temperature-Thermocouple).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Temperature-Thermocouple).vi"/>
				<Item Name="DAQmx Create Channel (AI-Torque-Bridge-Polynomial).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Torque-Bridge-Polynomial).vi"/>
				<Item Name="DAQmx Create Channel (AI-Torque-Bridge-Table).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Torque-Bridge-Table).vi"/>
				<Item Name="DAQmx Create Channel (AI-Torque-Bridge-Two-Point-Linear).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Torque-Bridge-Two-Point-Linear).vi"/>
				<Item Name="DAQmx Create Channel (AI-Velocity-IEPE Sensor).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Velocity-IEPE Sensor).vi"/>
				<Item Name="DAQmx Create Channel (AI-Voltage-Basic).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Voltage-Basic).vi"/>
				<Item Name="DAQmx Create Channel (AI-Voltage-Custom with Excitation).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Voltage-Custom with Excitation).vi"/>
				<Item Name="DAQmx Create Channel (AI-Voltage-RMS).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Voltage-RMS).vi"/>
				<Item Name="DAQmx Create Channel (AO-Current-Basic).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AO-Current-Basic).vi"/>
				<Item Name="DAQmx Create Channel (AO-FuncGen).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AO-FuncGen).vi"/>
				<Item Name="DAQmx Create Channel (AO-Voltage-Basic).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AO-Voltage-Basic).vi"/>
				<Item Name="DAQmx Create Channel (CI-Count Edges).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (CI-Count Edges).vi"/>
				<Item Name="DAQmx Create Channel (CI-Duty Cycle).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (CI-Duty Cycle).vi"/>
				<Item Name="DAQmx Create Channel (CI-Frequency).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (CI-Frequency).vi"/>
				<Item Name="DAQmx Create Channel (CI-GPS Timestamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (CI-GPS Timestamp).vi"/>
				<Item Name="DAQmx Create Channel (CI-Period).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (CI-Period).vi"/>
				<Item Name="DAQmx Create Channel (CI-Position-Angular Encoder).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (CI-Position-Angular Encoder).vi"/>
				<Item Name="DAQmx Create Channel (CI-Position-Linear Encoder).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (CI-Position-Linear Encoder).vi"/>
				<Item Name="DAQmx Create Channel (CI-Pulse Freq).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (CI-Pulse Freq).vi"/>
				<Item Name="DAQmx Create Channel (CI-Pulse Ticks).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (CI-Pulse Ticks).vi"/>
				<Item Name="DAQmx Create Channel (CI-Pulse Time).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (CI-Pulse Time).vi"/>
				<Item Name="DAQmx Create Channel (CI-Pulse Width).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (CI-Pulse Width).vi"/>
				<Item Name="DAQmx Create Channel (CI-Semi Period).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (CI-Semi Period).vi"/>
				<Item Name="DAQmx Create Channel (CI-Two Edge Separation).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (CI-Two Edge Separation).vi"/>
				<Item Name="DAQmx Create Channel (CI-Velocity-Angular).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (CI-Velocity-Angular).vi"/>
				<Item Name="DAQmx Create Channel (CI-Velocity-Linear).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (CI-Velocity-Linear).vi"/>
				<Item Name="DAQmx Create Channel (CO-Pulse Generation-Frequency).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (CO-Pulse Generation-Frequency).vi"/>
				<Item Name="DAQmx Create Channel (CO-Pulse Generation-Ticks).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (CO-Pulse Generation-Ticks).vi"/>
				<Item Name="DAQmx Create Channel (CO-Pulse Generation-Time).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (CO-Pulse Generation-Time).vi"/>
				<Item Name="DAQmx Create Channel (DI-Digital Input).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (DI-Digital Input).vi"/>
				<Item Name="DAQmx Create Channel (DO-Digital Output).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (DO-Digital Output).vi"/>
				<Item Name="DAQmx Create Channel (TEDS-AI-Acceleration-Accelerometer).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (TEDS-AI-Acceleration-Accelerometer).vi"/>
				<Item Name="DAQmx Create Channel (TEDS-AI-Bridge).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (TEDS-AI-Bridge).vi"/>
				<Item Name="DAQmx Create Channel (TEDS-AI-Current-Basic).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (TEDS-AI-Current-Basic).vi"/>
				<Item Name="DAQmx Create Channel (TEDS-AI-Force-Bridge).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (TEDS-AI-Force-Bridge).vi"/>
				<Item Name="DAQmx Create Channel (TEDS-AI-Force-IEPE Sensor).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (TEDS-AI-Force-IEPE Sensor).vi"/>
				<Item Name="DAQmx Create Channel (TEDS-AI-Position-LVDT).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (TEDS-AI-Position-LVDT).vi"/>
				<Item Name="DAQmx Create Channel (TEDS-AI-Position-RVDT).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (TEDS-AI-Position-RVDT).vi"/>
				<Item Name="DAQmx Create Channel (TEDS-AI-Pressure-Bridge).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (TEDS-AI-Pressure-Bridge).vi"/>
				<Item Name="DAQmx Create Channel (TEDS-AI-Resistance).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (TEDS-AI-Resistance).vi"/>
				<Item Name="DAQmx Create Channel (TEDS-AI-Sound Pressure-Microphone).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (TEDS-AI-Sound Pressure-Microphone).vi"/>
				<Item Name="DAQmx Create Channel (TEDS-AI-Strain-Strain Gage).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (TEDS-AI-Strain-Strain Gage).vi"/>
				<Item Name="DAQmx Create Channel (TEDS-AI-Temperature-RTD).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (TEDS-AI-Temperature-RTD).vi"/>
				<Item Name="DAQmx Create Channel (TEDS-AI-Temperature-Thermistor-Iex).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (TEDS-AI-Temperature-Thermistor-Iex).vi"/>
				<Item Name="DAQmx Create Channel (TEDS-AI-Temperature-Thermistor-Vex).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (TEDS-AI-Temperature-Thermistor-Vex).vi"/>
				<Item Name="DAQmx Create Channel (TEDS-AI-Temperature-Thermocouple).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (TEDS-AI-Temperature-Thermocouple).vi"/>
				<Item Name="DAQmx Create Channel (TEDS-AI-Torque-Bridge).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (TEDS-AI-Torque-Bridge).vi"/>
				<Item Name="DAQmx Create Channel (TEDS-AI-Voltage-Basic).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (TEDS-AI-Voltage-Basic).vi"/>
				<Item Name="DAQmx Create Channel (TEDS-AI-Voltage-Custom with Excitation).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (TEDS-AI-Voltage-Custom with Excitation).vi"/>
				<Item Name="DAQmx Create Virtual Channel.vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Virtual Channel.vi"/>
				<Item Name="DAQmx Fill In Error Info.vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/miscellaneous.llb/DAQmx Fill In Error Info.vi"/>
				<Item Name="DAQmx Read (Analog 1D DBL 1Chan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Analog 1D DBL 1Chan NSamp).vi"/>
				<Item Name="DAQmx Read (Analog 1D DBL NChan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Analog 1D DBL NChan 1Samp).vi"/>
				<Item Name="DAQmx Read (Analog 1D Wfm NChan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Analog 1D Wfm NChan 1Samp).vi"/>
				<Item Name="DAQmx Read (Analog 1D Wfm NChan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Analog 1D Wfm NChan NSamp).vi"/>
				<Item Name="DAQmx Read (Analog 2D DBL NChan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Analog 2D DBL NChan NSamp).vi"/>
				<Item Name="DAQmx Read (Analog 2D I16 NChan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Analog 2D I16 NChan NSamp).vi"/>
				<Item Name="DAQmx Read (Analog 2D I32 NChan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Analog 2D I32 NChan NSamp).vi"/>
				<Item Name="DAQmx Read (Analog 2D U16 NChan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Analog 2D U16 NChan NSamp).vi"/>
				<Item Name="DAQmx Read (Analog 2D U32 NChan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Analog 2D U32 NChan NSamp).vi"/>
				<Item Name="DAQmx Read (Analog DBL 1Chan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Analog DBL 1Chan 1Samp).vi"/>
				<Item Name="DAQmx Read (Analog Wfm 1Chan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Analog Wfm 1Chan 1Samp).vi"/>
				<Item Name="DAQmx Read (Analog Wfm 1Chan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Analog Wfm 1Chan NSamp).vi"/>
				<Item Name="DAQmx Read (Counter 1D DBL 1Chan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Counter 1D DBL 1Chan NSamp).vi"/>
				<Item Name="DAQmx Read (Counter 1D DBL NChan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Counter 1D DBL NChan 1Samp).vi"/>
				<Item Name="DAQmx Read (Counter 1D Pulse Freq 1 Chan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Counter 1D Pulse Freq 1 Chan NSamp).vi"/>
				<Item Name="DAQmx Read (Counter 1D Pulse Ticks 1Chan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Counter 1D Pulse Ticks 1Chan NSamp).vi"/>
				<Item Name="DAQmx Read (Counter 1D Pulse Time 1Chan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Counter 1D Pulse Time 1Chan NSamp).vi"/>
				<Item Name="DAQmx Read (Counter 1D U32 1Chan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Counter 1D U32 1Chan NSamp).vi"/>
				<Item Name="DAQmx Read (Counter 1D U32 NChan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Counter 1D U32 NChan 1Samp).vi"/>
				<Item Name="DAQmx Read (Counter 2D DBL NChan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Counter 2D DBL NChan NSamp).vi"/>
				<Item Name="DAQmx Read (Counter 2D U32 NChan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Counter 2D U32 NChan NSamp).vi"/>
				<Item Name="DAQmx Read (Counter DBL 1Chan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Counter DBL 1Chan 1Samp).vi"/>
				<Item Name="DAQmx Read (Counter Pulse Freq 1 Chan 1 Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Counter Pulse Freq 1 Chan 1 Samp).vi"/>
				<Item Name="DAQmx Read (Counter Pulse Ticks 1Chan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Counter Pulse Ticks 1Chan 1Samp).vi"/>
				<Item Name="DAQmx Read (Counter Pulse Time 1Chan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Counter Pulse Time 1Chan 1Samp).vi"/>
				<Item Name="DAQmx Read (Counter U32 1Chan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Counter U32 1Chan 1Samp).vi"/>
				<Item Name="DAQmx Read (Digital 1D Bool 1Chan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Digital 1D Bool 1Chan 1Samp).vi"/>
				<Item Name="DAQmx Read (Digital 1D Bool NChan 1Samp 1Line).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Digital 1D Bool NChan 1Samp 1Line).vi"/>
				<Item Name="DAQmx Read (Digital 1D U8 1Chan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Digital 1D U8 1Chan NSamp).vi"/>
				<Item Name="DAQmx Read (Digital 1D U8 NChan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Digital 1D U8 NChan 1Samp).vi"/>
				<Item Name="DAQmx Read (Digital 1D U16 1Chan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Digital 1D U16 1Chan NSamp).vi"/>
				<Item Name="DAQmx Read (Digital 1D U16 NChan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Digital 1D U16 NChan 1Samp).vi"/>
				<Item Name="DAQmx Read (Digital 1D U32 1Chan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Digital 1D U32 1Chan NSamp).vi"/>
				<Item Name="DAQmx Read (Digital 1D U32 NChan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Digital 1D U32 NChan 1Samp).vi"/>
				<Item Name="DAQmx Read (Digital 1D Wfm NChan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Digital 1D Wfm NChan 1Samp).vi"/>
				<Item Name="DAQmx Read (Digital 1D Wfm NChan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Digital 1D Wfm NChan NSamp).vi"/>
				<Item Name="DAQmx Read (Digital 2D Bool NChan 1Samp NLine).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Digital 2D Bool NChan 1Samp NLine).vi"/>
				<Item Name="DAQmx Read (Digital 2D U8 NChan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Digital 2D U8 NChan NSamp).vi"/>
				<Item Name="DAQmx Read (Digital 2D U16 NChan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Digital 2D U16 NChan NSamp).vi"/>
				<Item Name="DAQmx Read (Digital 2D U32 NChan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Digital 2D U32 NChan NSamp).vi"/>
				<Item Name="DAQmx Read (Digital Bool 1Line 1Point).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Digital Bool 1Line 1Point).vi"/>
				<Item Name="DAQmx Read (Digital U8 1Chan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Digital U8 1Chan 1Samp).vi"/>
				<Item Name="DAQmx Read (Digital U16 1Chan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Digital U16 1Chan 1Samp).vi"/>
				<Item Name="DAQmx Read (Digital U32 1Chan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Digital U32 1Chan 1Samp).vi"/>
				<Item Name="DAQmx Read (Digital Wfm 1Chan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Digital Wfm 1Chan 1Samp).vi"/>
				<Item Name="DAQmx Read (Digital Wfm 1Chan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Digital Wfm 1Chan NSamp).vi"/>
				<Item Name="DAQmx Read (Raw 1D I8).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Raw 1D I8).vi"/>
				<Item Name="DAQmx Read (Raw 1D I16).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Raw 1D I16).vi"/>
				<Item Name="DAQmx Read (Raw 1D I32).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Raw 1D I32).vi"/>
				<Item Name="DAQmx Read (Raw 1D U8).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Raw 1D U8).vi"/>
				<Item Name="DAQmx Read (Raw 1D U16).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Raw 1D U16).vi"/>
				<Item Name="DAQmx Read (Raw 1D U32).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read (Raw 1D U32).vi"/>
				<Item Name="DAQmx Read.vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/read.llb/DAQmx Read.vi"/>
				<Item Name="DAQmx Reference Trigger (Analog Edge).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/configure/trigger.llb/DAQmx Reference Trigger (Analog Edge).vi"/>
				<Item Name="DAQmx Reference Trigger (Analog Window).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/configure/trigger.llb/DAQmx Reference Trigger (Analog Window).vi"/>
				<Item Name="DAQmx Reference Trigger (Digital Edge).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/configure/trigger.llb/DAQmx Reference Trigger (Digital Edge).vi"/>
				<Item Name="DAQmx Reference Trigger (Digital Pattern).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/configure/trigger.llb/DAQmx Reference Trigger (Digital Pattern).vi"/>
				<Item Name="DAQmx Reference Trigger (None).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/configure/trigger.llb/DAQmx Reference Trigger (None).vi"/>
				<Item Name="DAQmx Self Calibrate.vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/calibration/calibrationInfo.llb/DAQmx Self Calibrate.vi"/>
				<Item Name="DAQmx Start Task.vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/configure/task.llb/DAQmx Start Task.vi"/>
				<Item Name="DAQmx Start Trigger (Analog Edge).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/configure/trigger.llb/DAQmx Start Trigger (Analog Edge).vi"/>
				<Item Name="DAQmx Start Trigger (Analog Window).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/configure/trigger.llb/DAQmx Start Trigger (Analog Window).vi"/>
				<Item Name="DAQmx Start Trigger (Digital Edge).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/configure/trigger.llb/DAQmx Start Trigger (Digital Edge).vi"/>
				<Item Name="DAQmx Start Trigger (Digital Pattern).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/configure/trigger.llb/DAQmx Start Trigger (Digital Pattern).vi"/>
				<Item Name="DAQmx Start Trigger (None).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/configure/trigger.llb/DAQmx Start Trigger (None).vi"/>
				<Item Name="DAQmx Stop Task.vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/configure/task.llb/DAQmx Stop Task.vi"/>
				<Item Name="DAQmx Timing (Burst Export Clock).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/configure/timing.llb/DAQmx Timing (Burst Export Clock).vi"/>
				<Item Name="DAQmx Timing (Burst Import Clock).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/configure/timing.llb/DAQmx Timing (Burst Import Clock).vi"/>
				<Item Name="DAQmx Timing (Change Detection).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/configure/timing.llb/DAQmx Timing (Change Detection).vi"/>
				<Item Name="DAQmx Timing (Handshaking).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/configure/timing.llb/DAQmx Timing (Handshaking).vi"/>
				<Item Name="DAQmx Timing (Implicit).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/configure/timing.llb/DAQmx Timing (Implicit).vi"/>
				<Item Name="DAQmx Timing (Pipelined Sample Clock).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/configure/timing.llb/DAQmx Timing (Pipelined Sample Clock).vi"/>
				<Item Name="DAQmx Timing (Sample Clock).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/configure/timing.llb/DAQmx Timing (Sample Clock).vi"/>
				<Item Name="DAQmx Timing (Use Waveform).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/configure/timing.llb/DAQmx Timing (Use Waveform).vi"/>
				<Item Name="DAQmx Timing.vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/configure/timing.llb/DAQmx Timing.vi"/>
				<Item Name="DAQmx Trigger.vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/configure/trigger.llb/DAQmx Trigger.vi"/>
				<Item Name="DAQmx Write (Analog 1D DBL 1Chan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Analog 1D DBL 1Chan NSamp).vi"/>
				<Item Name="DAQmx Write (Analog 1D DBL NChan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Analog 1D DBL NChan 1Samp).vi"/>
				<Item Name="DAQmx Write (Analog 1D Wfm NChan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Analog 1D Wfm NChan 1Samp).vi"/>
				<Item Name="DAQmx Write (Analog 1D Wfm NChan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Analog 1D Wfm NChan NSamp).vi"/>
				<Item Name="DAQmx Write (Analog 2D DBL NChan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Analog 2D DBL NChan NSamp).vi"/>
				<Item Name="DAQmx Write (Analog 2D I16 NChan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Analog 2D I16 NChan NSamp).vi"/>
				<Item Name="DAQmx Write (Analog 2D I32 NChan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Analog 2D I32 NChan NSamp).vi"/>
				<Item Name="DAQmx Write (Analog 2D U16 NChan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Analog 2D U16 NChan NSamp).vi"/>
				<Item Name="DAQmx Write (Analog DBL 1Chan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Analog DBL 1Chan 1Samp).vi"/>
				<Item Name="DAQmx Write (Analog Wfm 1Chan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Analog Wfm 1Chan 1Samp).vi"/>
				<Item Name="DAQmx Write (Analog Wfm 1Chan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Analog Wfm 1Chan NSamp).vi"/>
				<Item Name="DAQmx Write (Counter 1D Frequency 1Chan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Counter 1D Frequency 1Chan NSamp).vi"/>
				<Item Name="DAQmx Write (Counter 1D Frequency NChan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Counter 1D Frequency NChan 1Samp).vi"/>
				<Item Name="DAQmx Write (Counter 1D Ticks 1Chan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Counter 1D Ticks 1Chan NSamp).vi"/>
				<Item Name="DAQmx Write (Counter 1D Time 1Chan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Counter 1D Time 1Chan NSamp).vi"/>
				<Item Name="DAQmx Write (Counter 1D Time NChan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Counter 1D Time NChan 1Samp).vi"/>
				<Item Name="DAQmx Write (Counter 1DTicks NChan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Counter 1DTicks NChan 1Samp).vi"/>
				<Item Name="DAQmx Write (Counter Frequency 1Chan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Counter Frequency 1Chan 1Samp).vi"/>
				<Item Name="DAQmx Write (Counter Ticks 1Chan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Counter Ticks 1Chan 1Samp).vi"/>
				<Item Name="DAQmx Write (Counter Time 1Chan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Counter Time 1Chan 1Samp).vi"/>
				<Item Name="DAQmx Write (Digital 1D Bool 1Chan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Digital 1D Bool 1Chan 1Samp).vi"/>
				<Item Name="DAQmx Write (Digital 1D Bool NChan 1Samp 1Line).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Digital 1D Bool NChan 1Samp 1Line).vi"/>
				<Item Name="DAQmx Write (Digital 1D U8 1Chan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Digital 1D U8 1Chan NSamp).vi"/>
				<Item Name="DAQmx Write (Digital 1D U8 NChan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Digital 1D U8 NChan 1Samp).vi"/>
				<Item Name="DAQmx Write (Digital 1D U16 1Chan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Digital 1D U16 1Chan NSamp).vi"/>
				<Item Name="DAQmx Write (Digital 1D U16 NChan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Digital 1D U16 NChan 1Samp).vi"/>
				<Item Name="DAQmx Write (Digital 1D U32 1Chan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Digital 1D U32 1Chan NSamp).vi"/>
				<Item Name="DAQmx Write (Digital 1D U32 NChan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Digital 1D U32 NChan 1Samp).vi"/>
				<Item Name="DAQmx Write (Digital 1D Wfm NChan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Digital 1D Wfm NChan 1Samp).vi"/>
				<Item Name="DAQmx Write (Digital 1D Wfm NChan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Digital 1D Wfm NChan NSamp).vi"/>
				<Item Name="DAQmx Write (Digital 2D Bool NChan 1Samp NLine).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Digital 2D Bool NChan 1Samp NLine).vi"/>
				<Item Name="DAQmx Write (Digital 2D U8 NChan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Digital 2D U8 NChan NSamp).vi"/>
				<Item Name="DAQmx Write (Digital 2D U16 NChan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Digital 2D U16 NChan NSamp).vi"/>
				<Item Name="DAQmx Write (Digital 2D U32 NChan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Digital 2D U32 NChan NSamp).vi"/>
				<Item Name="DAQmx Write (Digital Bool 1Line 1Point).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Digital Bool 1Line 1Point).vi"/>
				<Item Name="DAQmx Write (Digital U8 1Chan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Digital U8 1Chan 1Samp).vi"/>
				<Item Name="DAQmx Write (Digital U16 1Chan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Digital U16 1Chan 1Samp).vi"/>
				<Item Name="DAQmx Write (Digital U32 1Chan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Digital U32 1Chan 1Samp).vi"/>
				<Item Name="DAQmx Write (Digital Wfm 1Chan 1Samp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Digital Wfm 1Chan 1Samp).vi"/>
				<Item Name="DAQmx Write (Digital Wfm 1Chan NSamp).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Digital Wfm 1Chan NSamp).vi"/>
				<Item Name="DAQmx Write (Raw 1D I8).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Raw 1D I8).vi"/>
				<Item Name="DAQmx Write (Raw 1D I16).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Raw 1D I16).vi"/>
				<Item Name="DAQmx Write (Raw 1D I32).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Raw 1D I32).vi"/>
				<Item Name="DAQmx Write (Raw 1D U8).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Raw 1D U8).vi"/>
				<Item Name="DAQmx Write (Raw 1D U16).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Raw 1D U16).vi"/>
				<Item Name="DAQmx Write (Raw 1D U32).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write (Raw 1D U32).vi"/>
				<Item Name="DAQmx Write.vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/write.llb/DAQmx Write.vi"/>
				<Item Name="Details Display Dialog.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Details Display Dialog.vi"/>
				<Item Name="DialogType.ctl" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/DialogType.ctl"/>
				<Item Name="DialogTypeEnum.ctl" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/DialogTypeEnum.ctl"/>
				<Item Name="DTbl Digital Size.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/DTblOps.llb/DTbl Digital Size.vi"/>
				<Item Name="DTbl Empty Digital.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/DTblOps.llb/DTbl Empty Digital.vi"/>
				<Item Name="DTbl Uncompress Digital.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/DTblOps.llb/DTbl Uncompress Digital.vi"/>
				<Item Name="DWDT Digital Size.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/DWDTOps.llb/DWDT Digital Size.vi"/>
				<Item Name="DWDT Empty Digital.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/DWDTOps.llb/DWDT Empty Digital.vi"/>
				<Item Name="DWDT Get Final Time Value.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/DWDTOps.llb/DWDT Get Final Time Value.vi"/>
				<Item Name="DWDT Uncompress Digital.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/DWDTOps.llb/DWDT Uncompress Digital.vi"/>
				<Item Name="DWDT Waveform Duration.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/DWDTOps.llb/DWDT Waveform Duration.vi"/>
				<Item Name="Error Cluster From Error Code.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Error Cluster From Error Code.vi"/>
				<Item Name="Error Code Database.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Error Code Database.vi"/>
				<Item Name="ErrWarn.ctl" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/ErrWarn.ctl"/>
				<Item Name="eventvkey.ctl" Type="VI" URL="/&lt;vilib&gt;/event_ctls.llb/eventvkey.ctl"/>
				<Item Name="Find First Error.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Find First Error.vi"/>
				<Item Name="Find Tag.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Find Tag.vi"/>
				<Item Name="Format Message String.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Format Message String.vi"/>
				<Item Name="General Error Handler Core CORE.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/General Error Handler Core CORE.vi"/>
				<Item Name="General Error Handler.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/General Error Handler.vi"/>
				<Item Name="Get File Extension.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/libraryn.llb/Get File Extension.vi"/>
				<Item Name="Get Final Time Value.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/WDTOps.llb/Get Final Time Value.vi"/>
				<Item Name="Get String Text Bounds.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Get String Text Bounds.vi"/>
				<Item Name="Get Text Rect.vi" Type="VI" URL="/&lt;vilib&gt;/picture/picture.llb/Get Text Rect.vi"/>
				<Item Name="GetHelpDir.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/GetHelpDir.vi"/>
				<Item Name="GetRTHostConnectedProp.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/GetRTHostConnectedProp.vi"/>
				<Item Name="Longest Line Length in Pixels.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Longest Line Length in Pixels.vi"/>
				<Item Name="LVBoundsTypeDef.ctl" Type="VI" URL="/&lt;vilib&gt;/Utility/miscctls.llb/LVBoundsTypeDef.ctl"/>
				<Item Name="LVNumericRepresentation.ctl" Type="VI" URL="/&lt;vilib&gt;/numeric/LVNumericRepresentation.ctl"/>
				<Item Name="LVRectTypeDef.ctl" Type="VI" URL="/&lt;vilib&gt;/Utility/miscctls.llb/LVRectTypeDef.ctl"/>
				<Item Name="NI_AALBase.lvlib" Type="Library" URL="/&lt;vilib&gt;/Analysis/NI_AALBase.lvlib"/>
				<Item Name="NI_AALPro.lvlib" Type="Library" URL="/&lt;vilib&gt;/Analysis/NI_AALPro.lvlib"/>
				<Item Name="NI_DigFilter_Design.lvlib" Type="Library" URL="/&lt;vilib&gt;/addons/Digital Filter Design/NI_DigFilter_Design.lvlib"/>
				<Item Name="NI_DigFilter_Process.lvlib" Type="Library" URL="/&lt;vilib&gt;/addons/Digital Filter Design/NI_DigFilter_Process.lvlib"/>
				<Item Name="NI_DigFilterLicensed.lvlib" Type="Library" URL="/&lt;vilib&gt;/addons/Digital Filter Design/NI_DigFilterLicensed.lvlib"/>
				<Item Name="NI_FileType.lvlib" Type="Library" URL="/&lt;vilib&gt;/Utility/lvfile.llb/NI_FileType.lvlib"/>
				<Item Name="NI_LVConfig.lvlib" Type="Library" URL="/&lt;vilib&gt;/Utility/config.llb/NI_LVConfig.lvlib"/>
				<Item Name="NI_MABase.lvlib" Type="Library" URL="/&lt;vilib&gt;/measure/NI_MABase.lvlib"/>
				<Item Name="NI_MAPro.lvlib" Type="Library" URL="/&lt;vilib&gt;/measure/NI_MAPro.lvlib"/>
				<Item Name="NI_PackedLibraryUtility.lvlib" Type="Library" URL="/&lt;vilib&gt;/Utility/LVLibp/NI_PackedLibraryUtility.lvlib"/>
				<Item Name="NI_PtbyPt.lvlib" Type="Library" URL="/&lt;vilib&gt;/ptbypt/NI_PtbyPt.lvlib"/>
				<Item Name="Not Found Dialog.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Not Found Dialog.vi"/>
				<Item Name="Number of Waveform Samples.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/WDTOps.llb/Number of Waveform Samples.vi"/>
				<Item Name="Open File+.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/file.llb/Open File+.vi"/>
				<Item Name="Parse State Queue__jki_lib_state_machine.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/State Machine/_JKI_lib_State_Machine.llb/Parse State Queue__jki_lib_state_machine.vi"/>
				<Item Name="ProgressBar_Win_WireFlow.lvclass" Type="LVClass" URL="/&lt;vilib&gt;/addons/WireFlow/_WF_ProgressBar.llb/ProgressBar_Win_WireFlow.lvclass"/>
				<Item Name="ProgressBar_WireFlow.lvclass" Type="LVClass" URL="/&lt;vilib&gt;/addons/WireFlow/_WF_ProgressBar.llb/ProgressBar_WireFlow.lvclass"/>
				<Item Name="Read File+ (string).vi" Type="VI" URL="/&lt;vilib&gt;/Utility/file.llb/Read File+ (string).vi"/>
				<Item Name="RGB to Color.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/colorconv.llb/RGB to Color.vi"/>
				<Item Name="Search and Replace Pattern.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Search and Replace Pattern.vi"/>
				<Item Name="Set Bold Text.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Set Bold Text.vi"/>
				<Item Name="Set Busy.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/cursorutil.llb/Set Busy.vi"/>
				<Item Name="Set Cursor (Cursor ID).vi" Type="VI" URL="/&lt;vilib&gt;/Utility/cursorutil.llb/Set Cursor (Cursor ID).vi"/>
				<Item Name="Set Cursor (Icon Pict).vi" Type="VI" URL="/&lt;vilib&gt;/Utility/cursorutil.llb/Set Cursor (Icon Pict).vi"/>
				<Item Name="Set Cursor.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/cursorutil.llb/Set Cursor.vi"/>
				<Item Name="Set String Value.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Set String Value.vi"/>
				<Item Name="Simple Error Handler.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Simple Error Handler.vi"/>
				<Item Name="Space Constant.vi" Type="VI" URL="/&lt;vilib&gt;/dlg_ctls.llb/Space Constant.vi"/>
				<Item Name="TagReturnType.ctl" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/TagReturnType.ctl"/>
				<Item Name="Three Button Dialog CORE.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Three Button Dialog CORE.vi"/>
				<Item Name="Three Button Dialog.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Three Button Dialog.vi"/>
				<Item Name="Trim Whitespace.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Trim Whitespace.vi"/>
				<Item Name="Unset Busy.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/cursorutil.llb/Unset Busy.vi"/>
				<Item Name="VariantType.lvlib" Type="Library" URL="/&lt;vilib&gt;/Utility/VariantDataType/VariantType.lvlib"/>
				<Item Name="Waveform Duration.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/WDTOps.llb/Waveform Duration.vi"/>
				<Item Name="Waveform to XY Pairs.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/WDTOps.llb/Waveform to XY Pairs.vi"/>
				<Item Name="WDT Get Final Time Value DBL.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/WDTOps.llb/WDT Get Final Time Value DBL.vi"/>
				<Item Name="WDT Number of Waveform Samples CDB.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/WDTOps.llb/WDT Number of Waveform Samples CDB.vi"/>
				<Item Name="WDT Number of Waveform Samples DBL.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/WDTOps.llb/WDT Number of Waveform Samples DBL.vi"/>
				<Item Name="WDT Number of Waveform Samples EXT.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/WDTOps.llb/WDT Number of Waveform Samples EXT.vi"/>
				<Item Name="WDT Number of Waveform Samples I8.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/WDTOps.llb/WDT Number of Waveform Samples I8.vi"/>
				<Item Name="WDT Number of Waveform Samples I16.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/WDTOps.llb/WDT Number of Waveform Samples I16.vi"/>
				<Item Name="WDT Number of Waveform Samples I32.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/WDTOps.llb/WDT Number of Waveform Samples I32.vi"/>
				<Item Name="WDT Number of Waveform Samples SGL.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/WDTOps.llb/WDT Number of Waveform Samples SGL.vi"/>
				<Item Name="WDT Waveform Duration DBL.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/WDTOps.llb/WDT Waveform Duration DBL.vi"/>
				<Item Name="WDT Waveform to XY Pairs CDB.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/WDTOps.llb/WDT Waveform to XY Pairs CDB.vi"/>
				<Item Name="WDT Waveform to XY Pairs CSG.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/WDTOps.llb/WDT Waveform to XY Pairs CSG.vi"/>
				<Item Name="WDT Waveform to XY Pairs CXT.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/WDTOps.llb/WDT Waveform to XY Pairs CXT.vi"/>
				<Item Name="WDT Waveform to XY Pairs DBL.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/WDTOps.llb/WDT Waveform to XY Pairs DBL.vi"/>
				<Item Name="WDT Waveform to XY Pairs EXT.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/WDTOps.llb/WDT Waveform to XY Pairs EXT.vi"/>
				<Item Name="WDT Waveform to XY Pairs I8.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/WDTOps.llb/WDT Waveform to XY Pairs I8.vi"/>
				<Item Name="WDT Waveform to XY Pairs I16.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/WDTOps.llb/WDT Waveform to XY Pairs I16.vi"/>
				<Item Name="WDT Waveform to XY Pairs I32.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/WDTOps.llb/WDT Waveform to XY Pairs I32.vi"/>
				<Item Name="WDT Waveform to XY Pairs I64.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/WDTOps.llb/WDT Waveform to XY Pairs I64.vi"/>
				<Item Name="WDT Waveform to XY Pairs SGL.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/WDTOps.llb/WDT Waveform to XY Pairs SGL.vi"/>
				<Item Name="WDT Waveform to XY Pairs U8.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/WDTOps.llb/WDT Waveform to XY Pairs U8.vi"/>
				<Item Name="WDT Waveform to XY Pairs U16.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/WDTOps.llb/WDT Waveform to XY Pairs U16.vi"/>
				<Item Name="WDT Waveform to XY Pairs U32.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/WDTOps.llb/WDT Waveform to XY Pairs U32.vi"/>
				<Item Name="WDT Waveform to XY Pairs U64.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/WDTOps.llb/WDT Waveform to XY Pairs U64.vi"/>
				<Item Name="whitespace.ctl" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/whitespace.ctl"/>
				<Item Name="nisyscfg.lvlib" Type="Library" URL="/&lt;vilib&gt;/nisyscfg/nisyscfg.lvlib"/>
				<Item Name="NI STM.lvlib" Type="Library" URL="/&lt;vilib&gt;/NI/STM/NI STM.lvlib"/>
				<Item Name="SMO.lvclass" Type="LVClass" URL="/&lt;vilib&gt;/JKI/JKI SMO/SMO/SMO.lvclass"/>
				<Item Name="Attribute.lvclass" Type="LVClass" URL="/&lt;vilib&gt;/JKI/JKI SMO/Support/Attribute/Attribute.lvclass"/>
				<Item Name="Attribute.Owner.lvclass" Type="LVClass" URL="/&lt;vilib&gt;/JKI/JKI SMO/Support/Attribute.Owner/Attribute.Owner.lvclass"/>
				<Item Name="MD5Checksum pad.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/MD5Checksum.llb/MD5Checksum pad.vi"/>
				<Item Name="MD5Checksum core.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/MD5Checksum.llb/MD5Checksum core.vi"/>
				<Item Name="MD5Checksum format message-digest.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/MD5Checksum.llb/MD5Checksum format message-digest.vi"/>
				<Item Name="MD5Checksum string.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/MD5Checksum.llb/MD5Checksum string.vi"/>
				<Item Name="Attribute.Identity.lvclass" Type="LVClass" URL="/&lt;vilib&gt;/JKI/JKI SMO/Support/Attribute.Identity/Attribute.Identity.lvclass"/>
				<Item Name="Attribute.SharedResource.lvclass" Type="LVClass" URL="/&lt;vilib&gt;/JKI/JKI SMO/Support/Attribute.SharedResource/Attribute.SharedResource.lvclass"/>
				<Item Name="Attribute.Config.lvclass" Type="LVClass" URL="/&lt;vilib&gt;/JKI/JKI SMO/Support/Attribute.Config/Attribute.Config.lvclass"/>
				<Item Name="Registry-SMO.lvclass" Type="LVClass" URL="/&lt;vilib&gt;/JKI/JKI SMO/Registry/Registry-SMO.lvclass"/>
				<Item Name="Terminal.lvclass" Type="LVClass" URL="/&lt;vilib&gt;/JKI/JKI SMO/SMOFacade/Terminal/Terminal.lvclass"/>
				<Item Name="Type Specific Details.ctl" Type="VI" URL="/&lt;vilib&gt;/Utility/VariantDataType/Type Specific Details.ctl"/>
				<Item Name="Check for Contained Data Type.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/VariantDataType/Check for Contained Data Type.vi"/>
				<Item Name="ArrayToCluster.vi" Type="VI" URL="/&lt;vilib&gt;/JKI/JKI SMO/Utilities/ArrayToCluster.vi"/>
				<Item Name="Get LV Class Path.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/LVClass/Get LV Class Path.vi"/>
				<Item Name="Get LV Class Name.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/LVClass/Get LV Class Name.vi"/>
				<Item Name="Attribute.StartupBehavior.lvclass" Type="LVClass" URL="/&lt;vilib&gt;/JKI/JKI SMO/Support/Attribute.StartupBehavior/Attribute.StartupBehavior.lvclass"/>
				<Item Name="Dependency.lvclass" Type="LVClass" URL="/&lt;vilib&gt;/JKI/JKI SMO/Dependency/Dependency.lvclass"/>
				<Item Name="Build State String with Arguments__JKI_lib_State_Machine.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/State Machine/_JKI_lib_State_Machine.llb/Build State String with Arguments__JKI_lib_State_Machine.vi"/>
				<Item Name="TCP Listen List Operations.ctl" Type="VI" URL="/&lt;vilib&gt;/Utility/tcp.llb/TCP Listen List Operations.ctl"/>
				<Item Name="TCP Listen Internal List.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/tcp.llb/TCP Listen Internal List.vi"/>
				<Item Name="Internecine Avoider.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/tcp.llb/Internecine Avoider.vi"/>
				<Item Name="TCP Listen.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/tcp.llb/TCP Listen.vi"/>
				<Item Name="JKI JSON Serialization.lvlib" Type="Library" URL="/&lt;vilib&gt;/addons/_JKI.lib/Serialization/JSON/JKI JSON Serialization.lvlib"/>
				<Item Name="JKI Serialization.lvlib" Type="Library" URL="/&lt;vilib&gt;/addons/_JKI.lib/Serialization/Core/JKI Serialization.lvlib"/>
				<Item Name="LVDateTimeRec.ctl" Type="VI" URL="/&lt;vilib&gt;/Utility/miscctls.llb/LVDateTimeRec.ctl"/>
				<Item Name="JKI Unicode.lvlib" Type="Library" URL="/&lt;vilib&gt;/addons/_JKI.lib/Unicode/JKI Unicode.lvlib"/>
				<Item Name="System Exec.vi" Type="VI" URL="/&lt;vilib&gt;/Platform/system.llb/System Exec.vi"/>
				<Item Name="Write Delimited Spreadsheet.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/file.llb/Write Delimited Spreadsheet.vi"/>
				<Item Name="Write Delimited Spreadsheet (DBL).vi" Type="VI" URL="/&lt;vilib&gt;/Utility/file.llb/Write Delimited Spreadsheet (DBL).vi"/>
				<Item Name="Write Spreadsheet String.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/file.llb/Write Spreadsheet String.vi"/>
				<Item Name="Write Delimited Spreadsheet (I64).vi" Type="VI" URL="/&lt;vilib&gt;/Utility/file.llb/Write Delimited Spreadsheet (I64).vi"/>
				<Item Name="Write Delimited Spreadsheet (string).vi" Type="VI" URL="/&lt;vilib&gt;/Utility/file.llb/Write Delimited Spreadsheet (string).vi"/>
				<Item Name="subBuildXYGraph.vi" Type="VI" URL="/&lt;vilib&gt;/express/express controls/BuildXYGraphBlock.llb/subBuildXYGraph.vi"/>
				<Item Name="ex_CorrectErrorChain.vi" Type="VI" URL="/&lt;vilib&gt;/express/express shared/ex_CorrectErrorChain.vi"/>
				<Item Name="Dynamic To Waveform Array.vi" Type="VI" URL="/&lt;vilib&gt;/express/express shared/transition.llb/Dynamic To Waveform Array.vi"/>
				<Item Name="Read Characters From File.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/file.llb/Read Characters From File.vi"/>
				<Item Name="Write To Spreadsheet File.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/file.llb/Write To Spreadsheet File.vi"/>
				<Item Name="Write To Spreadsheet File (DBL).vi" Type="VI" URL="/&lt;vilib&gt;/Utility/file.llb/Write To Spreadsheet File (DBL).vi"/>
				<Item Name="Write To Spreadsheet File (I64).vi" Type="VI" URL="/&lt;vilib&gt;/Utility/file.llb/Write To Spreadsheet File (I64).vi"/>
				<Item Name="Write To Spreadsheet File (string).vi" Type="VI" URL="/&lt;vilib&gt;/Utility/file.llb/Write To Spreadsheet File (string).vi"/>
				<Item Name="Read Delimited Spreadsheet.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/file.llb/Read Delimited Spreadsheet.vi"/>
				<Item Name="Read Delimited Spreadsheet (DBL).vi" Type="VI" URL="/&lt;vilib&gt;/Utility/file.llb/Read Delimited Spreadsheet (DBL).vi"/>
				<Item Name="Read Lines From File (with error IO).vi" Type="VI" URL="/&lt;vilib&gt;/Utility/file.llb/Read Lines From File (with error IO).vi"/>
				<Item Name="Read Delimited Spreadsheet (I64).vi" Type="VI" URL="/&lt;vilib&gt;/Utility/file.llb/Read Delimited Spreadsheet (I64).vi"/>
				<Item Name="Read Delimited Spreadsheet (string).vi" Type="VI" URL="/&lt;vilib&gt;/Utility/file.llb/Read Delimited Spreadsheet (string).vi"/>
				<Item Name="LVOffsetAndMultiplierTypeDef.ctl" Type="VI" URL="/&lt;vilib&gt;/Utility/miscctls.llb/LVOffsetAndMultiplierTypeDef.ctl"/>
				<Item Name="Recursive File List.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/libraryn.llb/Recursive File List.vi"/>
				<Item Name="List Directory and LLBs.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/libraryn.llb/List Directory and LLBs.vi"/>
				<Item Name="NI_Gmath.lvlib" Type="Library" URL="/&lt;vilib&gt;/gmath/NI_Gmath.lvlib"/>
				<Item Name="LVPoint32TypeDef.ctl" Type="VI" URL="/&lt;vilib&gt;/Utility/miscctls.llb/LVPoint32TypeDef.ctl"/>
				<Item Name="RectSize.vi" Type="VI" URL="/&lt;vilib&gt;/picture/PictureSupport.llb/RectSize.vi"/>
				<Item Name="panelstate.ctl" Type="VI" URL="/&lt;vilib&gt;/event_ctls.llb/panelstate.ctl"/>
				<Item Name="sizeaction.ctl" Type="VI" URL="/&lt;vilib&gt;/event_ctls.llb/sizeaction.ctl"/>
				<Item Name="Point2Rect.vi" Type="VI" URL="/&lt;vilib&gt;/picture/PictureSupport.llb/Point2Rect.vi"/>
				<Item Name="PointInRect.vi" Type="VI" URL="/&lt;vilib&gt;/picture/PictureSupport.llb/PointInRect.vi"/>
				<Item Name="InsetRect.vi" Type="VI" URL="/&lt;vilib&gt;/picture/PictureSupport.llb/InsetRect.vi"/>
				<Item Name="RectCentroid.vi" Type="VI" URL="/&lt;vilib&gt;/picture/PictureSupport.llb/RectCentroid.vi"/>
				<Item Name="Rectangle Size__lava_lib_ui_tools.vi" Type="VI" URL="/&lt;vilib&gt;/LAVA/UI Tools/Alignment/Rectangle Size__lava_lib_ui_tools.vi"/>
				<Item Name="LVPointTypeDef.ctl" Type="VI" URL="/&lt;vilib&gt;/Utility/miscctls.llb/LVPointTypeDef.ctl"/>
				<Item Name="System Directory Type.ctl" Type="VI" URL="/&lt;vilib&gt;/Utility/sysdir.llb/System Directory Type.ctl"/>
				<Item Name="Get System Directory.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/sysdir.llb/Get System Directory.vi"/>
				<Item Name="Open URL in Default Browser core.vi" Type="VI" URL="/&lt;vilib&gt;/Platform/browser.llb/Open URL in Default Browser core.vi"/>
				<Item Name="Escape Characters for HTTP.vi" Type="VI" URL="/&lt;vilib&gt;/printing/PathToURL.llb/Escape Characters for HTTP.vi"/>
				<Item Name="Path to URL.vi" Type="VI" URL="/&lt;vilib&gt;/printing/PathToURL.llb/Path to URL.vi"/>
				<Item Name="Open URL in Default Browser (path).vi" Type="VI" URL="/&lt;vilib&gt;/Platform/browser.llb/Open URL in Default Browser (path).vi"/>
				<Item Name="Open URL in Default Browser (string).vi" Type="VI" URL="/&lt;vilib&gt;/Platform/browser.llb/Open URL in Default Browser (string).vi"/>
				<Item Name="Open URL in Default Browser.vi" Type="VI" URL="/&lt;vilib&gt;/Platform/browser.llb/Open URL in Default Browser.vi"/>
				<Item Name="Guid Generator.vi" Type="VI" URL="/&lt;vilib&gt;/National Instruments/GUID Generator/Guid Generator.vi"/>
				<Item Name="URI.lvlib" Type="Library" URL="/&lt;vilib&gt;/JKI/JKI SMO/URI Parsing/URI.lvlib"/>
				<Item Name="NI_Data Type.lvlib" Type="Library" URL="/&lt;vilib&gt;/Utility/Data Type/NI_Data Type.lvlib"/>
				<Item Name="SMO.UI.lvclass" Type="LVClass" URL="/&lt;vilib&gt;/JKI/JKI SMO/SMO.UI/SMO.UI.lvclass"/>
				<Item Name="LMH-Toolbox.lvlib" Type="Library" URL="/&lt;vilib&gt;/MakerHub/Toolbox/LMH-Toolbox.lvlib"/>
				<Item Name="DAQmx Create Channel (AI-Acceleration-4 Wire DC Voltage).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Acceleration-4 Wire DC Voltage).vi"/>
				<Item Name="DAQmx Create Channel (AI-Acceleration-Charge).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Acceleration-Charge).vi"/>
				<Item Name="DAQmx Create Channel (AI-Charge).vi" Type="VI" URL="/&lt;vilib&gt;/DAQmx/create/channels.llb/DAQmx Create Channel (AI-Charge).vi"/>
				<Item Name="Caraya.lvlib" Type="Library" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/Caraya/Caraya.lvlib"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FBuild Error Cluster__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FBuild Error Cluster__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FType Descriptor Enumeration__ogtk.ctl" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FType Descriptor Enumeration__ogtk.ctl"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FType Descriptor Header__ogtk.ctl" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FType Descriptor Header__ogtk.ctl"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FType Descriptor__ogtk.ctl" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FType Descriptor__ogtk.ctl"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FGet Header from TD__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FGet Header from TD__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FGet Element TD from Array TD__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FGet Element TD from Array TD__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FGet TDEnum from TD__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FGet TDEnum from TD__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FPhysical Units__ogtk.ctl" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FPhysical Units__ogtk.ctl"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FGet Physical Units from TD__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FGet Physical Units from TD__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FGet Physical Units__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FGet Physical Units__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FParse String with TDs__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FParse String with TDs__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSplit Cluster TD__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSplit Cluster TD__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FVariant to Header Info__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FVariant to Header Info__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FCluster to Array of VData__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FCluster to Array of VData__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FGet Last PString__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FGet Last PString__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FGet PString__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FGet PString__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FGet Variant Attributes__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FGet Variant Attributes__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSet Data Name__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSet Data Name__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FGet Data Name from TD__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FGet Data Name from TD__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FGet Data Name__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FGet Data Name__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FArray Size(s)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FArray Size(s)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FReshape Array to 1D VArray__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FReshape Array to 1D VArray__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FArray to Array of VData__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FArray to Array of VData__ogtk.vi"/>
				<Item Name="property -- cluster.ctl" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/Caraya/classes/Test Report.JUnit/property -- cluster.ctl"/>
				<Item Name="Indent.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/Caraya/classes/Test Report.JUnit/Indent.vi"/>
				<Item Name="Call Chain To Indent.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/Caraya/classes/Test Report.JUnit/Call Chain To Indent.vi"/>
				<Item Name="subFile Dialog.vi" Type="VI" URL="/&lt;vilib&gt;/express/express input/FileDialogBlock.llb/subFile Dialog.vi"/>
				<Item Name="Get File System Separator.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/sysinfo.llb/Get File System Separator.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FStrip Path Extension - String__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FStrip Path Extension - String__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FStrip Path Extension - 1D Array of Strings__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FStrip Path Extension - 1D Array of Strings__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FStrip Path Extension - 1D Array of Paths__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FStrip Path Extension - 1D Array of Paths__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FStrip Path Extension - Path__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FStrip Path Extension - Path__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FStrip Path Extension__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FStrip Path Extension__ogtk.vi"/>
				<Item Name="TRef TravTarget.ctl" Type="VI" URL="/&lt;vilib&gt;/Utility/traverseref.llb/TRef TravTarget.ctl"/>
				<Item Name="TRef Traverse.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/traverseref.llb/TRef Traverse.vi"/>
				<Item Name="VI Scripting - Traverse.lvlib" Type="Library" URL="/&lt;vilib&gt;/Utility/traverseref.llb/VI Scripting - Traverse.lvlib"/>
				<Item Name="TRef Traverse for References.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/traverseref.llb/TRef Traverse for References.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FRemove Duplicates from 1D Array (Path)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FRemove Duplicates from 1D Array (Path)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FRemove Duplicates from 1D Array (LVObject)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FRemove Duplicates from 1D Array (LVObject)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FRemove Duplicates from 1D Array (U64)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FRemove Duplicates from 1D Array (U64)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FRemove Duplicates from 1D Array (I64)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FRemove Duplicates from 1D Array (I64)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FRemove Duplicates from 1D Array (Boolean)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FRemove Duplicates from 1D Array (Boolean)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FRemove Duplicates from 1D Array (Variant)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FRemove Duplicates from 1D Array (Variant)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FRemove Duplicates from 1D Array (U8)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FRemove Duplicates from 1D Array (U8)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FRemove Duplicates from 1D Array (U32)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FRemove Duplicates from 1D Array (U32)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FRemove Duplicates from 1D Array (U16)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FRemove Duplicates from 1D Array (U16)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FRemove Duplicates from 1D Array (String)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FRemove Duplicates from 1D Array (String)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FRemove Duplicates from 1D Array (SGL)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FRemove Duplicates from 1D Array (SGL)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FRemove Duplicates from 1D Array (I8)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FRemove Duplicates from 1D Array (I8)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FRemove Duplicates from 1D Array (I32)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FRemove Duplicates from 1D Array (I32)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FRemove Duplicates from 1D Array (I16)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FRemove Duplicates from 1D Array (I16)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FRemove Duplicates from 1D Array (EXT)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FRemove Duplicates from 1D Array (EXT)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FRemove Duplicates from 1D Array (DBL)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FRemove Duplicates from 1D Array (DBL)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FRemove Duplicates from 1D Array (CXT)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FRemove Duplicates from 1D Array (CXT)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FRemove Duplicates from 1D Array (CSG)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FRemove Duplicates from 1D Array (CSG)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FRemove Duplicates from 1D Array (CDB)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FRemove Duplicates from 1D Array (CDB)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FRemove Duplicates from 1D Array__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FRemove Duplicates from 1D Array__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FReorder 1D Array2 (Path)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FReorder 1D Array2 (Path)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FReorder 2D Array2 (LVObject)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FReorder 2D Array2 (LVObject)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FReorder 1D Array2 (LVObject)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FReorder 1D Array2 (LVObject)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FReorder 2D Array2 (U64)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FReorder 2D Array2 (U64)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FReorder 2D Array2 (I64)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FReorder 2D Array2 (I64)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FReorder 1D Array2 (U64)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FReorder 1D Array2 (U64)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FReorder 1D Array2 (I64)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FReorder 1D Array2 (I64)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FReorder 2D Array2 (Variant)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FReorder 2D Array2 (Variant)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FReorder 2D Array2 (U32)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FReorder 2D Array2 (U32)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FReorder 2D Array2 (U16)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FReorder 2D Array2 (U16)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FReorder 2D Array2 (U8)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FReorder 2D Array2 (U8)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FReorder 2D Array2 (String)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FReorder 2D Array2 (String)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FReorder 2D Array2 (SGL)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FReorder 2D Array2 (SGL)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FReorder 2D Array2 (Path)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FReorder 2D Array2 (Path)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FReorder 2D Array2 (I32)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FReorder 2D Array2 (I32)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FReorder 2D Array2 (I16)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FReorder 2D Array2 (I16)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FReorder 2D Array2 (I8)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FReorder 2D Array2 (I8)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FReorder 2D Array2 (EXT)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FReorder 2D Array2 (EXT)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FReorder 2D Array2 (DBL)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FReorder 2D Array2 (DBL)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FReorder 2D Array2 (CXT)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FReorder 2D Array2 (CXT)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FReorder 2D Array2 (CSG)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FReorder 2D Array2 (CSG)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FReorder 2D Array2 (CDB)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FReorder 2D Array2 (CDB)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FReorder 2D Array2 (Boolean)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FReorder 2D Array2 (Boolean)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FReorder 1D Array2 (Variant)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FReorder 1D Array2 (Variant)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FReorder 1D Array2 (String)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FReorder 1D Array2 (String)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FReorder 1D Array2 (Boolean)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FReorder 1D Array2 (Boolean)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FReorder 1D Array2 (U8)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FReorder 1D Array2 (U8)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FReorder 1D Array2 (U32)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FReorder 1D Array2 (U32)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FReorder 1D Array2 (U16)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FReorder 1D Array2 (U16)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FReorder 1D Array2 (SGL)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FReorder 1D Array2 (SGL)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FReorder 1D Array2 (I8)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FReorder 1D Array2 (I8)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FReorder 1D Array2 (I32)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FReorder 1D Array2 (I32)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FReorder 1D Array2 (I16)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FReorder 1D Array2 (I16)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FReorder 1D Array2 (EXT)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FReorder 1D Array2 (EXT)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FReorder 1D Array2 (DBL)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FReorder 1D Array2 (DBL)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FReorder 1D Array2 (CSG)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FReorder 1D Array2 (CSG)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FReorder 1D Array2 (CXT)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FReorder 1D Array2 (CXT)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FReorder 1D Array2 (CDB)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FReorder 1D Array2 (CDB)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FReorder Array2__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FReorder Array2__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSort 1D Array (I32)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSort 1D Array (I32)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSort 2D Array (U64)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSort 2D Array (U64)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSort 2D Array (I64)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSort 2D Array (I64)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSort 1D Array (U64)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSort 1D Array (U64)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSort 1D Array (I64)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSort 1D Array (I64)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSort 2D Array (String)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSort 2D Array (String)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSort 2D Array (Path)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSort 2D Array (Path)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSort 1D Array (String)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSort 1D Array (String)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSort 1D Array (Path)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSort 1D Array (Path)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSort 2D Array (U8)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSort 2D Array (U8)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSort 2D Array (U32)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSort 2D Array (U32)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSort 2D Array (U16)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSort 2D Array (U16)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSort 2D Array (SGL)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSort 2D Array (SGL)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSort 2D Array (I8)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSort 2D Array (I8)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSort 2D Array (I32)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSort 2D Array (I32)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSort 2D Array (I16)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSort 2D Array (I16)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSort 2D Array (EXT)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSort 2D Array (EXT)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSort 2D Array (DBL)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSort 2D Array (DBL)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSort 2D Array (CSG)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSort 2D Array (CSG)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSort 2D Array (CXT)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSort 2D Array (CXT)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSort 2D Array (CDB)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSort 2D Array (CDB)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSort 1D Array (U8)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSort 1D Array (U8)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSort 1D Array (U32)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSort 1D Array (U32)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSort 1D Array (U16)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSort 1D Array (U16)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSort 1D Array (SGL)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSort 1D Array (SGL)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSort 1D Array (I8)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSort 1D Array (I8)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSort 1D Array (I16)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSort 1D Array (I16)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSort 1D Array (EXT)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSort 1D Array (EXT)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSort 1D Array (DBL)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSort 1D Array (DBL)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FReorder 1D Array (CSG)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FReorder 1D Array (CSG)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSort 1D Array (CSG)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSort 1D Array (CSG)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FReorder 1D Array (CXT)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FReorder 1D Array (CXT)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSort 1D Array (CXT)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSort 1D Array (CXT)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FReorder 1D Array (CDB)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FReorder 1D Array (CDB)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSort 1D Array (CDB)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSort 1D Array (CDB)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSort Array__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSort Array__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 1D Array (Path)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 1D Array (Path)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 2D Array (LVObject)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 2D Array (LVObject)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 1D Array (LVObject)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 1D Array (LVObject)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 2D Array (U64)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 2D Array (U64)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 2D Array (I64)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 2D Array (I64)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 1D Array (U64)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 1D Array (U64)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 1D Array (I64)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 1D Array (I64)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 2D Array (Variant)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 2D Array (Variant)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 2D Array (U32)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 2D Array (U32)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 2D Array (U16)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 2D Array (U16)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 2D Array (U8)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 2D Array (U8)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 2D Array (String)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 2D Array (String)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 2D Array (SGL)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 2D Array (SGL)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 2D Array (Path)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 2D Array (Path)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 2D Array (I32)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 2D Array (I32)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 2D Array (I16)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 2D Array (I16)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 2D Array (I8)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 2D Array (I8)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 2D Array (EXT)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 2D Array (EXT)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 2D Array (DBL)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 2D Array (DBL)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 2D Array (CXT)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 2D Array (CXT)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 2D Array (CSG)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 2D Array (CSG)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 2D Array (CDB)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 2D Array (CDB)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 2D Array (Boolean)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 2D Array (Boolean)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 1D Array (Variant)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 1D Array (Variant)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 1D Array (U32)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 1D Array (U32)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 1D Array (U16)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 1D Array (U16)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 1D Array (U8)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 1D Array (U8)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 1D Array (String)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 1D Array (String)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 1D Array (SGL)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 1D Array (SGL)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 1D Array (I32)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 1D Array (I32)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 1D Array (I16)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 1D Array (I16)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 1D Array (I8)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 1D Array (I8)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 1D Array (EXT)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 1D Array (EXT)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 1D Array (CXT)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 1D Array (CXT)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 1D Array (DBL)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 1D Array (DBL)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 1D Array (CSG)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 1D Array (CSG)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 1D Array (CDB)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 1D Array (CDB)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 1D Array (Boolean)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FDelete Elements from 1D Array (Boolean)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FDelete Elements from Array__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FDelete Elements from Array__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSearch 1D Array (Path)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSearch 1D Array (Path)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSearch 1D Array (LVObject)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSearch 1D Array (LVObject)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSearch 1D Array (I64)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSearch 1D Array (I64)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSearch 1D Array (U64)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSearch 1D Array (U64)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSearch 1D Array (Variant)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSearch 1D Array (Variant)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSearch 1D Array (String)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSearch 1D Array (String)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSearch 1D Array (Boolean)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSearch 1D Array (Boolean)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSearch 1D Array (U32)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSearch 1D Array (U32)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSearch 1D Array (U16)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSearch 1D Array (U16)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSearch 1D Array (U8)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSearch 1D Array (U8)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSearch 1D Array (I32)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSearch 1D Array (I32)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSearch 1D Array (I16)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSearch 1D Array (I16)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSearch 1D Array (I8)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSearch 1D Array (I8)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSearch 1D Array (CXT)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSearch 1D Array (CXT)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSearch 1D Array (CDB)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSearch 1D Array (CDB)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSearch 1D Array (CSG)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSearch 1D Array (CSG)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSearch 1D Array (EXT)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSearch 1D Array (EXT)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSearch 1D Array (DBL)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSearch 1D Array (DBL)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSearch 1D Array (SGL)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSearch 1D Array (SGL)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FSearch Array__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FSearch Array__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array (Path)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array (Path)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array with Scalar (LVObject)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array with Scalar (LVObject)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array (LVObject)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array (LVObject)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array with Scalar (U64)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array with Scalar (U64)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array with Scalar (I64)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array with Scalar (I64)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array (U64)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array (U64)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array (I64)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array (I64)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array with Scalar (Variant)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array with Scalar (Variant)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array with Scalar (U32)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array with Scalar (U32)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array with Scalar (U16)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array with Scalar (U16)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array with Scalar (U8)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array with Scalar (U8)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array with Scalar (String)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array with Scalar (String)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array with Scalar (SGL)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array with Scalar (SGL)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array with Scalar (Path)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array with Scalar (Path)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array with Scalar (I32)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array with Scalar (I32)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array with Scalar (I16)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array with Scalar (I16)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array with Scalar (I8)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array with Scalar (I8)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array with Scalar (EXT)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array with Scalar (EXT)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array with Scalar (DBL)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array with Scalar (DBL)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array with Scalar (CXT)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array with Scalar (CXT)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array with Scalar (CSG)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array with Scalar (CSG)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array with Scalar (CDB)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array with Scalar (CDB)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array with Scalar (Boolean)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array with Scalar (Boolean)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array (SGL)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array (SGL)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array (DBL)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array (DBL)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array (EXT)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array (EXT)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array (CSG)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array (CSG)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array (CDB)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array (CDB)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array (CXT)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array (CXT)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array (Boolean)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array (Boolean)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array (Variant)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array (Variant)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array (I8)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array (I8)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array (I32)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array (I32)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array (I16)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array (I16)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array (U16)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array (U16)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array (U32)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array (U32)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array (U8)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array (U8)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array (String)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array (String)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FFilter 1D Array__ogtk.vi"/>
				<Item Name="Librarian File List.ctl" Type="VI" URL="/&lt;vilib&gt;/Utility/libraryn.llb/Librarian File List.ctl"/>
				<Item Name="Librarian File Info Out.ctl" Type="VI" URL="/&lt;vilib&gt;/Utility/libraryn.llb/Librarian File Info Out.ctl"/>
				<Item Name="Librarian File Info In.ctl" Type="VI" URL="/&lt;vilib&gt;/Utility/libraryn.llb/Librarian File Info In.ctl"/>
				<Item Name="Librarian.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/libraryn.llb/Librarian.vi"/>
				<Item Name="Get VI Library File Info.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/libraryn.llb/Get VI Library File Info.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FBuild Path - File Names Array__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FBuild Path - File Names Array__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FBuild Path - File Names and Paths Arrays - path__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FBuild Path - File Names and Paths Arrays - path__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FBuild Path - File Names Array - path__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FBuild Path - File Names Array - path__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FBuild Path - Traditional - path__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FBuild Path - Traditional - path__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FBuild Path - File Names and Paths Arrays__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FBuild Path - File Names and Paths Arrays__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FBuild Path - Traditional__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FBuild Path - Traditional__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FBuild Path__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FBuild Path__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FTrim Whitespace (String)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FTrim Whitespace (String)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FTrim Whitespace (String Array)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FTrim Whitespace (String Array)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FTrim Whitespace__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FTrim Whitespace__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FList Directory__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FList Directory__ogtk.vi"/>
				<Item Name="Has LLB Extension.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/libraryn.llb/Has LLB Extension.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FList Directory Recursive__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FList Directory Recursive__ogtk.vi"/>
				<Item Name="Application Directory.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/file.llb/Application Directory.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FConditional Auto-Indexing Tunnel (Variant)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FConditional Auto-Indexing Tunnel (Variant)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FConditional Auto-Indexing Tunnel (LVObject)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FConditional Auto-Indexing Tunnel (LVObject)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FConditional Auto-Indexing Tunnel (U64)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FConditional Auto-Indexing Tunnel (U64)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FConditional Auto-Indexing Tunnel (I64)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FConditional Auto-Indexing Tunnel (I64)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FConditional Auto-Indexing Tunnel (Bool)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FConditional Auto-Indexing Tunnel (Bool)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FConditional Auto-Indexing Tunnel (CTL-REF)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FConditional Auto-Indexing Tunnel (CTL-REF)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FConditional Auto-Indexing Tunnel (VI-REF)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FConditional Auto-Indexing Tunnel (VI-REF)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FConditional Auto-Indexing Tunnel (GObj-REF)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FConditional Auto-Indexing Tunnel (GObj-REF)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FConditional Auto-Indexing Tunnel (GEN-REF)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FConditional Auto-Indexing Tunnel (GEN-REF)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FConditional Auto-Indexing Tunnel (CXT)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FConditional Auto-Indexing Tunnel (CXT)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FConditional Auto-Indexing Tunnel (CDB)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FConditional Auto-Indexing Tunnel (CDB)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FConditional Auto-Indexing Tunnel (CSG)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FConditional Auto-Indexing Tunnel (CSG)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FConditional Auto-Indexing Tunnel (EXT)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FConditional Auto-Indexing Tunnel (EXT)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FConditional Auto-Indexing Tunnel (SGL)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FConditional Auto-Indexing Tunnel (SGL)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FConditional Auto-Indexing Tunnel (I8)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FConditional Auto-Indexing Tunnel (I8)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FConditional Auto-Indexing Tunnel (I16)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FConditional Auto-Indexing Tunnel (I16)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FConditional Auto-Indexing Tunnel (U8)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FConditional Auto-Indexing Tunnel (U8)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FConditional Auto-Indexing Tunnel (U16)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FConditional Auto-Indexing Tunnel (U16)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FConditional Auto-Indexing Tunnel (U32)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FConditional Auto-Indexing Tunnel (U32)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FConditional Auto-Indexing Tunnel (I32)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FConditional Auto-Indexing Tunnel (I32)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FConditional Auto-Indexing Tunnel (Path)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FConditional Auto-Indexing Tunnel (Path)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FConditional Auto-Indexing Tunnel (DBL)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FConditional Auto-Indexing Tunnel (DBL)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FConditional Auto-Indexing Tunnel (String)__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FConditional Auto-Indexing Tunnel (String)__ogtk.vi"/>
				<Item Name="4822C501820BB5A8313EAE4F8D4B529FConditional Auto-Indexing Tunnel__ogtk.vi" Type="VI" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/_Caraya_internal_deps/4822C501820BB5A8313EAE4F8D4B529FConditional Auto-Indexing Tunnel__ogtk.vi"/>
				<Item Name="imagedata.ctl" Type="VI" URL="/&lt;vilib&gt;/picture/picture.llb/imagedata.ctl"/>
				<Item Name="Application Menu.rtm" Type="Document" URL="/&lt;vilib&gt;/addons/_JKI Toolkits/Caraya/menu/Application Menu.rtm"/>
				<Item Name="NI_SysID.lvlib" Type="Library" URL="/&lt;vilib&gt;/addons/System Identification/NI_SysID.lvlib"/>
				<Item Name="Timestamp Subtract.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/TSOps.llb/Timestamp Subtract.vi"/>
				<Item Name="I128 Timestamp.ctl" Type="VI" URL="/&lt;vilib&gt;/Waveform/TSOps.llb/I128 Timestamp.ctl"/>
				<Item Name="DU64_U32SubtractWithBorrow.vi" Type="VI" URL="/&lt;vilib&gt;/Waveform/TSOps.llb/DU64_U32SubtractWithBorrow.vi"/>
			</Item>
			<Item Name="kernel32.dll" Type="Document" URL="kernel32.dll">
				<Property Name="NI.PreserveRelativePath" Type="Bool">true</Property>
			</Item>
			<Item Name="lvanlys.dll" Type="Document" URL="/&lt;resource&gt;/lvanlys.dll"/>
			<Item Name="LVDFD.dll" Type="Document" URL="/&lt;resource&gt;/LVDFD.dll"/>
			<Item Name="nilvaiu.dll" Type="Document" URL="nilvaiu.dll">
				<Property Name="NI.PreserveRelativePath" Type="Bool">true</Property>
			</Item>
			<Item Name="shell32.dll" Type="Document" URL="shell32.dll">
				<Property Name="NI.PreserveRelativePath" Type="Bool">true</Property>
			</Item>
			<Item Name="mscorlib" Type="VI" URL="mscorlib">
				<Property Name="NI.PreserveRelativePath" Type="Bool">true</Property>
			</Item>
			<Item Name="nisyscfg.dll" Type="Document" URL="nisyscfg.dll">
				<Property Name="NI.PreserveRelativePath" Type="Bool">true</Property>
			</Item>
			<Item Name="Instrument.Lockin.UI.lvclass" Type="LVClass" URL="../Instrument.Lockinl.UI/Instrument.Lockin.UI.lvclass"/>
			<Item Name="Instrument.Lockin.lvclass" Type="LVClass" URL="../Instrument.Lockin/Instrument.Lockin.lvclass"/>
			<Item Name="LockinDAQ.lvclass" Type="LVClass" URL="../LockinDAQ/LockinDAQ.lvclass"/>
		</Item>
		<Item Name="Build Specifications" Type="Build">
			<Item Name="Multichannel Lockin" Type="EXE">
				<Property Name="App_copyErrors" Type="Bool">true</Property>
				<Property Name="App_INI_aliasGUID" Type="Str">{31EF0C73-E777-4F70-87A7-D9EF15F3186C}</Property>
				<Property Name="App_INI_GUID" Type="Str">{3F9B6D2B-F7F0-4A86-BFE3-074A8EA488AD}</Property>
				<Property Name="App_serverConfig.httpPort" Type="Int">8002</Property>
				<Property Name="Bld_autoIncrement" Type="Bool">true</Property>
				<Property Name="Bld_buildCacheID" Type="Str">{68ABFC83-8948-4562-A2C4-134E82696611}</Property>
				<Property Name="Bld_buildSpecName" Type="Str">Multichannel Lockin</Property>
				<Property Name="Bld_excludeInlineSubVIs" Type="Bool">true</Property>
				<Property Name="Bld_excludeLibraryItems" Type="Bool">true</Property>
				<Property Name="Bld_excludePolymorphicVIs" Type="Bool">true</Property>
				<Property Name="Bld_localDestDir" Type="Path">../builds/Multichannel Lockin/NI_AB_PROJECTNAME</Property>
				<Property Name="Bld_localDestDirType" Type="Str">relativeToCommon</Property>
				<Property Name="Bld_modifyLibraryFile" Type="Bool">true</Property>
				<Property Name="Bld_previewCacheID" Type="Str">{BE714A7E-B7D4-4888-A1F2-966F210EC573}</Property>
				<Property Name="Bld_version.build" Type="Int">18</Property>
				<Property Name="Bld_version.major" Type="Int">1</Property>
				<Property Name="Destination[0].destName" Type="Str">lockin.exe</Property>
				<Property Name="Destination[0].path" Type="Path">../builds/Multichannel Lockin/NI_AB_PROJECTNAME/lockin.exe</Property>
				<Property Name="Destination[0].preserveHierarchy" Type="Bool">true</Property>
				<Property Name="Destination[0].type" Type="Str">App</Property>
				<Property Name="Destination[1].destName" Type="Str">Support Directory</Property>
				<Property Name="Destination[1].path" Type="Path">../builds/Multichannel Lockin/NI_AB_PROJECTNAME/data</Property>
				<Property Name="DestinationCount" Type="Int">2</Property>
				<Property Name="Source[0].itemID" Type="Str">{A6F73688-3F40-4D0F-8304-E945AB173FD2}</Property>
				<Property Name="Source[0].type" Type="Str">Container</Property>
				<Property Name="Source[1].destinationIndex" Type="Int">0</Property>
				<Property Name="Source[1].itemID" Type="Ref">/My Computer/Instrument.Lockin.lvclass/Lockin-4461 -Patrick -State.vi</Property>
				<Property Name="Source[1].sourceInclusion" Type="Str">TopLevel</Property>
				<Property Name="Source[1].type" Type="Str">VI</Property>
				<Property Name="SourceCount" Type="Int">2</Property>
				<Property Name="TgtF_companyName" Type="Str">Levylab</Property>
				<Property Name="TgtF_fileDescription" Type="Str">Multichannel Lockin</Property>
				<Property Name="TgtF_internalName" Type="Str">Multichannel Lockin</Property>
				<Property Name="TgtF_legalCopyright" Type="Str">Copyright © 2017 Levylab</Property>
				<Property Name="TgtF_productName" Type="Str">Multichannel Lockin</Property>
				<Property Name="TgtF_targetfileGUID" Type="Str">{F79A4A16-E3DA-45EF-AF6E-CE1DFAF4A4BE}</Property>
				<Property Name="TgtF_targetfileName" Type="Str">lockin.exe</Property>
			</Item>
		</Item>
	</Item>
</Project>
