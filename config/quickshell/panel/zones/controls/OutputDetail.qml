import QtQuick
import QtQuick.Layouts
import "../../common"
import "../../services"

// DETAIL: sound output device
Zone {
    title: "Sound output"
    icon: ""
    closable: true
    DeviceList {
        width: parent.width
        nodes: Audio.sinks
        current: Audio.sink
        onPicked: node => Audio.useSink(node)
    }
}
