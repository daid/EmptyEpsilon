----------     Generate call sign functions     ----------
--	Usage
--		generateCallSign()
--			No passed parameters. Prefix generated internally. No related faction prefix.
--		generateCallSign(prefix)
--			A call sign prefix has already been determined and passed in. The numeric
--			part after the prefix is what is generated. Especially useful if you want a
--			group of call signs with the same prefix, but with different numeric suffixes.
--		generateCallSign(nil,faction)
--			No prefix specified, but a faction is specified. The prefix will be taken from
--			the list of faction prefixes for the faction provided. The numeric suffix is
--			also generated.
--		generateCallSign(prefix,faction)
--			Both prefix and faction specified. Assumes you want a faction flavored prefix
--			along with the prefix provided. The prefix portion will be the faction flavored
--			prefix followed by a space followed by the provided prefix. The numeric suffix
--			follows.
--		generateCallSignPrefix()
--			No length specified. A call sign prefix of random characters of length
--			prefix_length will be generated. The randomness comes from a pool of characters
--			to reduce the chance of repetition. The pool is rebuilt when exhausted. Called
--			by generateCallSign when prefix is not provided. Useful when you want the same
--			prefix for a group of call signs, but you want it randomly generated: use
--			generateCallSignPrefix and pass the result to generateCallSign for each call
--			sign desired for your group.
--		generateCallSignPrefix(length)
--			Generates a random group of characters of the length passed.
--		getFactionPrefix()
--			Calls generateCallSignPrefix() if the faction is omitted
--		getFactionPrefix(faction)
--			Provides a faction flavored call sign prefix. Called internally by
--			generateCallSign(<>,faction). Pulled from the pool of faction prefixes. The
--			faction prefix pool is refilled when exhausted.
--	Global variables (set here if not set externally)
--		suffix_index - set to zero if not set externally
--		prefix_length - set to zero if not set externally
--		Faction flavored call sign prefixes: 
--			Kraylor_names, exuari_names, ghosts_names, independent_names, human_names,
--			arlenian_names, usn_names, tsn_names, cuf_names, ktlitan_names
--	Faction flavored prefix names
--		The Kraylor, Arlenian, Exuari and Ktlitan names are supposed to sound alien. They
--		follow an internal pattern so that with enough experience, one can tell by the 
--		ship name what faction they belong to. The Ghost names come from computer hardware
--		and software terminology in keeping with their cyber origins. The USN names follow 
--		a pirate theme. The TSN names follow a traditional space ship theme from science
--		fiction. The CUF names are somewhat whimsical with alliteration for multipart names.
--		The independent names borrow from every group since they represent ships that come
--		from a variety of sources.
--
--		You can set up your own list of names using the same list name and format. Once
--		your names have been exhausted, the pool will be refilled with the names here.

--Custom generateCallSign from the List for Odysseys
function generateCallSignFromList(prefix,faction)
	if faction == nil then
		--If faction is missing, returns the original call sign script result
		shipCallSign = generateCallSign(prefix, faction)
	else
		shipCallSign = string.format("%s",getFactionPrefix(faction))
	end
	if suffix_index == nil then
		suffix_index = 0
	end
	--Left here, so that spawning friendly fleet also raises the numbers
	suffix_index = suffix_index + math.random(1,8)
	if suffix_index > 999 then 
		-- Suffix_index starts always from 100
		suffix_index = 100
	end
	-- Sets the callsign as the result from the list
--	shipCallSign = string.format("%s%i",prefix)

	return shipCallSign
end


-- ooB generate call sign function
function generateCallSign(prefix,faction)
	if faction == nil then
		if prefix == nil then
			prefix = generateCallSignPrefix()
		end
	else
		if prefix == nil then
			prefix = getFactionPrefix(faction)
		else
			prefix = string.format("%s %s",getFactionPrefix(faction),prefix)
		end
	end
	if suffix_index == nil then
		suffix_index = 0
	end
	suffix_index = suffix_index + math.random(1,3)
	if suffix_index > 999 then 
		suffix_index = 1
	end
	return string.format("%s%i",prefix,suffix_index)
