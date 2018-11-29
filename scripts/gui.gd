extends CanvasLayer

func set_score(score):
	$VBoxContainer/ScoreLabel.set_text('Score: %d' % score)

func set_level(level):
	$VBoxContainer/LevelLabel.set_text('Level: %d' % level)
