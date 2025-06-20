# Mukodik, le lehet olvasni az adatokat:

import signal
import sys
import time
from interbotix_xs_modules.arm import InterbotixManipulatorXS

def main():
    bot = InterbotixManipulatorXS("px150", "arm", "gripper")

    def signal_handler(sig, frame):
        print('\n>> Ctrl+C jelzés fogadva, kilépés...')
        bot.arm.go_to_home_pose()
        sys.exit(0)

    signal.signal(signal.SIGINT, signal_handler)

    print(">> Mozgasd a robotot kézzel. A pozíciót 1 másodpercenként kiírjuk (Ctrl+C a kilépéshez).")
    while True:
        joints = bot.arm.get_joint_commands()
        pose = bot.arm.get_ee_pose()

        x = pose[0, 3]
        y = pose[1, 3]
        z = pose[2, 3]

        print("\n--- Aktuális állapot ---")
        print(f"Csuklószögek [rad]: {['{:.3f}'.format(j) for j in joints]}")
        print(f"Végpont pozíció: x = {x:.3f} m, y = {y:.3f} m, z = {z:.3f} m")

        time.sleep(1)

if __name__ == '__main__':
    main()

