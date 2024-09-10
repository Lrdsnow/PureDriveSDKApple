/*
 * Copyright (c) 2014 Anki, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifdef __cplusplus
# define ANKI_BEGIN_DECL extern "C" {
# define ANKI_END_DECL }
#else
 /** Start declarations in C mode */
# define ANKI_BEGIN_DECL /* empty */
 /** End declarations in C mode */
# define ANKI_END_DECL /* empty */
#endif

#ifndef INCLUDE_protocol_h
#define INCLUDE_protocol_h

#include <stdint.h>

ANKI_BEGIN_DECL

#define ANKI_VEHICLE_MSG_MAX_SIZE            20
#define ANKI_VEHICLE_MSG_PAYLOAD_MAX_SIZE    18
#define ANKI_VEHICLE_MSG_BASE_SIZE            1

/** Identifier for a vehicle message */
enum {
    // BLE Connections
    ANKI_VEHICLE_MSG_C2V_DISCONNECT = 0x0d,

    // Ping request / response
    ANKI_VEHICLE_MSG_C2V_PING_REQUEST = 0x16,
    ANKI_VEHICLE_MSG_V2C_PING_RESPONSE = 0x17,

    // Messages for checking vehicle version info
    ANKI_VEHICLE_MSG_C2V_VERSION_REQUEST = 0x18,
    ANKI_VEHICLE_MSG_V2C_VERSION_RESPONSE = 0x19,

    // Battery level
    ANKI_VEHICLE_MSG_C2V_BATTERY_LEVEL_REQUEST = 0x1a,
    ANKI_VEHICLE_MSG_V2C_BATTERY_LEVEL_RESPONSE = 0x1b,

    // Lights
    ANKI_VEHICLE_MSG_C2V_SET_LIGHTS = 0x1d,

    // Driving Commands
    ANKI_VEHICLE_MSG_C2V_SET_SPEED = 0x24,
    ANKI_VEHICLE_MSG_C2V_CHANGE_LANE = 0x25,
    ANKI_VEHICLE_MSG_C2V_CANCEL_LANE_CHANGE = 0x26,
    ANKI_VEHICLE_MSG_C2V_TURN_180 = 0x32,
    ANKI_VEHICLE_MSG_C2V_SET_OFFSET_FROM_ROAD_CENTER = 0x2c,

    // Vehicle position notifications
    ANKI_VEHICLE_MSG_V2C_LOCALIZATION_POSITION_UPDATE = 0x27,
    ANKI_VEHICLE_MSG_V2C_LOCALIZATION_TRANSITION_UPDATE = 0x29,
    ANKI_VEHICLE_MSG_V2C_VEHICLE_DELOCALIZED = 0x2b,
    ANKI_VEHICLE_MSG_V2C_OFFSET_FROM_ROAD_CENTER_UPDATE = 0x2d,
    ANKI_VEHICLE_MSG_V2C_SPEED_UPDATE = 0x36,
    ANKI_VEHICLE_MSG_V2C_TRACK_SPECIAL_TRIGGER = 0x53,
    
    // Turn Command
    ANKI_VEHICLE_MSG_C2V_TURN = 0x32, // 50

    // Light Patterns
    ANKI_VEHICLE_MSG_C2V_LIGHTS_PATTERN = 0x33,

    // SDK Mode
    ANKI_VEHICLE_MSG_C2V_SDK_MODE = 0x90,

    // Additional Identifiers
    ANKI_VEHICLE_MSG_V2C_CAR_ERROR = 0x2a,
    ANKI_VEHICLE_MSG_V2C_CAR_COLLISION = 0x4d,
    ANKI_VEHICLE_MSG_V2C_CAR_MESSAGE_CYCLE_OVERTIME = 0x86,
    ANKI_VEHICLE_MSG_C2V_CAR_CONFIGURATION = 0x45,
    ANKI_VEHICLE_MSG_V2C_STATUS_UPDATE = 0x3f
};

#define ATTRIBUTE_PACKED  __attribute__((packed))

/**
 * Basic vehicle message.
 *
 * - size: Size in bytes of the msg_id plus payload
 * - msg_id: Identifier for message
 * - payload: Optional message data for parameters or response info.
 *
 */
typedef struct anki_vehicle_msg {
    uint8_t size;
    uint8_t msg_id;
    uint8_t payload[ANKI_VEHICLE_MSG_PAYLOAD_MAX_SIZE];
} anki_vehicle_msg_t;

