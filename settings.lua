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
    [1] = {1237.48914, -946.57397, 42.70264},
    [2] = {1639.23682, -1116.55054, 23.90625},
    [3] = {2126.83545, -1136.34875, 25.48292},
    [4] = {2602.30322, -1032.60376, 70.37485},
    [5] = {2081.35278, 1219.15662, 10.82031},
    [6] = {1825.49585, 878.48291, 10.57741},
    [7] = {1735.15674, 1413.20886, 10.78628},
    [8] = {1607.23987, 1842.56909, 10.82031},
    [9] = {1635.28967, 2193.04810, 10.82031},
    [10] = {1899.55225, 2143.20581, 10.82031},
}


mnoznik_unique = 1.5
mnoznik_points = 0.02
mnoznik_upgrade_zarobek = 1.8
tp_before = true
masa_mnoznik = 300
start_marker = {866.74786, -1208.45911, 16}
tp_before_xyz = {875.25568, -1211.09192, 16.97656}