/*
  user_config_override.h - user configuration overrides my_user_config.h for Tasmota

  Copyright (C) 2021  Theo Arends

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef _USER_CONFIG_OVERRIDE_H_
#define _USER_CONFIG_OVERRIDE_H_

/*****************************************************************************************************\
 * USAGE:
 *   To modify the stock configuration without changing the my_user_config.h file:
 *   (1) copy this file to "user_config_override.h" (It will be ignored by Git)
 *   (2) define your own settings below
 *
 ******************************************************************************************************
 * ATTENTION:
 *   - Changes to SECTION1 PARAMETER defines will only override flash settings if you change define CFG_HOLDER.
 *   - Expect compiler warnings when no ifdef/undef/endif sequence is used.
 *   - You still need to update my_user_config.h for major define USE_MQTT_TLS.
 *   - All parameters can be persistent changed online using commands via MQTT, WebConsole or Serial.
\*****************************************************************************************************/

//#define FIRMWARE_LITE

#undef  MY_LANGUAGE
#define MY_LANGUAGE            nl_NL           // Dutch in the Nederland

#undef MQTT_BUTTONS
#define MQTT_BUTTONS           true

#undef KEY_HOLD_TIME
#define KEY_HOLD_TIME 8

#undef APP_BLINKTIME
#define APP_BLINKTIME 3

#undef  USE_HOME_ASSISTANT
#define USE_HOME_ASSISTANT

#undef HOME_ASSISTANT_DISCOVERY_PREFIX
#define HOME_ASSISTANT_DISCOVERY_PREFIX   "homeassistant"  // Home Assistant discovery prefix

#undef HOME_ASSISTANT_LWT_TOPIC
#define HOME_ASSISTANT_LWT_TOPIC   "homeassistant/status"  // home Assistant Birth and Last Will Topic (default = homeassistant/status)

#undef HOME_ASSISTANT_LWT_SUBSCRIBE
#define HOME_ASSISTANT_LWT_SUBSCRIBE    true               // Subscribe to Home Assistant Birth and Last Will Topic (default = true)

#undef USE_WS2812_HARDWARE
#define USE_WS2812_HARDWARE  NEO_HW_SK6812

#undef USE_WS2812_CTYPE
#define USE_WS2812_CTYPE     NEO_GRBW

#undef USE_BERRY_DEBUG
#define USE_BERRY_DEBUG

#undef USER_TEMPLATE
#define USER_TEMPLATE "{\"NAME\":\"Vuilnis Indicator\",\"GPIO\":[32,1,1,1376,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,0,1,1,1,0,0,0,0,1,1,1,1,1,0,0,1],\"FLAG\":0,\"BASE\":1}"  // [Template] Set JSON template

#undef MODULE
#define MODULE USER_MODULE

#undef FALLBACK_MODULE
#define FALLBACK_MODULE USER_MODULE

#undef PROJECT
#define PROJECT "VuilnisIndicator"

#endif  // _USER_CONFIG_OVERRIDE_H_