typedef struct anki_vehicle_msg_speed_update {
    uint8_t     size;
    uint8_t     msg_id;
    uint16_t    speed_mm_per_sec;
} ATTRIBUTE_PACKED anki_vehicle_msg_speed_update_t;

typedef struct anki_vehicle_msg_status_update {
    uint8_t     size;
    uint8_t     msg_id;
    uint8_t     reserved0;
    uint8_t     on_charger;
    uint8_t     battery_low;
    uint8_t     battery_full;
} ATTRIBUTE_PACKED anki_vehicle_msg_status_update_t;

typedef struct anki_vehicle_msg_version_response {
    uint8_t     size;
    uint8_t     msg_id;
    uint16_t    version;
} ATTRIBUTE_PACKED anki_vehicle_msg_version_response_t;
#define ANKI_VEHICLE_MSG_V2C_VERSION_RESPONSE_SIZE   3

typedef struct anki_vehicle_msg_battery_level_response {
    uint8_t     size;
    uint8_t     msg_id;
    uint16_t    battery_level;
} ATTRIBUTE_PACKED anki_vehicle_msg_battery_level_response_t;
#define ANKI_VEHICLE_MSG_V2C_BATTERY_LEVEL_RESPONSE_SIZE  3

#define ANKI_VEHICLE_SDK_OPTION_OVERRIDE_LOCALIZATION   0x1
typedef struct anki_vehicle_msg_sdk_mode {
    uint8_t     size;
    uint8_t     msg_id;
    uint8_t     on;
    uint8_t     flags;
} ATTRIBUTE_PACKED anki_vehicle_msg_sdk_mode_t;
#define ANKI_VEHICLE_MSG_SDK_MODE_SIZE   3

typedef struct anki_vehicle_msg_set_speed {
    uint8_t     size;
    uint8_t     msg_id;
    int16_t     speed_mm_per_sec;  // mm/sec
    int16_t     accel_mm_per_sec2; // mm/sec^2
    uint8_t     _reserved;
} ATTRIBUTE_PACKED anki_vehicle_msg_set_speed_t;
#define ANKI_VEHICLE_MSG_C2V_SET_SPEED_SIZE  6

typedef enum {
  VEHICLE_TURN_NONE        = 0,
  VEHICLE_TURN_LEFT        = 1,
  VEHICLE_TURN_RIGHT       = 2,
  VEHICLE_TURN_UTURN       = 3,
  VEHICLE_TURN_UTURN_JUMP  = 4,
} anki_vehicle_turn_type_t;

typedef enum {
  VEHICLE_TURN_TRIGGER_IMMEDIATE    = 0, // Run immediately
  VEHICLE_TURN_TRIGGER_INTERSECTION = 1, // Run at the next intersection
} anki_vehicle_turn_trigger_t;

typedef struct anki_vehicle_msg_turn {
    uint8_t     size;
    uint8_t     msg_id;
    uint8_t     type;
    uint8_t     trigger;
} ATTRIBUTE_PACKED anki_vehicle_msg_turn_t;
#define ANKI_VEHICLE_MSG_C2V_TURN_SIZE 3

typedef struct anki_vehicle_msg_set_offset_from_road_center {
    uint8_t     size;
    uint8_t     msg_id;
    float       offset_mm;
} ATTRIBUTE_PACKED anki_vehicle_msg_set_offset_from_road_center_t;
#define ANKI_VEHICLE_MSG_C2V_SET_OFFSET_FROM_ROAD_CENTER_SIZE   5

typedef struct anki_vehicle_msg_change_lane {
    uint8_t     size;
    uint8_t     msg_id;
    uint16_t    horizontal_speed_mm_per_sec;
    uint16_t    horizontal_accel_mm_per_sec2;
    float       offset_from_road_center_mm;
    uint8_t     hop_intent;
    uint8_t     tag;
} ATTRIBUTE_PACKED anki_vehicle_msg_change_lane_t;
#define ANKI_VEHICLE_MSG_C2V_CHANGE_LANE_SIZE    11

