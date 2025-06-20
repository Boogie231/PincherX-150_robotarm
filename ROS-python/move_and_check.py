from interbotix_xs_modules.arm import InterbotixManipulatorXS
import time

def main():
    # Létrehozzuk a robot objektumot
    bot = InterbotixManipulatorXS("px150", "arm", "gripper")

    print(">> A motorok most kikapcsolásra kerülnek... kézzel mozgathatod a robotot.")
    bot.arm.disable_servos()   # <<<<< ez kapcsolja le a motorokat

    try:
        print(">> Mozgasd a robotot kézzel. A pozíciót 1 másodpercenként kiírjuk (Ctrl+C a kilépéshez).")
        while True:
            # Csuklószögek kiolvasása (radián)
            joints = bot.arm.get_joint_commands()
            
            # Végpont pozíció kiolvasása
            pose = bot.arm.get_ee_pose()
            x = pose['position']['x']
            y = pose['position']['y']
            z = pose['position']['z']

            print("\n--- Aktuális állapot ---")
            print(f"Csuklószögek [rad]: {['{:.3f}'.format(j) for j in joints]}")
            print(f"Végpont pozíció: x = {x:.3f} m, y = {y:.3f} m, z = {z:.3f} m")

            time.sleep(1)

    except KeyboardInterrupt:
        print("\n>> Kilépés és visszaállás...")

    finally:
        bot.arm.enable_servos()   # opcionális: újra aktiválja a motorokat
        bot.arm.go_to_home_pose()
        print(">> A robot visszatért a kiindulási állapotba.")

if __name__ == '__main__':
    main()
