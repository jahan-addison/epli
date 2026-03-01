# serpent

### Overview

A recharged take at "snake" for the VMU device's firmware, CPU, and LCD frame buffer as an experienced engineer. My first incomplete version from 15 years ago can be found [here](https://github.com/jahan-addison/epli/tree/throwback).

The CPU in the VMS _(dubbed, "the potato")_ is a customized Sanyo microcontroller which is code compatible with the LC86000 series.
The VMU flash memory contains 128 kilobytes of storage. These are divided into 256 blocks of 512 bytes each. Of these blocks, 200 are available for user files.
The rest of the blocks contain filesystem information, or are simply not used at all.


<h5 align="center"> VMS: The dreamcast memory card peripheral device </h5>
<p align="center">
   <img src="/docs/screenshot.png">
</p>


---

I have a fork of Marcus Comstedt's assembler that can be found [here](https://github.com/jahan-addison/comstedt-as).


* VMS software resource: https://mc.pp.se/dc/sw.html
* VMS hardware resource: https://mc.pp.se/dc/hw.html
* Extras: https://www.deco.franken.de/myfiles/myfiles.html