typedef struct anki_vehicle_msg_localization_position_update {
    uint8_t     size;
    uint8_t     msg_id;
    uint8_t     _reserved[2];
    float       offset_from_road_center_mm;
    uint16_t    speed_mm_per_sec;
    uint8_t     is_clockwise;
} ATTRIBUTE_PACKED anki_vehicle_msg_localization_position_update_t;
#define ANKI_VEHICLE_MSG_V2C_LOCALIZATION_POSITION_UPDATE_SIZE  10

typedef struct anki_vehicle_msg_localization_transition_update {
    uint8_t     size;
    uint8_t     msg_id;
    uint8_t     _reserved;
    float       offset_from_road_center_mm;
    uint8_t     is_clockwise;
} ATTRIBUTE_PACKED anki_vehicle_msg_localization_transition_update_t;
#define ANKI_VEHICLE_MSG_V2C_LOCALIZATION_TRANSITION_UPDATE_SIZE  7

typedef struct anki_vehicle_msg_offset_from_road_center_update {
    uint8_t     size;
    uint8_t     msg_id;
    float       offset_from_road_center_mm;
    uint8_t     _reserved;
} ATTRIBUTE_PACKED anki_vehicle_msg_offset_from_road_center_update_t;
#define ANKI_VEHICLE_MSG_V2C_OFFSET_FROM_ROAD_CENTER_UPDATE_SIZE  6

// Lights
// The bits in the simple light message (ANKI_VEHICLE_MSG_C2V_SET_LIGHTS) corresponding to
// each type of light.
#define LIGHT_HEADLIGHTS    0
#define LIGHT_BRAKELIGHTS   1
#define LIGHT_FRONTLIGHTS   2
#define LIGHT_ENGINE        3

// Helper macros for parsing lights bits
#define LIGHT_ANKI_VEHICLE_MSG_IS_VALID(messageBits, LIGHT_ID) (((messageBits >> LIGHT_ID)  & 1) == TRUE)
#define LIGHT_ANKI_VEHICLE_MSG_GET_VALUE(messageBits, LIGHT_ID) ((messageBits >> (4 + LIGHT_ANKI_VEHICLE_MSG_HEADLIGHTS) & 1))

typedef struct anki_vehicle_msg_set_lights {
    uint8_t size;
    uint8_t msg_id;
    uint8_t light_mask;     // Valid and value bits for lights (see above)
} ATTRIBUTE_PACKED anki_vehicle_msg_set_lights_t;
#define ANKI_VEHICLE_MSG_C2V_SET_LIGHTS_SIZE 2

#define ANKI_VEHICLE_MAX_LIGHT_INTENSITY 14
#define ANKI_VEHICLE_MAX_LIGHT_TIME 11

// LED channel definitions - for RGB engine, front, and tail lights
typedef enum {
    LIGHT_RED,
    LIGHT_TAIL,
    LIGHT_BLUE,
    LIGHT_GREEN,
    LIGHT_FRONTL,
    LIGHT_FRONTR,
    LIGHT_COUNT
} anki_vehicle_light_channel_t;

// Below is a description of the various effects used in SetLight(...)
typedef enum {
    EFFECT_STEADY,    // Simply set the light intensity to 'start' value
    EFFECT_FADE,      // Fade intensity from 'start' to 'end'
    EFFECT_THROB,     // Fade intensity from 'start' to 'end' and back to 'start'
    EFFECT_FLASH,     // Turn on LED between time 'start' and time 'end' inclusive
    EFFECT_RANDOM,    // Flash the LED erratically - ignoring start/end
    EFFECT_COUNT
} anki_vehicle_light_effect_t;

typedef struct anki_vehicle_light_config {
    uint8_t     channel;
    uint8_t     effect;
    uint8_t     start;
    uint8_t     end;
    uint8_t     cycles_per_10_sec;
} ATTRIBUTE_PACKED anki_vehicle_light_config_t;

#define LIGHT_CHANNEL_COUNT_MAX 3
typedef struct anki_vehicle_msg_lights_pattern {
    uint8_t                         size;
    uint8_t                         msg_id;
    uint8_t                         channel_count;
    anki_vehicle_light_config_t     channel_config[LIGHT_CHANNEL_COUNT_MAX];
} ATTRIBUTE_PACKED anki_vehicle_msg_lights_pattern_t;
#define ANKI_VEHICLE_MSG_C2V_LIGHTS_PATTERN_SIZE    17

typedef enum anki_track_material {
    TRACK_MATERIAL_PLASTIC,
    TRACK_MATERIAL_VINYL,
} anki_track_material_t;

