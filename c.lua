SW, SH = guiGetScreenSize()
local baseX = 3440
zoom = 1 
local minZoom = 2.2
if SW < baseX then
    zoom = math.min(minZoom, baseX/SW)
end

function isMouseInPosition ( x, y, width, height )
	if ( not isCursorShowing( ) ) then
		return false
	end
	local sx, sy = guiGetScreenSize ( )
	local cx, cy = getCursorPosition ( )
	local cx, cy = ( cx * sx ), ( cy * sy )
	
	return ( ( cx >= x and cx <= x + width ) and ( cy >= y and cy <= y + height ) )
end


local elements = {
    start_marker = createMarker(start_marker[1], start_marker[2], start_marker[3], "cylinder", 3, 255, 255, 255, 50),
    blip = createBlip(start_marker[1], start_marker[2], start_marker[3], 51, 1),
    active_transport,
    scale = {
        ["bg"] = {1133/zoom, 360/zoom, 1175/zoom, 720/zoom},
        ["b_towary"] = {1165/zoom, 683/zoom, 223/zoom, 63/zoom},
        ["b_upgrade"] = {1165/zoom, 766/zoom, 223/zoom, 63/zoom},
        ["b_close"] = {1165/zoom, 849/zoom, 223/zoom, 63/zoom},
        ["title"] = {1133/zoom, 365/zoom, 2308/zoom, 430/zoom},
        ["upg_1"] = {1440/zoom, 481/zoom, 265/zoom, 550/zoom},
        ["upg_2"] = {1729/zoom, 481/zoom, 265/zoom, 550/zoom},
        ["upg_3"] = {2018/zoom, 481/zoom, 265/zoom, 550/zoom},
        ["rows"] = {1488/zoom, 480/zoom, 770/zoom, 90/zoom},
        ["box"] = {1500/zoom, 490/zoom, 68/zoom, 68/zoom},
        ["name"] = {1576/zoom, 491/zoom, 2242/zoom, 530/zoom},
        ["dst"] = {1576/zoom, 524/zoom, 2242/zoom, 563/zoom},
        ["inf"] = {1490/zoom, 1015/zoom, 2256/zoom, 1073/zoom},
        ["bginfo"] = {1329/zoom, 10/zoom, 780/zoom, 260/zoom},
        ["box2"] = {1355/zoom, 70/zoom, 137/zoom, 137/zoom},
        ["inname"] = {1543/zoom, 49/zoom, 2085/zoom, 90/zoom},
        ["incost"] = {1543/zoom, 133/zoom, 2085/zoom, 174/zoom},
        ["inhp"] = {1543/zoom, 159/zoom, 2085/zoom, 200/zoom},
        ["inweight"] = {1543/zoom, 185/zoom, 2085/zoom, 226/zoom},
        ["indistance"] = {1543/zoom, 211/zoom, 2085/zoom, 252/zoom}
    },
    font = dxCreateFont("font.otf", 40/zoom, false, "antialiased"),
    font2 = dxCreateFont("font.otf", 25/zoom, false, "antialiased"),
    font3 = dxCreateFont("font.otf", 17/zoom, false, "antialiased"),
    title = "System transportowy",
    points = 0,
    page,
    zarobek = 0,
    unique = 0,
    shield = 0,
    costs = {
        [1] = 2000,
        [2] = 1500,
        [3] = 1500
    },
    towary = {},
}

