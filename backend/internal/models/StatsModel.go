package models

type Stats struct {
	Vitality  int `bson:"vitality" validate:"gte=0,lte=100"`
	Strength  int `bson:"strength" validate:"gte=0,lte=100"`
	Endurance int `bson:"endurance" validate:"gte=0,lte=100"`
	Agility   int `bson:"agility" validate:"gte=0,lte=100"`
}