#define SUPERCODE_NONE          0
#define SUPERCODE_BOOST_JUMP    1
#define SUPERCODE_ALL           (SUPERCODE_BOOST_JUMP)

typedef struct anki_vehicle_msg_set_config_params {
    uint8_t     size;
    uint8_t     msg_id;
    uint8_t     super_code_parse_mask;
    uint8_t     track_material;
} ATTRIBUTE_PACKED anki_vehicle_msg_set_config_params_t;
#define ANKI_VEHICLE_MSG_C2V_SET_CONFIG_PARAMS_SIZE 3

/**
 * Create a message for setting the SDK mode.
 *
 * Note that in order to set the speed and change lanes in the current SDK,
 * the ANKI_VEHICLE_SDK_OPTION_OVERRIDE_LOCALIZATION flag must be set
 * when enabling the SDK mode.
 *
 * @param msg A pointer to the vehicle message struct to be written.
 * @param on Whether to turn SDK mode on (1) or off (0).
 * @param flags Option flags to specify vehicle behaviors while SDK mode is enabled.
 *
 * @return size of bytes written to msg
 */
uint8_t anki_vehicle_msg_set_sdk_mode(anki_vehicle_msg_t *msg, uint8_t on, uint8_t flags);

/**
 * Create a message for setting the vehicle speed.
 *
 * @param msg A pointer to the vehicle message struct to be written.
 * @param speed_mm_per_sec The requested vehicle speed in mm/sec.
 * @param accel_mm_per_sec2 The acceleration in mm/sec^2.
 *
 * @return size of bytes written to msg
 */
uint8_t anki_vehicle_msg_set_speed(anki_vehicle_msg_t *msg, uint16_t speed_mm_per_sec, uint16_t accel_mm_per_sec2);

/**
 * Create a message for setting vehicle's internal offset from road center.
 *
 * This value is stored internally in the vehicle and is used during a
 * lane change request to determine the target location. In the current
 * version of the SDK, this message is always sent to set the current offset
 * to zero before a lane change message. This allows the lane change to control
 * the relative horizontal movement of the vehicle
 *
 * @param msg A pointer to the vehicle message struct to be written.
 * @param offset_mm The offset from the road center in mm.
 *
 * @return size of bytes written to msg
 *
 * @see anki_vehicle_msg_change_lane
 */
uint8_t anki_vehicle_msg_set_offset_from_road_center(anki_vehicle_msg_t *msg, float offset_mm);

/**
 * Create a message to change the lane of driving vehicle.
 *
 * The vehicle must be moving in order for this command to be
 * executed.
 *
 * @param msg A pointer to the vehicle message struct to be written.
 * @param horizontal_speed_mm_per_sec The horizontal speed at for the lane change in mm/sec.
 * @param horizontal_accel_mm_per_sec The horizontal acceleration for the lane change in mm/sec.
 * @param offset_from_center_mm The target offset from the road center in mm.
 *
 * @return size of bytes written to msg
 */
uint8_t anki_vehicle_msg_change_lane(anki_vehicle_msg_t *msg,
                                     uint16_t horizontal_speed_mm_per_sec,
                                     uint16_t horizontal_accel_mm_per_sec2,
                                     float offset_from_center_mm);

/**
 * Create a message to set vehicle light directly using a mask.
 *
 * @param msg A pointer to the vehicle message struct to be written.
 * @param mask Mask byte representing the desired lights.
 *
 * @return size of bytes written to msg
 *
 * @see anki_vehicle_msg_set_lights_t
 */
uint8_t anki_vehicle_msg_set_lights(anki_vehicle_msg_t *msg, uint8_t mask);

/**
 * Create a vehicle lights configuration.
 *
 * @param config A pointer to the light channel configuration.
 * @param channel The target lights. See anki_vehicle_light_channel_t.
 * @param effect The type of desired effect. See anki_vehicle_light_effect_t.
 * @param start The starting intensity of the LED.
 * @param end The end intensity of the LED.
 * @param cycles_per_min The frequency repeated start->end transition phases (according to effect).
 *
 * @see anki_vehicle_light_channel_t, anki_vehicle_light_effect_t
 */
void anki_vehicle_light_config(anki_vehicle_light_config_t *config,
                               anki_vehicle_light_channel_t channel,
                               anki_vehicle_light_effect_t effect,
                               uint8_t start,
                               uint8_t end,
                               uint16_t cycles_per_min);

