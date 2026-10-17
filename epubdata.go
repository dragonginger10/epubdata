package main

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"sync"

	"github.com/raitucarp/epub"
	"github.com/urfave/cli/v3"
)

type EpubData struct {
	Title string
	Author string
	Path string
}


func main() {
	cmd := &cli.Command{
		Name: "epubdata",
		Usage: "View metadata for epub files",
		Arguments: []cli.Argument{
			&cli.StringArgs{
				Name: "epubs",
				Min: 1,
				Max: -1,
			},
		},
		Action: actions,
	}

	if err := cmd.Run(context.Background(), os.Args); err != nil {
		log.Fatal(err)
	}
}

func actions(ctx context.Context, cmd *cli.Command) error {
	var dataChunk []EpubData
	var wg sync.WaitGroup
	dataChan := make(chan EpubData)

	for _, file := range cmd.StringArgs("epubs") {
		wg.Add(1)
		go readData(dataChan, &wg, file)
		dataChunk = append(dataChunk, <-dataChan)
	}
	wg.Wait()

	dataJson, _ := json.Marshal(dataChunk)
	fmt.Println(string(dataJson))
	return nil
}

func readData(ch chan<- EpubData, wg *sync.WaitGroup, file string) {
	defer wg.Done()
	reader, err := epub.OpenReader(file)
	if err != nil {
		log.Fatal(err, filepath.Base(file))
	}

	if len(reader.Author()) < 1 || len(reader.Title()) < 1 {
		log.Fatal(errors.New("No metadata was found!"), " ", filepath.Base(file))
	}

	data := EpubData{reader.Title()[0], reader.Author()[0], filepath.Base(file)}

	ch <- data
}

