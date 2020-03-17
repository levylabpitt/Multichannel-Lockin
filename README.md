# Multichannel Lockin

Multichannel Lockin for National Instruments Dynamic Signal Acquisition hardware (4431, 4461, 4462). This version is configured to handle multiple cards for simultaneous, synchronized AI/AO. You can configure a number of analog outputs (8 or more) to output sine, square, sawtooth, or triangle functions with DC offsets. Each of the analog inputs (8 or more) can be demodulated at multiple frequencies.

![Multichannel Lockin Front Panel](images/Lockin-Front-Panel.png)

## Installation
- LabVIEW 2016 32-bit required
- Multichannel Lockin.exe can be installed by downloading the latest installer found here [here](https://github.com/levylabpitt/Multichannel-Lockin/releases/latest)
- The LabVIEW API can be installed using VI Package Manager as described [here](https://levylabpitt.github.io/)

## Usage
### Basic Usage

The main controls are found on the "AO/REF Setup" tab:
- Analog outputs are configured in the "Output" section.
- Input prefilters and offsets are configured in the "Input" section.
- The lockin stage is configured in the "Reference" section.

![Block Diagram 1](images/Lockin-Block-Diagram-1.png)

The DSA DAQ settings (hardware addresses, input/output ranges, ac/dc coupling) are configured on the "DAQ Settings" section.

### Auxilliary Output

The lockin can be configured to output a static voltage on a multifunction DAQ in the "Auxilliary Output" section of the "AUX" tab. 

![Block Diagram 2](images/Lockin-Block-Diagram-2.png)

A demodulated lockin signal can also be routed to another analog output.

![Block Diagram 3](images/Lockin-Block-Diagram-3.png)

### Simulation mode

If the configured DAQ card is a simulated card, the lockin will automatically revert to a simulation mode. The simulated device is a three terminal quantum wire with conductance that quanitized in unites of e2/h as a function of an applied gate voltage.\

- AO1 = source voltage
- AO2 = gate voltage
- AI1 = drain current

![Block Diagram 4](images/Lockin-Block-Diagram-4.png)

## Contributing

Please contact [Patrick Irvin](https://github.com/ciozi137)

## License

[BSD-3](https://opensource.org/licenses/BSD-3-Clause)
