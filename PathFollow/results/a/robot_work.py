# A FERDE SIK elméleti modell elsődleges méréséhez hasznalt kod:

from interbotix_xs_modules.arm import InterbotixManipulatorXS
import numpy as np
import time as t
import numpy as np

def main():
    # Saját szerkeztésű Python kód a robot 
    
    bot = InterbotixManipulatorXS("px150", "arm", "gripper")
#        bot = InterbotixManipulatorXS("px150", "arm", "gripper", moving_time=0.35, accel_time=0.01)

    # ---------------   Filefeldolgozás kezdete:    -----------------
    
    # Fájl megnyitása és sorok beolvasása, kihagyva az első üres sort
    with open("test19_qs.txt") as f:
        lines = f.readlines()[1:]  # első sor kihagyása, történetesen üres

    # Sorok feldolgozása lebegőpontos számokká
    qs_data = np.array([[float(szám) for szám in sor.strip().split()] for sor in lines])

    lépés = 1
    qs_data = qs_data[::lépés]
    bot.arm.go_to_home_pose()
    mesured_index = 1
    print(qs_data[mesured_index])
    bot.arm.set_joint_positions(qs_data[mesured_index])
    return

    # Start movement:
    #bot.arm.go_to_sleep_pose()
    bot.arm.go_to_home_pose()
    t.sleep(2)
    #bot.gripper.open()
    #t.sleep(3)
    bot.gripper.close()
    #t.sleep(2)
    #bot.arm.set_ee_pose_components(x = 0.11, y = 0.06, z = 0.155, roll = 0., pitch = np.pi/2)


    # Set the qs values from file to 
    for q in qs_data:                
#        q[4] = 0
        bot.arm.set_joint_positions(q)
        t.sleep(0.1)
        print(q)

    # End the movement series:
    #bot.arm.go_to_home_pose()
    #bot.arm.go_to_sleep_pose()

if __name__=='__main__':
    main()
