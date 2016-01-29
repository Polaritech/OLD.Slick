# Slick
Slick is an operating system kernel, as well as the name of the group of
projects comprising of the kernel, bootloader, and drivers. It is designed to
be an extensible microkernel that limits the amount of abstraction required to
write and run an application. The premise behind this idea is that software can
still be written to take advantage of exsisting abstractions and frameworks,
while still having the flexibility to access lower-level components to increase
performance without sacrificing stability and safety.

**The Slick OS Project Consists of the Following Components**  
+ GLOSS ~ **G**eneric **L**oader for **O**perating **S**ystem**S**  
An extensible bootloader that supports configuration files per-OS, which reduces the need for the OS to support boot routines.
+ SLICK ~ **S**ystem **L**evel **I**ntegrated **C**omputer **K**ernel  
The core microkernel which the operating system is built upon.
