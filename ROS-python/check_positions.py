# Check the precision of the robotic arm:

from interbotix_xs_modules.arm import InterbotixManipulatorXS
import numpy as np
import time as t
import numpy as np

def main():
    # Saját szerkeztésű Python kód a robot 
    
    bot = InterbotixManipulatorXS("px150", "arm", "gripper")
    # bot = InterbotixManipulatorXS("px150", "arm", "gripper", moving_time=0.35, accel_time=0.01)


    # ---------------   Filefeldolgozás kezdete:    -----------------
    
    # Fájl megnyitása és sorok beolvasása, kihagyva az első üres sort
    with open("test19_qs.txt") as f:
        lines = f.readlines()[1:]  # első sor kihagyása, történetesen üres

    # Sorok feldolgozása lebegőpontos számokká
    qs_data = np.array([[float(szám) for szám in sor.strip().split()] for sor in lines])


    # ---------------   Mérés kezdete:               -----------------

    bot.arm.go_to_home_pose()

    lépés = 1           # mennyi adatot ignoralunk
    mesured_index = 1   # hanyadikat adat eseten merunk
    
    qs_data = qs_data[::lépés]
    print(qs_data[mesured_index])
    bot.arm.set_joint_positions(qs_data[mesured_index])


    # ---------------   Új rész:               -----------------
    current_joint_positions = bot.arm.get_joint_commands()
    print("Aktuális csuklószögek (radián):", current_joint_positions) # ezt hasonlitani azzal, amit en adtam neki
    print("Beállított csuklószögek (radián):", qs_data[mesured_index]) # amit én adtam neki
    

    ee_pose = bot.arm.get_ee_pose()
    print("Aktuális végpont pozíció és orientáció:", ee_pose)

    return


    
        



    # Set the qs values from file to 
    for q in qs_data:                
#        q[4] = 0
        bot.arm.set_joint_positions(q)
        t.sleep(0.1)
        print(q)



if __name__=='__main__':
    main()



# STANDARD COMMANDOK:

    # t.sleep(2)
    # bot.arm.go_to_home_pose()
    # bot.arm.go_to_sleep_pose()
    # bot.gripper.open()
    # bot.gripper.close()

    # bot.arm.set_ee_pose_components(x = 0.11, y = 0.06, z = 0.155, roll = 0., pitch = np.pi/2)
    # bot.arm.set_joint_positions(q)

    # current_joint_positions = bot.arm.get_joint_commands()
    # ee_pose = bot.arm.get_ee_pose()
