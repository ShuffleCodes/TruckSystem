local db = dbConnect("sqlite", "db.db")
vehs = {}
trailers = {}
local types = {
    [1] = 584,
    [2] = 450,
    [3] = 435
}


addEvent("queryDatabase",true)
addEventHandler("queryDatabase", resourceRoot, function()
    if not isElement(client) then return end
    local q = dbQuery(db, "SELECT * FROM Trucks WHERE Serial = ?", getPlayerSerial(client))
    local w = dbPoll(q, -1)
    if #w == 0 then
        triggerClientEvent(client, "queryDatabase", resourceRoot, 0)
        dbQuery(db,"INSERT INTO Trucks (Serial, Points, Upg1, Upg2, Upg3) VALUES (?,0, 0, 0, 0)", getPlayerSerial(client))
        dbFree(q)
    else
        triggerClientEvent(client, "queryDatabase", resourceRoot, w[1].Points, w[1].Upg1, w[1].Upg2, w[1].Upg3)
    end
end)


addEvent("buyUpgrade", true)
addEventHandler("buyUpgrade", resourceRoot, function (type, cost)
    if not isElement(client) then return end

    if type == 1 then
        dbExec(db, "UPDATE Trucks SET Upg1 = 1, Points = Points - ? WHERE Serial = ?", cost, getPlayerSerial(client))
        outputChatBox("Zakupiłeś ulepszenie : Ulepszony zarobek!", client, 255, 255, 255)
    elseif type == 2 then
        dbExec(db, "UPDATE Trucks SET Upg2 = 1, Points = Points - ? WHERE Serial = ?", cost, getPlayerSerial(client))
        outputChatBox("Zakupiłeś ulepszenie : Unikalne ładunki!", client, 255, 255, 255)
    elseif type == 3 then
        dbExec(db, "UPDATE Trucks SET Upg3 = 1, Points = Points - ? WHERE Serial = ?", cost, getPlayerSerial(client))
        outputChatBox("Zakupiłeś ulepszenie : Ulepszona wytrzymałość!", client, 255, 255, 255)
    end
end)

addEvent("giveTransport",true)
addEventHandler("giveTransport", resourceRoot, function(type, weight, mnoznik)
    if not isElement(client) then return end

    vehs[client] = createVehicle(514, 869.38318, -1217.63049, 16.98354, 0, 0, -90)
    warpPedIntoVehicle(client, vehs[client])
    trailers[client] = createVehicle(types[tonumber(type)], 0 ,0 ,0, 0, 0, -90)
    attachTrailerToVehicle(vehs[client], trailers[client])
    outputChatBox("Jedź uważnie, każde uszkodzenie ładunku lub ciągnika spowoduje obniżenie wynagrodzenia!", client, 255, 255, 255)
    setVehicleHandling(trailers[client], "mass", getVehicleHandling(trailers[client])["mass"] + (weight * mnoznik))
end)

addEventHandler("onVehicleStartEnter", root, function(el)
    for _, v in pairs(vehs) do
        if v == source then
            cancelEvent()
        end
    end
end)

addEventHandler("onTrailerDetach", root, function(veh)
    attachTrailerToVehicle(veh, source)
end)

addEventHandler("onVehicleStartExit", root, function(plr, seat)
    if seat and seat == 0 then
        if vehs[plr] ~= source then return end
        if not getElementData(plr,"exiting:Truck") then
            setElementData(plr,"exiting:Truck", true)
            setTimer(function(plr)
                setElementData(plr,"exiting:Truck", false)
            end, 2000, 1, plr)
            outputChatBox("Próbujesz wysiąść z pojazdu co spowoduje zakończenie pracy bez wynagrodzenia! Wysiądź ponownie, aby potwierdzić decyzję.", plr, 255, 255, 255)
            cancelEvent()
            return
        end
        setElementData(plr, "exiting:Truck", false)
        local veh = source
        for _, v in pairs(vehs) do
            if v == veh then
                if isElement(vehs[plr]) then
                    destroyElement(vehs[plr])
                end
                if isElement(trailers[plr]) then
                    destroyElement(trailers[plr])
                end
                setTimer(function(plr)
                    setElementPosition(plr, 872.27826, -1210.12634, 16.97656)
                end, 1000, 1, plr)
                outputChatBox("Zakończyłeś zlecenie poprzez opuszczenie pojazdu, praca zresetowana.", plr, 255, 255, 255)
                triggerClientEvent(plr, "endJob:Truck", resourceRoot)
                break
            end
        end 
    end
end)

addEvent("damage:Truck",true)
addEventHandler("damage:Truck", resourceRoot, function(veh, loss, shield)
    if not isElement(client) then return end

    if vehs and vehs[getVehicleOccupant(veh,0)] then
        if shield and shield == 1 then
            damage = loss / 30
        else
            damage = loss / 15
        end
        triggerClientEvent(client, "damage:Truck", resourceRoot, damage)
    end
end)

addEvent("end:Truck", true)
addEventHandler("end:Truck", resourceRoot, function(tp, points, rem, xyz)
    if not isElement(client) then return end

    destroyElement(vehs[client])
    destroyElement(trailers[client])
    dbExec(db,"UPDATE Trucks SET Points = Points + ? WHERE Serial = ?", tonumber(points), getPlayerSerial(client))
    givePlayerMoney(client, rem)
    if tp then
        setTimer(function(client)
            setElementPosition(client, xyz[1], xyz[2], xyz[3])
        end, 900, 1, client)
    end
end)