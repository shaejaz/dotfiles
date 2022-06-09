package main

type Communicator interface {
	init()
	clean()
	listen(fn func(Battery))
	check() Battery
	refresh()
}
