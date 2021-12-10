--Miner8149
--12/7/2021

-- Visit my github for a more detailed set of instructions https://github.com/Miner8149/Agricraft-10-10-10-seed-breeder
-- https://pastebin.com/uSjibHSi
-- Copyright 2020 Miner8149
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--
-- I am not responible for exploding robots, or missing limbs. Do note that if the
-- robot gains sentience, that is would be in your best interest to run

--This is for the ROBOT
local com = require("component")
local ic = com.inventory_controller
local m = com.modem
local r = require("robot")
local s = require("sides")
local event = require("event")


local numCropsticksPlaced = nil
local childSeedPresent = false
local actionSlot = 0
local numParentSeedsObtained = 0
local mode = "clipping"  --Availiable modes are clipping and replacing

-- clipping mode will take a clipping of each new crop to replace both parents at once, 
-- replacing will replace the lowest parent
-- it will swap modes automatically to accomidate the presence of clippers.
-- replacing mode: avg time for 1.1.1 seeds to 10.10.10 seeds is 67 mins
-- clipping mode: avg time for 1.1.1 seeds to 10.10.10 seeds is not calulated yet

local pos = 0 --  -1 is left, 0 is center, 1 is right
local rot = 0 --  0-front, 1-right, 2-back, 3-left

--Slot Config
local newParentSeedSlot = 10
local brokenParentSeedSlot = 6
local childSeedSlot = 2
local clippingSeedSlot = 14
local cropStickSlot = 1
local wateringCanSlot = 16
local clippersSlot = 15


function goTo(posL, rotL)
  --print("Going to Position: ", posL, ", Rotation: ", rotL)
  local rotC = rotL - rot
  local posC = posL - pos
  local forwardMoved = false
  if (posC == 0) then
    if ((rotC == 3) or (rotC == -1)) then
      r.turnLeft()
      rot = (rot+3)%4
    elseif ((rotC == 2) or (rotC == -2)) then
      r.turnAround()
      rot = (rot+2)%4
    elseif ((rotC == -3) or (rotC == 1)) then
      r.turnRight()
      rot = (rot+1)%4
    end
  elseif (posC < 0) then
    goTo(pos, 3)
    if (posC == -1) then
      moveForward()
      pos = pos - 1
    elseif (posC == -2) then
      moveForward()
      pos = pos - 1
      moveForward()
      pos = pos - 1
    end
    goTo(posL, rotL)
  elseif (posC > 0) then
    goTo(pos, 1)
    if (posC == 1) then
      moveForward()
      pos = pos + 1
    elseif (posC == 2) then
      moveForward()
      pos = pos + 1
      moveForward()
      pos = pos + 1
    end
    goTo(posL, rotL)
  end
end

function moveForward()
  local hasMovedForward = nil 
  while (hasMovedForward == nil) do
    hasMovedForward = r.forward()
    if (hasMovedForward == nil) then
      print("I've bumped something")
      os.sleep(1)
    end
  end
end