/**
 * Create a message to set a vehicle lights pattern.
 *
 * @param msg A pointer to the vehicle message struct to be written.
 * @param channel The target lights. See anki_vehicle_light_channel_t.
 * @param effect The type of desired effect. See anki_vehicle_light_effect_t.
 * @param start The starting intensity of the LED.
 * @param end The end intensity of the LED.
 * @param cycles_per_min The frequency repeated start->end transition phases (according to effect).
 *
 * @return size of bytes written to msg
 *
 * @see anki_vehicle_light_channel_t, anki_vehicle_light_effect_t
 */
uint8_t anki_vehicle_msg_lights_pattern(anki_vehicle_msg_t *message,
                                        anki_vehicle_light_channel_t channel,
                                        anki_vehicle_light_effect_t effect,
                                        uint8_t start,
                                        uint8_t end,
                                        uint16_t cycles_per_min);

/**
 * Create a message to set vehicle lights using light channel configurations.
 *
 * Up to 3 channel configurations can be added to a single lights_pattern message.
 *
 * @param message A pointer to the vehicle message struct to be written.
 * @param config A pointer to the light channel config to append to the message.
 *
 * @return size of appended config object or zero if nothing was appended.
 */
uint8_t anki_vehicle_msg_lights_pattern_append(anki_vehicle_msg_lights_pattern_t* message,
                                               anki_vehicle_light_config_t* config);

/**
 * Create a message to request that the vehicle disconnect.
 *
 * This is often a more reliable way to disconnect compared to closing
 * the connection to a vehicle from the central.
 *
 * @param msg A pointer to the vehicle message struct to be written.
 *
 * @return size of bytes written to msg
 */
uint8_t anki_vehicle_msg_disconnect(anki_vehicle_msg_t *msg);

/**
 * Create a message to send the vehicle a ping request.
 *
 * This will cause the vehicle to response with a message of type
 * ANKI_VEHICLE_MSG_V2C_PING_RESPONSE.
 *
 * @param msg A pointer to the vehicle message struct to be written.
 *
 * @return size of bytes written to msg
 */
uint8_t anki_vehicle_msg_ping(anki_vehicle_msg_t *msg);

/**
 * Create a message to request the vehicle firmware version.
 *
 * The vehicle will response with a anki_vehicle_msg_version_response_t message.
 *
 * @param msg A pointer to the vehicle message struct to be written.
 *
 * @return size of bytes written to msg
 */
uint8_t anki_vehicle_msg_get_version(anki_vehicle_msg_t *);

/**
 * Create a message to request the vehicle battery level.
 *
 * The vehicle will respond with a anki_vehicle_msg_battery_level_response_t
 * message.
 *
 * @param msg A pointer to the vehicle message struct to be written.
 *
 * @return size of bytes written to msg
 */
uint8_t anki_vehicle_msg_get_battery_level(anki_vehicle_msg_t *);

/**
 * Create a message to cancel a requested lane change.
 *
 * @param msg A pointer to the vehicle message struct to be written.
 *
 * @return size of bytes written to msg
 */
uint8_t anki_vehicle_msg_cancel_lane_change(anki_vehicle_msg_t *msg);

/**
 * Create a message to request a turn.
 *
 * @param msg A pointer to the vehicle message struct to be written.
 * @param type Enum value specifying the type of turn to execute. (see `see anki_vehicle_turn_type_t`)
 *             The default value is `VEHICLE_TURN_TYPE_NONE`, which is a no-op (no turn executed).
 * @param trigger Enum value specifying when to execute the turn. (see `anki_vehicle_turn_trigger_t`)
 *                The only supported value is currently `VEHICLE_TURN_TRIGGER_IMMEDIATE`,
 *                which causes the turn to be executed immediately.
 *
 * @return size of bytes written to msg
 */
uint8_t anki_vehicle_msg_turn(anki_vehicle_msg_t *msg,
                              anki_vehicle_turn_type_t type,
                              anki_vehicle_turn_trigger_t trigger);

/**
 * Create a message to request a 180 degree turn.
 *
 * @param msg A pointer to the vehicle message struct to be written.
 *
 * @return size of bytes written to msg
 */
uint8_t anki_vehicle_msg_turn_180(anki_vehicle_msg_t *msg);

ANKI_END_DECL

#endif
