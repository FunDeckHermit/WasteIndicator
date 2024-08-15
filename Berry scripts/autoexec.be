import webserver
import persist
import string
import json
import scheduler

class MyButtonMethods
  def queryAPI(postcode,huisnummer)
    print(postcode, huisnummer)

    var wc = webclient()
    wc.begin("https://wasteapi.ximmio.com/api/GetAddress")
    wc.add_header("Content-Type","application/json")
    var code = wc.POST(f'{{"companyCode":"f8e2844a-095e-48f9-9f98-71fceb51d2c3","postCode":"{postcode}","houseNumber":{huisnummer}}}')
    var resp = wc.get_string()
    print(resp)
    return [code, json.load(resp)]
  end

  def get_adres()
    print("Zoeken naar adres")
    var postcode = webserver.arg("fpostcode")
    var huisnummer = webserver.arg("fhuisnummer")
    huisnummer = str(int(huisnummer))
    if((postcode == "") || (huisnummer == ""))
      return [400, ""]
    end

    var result = self.queryAPI(postcode,huisnummer)
    if(result[0] == 200)
      var status = result[1]["status"]
      var dataList = result[1]["dataList"]
      if(status)
        return [200, dataList]
      end
    end
    return [422, ""]
  end

  def parse_form1()
    var res = self.get_adres()
    print(res[0])
    if(res[0] == 400)
      persist.adres = "Error: postcode of huisnummer ontbreken"
    end
    if(res[0] == 422)
      persist.adres = "Error: Er ging iets fout"
    end
    if(res[0] == 200)
      print(res[1])
      if(size(res[1]) == 0)
        persist.adres = "Error: adres niet gevonden"
      else
        print(res[1][0])
        persist.straat = res[1][0]["Street"]
        persist.huisnummer = res[1][0]["HouseNumber"]
        persist.stad = res[1][0]["City"]
        persist.unid = res[1][0]["UniqueId"]
        persist.adres = f"{persist.straat} {persist.huisnummer}, {persist.stad}"
      end
    end

    persist.save()
    tasmota.cmd("restart 1")
    webserver.redirect("/")
  end

  def parse_form2()
    persist.checktime = webserver.arg("fchecktime")
    persist.brightness = webserver.arg("fbrightness")
    light.set({'bri': int(webserver.arg("fbrightness"))})
    persist.save()
    webserver.redirect("/")
  end


  def web_add_main_button()
    webserver.content_send("<p></p><style>.r,div:has(+ .r),.r + *{display:none;}</style>")

    webserver.content_send("<p><form id='form1' style='display: block;' action='/form1' method='post'><fieldset>")
    webserver.content_send("<legend>Adresgegevens:</legend>")
    webserver.content_send("<p></p><label for='fpostcode'>Postcode:</label><input type='text' id='fpostcode' name='fpostcode'>")
    webserver.content_send("<p></p><label for='fhuisnummer'>Huisnummer:</label><input type='text' id='fhuisnummer' name='fhuisnummer'>")
    webserver.content_send("<p></p><button name='fzoekadres'>Zoek adres</button>")
    webserver.content_send("<p></p>" + persist.find("adres", ""))
    webserver.content_send("</fieldset></form></p>")

    webserver.content_send("<p><form id='form2' style='display: block;' action='/form2' method='post'><fieldset>")
    webserver.content_send("<legend>LED Indicator:</legend>")
    webserver.content_send("<p></p><label for='fchecktime'>Vorige dag indicator AAN tijd:</label><input type='text' id='fchecktime' name='fchecktime' value='" + persist.find("checktime", "14:00") + "'>")
    webserver.content_send("<p></p><label for='fbrightness'>Indicator helderheid:</label><input type='range' min='1' max='255' id='fbrightness' name='fbrightness' value='" + persist.find("brightness", "255") + "'>")
    webserver.content_send("<p></p><button name='fsetminorconfigs'>Sla configuratie op</button>")
    webserver.content_send("</fieldset></form></p>")
    webserver.content_send("<div style='max-width: 360px;margin: 0 auto'>")
    webserver.content_send("<b>Informatie:</b>")
    webserver.content_send("<p>Deze vuilnis indicator haalt elke dag actuele ophaaldata op. Op de dag voor een ophaalmoment gaat de indicator aan.</p>")
    webserver.content_send("<p>Door de knop 8 seconden ingedrukt te houden gaat dit apparaat terug naar fabrieksinstellingen. Hierna kan verbonden worden met een nieuw WiFi netwerk.</p>")
    webserver.content_send("<p>Het apparaat draait open-source firmware genaamd Tasmota en kan uitgebreid worden met sensoren en verbinden met Home Assistant.</p>")
    webserver.content_send("</div>")
  end

  #- As we can add only one sensor method we will have to combine them besides all other sensor readings in one method -#
  def web_sensor()
    if webserver.has_arg("m_toggle_main")
      print("button pressed")
    end
  end

  def web_add_handler()
    webserver.on("/form1", / -> self.parse_form1())
    webserver.on("/form2", / -> self.parse_form2())
  end

end
d1 = MyButtonMethods()
tasmota.add_driver(d1)

tasmota.add_rule("Button1#Action=SINGLE", def (value) print("Toggling LED OFF") light.set({"power": false}) end, 1)
tasmota.add_rule("Button1#Action=DOUBLE", def (value) print("Device Restarting") tasmota.cmd("Restart 1") end, 2)
tasmota.add_rule("Button1#Action=HOLD", def (value) print("Device Resetting")  light.set({"power": false, "bri": "255", "rgb":"AAAAAA"}) tasmota.cmd("Power 3") end, 3)
tasmota.add_rule("Button1#Action=CLEAR", def (value) print("Reset Aborted")  tasmota.cmd("Power 4") light.set({"power": false}) end, 4)