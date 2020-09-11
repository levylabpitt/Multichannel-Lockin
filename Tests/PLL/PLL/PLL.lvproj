<?xml version='1.0'?>
<Project Type="Project" LVVersion="8208000">
   <Item Name="My Computer" Type="My Computer">
      <Property Name="server.app.propertiesEnabled" Type="Bool">true</Property>
      <Property Name="server.control.propertiesEnabled" Type="Bool">true</Property>
      <Property Name="server.tcp.enabled" Type="Bool">false</Property>
      <Property Name="server.tcp.port" Type="Int">0</Property>
      <Property Name="server.tcp.serviceName" Type="Str">My Computer/VI Server</Property>
      <Property Name="server.tcp.serviceName.default" Type="Str">My Computer/VI Server</Property>
      <Property Name="server.vi.callsEnabled" Type="Bool">true</Property>
      <Property Name="server.vi.propertiesEnabled" Type="Bool">true</Property>
      <Property Name="specify.custom.address" Type="Bool">false</Property>
      <Item Name="SubVI" Type="Folder">
         <Item Name="Simple_PI.vi" Type="VI" URL="Simple_PI.vi"/>
      </Item>
      <Item Name="PLL_Simple_WithoutTime.vi" Type="VI" URL="PLL_Simple_WithoutTime.vi"/>
      <Item Name="PLL_PID.vi" Type="VI" URL="PLL_PID.vi"/>
      <Item Name="PLL_Simple_WithTime.vi" Type="VI" URL="PLL_Simple_WithTime.vi"/>
      <Item Name="PLL_PID_WithoutPIDToolkit.vi" Type="VI" URL="PLL_PID_WithoutPIDToolkit.vi"/>
      <Item Name="Dependencies" Type="Dependencies"/>
      <Item Name="Build Specifications" Type="Build"/>
   </Item>
</Project>
