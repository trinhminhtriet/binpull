package main

import (
	"fmt"
	"os"
	"os/exec"
)

func fileExists(path string) error {
	_, err := os.Stat(path)
	return err
}

func run(name string, args ...string) error {
	cmd := exec.Command(name, args...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	return cmd.Run()
}

func must(err error) {
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

func main() {
	binpull := os.Getenv("TEST_EGET")

	must(run(binpull, "--system", "linux/amd64", "jgm/pandoc"))
	must(fileExists("pandoc"))

	must(run(binpull, "trinhminhtriet/micro", "--tag", "nightly", "--asset", "osx"))
	must(fileExists("micro"))

	must(run(binpull, "--asset", "nvim.appimage", "--to", "nvim", "neovim/neovim"))
	must(fileExists("nvim"))

	must(run(binpull, "--system", "darwin/amd64", "sharkdp/fd"))
	must(fileExists("fd"))

	must(run(binpull, "--system", "windows/amd64", "--asset", "windows-gnu", "BurntSushi/ripgrep"))
	must(fileExists("rg.exe"))

	must(run(binpull, "-f", "binpull.1", "trinhminhtriet/binpull"))
	must(fileExists("binpull.1"))

	fmt.Println("ALL TESTS PASS")
}
