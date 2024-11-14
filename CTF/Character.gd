extends KinematicBody

class_name Character

enum TEAMS {PLAYER, BANDITS}
export(TEAMS) var team

func hurt():
	print('hurt method undefined for this character')

func is_dead():
	return false