end
function generateCallSignPrefix(length)
	if prefix_length == nil then
		prefix_length = 0
	end
	if call_sign_prefix_pool == nil then
		call_sign_prefix_pool = {}
		prefix_length = prefix_length + 1
		if prefix_length > 3 then
			prefix_length = 1
		end
		fillPrefixPool()
	end
	if length == nil then
		length = prefix_length
	end
	local prefix_index = 0
	local prefix = ""
	for i=1,length do
		if #call_sign_prefix_pool < 1 then
			fillPrefixPool()
		end
		prefix_index = math.random(1,#call_sign_prefix_pool)
		prefix = prefix .. call_sign_prefix_pool[prefix_index]
		table.remove(call_sign_prefix_pool,prefix_index)
	end
	return prefix
end
function fillPrefixPool()
	for i=1,26 do
		table.insert(call_sign_prefix_pool,string.char(i+64))
	end
end
function getFactionPrefix(faction)
	local faction_prefix = nil
	if faction == "ESS Halo" then
		if halo_names == nil then
			setHaloNames()
		else
			if #halo_names < 1 then
				setHaloNames()
			end
		end
		local halo_name_choice = math.random(1,#halo_names)
		faction_prefix = halo_names[halo_name_choice]
		table.remove(halo_names,halo_name_choice)
	end
	if faction == "ESS Inferno" then
		if inferno_names == nil then
			setInfernoNames()
		else
			if #inferno_names < 1 then
				setInfernoNames()
			end
		end
		local inferno_name_choice = math.random(1,#inferno_names)
		faction_prefix = inferno_names[inferno_name_choice]
		table.remove(inferno_names,inferno_name_choice)
	end
	if faction == "ESS Valor" then
		if valor_names == nil then
			setValorNames()
		else
			if #valor_names < 1 then
				setValorNames()
			end
		end
		local valor_name_choice = math.random(1,#valor_names)
		faction_prefix = valor_names[valor_name_choice]
		table.remove(valor_names,valor_name_choice)
	end
	if faction == "ESS Aurora" then
		if aurora_names == nil then
			setAuroraNames()
		else
			if #aurora_names < 1 then
				setAuroraNames()
			end
		end
		local aurora_name_choice = math.random(1,#aurora_names)
		faction_prefix = aurora_names[aurora_name_choice]
		table.remove(aurora_names,aurora_name_choice)
	end
	if faction == "Kraylor" then
		if Kraylor_names == nil then
			setKraylorNames()
		else
			if #Kraylor_names < 1 then
				setKraylorNames()
			end
		end
		local Kraylor_name_choice = math.random(1,#Kraylor_names)
		faction_prefix = Kraylor_names[Kraylor_name_choice]
		table.remove(Kraylor_names,Kraylor_name_choice)
	end
	if faction == "Exuari" then
		if exuari_names == nil then
			setExuariNames()
		else
			if #exuari_names < 1 then
				setExuariNames()
			end
		end
		local exuari_name_choice = math.random(1,#exuari_names)
		faction_prefix = exuari_names[exuari_name_choice]
		table.remove(exuari_names,exuari_name_choice)
	end
	if faction == "Ghosts" then
		if ghosts_names == nil then
			setGhostsNames()
		else
			if #ghosts_names < 1 then
				setGhostsNames()
			end
		end
		local ghosts_name_choice = math.random(1,#ghosts_names)
		faction_prefix = ghosts_names[ghosts_name_choice]
		table.remove(ghosts_names,ghosts_name_choice)
	end
	if faction == "Independent" then
		if independent_names == nil then
			setIndependentNames()
		else
			if #independent_names < 1 then
				setIndependentNames()
			end
		end
		local independent_name_choice = math.random(1,#independent_names)
		faction_prefix = independent_names[independent_name_choice]
		table.remove(independent_names,independent_name_choice)
	end
	if faction == "Human Navy" then
		if human_names == nil then
			setHumanNames()
		else
			if #human_names < 1 then
				setHumanNames()
			end
		end
		local human_name_choice = math.random(1,#human_names)
		faction_prefix = human_names[human_name_choice]
		table.remove(human_names,human_name_choice)
	end
	if faction == "Arlenians" then
		if arlenian_names == nil then
			setArlenianNames()
		else
			if #arlenian_names < 1 then
				setArlenianNames()
			end
		end
		local arlenian_name_choice = math.random(1,#arlenian_names)
		faction_prefix = arlenian_names[arlenian_name_choice]
		table.remove(arlenian_names,arlenian_name_choice)
	end
	if faction == "USN" then
		if usn_names == nil then
			setUsnNames()
		else
			if #usn_names < 1 then
				setUsnNames()
			end
		end
		local usn_name_choice = math.random(1,#usn_names)
		faction_prefix = usn_names[usn_name_choice]
		table.remove(usn_names,usn_name_choice)
	end
	if faction == "TSN" then
		if tsn_names == nil then
			setTsnNames()
		else
			if #tsn_names < 1 then
				setTsnNames()
			end
		end
		local tsn_name_choice = math.random(1,#tsn_names)
		faction_prefix = tsn_names[tsn_name_choice]
		table.remove(tsn_names,tsn_name_choice)
	end
	if faction == "CUF" then
		if cuf_names == nil then
			setCufNames()
		else
			if #cuf_names < 1 then
				setCufNames()
			end
		end
		local cuf_name_choice = math.random(1,#cuf_names)
		faction_prefix = cuf_names[cuf_name_choice]
		table.remove(cuf_names,cuf_name_choice)
	end
	if faction == "Ktlitans" then
		if ktlitan_names == nil then
			setKtlitanNames()
		else
			if #ktlitan_names < 1 then
				setKtlitanNames()
			end
		end
		local ktlitan_name_choice = math.random(1,#ktlitan_names)
		faction_prefix = ktlitan_names[ktlitan_name_choice]
		table.remove(ktlitan_names,ktlitan_name_choice)
	end
	if faction_prefix == nil then
		faction_prefix = generateCallSignPrefix()
	end
	return faction_prefix
end
function setGhostsNames()
	ghosts_names = {}
	table.insert(ghosts_names,"Abstract")
	table.insert(ghosts_names,"Ada")
	table.insert(ghosts_names,"Assemble")
	table.insert(ghosts_names,"Assert")
	table.insert(ghosts_names,"Backup")
	table.insert(ghosts_names,"BASIC")
	table.insert(ghosts_names,"Big Iron")
	table.insert(ghosts_names,"BigEndian")
	table.insert(ghosts_names,"Binary")
	table.insert(ghosts_names,"Bit")
	table.insert(ghosts_names,"Block")
	table.insert(ghosts_names,"Boot")
	table.insert(ghosts_names,"Branch")
	table.insert(ghosts_names,"BTree")
	table.insert(ghosts_names,"Bubble")
	table.insert(ghosts_names,"Byte")
	table.insert(ghosts_names,"Capacitor")
	table.insert(ghosts_names,"Case")
	table.insert(ghosts_names,"Chad")
	table.insert(ghosts_names,"Charge")
	table.insert(ghosts_names,"COBOL")
	table.insert(ghosts_names,"Collate")
	table.insert(ghosts_names,"Compile")
	table.insert(ghosts_names,"Control")
	table.insert(ghosts_names,"Construct")
	table.insert(ghosts_names,"Cycle")
	table.insert(ghosts_names,"Data")
	table.insert(ghosts_names,"Debug")
	table.insert(ghosts_names,"Decimal")
	table.insert(ghosts_names,"Decision")
	table.insert(ghosts_names,"Default")
	table.insert(ghosts_names,"DIMM")
	table.insert(ghosts_names,"Displacement")
	table.insert(ghosts_names,"Edge")
	table.insert(ghosts_names,"Exit")
	table.insert(ghosts_names,"Factor")
	table.insert(ghosts_names,"Flag")
	table.insert(ghosts_names,"Float")
	table.insert(ghosts_names,"Flow")
	table.insert(ghosts_names,"FORTRAN")
	table.insert(ghosts_names,"Fullword")
	table.insert(ghosts_names,"GIGO")
	table.insert(ghosts_names,"Graph")
	table.insert(ghosts_names,"Hack")
	table.insert(ghosts_names,"Hash")
	table.insert(ghosts_names,"Halfword")
	table.insert(ghosts_names,"Hertz")
	table.insert(ghosts_names,"Hexadecimal")
	table.insert(ghosts_names,"Indicator")
	table.insert(ghosts_names,"Initialize")
	table.insert(ghosts_names,"Integer")
	table.insert(ghosts_names,"Integrate")
	table.insert(ghosts_names,"Interrupt")
	table.insert(ghosts_names,"Java")
	table.insert(ghosts_names,"Lisp")
	table.insert(ghosts_names,"List")
	table.insert(ghosts_names,"Logic")
	table.insert(ghosts_names,"Loop")
	table.insert(ghosts_names,"Lua")
	table.insert(ghosts_names,"Magnetic")
	table.insert(ghosts_names,"Mask")
	table.insert(ghosts_names,"Memory")
	table.insert(ghosts_names,"Mnemonic")
	table.insert(ghosts_names,"Micro")
	table.insert(ghosts_names,"Model")
	table.insert(ghosts_names,"Nibble")
	table.insert(ghosts_names,"Octal")
	table.insert(ghosts_names,"Order")
	table.insert(ghosts_names,"Operator")
	table.insert(ghosts_names,"Parameter")
	table.insert(ghosts_names,"Pascal")
	table.insert(ghosts_names,"Pattern")
	table.insert(ghosts_names,"Pixel")
	table.insert(ghosts_names,"Point")
	table.insert(ghosts_names,"Polygon")
	table.insert(ghosts_names,"Port")
	table.insert(ghosts_names,"Process")
	table.insert(ghosts_names,"RAM")
	table.insert(ghosts_names,"Raster")
	table.insert(ghosts_names,"Rate")
	table.insert(ghosts_names,"Redundant")
	table.insert(ghosts_names,"Reference")
	table.insert(ghosts_names,"Refresh")
	table.insert(ghosts_names,"Register")
	table.insert(ghosts_names,"Resistor")
	table.insert(ghosts_names,"ROM")
	table.insert(ghosts_names,"Routine")
	table.insert(ghosts_names,"Ruby")
	table.insert(ghosts_names,"SAAS")
	table.insert(ghosts_names,"Sequence")
	table.insert(ghosts_names,"Share")
	table.insert(ghosts_names,"Silicon")
	table.insert(ghosts_names,"SIMM")
	table.insert(ghosts_names,"Socket")
	table.insert(ghosts_names,"Sort")
	table.insert(ghosts_names,"Structure")
	table.insert(ghosts_names,"Switch")
	table.insert(ghosts_names,"Symbol")
	table.insert(ghosts_names,"Trace")
	table.insert(ghosts_names,"Transistor")
	table.insert(ghosts_names,"Value")
	table.insert(ghosts_names,"Vector")
	table.insert(ghosts_names,"Version")
	table.insert(ghosts_names,"View")
	table.insert(ghosts_names,"WYSIWYG")
	table.insert(ghosts_names,"XOR")
end
function setExuariNames()
	exuari_names = {}
	table.insert(exuari_names,"Astonester")
	table.insert(exuari_names,"Ametripox")
	table.insert(exuari_names,"Bakeltevex")
	table.insert(exuari_names,"Baropledax")
	table.insert(exuari_names,"Batongomox")
	table.insert(exuari_names,"Bekilvimix")
	table.insert(exuari_names,"Benoglopok")
	table.insert(exuari_names,"Bilontipur")
	table.insert(exuari_names,"Bolictimik")
	table.insert(exuari_names,"Bomagralax")
	table.insert(exuari_names,"Buteldefex")
	table.insert(exuari_names,"Catondinab")
	table.insert(exuari_names,"Chatorlonox")
	table.insert(exuari_names,"Culagromik")
	table.insert(exuari_names,"Dakimbinix")
	table.insert(exuari_names,"Degintalix")
	table.insert(exuari_names,"Dimabratax")
	table.insert(exuari_names,"Dokintifix")
	table.insert(exuari_names,"Dotandirex")
	table.insert(exuari_names,"Dupalgawax")
	table.insert(exuari_names,"Ekoftupex")
	table.insert(exuari_names,"Elidranov")
	table.insert(exuari_names,"Fakobrovox")
	table.insert(exuari_names,"Femoplabix")
	table.insert(exuari_names,"Fibatralax")
	table.insert(exuari_names,"Fomartoran")
	table.insert(exuari_names,"Gateldepex")
	table.insert(exuari_names,"Gamutrewal")
	table.insert(exuari_names,"Gesanterux")
	table.insert(exuari_names,"Gimardanax")
	table.insert(exuari_names,"Hamintinal")
	table.insert(exuari_names,"Holangavak")
	table.insert(exuari_names,"Igolpafik")
	table.insert(exuari_names,"Inoklomat")
	table.insert(exuari_names,"Jamewtibex")
	table.insert(exuari_names,"Jepospagox")
	table.insert(exuari_names,"Kajortonox")
	table.insert(exuari_names,"Kapogrinix")
	table.insert(exuari_names,"Kelitravax")
	table.insert(exuari_names,"Kipaldanax")
	table.insert(exuari_names,"Kodendevex")
	table.insert(exuari_names,"Kotelpedex")
	table.insert(exuari_names,"Kutandolak")
	table.insert(exuari_names,"Lakirtinix")
	table.insert(exuari_names,"Lapoldinek")
	table.insert(exuari_names,"Lavorbonox")
	table.insert(exuari_names,"Letirvinix")
	table.insert(exuari_names,"Lowibromax")
	table.insert(exuari_names,"Makintibix")
	table.insert(exuari_names,"Makorpohox")
	table.insert(exuari_names,"Matoprowox")
	table.insert(exuari_names,"Mefinketix")
	table.insert(exuari_names,"Motandobak")
	table.insert(exuari_names,"Nakustunux")
	table.insert(exuari_names,"Nequivonax")
	table.insert(exuari_names,"Nitaldavax")
	table.insert(exuari_names,"Nobaldorex")
	table.insert(exuari_names,"Obimpitix")
	table.insert(exuari_names,"Owaklanat")
	table.insert(exuari_names,"Pakendesik")
	table.insert(exuari_names,"Pazinderix")
	table.insert(exuari_names,"Pefoglamuk")
	table.insert(exuari_names,"Pekirdivix")
	table.insert(exuari_names,"Potarkadax")
	table.insert(exuari_names,"Pulendemex")
	table.insert(exuari_names,"Quatordunix")
	table.insert(exuari_names,"Rakurdumux")
	table.insert(exuari_names,"Ralombenik")
	table.insert(exuari_names,"Regosporak")
	table.insert(exuari_names,"Retordofox")
	table.insert(exuari_names,"Rikondogox")
	table.insert(exuari_names,"Rokengelex")
	table.insert(exuari_names,"Rutarkadax")
	table.insert(exuari_names,"Sakeldepex")
	table.insert(exuari_names,"Setiftimix")
	table.insert(exuari_names,"Siparkonal")
	table.insert(exuari_names,"Sopaldanax")
	table.insert(exuari_names,"Sudastulux")
	table.insert(exuari_names,"Takeftebex")
	table.insert(exuari_names,"Taliskawit")
	table.insert(exuari_names,"Tegundolex")
	table.insert(exuari_names,"Tekintipix")
	table.insert(exuari_names,"Tiposhomox")
	table.insert(exuari_names,"Tokaldapax")
	table.insert(exuari_names,"Tomuglupux")
	table.insert(exuari_names,"Tufeldepex")
	table.insert(exuari_names,"Unegremek")
	table.insert(exuari_names,"Uvendipax")
	table.insert(exuari_names,"Vatorgopox")
	table.insert(exuari_names,"Venitribix")
	table.insert(exuari_names,"Vobalterix")
	table.insert(exuari_names,"Wakintivix")
	table.insert(exuari_names,"Wapaltunix")
	table.insert(exuari_names,"Wekitrolax")
	table.insert(exuari_names,"Wofarbanax")
	table.insert(exuari_names,"Xeniplofek")
	table.insert(exuari_names,"Yamaglevik")
	table.insert(exuari_names,"Yakildivix")
	table.insert(exuari_names,"Yegomparik")
	table.insert(exuari_names,"Zapondehex")
	table.insert(exuari_names,"Zikandelat")
end
function setKraylorNames()		
	Kraylor_names = {}
	table.insert(Kraylor_names,"Abroten")
	table.insert(Kraylor_names,"Ankwar")
	table.insert(Kraylor_names,"Bakrik")
	table.insert(Kraylor_names,"Belgor")
	table.insert(Kraylor_names,"Benkop")
	table.insert(Kraylor_names,"Blargvet")
	table.insert(Kraylor_names,"Bloktarg")
	table.insert(Kraylor_names,"Bortok")
	table.insert(Kraylor_names,"Bredjat")
	table.insert(Kraylor_names,"Chankret")
	table.insert(Kraylor_names,"Chatork")
	table.insert(Kraylor_names,"Chokarp")
	table.insert(Kraylor_names,"Cloprak")
	table.insert(Kraylor_names,"Coplek")
	table.insert(Kraylor_names,"Cortek")
	table.insert(Kraylor_names,"Daltok")
	table.insert(Kraylor_names,"Darpik")
	table.insert(Kraylor_names,"Dastek")
	table.insert(Kraylor_names,"Dotark")
	table.insert(Kraylor_names,"Drambok")
	table.insert(Kraylor_names,"Duntarg")
	table.insert(Kraylor_names,"Earklat")
	table.insert(Kraylor_names,"Ekmit")
	table.insert(Kraylor_names,"Fakret")
	table.insert(Kraylor_names,"Fapork")
	table.insert(Kraylor_names,"Fawtrik")
	table.insert(Kraylor_names,"Fenturp")
	table.insert(Kraylor_names,"Feplik")
	table.insert(Kraylor_names,"Figront")
	table.insert(Kraylor_names,"Floktrag")
	table.insert(Kraylor_names,"Fonkack")
	table.insert(Kraylor_names,"Fontreg")
	table.insert(Kraylor_names,"Foondrap")
	table.insert(Kraylor_names,"Frotwak")
	table.insert(Kraylor_names,"Gastonk")
	table.insert(Kraylor_names,"Gentouk")
	table.insert(Kraylor_names,"Gonpruk")
	table.insert(Kraylor_names,"Gortak")
	table.insert(Kraylor_names,"Gronkud")
	table.insert(Kraylor_names,"Hewtang")
	table.insert(Kraylor_names,"Hongtag")
	table.insert(Kraylor_names,"Hortook")
	table.insert(Kraylor_names,"Indrut")
	table.insert(Kraylor_names,"Iprant")
	table.insert(Kraylor_names,"Jakblet")
	table.insert(Kraylor_names,"Jonket")
	table.insert(Kraylor_names,"Jontot")
	table.insert(Kraylor_names,"Kandarp")
	table.insert(Kraylor_names,"Kantrok")
	table.insert(Kraylor_names,"Kiptak")
	table.insert(Kraylor_names,"Kortrant")
	table.insert(Kraylor_names,"Krontgat")
	table.insert(Kraylor_names,"Lobreck")
	table.insert(Kraylor_names,"Lokrant")
	table.insert(Kraylor_names,"Lomprok")
	table.insert(Kraylor_names,"Lutrank")
	table.insert(Kraylor_names,"Makrast")
	table.insert(Kraylor_names,"Moklahft")
	table.insert(Kraylor_names,"Morpug")
	table.insert(Kraylor_names,"Nagblat")
	table.insert(Kraylor_names,"Nokrat")
	table.insert(Kraylor_names,"Nomek")
	table.insert(Kraylor_names,"Notark")
	table.insert(Kraylor_names,"Ontrok")
	table.insert(Kraylor_names,"Orkpent")
	table.insert(Kraylor_names,"Peechak")
	table.insert(Kraylor_names,"Plogrent")
	table.insert(Kraylor_names,"Pokrint")
	table.insert(Kraylor_names,"Potarg")
	table.insert(Kraylor_names,"Prangtil")
	table.insert(Kraylor_names,"Quagbrok")
	table.insert(Kraylor_names,"Quimprill")
	table.insert(Kraylor_names,"Reekront")
	table.insert(Kraylor_names,"Ripkort")
	table.insert(Kraylor_names,"Rokust")
	table.insert(Kraylor_names,"Rontrait")
	table.insert(Kraylor_names,"Saknep")
	table.insert(Kraylor_names,"Sengot")
	table.insert(Kraylor_names,"Skitkard")
	table.insert(Kraylor_names,"Skopgrek")
	table.insert(Kraylor_names,"Sletrok")
	table.insert(Kraylor_names,"Slorknat")
	table.insert(Kraylor_names,"Spogrunk")
	table.insert(Kraylor_names,"Staklurt")
	table.insert(Kraylor_names,"Stonkbrant")
	table.insert(Kraylor_names,"Swaktrep")
	table.insert(Kraylor_names,"Tandrok")
	table.insert(Kraylor_names,"Takrost")
	table.insert(Kraylor_names,"Tonkrut")
	table.insert(Kraylor_names,"Torkrot")
	table.insert(Kraylor_names,"Trablok")
	table.insert(Kraylor_names,"Trokdin")
	table.insert(Kraylor_names,"Unkelt")
	table.insert(Kraylor_names,"Urjop")
	table.insert(Kraylor_names,"Vankront")
	table.insert(Kraylor_names,"Vintrep")
	table.insert(Kraylor_names,"Volkerd")
	table.insert(Kraylor_names,"Vortread")
	table.insert(Kraylor_names,"Wickurt")
	table.insert(Kraylor_names,"Xokbrek")
	table.insert(Kraylor_names,"Yeskret")
	table.insert(Kraylor_names,"Zacktrope")
end
function setIndependentNames()
	independent_names = {}
	table.insert(independent_names,"Akdroft")	--faux Kraylor
	table.insert(independent_names,"Bletnik")	--faux Kraylor
	table.insert(independent_names,"Brogfent")	--faux Kraylor
	table.insert(independent_names,"Cruflech")	--faux Kraylor
	table.insert(independent_names,"Dengtoct")	--faux Kraylor
	table.insert(independent_names,"Fiklerg")	--faux Kraylor
	table.insert(independent_names,"Groftep")	--faux Kraylor
	table.insert(independent_names,"Hinkflort")	--faux Kraylor
	table.insert(independent_names,"Irklesht")	--faux Kraylor
	table.insert(independent_names,"Jotrak")	--faux Kraylor
	table.insert(independent_names,"Kargleth")	--faux Kraylor
	table.insert(independent_names,"Lidroft")	--faux Kraylor
	table.insert(independent_names,"Movrect")	--faux Kraylor
	table.insert(independent_names,"Nitrang")	--faux Kraylor
	table.insert(independent_names,"Poklapt")	--faux Kraylor
	table.insert(independent_names,"Raknalg")	--faux Kraylor
	table.insert(independent_names,"Stovtuk")	--faux Kraylor
	table.insert(independent_names,"Trongluft")	--faux Kraylor
	table.insert(independent_names,"Vactremp")	--faux Kraylor
	table.insert(independent_names,"Wunklesp")	--faux Kraylor
	table.insert(independent_names,"Yentrilg")	--faux Kraylor
	table.insert(independent_names,"Zeltrag")	--faux Kraylor
	table.insert(independent_names,"Avoltojop")		--faux Exuari
	table.insert(independent_names,"Bimartarax")	--faux Exuari
	table.insert(independent_names,"Cidalkapax")	--faux Exuari
	table.insert(independent_names,"Darongovax")	--faux Exuari
	table.insert(independent_names,"Felistiyik")	--faux Exuari
	table.insert(independent_names,"Gopendewex")	--faux Exuari
	table.insert(independent_names,"Hakortodox")	--faux Exuari
	table.insert(independent_names,"Jemistibix")	--faux Exuari
	table.insert(independent_names,"Kilampafax")	--faux Exuari
	table.insert(independent_names,"Lokuftumux")	--faux Exuari
	table.insert(independent_names,"Mabildirix")	--faux Exuari
	table.insert(independent_names,"Notervelex")	--faux Exuari
	table.insert(independent_names,"Pekolgonex")	--faux Exuari
	table.insert(independent_names,"Rifaltabax")	--faux Exuari
	table.insert(independent_names,"Sobendeyex")	--faux Exuari
	table.insert(independent_names,"Tinaftadax")	--faux Exuari
	table.insert(independent_names,"Vadorgomax")	--faux Exuari
	table.insert(independent_names,"Wilerpejex")	--faux Exuari
	table.insert(independent_names,"Yukawvalak")	--faux Exuari
	table.insert(independent_names,"Zajiltibix")	--faux Exuari
	table.insert(independent_names,"Alter")		--faux Ghosts
	table.insert(independent_names,"Assign")	--faux Ghosts
	table.insert(independent_names,"Brain")		--faux Ghosts
	table.insert(independent_names,"Break")		--faux Ghosts
	table.insert(independent_names,"Boundary")	--faux Ghosts
	table.insert(independent_names,"Code")		--faux Ghosts
	table.insert(independent_names,"Compare")	--faux Ghosts
	table.insert(independent_names,"Continue")	--faux Ghosts
	table.insert(independent_names,"Core")		--faux Ghosts
	table.insert(independent_names,"CRUD")		--faux Ghosts
	table.insert(independent_names,"Decode")	--faux Ghosts
	table.insert(independent_names,"Decrypt")	--faux Ghosts
	table.insert(independent_names,"Device")	--faux Ghosts
	table.insert(independent_names,"Encode")	--faux Ghosts
	table.insert(independent_names,"Encrypt")	--faux Ghosts
	table.insert(independent_names,"Event")		--faux Ghosts
	table.insert(independent_names,"Fetch")		--faux Ghosts
	table.insert(independent_names,"Frame")		--faux Ghosts
	table.insert(independent_names,"Go")		--faux Ghosts
	table.insert(independent_names,"IO")		--faux Ghosts
	table.insert(independent_names,"Interface")	--faux Ghosts
	table.insert(independent_names,"Kilo")		--faux Ghosts
	table.insert(independent_names,"Modify")	--faux Ghosts
	table.insert(independent_names,"Pin")		--faux Ghosts
	table.insert(independent_names,"Program")	--faux Ghosts
	table.insert(independent_names,"Purge")		--faux Ghosts
	table.insert(independent_names,"Retrieve")	--faux Ghosts
	table.insert(independent_names,"Store")		--faux Ghosts
	table.insert(independent_names,"Unit")		--faux Ghosts
	table.insert(independent_names,"Wire")		--faux Ghosts
	table.insert(independent_names,"Chakak")		--faux Ktlitans
	table.insert(independent_names,"Chakik")		--faux Ktlitans
	table.insert(independent_names,"Chaklik")		--faux Ktlitans
	table.insert(independent_names,"Kaklak")		--faux Ktlitans
	table.insert(independent_names,"Kiklak")		--faux Ktlitans
	table.insert(independent_names,"Kitpak")		--faux Ktlitans
	table.insert(independent_names,"Kitplak")		--faux Ktlitans
	table.insert(independent_names,"Pipklat")		--faux Ktlitans
	table.insert(independent_names,"Piptik")		--faux Ktlitans
end
function setCufNames()
	cuf_names = {}
	table.insert(cuf_names,"Allegro")
	table.insert(cuf_names,"Bonafide")
	table.insert(cuf_names,"Brief Blur")
	table.insert(cuf_names,"Byzantine Born")
	table.insert(cuf_names,"Celeste")
	table.insert(cuf_names,"Chosen Charter")
	table.insert(cuf_names,"Conundrum")
	table.insert(cuf_names,"Crazy Clef")
	table.insert(cuf_names,"Curtail")
	table.insert(cuf_names,"Dark Demesne")
	table.insert(cuf_names,"Diminutive Drama")
	table.insert(cuf_names,"Draconian Destiny")
	table.insert(cuf_names,"Fickle Frown")
	table.insert(cuf_names,"Final Freeze")
	table.insert(cuf_names,"Fried Feather")
	table.insert(cuf_names,"Frozen Flare")
	table.insert(cuf_names,"Gaunt Gator")
	table.insert(cuf_names,"Hidden Harpoon")
	table.insert(cuf_names,"Intense Interest")
	table.insert(cuf_names,"Lackadaisical")
	table.insert(cuf_names,"Largess")
	table.insert(cuf_names,"Ointment")
	table.insert(cuf_names,"Plush Puzzle")
	table.insert(cuf_names,"Slick")
	table.insert(cuf_names,"Thumper")
	table.insert(cuf_names,"Torpid")
	table.insert(cuf_names,"Triple Take")
end
function setUsnNames()
	usn_names = {}
	table.insert(usn_names,"Belladonna")
	table.insert(usn_names,"Broken Dragon")
	table.insert(usn_names,"Burning Knave")
	table.insert(usn_names,"Corona Flare")
	table.insert(usn_names,"Daring the Deep")
	table.insert(usn_names,"Dragon's Cutlass")
	table.insert(usn_names,"Dragon's Sadness")
	table.insert(usn_names,"Elusive Doom")
	table.insert(usn_names,"Fast Flare")
	table.insert(usn_names,"Flying Flare")
	table.insert(usn_names,"Fulminate")
	table.insert(usn_names,"Gaseous Gale")
	table.insert(usn_names,"Golden Anger")
	table.insert(usn_names,"Greedy Promethean")
	table.insert(usn_names,"Happy Mynock")
	table.insert(usn_names,"Jimi Saru")
	table.insert(usn_names,"Jolly Roger")
	table.insert(usn_names,"Killer's Grief")
	table.insert(usn_names,"Mad Delight")
	table.insert(usn_names,"Nocturnal Neptune")
	table.insert(usn_names,"Obscure Orbiter")
	table.insert(usn_names,"Red Rift")
	table.insert(usn_names,"Rusty Belle")
	table.insert(usn_names,"Silver Pearl")
	table.insert(usn_names,"Sodden Corsair")
	table.insert(usn_names,"Solar Sailor")
	table.insert(usn_names,"Solar Secret")
	table.insert(usn_names,"Sun's Grief")
	table.insert(usn_names,"Tortuga Shadows")
	table.insert(usn_names,"Trinity")
	table.insert(usn_names,"Wayfaring Wind")
end
function setTsnNames()
	tsn_names = {}
	table.insert(tsn_names,"Aegis")
	table.insert(tsn_names,"Allegiance")
	table.insert(tsn_names,"Apollo")
	table.insert(tsn_names,"Ares")
	table.insert(tsn_names,"Casper")
	table.insert(tsn_names,"Charger")
	table.insert(tsn_names,"Dauntless")
	table.insert(tsn_names,"Demeter")
	table.insert(tsn_names,"Eagle")
	table.insert(tsn_names,"Excalibur")
	table.insert(tsn_names,"Falcon")
	table.insert(tsn_names,"Guardian")
	table.insert(tsn_names,"Hawk")
	table.insert(tsn_names,"Hera")
	table.insert(tsn_names,"Horizon")
	table.insert(tsn_names,"Hunter")
	table.insert(tsn_names,"Hydra")
	table.insert(tsn_names,"Intrepid")
	table.insert(tsn_names,"Lancer")
	table.insert(tsn_names,"Montgomery")
	table.insert(tsn_names,"Nemesis")
	table.insert(tsn_names,"Osiris")
	table.insert(tsn_names,"Pegasus")
	table.insert(tsn_names,"Phoenix")
	table.insert(tsn_names,"Poseidon")
	table.insert(tsn_names,"Raven")
	table.insert(tsn_names,"Sabre")
	table.insert(tsn_names,"Stalker")
	table.insert(tsn_names,"Valkyrie")
	table.insert(tsn_names,"Viper")
end
function setHumanNames()
	human_names = {}
	table.insert(human_names,"Andromeda")
	table.insert(human_names,"Angelica")
	table.insert(human_names,"Artemis")
	table.insert(human_names,"Barrier")
	table.insert(human_names,"Beauteous")
	table.insert(human_names,"Bliss")
	table.insert(human_names,"Bonita")
	table.insert(human_names,"Bounty Hunter")
	table.insert(human_names,"Bueno")
	table.insert(human_names,"Capitol")
	table.insert(human_names,"Castigator")
	table.insert(human_names,"Centurion")
	table.insert(human_names,"Chakalaka")
	table.insert(human_names,"Charity")
	table.insert(human_names,"Christmas")
	table.insert(human_names,"Chutzpah")
	table.insert(human_names,"Constantine")
	table.insert(human_names,"Crystal")
	table.insert(human_names,"Dauntless")
	table.insert(human_names,"Defiant")
	table.insert(human_names,"Discovery")
	table.insert(human_names,"Dorcas")
	table.insert(human_names,"Elite")
	table.insert(human_names,"Empathy")
	table.insert(human_names,"Enlighten")
	table.insert(human_names,"Enterprise")
	table.insert(human_names,"Escape")
	table.insert(human_names,"Exclamatory")
	table.insert(human_names,"Faith")
	table.insert(human_names,"Felicity")
	table.insert(human_names,"Firefly")
	table.insert(human_names,"Foresight")
	table.insert(human_names,"Forthright")
	table.insert(human_names,"Fortitude")
	table.insert(human_names,"Frankenstein")
	table.insert(human_names,"Gallant")
	table.insert(human_names,"Gladiator")
	table.insert(human_names,"Glider")
	table.insert(human_names,"Godzilla")
	table.insert(human_names,"Grind")
	table.insert(human_names,"Happiness")
	table.insert(human_names,"Hearken")
	table.insert(human_names,"Helena")
	table.insert(human_names,"Heracles")
	table.insert(human_names,"Honorable Intentions")
	table.insert(human_names,"Hope")
	table.insert(human_names,"Inertia")
	table.insert(human_names,"Ingenius")
	table.insert(human_names,"Injurious")
	table.insert(human_names,"Insight")
	table.insert(human_names,"Insufferable")
	table.insert(human_names,"Insurmountable")
	table.insert(human_names,"Intractable")
	table.insert(human_names,"Intransigent")
	table.insert(human_names,"Jenny")
	table.insert(human_names,"Juice")
	table.insert(human_names,"Justice")
	table.insert(human_names,"Jurassic")
	table.insert(human_names,"Karma Cast")
	table.insert(human_names,"Knockout")
	table.insert(human_names,"Leila")
	table.insert(human_names,"Light Fantastic")
	table.insert(human_names,"Livid")
	table.insert(human_names,"Lolita")
	table.insert(human_names,"Mercury")
	table.insert(human_names,"Moira")
	table.insert(human_names,"Mona Lisa")
	table.insert(human_names,"Nancy")
	table.insert(human_names,"Olivia")
	table.insert(human_names,"Ominous")
	table.insert(human_names,"Oracle")
	table.insert(human_names,"Orca")
	table.insert(human_names,"Pandemic")
	table.insert(human_names,"Parsimonious")
	table.insert(human_names,"Personal Prejudice")
	table.insert(human_names,"Porpoise")
	table.insert(human_names,"Pristine")
	table.insert(human_names,"Purple Passion")
	table.insert(human_names,"Renegade")
	table.insert(human_names,"Revelation")
	table.insert(human_names,"Rosanna")
	table.insert(human_names,"Rozelle")
	table.insert(human_names,"Sainted Gramma")
	table.insert(human_names,"Shazam")
	table.insert(human_names,"Starbird")
	table.insert(human_names,"Stargazer")
	table.insert(human_names,"Stile")
	table.insert(human_names,"Streak")
	table.insert(human_names,"Take Flight")
	table.insert(human_names,"Taskmaster")
	table.insert(human_names,"The Way")
	table.insert(human_names,"Tornado")
	table.insert(human_names,"Trailblazer")
	table.insert(human_names,"Trident")
	table.insert(human_names,"Triple Threat")
	table.insert(human_names,"Turnabout")
	table.insert(human_names,"Undulator")
	table.insert(human_names,"Urgent")
	table.insert(human_names,"Victoria")
	table.insert(human_names,"Wee Bit")
	table.insert(human_names,"Wet Willie")
end
function setKtlitanNames()
	ktlitan_names = {}
	table.insert(ktlitan_names,"Chaklak")
	table.insert(ktlitan_names,"Chaklit")
	table.insert(ktlitan_names,"Chitlat")
	table.insert(ktlitan_names,"Chitlit")
	table.insert(ktlitan_names,"Chitpik")
	table.insert(ktlitan_names,"Chokpit")
	table.insert(ktlitan_names,"Choktip")
	table.insert(ktlitan_names,"Choktot")
	table.insert(ktlitan_names,"Chotlap")
	table.insert(ktlitan_names,"Chotlat")
	table.insert(ktlitan_names,"Chotlot")
	table.insert(ktlitan_names,"Kaftlit")
	table.insert(ktlitan_names,"Kaplak")
	table.insert(ktlitan_names,"Kaplat")
	table.insert(ktlitan_names,"Kichpak")
	table.insert(ktlitan_names,"Kichpik")
	table.insert(ktlitan_names,"Kichtak")
	table.insert(ktlitan_names,"Kiftlat")
	table.insert(ktlitan_names,"Kiftak")
	table.insert(ktlitan_names,"Kiftakt")
	table.insert(ktlitan_names,"Kiftlikt")
	table.insert(ktlitan_names,"Kiftlit")
	table.insert(ktlitan_names,"Kiklat")
	table.insert(ktlitan_names,"Kiklik")
	table.insert(ktlitan_names,"Kiklit")
	table.insert(ktlitan_names,"Kiplit")
	table.insert(ktlitan_names,"Kiptot")
	table.insert(ktlitan_names,"Kitchip")
	table.insert(ktlitan_names,"Kitchit")
	table.insert(ktlitan_names,"Kitlaft")
	table.insert(ktlitan_names,"Kitlak")
	table.insert(ktlitan_names,"Kitlakt")
	table.insert(ktlitan_names,"Kitlich")
	table.insert(ktlitan_names,"Kitlik")
	table.insert(ktlitan_names,"Kitpok")
	table.insert(ktlitan_names,"Koptich")
	table.insert(ktlitan_names,"Koptlik")
	table.insert(ktlitan_names,"Kotplat")
	table.insert(ktlitan_names,"Pachtik")
	table.insert(ktlitan_names,"Paflak")
	table.insert(ktlitan_names,"Paftak")
	table.insert(ktlitan_names,"Paftik")
	table.insert(ktlitan_names,"Pakchit")
	table.insert(ktlitan_names,"Pakchok")
	table.insert(ktlitan_names,"Paktok")
	table.insert(ktlitan_names,"Piklit")
	table.insert(ktlitan_names,"Piflit")
	table.insert(ktlitan_names,"Piftik")
	table.insert(ktlitan_names,"Pitlak")
	table.insert(ktlitan_names,"Pochkik")
	table.insert(ktlitan_names,"Pochkit")
	table.insert(ktlitan_names,"Poftlit")
	table.insert(ktlitan_names,"Pokchap")
	table.insert(ktlitan_names,"Pokchat")
	table.insert(ktlitan_names,"Poktat")
	table.insert(ktlitan_names,"Poklit")
	table.insert(ktlitan_names,"Potlak")
	table.insert(ktlitan_names,"Tachpik")
	table.insert(ktlitan_names,"Tachpit")
	table.insert(ktlitan_names,"Taklit")
	table.insert(ktlitan_names,"Talkip")
	table.insert(ktlitan_names,"Talpik")
	table.insert(ktlitan_names,"Taltkip")
	table.insert(ktlitan_names,"Taltkit")
	table.insert(ktlitan_names,"Tichpik")
	table.insert(ktlitan_names,"Tikplit")
	table.insert(ktlitan_names,"Tiklich")
	table.insert(ktlitan_names,"Tiklip")
	table.insert(ktlitan_names,"Tiklip")
	table.insert(ktlitan_names,"Tilpit")
	table.insert(ktlitan_names,"Tiltlit")
	table.insert(ktlitan_names,"Tochtik")
	table.insert(ktlitan_names,"Tochkap")
	table.insert(ktlitan_names,"Tochpik")
	table.insert(ktlitan_names,"Tochpit")
	table.insert(ktlitan_names,"Tochkit")
	table.insert(ktlitan_names,"Totlop")
	table.insert(ktlitan_names,"Totlot")
end
function setArlenianNames()
	arlenian_names = {}
	table.insert(arlenian_names,"Balura")
	table.insert(arlenian_names,"Baminda")
	table.insert(arlenian_names,"Belarne")
	table.insert(arlenian_names,"Bilanna")
	table.insert(arlenian_names,"Calonda")
	table.insert(arlenian_names,"Carila")
	table.insert(arlenian_names,"Carulda")
	table.insert(arlenian_names,"Charma")
	table.insert(arlenian_names,"Choralle")
	table.insert(arlenian_names,"Corlune")
	table.insert(arlenian_names,"Damilda")
	table.insert(arlenian_names,"Dilenda")
	table.insert(arlenian_names,"Dorla")
	table.insert(arlenian_names,"Elena")
	table.insert(arlenian_names,"Emerla")
	table.insert(arlenian_names,"Famelda")
	table.insert(arlenian_names,"Finelle")
	table.insert(arlenian_names,"Fontaine")
	table.insert(arlenian_names,"Forlanne")
	table.insert(arlenian_names,"Gendura")
	table.insert(arlenian_names,"Gilarne")
	table.insert(arlenian_names,"Grizelle")
	table.insert(arlenian_names,"Hilerna")
	table.insert(arlenian_names,"Homella")
	table.insert(arlenian_names,"Jarille")
	table.insert(arlenian_names,"Jindarre")
	table.insert(arlenian_names,"Juminde")
	table.insert(arlenian_names,"Kalena")
	table.insert(arlenian_names,"Kimarna")
	table.insert(arlenian_names,"Kolira")
	table.insert(arlenian_names,"Lanerra")
	table.insert(arlenian_names,"Lamura")
	table.insert(arlenian_names,"Lavila")
	table.insert(arlenian_names,"Lavorna")
	table.insert(arlenian_names,"Lendura")
	table.insert(arlenian_names,"Limala")
	table.insert(arlenian_names,"Lorelle")
	table.insert(arlenian_names,"Mavelle")
	table.insert(arlenian_names,"Menola")
	table.insert(arlenian_names,"Merla")
	table.insert(arlenian_names,"Mitelle")
	table.insert(arlenian_names,"Mivelda")
	table.insert(arlenian_names,"Morainne")
	table.insert(arlenian_names,"Morda")
	table.insert(arlenian_names,"Morlena")
	table.insert(arlenian_names,"Nadela")
	table.insert(arlenian_names,"Naminda")
	table.insert(arlenian_names,"Nilana")
	table.insert(arlenian_names,"Nurelle")
	table.insert(arlenian_names,"Panela")
	table.insert(arlenian_names,"Pelnare")
	table.insert(arlenian_names,"Pilera")
	table.insert(arlenian_names,"Povelle")
	table.insert(arlenian_names,"Quilarre")
	table.insert(arlenian_names,"Ramila")
	table.insert(arlenian_names,"Renatha")
	table.insert(arlenian_names,"Rendelle")
	table.insert(arlenian_names,"Rinalda")
	table.insert(arlenian_names,"Riderla")
	table.insert(arlenian_names,"Rifalle")
	table.insert(arlenian_names,"Samila")
	table.insert(arlenian_names,"Salura")
	table.insert(arlenian_names,"Selinda")
	table.insert(arlenian_names,"Simanda")
	table.insert(arlenian_names,"Sodila")
	table.insert(arlenian_names,"Talinda")
	table.insert(arlenian_names,"Tamierre")
	table.insert(arlenian_names,"Telorre")
	table.insert(arlenian_names,"Terila")
	table.insert(arlenian_names,"Turalla")
	table.insert(arlenian_names,"Valerna")
	table.insert(arlenian_names,"Vilanda")
	table.insert(arlenian_names,"Vomera")
	table.insert(arlenian_names,"Wanelle")
	table.insert(arlenian_names,"Warenda")
	table.insert(arlenian_names,"Wilena")
	table.insert(arlenian_names,"Wodarla")
	table.insert(arlenian_names,"Yamelda")
	table.insert(arlenian_names,"Yelanda")
end
function setValorNames()
	valor_names = {}
	table.insert(valor_names,"VALOR-F04")
	table.insert(valor_names,"VALOR-F11")
	table.insert(valor_names,"VALOR-F16")
	table.insert(valor_names,"VALOR-F19")
	table.insert(valor_names,"VALOR-F22")
	table.insert(valor_names,"VALOR-F26")
	table.insert(valor_names,"VALOR-F37")
	table.insert(valor_names,"VALOR-F41")
	table.insert(valor_names,"VALOR-F44")
	table.insert(valor_names,"VALOR-F47")
	table.insert(valor_names,"VALOR-F51")
	table.insert(valor_names,"VALOR-F55")
	table.insert(valor_names,"VALOR-F59")
	table.insert(valor_names,"VALOR-F64")
	table.insert(valor_names,"VALOR-F69")
	table.insert(valor_names,"VALOR-F71")
	table.insert(valor_names,"VALOR-F75")
	table.insert(valor_names,"VALOR-F78")
	table.insert(valor_names,"VALOR-F81")
	table.insert(valor_names,"VALOR-F85")
end
function setHaloNames()
	halo_names = {}
	table.insert(halo_names,"HALO-F04")
	table.insert(halo_names,"HALO-F11")
	table.insert(halo_names,"HALO-F16")
	table.insert(halo_names,"HALO-F19")
	table.insert(halo_names,"HALO-F25")
	table.insert(halo_names,"HALO-F26")
	table.insert(halo_names,"HALO-F37")
	table.insert(halo_names,"HALO-F41")
	table.insert(halo_names,"HALO-F44")
	table.insert(halo_names,"HALO-F47")
	table.insert(halo_names,"HALO-F51")
	table.insert(halo_names,"HALO-F55")
	table.insert(halo_names,"HALO-F59")
	table.insert(halo_names,"HALO-F64")
	table.insert(halo_names,"HALO-F69")
	table.insert(halo_names,"HALO-F71")
	table.insert(halo_names,"HALO-F75")
	table.insert(halo_names,"HALO-F78")
	table.insert(halo_names,"HALO-F81")
	table.insert(halo_names,"HALO-F85")
end
function setAuroraNames()
	aurora_names = {}
	table.insert(aurora_names,"AUROR-F04")
	table.insert(aurora_names,"AUROR-F11")
	table.insert(aurora_names,"AUROR-F16")
	table.insert(aurora_names,"AUROR-F19")
	table.insert(aurora_names,"AUROR-F22")
	table.insert(aurora_names,"AUROR-F26")
	table.insert(aurora_names,"AUROR-F37")
	table.insert(aurora_names,"AUROR-F41")
	table.insert(aurora_names,"AUROR-F44")
	table.insert(aurora_names,"AUROR-F47")
	table.insert(aurora_names,"AUROR-F51")
	table.insert(aurora_names,"AUROR-F55")
	table.insert(aurora_names,"AUROR-F59")
	table.insert(aurora_names,"AUROR-F64")
	table.insert(aurora_names,"AUROR-F69")
	table.insert(aurora_names,"AUROR-F71")
	table.insert(aurora_names,"AUROR-F75")
	table.insert(aurora_names,"AUROR-F78")
	table.insert(aurora_names,"AUROR-F81")
	table.insert(aurora_names,"AUROR-F85")
end
function setInfernoNames()
	inferno_names = {}
	table.insert(inferno_names,"INFER-F04")
	table.insert(inferno_names,"INFER-F11")
	table.insert(inferno_names,"INFER-F16")
	table.insert(inferno_names,"INFER-F19")
	table.insert(inferno_names,"INFER-F22")
	table.insert(inferno_names,"INFER-F26")
	table.insert(inferno_names,"INFER-F37")
	table.insert(inferno_names,"INFER-F41")
	table.insert(inferno_names,"INFER-F44")
	table.insert(inferno_names,"INFER-F47")
	table.insert(inferno_names,"INFER-F51")
	table.insert(inferno_names,"INFER-F55")
	table.insert(inferno_names,"INFER-F59")
	table.insert(inferno_names,"INFER-F64")
	table.insert(inferno_names,"INFER-F69")
	table.insert(inferno_names,"INFER-F71")
	table.insert(inferno_names,"INFER-F75")
	table.insert(inferno_names,"INFER-F78")
	table.insert(inferno_names,"INFER-F81")
	table.insert(inferno_names,"INFER-F85")
end