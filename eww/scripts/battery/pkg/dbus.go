package main

import (
	"fmt"
	"os"
	"os/exec"
	"regexp"
	"strconv"

	"github.com/godbus/dbus/v5"
)

var UPOWER_BUS_NAME = "org.freedesktop.UPower"
var BATTERY_OBJECT_PATH = "/org/freedesktop/UPower/devices/battery_BAT0"
var DEVICE_PROPERTIES_INTERFACE = "org.freedesktop.DBus.Properties"
var PROPERTIES_CHANGED_SIGNAL = "PropertiesChanged"

type DBus struct {
	conn           *dbus.Conn
	currentBattery *Battery
}

func (d *DBus) init() {
	var err error
	d.conn, err = initBusConnection()
	if err != nil {
		fmt.Fprintln(os.Stderr, "Failed to connect to SystemBus bus:", err)
		os.Exit(1)
	}

	d.currentBattery = new(Battery)
}

func (d *DBus) clean() {
	cleanConnection(d.conn)
}

func (d *DBus) listen(fn func(Battery)) {
	err := connectToPropertiesChangedSignal(d.conn)
	if err != nil {
		fmt.Fprintln(os.Stderr, "Failed to connect to UPower Signal", err)
		os.Exit(1)
	}

	listenToBusSignal(d.conn, func(_ *dbus.Signal) {
		b := fetchBatteryDetails(*d.conn)
		d.currentBattery = b
		fn(*b)
	})
}

func (d *DBus) check() Battery {
	b := fetchBatteryDetails(*d.conn)
	return *b
}

func (d *DBus) refresh() {
	o := d.conn.Object(UPOWER_BUS_NAME, dbus.ObjectPath(BATTERY_OBJECT_PATH))
	err := o.Call("org.freedesktop.UPower.Device.Refresh", 0).Err
	if err != nil {
		fmt.Fprintln(os.Stderr, "Failed to trigger refresh function", err)
		os.Exit(1)
	}
}

func fetchBatteryDetails(d dbus.Conn) *Battery {
	var e float64
	obj := d.Object(UPOWER_BUS_NAME, dbus.ObjectPath(BATTERY_OBJECT_PATH))
	err := obj.Call("org.freedesktop.DBus.Properties.Get", 0, "org.freedesktop.UPower.Device", "EnergyRate").Store(&e)
	if err != nil {
		fmt.Fprintln(os.Stderr, "Failed to trigger refresh function", err)
		os.Exit(1)
	}

	app := "acpi"
	arg1 := "-V"

	cmd := exec.Command(app, arg1)
	o, err := cmd.Output()
	if err != nil {
		fmt.Fprintln(os.Stderr, "Failed to trigger refresh function", err)
		os.Exit(1)
	}

	r, _ := regexp.Compile(`Battery 0: (?P<State>Charging|Discharging), (?P<Percentage>\d+)%, (?P<Time>\d+:\d+:\d+)`)

	as := r.FindStringSubmatch(string(o))
	if len(as) != 4 {
		fmt.Fprintln(os.Stderr, "Regex did not find the correct sequence")
		os.Exit(1)
	}

	b := new(Battery)
	b.EnergyRate = e
	b.Percentage, err = strconv.Atoi(as[2])
	b.State = as[1]

	if b.State == "Charging" {
		b.TimeToFull = as[3]
	} else {
		b.TimeToEmpty = as[3]
	}

	return b
}

func initBusConnection() (*dbus.Conn, error) {
	conn, err := dbus.ConnectSystemBus()
	if err != nil {
		return nil, err
	}

	return conn, nil
}

func cleanConnection(conn *dbus.Conn) {
	conn.Close()
}

func connectToPropertiesChangedSignal(conn *dbus.Conn) error {
	if err := conn.AddMatchSignal(
		dbus.WithMatchSender(UPOWER_BUS_NAME),
		dbus.WithMatchInterface(DEVICE_PROPERTIES_INTERFACE),
		dbus.WithMatchObjectPath(dbus.ObjectPath(BATTERY_OBJECT_PATH)),
	); err != nil {
		return err
	}

	return nil
}

func listenToBusSignal(conn *dbus.Conn, fn func(*dbus.Signal)) {
	c := make(chan *dbus.Signal, 10)
	conn.Signal(c)
	for v := range c {
		fn(v)
	}
}