function startRefresh()
    elements.towary = {}
    for i = 1, 5 do
        local index = math.random(1,#shipments)
        local start = {866.74786, -1208.45911, 16}
        local rnd = math.random(1,#target)
        local unique_rnd = math.random(1,2)
        local unique = false
        local cost = shipments[index]["costs"]
        if unique_rnd == 1 then
            cost = cost * mnoznik_upgrade_zarobek
            unique = true
        end
        local distance = getDistanceBetweenPoints3D(start[1], start[2], start[3], target[rnd][1],target[rnd][2],target[rnd][3])
        local dest = {target[rnd][1],target[rnd][2],target[rnd][3]}
        table.insert(elements.towary, {name = shipments[index]["towar"], weight = math.random(shipments[index]["weight_min"], shipments[index]["weight_max"]), cost = cost, distance = distance, trailer = shipments[index]["trailer"], dest = dest, unique = unique})
    end
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    setTimer(function()
        for i = 1, 5 do
            local start = {866.74786, -1208.45911, 16}
            local rnd = math.random(1,#target)
            local unique_rnd = math.random(1,2)
            local unique = false
            local distance = getDistanceBetweenPoints3D(start[1], start[2], start[3], target[rnd][1],target[rnd][2],target[rnd][3])
            local dest = {target[rnd][1],target[rnd][2],target[rnd][3]}
            local cost = shipments[i]["costs"]
            if unique_rnd == 1 then
                cost = cost * mnoznik_upgrade_zarobek
                unique = true
            end
            table.insert(elements.towary, {name = shipments[i]["towar"], weight = math.random(shipments[i]["weight_min"], shipments[i]["weight_max"]), cost = cost, distance = distance, trailer = shipments[i]["trailer"], dest = dest, unique = shipments[i]["unique"]})
        end
    end, 500, 1)
    setTimer(function()
        startRefresh()
    end,5000,0)
end)

local function buyNewUpgrade(el,type)
    if el and type then
        triggerServerEvent("buyUpgrade", el, type, elements.costs[tonumber(type)])
        if type == 1 then
            elements.zarobek = 1
            elements.points = elements.points - elements.costs[tonumber(type)]
        elseif type == 2 then
            elements.unique = 1
            elements.points = elements.points - elements.costs[tonumber(type)]
        elseif type == 3 then
            elements.shield = 1
            elements.points = elements.points - elements.costs[tonumber(type)]
        end
        elements.title = "Ulepszenia pracy - #ffc107"..(elements.points).."#ffffff punktów pracy"
    end
end

local function click(b,s)
    if b == "left" and s == "down" then
        if isMouseInPosition(elements.scale.b_close[1], elements.scale.b_close[2], elements.scale.b_close[3], elements.scale.b_close[4]) then
            close(localPlayer)
            return
        elseif isMouseInPosition(elements.scale.b_towary[1], elements.scale.b_towary[2], elements.scale.b_towary[3], elements.scale.b_towary[4]) then
            elements.title = "Rynek ładunków"
            elements.page = 0
            return
        elseif isMouseInPosition(elements.scale.b_upgrade[1], elements.scale.b_upgrade[2], elements.scale.b_upgrade[3], elements.scale.b_upgrade[4]) then
            elements.title = "Ulepszenia pracy - #ffc107"..(elements.points).."#ffffff punktów"
            elements.page = 1
            return
        end
        if elements.page then
            if elements.page == 1 then
                if isMouseInPosition(elements.scale.upg_1[1], elements.scale.upg_1[2], elements.scale.upg_1[3], elements.scale.upg_1[4]) then
                    --zarobek
                    if elements.zarobek and elements.zarobek == 1 then
                        return outputChatBox("Posiadasz już Ulepszony zarobek!", 255, 255, 255)
                    end
                    if elements.points and elements.points < tonumber(elements.costs[1]) then
                        return outputChatBox("Nie posiadasz "..tonumber(elements.costs[1]).." punktów", 255,255,255)
                    end
                    buyNewUpgrade(localPlayer, 1)
                end
    
                if isMouseInPosition(elements.scale.upg_2[1], elements.scale.upg_2[2], elements.scale.upg_2[3], elements.scale.upg_2[4]) then
                    --unikalne
                    if elements.unique and elements.unique == 1 then
                        return outputChatBox("Posiadasz już Unikalne ładunki!", 255, 255, 255)
                    end
                    if elements.points and elements.points < tonumber(elements.costs[2]) then
                        return outputChatBox("Nie posiadasz "..tonumber(elements.costs[2]).." punktów", 255,255,255)
                    end
                    buyNewUpgrade(localPlayer, 2)
                end
    
                if isMouseInPosition(elements.scale.upg_3[1], elements.scale.upg_3[2], elements.scale.upg_3[3], elements.scale.upg_3[4]) then
                    --wytrzymalosc
                    if elements.shield and elements.shield == 1 then
                        return outputChatBox("Posiadasz już Ulepszoną wytrzymałość!", 255, 255, 255)
                    end
                    if elements.points and elements.points < tonumber(elements.costs[3]) then
                        return outputChatBox("Nie posiadasz "..tonumber(elements.costs[3]).." punktów", 255,255,255)
                    end
                    buyNewUpgrade(localPlayer, 3)
                end
            elseif elements.page == 0 then
                offset = 0
                for i = 1,5 do
                    if isMouseInPosition(elements.scale.rows[1], elements.scale.rows[2] + offset, elements.scale.rows[3], elements.scale.rows[4]) then
                        if elements.towary[i]["unique"] and elements.unique == 0 then
                            return outputChatBox("Nie posiadasz ulepszenia na unikatowe ładunki!", 255, 255, 255)
                        end
                        local name = elements.towary[i]["name"]
                        local weight = elements.towary[i]["weight"]
                        local cost = elements.towary[i]["cost"]
                        if (elements.towary[i]["unique"]) then
                            cost = math.floor(cost * tonumber(mnoznik_unique))
                        end
                        blip = createBlip(elements.towary[i]["dest"][1],elements.towary[i]["dest"][2],elements.towary[i]["dest"][3],41,2)
                        local rem = math.floor(cost * (math.floor(elements.towary[i]["distance"]) / 1000))
                        elements.active_transport = {name = name, cost = rem, weight = weight, stan = 100, dest = elements.towary[i]["dest"]}
                        triggerServerEvent("giveTransport", localPlayer, elements.towary[i]["trailer"], weight, masa_mnoznik )
                        local target_marker = createMarker(elements.towary[i]["dest"][1],elements.towary[i]["dest"][2],elements.towary[i]["dest"][3], "cylinder", 4, 255, 255, 255, 50)
                        setElementData(target_marker,"Truck:Target", localPlayer)
                        addEventHandler("onClientRender", root, render_info)
                        close(localPlayer)
                        break
                    end
                    offset = offset + 110/zoom
                end
            end
        end
    end
end

addEventHandler("onClientVehicleDamage", root, function(_,_,loss)
    triggerServerEvent("damage:Truck", localPlayer, source, loss, elements.shield)
end)

addEvent("damage:Truck",true)
addEventHandler("damage:Truck", root, function(loss)
    if source == localPlayer then
        local data = elements.active_transport
        if data then
            data["stan"] = tonumber(data["stan"]) - loss
        end
        elements.active_transport = data
    end
end)

function close(el)
    if el == localPlayer then
        showCursor(false)
        removeEventHandler("onClientRender", root, render_gui)
        removeEventHandler("onClientClick", root, click)
        elements.title = "System transportowy"
        elements.points = 0
        elements.page = null
    end
end


function render_info()
    if elements.active_transport then
        dxDrawImage(elements.scale.bginfo[1], elements.scale.bginfo[2], elements.scale.bginfo[3], elements.scale.bginfo[4], "img/bginfo.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
        dxDrawImage(elements.scale.box2[1], elements.scale.box2[2], elements.scale.box2[3], elements.scale.box2[4], "img/box.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
        dxDrawText(elements.active_transport.name, elements.scale.inname[1], elements.scale.inname[2], elements.scale.inname[3], elements.scale.inname[4], tocolor(255, 255, 255, 255), 0.5, elements.font, "center", "center", false, true, false, false, false)
        local changeRem = math.floor(elements.active_transport.cost * (math.floor(elements.active_transport.stan)/100))
        dxDrawText("Wynagrodzenie: "..elements.active_transport.cost.." #ffc107$", elements.scale.incost[1], elements.scale.incost[2], elements.scale.incost[3], elements.scale.incost[4], tocolor(255, 255, 255, 255), 0.5, elements.font2, "center", "center", false, true, false, true, false)
        dxDrawText("Stan ładunku: "..math.floor(elements.active_transport.stan).." #ffc107%#ffffff ("..changeRem.." #ffc107$#ffffff)", elements.scale.inhp[1], elements.scale.inhp[2], elements.scale.inhp[3], elements.scale.inhp[4], tocolor(255, 255, 255, 255), 0.5, elements.font2, "center", "center", false, true, false, true, false)
        dxDrawText("Waga ładunku: "..elements.active_transport.weight.." #ffc107ton", elements.scale.inweight[1], elements.scale.inweight[2], elements.scale.inweight[3], elements.scale.inweight[4], tocolor(255, 255, 255, 255), 0.5, elements.font2, "center", "center", false, true, false, true, false)
        local dx,dy,dz = elements.active_transport.dest[1], elements.active_transport.dest[2], elements.active_transport.dest[3]
        local x,y,z = getElementPosition(localPlayer)
        local dest = getDistanceBetweenPoints3D(x, y, z, dx,dy,dz)
        dxDrawText("Cel: "..string.format("%.2f", dest / 1000).." #ffc107km", elements.scale.indistance[1], elements.scale.indistance[2], elements.scale.indistance[3], elements.scale.indistance[4], tocolor(255, 255, 255, 255), 0.5, elements.font2, "center", "center", false, true, false, true, false)
    end
end

function render_gui()
    dxDrawImage(elements.scale.bg[1], elements.scale.bg[2], elements.scale.bg[3], elements.scale.bg[4], "img/bg.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
    dxDrawText(elements.title, elements.scale.title[1], elements.scale.title[2], elements.scale.title[3], elements.scale.title[4], tocolor(255, 255, 255, 255), 0.5, elements.font, "center", "center", false, false, false, true, false)

    if isMouseInPosition(elements.scale.b_towary[1], elements.scale.b_towary[2], elements.scale.b_towary[3], elements.scale.b_towary[4]) then
        dxDrawImage(elements.scale.b_towary[1], elements.scale.b_towary[2], elements.scale.b_towary[3], elements.scale.b_towary[4], "img/towary_a.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
    else
        dxDrawImage(elements.scale.b_towary[1], elements.scale.b_towary[2], elements.scale.b_towary[3], elements.scale.b_towary[4], "img/towary.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
    end
    
    if isMouseInPosition(elements.scale.b_upgrade[1], elements.scale.b_upgrade[2], elements.scale.b_upgrade[3], elements.scale.b_upgrade[4]) then
        dxDrawImage(elements.scale.b_upgrade[1], elements.scale.b_upgrade[2], elements.scale.b_upgrade[3], elements.scale.b_upgrade[4], "img/upgrade_a.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
    else
        dxDrawImage(elements.scale.b_upgrade[1], elements.scale.b_upgrade[2], elements.scale.b_upgrade[3], elements.scale.b_upgrade[4], "img/upgrade.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
    end
    
    if isMouseInPosition(elements.scale.b_close[1], elements.scale.b_close[2], elements.scale.b_close[3], elements.scale.b_close[4]) then
        dxDrawImage(elements.scale.b_close[1], elements.scale.b_close[2], elements.scale.b_close[3], elements.scale.b_close[4], "img/close_a.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
    else
        dxDrawImage(elements.scale.b_close[1], elements.scale.b_close[2], elements.scale.b_close[3], elements.scale.b_close[4], "img/close.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
    end

    if elements.page then
        if elements.page == 1 then
            if isMouseInPosition(elements.scale.upg_1[1], elements.scale.upg_1[2], elements.scale.upg_1[3], elements.scale.upg_1[4]) or elements.zarobek == 1 then
                dxDrawImage(elements.scale.upg_1[1], elements.scale.upg_1[2], elements.scale.upg_1[3], elements.scale.upg_1[4], "img/unique2_a.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
            else
                dxDrawImage(elements.scale.upg_1[1], elements.scale.upg_1[2], elements.scale.upg_1[3], elements.scale.upg_1[4], "img/unique2.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
            end

            if isMouseInPosition(elements.scale.upg_2[1], elements.scale.upg_2[2], elements.scale.upg_2[3], elements.scale.upg_2[4]) or elements.unique == 1 then
                dxDrawImage(elements.scale.upg_2[1], elements.scale.upg_2[2], elements.scale.upg_2[3], elements.scale.upg_2[4], "img/unique_a.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
            else
                dxDrawImage(elements.scale.upg_2[1], elements.scale.upg_2[2], elements.scale.upg_2[3], elements.scale.upg_2[4], "img/unique.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
            end

            if isMouseInPosition(elements.scale.upg_3[1], elements.scale.upg_3[2], elements.scale.upg_3[3], elements.scale.upg_3[4]) or elements.shield == 1 then
                dxDrawImage(elements.scale.upg_3[1], elements.scale.upg_3[2], elements.scale.upg_3[3], elements.scale.upg_3[4], "img/unique3_a.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
            else
                dxDrawImage(elements.scale.upg_3[1], elements.scale.upg_3[2], elements.scale.upg_3[3], elements.scale.upg_3[4], "img/unique3.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
            end
        elseif elements.page == 0 then
            offset = 0
            dxDrawText("Po PODWÓJNYM kliknięciu na towar, rozpoczniesz trasę", elements.scale.inf[1], elements.scale.inf[2] + offset, elements.scale.inf[3], elements.scale.inf[4], tocolor(255, 255, 255, 255), 0.5, elements.font3, "center", "center", false, false, false, false, false)
            for i = 1,5 do
                local cost = elements.towary[i]["cost"]
                if isMouseInPosition(elements.scale.rows[1], elements.scale.rows[2] + offset, elements.scale.rows[3], elements.scale.rows[4]) then
                    dxDrawImage(elements.scale.rows[1], elements.scale.rows[2] + offset, elements.scale.rows[3], elements.scale.rows[4], "img/rows_a.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
                else
                    dxDrawImage(elements.scale.rows[1], elements.scale.rows[2] + offset, elements.scale.rows[3], elements.scale.rows[4], "img/rows.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
                end
                if elements.towary[i]["unique"] then
                    cost = math.floor(cost * tonumber(mnoznik_unique))
                    dxDrawImage(elements.scale.box[1], elements.scale.box[2] + offset, elements.scale.box[3], elements.scale.box[4], "img/box_unique.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
                else
                    dxDrawImage(elements.scale.box[1], elements.scale.box[2] + offset, elements.scale.box[3], elements.scale.box[4], "img/box.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
                end
                dxDrawText(elements.towary[i]["name"] .. " #606060("..elements.towary[i]["weight"].." ton) ("..(math.floor(elements.towary[i]["distance"])/1000).." km)", elements.scale.name[1], elements.scale.name[2] + offset, elements.scale.name[3], elements.scale.name[4] + offset, tocolor(255, 255, 255, 255), 0.5, elements.font2, "center", "center", false, false, false, true, false)
                dxDrawText(cost .. "#ffc107 $#ffffff/km\nWynagrodzenie : " .. math.floor(cost * (math.floor(elements.towary[i]["distance"]) / 1000)) .. " #ffc107$", elements.scale.dst[1], elements.scale.dst[2] + offset, elements.scale.dst[3], elements.scale.dst[4] + offset, tocolor(255, 255, 255, 255), 0.5, elements.font3, "center", "center", false, false, false, true, false)

                offset = offset + 110/zoom
            end
        end
    end
end

function targetHit(el)
    if el == localPlayer then
        if getElementType(el) == "player" then
            local trans = elements.active_transport
            if trans then
                local rem = math.floor(trans.cost * (math.floor(trans.stan)/100))
                local points = math.floor(tonumber(rem) * tonumber(mnoznik_points))
                outputChatBox("Zakończyłeś zlecenie, na Twoje konto wpływa "..rem.." $ i "..points.." punktów.", 255, 255, 255)
                triggerServerEvent("end:Truck", el, tp_before, points, rem)
                removeEventHandler("onClientRender", root, render_info)
                if isElement(blip) then
                    destroyElement(blip)
                end
                for _,v in ipairs(getElementsByType("marker"))do
                    if getElementData(v, "Truck:Target") then
                        if getElementData(v, "Truck:Target") == el then
                            destroyElement(v)
                        end
                    end
                end
                elements.active_transport = null
            end
        end
    end
end

addEventHandler("onClientMarkerHit", root, function(el)
    if el and getElementType(el) == "player" then
        if getElementData(source, "Truck:Target") then
            targetHit(el)
        else
            if source == elements.start_marker then
                if elements.active_transport then return end
                showCursor(true)
                triggerServerEvent("queryDatabase", el)
            end
        end
    end
end)

addEvent("queryDatabase", true)
addEventHandler("queryDatabase", root, function(points, u1, u2, u3)
    if source == localPlayer then
        addEventHandler("onClientRender", root, render_gui)
        addEventHandler("onClientClick", root, click)
        elements.points = points
        elements.zarobek = u1
        elements.unique = u2
        elements.shield = u3
    end
end)

addEvent("endJob:Truck", true)
addEventHandler("endJob:Truck", root, function()
    if source == localPlayer then
        elements.active_transport = null
        removeEventHandler("onClientRender", root, render_info)
        if isElement(blip) then
            destroyElement(blip)
        end
    end
end)