## Traffic Light Control Module 

### Overview

This project implements a traffic light control module in Verilog. The design uses a finite state machine (FSM) to manage traffic lights for North-South (NS) and East-West (EW) directions, with additional functionality for pedestrian crossing signals and emergency handling. The system operates based on input signals from sensors, emergency overrides, and a configurable time slot.

### Features
1. **Finite State Machine (FSM):**
   - The module uses a six-state FSM to control the traffic lights and pedestrian signals.
   - States include:
     - `IDLE`: Initial state where all lights are red.
     - `NS_GREEN_EW_RED`: North-South direction has a green light, East-West has a red light.
     - `NS_YELLOW_EW_RED`: North-South has a yellow light, East-West remains red.
     - `EW_GREEN_NS_RED`: East-West direction has a green light, North-South has a red light.
     - `EW_YELLOW_NS_RED`: East-West has a yellow light, North-South remains red.
     - `PEDESTRIAN_CROSSING`: All lights are red, and the pedestrian signal is active.
     - `EMERGENCY`: All lights are red, overriding normal operation.

2. **Traffic Light Signals:**
   - Lights for NS and EW directions are controlled separately.
   - Light encodings:
     - `3'b100`: Red
     - `3'b010`: Yellow
     - `3'b001`: Green

3. **Pedestrian Crossing:**
   - A dedicated signal allows pedestrians to cross safely during the `PEDESTRIAN_CROSSING` state.

4. **Emergency Handling:**
   - Overrides normal operation, turning all lights red (`EMERGENCY` state).

5. **Configurable Timing:**
   - A `time_slot` input specifies the duration of green and pedestrian crossing states.
   - Yellow lights have a fixed duration of 2 clock cycles.

### Inputs and Outputs

#### Inputs:
- **`clk` (Clock):** Synchronizes state transitions and timer updates.
- **`rst_n` (Reset):** Active-low asynchronous reset to initialize the system.
- **`time_slot` (4 bits):** Specifies the duration of green and pedestrian crossing states.
- **`sensor_car` (1 bit):** Indicates the presence of vehicles in the North-South direction.
- **`sensor_pedestrian` (1 bit):** Indicates the presence of pedestrians.
- **`emergency` (1 bit):** Triggers emergency mode when active.

#### Outputs:
- **`light_NS` (3 bits):** Controls the traffic light for the North-South direction.
- **`light_EW` (3 bits):** Controls the traffic light for the East-West direction.
- **`pedestrian_signal` (1 bit):** Activates the pedestrian crossing signal.

### FSM State Transitions

The FSM determines the next state based on the current state, sensor inputs, emergency status, and timer values:

1. **IDLE State:**
   - Transition to `EMERGENCY` if `emergency` is active.
   - Transition to `PEDESTRIAN_CROSSING` if `sensor_pedestrian` is active.
   - Transition to `NS_GREEN_EW_RED` if `sensor_car` is active.
   - Remain in `IDLE` otherwise.

2. **NS_GREEN_EW_RED:**
   - Transition to `NS_YELLOW_EW_RED` after `time_slot` cycles.

3. **NS_YELLOW_EW_RED:**
   - Transition to `EW_GREEN_NS_RED` after 2 cycles.

4. **EW_GREEN_NS_RED:**
   - Transition to `EW_YELLOW_NS_RED` after `time_slot` cycles.

5. **EW_YELLOW_NS_RED:**
   - Transition to `IDLE` after 2 cycles.

6. **PEDESTRIAN_CROSSING:**
   - Transition to `IDLE` after `time_slot` cycles.

7. **EMERGENCY:**
   - Remain in `EMERGENCY` if `emergency` is active.
   - Transition to `IDLE` when `emergency` is deactivated.

### Light and Signal Control Logic

The output logic determines the traffic light states (`light_NS`, `light_EW`) and pedestrian signal (`pedestrian_signal`) based on the current state:
- Green, yellow, and red lights are set according to the active state.
- The pedestrian signal is activated only during the `PEDESTRIAN_CROSSING` state.

### Initialization
- The system initializes all lights to red (`3'b100`) and deactivates the pedestrian signal (`1'b0`).
- The initial state is `IDLE`.

### Applications
This traffic light control module can be deployed in small-scale intersections, pedestrian-heavy zones, or emergency-prone areas. The modular design allows for easy customization and scaling.

### Future Improvements
1. Dynamic adjustment of `time_slot` based on traffic density.
2. Integration with real-world sensors for adaptive traffic management.
3. Support for additional directions (e.g., diagonal traffic).

