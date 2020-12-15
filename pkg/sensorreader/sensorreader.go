package sensorreader

import (
	"encoding/json"
	"io/ioutil"
	"log"
	"math"
	"os"
	"strconv"
	"strings"

	"github.com/gonum/stat"
)

type DeviceBrand int
type DeviceType int

const (
	EMPTY         DeviceBrand = -1
	ULTRA_PRESIZE DeviceBrand = 0
	VERY_PRESIZE  DeviceBrand = 1
	PRESIZE       DeviceBrand = 2

	KEEP    DeviceBrand = 0
	DISCARD DeviceBrand = 1

	NONSUPPORTED   DeviceType = -1
	THERMOMETER    DeviceType = 0
	HUMIDITYSENSOR DeviceType = 1

	THERMOMETER_TEXT_ID    string = "thermometer"
	HUMIDITYSENSOR_TEXT_ID string = "humidity"
)

type Device struct {
	name    string
	brand   DeviceBrand
	kind    DeviceType
	records []float64
}

type Room struct {
	Temperature float64  `json:"temp"`
	Humidity    float64  `json:"hum"`
	Devices     []Device `json:"devices`
}

func nilRoom() Room {
	return Room{
		Temperature: 0,
		Humidity:    0,
		Devices:     nil,
	}
}

//New creares Processor obj
func New() Room {
	return nilRoom()
}

func NewDevice(textid string, name string) Device {
	if textid == THERMOMETER_TEXT_ID {
		return Device{
			name:    name,
			brand:   EMPTY,
			kind:    THERMOMETER,
			records: nil,
		}
	} else if textid == HUMIDITYSENSOR_TEXT_ID {
		return Device{
			name:    name,
			brand:   EMPTY,
			kind:    HUMIDITYSENSOR,
			records: nil,
		}
	} else {
		return Device{
			name:    name,
			brand:   EMPTY,
			kind:    NONSUPPORTED,
			records: nil,
		}
	}
}

func ClassifyDevice(temperature float64, humidity float64, thisdevice Device) DeviceBrand {
	switch thisdevice.kind {
	case THERMOMETER:
		{
			mean := stat.Mean(thisdevice.records, nil)
			stddev := math.Sqrt(stat.Variance(thisdevice.records, nil))
			if math.Abs(mean-temperature) <= 0.5 && stddev < 3 {
				return ULTRA_PRESIZE
			} else if math.Abs(mean-temperature) <= 0.5 && stddev < 5 {
				return VERY_PRESIZE
			} else {
				return PRESIZE
			}
		}
	case HUMIDITYSENSOR:
		{
			min, max := MinMax(thisdevice.records)
			if math.Abs(humidity-min) <= 1 || math.Abs(humidity-max) <= 1 {
				return KEEP
			} else {
				return DISCARD
			}
		}
	default:
		{
			return EMPTY
		}
	}
}

func (RoomInWorks Room) FinalizeDevice(device Device) {
	//first classify device
	device.brand = ClassifyDevice(RoomInWorks.Temperature, RoomInWorks.Humidity, device)
	//second save divice
	RoomInWorks.Devices = append(RoomInWorks.Devices, device)
}

//Process creares Room obj
func (RoomInWorks Room) Process(reportFile string) {

	//open file
	fileIO, err := os.Open(reportFile)
	if err != nil {
		log.Fatal(err)
	}
	defer fileIO.Close()
	//and read it into array of strings
	rawBytes, err := ioutil.ReadAll(fileIO)
	if err != nil {
		panic(err)
	}
	lines := strings.Split(string(rawBytes), "\n")
	var currentLine []string
	var currentDevice Device
	for index, line := range lines {
		currentLine = strings.Split(line, " ")
		//read HEADER - header
		if index == 0 {
			if len(currentLine) != 3 {
				log.Fatal("Unable to read header")
			}
			RoomInWorks.Temperature, err = strconv.ParseFloat(currentLine[1], 32)
			if err != nil {
				log.Fatal("Unable to read temperature from header")
			}
			RoomInWorks.Humidity, err = strconv.ParseFloat(currentLine[2], 32)
			if err != nil {
				log.Fatal("Unable to read humidity from header")
			}
			//end of read HEADER

		} else {

			//read regular lines
			if len(currentLine) != 2 {
				log.Fatal("Unable to read data from body")
			}

			if currentLine[0] == "thermometer" || currentLine[0] == "humidity" {
				//thermometer or humidity sensor detected

				//first finilize previous device
				RoomInWorks.FinalizeDevice(currentDevice)
				//create new empty device
				currentDevice = NewDevice(currentLine[0], currentLine[1])

			} else {
				//record line detected - just append to the current device
				currentValue, err := strconv.ParseFloat(currentLine[1], 32)
				if err != nil {
					log.Fatal("Unable to parse device value at line: " + strconv.Itoa(index))
				}
				currentDevice.records = append(currentDevice.records, currentValue)
			}

		}

	}
}

func (RoomInWorks Room) PrintReport() []byte {
	b, err := json.Marshal(RoomInWorks.Devices)
	if err != nil {
		log.Printf("Error: %s", err)
		return nil
	}
	return b
}
