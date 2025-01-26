package models

type Stats struct {
    Vitality  int `json:"vitality" bson:"vitality" validate:"gte=0,lte=100"`
    Strength  int `json:"strength" bson:"strength" validate:"gte=0,lte=100"`
    Endurance int `json:"endurance" bson:"endurance" validate:"gte=0,lte=100"`
    Agility   int `json:"agility" bson:"agility" validate:"gte=0,lte=100"`
}
