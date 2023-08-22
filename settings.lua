--typy naczep "trailer"
--1 - cysterna
--2 - "wanna" - przewóz towarów sypkich
--3 - kontener



shipments = {
    [1] = {towar = "Mleko", weight_min = 7, weight_max = 16, costs = math.random(900,2370), trailer = 1},
    [2] = {towar = "Pluszaki", weight_min = 2, weight_max = 10, costs = math.random(700,1800), trailer = 3},
    [3] = {towar = "Konstrukcje stalowe", weight_min = 20, weight_max = 29, costs = math.random(2900,3100), trailer = 3},
    [4] = {towar = "Piasek", weight_min = 10, weight_max = 21, costs = math.random(4500,5100), trailer = 2},
    [5] = {towar = "Żwir", weight_min = 12, weight_max = 24, costs = math.random(759,1310), trailer = 2},
    [6] = {towar = "Betonowe kabiny prysznicowe", weight_min = 15, weight_max = 32, costs = math.random(870,4500), trailer = 3},
    [7] = {towar = "Gaz ziemny", weight_min = 20, weight_max = 29, costs = math.random(1000,5600), trailer = 1},
    [8] = {towar = "Kartony", weight_min = 5, weight_max = 8, costs = math.random(500,1500), trailer = 3},
}

target = {
    [1] = {1184.36304, -1320.88257, 13.57400},
    [2] = {1720.05066, -1448.50879, 13.54688},
    [3] = {1729.44983, -1139.26135, 24.08594},
    [4] = {2100.40869, -1194.08423, 23.81632},
    [5] = {2705.93921, -1190.22876, 69.41296},
    [6] = {-2468.65894, 2439.26416, 15.65439},
    [7] = {2647.72046, 2809.45020, 36.32222},
}


mnoznik_unique = 1.5
mnoznik_points = 0.02
mnoznik_upgrade_zarobek = 1.8
tp_before = true
masa_mnoznik = 300
start_marker = {866.74786, -1208.45911, 16}