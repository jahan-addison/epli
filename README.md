<h1 align="center">serpent 🐍</h1>

<h5 align="center"> VMS: The dreamcast memory card peripheral device </h5>
<p align="center">
   <img src="/docs/screenshot.png">
</p>

### Overview

A recharged take at "snake" for the VMU device's firmware, CPU, and LCD frame buffer as an experienced engineer. My first incomplete version from 15 years ago can be found [here](https://github.com/jahan-addison/serpent/tree/throwback).

The CPU in the VMS _(dubbed, "the potato")_ is a customized Sanyo microcontroller which is code compatible with the LC86000 series.

* The microcontroller: https://mc.pp.se/dc/vms/cpu.html ([pdf](/docs/mc-pp-se-dc-vms-cpu-html....pdf))
* The flash memory: https://mc.pp.se/dc/vms/flashmem.html ([pdf](/docs/mc-pp-se-dc-vms-flashmem-html....pdf))
* The firmware: https://mc.pp.se/dc/vms/fw.html ([pdf](/docs/mc-pp-se-dc-vms-fw-html....pdf))

### Resources

* My fork of Comstedt's VMS assembler https://github.com/jahan-addison/aslc86k-mc
* My fork of Comstedt's VMS emulator https://github.com/jahan-addison/softvms-mc

## Build


### Requirements

- CMake ≥ 3.16
- Flex and Bison (required by the assembler)
- The `external/as` submodule initialized:
  ```sh
  git submodule update --init
  ```

### Steps

```sh
cmake -B build
cmake --build build
```

The game compiles to `build/serpent.vms`.

# License

#### Simplified BSD License