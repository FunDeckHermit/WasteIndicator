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

  def web_add_main_button()
    webserver.content_send("<p></p><style>.r,div:has(+ .r),.r + *{display:none;}</style>")

    webserver.content_send("<p><form id='form1' style='display: block;' action='/form1' method='post'>")
    webserver.content_send("<p></p><label for='fpostcode'>Postcode:</label><input type='text' id='fpostcode' name='fpostcode'>")
    webserver.content_send("<p></p><label for='fhuisnummer'>Huisnummer:</label><input type='text' id='fhuisnummer' name='fhuisnummer'>")
    webserver.content_send("<p></p><button name='fzoekadres'>Zoek adres</button>")
    webserver.content_send("</form></p>")
    webserver.content_send("<p></p>" + persist.adres)

  end

  #- As we can add only one sensor method we will have to combine them besides all other sensor readings in one method -#
  def web_sensor()
    if webserver.has_arg("m_toggle_main")
      print("button pressed")
    end
  end

  def web_add_handler()
    webserver.on("/form1", / -> self.parse_form1())
  end

end
d1 = MyButtonMethods()
tasmota.add_driver(d1)
