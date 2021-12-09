--Miner8149
--12/7/2021

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

--this is for the COMPUTER
local com = require("component")
local event = require("event")
--local s = require("sides")
local m = com.modem

-- Change the leters and numbers here to
-- the first 5 characters of the address of your
-- analyzers
an1 = com.proxy(com.get("6352f")) --Parent 1
an2 = com.proxy(com.get("fb213")) --Child
an3 = com.proxy(com.get("db467")) --Parent 2
an4 = com.proxy(com.get("42689")) --Analyzer


curentPlant = nil
Par1Gro = 0 --Par1 is in slot -1
Par1Gai = 0
Par1Str = 0
Par1    = 0
Par2Gro = 0 --Par 2 is in slot 1
Par2Gai = 0
Par2Str = 0
Par2    = 0
Chi0Gro = 0 --child is in slot 0
Chi0Gai = 0
Chi0Str = 0
Chi0    = 0
incommingMsgFunct = nil
incommingMsgSlot  = nil
stateVarToBroadcast = nil

function getMyPlant(slot)
  local plant = nil
  local analyzerTemp = nil
  if (slot == -1) then
    analyzerTemp = an1
    print("an1")
  elseif (slot == 0) then
    analyzerTemp = an2
    print("an2")
  elseif (slot == 1) then
    analyzerTemp = an3
    print("an3")
  else
    print("analyzer - nil")
    return nil
  end
  plant = analyzerTemp.getPlant("SOUTH")
  print(plant)
  if (plant==nil) or (plant=="None") then
    print("false")
    return false
  else
    print("true")
    return true
  end
end

function initializeParents()
  print("NewLine")
  print("NewLine")
  print("Initializing Parent Seeds")
  local status = analyzePlant()
  Par1Gro, Par1Gai, Par1Str = an4.getSpecimenStats()
  Par2Gro, Par2Gai, Par2Str = Par1Gro, Par1Gai, Par1Str
  Par2 = Par1Gro + Par1Gai + Par1Str
  Par1 = Par2
  Chi0Gro, Chi0Gai, Chi0Str, Chi0 = 0, 0, 0, 0
  print("Parents Stats Sum: ", Par1)
  return status
end

function decideLocation()
  print("Deciding Location")
  local plantInAnalyzer = nil
  plantInAnalyzer = an4.getSpecimen()
  print("Plant in Analyzer: ", plantInAnalyzer)
  if (plantInAnalyzer == nil) or (plantInAnalyzer == "Air") then
    return nil
  end
  print("About to Analyze")
  local isAnalyzedAlready = an4.isAnalyzed()
  if not (isAnalyzedAlready) then
    print("Not Yet Analyzed.")
    analyzePlant()
  else
    print("Already Analyzed.")
  end
  Chi0Gro, Chi0Gai, Chi0Str = an4.getSpecimenStats()
  Chi0 = Chi0Gro + Chi0Gai + Chi0Str
  print("Child Stat Sum: ", Chi0)
  print("Parent 1 Stat Sum: ", Par1)
  print("Parent 2 Stat Sum: ", Par2)
  if (Chi0 == 30) then
    return 2
  end
  if (Par1 < Par2) then   --parent 1 less than parent 2
    if (Par1 < Chi0) then
      Par1Gro, Par1Gai, Par1Str = Chi0Gro, Chi0Gai, Chi0Str
      Par1 = Chi0
      return -1           --parent 1 (slot -1) is least
    else
      return 0            --child is least
    end
  else                    --parent 2 less than parent 1
    if (Par2 < Chi0) then
      Par2Gro, Par2Gai, Par2Str = Chi0Gro, Chi0Gai, Chi0Str
      Par2 = Chi0
      return 1            --parent 2 (slot 1) is least
    else
      return 0            --child is least
    end
  end
end

function analyzePlant()
  print("Analyzing plant")
  local plant = an4.getSpecimen()
  if (plant==nil) or (plant=="Air") then
    print("no plant: ", plant)
    return false
  end
  while (not an4.isAnalyzed()) do
    plant = an4.getSpecimen()
    if (plant==nil) or (plant=="Air") then
      print("Plant went Missing: ", plant)
      return false
    end
    print("Analyzing...")
    an4.analyze()
    os.sleep(1)
  end
  return true
end

function cropStickState(slot)
  local analyzerTemp = nil
  local state = nil
  if (slot == -1) then
    print("Sticks an1")
    analyzerTemp = an1
  elseif (slot == 0) then
    print("Sticks an2")
    analyzerTemp = an2
  elseif (slot == 1) then
    print("Sticks an3")
    analyzerTemp = an3
  else
    print("Sticks Nil")
    return nil
  end
  state = analyzerTemp.isCrossCrop("SOUTH")
  if (state == nil) then
    print("No sticks")
    return 0 --no sticks
  elseif (state == false) then
    print("1 Stick")
    return 1 -- 1 stick
  elseif (state == true) then
    print("2 Sticks")
    return 2 -- 2 sticks
  else
    print("nil Sticks")
    return nil
  end
end

function setup()
  m.open(111)
  print("Ready")
end

setup()
while true do
  _, _, _, _, _, incommingMsgFunct, incommingMsgSlot = event.pull("modem_message")
  --print("Recived: ", incommingMsgFunct, ", ", incommingMsgSlot)

  if (incommingMsgFunct == 0) then --wants me to init parents
    stateVarToBroadcast = initializeParents()
    print("init")
  elseif (incommingMsgFunct == 1) then --wants me to check for plant at slot
    stateVarToBroadcast = getMyPlant(incommingMsgSlot)
    print("plant")
  elseif (incommingMsgFunct == 2) then --wants me to check for cropsticks at slot
    stateVarToBroadcast = cropStickState(incommingMsgSlot)
    print("cropsticks")
  elseif (incommingMsgFunct == 3) then --wants me to analyze crop
    stateVarToBroadcast = analyzePlant()
    print("analyze")
  elseif (incommingMsgFunct == 4) then --wants me to decide what to do with new plant
    stateVarToBroadcast = decideLocation()
    print("decide")
  else
    stateVarToBroadcast = nil
  end
  os.sleep(1)
  m.broadcast(112, stateVarToBroadcast)
  print("Sending: ", stateVarToBroadcast)
end
