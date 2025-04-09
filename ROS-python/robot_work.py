from interbotix_xs_modules.arm import InterbotixManipulatorXS
import numpy as np
import time as t
import numpy as np

def main():
    # Saját szerkeztésű Python kód a robot 
    
    # bot = InterbotixManipulatorXS("px150", "arm", "gripper")
    bot = InterbotixManipulatorXS("px150", "arm", "gripper", moving_time=0.05,
    accel_time=0.01) # GPT altal javasolt dolgok

    # ---------------   Filefeldolgozás kezdete:    -----------------
    
    # Fájl megnyitása és sorok beolvasása, kihagyva az első üres sort
    with open("PathFollow\\results\\test2_qs.txt") as f:
        lines = f.readlines()[1:]  # első sor kihagyása, történetesen üres

    # Sorok feldolgozása lebegőpontos számokká
    qs_data = np.array([[float(szám) for szám in sor.strip().split()] for sor in lines])




    # Start movement:
    bot.arm.go_to_sleep_pose()
    bot.arm.go_to_home_pose()

    # Set the qs values from file to 
    for q in qs_data:                
        bot.arm.set_joint_positions(q)
        t.sleep(2)

    # End the movement series:
    bot.arm.go_to_home_pose()
    bot.arm.go_to_sleep_pose()

if __name__=='__main__':
    main()