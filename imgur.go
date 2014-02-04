package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"mime/multipart"
	"net/http"
	"os"
	"os/exec"
)

type JsonResponse struct {
	Data Data
}

type Data struct {
	Link string
}

func main() {

	var err error

	switch len(os.Args) {
	case 2:
		err = exec.Command("scrot", os.Args[1]).Run()
	case 3:
		err = exec.Command("scrot", os.Args[1], os.Args[2]).Run()
	default:
		fmt.Printf("Usage: %s <path/to/file.(png|jpg)> [scrot extra flag]\n", os.Args[0])
		os.Exit(1)
	}

	if err != nil {
		log.Fatal(err)
	}

	buffer := new(bytes.Buffer)
	form := multipart.NewWriter(buffer)
	formFile, err := form.CreateFormFile("image", os.Args[1])
	if err != nil {
		log.Fatal(err)
	}

	localFile, err := os.Open(os.Args[1])
	if err != nil {
		log.Fatal(err)
	}

	_, err = io.Copy(formFile, localFile)
	if err != nil {
		log.Fatal(err)
	}

	form.Close()
	localFile.Close()
	request, err := http.NewRequest("POST", "https://api.imgur.com/3/upload.json", buffer)
	if err != nil {
		log.Fatal(err)
	}

	request.Header.Set("Content-Type", form.FormDataContentType())
	request.Header.Set("Authorization", "Client-ID c3d5102cafbba4c")
	client := &http.Client{}
	response, err := client.Do(request)
	if err != nil {
		log.Fatal(err)
	}

	var jsonResponse JsonResponse
	if err = json.NewDecoder(response.Body).Decode(&jsonResponse); err != nil {
		log.Fatal(err)
	}

	if jsonResponse.Data.Link == "" {
		exec.Command("notify-send", "Upload failed").Run()
		os.Exit(1)
	}

	response.Body.Close()
	cmd := exec.Command("xclip", "-selection", "c")
	cmdPipe, err := cmd.StdinPipe()
	if err != nil {
		log.Fatal(err)
	}

	err = cmd.Start()
	fmt.Fprint(cmdPipe, jsonResponse.Data.Link)
	cmdPipe.Close()
	cmd.Wait()

	if err != nil {
		fmt.Print(jsonResponse.Data.Link)
	}

	exec.Command("notify-send", "Upload complete").Run()
}
