package main

import (
	"bytes"
	"flag"
	"encoding/json"
	"github.com/gorilla/mux"
	"github.com/hillu/go-yara"
	"io/ioutil"
	"log"
	"net/http"
	"time"
)

var rules *yara.Rules

var yaraMasterPath string

func init() {
	flag.StringVar(&yaraMasterPath, "yaramasterpath", "", "path to master yara file")
	flag.Parse()

	if yaraMasterPath == "" {
		log.Fatal("yara master file path not set")
	}

	var err error

	compiledRuleBuf, err := ioutil.ReadFile(yaraMasterPath)
	if err != nil {
		log.Fatalf("unable to read compiled yara rules: %s", err)
	}

	buf := bytes.NewBuffer(compiledRuleBuf)
	rules, err = yara.ReadRules(buf)
	if err != nil {
		log.Fatalf("unable to load yara rules: %s", err)
	}
}

func main() {
	r := mux.NewRouter()
	r.HandleFunc("/scanfile", ScanHandler).Methods("POST")

	srv := &http.Server{
		Handler:      r,
		Addr:         "0.0.0.0:8000",
		WriteTimeout: 15 * time.Second,
		ReadTimeout:  15 * time.Second,
	}

	log.Fatal(srv.ListenAndServe())
}

func ScanHandler(w http.ResponseWriter, r *http.Request) {
	file, _, err := r.FormFile("file")
	if err != nil {
		return
	} else if file == nil {
		return
	}

	fdata, err := ioutil.ReadAll(file)
	if err != nil {
		return
	}

	matches, err := rules.ScanMem(fdata, yara.ScanFlagsFastMode, time.Second * 5)
	if err != nil {
		return
	}

	jsonBuf, err := json.Marshal(matches)
	if err != nil {
		return
	}

	w.Header().Set("content-type", "application/javascript")

	_, err = w.Write(jsonBuf)
	if err != nil {
		return
	}
}
