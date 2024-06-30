# simple module
# use `import pickups`
import persist
import json
import path

var pickups = module("pickups")

var get_tomorrow_ISO_date = def()
  while(tasmota.rtc('local') == 0)
    tasmota.delay(30)
  end
  var x = tasmota.rtc('local') + (60*60*24)
  var datepart = string.split(tasmota.time_str(x), 11)[0]
  return f'{datepart}00:00:00'
end

var set_lights = def(waste_type)
  if(waste_type == "NONE")
    light.set({"power": false})
  elif(waste_type == "GREEN")
    light.set({"power": true, "rgb":"00FF00"})
  elif(waste_type == "PAPER")
    light.set({"power": true, "rgb":"0000FF"})
  elif(waste_type == "PACKAGES")
    light.set({"power": true, "rgb":"FF8400"})
  elif(waste_type == "GREY")
    light.set({"power": true, "rgb":"FF0000"})
  end
end

pickups.check = def()
  var db = map()

  print("Opening database for pickup dates")
  if(path.exists("/pickupdates.json"))
    var dbFile = open('/pickupdates.json', 'r')
      db = json.load(dbFile.readline())
    dbFile.close()
  end

  print("Comparing pickup dates to tomorrow")
  var tomorrowISO = get_tomorrow_ISO_date()
  var match = "NONE"

  print(tomorrowISO)
  for pu: db.find("GREEN")
    if(pu == tomorrowISO)
      print("Green waste has pickup tomorrow")
      match = "GREEN"
    end
  end
  for pu: db.find("PAPER")
    if(pu == tomorrowISO)
      print("Paper waste has pickup tomorrow")
      match = "PAPER"
    end
  end
  for pu: db.find("PACKAGES")
    if(pu == tomorrowISO)
      print("Packages waste has pickup tomorrow")
      match = "PACKAGES"
    end
  end
  for pu: db.find("GREY")
    if(pu == tomorrowISO)
      print("Grey waste has pickup tomorrow")
      match = "GREY"
    end
  end

  set_lights(match)
end

pickups.query_pickupAPI = def()
  var date = tasmota.time_dump(tasmota.rtc()['local'])
  var prevday = date["day"] - 1
  var nextyear_year = date["year"] + 1
  var yesterday = f'{date["year"]:02i}-{date["month"]:02i}-{prevday:02i}'
  var nextyear = f'{nextyear_year:02i}-{date["month"]:02i}-{date["day"]:02i}'
  var companyCode = "f8e2844a-095e-48f9-9f98-71fceb51d2c3"
  var querystring = f'{{"companyCode":"{companyCode}","startDate":"{yesterday}","endDate":"{nextyear}", "uniqueAddressID":"{persist.unid}"}}'
  var wc = webclient()
  
  wc.begin("https://wasteapi.ximmio.com/api/GetCalendar")
  wc.add_header("Content-Type","application/json")
  var code = wc.POST(querystring)
  var resp = wc.get_string()
  return [code, json.load(resp)]
end

pickups.parse_and_save = def(types_list)
  var pickup_data = map()
  var dbFile = open('/pickupdates.json', 'w')
  
  for pu_type: types_list
    var pu_type_str = pu_type["_pickupTypeText"]
    pickup_data[pu_type_str] = []
    for pu: pu_type["pickupDates"]
      pickup_data[pu_type_str].push(pu)
    end
  end

  dbFile.write(json.dump(pickup_data))
  dbFile.close()
end

pickups.gather = def()
  if(persist.has("unid") && tasmota.wifi().find('up'))
    print("Connected to the Internet and houseID set")
    var result = pickups.query_pickupAPI()
    print(result)
    if((result[0] == 200) && result[1]["status"])
      print("Conditions OK for parsing")
      pickups.parse_and_save(result[1]["dataList"])
    end
  end
end

return pickups