function getCropSticks() --keep 48 on the robot max, 8 min
  --print("Fetching Cropsticks")
  local cropstickcount = ic.getStackInInternalSlot(cropStickSlot)
  if ((cropstickcount ~= nil) and (string.match(cropstickcount["name"], "crop") ~= "crop") and (string.match(cropstickcount["name"], "stick") ~= "stick"))  then
    local cropStickSlotFree = false
    for index=1, r.inventorySize() do
      r.select(index)
      cropstickcount = ic.getStackInInternalSlot(index)
      if ((cropstickcount == nil) and ( (index ~= newParentSeedSlot) and (index ~= brokenParentSeedSlot) and (index ~= childSeedSlot) and (index ~= clippingSeedSlot) and (index ~= cropStickSlot) and (index ~= wateringCanSlot) and (index ~= clippersSlot) ) ) then
        r.select(cropStickSlot)
        r.transferTo(index)
        cropStickSlotFree = true
        index = r.inventorySize()
      end
    end
    if not cropStickSlotFree then
      storeOther(cropStickSlot)
    end
  end
  local getNumber = 0
  cropstickcount = ic.getStackInInternalSlot(cropStickSlot)
  if(cropstickcount == nil) then
    getNumber = 48
  elseif (cropstickcount["size"] < 16) then
    getNumber = 48 - cropstickcount["size"]
  else
    --print("Nevermind")
    return true
  end
  goTo(0, 0)
  local chestSlot = nil
  r.select(cropStickSlot)
  for index=1,ic.getInventorySize(s.top) do
    chestSlot = ic.getStackInSlot(s.top,index)
    if ((chestSlot ~= nil) and ((string.match(invSlot["name"], "crop") == "crop") and (string.match(invSlot["name"], "stick") == "stick"))) then
      if (chestSlot["size"] < getNumber) then
        ic.suckFromSlot(s.top,index,chestSlot["size"])
        getNumber = getNumber - chestSlot["size"]
        print("Getting ", chestSlot["size"])
      else
        ic.suckFromSlot(s.top,index,getNumber)
        print("Getting ", getNumber)
        return true
      end
    end
  end
  return false
end

function destroy(slot) --void item in "slot" to trashcan
  print("Destroying Slot ", slot)
  goTo(-1, 3)
  r.select(slot)
  r.drop()
  --r.select(1)
end

function storeFinished(slot)
  print("Storing Finished Seed")
  goTo(-1, 2)
  r.select(slot)
  r.drop()
end

function storeOther(slot)
  print("Storing Other: ", slot)
  goTo(0, 2)
  r.select(slot)
  r.drop()
  --r.select(1)
end

function placeAnalyzeSeed(slot)
  print("Giving seed to Analyzer")
  goTo(1, 1)
  r.select(slot)
  r.drop()
  os.sleep(1)
end

function getAnalyzedSeed(slot)
  print("Retrieving Seed from Analyzer")
  goTo(1, 1)
  r.select(slot)
  os.sleep(1)
  r.suck()
end

function placeSingleCropstick(posL, index)
  print("Placing single cropsticks at ", posL)
  getCropSticks()
  goTo(posL, 0)
  r.select(cropStickSlot)
  r.place(s.front, false)
  local confirmSticks = 1 --requestData(2, posL)
  if (confirmSticks ~= 1) or (confirmSticks == nil) then
    if (index >= 3) then
      print("Unable to place Single Cropstick")
      return false
    end
    print("trying again in 5")
    os.sleep(5)
    placeSingleCropstick(posL, index+1)
  end
  return true
end

function placeDoubleCropstick(posL, index)
  print("Placing double cropsticks at ", posL)
  getCropSticks()
  goTo(posL, 0)
  r.select(cropStickSlot)
  r.place(s.front, true)
  local confirmSticks = 2 --requestData(2, posL)
  if (confirmSticks ~= 2) or (confirmSticks == nil) then
    if (index >= 3) then
      print("Unable to place Double Cropstick")
      return false
    end
    print("trying again in 5")
    os.sleep(5)
    placeDoubleCropstick(posL, index+1)
  end
  return true
end

function waterCrops() --watering can in slot 16
  --This is a work in progress, but the watering can isnt working... yes, I changed the config
  print("Watering...")
  goTo(0, 0)
  r.select(wateringCanSlot)
  --ic.equip()
  --r.use(s.all, true, 10)
  --ic.equip()
  os.sleep(10)
--  r.useDown(s.all, false, 10)
end

function breakChildSeed()
  print("Breaking Child Seed")
  local slotForChildSeed = ic.getStackInInternalSlot(childSeedSlot)
  while (slotForChildSeed ~= nil) do
    storeOther(childSeedSlot)
  end
  r.select(childSeedSlot)
  goTo(0, 0)
  r.swing()
end

function breakParentSeed(location) -- -1 or 1
  print("Breaking Parent at ", location)
  local slotForBrokenParentSeed = ic.getStackInInternalSlot(brokenParentSeedSlot)
  while (slotForBrokenParentSeed ~= nil) do
    storeOther(brokenParentSeedSlot)
  end
  r.select(brokenParentSeedSlot)
  goTo(location, 0)
  r.swing()
