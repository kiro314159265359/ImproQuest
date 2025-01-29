package models

type Stats struct {
	Vitality  *int `json:"vitality" validate:"omitempty,gte=0,lte=100"`
	Strength  *int `json:"strength" validate:"omitempty,gte=0,lte=100"`
	Endurance *int `json:"endurance" validate:"omitempty,gte=0,lte=100"`
	Agility   *int `json:"agility" validate:"omitempty,gte=0,lte=100"`
}
