# Waste Indicator
Scripts that modify Tasmota to interact with the Ximmio waste API. The color of an LED is set the day before a pickup date. It should also be easy to integrate into Home Assistant. 

<img src="https://github.com/FunDeckHermit/WasteIndicator/assets/5075692/daa3b6ec-65e7-4bce-ad62-c1d5df871f93" alt="image" width="300" height="auto">
<img src="https://github.com/FunDeckHermit/WasteIndicator/assets/5075692/0be5ab7f-91a1-466a-9271-e1e5757cb129" alt="image" width="300" height="auto">

## What it does:
* Sets the color of an RGB LED on the day before a pickup date
* Hides the RGB LED controls from Tasmota's main page
* Adds a form to set home adres
* Queries Ximmio's API to get the uniqueID of the adres
* Queries pickup dates every 12 hours

## To-do
* Add a button to turn the LED off
* Save configuration during reset
* Actually test it
* Integrate into Home Assistant
* Don't use the companyCode of my local waste collector
* Test with a Tasmota compatible RGB light bulb