end

function plantSeed(slot, location, index)
  print("Planting Seed at ", location)
  r.select(slot)
  goTo(location, 0)
  ic.equip()  
  r.use()
  ic.equip()
  local confirmSeeds = true --requestData(1, location)
  if (confirmSeeds ~= true) then
    if (index >= 3) then
      print("Unable to place Seed")
      return false
    end
    print("trying again in 5")
    os.sleep(5)
    plantSeed(slot, location, index+1)
  end
  return true
end

function getNewSeeds()  --returns true on sucess, false otherwise
  print("Getting new Seeds")
  goTo(1, 2)
  local chestSlot = nil
  local numSeeds = 0
  r.select(newParentSeedSlot)
  for index=1,ic.getInventorySize(s.front) do
    chestSlot = ic.getStackInSlot(s.front,index)
    if ((chestSlot ~= nil) and (((string.match(invSlot["name"], "Seed") == "Seed") or (string.match(invSlot["name"], "seed") == "seed")) or (string.match(invslot["name"], "clipping") == "clipping")))then
      numSeeds = chestSlot["size"]
      if (numSeeds==2) or (numSeeds==1) then
        ic.suckFromSlot(s.front,index,numSeeds)
        print("Found Seeds/Clippings")
        numParentSeedsObtained = numSeeds
        initParents(newParentSeedSlot)
        return true
      else
        print("Not 2 or 1 Seeds/Clippings!")
        --return false
      end
    end
  end
  print("No Seeds Found")
  return false
end

function initParents(slot)
  print("initializing Parents from slot ", slot)
  goTo(1, 1)
  r.select(slot)
  r.drop()
  requestData(0, 0)
  r.suck()
end

function clearInv()
  local invSlot = nil
  for index=1,r.inventorySize() do
    r.select(index)
    invSlot = ic.getStackInInternalSlot(index)
    if (invSlot == nil) then
      --do nothing
    elseif ((string.match(invSlot["name"], "crop") == "crop") and (string.match(invSlot["name"], "stick") == "stick") and (index ~= cropStickSlot))  then
      storeOther(index)
    elseif ((invSlot["name"] == "agricraft:clippers") and (index ~= clippersSlot)) then
      local subCheckInv = ic.getStackInInternalSlot(clippersSlot)
      if (subCheckInv["name"] == "agricraft:clippers") then
        storeOther(index)
      else
        r.transferTo(clippersSlot)
        index = index - 1
      end
    elseif ((string.match(invSlot["name"], "Seed") == "Seed") or (string.match(invSlot["name"], "seed") == "seed")) then
      destroy(index)
    elseif (string.match(invslot["name"], "clipping") == "clipping") then
      destroy(index)
    elseif ((string.match(invSlot["name"], "water") == "water") and (string.match(invSlot["name"], "can") == "can") and (index ~= wateringCanSlot)) then
      local subCheckInv = ic.getStackInInternalSlot(wateringCanSlot)
      if ((string.match(invSlot["name"], "water") == "water") and (string.match(invSlot["name"], "can") == "can")) then
        storeOther(index)
      else
        r.transferTo(wateringCanSlot)
        index = index - 1
      end
  end
  --destroy(2)
  --destroy(6)
  --destroy(10)
  --storeOther(3)
  --storeOther(4)
  --storeOther(5)
  --storeOther(7)
  --storeOther(8)
  --storeOther(9)
  --storeOther(11)
  --storeOther(12)
  --storeOther(13)
  --storeOther(14)
  --storeOther(15)
end

function breakAll()
  print("Breaking all")
  goTo(1, 0)
  r.swing()
  goTo(0, 0)
  r.swing()
  goTo(-1, 0)
  r.swing()
  --goTo(-1, 3)
  --for index=2,15 do
  --  r.select(index)
  --  r.drop()
  --end
  --r.select(1)
end

