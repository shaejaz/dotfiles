package main

import (
	"encoding/json"
	"fmt"
	"os"
	"strconv"
)

type Export struct {
	EnergyRate  string `json:"energy"`
	Percentage  string `json:"percentage"`
	State       string `json:"state"`
	TimeToEmpty string `json:"timeToEmpty"`
	TimeToFull  string `json:"timeToFull"`
}

func BatteryInfoExport(b Battery) {
	e := Export{
		EnergyRate:  strconv.FormatFloat(b.EnergyRate, 'f', 2, 64),
		Percentage:  fmt.Sprint(b.Percentage),
		State:       b.State,
		TimeToEmpty: b.TimeToEmpty,
		TimeToFull:  b.TimeToFull,
	}

	o, err := json.Marshal(e)
	if err != nil {
		fmt.Fprintln(os.Stderr, "Error in json marshal", err)
		os.Exit(1)
	}

	fmt.Println(string(o))
}

func main() {
	dbusBatteryChecker := new(DBus)

	dbusBatteryChecker.init()
	defer dbusBatteryChecker.clean()

	args := os.Args[1:]

	if len(args) == 0 {
		BatteryInfoExport(dbusBatteryChecker.check())
		dbusBatteryChecker.listen(BatteryInfoExport)
	} else {
		for _, v := range args {
			if v == "refresh" {
				dbusBatteryChecker.refresh()
				os.Exit(0)
			}
		}
	}
}
