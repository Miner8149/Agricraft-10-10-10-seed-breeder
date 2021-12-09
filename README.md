# Agricraft 10/10/10 Seed Breeder
Code to automate the creation/breeding of 10/10/10 or 10 10 10 or 101010 seeds (however you type it) from Agricraft and Mystical Agriculture using OpenComputers in Minecraft version 1.12.2


## Setup

This area is a work in progress. Pictures and instructions coming soon. (Dec.9.2021)

###### The Robot
The Robot is made with:

    - 1 Tier 3 Computer Case
    - 1 keyboard
    - 1 Tier 1 Screen
    - 1 Disk Drive
    - 1 Inventory Upgrade
    - 1 Inventory Controller Upgrade
    - 1 Tier 2 Card Slot Upgrade
    - 1 Tier 3 CPU
    - 1 Tier 1 GPU
    - 2 Tier 3.5 Memory Modules
    - 1 Tier 2 Hard Disk Drive
    
Also Required:

    - 1 Tier 2 Wireless Network Card (to communicate with the base computer)
    - 1 Internet Card (to download the code to the robot)
    - 1 Charger (to charge the robot)
    - 1 Block of Redstone (or another redstone power source) (to turn the charger on)
    
###### The Computer
The Computer System is setup with:

    - 1 Tier 3 Case
    - 1 Tier 3 Screen
    - 1 Keyboard
    - 1 Tier 3 CPU
    - 1 Tier 3 GPU
    - 2 Tier 3.5 Memory Modules
    - 1 Network Card
    - 1 Internet Card
    - 4 Computer Controlled Analyzers (Agricraft)
    
Also Required:

    - 1 Power Converter (to power the system)

###### Other Pieces
    - At Least 4 Chests
    - 1 Trashcan (Extra Utilities 2) or an equivilant way to dispose of items, i.e. another chest
    - Sprinklers (Agricraft) (Not Required) (I highly reccomend some way to speed up the growth of the crops)
    - Support Equipment for Sprinklers (Nor Required)
    - Growth Accelerators (Mystical Agriculture) (Not Required)
    
## Placement  
###### Information about placement 
I am using Iron Chests from the Iron Chests mod, but any chest should do.
The Chest above the Robot is for Crop Sticks
The Chest on the lefif for the finished 10/10/10 seeds
The Chest in the middle (Behind the robot) is for extra outputs produced during the automated breeding process
The Chest on the right is for the input seeds
The trashcan to the left of the Robot is where the seeds that re not 10/10/10 will be dumped as the robot works
The Computer Controlled seed analyzer to the Right of the robot is for analyzing the seeds the robot 

the code referances the Computer Controlled Seed analyzers as follows:
Analyzer 1: Analyzer to the front left of the Robot (For Parent 1)
Analyzer 2: Analyzer directly in front of the Robot (For Child)
Analyzer 3: Analyzer to the front eight of the Robot (For Parent 2)
Analyzer 4: Analyzer to the right of the Robot

The Farmland is referencd as follows:
Slot  1: Farmland to the front left of the Robot (For Parent 1)
Slot  0: Farmland directly in front of the Robot (For Child)
Slot -1: Farmland to the front right of the Robot (For Parent 2)

![2021-12-09_15 48 42](https://user-images.githubusercontent.com/95875669/145482239-66589667-92c5-428c-8f8a-39e746185597.png)
![2021-12-09_15 48 51](https://user-images.githubusercontent.com/95875669/145482247-9b01364e-f985-4dcf-9901-dece6b9d3f77.png)
![2021-12-09_15 49 02](https://user-images.githubusercontent.com/95875669/145482258-bc0b2b86-fe8c-4b23-ab17-f08c9f7db93b.png)


## The Code

The Code is Avaliable on Pastebin, as well as here.

For the Robot:
Direct Link: https://pastebin.com/uSjibHSi

For OpenOS:

    pastebin get -f uSjibHSi crops_robot.lua

for the Computer:
Direct Link: https://pastebin.com/VrrGhuKT

For OpenOS:

    pastebin get -f VrrGhuKT vrops_computer.lua