function requestData(funct, slot) --can request init (0), isplant(1, slot), is cropstick(2, slot), analyze(3), decide analyze location(4)
  local returnVal = nil
  print("Requesting data: ", funct, ", ", slot)
  if (funct == 0) then  --initialize parent varibales, expect bool return
    m.broadcast(111, 0, 0)
    _, _, _, _, _, returnVal = event.pull("modem_message")
    event.pull(2, "modem_message")
  elseif (funct == 1) then --check for plant at slot, expect bool return
    m.broadcast(111, 1, slot)
    _, _, _, _, _, returnVal = event.pull("modem_message")
    event.pull(2, "modem_message")
  elseif (funct == 2) then --check for cropsticks, expect number of cropsticks 0, 1, 2
    m.broadcast(111, 2, slot)
    _, _, _, _, _, returnVal = event.pull("modem_message")
    event.pull(2, "modem_message")
  elseif (funct == 3) then --analyze crop, expect bool return
    m.broadcast(111, 3, 0)
    _, _, _, _, _, returnVal = event.pull("modem_message")
    event.pull(2, "modem_message")
  elseif (funct == 4) then --decide location, expect slot -1, 0, 1
    m.broadcast(111, 4, 0)
    _, _, _, _, _, returnVal = event.pull("modem_message")
    event.pull(2, "modem_message")
  else
    return nil
  end
  print("Recieved: ", returnVal)
  return returnVal
end

function obtainClipping()
  local itemInClippersSlot = ic.getStackInInternalSlot(clippersSlot)
  local hasClippers = false
  if ((itemInClippersSlot ~= nil) and (itemInClippersSlot["name"] == "agricraft:clippers")) then
    hasClippers = true
  else    --look for clippers
    r.select(clippersSlot)
    ic.equip()
    itemInClippersSlot = ic.getStackInInternalSlot(clippersSlot)
    if ((itemInClippersSlot ~= nil) and (itemInClippersSlot["name"] == "agricraft:clippers")) then
      hasClippers = true
    else
      for index=1,r.inventorySize() do
        r.select(index)
        itemInClippersSlot = ic.getStackInInternalSlot(index)
        if ((itemInClippersSlot ~= nil) and (itemInClippersSlot["name"] == "agricraft:clippers")) then
          r.transferTo(clippersSlot)
          hasClippers = true
        end
      end
      if (hasClippers == false) then
        return nil
      end
    end
  end
  r.select(clippersSlot)
  ic.equip()
  r.select(ClippingSeedSlot)
  local gotClipping = r.use() --true or false
  r.select(clippersSlot)
  ic.equip()
  return gotClipping
end

function setup()
  m.open(112)
end

setup()
while true do
  while not (getCropSticks()) do
    os.sleep(10)
  end
  breakAll()
  clearInv()
  while not (getNewSeeds()) do
    goTo(0, 0)
    os.sleep(10)
  end
  placeSingleCropstick(1, 0)
  placeDoubleCropstick(0, 0)
  placeSingleCropstick(-1, 0)
  plantSeed(newParentSeedSlot, -1, 0)
  plantSeed(newParentSeedSlot, 1, 0)
  while true do
    while not (childSeedPresent) do
      waterCrops()
      childSeedPresent = requestData(1, 0)
    end
    breakChildSeed()
    childSeedPresent = false
    placeDoubleCropstick(0, 0)
    placeAnalyzeSeed(childSeedSlot)
    actionSlot = requestData(4, 0)
    getAnalyzedSeed(childSeedSlot)
    if (actionSlot == 2) then --just a return val
      storeFinished(childSeedSlot)
      breakAll()
      clearInv()
      break
    elseif (actionSlot == 0) then --just a return val
      destroy(childSeedSlot)
    elseif (actionSlot == nil) then  --just a return val
      print("the seed wasnt analyzed")
      storeOther(childSeedSlot)
    else
      breakParentSeed(actionSlot)
      placeSingleCropstick(actionSlot, 0)
      plantSeed(childSeedSlot, actionSlot, 0)
      clearInv()
    end
  end
end
