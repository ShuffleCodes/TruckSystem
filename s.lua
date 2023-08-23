local db = dbConnect("sqlite", "db.db")
vehs = {}
trailers = {}
local types = {
    [1] = 584,
    [2] = 450,
    [3] = 435
}

addEvent("queryDatabase",true)
addEventHandler("queryDatabase", root, function()
    local q = dbQuery(db, "SELECT * FROM Trucks WHERE Serial = ?", getPlayerSerial(source))
    local w = dbPoll(q, -1)
    if #w == 0 then
        triggerClientEvent("queryDatabase", source, 0)
        dbQuery(db,"INSERT INTO Trucks (Serial, Points, Upg1, Upg2, Upg3) VALUES (?,0, 0, 0, 0)", getPlayerSerial(source))
        dbFree(q)
    else
        triggerClientEvent("queryDatabase", source, w[1].Points, w[1].Upg1, w[1].Upg2, w[1].Upg3)
    end
end)


addEvent("buyUpgrade", true)
addEventHandler("buyUpgrade", root, function (type, cost)
    if type == 1 then
        dbExec(db, "UPDATE Trucks SET Upg1 = 1, Points = Points - ? WHERE Serial = ?", cost, getPlayerSerial(source))
        outputChatBox("Zakupiłeś ulepszenie : Ulepszony zarobek!", source, 255, 255, 255)
    elseif type == 2 then
        dbExec(db, "UPDATE Trucks SET Upg2 = 1, Points = Points - ? WHERE Serial = ?", cost, getPlayerSerial(source))
        outputChatBox("Zakupiłeś ulepszenie : Unikalne ładunki!", source, 255, 255, 255)
    elseif type == 3 then
        dbExec(db, "UPDATE Trucks SET Upg3 = 1, Points = Points - ? WHERE Serial = ?", cost, getPlayerSerial(source))
        outputChatBox("Zakupiłeś ulepszenie : Ulepszona wytrzymałość!", source, 255, 255, 255)
    end
end)

addEvent("giveTransport",true)
addEventHandler("giveTransport", root, function(type, weight, mnoznik)
    vehs[source] = createVehicle(514, 869.38318, -1217.63049, 16.98354, 0, 0, -90)
    warpPedIntoVehicle(source, vehs[source])
    trailers[source] = createVehicle(types[tonumber(type)], 0 ,0 ,0, 0, 0, -90)
    attachTrailerToVehicle(vehs[source], trailers[source])
    outputChatBox("Jedź uważnie, każde uszkodzenie ładunku lub ciągnika spowoduje obniżenie wynagrodzenia!", source, 255, 255, 255)
    setVehicleHandling(trailers[source], "mass", getVehicleHandling(trailers[source])["mass"] + (weight * mnoznik))
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

addEventHandler("onPlayerVehicleExit", root, function(veh, seat)
    if seat and seat == 0 then
        for _, v in pairs(vehs) do
            if v == veh then
                if isElement(vehs[source]) then
                    destroyElement(vehs[source])
                end
                if isElement(trailers[source]) then
                    destroyElement(trailers[source])
                end
                setElementPosition(source, 872.27826, -1210.12634, 16.97656)
                outputChatBox("Zakończyłeś zlecenie poprzez opuszczenie pojazdu, praca zresetowana.", source, 255, 255, 255)
                triggerClientEvent("endJob:Truck", source)
                break
            end
        end 
    end
end)

addEvent("damage:Truck",true)
addEventHandler("damage:Truck", root, function(veh, loss, shield)
    if vehs and vehs[getVehicleOccupant(veh,0)] then
        if shield and shield == 1 then
            damage = loss / 30
        else
            damage = loss / 15
        end
        triggerClientEvent("damage:Truck", source, damage)
    end
end)

addEvent("end:Truck", true)
addEventHandler("end:Truck", root, function(tp, points, rem, xyz)
    destroyElement(vehs[source])
    destroyElement(trailers[source])
    local s = dbQuery(db,"UPDATE Trucks SET Points = Points + ? WHERE Serial = ?", tonumber(points), getPlayerSerial(source))
    givePlayerMoney(source, rem)
    if tp then
        setTimer(function(source)
            setElementPosition(source, xyz[1], xyz[2], xyz[3])
        end, 900, 1, source)
    end
    dbFree(s)
end)