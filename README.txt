			******** Kernel Debugging Virtualized ********
----------------------------------------------------------------------------------------------------------
Without Virtualization:
----------------------

2 x86 PCs – connected by a serial cable – one booted up into our custom environment (referred to as the guest), the other with GDB running (referred to as the host). The guest is booted up using a USB drive that is prepared according to a procedure that I assume the reader already knows. Using the COM interface, we execute our program on the guest, and receive debugging info on the host. I assume that the reader knows the steps involved in setting this up.
______________________________________________________________________________________________________________________________________________
With Virtualization:
---------------------
Exactly the same setup, except that both PCs are Virtual Machines (VMs) on any popular Virtualization platform. Oracle VirtualBox on Windows & OS X, and VMWare Workstation Windows have been tested and confirmed to work. VirtualBox on Linux should work too.

Setup Procedure:

1. Create 2 new VMs. Know the path where they both are located. Install your favourite Linux distribution on one of them - the host (my favourite is Xubuntu). The VMs will have Virtual Hard Disks. A VHD is essentially just a file – the extension/format will vary with each virtualization platform. The VHD of the guest VM is going to play the role of the USB drive.

2. Shut down both VMs. In the VM settings of the host VM, add a hard disk. Here, choose the hard disk of the Guest VM. Now start up the host VM. The VHD of the Guest VM would be connected to the Host VM.

3. Follow the identical procedure used to prepare the USB drive in order to prepare the VHD of the Guest VM for boot.

4. After the VHD is prepared and is bootable, shut down the Host VM and from the VM settings, disconnect the Guest VHD from the Host VM.

Now that both VMs are ready, we just need to connect them with a serial cable. There are plenty of ways to do this. We can assign physical serial ports of our physical computer to both VMs and connect it with a physical serial cable. We also can virtualize this whole thing
and connect them to a “named pipe”.

5. In the VM settings of both VMs, add a serial port. Connect the serial ports to a named pipe – use the same name on both VMs. The UI for different virtualization solutions will differ, but essentially, one VM must initiate the connection, and the other must receive it. Set up one
VM to start the serial port / set it up as the server. Set the other as a client.

6. You’re good to go.! Just start both VMs, and use them as you normally would. 
_______________________________________________________________________________________________________________________________________________
Alternative Configuration (Untested & untried):
-----------------------------------------------

If the PC being used is a Linux PC, instead of 2 VMs one can create just 1 VM, and connect it with a virtual serial port to the Host.
I have not tried this out. This is going to make life a little difficult when it comes to setting up the VHD of the guest.

Try this out if you have the inclination!

