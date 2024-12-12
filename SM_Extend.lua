-- Script created by Leontiesh.
-- Credit to furyswipes for insipiring me to learn Lua and to create my own scripts, check out his website for multiboxing (https://furyswipes.wixsite.com/mysite).
-- Some of the Library functions I picked up from furyswipes, credit goes to him.

---------- LIBRARY ----------
AUTO_ATTACK = 61
HEROIC_STRIKE = 62
CLEAVE = 63
SHORT_RANGE = 3
LONG_RANGE = 1

player_isCasting = false
player_isChanneling = false
player_isCastingAutoRepeat = false
lastDodgeTime = 0
overpowerCooldownEndTime = 0

-- Update Overpower cooldown
local function UpdateOverpowerCooldown()
	local start,duration,enable = GetSpellCooldown(SpellNum("Overpower"),BOOKTYPE_SPELL)
	if enable and start > 0 and duration > 1.5 then
		overpowerCooldownEndTime = start + duration
	end
end

-- create a frame for tracking events
Nexus = CreateFrame("Button","Nexus",UIParent)
-- register the events we want to use (this is why we made the frame)
Nexus:RegisterEvent("SPELLCAST_START")
Nexus:RegisterEvent("CHAT_MSG_SPELL_SELF_BUFF")
Nexus:RegisterEvent("SPELLCAST_INTERRUPTED")
Nexus:RegisterEvent("SPELLCAST_FAILED")
Nexus:RegisterEvent("SPELLCAST_DELAYED")
Nexus:RegisterEvent("SPELLCAST_STOP")
Nexus:RegisterEvent("SPELLCAST_CHANNEL_START")
Nexus:RegisterEvent("SPELLCAST_CHANNEL_UPDATE")
Nexus:RegisterEvent("SPELLCAST_CHANNEL_STOP")
Nexus:RegisterEvent("CURRENT_SPELL_CAST_CHANGED")
Nexus:RegisterEvent("START_AUTOREPEAT_SPELL")
Nexus:RegisterEvent("STOP_AUTOREPEAT_SPELL")
Nexus:RegisterEvent("CHAT_MSG_COMBAT_SELF_MISSES")
Nexus:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
Nexus:RegisterEvent("CHAT_MSG_COMBAT_SELF_MISSES")
Nexus:RegisterEvent("CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF")
Nexus:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")

-- create the OnEvent function
function Nexus:OnEvent()
	-- Say(arg1)
	-- this event fires when you start casting
	if event == "SPELLCAST_START" then
		player_isCasting=true
	-- this event fires when you stop casting
	elseif ( event == "SPELLCAST_STOP" ) then
		player_isCasting=false
	-- this event fires when your spells gets interrupted
	elseif event == "SPELLCAST_INTERRUPTED" then
		player_isCasting=false
	-- this event fires when your spell fails
	elseif event == "SPELLCAST_FAILED" then
		player_isCasting=false
	-- this event fires when you start channeling
	elseif event == "SPELLCAST_CHANNEL_START" then
		player_isChanneling=true
	-- this event fires when you stop channeling
	elseif event == "SPELLCAST_CHANNEL_STOP" then
		player_isChanneling=false
	-- this event fires when you start casting auto repeat spells
	elseif ( event == "START_AUTOREPEAT_SPELL" ) then
		player_isCastingAutoRepeat=true
	-- this event fires when you stop casting auto repeat spells
	elseif ( event == "STOP_AUTOREPEAT_SPELL" ) then
		player_isCastingAutoRepeat=false
	-- mark that the target has dodged your attack and overpower is ready to use
	elseif event == "CHAT_MSG_COMBAT_SELF_MISSES" then
		if UnitName("target") and string.find(arg1, UnitName("target")) and	string.find(arg1, "dodges") then
			UpdateOverpowerCooldown()
			lastDodgeTime = GetTime()
		end
	-- mark that overpower has been cast and is now on cooldown
	elseif event == "CHAT_MSG_SPELL_SELF_DAMAGE" or event == "CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF" then
		if string.find(arg1, "Your Overpower") then
			UpdateOverpowerCooldown()
		end
	end
end

-- this will send all the registered events to the OnEvent function
-- without this we won't receive any events.
Nexus:SetScript("OnEvent", Nexus.OnEvent) -- event handler

function init()
	if not HasAction(AUTO_ATTACK) then
		PickupSpell(SpellNum("Attack"),BOOKTYPE_SPELL)
		PlaceAction(AUTO_ATTACK)
	end
	
	if not HasAction(HEROIC_STRIKE) then
		PickupSpell(SpellNum("Heroic Strike"),BOOKTYPE_SPELL)
		PlaceAction(HEROIC_STRIKE)
	end
	
	if not HasAction(CLEAVE) then
		PickupSpell(SpellNum("Cleave"),BOOKTYPE_SPELL)
		PlaceAction(CLEAVE)
	end
end

function MyLevel()
	return UnitLevel("player")
end

function MyRage()
	return UnitMana("player")
end

function MyMana()
	return UnitMana("player")
end

function MyEnergy()
	return UnitMana("player")
end

function MyManaPct()
	return UnitMana("player")/UnitManaMax("player")
end

function MyHealth()
	return UnitHealth("player")
end

function TargetHealthPct()
	return UnitHealth("target")/UnitHealthMax("target")
end

function MyHealthPct()
	return UnitHealth("player")/UnitHealthMax("player")
end

function MyAttackPower()
	local base, posBuff, negBuff = UnitAttackPower("player");
	return base + posBuff + negBuff;
end

function MyDruidManaPct()
	return druid_mana/druid_mana_max
end

function focus()
	return UnitMana("pet")
end

function IAmTarget()
	if UnitName("targettarget")==UnitName("player") then return true end
end

function InCombat(target)
	return (UnitAffectingCombat(target) or PVP()) and not TargetSheeped()
end

function MyHealthPct()
	return UnitHealth("player")/UnitHealthMax("player")
end

function InBuffRange()
	return CheckInteractDistance("party",4)
end

function InRaid()
	if UnitInRaid("player") then return true end
end

function MyStance()
	local stance
	local texture,name,isActive,isCastable = GetShapeshiftFormInfo(1)
	if isActive then stance=1 end
	local texture,name,isActive,isCastable = GetShapeshiftFormInfo(2)
	if isActive then stance=2 end
	local texture,name,isActive,isCastable = GetShapeshiftFormInfo(3)
	if isActive then stance=3 end
	local texture,name,isActive,isCastable = GetShapeshiftFormInfo(4)
	if isActive then stance=4 end
	local texture,name,isActive,isCastable = GetShapeshiftFormInfo(5)
	if isActive then stance=5 end
	local texture,name,isActive,isCastable = GetShapeshiftFormInfo(6)
	if isActive then stance=6 end
	local texture,name,isActive,isCastable = GetShapeshiftFormInfo(7)
	if isActive then stance=7 end
	return stance
end

function SpellExists(findspell)
	if not findspell then return end
	for i = 1, MAX_SKILLLINE_TABS do
		local name, texture, offset, numSpells = GetSpellTabInfo(i);
		if not name then break end
		for s = offset + 1, offset + numSpells do
			local	spell, rank = GetSpellName(s, BOOKTYPE_SPELL);
			if rank then
				local spell = spell.." "..rank;
			end
			if string.find(spell,findspell,nil,true) then
				return true
			end
		end
	end
end

function SpellNum(spell)
	local i = 1 highestSpellNum=0
	local spellName
	while true do
		spellName, spellRank = GetSpellName(i, BOOKTYPE_SPELL)
		if not spellName then
			do break end
		end
		if string.find(spellName,spell) then highestSpellNum=i end
		i = i + 1
	end
	if highestSpellNum==0 then return end
	return highestSpellNum
end

function OnCooldownGCD(spell)
	if not SpellExists(spell) then return true end
	local start,duration,enable = GetSpellCooldown(SpellNum(spell),BOOKTYPE_SPELL)
	if duration >= 0 and duration <= 1.5 then
		return false
	else
		return duration
	end
end

function OnCooldown(spell)
	if not SpellExists(spell) then return true end
	local start,duration,enable = GetSpellCooldown(SpellNum(spell),BOOKTYPE_SPELL)
	if not enable then return true end
	if start == 0 then return false end
	local currentTime = GetTime()
	local remainingCD = (start + duration) - currentTime
	if remainingCD <= 0 then
		return false
	else
		return true
	end
	
	-- if duration == 0 then
		-- return false
	-- else
		-- return duration
	-- end
end

function CooldownTime(spell)
	if not SpellExists(spell) then return end
	local time=GetTime()
	local cdtime
	local start,duration,enable = GetSpellCooldown(SpellNum(spell),BOOKTYPE_SPELL)
	if duration==0 then cdtime=0
	else
		cdtime=time-start
	end
	return cdtime
end

function SelfBuff(spell)
	if CanTryToCastSpell(spell) and not buffed(spell,"player") then
		CastSpellByName(spell,1)
	end
end

function DeBuff(spell)
	if CanTryToCastSpell(spell) and not buffed(spell,"target") then
		CastSpellByName(spell,1)
	end
end

function IsAlive(id)
	if not id then return end
	if UnitName(id) and (not UnitIsDead(id) and UnitHealth(id)>1 and not UnitIsGhost(id) and UnitIsConnected(id)) then return true end
end

function TargetSheeped()
	if buffed("Scare Beast","target") or buffed("Polymorph","target") or buffed("Shackle Undead","target") or buffed("Hibernate","target") or buffed("Wyvern Sting","target") then return true end
end

function DotCast(spell)
	local name,realm=UnitName("target")
	if not name or not UnitIsConnected("target") or UnitIsDead("target") or UnitIsGhost("target") then return end
	if not buffed(spell,"target") then cast(spell) end
end

debuffslotlist={"Repentance","Hammer of Justice","Viper Sting","Detect Magic","Curse of Recklessness","Curse of Shadow","Curse of the Elements","Curse of Agony","Curse of Agony","Curse of Agony","Demoralizing Shout","Thunder Clap","Insect Swarm(Rank 1)","Vampiric Embrace","Hunter's Mark","Fairy Fire","Placeholder for Nightfall","Placeholder for Shadow Weaving","Placeholder for Mindflay","Placeholder for Winters Chill","Scorpid Sting","Placeholder for improved Shadowbolt","Polymorph","Shackle Undead","Banish","Hibernate","Fear","Scare Beast"}
function BuffCast(spell)
	if not UnitName("target") or UnitIsDead("target") or UnitIsGhost("target") then return end
	if UnitIsEnemy("player","target") then
		if FindInTable(debuffslotlist,spell) and not buffed(spell,"target") then cast(spell) end
	else
		if not buffed(spell,"target") then cast(spell) end
	end
end

function PartyBuff(spell)
	if InCombat("player") then return end
	if not CanTryToCastSpell(spell) then return end
		
	-- buff self
	if not buffed(spell,"player") then
		TargetUnit("player")
		BuffCast(spell)
	end
	
	-- buff party but skip checking self
	if GetNumPartyMembers()==0 then return end
	local n=GetNumPartyMembers()
	for i=1,n do
		if UnitName("party"..i) ~= UnitName("player") then 
			if UnitName("party"..i) and IsAlive("party"..i) and CheckInteractDistance("party"..i, 4) and not buffed(spell,"party"..i) then
				TargetUnit("party"..i)
				BuffCast(spell)
				return
			end
		end
	end
end

function RaidBuff(spell)
	if InCombat("player") then return end
	if not CanTryToCastSpell(spell) then return end
	if not UnitInRaid("player") then 
		PartyBuff(spell) 
		return 
	end
	
	local n=GetNumRaidMembers()
	for i=1,n do
		if UnitName("raid"..i) and IsAlive("raid"..i) and CheckInteractDistance("raid"..i, 4) and not buffed(spell,"raid"..i) then
			TargetUnit("raid"..i)
			BuffCast(spell)
			return
		end
	end
end

cooldowns={}
function CooldownCast(spell,cooldown)
	if not CanTryToCastSpell(spell) then return end
	local time = GetTime()
	if not cooldowns[spell] then
		cast(spell)
		cooldowns[spell] = time
		return
	end
	if cooldowns[spell] + cooldown > time then
		--Print(spell.." is in cooldown for "..math.floor(cooldowns[spell]+cooldown-time).." more seconds")
		return
	end
	if cooldowns[spell] + cooldown <= time then
		cast(spell)
		cooldowns[spell] = nil
	end
end

function StackCast(spell,numstacks)
	if not buffed(spell,"target") then cast(spell) end
	local spell_icon=GetSpellTexture(SpellNum(spell),BOOKTYPE_SPELL)
	local count,icon
	for i=1,16 do
		icon,count = UnitDebuff("target",i)	
		-- if icon then
		-- Say(i)
		-- end
		if icon == spell_icon then
			if count < numstacks then cast(spell)
			elseif count >= numstacks then CooldownCast(spell,15)
			end
		end
	end
end

function PVP()
	return GetRealZoneText()=="Alterac Valley" or (UnitIsPlayer("target") and UnitIsEnemy("target","player"))
end

function UnsilencedCast(spell)
	if not buffed("Shield Bash","target") and not buffed("Pummel","target") and not buffed("Concussion Blow","target") and not buffed("War Stomp","target") then
		cast(spell)
	end
end

function CombatUse(item)
	if InCombat("player") then use(item) end
end

function normal(unit)
	if UnitClassification(unit) == "normal" then return true else return end
end

function normalplus(unit)
	if UnitClassification(unit) == "rareelite" or UnitClassification(unit) == "elite" or UnitClassification(unit) == "rare" or UnitClassification(unit) == "normal" then return true else return end
end

function elite(unit)
	if UnitClassification(unit) == "rareelite" or UnitClassification(unit) == "elite" or UnitClassification(unit) == "rare" then return true else return end
end

function eliteplus(unit)
	if UnitClassification(unit) == "worldboss" or UnitClassification(unit) == "rareelite" or UnitClassification(unit) == "elite" or UnitClassification(unit) == "rare" then return true else return end
end

function boss(unit)
	if UnitClassification(unit) == "worldboss" then return true else return end
end

function casting()
    return CastingBarFrame.casting
end

function channeling()
    return CastingBarFrame.channeling
end

function IsNonMeleeSpellCasted(checkCasted, checkChannelled, checkAutoRepeat)
	-- this is how you do default arguments in lua, similar to saying:
	-- IsNonMeleeSpellCasted(true, true, false)
    checkCasted = checkCasted == nil and true or checkCasted
    checkChannelled = checkChannelled == nil and true or checkChannelled
    checkAutoRepeat = checkAutoRepeat == nil and false or checkAutoRepeat

    if checkCasted then
        if player_isCasting then
			-- Say("CASTING")
            return true
        end
    end

    if checkChannelled then
        if player_isChanneling then
			-- Say("CHANNELING")
            return true
        end
    end

    if checkAutoRepeat then
        if player_isCastingAutoRepeat then
			-- Say("SHOOTING")
            return true
        end
    end

    return false
end

function GetWeaponSpeed()
	local speedMH, speedOH = UnitAttackSpeed("player")
	return speedMH
end

function Jindo()
	tname=UnitName("target")
	if tname=="Powerful Healing Ward" or tname=="Shade of Jin'do" or tname=="Jin'do the Hexxer" or tname=="Brain Wash Totem" then return true end
end

function Sulfuron()
	tname=UnitName("target")
	if tname=="Sulfuron Harbinger" or tname=="Flamewaker Priest" then return true end
end

function Garr()
	tname=UnitName("target")
	if tname=="Garr" or tname=="Firesworn" then return true end
end

function Decurse()
	if InCombat("player") then return end	
	
   --REQUIRES DEURSIVE ADDON
   if Jindo() then return end
   if Sulfuron() then return end
   if Garr() then return end
   if MyMana()<220 then return end
   if IsNonMeleeSpellCasted() then return end
   if not UnitInRaid("player") then DecurseParty() return end
   local y,x
   for y=1,GetNumRaidMembers() do
	for x=1,16 do
	  local name,count,debuffType=UnitDebuff("raid"..y,x,1)
	  if debuffType=="Curse" and DCR_CAN_CURE_CURSE then 
		  -- Print("DECURSE: "..UnitName("raid"..y).." is cursed.") 
		  RunLine("/decursive") 
	  return end
	  if debuffType=="Magic" and DCR_CAN_CURE_MAGIC then 
		  -- Print("DECURSE: "..UnitName("raid"..y).." is magicked.") 
		  RunLine("/decursive") 
	  return end
	  if debuffType=="Disease" and DCR_CAN_CURE_DISEASE then 
		  -- Print("DECURSE: "..UnitName("raid"..y).." is Diseased.") 
		  RunLine("/decursive") 
	  return end
	  if debuffType=="Poison" and DCR_CAN_CURE_POISON then 
		  -- Print("DECURSE: "..UnitName("raid"..y).." is Poisoned.") 
		  RunLine("/decursive") 
	  return end
        end
   end
   TargetUnit("playertarget")
end

function DecurseParty()
   --REQUIRES DEURSIVE ADDON
   local y,x
	for x=1,16 do
	  local name,count,debuffType=UnitDebuff("player",x,1)
	  if debuffType=="Curse" and DCR_CAN_CURE_CURSE then 
		  -- Print("DECURSE: "..UnitName("player").." is cursed.") 
		  RunLine("/decursive") 
	  return end
	  if debuffType=="Magic" and DCR_CAN_CURE_MAGIC then 
		  -- Print("DECURSE: "..UnitName("player").." is magicked.") 
		  RunLine("/decursive") 
	  return end
	  if debuffType=="Disease" and DCR_CAN_CURE_DISEASE then 
		  -- Print("DECURSE: "..UnitName("player").." is Diseased.") 
		  RunLine("/decursive") 
	  return end
	  if debuffType=="Poison"  and DCR_CAN_CURE_POISON then  
		  -- Print("DECURSE: "..UnitName("player").." is Poisoned.") 
		  RunLine("/decursive") 
	  return end
        end
   for y=1,4 do
	for x=1,16 do
	  local name,count,debuffType=UnitDebuff("party"..y,x,1)
	  if debuffType=="Curse" and DCR_CAN_CURE_CURSE then  
		  -- Print("DECURSE: "..UnitName("party"..y).." is cursed.") 
		  RunLine("/decursive") 
	  return end
	  if debuffType=="Magic" and DCR_CAN_CURE_MAGIC then  
		  -- Print("DECURSE: "..UnitName("party"..y).." is magicked.") 
		  RunLine("/decursive") 
	  return end
	  if debuffType=="Disease" and DCR_CAN_CURE_DISEASE then  
		  -- Print("DECURSE: "..UnitName("party"..y).." is Diseased.") 
		  RunLine("/decursive") 
	  return end
	  if debuffType=="Poison" and DCR_CAN_CURE_POISON then  
		  -- Print("DECURSE: "..UnitName("party"..y).." is Poisoned.") 
		  RunLine("/decursive") 
	  return end
	end
   end
   TargetUnit("playertarget")
end

function Fade()
	--Priests fade when any of 3 nearby mobs are attacking them
	if OnCooldown("Fade") then return end
	for i=1,3 do
		TargetNearestEnemy()
		if UnitIsEnemy("target","player") and not OnCooldown("Fade") and not PVP() and TargetInCombat("player") and UnitIsUnit("targettarget","player") then
		-- print(UnitName("player").." CASTING FADE BECAUSE OF AGRO FROM "..UnitName("target"))
		CastSpellByName("Fade",1)
		end
	end
	TargetUnit("playertarget")
end

function FindTarget(name)
    local targetName = UnitName("target")
	if 
		targetName == name and 
		IsAlive("target") 
	then
		return
	else
		ClearTarget()
        TargetByName(name, true);
	end
end

isTargetFinderActive = false
function AutoTargetFinder(name)
    if not isTargetFinderActive then
        local startTime = GetTime();
        DEFAULT_CHAT_FRAME:AddMessage("\124cff008ae6 Auto Target Finder \124r is \124cff00FF00 ENABLED \124r")
        isTargetFinderActive = true
        IndicatorFrame = CreateFrame("Frame",nil,UIParent)
        IndicatorFrame:SetScript("OnUpdate", function(self)
            local currentTime = GetTime()
            if (currentTime - startTime >= 1) then
				-- DEFAULT_CHAT_FRAME:AddMessage(currentTime - startTime)
                startTime = GetTime()
                FindTarget(name)
            end
        end)
    else
        IndicatorFrame:SetScript("OnUpdate", nil)
        DEFAULT_CHAT_FRAME:AddMessage("\124cff008ae6 Auto Target Finder \124r is \124cffFF0000 DISABLED \124r")
        isTargetFinderActive = false
    end
end

function HasPet()
	return HasPetUI()
end

function IsPetAlive()
	return HasPet() and UnitIsDead( "pet" )
end

function HasTarget()
	return UnitExists("target")
end

function HasEnemyTarget()
	return HasTarget() and UnitCanAttack("player", "target")
end

function TargetAtRange(unit, range)
	if range ~= SHORT_RANGE and range ~= LONG_RANGE or not unit then
		return false
	end
	
	return CheckInteractDistance(unit, range)
end

function InMeleeRange()
	if not HasEnemyTarget() then
		return false
	end

return true
	-- return TargetAtRange("target", SHORT_RANGE)
end

function ListActions()
  local i = 0
  
  for i = 1, 120 do
    local t = GetActionText(i);
    local x = GetActionTexture(i);
    if x then
      local m = "[" .. i .. "] (" .. x .. ")";
      if t then m = m .. " \"" .. t .. "\""; end
      DEFAULT_CHAT_FRAME:AddMessage(m);
    end
  end
end

function ListPetActions()
  local i = 0
  
  for i = 1, 120 do
    local t = GetActionText(i);
    local x = GetActionTexture(i);
    if x then
      local m = "[" .. i .. "] (" .. x .. ")";
      if t then m = m .. " \"" .. t .. "\""; end
      DEFAULT_CHAT_FRAME:AddMessage(m);
    end
  end
end

function AutoTarget()
	if 
		not UnitName("target") or 
		not IsAlive("target") or 
		-- not InMeleeRange() or
		TargetSheeped() or 
		not UnitAffectingCombat("target") and UnitAffectingCombat("player")
		-- or UnitIsPlayer("target") and not UnitIsEnemy("target","player")
	then 
		ClearTarget()
		TargetNearestEnemy()
	end
end

function CanTryToCastSpell(spell)	

	if not SpellExists(spell) then 
		return false
	end
	
	if OnCooldown(spell) then
		return false
	end
	
	return true
end

function Say(text)	
	DEFAULT_CHAT_FRAME:AddMessage(text)
end

function CountDebuffs(unit)
    if not unit then
        unit = 'player'
    end

    local tooltip = SM_Tooltip
    local textleft1 = getglobal(tooltip:GetName().."TextLeft1")

    local i = 1
    local debuffCount = 0
    while true do
        tooltip:SetOwner(UIParent, "ANCHOR_NONE")
        tooltip:SetUnitDebuff(unit, i)

        local debuffName = textleft1:GetText()
        tooltip:Hide()

        if debuffName then
            debuffCount = debuffCount + 1
        else
            break
        end
        i = i + 1
    end
	-- Say(debuffCount)
    return debuffCount
end

function Attack()
	if not TargetSheeped() and InMeleeRange() then
		if not IsCurrentAction(61) then UseAction(61) end
	elseif IsCurrentAction(AUTO_ATTACK) then UseAction(AUTO_ATTACK)
	end
end

---------- LIBRARY/end ----------

---------- WARRIOR ----------

-- Check if Overpower should be cast
local function ShouldCastOverpower()
	local currentTime = GetTime()
	return currentTime >= lastDodgeTime and 
		   currentTime <= lastDodgeTime + 4 and 
		   currentTime >= overpowerCooldownEndTime
end

function warrior_PVP()
	if PVP() then
		--use Disarm on weapon classes who are swinging at me
		if not OnCooldown("Disarm") and not buffed("Disarm","target") and IAmTarget() and MyRage() >= 20 and TargetHealthPct() > 0.2 and (UnitClass("target")=="Rogue" or UnitClass("target")=="Warrior" or UnitClass("target")=="Paladin") then
			if MyStance() ~= 2 then
				if MyRage() > 25 then
					if MyStance() == 1 or MyStance() == 3 then DotCast("Hamstring") end
					if MyStance() == 1 then DotCast("Rend") end
					if not OnCooldown("Mortal Strike") then cast("Mortal Strike")
					elseif not OnCooldown("Bloodthirst") then cast("Bloodthirst")
					end
					cast("Heroic Strike")
				end
				if MyRage() <= 25 then SpellStopCasting() SelfBuff("Defensive Stance") end
			end
			if MyStance() == 2 then
				if not OnCooldown("Bloodrage") then SelfBuff("Bloodrage") end
				cast("Disarm")
			end
		end
		--reapply Hamstring and Rend when they fall off
		if not buffed("Hamstring","target") and TargetHealthPct() > 0.2 and MyRage() >= 10 then
			if MyStance() == 2 and tactical == 5 then
				if MyRage() > 25 then
					if not OnCooldown("Disarm") then cast("Disarm") end
					DotCast("Rend")
					if not OnCooldown("Shield Slam") then cast("Shield Slam")
					elseif not OnCooldown("Mortal Strike") then cast("Mortal Strike")
					elseif not OnCooldown("Bloodthirst") then cast("Bloodthirst")					
					end
					cast("Heroic Strike")
				end
				if MyRage() <= 25 then SpellStopCasting() SelfBuff("Battle Stance") end
			end
			if MyStance() == 1 or MyStance() == 3 then cast("Hamstring") end
		end
		if not buffed("Rend","target") and buffed("Hamstring","target") and TargetHealthPct() > 0.2 and MyRage() >= 10 then
			if MyStance() == 3 and MyRole == 2 and tactical == 5 then
				if MyRage() > 25 then
					if not OnCooldown("Mortal Strike") then cast("Mortal Strike")
					elseif not OnCooldown("Bloodthirst") then cast("Bloodthirst")
					end
					cast("Heroic Strike")
				end
				if MyRage() <= 25 then SpellStopCasting() SelfBuff("Defensive Stance") end
			end
			if MyStance() == 3 and MyRole ~= 2 and tactical == 5 then
				if MyRage() > 25 then
					if not OnCooldown("Mortal Strike") then cast("Mortal Strike")
					elseif not OnCooldown("Bloodthirst") then cast("Bloodthirst")
					end
					cast("Heroic Strike")
				end
				if MyRage() <= 25 then SpellStopCasting() SelfBuff("Battle Stance") end
			end
			if (MyStance() == 1 or MyStance() == 2) then cast("Rend") end
		end
		--use Mortal Strike on cooldown
		if not OnCooldown("Mortal Strike") then cast("Mortal Strike") end
	end
end

function warrior_interrupt()
	--interrupt enemy spellcasting
	if InMeleeRange() and InCombat("player") and InCombat("target") then
		--use Shield Bash if in Battle or Defensive Stance
		if CanTryToCastSpell("Shield Bash") and MyStance() ~= 3 and MyRage() >= 10 then UnsilencedCast("Shield Bash") end
		--use Pummel if in Berserker Stance
		if CanTryToCastSpell("Pummel") and MyStance() == 3 and MyRage() >= 10 then UnsilencedCast("Pummel") end
		--use Concussion Blow when possible
		if CanTryToCastSpell("Concussion Blow") and MyRage() >= 15 then UnsilencedCast("Concussion Blow") end
	end
end

function warrior_auto_taunt()
	if not OnCooldown("Taunt") then
		if MyStance() ~= 2 then
			SpellStopCasting() 
			SelfBuff("Defensive Stance")
		end
		if MyStance() == 2 then cast("Taunt") end
	end
end

function warrior_disarm()
	if UnitName("target") and InMeleeRange() and InCombat("player") and TargetInCombat("player") then
		if MyStance() ~= 2 then SelfBuff("Defensive Stance") end
		if MyStance() == 2 then
			if not OnCooldown("Bloodrage") then SelfBuff("Bloodrage") end
			if MyRage() >= 20 then cast("Disarm") end
		end
	end
	--start auto attack
	if not TargetSheeped() then
		if not IsCurrentAction(AUTO_ATTACK) then UseAction(AUTO_ATTACK) end
	elseif IsCurrentAction(AUTO_ATTACK) then UseAction(AUTO_ATTACK)
	end
end

function warrior_charge()
	--if Control Key is not held then use Charge and Interception, otherwise shoot
	if not IsControlKeyDown() then
		if CanTryToCastSpell("Charge") and not InCombat("player") and not OnCooldown("Charge") then
			if MyStance() ~= 1 and MyRage() <= 25 then SelfBuff("Battle Stance") end
			if MyStance() == 1 then cast("Charge") end
		end
		--in all the situations when Charge cannot be used, use Intercept when available
		if ((OnCooldown("Charge") and not InCombat("player")) 
		or (CooldownTime("Charge")>2 and InCombat("player")) 
		or (not OnCooldown("Charge") and MyStance() ~= 1 and MyRage()>25) 
		or (not OnCooldown("Charge") and InCombat("player") )) and not InMeleeRange() and not OnCooldown("Intercept") and MyRage()>=10 then
			if MyStance() ~= 3 and MyRage() <= 25 then SelfBuff("Berserker Stance") end
			if MyStance() == 3 then
				if MyRage() < 10 then SelfBuff("Berserker Rage") end
				cast("Intercept")
			end
		end
	else cast("Shoot Bow") cast("Shoot Crossbow") cast("Shoot Gun")
	end
end

function shoot()
	cast("Shoot Bow") cast("Shoot Crossbow") cast("Shoot Gun")
end

function warrior_boost()
	if not OnCooldown("Death Wish") then cast("Death Wish") end
	if OnCooldown("Death Wish") then
		RunLine("/use Eternal Mighty Rage Potion")
		if not OnCooldown("Recklessness") then cast("Recklessness") end
	end
end

function warrior_brage()
	if not OnCooldown("Berserker Rage") and MyRage() == 0 and not buffed("Berserker Rage","player") then
		SelfBuff("Berserker Stance")
		SelfBuff("Berserker Rage")
	end
	SelfBuff("Defensive Stance")
end

function RockbiterWeapon()
	has_enchant_main,mx,mc,has_enchant_off = GetWeaponEnchantInfo()
	if not has_enchant_main then
		cast("Rockbiter Weapon")
		RunLine("/use 16")
	end
end

function DumpRage()
	cast("Heroic Strike")
	if CanTryToCastSpell("Bloodthirst") then cast("Bloodthirst") end
	if MyStance() == 3 and CanTryToCastSpell("Whirlwind") then cast("Whirlwind") end
	SelfBuff("Battle Shout")
	if MyRole == 2 then	
		DeBuff("Demoralizing Shout")		
		if CanTryToCastSpell("Sunder Armor") then cast("Sunder Armor") end
	end
	if CanTryToCastSpell("Hamstring") then cast("Hamstring") end
end

function warrior_single()
	if not rotation then rotation = true
		--equip Auto Attack on Action Slot
		init()
		--check for relevant talents
		_,_,_,_,flurry=GetTalentInfo(2,16)
		_,_,_,_,tactical=GetTalentInfo(1,5)
		function multi_Disable()
			multi_enabled = false
			Say("\124cff008ae6Multi-Target \124r Rotation \124cffFF0000 Disabled \124r")
		end
		
		---------- WARRIOR - Single Target ----------
		function Rotation()				
			-- Don't execute any logic while taxi flying
			if UnitOnTaxi("player") then return end				
			-- Don't interrupt ongoing casts
			if IsNonMeleeSpellCasted() then return end			
			-- dispel undesirables
			if buffed("Slip'kik's Savvy") then CancelBuff("Slip'kik's Savvy") end
			
			---------- WARRIOR COMMON ROTATION ----------
			if InMeleeRange() and InCombat("player") and InCombat("target") then
				--defensive spells
				if MyHealthPct() < 0.25 then
					if CanTryToCastSpell("Last Stand") then cast("Last Stand") end
					RunLine("/use Major Healthstone")
					RunLine("/use Major Healing Potion")
				end
				--use Berserker Rage when low on rage
				if MyRage() < 10 and CanTryToCastSpell("Berserker Rage") and SpellExists("Berserker Stance") then
					if MyStance() ~= 3 then	
						if MyRage() <= 25 then SpellStopCasting() SelfBuff("Berserker Stance") end
						if MyRage() > 25 then DumpRage() end	
					else
						SelfBuff("Berserker Rage")				
					end	
				end
				--keep Battle Shout up
				if MyRage() >= 10 then SelfBuff("Battle Shout")	end
			end
			
			---------- WARRIOR LEVELING ROTATION ----------
			if MyLevel() < 60 then
				if UnitName("target") and InMeleeRange() and InCombat("player") and InCombat("target") then
					--keep Bleed up on all targets except mechanical
					if MyRage() >= 15 and not buffed("Rend","target") and MyStance() == 1 and not PVP() and TargetHealthPct() > 0.75 and (UnitCreatureType("target") ~= "Mechanical" or UnitCreatureType("target") ~= "Elemental") then
						if MyStance() == 1 then DotCast("Rend") end
					end
					--use Bloodrage on cooldown
					if MyRage() < 30 and CanTryToCastSpell("Bloodrage") then cast("Bloodrage") end
					-- cast OP on cooldown
					if MyRage() >= 5 and CanTryToCastSpell("Overpower") and ShouldCastOverpower() then cast("Overpower") end
					--cast Execute whenever possible
					if MyRage() >= 10 and CanTryToCastSpell("Execute") and TargetHealthPct() < 0.2 then cast("Execute") end	
					--be a good team player and debuff bosses for armor
					if MyRage() >= 15 and CanTryToCastSpell("Sunder Armor") then 
						if boss("target") or TargetHealthPct() >= 0.5 then
							StackCast("Sunder Armor",5)
						end
					end
					--dump rage with Heroic Strike
					if MyRage() >= 30 then 					
						if MyMode == nil or MyMode == 1 then
							cast("Heroic Strike")
						else
							cast("Cleave")
						end
					elseif IsCurrentAction(HEROIC_STRIKE) or IsCurrentAction(CLEAVE) then
						SpellStopCasting()
					end
					--dump rage with Hamstring
					if MyRage() >= 100 then cast("Hamstring") end
				end		
				
				-- start attacking the enemy
				Attack()
				
				return -- don't execute any further
			end
			
			---------- WARRIOR TANK ROTATION ----------
			if MyRole == 2 then
				-- dispel undesirables
				if buffed("Greater Blessing of Salvation") then CancelBuff("Greater Blessing of Salvation") end
				-- only use abilitites if I'm in combat and in melee range
				if InCombat("player") and InCombat("target") then				
					--keep Stoneshield Potion up
					if boss("target") and UnitIsUnit("targettarget", "player") then
						if not buffed("Greater Stoneshield","player") then RunLine("/use Eternal Greater Stoneshield Potion") end
						if MyHealthPct() < 0.25 and not buffed("Glyph of Deflection","player") then RunLine("/use Glyph of Deflection") end
					end
					--cast Execute on bosses
					if TargetHealthPct() < 0.2 and boss("target") then
						if CanTryToCastSpell("Bloodthirst") and MyAttackPower() >= 2000 and MyRage() >= 30 then cast("Bloodthirst") end
						if CanTryToCastSpell("Execute") then
							if MyStance() ~= 1 then
								if MyRage() <= 25 then SpellStopCasting() SelfBuff("Battle Stance") end
								if MyRage() > 25 then DumpRage() end	
							else
								if MyRage() >= 10 and CanTryToCastSpell("Execute") then cast("Execute") end
								return
							end
						end
						return
					end
					--PVE Defensive Rotation
					if MyStance() == 2 then			
						--use Bloodrage for rage generation
						if CanTryToCastSpell("Bloodrage") and MyHealthPct() > 0.2 and MyRage() < 30 then SelfBuff("Bloodrage") end
						--be a good team player and debuff bosses for armor
						if CanTryToCastSpell("Sunder Armor") and CountDebuffs("target") <= 8 and (TargetHealthPct() > 0.5 or boss("target")) then StackCast("Sunder Armor",5) end	
						--debuff enemies
						if CountDebuffs("target") <= 8 then DeBuff("Demoralizing Shout") end	
						--raid power items
						if GetNumRaidMembers() <= 10 or boss("target") then 
							--use trinkets
							RunLine("/use Kiss of the Spider") 
							RunLine("/use Slayer's Crest") 
							--Death Wish for big threat
							if MyRage() >= 10 and CanTryToCastSpell("Death Wish") and MyHealthPct() > 0.5 then SelfBuff("Death Wish") end							
						end
						--Shield Block is top priority
						if MyRage() >= 40 and MyStance() == 2 and CanTryToCastSpell("Shield Block") and UnitName("targettarget") and UnitName("targettarget") == UnitName("player") then cast("Shield Block") end
						--after all other debuffs have been used then cast Shield Slam on cooldown
						if MyRage() >= 30 and CanTryToCastSpell("Bloodthirst") then cast("Bloodthirst") end
						--cast Revenge whenever possible
						if MyRage() >= 5 and MyStance() == 2 and CanTryToCastSpell("Revenge") then cast("Revenge") end
						--dump rage with Heroic Strike
						if MyMode == nil or MyMode == 1 then
							if MyRage() >= 65 then cast("Heroic Strike") end
						else
							if MyRage() >= 65 then cast("Cleave") end
						end
						--dump rage with Hamstring
						if MyRage() >= 100 then cast("Hamstring") end
					--rage dump stance dance to Defensive Stance
					else
						if MyRage() <= 25 then SpellStopCasting() SelfBuff("Defensive Stance") end
						if MyRage() > 25 then DumpRage() end					
					end									
				end
			end
			---------- WARRIOR TANK ROTATION/end ----------
			
			---------- WARRIOR Fury DPS ROTATION ----------
			if MyRole == 1 or MyRole == nil then
				if InMeleeRange() and InCombat("player") and InCombat("target") then
					--Berserker Stance Rotation
					if MyStance() == 3 then
						--raid power items
						if GetNumRaidMembers() <= 10 or boss("target") then 
							--use trinkets
							RunLine("/use Kiss of the Spider") 
							RunLine("/use Slayer's Crest") 
							--Eternal Mighty Rage Potion
							if MyRage() <= 25 then RunLine("/use Eternal Mighty Rage Potion") end		
							--Death Wish for big threat
							if MyRage() >= 10 and CanTryToCastSpell("Death Wish") and MyHealthPct() > 0.5 then SelfBuff("Death Wish") end						
						end
						--use Bloodrage on cooldown
						if MyRage() < 30 and CanTryToCastSpell("Bloodrage")then cast("Bloodrage") end
						--cast Execute whenever possible
						if MyRage() >= 10 and CanTryToCastSpell("Execute") and TargetHealthPct() < 0.2 then cast("Execute") end
						--cast Bloodthirst on cooldown
						if MyRage() >= 30 and CanTryToCastSpell("Bloodthirst") then cast("Bloodthirst") end
						--cast Whirlwind only if Bloodthirst is on cooldown
						if MyRage() >= 55 and CanTryToCastSpell("Whirlwind") then cast("Whirlwind") end
						--dump rage with Heroic Strike
						if MyMode == nil or MyMode == 1 then
							if MyRage() >= 75 then cast("Heroic Strike") end
						else
							if MyRage() >= 75 then cast("Cleave") end
						end
						--dump rage with Hamstring
						if MyRage() >= 100 then cast("Hamstring") end
						--Enter Berserker Stance
					else
						if MyRage() <= 25 then SpellStopCasting() SelfBuff("Berserker Stance") end
						if MyRage() > 25 then DumpRage() end
					end
				end
			end
			---------- WARRIOR Fury DPS ROTATION/end ----------
			
			---------- WARRIOR Slam DPS ROTATION ----------
			if MyRole == 3 then
				if UnitName("target") and InMeleeRange() and InCombat("player") and InCombat("target") then
					--keep Bleed up on all targets except mechanical
					if not buffed("Rend","target") and MyStance() == 1 and not PVP() and TargetHealthPct() > 0.75 and (UnitCreatureType("target") ~= "Mechanical" or UnitCreatureType("target") ~= "Elemental") and MyRage() >= 15 then
						if MyStance() == 1 then DotCast("Rend") end
					end
					--Berserker Stance Rotation
					if MyStance() == 3 then						
						--use Bloodrage on cooldown
						if not OnCooldown("Bloodrage") and MyRage() < 30 then cast("Bloodrage") end
						--keep Battle Shout up
						SelfBuff("Battle Shout")
						--be a good team player and debuff bosses for armor
						if not OnCooldown("Sunder Armor") and boss("target") then StackCast("Sunder Armor",5) end
						--use Death Wish against elites
						if not OnCooldown("Death Wish") and (eliteplus("target") or PVP()) then cast("Death Wish") end											
						--use Recklessness against bosses
						if not OnCooldown("Recklessness") and (boss("target") and TargetHealthPct() < 0.2 or PVP()) then cast("Recklessness") end
						--cast Execute whenever possible
						if not OnCooldown("Execute") and TargetHealthPct() < 0.2 and (eliteplus("target") or PVP()) then cast("Execute") end
						--cast Bloodthirst on cooldown
						if not OnCooldown("Bloodthirst") then cast("Bloodthirst") end
						--cast Whirlwind only if Bloodthirst is on cooldown
						if not OnCooldown("Whirlwind") and OnCooldown("Bloodthirst") then cast("Whirlwind") end
						--dump rage with Slam
						if MyRage() > 55 and st_timer > GetWeaponSpeed() * 0.5 then cast("Slam") end
						--dump rage with Hamstring
						if MyRage() >= 70 and flurry > 0 and not buffed("Flurry","player") then cast("Hamstring") end
					else --Enter Berserker Stance
						if MyRage() <= 25 then SpellStopCasting() SelfBuff("Berserker Stance") end
						if MyRage() > 25 then
							if not OnCooldown("Bloodthirst") then cast("Bloodthirst") end
							if st_timer > GetWeaponSpeed() * 0.5 then cast("Slam") end
							cast("Hamstring")
						end
					end
				end
			end
			---------- WARRIOR Slam DPS ROTATION/end ----------
			
			--start auto attack
			Attack()
		end
		---------- /WARRIOR - Single Target ----------
		
		--Create a frame to constantly run the main Rotation
		enabled = false
		local elapsed = 0
		local script_use_rate = 10 --This value determines how fast the Rotation will be triggered. Lower the value to trigger faster, but not recommended.
		frame = CreateFrame("Frame", nil, UIParent)
		frame:SetScript("OnUpdate", function()
			elapsed = elapsed + 1
			if enabled and elapsed > script_use_rate then
				Rotation()
				elapsed = 0
			end
		end)
	end
	--Script control. Press once to enable/disable. Hold Control + press to enable DPS Rotation or Hold Shift + press to enable Tank Rotation.
	if not IsControlKeyDown() and not IsShiftKeyDown() and not IsAltKeyDown() then
		-- Enable the Rotation
		function Disable()
			SpellStopCasting()
			enabled = false
			if IsCurrentAction(AUTO_ATTACK) then UseAction(AUTO_ATTACK) end
			frame:Hide()
			rotation = nil
			Say("\124cffffcc66Single-Target \124r Rotation \124cffFF0000 Disabled \124r")
		end
		-- Disable the Rotation
		function Enable()
			enabled = true
			Say("\124cffffcc66Single-Target \124r Rotation \124cff00FF00 Enabled \124r")
		end
		-- Script Control
		if enabled then
			Disable()
		else
			if multi_enabled then multi_Disable() end
			Enable()
		end
	end
	
	if IsControlKeyDown() then Say("\124cffffcc66Single-Target\124r - \124cffe65c00DPS\124r - Rotation") MyRole = 1 end --DPS Rotation
	if IsShiftKeyDown() then Say("\124cffffcc66Single-Target\124r - \124cff996633Tank\124r - Rotation") MyRole = 2 end --Tank Rotation	
	if IsAltKeyDown() then 
		if MyMode == nil or MyMode == 1 then
			Say("Use - \124cff008ae6Cleave\124r") MyMode = 2
		else
			Say("Use - \124cffffcc66Heroic Strike\124r") MyMode = 1
		end
	end
end

---------- WARRIOR/end ----------

---------- PALADIN ----------

function HasSealActive(type)
	if type == "damage" then
		if 
			buffed("Seal of Command","player") or
			buffed("Seal of the Crusader","player") or
			buffed("Seal of Righteousness","player") 
		then
			return true
		end
	elseif type == "utility" then	
		if 
			buffed("Seal of Wisdom","player") or
			buffed("Seal of Light","player") 
		then
			return true
		end
	end
	
	return false
end

function paladin_single()
	if not rotation then rotation = true
		--equip Auto Attack on Action Slot
		init()
		---------- PALADIN - Single Target ----------
		function Rotation()
			--- Auto TARGET ---
			AutoTarget()
			--defensive spells
			if HasEnemyTarget() and InCombat("player") and InCombat("target") and MyHealthPct() < 0.1 then
				if CanTryToCastSpell("Divine Protection") and not buffed("Forbearance","player") then
					SelfBuff("Divine Protection")
				end
				if CanTryToCastSpell("Lay on Hands") then
					SelfBuff("Lay on Hands")
				end
			end
			---------- PALADIN DPS ROTATION ----------
			if MyRole ~= 2 then			
				-- Don't execute any logic while taxi flying
				if UnitOnTaxi("player") then return end				
				-- Don't interrupt ongoing casts
				if IsNonMeleeSpellCasted() then return end			
				--Keep Seal of Command or Righteousness up
				if CanTryToCastSpell("Seal of Command") then
					if MyManaPct() < 0.5 then
						if not buffed("Seal of Command","player") then	
							SelfBuff("Seal of Command(Rank 1)")
						end
					else
						SelfBuff("Seal of Command")						
					end
				elseif CanTryToCastSpell("Seal of Righteousness") then
					if MyManaPct() < 0.5 then
						if not buffed("Seal of Righteousness","player") then	
							SelfBuff("Seal of Righteousness(Rank 1)")
						end
					else
						SelfBuff("Seal of Righteousness")						
					end
				end				
				--only use abilitites if I'm in combat and in melee range
				if InMeleeRange() and InCombat("player") and InCombat("target") then				
					--Judge on cooldown for dps
					if MyManaPct() > 0.2 and HasSealActive("damage") and CanTryToCastSpell("Judgement") then cast("Judgement") end					
					--Hammer of Justice finisher
					if CanTryToCastSpell("Hammer of Wrath") and TargetHealthPct() < 0.2 and (eliteplus("target") or PVP()) then cast("Hammer of Wrath") end					
					--Use Exorcism on undeads and demons
					if CanTryToCastSpell("Exorcism") and (UnitCreatureType("target") == "Undead" or UnitCreatureType("target") == "Demon") then cast("Exorcism") end
				end				
				-- decursing logic
				Decurse()				
				-- buffing logic
				RaidBuff("Blessing of Kings")				
			end
			---------- PALADIN DPS ROTATION/end ----------
			--start auto attack
			if not TargetSheeped() and InMeleeRange() then
				if not IsCurrentAction(61) then UseAction(61) end
			elseif IsCurrentAction(AUTO_ATTACK) then UseAction(AUTO_ATTACK)
			end
		end
		---------- /PALADIN - Single Target ----------		
		--Create a frame to constantly run the main Rotation
		enabled = false
		local elapsed = 0
		local script_use_rate = 100 --This value determines how fast the Rotation will be triggered. Lower the value to trigger faster, but not recommended.
		frame = CreateFrame("Frame", nil, UIParent)
		frame:SetScript("OnUpdate", function()
			elapsed = elapsed + 1
			if enabled and elapsed > script_use_rate then
				Rotation()
				elapsed = 0
			end
		end)
	end
	--Script control. Press once to enable/disable. Hold Control + press to enable DPS Rotation or Hold Shift + press to enable Tank Rotation.
	if not IsControlKeyDown() and not IsShiftKeyDown() then
		-- Enable the Rotation
		function Disable()
			enabled = false
			if IsCurrentAction(AUTO_ATTACK) then UseAction(AUTO_ATTACK) end
			frame:Hide()
			rotation = nil
			DEFAULT_CHAT_FRAME:AddMessage("\124cffffcc66Single-Target \124r Rotation \124cffFF0000 Disabled \124r")
		end
		-- Disable the Rotation
		function Enable()
			enabled = true
			DEFAULT_CHAT_FRAME:AddMessage("\124cffffcc66Single-Target \124r Rotation \124cff00FF00 Enabled \124r")
		end
		-- Script Control
		if enabled then
			Disable()
		else
			if multi_enabled then multi_Disable() end
			Enable()
		end
	end
	if IsControlKeyDown() then DEFAULT_CHAT_FRAME:AddMessage("\124cffffcc66Single-Target\124r - \124cffe65c00DPS\124r - Rotation") MyRole = 1 end --DPS Rotation
	if IsShiftKeyDown() then DEFAULT_CHAT_FRAME:AddMessage("\124cffffcc66Single-Target\124r - \124cff996633Tank\124r - Rotation") MyRole = 2 end --Tank Rotation
end

---------- PALADIN/end ----------

---------- SHAMAN ----------
function shaman_single()
	if not rotation then rotation = true
		--equip Auto Attack on Action Slot
		init()
		function multi_Disable()
			multi_enabled = false
			RunLine("/print '\124cff008ae6 Multi-Target \124r Rotation \124cffFF0000 Disabled \124r'")
		end
		---------- SHAMAN - Single Target ----------
		function Rotation()
			--- Auto TARGET ---
			AutoTarget()
			--defensive spells
			if UnitName("target") and InMeleeRange() and InCombat("player") and TargetInCombat("player") then
				--Healthstones
				if MyHealthPct() < 0.3 then RunLine("/use Major Healthstone") end
				if MyHealthPct() < 0.3 then RunLine("/use Greater Healthstone") end
				if MyHealthPct() < 0.3 then RunLine("/use Healthstone") end
				if MyHealthPct() < 0.3 then RunLine("/use Lesser Healthstone") end
				if MyHealthPct() < 0.3 then RunLine("/use Minor Healthstone") end
				--Healing Potions
				if MyHealthPct() < 0.3 then RunLine("/use Major Healing Potion") end
				if MyHealthPct() < 0.3 then RunLine("/use Greater Healing Potion") end
				if MyHealthPct() < 0.3 then RunLine("/use Healing Potion") end
				if MyHealthPct() < 0.3 then RunLine("/use Lesser Healing Potion") end
				if MyHealthPct() < 0.3 then RunLine("/use Minor Healing Potion") end
			end			
			---------- SHAMAN TANK ROTATION ----------
			if MyRole == 2 or MyRole == nil then
				--Dispel Salvation if it was accidentaly applied to us
				if buffed("Greater Blessing of Salvation") then CancelBuff("Greater Blessing of Salvation") end
				--Rockbiter Weapon is essential for tanking
				if not OnCooldownGCD("Rockbiter Weapon") then RockbiterWeapon() end				
				--- Auto TAUNT ---
				if Mode ~= 2 and UnitName("target") and UnitName("targettarget") and UnitName("targettarget") ~= UnitName("player") and UnitAffectingCombat("target") and not UnitIsPlayer("target") and UnitIsEnemy("player","target") then cast("Earth Shock") end	
				--only use abilitites if I'm in combat and in melee range
				if UnitName("target") and InMeleeRange() and InCombat("player") and TargetInCombat("player") then
					--if not buffed("Stoneskin","player") then SelfBuff("Stoneskin Totem") end
				end
				--Lightning Shield is an efficient damaging spell, just not a priority
				if not OnCooldownGCD("Lightning Shield") then SelfBuff("Lightning Shield") end
			end
			---------- SHAMAN TANK ROTATION/end ----------
			--start auto attack
			if not TargetSheeped() and InMeleeRange() then
				if not IsCurrentAction(AUTO_ATTACK) then UseAction(AUTO_ATTACK) end
			elseif IsCurrentAction(AUTO_ATTACK) then UseAction(AUTO_ATTACK)
			end
		end
		---------- /SHAMAN - Single Target ----------
		--Create a frame to constantly run the main Rotation
		enabled = false
		local elapsed = 0
		local script_use_rate = 10 --This value determines how fast the Rotation will be triggered. Lower the value to trigger faster, but not recommended.
		frame = CreateFrame("Frame", nil, UIParent)
		frame:SetScript("OnUpdate", function()
			elapsed = elapsed + 1
			if enabled and elapsed > script_use_rate then
				Rotation()
				elapsed = 0
			end
		end)
	end
	--Script control. Press once to enable/disable. Hold Control + press to enable DPS Rotation or Hold Shift + press to enable Tank Rotation.
	if not IsControlKeyDown() and not IsShiftKeyDown() and not IsAltKeyDown() then
		-- Enable the Rotation
		function Disable()
			SpellStopCasting()
			enabled = false
			if IsCurrentAction(AUTO_ATTACK) then UseAction(AUTO_ATTACK) end
			frame:Hide()
			rotation = nil
			-- RunLine("/print --------------------")
			RunLine("/print '\124cffffcc66 Single-Target \124r Rotation \124cffFF0000 Disabled \124r'")
		end
		-- Disable the Rotation
		function Enable()
			enabled = true
			-- RunLine("/print ++++++++++++++++++++")
			RunLine("/print '\124cffffcc66 Single-Target \124r Rotation \124cff00FF00 Enabled \124r'")
		end
		-- Script Control
		if enabled then
			Disable()
		else
			if multi_enabled then multi_Disable() end
			Enable()
		end
	end
	if IsControlKeyDown() then RunLine("/print '\124cffffcc66 Mode\124r - \124cffe65c00Automatic\124r - Rotation'") Mode = 1 end --Automatic Mode
	if IsAltKeyDown() then RunLine("/print '\124cffffcc66 Mode\124r - \124cffe65c00Manual\124r - Rotation'") Mode = 2 end --Manual Mode
end
---------- SHAMAN/end ----------

---------- PRIEST ----------
function priest_single()
	if not rotation then rotation = true
		function multi_Disable()
			multi_enabled = false
			RunLine("/print \124cff008ae6 Multi-Target \124r Rotation \124cffFF0000 Disabled \124r")
		end
		---------- PRIEST - Single Target ----------
		function Rotation()
			Fade()
			Decurse()
			-- SelfBuff("Inner Fire")
			if InCombat("player") then 
				if MyHealthPct()<.25 then 
					RunLine("/use Major Healthstone")
					RunLine("/use Major Healing Potion")
					CastSpellByName("Desperate Prayer",1) 
				end
				if MyManaPct()<.25 then 
					RunLine("/use Major Mana Potion")
					if MyHealth() > 2000 then RunLine("/use Demonic Rune") end
				end
			end
		end
		---------- /PRIEST - Single Target ----------		
		--Create a frame to constantly run the main Rotation
		enabled = false
		local elapsed = 0
		local script_use_rate = 100 --This value determines how fast the Rotation will be triggered. Lower the value to trigger faster, but not recommended.
		frame = CreateFrame("Frame", nil, UIParent)
		frame:SetScript("OnUpdate", function()
			elapsed = elapsed + 1
			if enabled and elapsed > script_use_rate then
				Rotation()
				elapsed = 0
			end
		end)
	end
	--Script control. Press once to enable/disable. Hold Control + press to enable DPS Rotation or Hold Shift + press to enable Tank Rotation.
	if not IsControlKeyDown() and not IsShiftKeyDown() then
		-- Enable the Rotation
		function Disable()
			enabled = false
			if IsCurrentAction(AUTO_ATTACK) then UseAction(AUTO_ATTACK) end
			frame:Hide()
			rotation = nil
			-- RunLine("/print --------------------")
			RunLine("/print \124cffffcc66 Single-Target \124r Rotation \124cffFF0000 Disabled \124r")
		end
		-- Disable the Rotation
		function Enable()
			enabled = true
			-- RunLine("/print ++++++++++++++++++++")
			RunLine("/print \124cffffcc66 Single-Target \124r Rotation \124cff00FF00 Enabled \124r")
		end
		-- Script Control
		if enabled then
			Disable()
		else
			if multi_enabled then multi_Disable() end
			Enable()
		end
	end
	-- if IsControlKeyDown() then RunLine("/print '\124cffffcc66 Single-Target\124r - \124cffe65c00DPS\124r - Rotation'") MyRole = 1 end --DPS Rotation
	-- if IsShiftKeyDown() then RunLine("/print '\124cffffcc66 Single-Target\124r - \124cff996633Tank\124r - Rotation'") MyRole = 2 end --Tank Rotation
end

function priest_boost()
	-- if InCombat("player") then
		CombatUse(13)
		CombatUse(14)
		CastSpellByName("Power Infusion",1)
		CastSpellByName("Inner Focus",1)
		RunLine("/print \124cffffcc66 BOOST\124r")
	-- end
end
---------- PRIEST/end ----------

function cometome()
	if GetNumPartyMembers()==0 then return end
	local n=GetNumPartyMembers()
	r=math.random(n)-1
	if n>0 then
		for i=1,n do
			j=i+r
			if j>n then j=j-n end			
			if UnitClass("party"..j) == "Mage" then	
				TargetUnit("party"..j)
			end	
			if UnitName("target") and UnitClass("party"..j) == "Mage" then	
				RunLine(".partybot cometome")
			end	
		end
	end
end

-- create a table to store your auras
local auras = {
    "devotion aura",
    "retribution aura",
    "concentration aura",
    "shadow resistance aura",
    "frost resistance aura",
    "fire resistance aura"
}
local numAuras = 6  -- store the number of auras manually
local currentIndex = 0  -- this variable will track our current position in the list of auras
function Auras()
    if UnitExists("target") then
        -- adjust the index based on whether or not the CTRL key is down
        if IsControlKeyDown() then
            -- CTRL is down, go backwards
            currentIndex = currentIndex - 1
            
            -- if we're at the beginning of the list, wrap around to the end
            if currentIndex < 1 then
                currentIndex = numAuras
            end		
        else
            -- no modifier, go forwards
            currentIndex = currentIndex + 1
            
            -- if we're at the end of the list, wrap around to the beginning
            if currentIndex > numAuras then
                currentIndex = 1
            end
        end
			
		-- use the current index to get the correct aura
		local aura = auras[currentIndex]
		
		-- send the whisper
		SendChatMessage("set aura " .. aura, "WHISPER", nil, UnitName("target"))	
    end
end

function CompanionBuffMe(class, buff)
    if buffed(buff,"player") then return end
    TargetUnit("player")
    if UnitName("target") ~= UnitName("player") then return end
    if GetNumPartyMembers() == 0 then return end
    local n=GetNumPartyMembers()
    local timer = 0
    IndicatorFrame = CreateFrame("Frame",nil,UIParent)
    IndicatorFrame:SetScript("OnUpdate", function()
        timer = timer + 1
        if (timer == 100) then 
            for i=1,n do
                if UnitName("party"..i) and IsAlive("party"..i) and CheckInteractDistance("party"..i, 4) and UnitClass("party"..i) == class then
                    SendChatMessage("cast "..buff,WHISPER,nil,UnitName("party"..i))
                end
            end
        end 
        if (timer >= 200) then IndicatorFrame:SetScript("OnUpdate", nil) end        
    end)
end

function CompanionSetRole()
    TargetUnit("target")
    local timer = 0
    IndicatorFrame = CreateFrame("Frame",nil,UIParent)
    IndicatorFrame:SetScript("OnUpdate", function()
        timer = timer + 1
        if (timer == 100) then 
			SendChatMessage(".z set rdps")
			TargetUnit("player")
        end 
        if timer >= 200 and UnitName("target") == UnitName("player") then 			
			TargetLastEnemy();
			IndicatorFrame:SetScript("OnUpdate", nil) 				
		end        
    end)
end

function Blacklist()
	if UnitName("target") == nil then return end
	local timer = 0
	IndicatorFrame = CreateFrame("Frame",nil,UIParent)
	IndicatorFrame:SetScript("OnUpdate", function()
		if (timer == 0) then 
			SendChatMessage("deny add Flamestrike", "WHISPER", "COMMON", UnitName("target"))
		end 	
		if (timer == 200) then 
			SendChatMessage("deny add Frostbolt", "WHISPER", "COMMON", UnitName("target"))
		end 	
		if (timer == 400) then 
			SendChatMessage("deny add Fireball", "WHISPER", "COMMON", UnitName("target"))
		end 	
		if (timer == 600) then 
			SendChatMessage("deny add Blizzard", "WHISPER", "COMMON", UnitName("target"))
		end 	
		if (timer == 800) then 
			SendChatMessage("deny add Cone of Cold", "WHISPER", "COMMON", UnitName("target"))
		end 		
		timer = timer + 1
		if (timer >= 1000) then IndicatorFrame:SetScript("OnUpdate", nil) end		
	end)
end

function HireCompanions()
	local timer = 0
	IndicatorFrame = CreateFrame("Frame",nil,UIParent)
	IndicatorFrame:SetScript("OnUpdate", function()
		if (timer == 200) then 
			SendChatMessage(".z add warrior tank")
		end 	
		if (timer == 400) then 
			SendChatMessage(".z add paladin tank")
		end 	
		if (timer == 600) then 
			SendChatMessage(".z add paladin healer")
		end 	
		if (timer == 800) then 
			SendChatMessage(".z add priest healer")
		end 		
		timer = timer + 1
		if (timer >= 1000) then IndicatorFrame:SetScript("OnUpdate", nil) end		
	end)
end

function Pull()
	SendChatMessage(".z start tank")
	SendChatMessage(".z stop dps")	
	local timer = 0
	IndicatorFrame = CreateFrame("Frame",nil,UIParent)
	IndicatorFrame:SetScript("OnUpdate", function()
		if (timer >= 500) then 
			SendChatMessage(".z start dps")
			IndicatorFrame:SetScript("OnUpdate", nil)
		end	
		timer = timer + 1	
	end)
end

function HireCompsParty()
	-- Group 1
	SendChatMessage(".z add warrior tank human")
	SendChatMessage(".z add warrior tank human")
	SendChatMessage(".z add warrior tank human")
	SendChatMessage(".z add warrior tank human")
end

function List(type)
	if type == "buffs" then
	Say("---Buffs---")
	ListBuffs("target")
	end
	if type == "debuffs" then 
	Say("---Debuffs---")
	ListDebuffs("target")
	end
end

function HireCompsRaid()
	-- Group 8
	SendChatMessage(".z add warlock rangedps default gnome")
	SendChatMessage(".z add paladin healer default human")
	SendChatMessage(".z add priest healer default dwarf")
	SendChatMessage(".z add mage rangedps frost gnome")
	
	-- Group 7
	SendChatMessage(".z add warlock rangedps default gnome")
	SendChatMessage(".z add paladin healer default human")
	SendChatMessage(".z add priest healer default dwarf")
	SendChatMessage(".z add mage rangedps frost gnome")
	SendChatMessage(".z add mage rangedps frost gnome")
	
	-- Group 6
	SendChatMessage(".z add warlock rangedps default gnome")
	SendChatMessage(".z add paladin healer default human")
	SendChatMessage(".z add priest healer default dwarf")
	SendChatMessage(".z add mage rangedps frost gnome")
	SendChatMessage(".z add mage rangedps frost gnome")
	
	-- Group 5
	SendChatMessage(".z add warlock rangedps default gnome")
	SendChatMessage(".z add druid healer")
	SendChatMessage(".z add priest healer default dwarf")
	SendChatMessage(".z add mage rangedps frost gnome")
	SendChatMessage(".z add mage rangedps frost gnome")
	
	-- Group 4
	SendChatMessage(".z add warrior meleedps default human")
	SendChatMessage(".z add warrior meleedps default human")
	SendChatMessage(".z add warrior meleedps default human")
	SendChatMessage(".z add warrior meleedps default human")
	SendChatMessage(".z add shaman meleedps")
	
	-- Group 3
	SendChatMessage(".z add rogue meleedps default human")
	SendChatMessage(".z add warrior meleedps default human")
	SendChatMessage(".z add warrior meleedps default human")
	SendChatMessage(".z add warrior meleedps default human")
	SendChatMessage(".z add shaman meleedps")
	
	-- Group 2
	SendChatMessage(".z add warrior tank")
	SendChatMessage(".z add warrior tank")
	SendChatMessage(".z add paladin meleedps")
	SendChatMessage(".z add hunter rangedps default dwarf")
	SendChatMessage(".z add shaman meleedps")
	
	-- Group 1
	SendChatMessage(".z add warrior tank")	
	SendChatMessage(".z add warrior tank")
	SendChatMessage(".z add paladin meleedps")
	SendChatMessage(".z add hunter rangedps default dwarf")
	SendChatMessage(".z add shaman meleedps")
end

function HireCompsZG()
	-- Group 2
	SendChatMessage(".z add druid tank")
	SendChatMessage(".z add warrior meleedps human")
	SendChatMessage(".z add warrior meleedps human")
	SendChatMessage(".z add rogue meleedps human")
	SendChatMessage(".z add hunter rangedps dwarf")
	
	-- Group 3
	SendChatMessage(".z add warlock rangedps gnome")
	SendChatMessage(".z add warlock rangedps gnome")
	SendChatMessage(".z add druid healer")
	SendChatMessage(".z add paladin tank dwarf")
	SendChatMessage(".z add priest healer dwarf")
	
	-- Group 4
	SendChatMessage(".z add mage rangedps gnome")
	SendChatMessage(".z add mage rangedps gnome")
	SendChatMessage(".z add druid rangedps")
	SendChatMessage(".z add paladin healer dwarf")
	SendChatMessage(".z add priest healer dwarf")
end

function Buff_debug_2()
    local timer = 0
    local MyDruidName="Swiftsinger"
    local MyPalName="Jack"
    IndicatorFrame = CreateFrame("Frame",nil,UIParent)
    IndicatorFrame:SetScript("OnUpdate", function()
        if (true) then 
            SendChatMessage("cast Thorns", "WHISPER", nil,MyDruidName);
        end
        if (true) then 
            SendChatMessage("cast Mark of the Wild", "WHISPER", nil,MyDruidName)
        end
        if (true) then 
            SendChatMessage("cast Blessing of Freedom", "WHISPER", nil, MyPalName)
        end
        timer = timer + 1
        if (timer >= 30001) then IndicatorFrame:SetScript("OnUpdate", nil) end
    end)
end

function hm_warrior_single()
	if not rotation then rotation = true
		--equip Auto Attack on Action Slot
		init()
		--check for relevant talents
		_,_,_,_,flurry=GetTalentInfo(2,16)
		_,_,_,_,tactical=GetTalentInfo(1,5)
		function multi_Disable()
			multi_enabled = false
			Say("\124cff008ae6Multi-Target \124r Rotation \124cffFF0000 Disabled \124r")
		end
		
		---------- WARRIOR - Single Target ----------
		function Rotation()				
			-- Don't execute any logic while taxi flying
			if UnitOnTaxi("player") then return end				
			-- Don't interrupt ongoing casts
			if IsNonMeleeSpellCasted() then return end			
			-- dispel undesirables
			if buffed("Slip'kik's Savvy") then CancelBuff("Slip'kik's Savvy") end
			-- dispel undesirables
			if buffed("Greater Blessing of Salvation") then CancelBuff("Greater Blessing of Salvation") end
			
			---------- WARRIOR COMMON ROTATION ----------
			if InMeleeRange() and InCombat("player") and InCombat("target") then
				--defensive spells
				if MyHealthPct() < 0.25 then
					if CanTryToCastSpell("Last Stand") then cast("Last Stand") end
				end
				--keep Battle Shout up
				if MyRage() >= 10 then SelfBuff("Battle Shout")	end
			end
			
			---------- WARRIOR TANK ROTATION ----------
			-- only use abilitites if I'm in combat and in melee range
			if InMeleeRange() and InCombat("player") and InCombat("target") then
				--PVE Defensive Rotation
				if MyStance() == 2 then	
					--- Auto TAUNT ---
					if UnitName("target") and UnitName("targettarget") and UnitName("targettarget") ~= UnitName("player") and UnitAffectingCombat("target") and not UnitIsPlayer("target") and UnitIsEnemy("player","target") then warrior_auto_taunt() end	
					warrior_auto_taunt()
					--use Bloodrage for rage generation
					if CanTryToCastSpell("Bloodrage") and MyHealthPct() > 0.2 and MyRage() < 30 then SelfBuff("Bloodrage") end
					--be a good team player and debuff bosses for armor
					if CanTryToCastSpell("Sunder Armor") and CountDebuffs("target") <= 8 and (TargetHealthPct() > 0.5 or boss("target")) then StackCast("Sunder Armor",5) end	
					--debuff enemies
					if CountDebuffs("target") <= 8 then DeBuff("Demoralizing Shout") end
					--Shield Block is top priority
					if MyRage() >= 30 and MyStance() == 2 and CanTryToCastSpell("Shield Block") and UnitName("targettarget") and UnitName("targettarget") == UnitName("player") then cast("Shield Block") end
					--after all other debuffs have been used then cast Shield Slam on cooldown
					if MyRage() >= 20 and CanTryToCastSpell("Shield Slam") then cast("Shield Slam") end
					--cast Revenge whenever possible
					if MyRage() >= 5 and MyStance() == 2 and CanTryToCastSpell("Revenge") then cast("Revenge") end
					--dump rage with Heroic Strike
					if MyMode == nil or MyMode == 1 then
						if MyRage() >= 65 then cast("Heroic Strike") end
					else
						if MyRage() >= 65 then cast("Cleave") end
					end
					--dump rage with Hamstring
					if MyRage() >= 100 then cast("Hamstring") end
				--rage dump stance dance to Defensive Stance
				else
					if MyRage() <= 25 then SpellStopCasting() SelfBuff("Defensive Stance") end
					if MyRage() > 25 then DumpRage() end					
				end									
			end
			---------- WARRIOR TANK ROTATION/end ----------
			
			--start auto attack
			if not TargetSheeped() and InMeleeRange() then
				if not IsCurrentAction(61) then UseAction(61) end
			elseif IsCurrentAction(AUTO_ATTACK) then UseAction(AUTO_ATTACK)
			end
		end
		---------- /WARRIOR - Single Target ----------
		
		--Create a frame to constantly run the main Rotation
		enabled = false
		local elapsed = 0
		local script_use_rate = 10 --This value determines how fast the Rotation will be triggered. Lower the value to trigger faster, but not recommended.
		frame = CreateFrame("Frame", nil, UIParent)
		frame:SetScript("OnUpdate", function()
			elapsed = elapsed + 1
			if enabled and elapsed > script_use_rate then
				Rotation()
				elapsed = 0
			end
		end)
	end
	--Script control. Press once to enable/disable. Hold Control + press to enable DPS Rotation or Hold Shift + press to enable Tank Rotation.
	if not IsControlKeyDown() and not IsShiftKeyDown() and not IsAltKeyDown() then
		-- Enable the Rotation
		function Disable()
			SpellStopCasting()
			enabled = false
			if IsCurrentAction(AUTO_ATTACK) then UseAction(AUTO_ATTACK) end
			frame:Hide()
			rotation = nil
			Say("\124cffffcc66Single-Target \124r Rotation \124cffFF0000 Disabled \124r")
		end
		-- Disable the Rotation
		function Enable()
			enabled = true
			Say("\124cffffcc66Single-Target \124r Rotation \124cff00FF00 Enabled \124r")
		end
		-- Script Control
		if enabled then
			Disable()
		else
			if multi_enabled then multi_Disable() end
			Enable()
		end
	end
	
	if IsAltKeyDown() then 
		if MyMode == nil or MyMode == 1 then
			Say("Use - \124cff008ae6Cleave\124r") MyMode = 2
		else
			Say("Use - \124cffffcc66Heroic Strike\124r") MyMode = 1
		end
	end
end

-- Holymana hiring poops

-- Usage: /script hire("mc")
-- Usage: /script hire("bwl")

-- .z invite [character name][license][class][role][spec][race][gender][preset]
local presets = {
	-- Preset 1
    ["mc"] = {
		-- Group 1
        ".z invite holymana t5r warrior tank default human",
        ".z invite tigerbow t4r hunter rangedps default nightelf",
        ".z invite holymoon t4r rogue meleedps default human",
		-- Group 2
        ".z invite holymana t5r warrior tank default human",
        ".z invite tigerbow t4r hunter rangedps default nightelf",
        ".z invite holymoon t4r warrior meleedps default human",
        ".z invite security t4r warrior meleedps default human",
		-- Group 3
        ".z invite holymana t5r warrior tank default human",
        ".z invite tigerbow t4r hunter rangedps default nightelf",
        ".z invite holymoon t4r warrior meleedps default human",
        ".z invite security t4r warrior meleedps default human",
		-- Group 4
        ".z invite holymana t5r warrior tank default human",
        ".z invite tigerbow t4r hunter rangedps default nightelf",
        ".z invite holymoon t4r warrior meleedps default human",
        ".z invite security t4r warrior meleedps default human",		
		-- Group 5
        ".z invite holynova t4r priest healer default dwarf",
        ".z invite holyfreeze t4r paladin healer default dwarf",
        ".z invite holybow t2r mage rangedps default gnome",
        ".z invite holystones t2r warlock rangedps default gnome",
		-- Group 6
        ".z invite holynova t4r priest healer default dwarf",
        ".z invite holyfreeze t4r paladin healer default dwarf",
        ".z invite holybow t2r mage rangedps default gnome",
        ".z invite holystones t2r warlock rangedps default gnome",
		-- Group 7
        ".z invite holynova t4r priest healer default dwarf",
        ".z invite holyfreeze t4r paladin healer default dwarf",
        ".z invite holybow t2r mage rangedps default gnome",
        ".z invite holystones t2r warlock rangedps default gnome",
		-- Group 8
        ".z invite holynova t4r priest healer default dwarf",
        ".z invite holyfreeze t4r druid healer default nightelf",
        ".z invite holybow t2r mage rangedps default gnome",
        ".z invite holystones t2r warlock rangedps default gnome",
    },
	-- Preset 2
    ["bwl"] = {
        ".z add rogue dps",
        ".z add mage dps",
    },
	-- Preset 3
    ["aq40"] = {
        ".z add rogue dps",
        ".z add mage dps",
    },
	-- Preset 4
    ["naxx"] = {
        ".z add rogue dps",
        ".z add mage dps",
    },
	-- Preset 5
    ["zg"] = {
        ".z add rogue dps",
        ".z add mage dps",
    },
	-- Preset 6
    ["ony"] = {
        ".z add rogue dps",
        ".z add mage dps",
    },
}

local function countTableElements(tbl)
    local count = 0
    for _ in pairs(tbl) do count = count + 1 end
    return count
end

function hire(preset)
    local commands = presets[string.lower(preset)]
    if not commands then
        print("Preset for " .. preset .. " not found.")
        return
    end

	local delay = 500  -- Set Delay
    local index = 0
	local elapsed = 0
    local totalCommands = countTableElements(commands)

    local indicatorFrame = CreateFrame("Frame", nil, UIParent)
    indicatorFrame:SetScript("OnUpdate", function(self)
		
        elapsed = elapsed + 1		
        if elapsed >= delay or index == 0 then
            index = index + 1

            if index <= totalCommands then
                SendChatMessage(commands[index])
                elapsed = 0
            else
                indicatorFrame:SetScript("OnUpdate", nil)
            end
        end
    end)
end
