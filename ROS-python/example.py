from interbotix_xs_modules.arm import InterbotixManipulatorXS
import numpy as np
import time as t

def main():
    # A megadott csukló szögeket egy listában tároljuk
	# az alábbi szögek a robot fogóját tartó csuklót
	# forgatják el 180 fokkal
    joint_positions = [0, 0, 0, 0, np.pi]
    bot = InterbotixManipulatorXS("px150", "arm", "gripper")
    bot.arm.go_to_sleep_pose()
    bot.arm.go_to_home_pose()

    t.sleep(2)
    bot.arm.set_joint_positions(joint_positions)
    t.sleep(2)

    bot.arm.go_to_sleep_pose()
    bot.arm.go_to_home_pose()

if __name__=='__main__':
    main()
