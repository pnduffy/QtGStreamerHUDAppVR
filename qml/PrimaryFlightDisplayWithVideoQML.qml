//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.

//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.

//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
//    (c) 2014 Author: Bill Bonney <billbonney@communistech.com>
//

import QtQuick 2.3
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1
import QtGStreamer 1.0
import QtQuick.LocalStorage 2.0
import QtQuick.Controls.Styles 1.3
import QtQuick.Dialogs 1.1
import QtQuick.Window 2.2
import "Storage.js" as Settings

import "./components"

Rectangle {
    // Property Defintions
    id:root
    property bool enableBackgroundVideo: true
    property string statusMessage: ""
    property bool showStatusMessage: false
    property bool enableFullScreen: false
    property bool popupVisible: false
    property bool popupVisible2: false
    property bool popupContextVisible: false
    property bool enableConnect: true
    property bool swapColorMatrix1: false
    property bool swapColorMatrix2: false
    property bool splitImage: false
    property bool swapImages: false
    property bool singlePane: false
    property bool showMessageBox: false
    property bool hudLeft: true
    property bool hudRight: true
    property string navMode: ""
    property string messageBoxText: ""
    property real zoom: 3 * zoomSlider.value //Screen.pixelDensity * zoomSlider.value
    property real mm: 3 //Screen.pixelDensity

    Binding { target: root; property: "enableBackgroundVideo"; value: container.videoEnabled }
    Binding { target: root; property: "enableConnect"; value: container.uasConnected }

    function activeUasSet() {
        rollPitchIndicator.rollAngle = Qt.binding(function() { return relpositionoverview.roll})
        rollPitchIndicator.pitchAngle = Qt.binding(function() { return  relpositionoverview.pitch})
        rollPitchIndicator2.rollAngle = Qt.binding(function() { return relpositionoverview.roll})
        rollPitchIndicator2.pitchAngle = Qt.binding(function() { return  relpositionoverview.pitch})
        pitchIndicator.rollAngle = Qt.binding(function() { return relpositionoverview.roll})
        pitchIndicator.pitchAngle = Qt.binding(function() { return  relpositionoverview.pitch})
        pitchIndicator2.rollAngle = Qt.binding(function() { return relpositionoverview.roll})
        pitchIndicator2.pitchAngle = Qt.binding(function() { return  relpositionoverview.pitch})
        speedIndicator.groundspeed = Qt.binding(function() { return relpositionoverview.groundspeed})
        speedIndicator2.groundspeed = Qt.binding(function() { return relpositionoverview.groundspeed})
        informationIndicator.groundSpeed = Qt.binding(function() { return relpositionoverview.groundspeed})
        informationIndicator.airSpeed = Qt.binding(function() { return relpositionoverview.airspeed })
        informationIndicator.batVoltage = Qt.binding(function() { return vehicleoverview.voltage_battery/1000.0 })
        informationIndicator.batCurrent = Qt.binding(function() { return vehicleoverview.current_battery/100.0 })
        informationIndicator.batPercent = Qt.binding(function() { return vehicleoverview.battery_remaining })
        informationIndicator.lat = Qt.binding(function() { return abspositionoverview.lat.toFixed(10)/1E7})
        informationIndicator.lng = Qt.binding(function() { return abspositionoverview.lon.toFixed(10)/1E7})
        informationIndicator.satcount = Qt.binding(function() { return abspositionoverview.satellites_visible})
        informationIndicator2.groundSpeed = Qt.binding(function() { return relpositionoverview.groundspeed})
        informationIndicator2.airSpeed = Qt.binding(function() { return relpositionoverview.airspeed })
        informationIndicator2.batVoltage = Qt.binding(function() { return vehicleoverview.voltage_battery/1000.0 })
        informationIndicator2.batCurrent = Qt.binding(function() { return vehicleoverview.current_battery/100.0 })
        informationIndicator2.batPercent = Qt.binding(function() { return vehicleoverview.battery_remaining })
        informationIndicator2.lat = Qt.binding(function() { return abspositionoverview.lat.toFixed(10)/1E7})
        informationIndicator2.lng = Qt.binding(function() { return abspositionoverview.lon.toFixed(10)/1E7})
        informationIndicator2.satcount = Qt.binding(function() { return abspositionoverview.satellites_visible})

        compassIndicator.heading = Qt.binding(function() {
            return (relpositionoverview.yaw < 0) ? relpositionoverview.yaw + 360 : relpositionoverview.yaw ;
        })

        compassIndicator.homeHeading = Qt.binding(function()
        {
            var homeHeading = abspositionoverview.homeHeading - relpositionoverview.yaw;
            return homeHeading;
        })

        compassIndicator2.heading = Qt.binding(function() {
            return (relpositionoverview.yaw < 0) ? relpositionoverview.yaw + 360 : relpositionoverview.yaw ;
        })

        compassIndicator2.homeHeading = Qt.binding(function()
        {
            var homeHeading = abspositionoverview.homeHeading - relpositionoverview.yaw;
            return homeHeading;
        })

        speedIndicator.airspeed = Qt.binding(function() { return relpositionoverview.airspeed } )
        speedIndicator2.airspeed = Qt.binding(function() { return relpositionoverview.airspeed } )
        altIndicator.alt = Qt.binding(function() { return abspositionoverview.relative_alt } )
        altIndicator2.alt = Qt.binding(function() { return abspositionoverview.relative_alt } )


        informationIndicator2.gpsstatus = informationIndicator.gpsstatus = Qt.binding(function()
        {
            switch (abspositionoverview.fix_type)
            {
                case 0:
                case 1:
                    return "No Fix";
                break;
                case 2:
                    return "2D Fix";
                break;
                case 3:
                    return "3D Fix";
                break;
                case 4:
                    return "DGPS";
                break;
                case 5:
                    return "RTK";
                break;
            }

            return "No Fix";
        })

        informationIndicator.watts = Qt.binding(function() { return informationIndicator.batVoltage * informationIndicator.batCurrent })
        informationIndicator.gpshdop = Qt.binding(function() { return currentState.gpshdop})
        informationIndicator.wp_dist = Qt.binding(function() { return currentState.wp_dist})
        informationIndicator.ch3percent = Qt.binding(function() { return currentState.ch3percent})
        informationIndicator.timeInAir = Qt.binding(function() { return currentState.timeInAir})
        informationIndicator.distToHome = Qt.binding(function() { return currentState.DistToHome})
        informationIndicator.distTraveled = Qt.binding(function() { return currentState.distTraveled})
        informationIndicator.armed = Qt.binding(function() { return currentState.armed})
        informationIndicator.distUnit = Qt.binding(function() { return currentState.distUnit})
        informationIndicator.speedUnit = Qt.binding(function() { return currentState.speedUnit})
        informationIndicator.message = Qt.binding(function() { return currentState.message})

        informationIndicator2.watts = Qt.binding(function() { return informationIndicator.batVoltage * informationIndicator.batCurrent })
        informationIndicator2.gpshdop = Qt.binding(function() { return currentState.gpshdop})
        informationIndicator2.wp_dist = Qt.binding(function() { return currentState.wp_dist})
        informationIndicator2.ch3percent = Qt.binding(function() { return currentState.ch3percent})
        informationIndicator2.timeInAir = Qt.binding(function() { return currentState.timeInAir})
        informationIndicator2.distToHome = Qt.binding(function() { return currentState.DistToHome})
        informationIndicator2.distTraveled = Qt.binding(function() { return currentState.distTraveled})
        informationIndicator2.armed = Qt.binding(function() { return currentState.armed})
        informationIndicator2.distUnit = Qt.binding(function() { return currentState.distUnit})
        informationIndicator2.speedUnit = Qt.binding(function() { return currentState.speedUnit})
        informationIndicator2.message = Qt.binding(function() { return currentState.message})
    }

    Component.onCompleted:
    {
        rollPitchIndicator.enableRollPitch = rollPitchIndicator2.enableRollPitch = Settings.get("enableRollPitchIndicator", true) == 0 ? false : true
        pitchIndicator.visible = pitchIndicator2.visible = Settings.get("enablePitchIndicator", true) == 0 ? false : true
        altIndicator.visible = altIndicator2.visible = Settings.get("enableAltIndicator", true) == 0 ? false : true
        speedIndicator.visible = speedIndicator2.visible = Settings.get("enableSpeedIndicator", true) == 0 ? false : true
        compassIndicator.visible = compassIndicator2.visible = Settings.get("enableCompassIndicator", true) == 0 ? false : true
        informationIndicator.visible = informationIndicator2.visible = Settings.get("enableInformationIndicator", true) == 0 ? false : true
        brightnessSlider.value = Settings.get("brightness",0);
        contrastSlider.value = Settings.get("contrast",0);
        hueSlider.value = Settings.get("hue",0);
        saturationSlider.value = Settings.get("saturation",0);
        brightnessSlider2.value = Settings.get("brightness2",0);
        contrastSlider2.value = Settings.get("contrast2",0);
        hueSlider2.value = Settings.get("hue2",0);
        saturationSlider2.value = Settings.get("saturation2",0);
        ipOrHost.text = Settings.get("ipOrHost", "");
        zoomSlider.value = Settings.get("zoomFactor",1.0);
        fontsizeSlider.value = Settings.get("fontPointSize", 15.0);
        cameraIpAddress.text = Settings.get("cameraIpAddress", "");
        root.swapColorMatrix1 = container.swapColorMatrix1 = Settings.get("swapColorMatrix1", false) == 0 ? false : true
        root.swapColorMatrix2 = container.swapColorMatrix2 = Settings.get("swapColorMatrix2", false) == 0 ? false : true
        root.splitImage = Settings.get("splitImage", false) == 0 ? false : true
        root.swapImages = container.swapImages = Settings.get("swapImage", false) == 0 ? false : true
        root.singlePane = Settings.get("singlePane",false) == 0 ? false : true

        if (root.singlePane)
        {
            // Disable VR split mode for single pane
            root.splitImage = container.splitImage = false
            checkSplitImage.enabled = false;
        }
        else
        {
            container.splitImage = root.splitImage
            checkSplitImage.enabled = true;
        }

        hudLeft = Settings.get("HUDLeft", true) == 0 ? false : true
        hudRight = Settings.get("HUDRight", true) == 0 ? false : true

        informationIndicator.enableAirSpeed = Settings.get("enableAirSpeed",true) == 0 ? false : true
        informationIndicator.enableGroundSpeed = Settings.get("enableGroundSpeed",true)== 0 ? false : true
        informationIndicator.enableBatVoltage = Settings.get("enableBatVoltage",true) == 0 ? false : true
        informationIndicator.enableBatCurrent = Settings.get("enableBatCurrent",true) == 0 ? false : true
        informationIndicator.enableBatPercent = Settings.get("enableBatPercent",true) == 0 ? false : true
        informationIndicator.enableWatts = Settings.get("enableWatts",true) == 0 ? false : true
        informationIndicator.enableGpshdop = Settings.get("enableGpshdop",true) == 0 ? false : true
        informationIndicator.enableSatcount = Settings.get("enableSatcount",true) == 0 ? false : true
        informationIndicator.enableWp_dist = Settings.get("enableWp_dist",true) == 0 ? false : true
        informationIndicator.enableTimeInAir = Settings.get("enableTimeInAir",true) == 0 ? false : true
        informationIndicator.enableDistToHome = Settings.get("enableDistToHome",true) == 0 ? false : true
        informationIndicator.enableDistTraveled = Settings.get("enableDistTraveled",true) == 0 ? false : true
        informationIndicator.enableLat = Settings.get("enableLat",true) == 0 ? false : true
        informationIndicator.enableLng = Settings.get("enableLng",true) == 0 ? false : true
        informationIndicator.enableArmed = Settings.get("enableArmed",true) == 0 ? false : true
        informationIndicator.enableNavMode = Settings.get("enableNavMode",true) == 0 ? false : true
        informationIndicator.enableGpsstatus = Settings.get("enableGpsstatus",true) == 0 ? false : true

        informationIndicator2.enableAirSpeed = Settings.get("enableAirSpeed",true) == 0 ? false : true
        informationIndicator2.enableGroundSpeed = Settings.get("enableGroundSpeed",true)== 0 ? false : true
        informationIndicator2.enableBatVoltage = Settings.get("enableBatVoltage",true) == 0 ? false : true
        informationIndicator2.enableBatCurrent = Settings.get("enableBatCurrent",true) == 0 ? false : true
        informationIndicator2.enableBatPercent = Settings.get("enableBatPercent",true) == 0 ? false : true
        informationIndicator2.enableWatts = Settings.get("enableWatts",true) == 0 ? false : true
        informationIndicator2.enableGpshdop = Settings.get("enableGpshdop",true) == 0 ? false : true
        informationIndicator2.enableSatcount = Settings.get("enableSatcount",true) == 0 ? false : true
        informationIndicator2.enableWp_dist = Settings.get("enableWp_dist",true) == 0 ? false : true
        informationIndicator2.enableTimeInAir = Settings.get("enableTimeInAir",true) == 0 ? false : true
        informationIndicator2.enableDistToHome = Settings.get("enableDistToHome",true) == 0 ? false : true
        informationIndicator2.enableDistTraveled = Settings.get("enableDistTraveled",true) == 0 ? false : true
        informationIndicator2.enableLat = Settings.get("enableLat",true) == 0 ? false : true
        informationIndicator2.enableLng = Settings.get("enableLng",true) == 0 ? false : true
        informationIndicator2.enableArmed = Settings.get("enableArmed",true) == 0 ? false : true
        informationIndicator2.enableNavMode = Settings.get("enableNavMode",true) == 0 ? false : true
        informationIndicator2.enableGpsstatus = Settings.get("enableGpsstatus",true) == 0 ? false : true

    }

    function hudLChanged()
    {
        if (!hudLeft)
        {
            rollPitchIndicator.enableRollPitch = false
            pitchIndicator.visible = false
            altIndicator.visible = false
            speedIndicator.visible = false
            compassIndicator.visible = false
            informationIndicator.visible = false
            statusMessageIndicator.visible = false
        }
        else
        {
            rollPitchIndicator.enableRollPitch = Settings.get("enableRollPitchIndicator", true) == 0 ? false : true
            pitchIndicator.visible = Settings.get("enablePitchIndicator", true) == 0 ? false : true
            altIndicator.visible = Settings.get("enableAltIndicator", true) == 0 ? false : true
            speedIndicator.visible = Settings.get("enableSpeedIndicator", true) == 0 ? false : true
            compassIndicator.visible = Settings.get("enableCompassIndicator", true) == 0 ? false : true
            informationIndicator.visible = Settings.get("enableInformationIndicator", true) == 0 ? false : true
            statusMessageIndicator.visible = true
        }
    }

    function singlePnChanged()
    {
        if (singlePane)
        {
            pitchIndicator2.visible = false;
            rollPitchIndicator2.enableRollPitch = false;
            altIndicator2.visible = false;
            speedIndicator2.visible = false;
            compassIndicator2.visible = false;
            informationIndicator2.visible = false;
            statusMessageIndicator2.visible = false;
        }
        else
        {
            rollPitchIndicator2.enableRollPitch = Settings.get("enableRollPitchIndicator", true) == 0 ? false : true
            pitchIndicator2.visible = Settings.get("enablePitchIndicator", true) == 0 ? false : true
            altIndicator2.visible = Settings.get("enableAltIndicator", true) == 0 ? false : true
            speedIndicator2.visible = Settings.get("enableSpeedIndicator", true) == 0 ? false : true
            compassIndicator2.visible = Settings.get("enableCompassIndicator", true) == 0 ? false : true
            informationIndicator2.visible = Settings.get("enableInformationIndicator", true) == 0 ? false : true
            hudLChanged()
            hudRChanged()
        }
    }

    onSinglePaneChanged:
    {
        singlePnChanged()
    }

    onHudLeftChanged:
    {
        hudLChanged()
    }

    function hudRChanged()
    {
        if (!hudRight)
        {
            rollPitchIndicator2.enableRollPitch = false
            pitchIndicator2.visible = false
            altIndicator2.visible = false
            speedIndicator2.visible = false
            compassIndicator2.visible = false
            informationIndicator2.visible = false
            statusMessageIndicator2.visible = false;
        }
        else
        {
            rollPitchIndicator2.enableRollPitch = Settings.get("enableRollPitchIndicator", true) == 0 ? false : true
            pitchIndicator2.visible = Settings.get("enablePitchIndicator", true) == 0 ? false : true
            altIndicator2.visible = Settings.get("enableAltIndicator", true) == 0 ? false : true
            speedIndicator2.visible = Settings.get("enableSpeedIndicator", true) == 0 ? false : true
            compassIndicator2.visible = Settings.get("enableCompassIndicator", true) == 0 ? false : true
            informationIndicator2.visible = Settings.get("enableInformationIndicator", true) == 0 ? false : true
            statusMessageIndicator2.visible = true;
        }
    }

    onHudRightChanged:
    {
        hudRChanged()
    }

    function activeUasUnset() {
        console.log("PFD-QML: Active UAS is now unset");
        //Code to make display show a lack of connection here.
    }

    onShowStatusMessageChanged: {
        statusMessageTimer.start()
    }

    Timer{
        id: statusMessageTimer
        interval: 5000;
        repeat: false;
        onTriggered: showStatusMessage = false
    }

    VideoItem {
        id: video
        objectName: "video"
        visible: enableBackgroundVideo && singlePane ? !swapImages : (swapImages ? !splitImage || singlePane : true)
        width: singlePane ? root.width : (swapImages ? (splitImage ? 0 : root.width / 2) :  (splitImage ? root.width : root.width / 2))
        height: root.height
        anchors.left: root.left
        surface: videoSurface1
    }

    VideoItem {
        id: video2
        objectName: "video2"
        visible: enableBackgroundVideo && singlePane ? swapImages : (swapImages ? true : !splitImage || singlePane)
        width: singlePane ? root.width : (swapImages ? (splitImage ? root.width : root.width / 2) : (splitImage ? 0 : root.width / 2))
        height: root.height
        anchors.right: root.right
        surface: videoSurface2
    }

    PitchIndicator {
        id: pitchIndicator
        zoom: root.zoom
        anchors.fill: root
        anchors.rightMargin: singlePane ? 0 : root.width / 2
        opacity: 0.6

        pitchAngle: 0
        rollAngle: 0
    }

    PitchIndicator {
        id: pitchIndicator2
        visible: !singlePane
        zoom: root.zoom
        anchors.fill: root
        anchors.leftMargin: root.width / 2
        opacity: 0.6

        pitchAngle: 0
        rollAngle: 0
    }


    RollPitchIndicator {
        id: rollPitchIndicator
        zoom: root.zoom
        anchors.horizontalCenter: root.horizontalCenter
        anchors.verticalCenter: root.verticalCenter
        anchors.horizontalCenterOffset: singlePane ? 0 : -(root.width / 4)
        rollAngle: 0
        pitchAngle: 0
        enableBackgroundVideo: root.enableBackgroundVideo
    }

    RollPitchIndicator {
        id: rollPitchIndicator2
        visible: !singlePane
        zoom: root.zoom
        anchors.horizontalCenter: root.horizontalCenter
        anchors.verticalCenter: root.verticalCenter
        anchors.horizontalCenterOffset: root.width / 4
        rollAngle: 0
        pitchAngle: 0
        enableBackgroundVideo: root.enableBackgroundVideo
    }

    AltitudeIndicator {
        id: altIndicator
        property real padding: 0

        zoom: root.mm * 0.6
        anchors.right: root.right
        anchors.rightMargin: singlePane ? 0 : root.width / 2
        width: (13*root.mm)
        alt: 0
        onVisibleChanged: updateSize()
        onHeightChanged: updateSize()
        onXChanged: updateSize()
        onYChanged: updateSize()

        function updateSize()
        {
            if (visible)
            {
                if (informationIndicator.topRightBottom > y || informationIndicator.bottomRightTop < y+height)
                {
                    padding = width+root.mm
                }
                else
                {
                    padding = 0
                }
            }
            else
            {
                padding = 0
            }
        }
    }

    AltitudeIndicator {
        id: altIndicator2
        visible: !singlePane
        property real padding: 0

        zoom: root.mm * 0.6
        anchors.right: root.right
        width: (13*root.mm)
        alt: 0
        onVisibleChanged: updateSize()
        onHeightChanged: updateSize()
        onXChanged: updateSize()
        onYChanged: updateSize()

        function updateSize()
        {
            if (visible)
            {
                if (informationIndicator2.topRightBottom > y || informationIndicator2.bottomRightTop < y+height)
                {
                    padding = width+root.mm
                }
                else
                {
                    padding = 0
                }
            }
            else
            {
                padding = 0
            }
        }
    }

    SpeedIndicator {
        id: speedIndicator

        property real padding: 0
        zoom: root.mm * 0.6
        anchors.left: root.left
        width: (13*root.mm)
        airspeed: 0
        groundspeed: 0
        onVisibleChanged: updateSize()
        onHeightChanged: updateSize()
        onXChanged: updateSize()
        onYChanged: updateSize()

        function updateSize()
        {
            if (visible)
            {
                if (informationIndicator.topLeftBottom > y || informationIndicator.bottomLeftTop < y+height)
                {
                    padding = width+root.mm
                }
                else
                {
                    padding = 0
                }
            }
            else
            {
                padding = 0
            }
        }
    }

    SpeedIndicator {
        id: speedIndicator2
        visible: !singlePane
        property real padding: 0
        zoom: root.mm * 0.6
        anchors.left: root.left
        anchors.leftMargin: root.width / 2
        width: (13*root.mm)
        airspeed: 0
        groundspeed: 0
        onVisibleChanged: updateSize()
        onHeightChanged: updateSize()
        onXChanged: updateSize()
        onYChanged: updateSize()

        function updateSize()
        {
            if (visible)
            {
                if (informationIndicator2.topLeftBottom > y || informationIndicator2.bottomLeftTop < y+height)
                {
                    padding = width+root.mm
                }
                else
                {
                    padding = 0
                }
            }
            else
            {
                padding = 0
            }
        }
    }

    CompassIndicator {
        id: compassIndicator
        zoom: root.zoom
        anchors.horizontalCenter: root.horizontalCenter
        anchors.horizontalCenterOffset: singlePane ? - (compassIndicator.imageWidth/2) : (-root.width / 4) - (compassIndicator.imageWidth/2)
        transform: Translate {
            y: 20
        }

        heading: 0
    }

    CompassIndicator {
        id: compassIndicator2
        visible: !singlePane
        zoom: root.zoom
        anchors.horizontalCenter: root.horizontalCenter
        anchors.horizontalCenterOffset: (root.width / 4) - (compassIndicator2.imageWidth/2)
        transform: Translate {
            y: 20
        }

        heading: 0
    }

    StatusMessageIndicator  {
        id: statusMessageIndicator
        anchors.left: root.left
        width: singlePane ? root.width : root.width / 2
        anchors.verticalCenter: root.verticalCenter
        message: statusMessage
        visible: showStatusMessage
    }

    StatusMessageIndicator  {
        id: statusMessageIndicator2
        anchors.right: root.right
        width: root.width / 2
        anchors.verticalCenter: root.verticalCenter
        message: statusMessage
        visible: !singlePane && showStatusMessage
    }

    InformationOverlayIndicator{
        id: informationIndicator
        anchors.left: root.left
        anchors.bottom: root.bottom
        width: singlePane ? root.width : root.width / 2
        height: root.height

        airSpeed: 0
        groundSpeed: 0
        batVoltage: 0
        batCurrent: 0
        batPercent: 0
        navMode : root.navMode
        fontPointSize: fontsizeSlider.value
        paddingLeft: speedIndicator.padding
        paddingRight: altIndicator.padding
    }

    InformationOverlayIndicator{
        id: informationIndicator2
        visible: !singlePane
        anchors.right: root.right
        anchors.bottom: root.bottom
        width: root.width / 2
        height: root.height
        airSpeed: 0
        groundSpeed: 0
        batVoltage: 0
        batCurrent: 0
        batPercent: 0
        navMode : root.navMode
        fontPointSize: fontsizeSlider.value
        paddingLeft: speedIndicator2.padding
        paddingRight: altIndicator2.padding
    }

    Rectangle
    {
        id: popup
        color: "lightgrey"
        width: parent.width*2/3
        anchors.left: parent.left

        height: (116*root.mm)
        z:3

        property real rowHeight: (9*root.mm)

        visible: root.popupVisible

        anchors
        {
            left: parent.left; top: parent.top
        }

        onVisibleChanged:
        {
            if (visible) checkSwapColorMatrix1.checked = Settings.get("swapColorMatrix1", false) == 0 ? false : true
        }

        Column
        {
            Layout.fillHeight: true

            anchors
            {
                left: parent.left; top: parent.top; leftMargin: 10; topMargin: (4.5*root.mm)
            }

            Text
            {
                height: popup.rowHeight
                text: "Brightness"
            }
            Text
            {
                height: popup.rowHeight
                text: "Contrast"
            }
            Text
            {
                height: popup.rowHeight
                text: "Hue"
            }
            Text
            {
                height: popup.rowHeight
                text: "Saturation"
            }

            Text
            {
                height: popup.rowHeight
                text: "HUD Size"
            }

            Text
            {
                height: popup.rowHeight
                text: "Font Size"
            }

            Text
            {
                height: popup.rowHeight
                text: "Stream Type"
            }

            Text
            {
                Layout.topMargin: 10
                Layout.fillHeight: true
                height: popup.rowHeight
                text: "Pipeline"
            }

            Text
            {
                height: popup.rowHeight
                text: "MAV Connect"
            }

            Text
            {
                height: popup.rowHeight
                text: "Camera IP"
            }
        }

        Column
        {
            id: contentCol

            width: parent.width - (30*root.mm)
            z:3
            anchors
            {
                right: parent.right; top: parent.top; topMargin: (2*root.mm); rightMargin: (2*root.mm)
            }

            Slider
            {
                id: brightnessSlider
                width: parent.width
                height: popup.rowHeight
                z:3
                minimumValue: -100
                maximumValue: 100
                stepSize: 1
                Binding { target: player; property: "brightness"; value: brightnessSlider.value }
                onValueChanged:
                {
                    Settings.set("brightness", brightnessSlider.value)
                }
            }

            Slider
            {
                id: contrastSlider
                width: parent.width
                height: popup.rowHeight
                z:3
                minimumValue: -100
                maximumValue: 100
                stepSize: 1
                Binding { target: player; property: "contrast"; value: contrastSlider.value }
                onValueChanged:
                {
                    Settings.set("contrast", contrastSlider.value)
                }
            }
            Slider
            {
                id: hueSlider
                width: parent.width
                height: popup.rowHeight
                z:3
                minimumValue: -100
                maximumValue: 100
                stepSize: 1
                Binding { target: player; property: "hue"; value: hueSlider.value }
                onValueChanged:
                {
                    Settings.set("hue", hueSlider.value)
                }
            }
            Slider
            {
                id: saturationSlider
                width: parent.width
                height: popup.rowHeight
                z:3
                minimumValue: -100
                maximumValue: 100
                stepSize: 1
                Binding { target: player; property: "saturation"; value: saturationSlider.value }
                onValueChanged:
                {
                    Settings.set("saturation", saturationSlider.value)
                }
            }
            Slider
            {
                id: zoomSlider
                width: parent.width
                height: popup.rowHeight
                z:3
                minimumValue: 1.0
                maximumValue: 2.0
                stepSize: 0.1
                onValueChanged:
                {
                    if (value>1) Settings.set("zoomFactor", zoomSlider.value)
                }
            }
            Slider
            {
                id: fontsizeSlider
                width: parent.width
                height: popup.rowHeight
                z:3
                minimumValue: 12
                maximumValue: 36
                stepSize: 1
                onValueChanged:
                {
                    if (value>12) Settings.set("fontPointSize", fontsizeSlider.value)
                }
            }

            RowLayout
            {
                width: parent.width
                height: popup.rowHeight
                anchors.left: parent.left
                z:3

                Button
                {
                    id: buttonH264
                    text: "H264"

                    onClicked:
                    {
                        pipelineString.currentIndex = 0
                        player.stopped = true
                        player.playing = true
                    }
                }

                Button
                {
                    id: buttonMJPEG
                    text: "MJPEG"
                    anchors
                    {
                        left: buttonH264.right; leftMargin: 10
                    }

                    onClicked:
                    {
                        pipelineString.currentIndex = 1
                        player.stopped = true
                        player.playing = true
                    }
                }
            }

            RowLayout
            {
                width: parent.width
                height: popup.rowHeight
                anchors.left: parent.left
                z:3

                ComboBox
                {
                    id: pipelineString
                    editable: true
                    height: parent.height
                    anchors.right: buttonDeleteString.left
                    anchors.left: parent.left
                    property string stringText
                    property int stringIndex
                    z:3

                    Binding { target: container; property: "pipelineString"; value: pipelineString.currentText }
                    model: ListModel
                    {
                        id: model
                    }
                    onAccepted:
                    {
                        if (find(currentText) === -1)
                        {
                            if (editText.length > 0)
                            {
                                console.log("New pipeline = " + editText)
                                model.append({text: editText})
                                currentIndex = find(editText)

                                // Add to database
                                stringText = ""
                                for (stringIndex=0;; stringIndex++)
                                {
                                    stringText = Settings.get("pipelineString"+stringIndex,"");
                                    if (stringText.length == 0) break;
                                }

                                Settings.set("pipelineString"+stringIndex, currentText);
                            }
                        }

                        if (pipelineString.currentText.length > 0) Settings.set("pipelineString", pipelineString.currentText)
                    }

                    onCurrentIndexChanged:
                    {
                        console.log("Current Text = " + pipelineString.currentText + " Index = " + pipelineString.currentIndex)
                        if (pipelineString.currentText.length > 0) Settings.set("pipelineString", pipelineString.currentText)
                    }

                    Component.onCompleted:
                    {
                        // Get stored values
                        stringText = Settings.get("pipelineString0", "");
                        if (stringText.length == 0)
                        {
                            // Set defaults
                            Settings.set("pipelineString0", "udpsrc port=9000 buffer-size=60000 ! application/x-rtp,encoding-name=H264,payload=96 ! rtph264depay ! h264parse ! queue ! avdec_h264");
                            Settings.set("pipelineString1", "udpsrc port=9000 ! application/x-rtp,media=(string)video,clock-rate=(int)90000,encoding-name=(string)JPEG,payload=(int)26 ! rtpjpegdepay ! jpegdec");
                            Settings.set("pipelineString2", "videotestsrc ! queue");
                        }

                        for (stringIndex=0;; stringIndex++)
                        {
                            // Get stored values
                            stringText = Settings.get("pipelineString" + stringIndex,"");
                            if (stringText.length > 0) model.append({ text: stringText })
                            else break;
                        }

                        pipelineString.currentIndex = pipelineString.find(Settings.get("pipelineString", "udpsrc port=9000 buffer-size=60000 ! application/x-rtp,encoding-name=H264,payload=96 ! rtph264depay ! h264parse ! queue ! avdec_h264"));
                        console.log("pipelineString current Index = " + pipelineString.currentIndex)
                    }
                }

                Action
                {
                    id: deletePipelineString
                    enabled: pipelineString.currentText.length > 0
                    tooltip: "Delete Current Pipeline String"
                    property int stringIndex
                    property string stringText

                    onTriggered:
                    {
                        // Delete it
                        stringIndex = pipelineString.find(pipelineString.currentText)
                        if (stringIndex >= 3) // Can't delete first 3 defaults
                        {
                            // Erase first
                            for (var i=0; i<model.count; i++)
                            {
                                Settings.set("pipelineString" + i,"");
                            }

                            console.log("Deleting Pipeline String = " + pipelineString.currentText);
                            pipelineString.editText = "";
                            model.remove(stringIndex);

                            for (stringIndex=0; stringIndex<model.count; stringIndex++)
                            {
                                var modeltext = pipelineString.model.get(stringIndex);
                                console.log("Saving pipelineString"+stringIndex+","+ modeltext.text);
                                Settings.set("pipelineString"+stringIndex, modeltext.text);
                            }
                        }
                    }
                }

                ToolButton
                {
                    id: buttonDeleteString
                    anchors.right: parent.right
                    height: parent.height
                    width: (6*root.mm)
                    Image {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: "./resources/components/primaryFlightDisplay/disconnect.svg"
                        sourceSize.height: (6*root.mm)
                        sourceSize.width: (6*root.mm)
                    }
                    action: deletePipelineString
                }
            }

            RowLayout
            {
                width: parent.width
                height: popup.rowHeight
                anchors.left: parent.left
                z:3

                TextField
                {
                    id: ipOrHost
                    width: parent.width/2
                    height: popup.rowHeight
                    Layout.fillWidth: true
                    z:3
                    Binding { target: container; property: "ipOrHost"; value: ipOrHost.text }
                    onEditingFinished:
                    {
                        Settings.set("ipOrHost", ipOrHost.text)
                    }
                }

                Text
                {
                    width: parent.width
                    height: popup.rowHeight
                    anchors
                    {
                        left: ipOrHost.right; top: ipOrHost.top; leftMargin: 10; topMargin: 5; rightMargin: 5
                    }

                    z:3
                    text: "TCP:{ip/host}:{port} or UDP:{port}"
                }
            }

            RowLayout
            {
                width: parent.width
                height: popup.rowHeight
                anchors.left: parent.left
                anchors.right: parent.right
                z:3
                TextField
                {
                    id: cameraIpAddress
                    anchors.left: parent.left
                    anchors.right: parent.right
                    z:3
                    Binding { target: container; property: "cameraIpAddress"; value: cameraIpAddress.text }
                    onEditingFinished:
                    {
                        Settings.set("cameraIpAddress", cameraIpAddress.text)
                    }
                }
            }

            CheckBox {
                z:3
                id: checkSwapColorMatrix1
                height: popup.rowHeight
                text: "Invert Color Matrix"
                onCheckedChanged:
                {
                    root.swapColorMatrix1 = checked
                    container.swapColorMatrix1 = checked
                    Settings.set("swapColorMatrix1", checked)
                }
            }
        }

        Action
        {
            id: play
            enabled: player.stopped || player.paused
            tooltip: "Play"
            onTriggered: player.playing = true
        }

        Action
        {
            id: pause
            enabled: player.playing
            tooltip: "Pause"
            onTriggered: player.paused = true
        }

        Action
        {
            id: stop
            enabled: player.playing
            tooltip: "Stop"
            onTriggered: player.stopped = true
        }

        Action
        {
            id: reset
            enabled: true
            tooltip: "Reset Defaults"
            onTriggered:
            {
                brightnessSlider.value = 0
                contrastSlider.value = 0
                hueSlider.value = 0
                saturationSlider.value = 0
                zoomSlider.value = 1
                fontsizeSlider.value = 20
            }
        }

        Action
        {
            id: connect
            enabled: !container.uasConnected
            tooltip: "Connect to MavLink"
            onTriggered:
            {
                root.enableConnect = !root.enableConnect
                container.uasConnected = root.enableConnect
            }
        }

        Action
        {
            id: disconnect
            enabled: container.uasConnected
            tooltip: "Disconnect from MavLink"
            onTriggered:
            {
                root.enableConnect = !root.enableConnect
                container.uasConnected = root.enableConnect
            }
        }

        ToolBar
        {
            z:3
            height: (15*root.mm)
            anchors
            {
                bottom: parent.bottom
            }

            style: ToolBarStyle {
                   background: Rectangle {
                       color: "lightsteelblue"
                   }
            }

            RowLayout
            {
                id: tbRow
                anchors
                {
                    verticalCenter: parent.verticalCenter
                }
                height : (15*root.mm)
                property real buttonHeight: (13*root.mm)
                z:3
                ToolButton
                {
                    id: buttonPlay
                    action: play
                    height: parent.height
                    Image {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: "./resources/components/primaryFlightDisplay/play.svg"
                        sourceSize.height: tbRow.buttonHeight
                        sourceSize.width: tbRow.buttonHeight
                    }
                }

                ToolButton
                {
                    id: buttonStop
                    anchors.left: buttonPlay.right
                    anchors.leftMargin: (5*root.mm)
                    action: stop
                    height: parent.height
                    Image {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: "./resources/components/primaryFlightDisplay/stop.svg"
                        sourceSize.height: tbRow.buttonHeight
                        sourceSize.width: tbRow.buttonHeight
                    }
                }

                ToolButton
                {
                    id: buttonPause
                    anchors.left: buttonStop.right
                    anchors.leftMargin: (5*root.mm)
                    action: pause
                    height: parent.height
                    Image {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: "./resources/components/primaryFlightDisplay/pause.svg"
                        sourceSize.height: tbRow.buttonHeight
                        sourceSize.width: tbRow.buttonHeight
                    }
                }

                ToolButton
                {
                    id: buttonReset
                    anchors.left: buttonPause.right
                    anchors.leftMargin: (5*root.mm)
                    action: reset
                    height: parent.height
                    Image {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: "./resources/components/primaryFlightDisplay/reset.svg"
                        sourceSize.height: tbRow.buttonHeight
                        sourceSize.width: tbRow.buttonHeight
                    }
                }

                ToolButton
                {
                    id: buttonConnect
                    anchors.left: buttonReset.right
                    anchors.leftMargin: (5*root.mm)
                    action: connect
                    height: parent.height
                    Image {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: "./resources/components/primaryFlightDisplay/connect.svg"
                        sourceSize.height: tbRow.buttonHeight
                        sourceSize.width: tbRow.buttonHeight
                    }
                }

                ToolButton
                {
                    id: buttonDisconnect
                    anchors.left: buttonConnect.right
                    anchors.leftMargin: (5*root.mm)
                    action: disconnect
                    height: parent.height
                    Image {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: "./resources/components/primaryFlightDisplay/disconnect.svg"
                        sourceSize.height: tbRow.buttonHeight
                        sourceSize.width: tbRow.buttonHeight
                    }
                }
            }
        }

        MouseArea
        {
            anchors.fill: parent

            onClicked:
            {
            }
        }
    }

    Rectangle
    {
        id: popup2
        color: "lightgrey"
        width: parent.width*2/3

        height: (80*root.mm)
        z:3

        property real rowHeight: (9*root.mm)

        visible: root.popupVisible2

        anchors
        {
            right: parent.right; top: parent.top
        }

        onVisibleChanged:
        {
            if (visible) checkSwapColorMatrix2.checked = Settings.get("swapColorMatrix2", false) == 0 ? false : true
        }

        Column
        {
            Layout.fillHeight: true

            anchors
            {
                left: parent.left; top: parent.top; leftMargin: 10; topMargin: (4.5*root.mm)
            }

            Text
            {
                height: popup2.rowHeight
                text: "Brightness"
            }
            Text
            {
                height: popup2.rowHeight
                text: "Contrast"
            }
            Text
            {
                height: popup2.rowHeight
                text: "Hue"
            }
            Text
            {
                height: popup2.rowHeight
                text: "Saturation"
            }

            Text
            {
                height: popup2.rowHeight
                text: "Stream Type"
            }

            Text
            {
                height: popup2.rowHeight
                text: "Pipeline"
            }
        }

        Column
        {
            id: contentCol2
            width: parent.width - (30*root.mm)
            z:3
            anchors
            {
                right: parent.right; top: parent.top; topMargin: (2*root.mm); rightMargin: (2*root.mm)
            }

            Slider
            {
                id: brightnessSlider2
                width: parent.width
                height: popup2.rowHeight
                z:3
                minimumValue: -100
                maximumValue: 100
                stepSize: 1
                Binding { target: player2; property: "brightness"; value: brightnessSlider2.value }
                onValueChanged:
                {
                    Settings.set("brightness2", brightnessSlider2.value)
                }
            }
            Slider
            {
                id: contrastSlider2
                width: parent.width
                height: popup2.rowHeight
                z:3
                minimumValue: -100
                maximumValue: 100
                stepSize: 1
                Binding { target: player2; property: "contrast"; value: contrastSlider2.value }
                onValueChanged:
                {
                    Settings.set("contrast2", contrastSlider2.value)
                }
            }

            Slider
            {
                id: hueSlider2
                width: parent.width
                height: popup2.rowHeight
                z:3
                minimumValue: -100
                maximumValue: 100
                stepSize: 1
                Binding { target: player2; property: "hue"; value: hueSlider2.value }
                onValueChanged:
                {
                    Settings.set("hue2", hueSlider2.value)
                }
            }

            Slider
            {
                id: saturationSlider2
                width: parent.width
                height: popup2.rowHeight
                z:3
                minimumValue: -100
                maximumValue: 100
                stepSize: 1
                Binding { target: player2; property: "saturation"; value: saturationSlider2.value }
                onValueChanged:
                {
                    Settings.set("saturation2", saturationSlider2.value)
                }
            }

            RowLayout
            {
                width: parent.width
                height: popup.rowHeight
                anchors.left: parent.left
                z:3

                Button
                {
                    id: buttonH264_2
                    text: "H264"

                    onClicked:
                    {
                        pipelineString2.currentIndex = 0
                        player2.stopped = true
                        player2.playing = true
                    }
                }

                Button
                {
                    id: buttonMJPEG_2
                    text: "MJPEG"
                    anchors
                    {
                        left: buttonH264_2.right; leftMargin: 10
                    }

                    onClicked:
                    {
                        pipelineString2.currentIndex = 1
                        player2.stopped = true
                        player2.playing = true
                    }
                }
            }

            RowLayout
            {
                id: lastRow
                width: parent.width
                height: popup2.rowHeight
                anchors.left: parent.left
                z:3

                ComboBox
                {
                    id: pipelineString2
                    editable: true
                    height: parent.height
                    anchors.right: buttonDeleteString2.left
                    anchors.left: parent.left
                    property string stringText
                    property int stringIndex
                    z:3

                    Binding { target: container; property: "pipelineString2"; value: pipelineString2.currentText }
                    model: ListModel
                    {
                        id: model2
                    }
                    onAccepted:
                    {
                        if (find(currentText) === -1)
                        {
                            if (editText.length > 0)
                            {
                                console.log("New pipeline = " + editText)
                                model2.append({text: editText})
                                currentIndex = find(editText)

                                // Add to database
                                stringText = ""
                                for (stringIndex=0;; stringIndex++)
                                {
                                    stringText = Settings.get("pipelineString2"+stringIndex,"");
                                    if (stringText.length == 0) break;
                                }

                                Settings.set("pipelineString2"+stringIndex, currentText);
                            }
                        }

                        if (pipelineString2.currentText.length > 0) Settings.set("pipelineString2", pipelineString2.currentText)
                    }

                    onCurrentIndexChanged:
                    {
                        console.log("Current Text = " + pipelineString2.currentText + " Index = " + pipelineString2.currentIndex)
                        if (pipelineString2.currentText.length > 0) Settings.set("pipelineString2", pipelineString2.currentText)
                    }

                    Component.onCompleted:
                    {
                        // Get stored values
                        stringText = Settings.get("pipelineString20", "");
                        if (stringText.length == 0)
                        {
                            // Set defaults
                            Settings.set("pipelineString20", "udpsrc port=9001 buffer-size=60000 ! application/x-rtp,encoding-name=H264,payload=96 ! rtph264depay ! h264parse ! queue ! avdec_h264");
                            Settings.set("pipelineString21", "udpsrc port=9001 ! application/x-rtp,media=(string)video,clock-rate=(int)90000,encoding-name=(string)JPEG,payload=(int)26 ! rtpjpegdepay ! jpegdec");
                            Settings.set("pipelineString22", "videotestsrc ! queue");
                        }

                        for (stringIndex=0;; stringIndex++)
                        {
                            // Get stored values
                            stringText = Settings.get("pipelineString2" + stringIndex,"");
                            if (stringText.length > 0) model2.append({ text: stringText })
                            else break;
                        }

                        pipelineString2.currentIndex = pipelineString2.find(Settings.get("pipelineString2", "udpsrc port=9001 buffer-size=60000 ! application/x-rtp,encoding-name=H264,payload=96 ! rtph264depay ! h264parse ! queue ! avdec_h264"));
                        console.log("pipelineString2 current Index = " + pipelineString2.currentIndex)
                    }
                }

                Action
                {
                    id: deletePipelineString2
                    enabled: pipelineString2.currentText.length > 0
                    tooltip: "Delete Current Pipeline String"
                    property int stringIndex
                    property string stringText

                    onTriggered:
                    {
                        // Delete it
                        stringIndex = pipelineString2.find(pipelineString2.currentText)
                        if (stringIndex >= 3) // Can't delete first 3 defaults
                        {
                            // Erase first
                            for (var i=0; i<model.count; i++)
                            {
                                Settings.set("pipelineString2" + i,"");
                            }

                            console.log("Deleting Pipeline String = " + pipelineString2.currentText);
                            pipelineString2.editText = "";
                            model.remove(stringIndex);

                            for (stringIndex=0; stringIndex<model.count; stringIndex++)
                            {
                                var modeltext = pipelineString2.model.get(stringIndex);
                                console.log("Saving pipelineString2"+stringIndex+","+ modeltext.text);
                                Settings.set("pipelineString2"+stringIndex, modeltext.text);
                            }
                        }
                    }
                }

                ToolButton
                {
                    id: buttonDeleteString2
                    anchors.right: parent.right
                    height: parent.height
                    width: (6*root.mm)
                    Image {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: "./resources/components/primaryFlightDisplay/disconnect.svg"
                        sourceSize.height: (6*root.mm)
                        sourceSize.width: (6*root.mm)
                    }
                    action: deletePipelineString2
                }
            }

            CheckBox {
                z:3
                id: checkSwapColorMatrix2
                text: "Invert Color Matrix"
                onCheckedChanged:
                {
                    root.swapColorMatrix2 = checked
                    container.swapColorMatrix2 = checked
                    Settings.set("swapColorMatrix2", checked)
                }
            }
        }

        Action
        {
            id: play2
            enabled: player2.stopped || player2.paused
            tooltip: "Play"
            onTriggered: player2.playing = true
        }

        Action
        {
            id: pause2
            enabled: player2.playing
            tooltip: "Pause"
            onTriggered: player2.paused = true
        }

        Action
        {
            id: stop2
            enabled: player2.playing
            tooltip: "Stop"
            onTriggered: player2.stopped = true
        }

        Action
        {
            id: reset2
            enabled: true
            tooltip: "Reset Defaults"
            onTriggered:
            {
                brightnessSlider2.value = 0
                contrastSlider2.value = 0
                hueSlider2.value = 0
                saturationSlider2.value = 0
            }
        }

        ToolBar
        {
            z:3
            height: (15*root.mm)
            anchors
            {
                bottom: parent.bottom
            }

            style: ToolBarStyle {
                   background: Rectangle {
                       color: "lightsteelblue"
                   }
            }

            RowLayout
            {
                id: tbRow2
                anchors
                {
                    verticalCenter: parent.verticalCenter
                }
                height : (15*root.mm)
                property real buttonHeight: (6*root.mm)
                z:3
                ToolButton
                {
                    id: buttonPlay2
                    action: play2
                    height: parent.height
                    Image {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: "./resources/components/primaryFlightDisplay/play.svg"
                        sourceSize.height: tbRow.buttonHeight
                        sourceSize.width: tbRow.buttonHeight
                    }
                }

                ToolButton
                {
                    id: buttonStop2
                    anchors.left: buttonPlay2.right
                    anchors.leftMargin: (5*root.mm)
                    action: stop2
                    height: parent.height
                    Image {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: "./resources/components/primaryFlightDisplay/stop.svg"
                        sourceSize.height: tbRow.buttonHeight
                        sourceSize.width: tbRow.buttonHeight
                    }
                }

                ToolButton
                {
                    id: buttonPause2
                    anchors.left: buttonStop2.right
                    anchors.leftMargin: (5*root.mm)
                    action: pause2
                    height: parent.height
                    Image {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: "./resources/components/primaryFlightDisplay/pause.svg"
                        sourceSize.height: tbRow.buttonHeight
                        sourceSize.width: tbRow.buttonHeight
                    }
                }

                ToolButton
                {
                    id: buttonReset2
                    anchors.left: buttonPause2.right
                    anchors.leftMargin: (5*root.mm)
                    action: reset2
                    height: parent.height
                    Image {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: "./resources/components/primaryFlightDisplay/reset.svg"
                        sourceSize.height: tbRow.buttonHeight
                        sourceSize.width: tbRow.buttonHeight
                    }
                }
            }
        }


        MouseArea
        {
            anchors.fill: parent

            onClicked:
            {
            }
        }
    }

    Rectangle
    {
        id: popupContext
        color: "lightgrey"
        width: popupMenu.width + popupMenu2.width + popupMenu3.width + (14*root.mm)
        height: Math.max(popupMenu2.height,popupMenu.height,popupMenu3.height) + (5*root.mm)
        border.color: "black"
        border.width: 2
        z:3

        property real rowHeight: (6*root.mm)

        visible: root.popupContextVisible

        anchors
        {
            left: parent.left; top: parent.top
        }

        onVisibleChanged:
        {
            if (visible)
            {
                checkVideo.checked = root.enableBackgroundVideo
                checkRollPitch.checked = Settings.get("enableRollPitchIndicator", true) == 0 ? false : true
                checkPitch.checked = pitchIndicator2.visible = Settings.get("enablePitchIndicator", true) == 0 ? false : true
                checkAlitude.checked = Settings.get("enableAltIndicator", true) == 0 ? false : true
                checkSpeed.checked = Settings.get("enableSpeedIndicator", true) == 0 ? false : true
                checkCompass.checked = Settings.get("enableCompassIndicator", true) == 0 ? false : true
                checkInformation.checked = Settings.get("enableInformationIndicator", true) == 0 ? false : true
                checkSplitImage.checked = root.splitImage
                checkSwapImages.checked = root.swapImages
                checkHUDLeft.checked = root.hudLeft
                checkHUDRight.checked = root.hudRight

                checkEnableAirSpeed.checked = Settings.get("enableAirSpeed",true) == 0 ? false : true
                checkEnableGroundSpeed.checked = Settings.get("enableGroundSpeed",true)== 0 ? false : true
                checkEnableBatVoltage.checked = Settings.get("enableBatVoltage",true) == 0 ? false : true
                checkEnableBatCurrent.checked = Settings.get("enableBatCurrent",true) == 0 ? false : true
                checkEnableBatPercent.checked = Settings.get("enableBatPercent",true) == 0 ? false : true
                checkEnableWatts.checked = Settings.get("enableWatts",true) == 0 ? false : true
                checkEnableGpshdop.checked = Settings.get("enableGpshdop",true) == 0 ? false : true
                checkEnableSatcount.checked = Settings.get("enableSatcount",true) == 0 ? false : true
                checkEnableWp_dist.checked = Settings.get("enableWp_dist",true) == 0 ? false : true
                checkEnableTimeInAir.checked = Settings.get("enableTimeInAir",true) == 0 ? false : true
                checkEnableDistToHome.checked = Settings.get("enableDistToHome",true) == 0 ? false : true
                checkEnableDistTraveled.checked = Settings.get("enableDistTraveled",true) == 0 ? false : true
                checkEnableLat.checked = Settings.get("enableLat",true) == 0 ? false : true
                checkEnableLng.checked = Settings.get("enableLng",true) == 0 ? false : true
                checkEnableArmed.checked = Settings.get("enableArmed",true) == 0 ? false : true
                checkEnableNavMode.checked = Settings.get("enableNavMode",true) == 0 ? false : true
                checkEnableGpsstatus.checked = Settings.get("enableGpsstatus",true) == 0 ? false : true
                checkSingleImage.checked = Settings.get("singlePane",false) == 0 ? false : true

            }
        }

        function save()
        {
            root.enableBackgroundVideo = checkVideo.checked
            container.videoEnabled = root.enableBackgroundVideo
            rollPitchIndicator2.enableRollPitch = checkRollPitch.checked
            rollPitchIndicator.enableRollPitch = checkRollPitch.checked
            Settings.set("enableRollPitchIndicator", rollPitchIndicator.enableRollPitch)
            pitchIndicator.visible = pitchIndicator2.visible = checkPitch.checked
            Settings.set("enablePitchIndicator", pitchIndicator.visible)
            altIndicator.visible = altIndicator2.visible = checkAlitude.checked
            Settings.set("enableAltIndicator", altIndicator.visible)
            speedIndicator2.visible = speedIndicator.visible = checkSpeed.checked
            Settings.set("enableSpeedIndicator", speedIndicator.visible)
            compassIndicator2.visible = compassIndicator.visible = checkCompass.checked
            Settings.set("enableCompassIndicator", compassIndicator.visible)
            informationIndicator2.visible = informationIndicator.visible = checkInformation.checked
            Settings.set("enableInformationIndicator", informationIndicator.visible)
            Settings.set("swapImages",checkSwapImages.checked)
            Settings.set("enableAirSpeed",checkEnableAirSpeed.checked)
            Settings.set("enableGroundSpeed",checkEnableGroundSpeed.checked)
            Settings.set("enableBatVoltage",checkEnableBatVoltage.checked)
            Settings.set("enableBatCurrent",checkEnableBatCurrent.checked)
            Settings.set("enableBatPercent",checkEnableBatPercent.checked)
            Settings.set("enableWatts",checkEnableWatts.checked)
            Settings.set("enableGpshdop",checkEnableGpshdop.checked)
            Settings.set("enableSatcount",checkEnableSatcount.checked)
            Settings.set("enableWp_dist",checkEnableWp_dist.checked)
            Settings.set("enableTimeInAir",checkEnableTimeInAir.checked)
            Settings.set("enableDistToHome",checkEnableDistToHome.checked)
            Settings.set("enableDistTraveled",checkEnableDistTraveled.checked)
            Settings.set("enableLat",checkEnableLat.checked)
            Settings.set("enableLng",checkEnableLng.checked)
            Settings.set("enableArmed",checkEnableArmed.checked)
            Settings.set("enableNavMode",checkEnableNavMode.checked)
            Settings.set("enableGpsstatus",checkEnableGpsstatus.checked)

            root.hudRight = Settings.get("HUDRight", true) == 0 ? false : true
            root.hudLeft = Settings.get("HUDLeft", true) == 0 ? false : true

            root.hudLChanged()
            root.hudRChanged()
            root.singlePnChanged()
        }

        Column
        {
            id: popupMenu
            z:3

            anchors
            {
                left: parent.left; top: parent.top; leftMargin: 10; topMargin: (2*root.mm)
            }

            CheckBox {
                z:3
                id: checkVideo
                text: "Video"
                onCheckedChanged:
                {
                    root.enableBackgroundVideo = checkVideo.checked
                    container.videoEnabled = root.enableBackgroundVideo
                }
            }

            CheckBox {
                z:3
                id: checkRollPitch
                text: "Roll/Pitch"
                onCheckedChanged: rollPitchIndicator.enableRollPitch = rollPitchIndicator2.enableRollPitch = checked
            }

            CheckBox {
                z:3
                id: checkPitch
                text: "Pitch"
                onCheckedChanged: pitchIndicator.visible = pitchIndicator2.visible = checked
            }

            CheckBox {
                z:3
                id: checkAlitude
                text: "Altitude"
                onCheckedChanged: altIndicator.visible = altIndicator2.visible = checked
            }

            CheckBox {
                z:3
                id: checkSpeed
                text: "Speed"
                onCheckedChanged: speedIndicator.visible = speedIndicator2.visible = checked
            }

            CheckBox {
                z:3
                id: checkCompass
                text: "Compass"
                onCheckedChanged: compassIndicator.visible = compassIndicator2.visible = checked
            }

            CheckBox {
                z:3
                id: checkInformation
                text: "Information"
                onCheckedChanged: informationIndicator.visible = informationIndicator2.visible = checked
            }

            CheckBox {
                z:3
                id: checkHUDLeft
                text: "HUD Left"
                onCheckedChanged:
                {
                    Settings.set("HUDLeft", checked)
                    hudLeft = checked
                }
            }

            CheckBox {
                z:3
                id: checkSplitImage
                text: "VR Mode"
                onCheckedChanged:
                {
                    root.splitImage = checked
                    container.splitImage = checked
                    Settings.set("splitImage", checked)
                }
            }
            CheckBox {
                z:3
                id: checkSwapImages
                text: "Swap Images"
                onCheckedChanged:
                {
                    root.swapImages = checked
                    container.swapImages = checked
                    Settings.set("swapImages", checked)
                }
            }
        }

        Column
        {
            id: popupMenu2
            z:3

            anchors
            {
                left: popupMenu.right; top: parent.top; leftMargin: 10; topMargin: (2*root.mm)
            }

            CheckBox {
                z:3
                id: checkEnableNavMode
                text: "NAV Mode"
                onCheckedChanged: informationIndicator.enableNavMode = informationIndicator2.enableNavMode = checked
            }

            CheckBox {
                z:3
                id: checkEnableGpsstatus
                text: "GPS Status"
                onCheckedChanged:
                {
                    informationIndicator.enableGpsstatus = informationIndicator2.enableGpsstatus = checked
                }
            }

            CheckBox {
                z:3
                id: checkEnableGpshdop
                text: "GPS HDOP"
                onCheckedChanged: informationIndicator.enableGpshdop = informationIndicator2.enableGpshdop = checked
            }

            CheckBox {
                z:3
                id: checkEnableSatcount
                text: "Sat Count"
                onCheckedChanged: informationIndicator.enableSatcount = informationIndicator2.enableSatcount = checked
            }

            CheckBox {
                z:3
                id: checkEnableLat
                text: "Latitude"
                onCheckedChanged: informationIndicator.enableLat = informationIndicator2.enableLat = checked
            }

            CheckBox {
                z:3
                id: checkEnableLng
                text: "Longitude"
                onCheckedChanged: informationIndicator.enableLng = informationIndicator2.enableLng = checked
            }

            CheckBox {
                z:3
                id: checkEnableTimeInAir
                text: "Time in Air"
                onCheckedChanged: informationIndicator.enableTimeInAir = informationIndicator2.enableTimeInAir = checked
            }

            CheckBox {
                z:3
                id: checkEnableArmed
                text: "Arm Status"
                onCheckedChanged: informationIndicator.enableArmed = informationIndicator2.enableArmed = checked
            }
            CheckBox {
                z:3
                id: checkHUDRight
                text: "HUD Right"
                onCheckedChanged:
                {
                    Settings.set("HUDRight", checked)
                    hudRight = checked
                }
            }
            CheckBox {
                z:3
                id: checkSingleImage
                text: "Single Pane"
                onCheckedChanged:
                {
                    root.singlePane = checked;
                    Settings.set("singlePane",checked)
                    if (checked)
                    {
                        checkSplitImage.checked = false
                        checkSplitImage.enabled = false
                    }
                    else
                    {
                        checkSplitImage.enabled = true
                        checkSplitImage.checked = Settings.get("splitImage", false) == 0 ? false : true
                    }
                }
            }
        }

        Column
        {
            id: popupMenu3
            z:3

            anchors
            {
                left: popupMenu2.right; top: parent.top; leftMargin: 10; topMargin: (2*root.mm)
            }

            CheckBox {
                z:3
                id: checkEnableAirSpeed
                text: "Air Speed"
                onCheckedChanged: informationIndicator.enableAirSpeed = informationIndicator2.enableAirSpeed = checked
            }

            CheckBox {
                z:3
                id: checkEnableGroundSpeed
                text: "Ground Speed"
                onCheckedChanged: informationIndicator.enableGroundSpeed = informationIndicator2.enableGroundSpeed = checked
            }

            CheckBox {
                z:3
                id: checkEnableDistToHome
                text: "Distance to Home"
                onCheckedChanged: informationIndicator.enableDistToHome = informationIndicator2.enableDistToHome = checked
            }

            CheckBox {
                z:3
                id: checkEnableDistTraveled
                text: "Distance Traveled"
                onCheckedChanged: informationIndicator.enableDistTraveled = informationIndicator2.enableDistTraveled = checked
            }

            CheckBox {
                z:3
                id: checkEnableWp_dist
                text: "Waypoint Distance"
                onCheckedChanged: informationIndicator.enableWp_dist = informationIndicator2.enableWp_dist = checked
            }

            CheckBox {
                z:3
                id: checkEnableBatVoltage
                text: "Battery Voltage"
                onCheckedChanged: informationIndicator.enableBatVoltage = informationIndicator2.enableBatVoltage = checked
            }

            CheckBox {
                z:3
                id: checkEnableBatCurrent
                text: "Battery Current"
                onCheckedChanged: informationIndicator.enableBatCurrent = informationIndicator2.enableBatCurrent = checked
            }

            CheckBox {
                z:3
                id: checkEnableBatPercent
                text: "Battery Percent"
                onCheckedChanged: informationIndicator.enableBatPercent = informationIndicator2.enableBatPercent = checked
            }

            CheckBox {
                z:3
                id: checkEnableWatts
                text: "Watts"
                onCheckedChanged: informationIndicator.enableWatts = informationIndicator2.enableWatts = checked
            }

            CheckBox {
                z:3
                text: "FullScreen"
                onCheckedChanged:
                {
                    container.fullScreenMode = !container.fullScreenMode
                    root.enableFullScreen = container.fullScreenMode
                }
            }
        }

        MouseArea
        {
            anchors.fill: parent

            onClicked:
            {
            }
        }
    }

    MouseArea
    {
        anchors.fill: parent

        onClicked:
        {
            root.popupVisible = false
            root.popupVisible2 = false
            if (root.popupContextVisible)
            {
                root.popupContextVisible = false
                popupContext.save()
            }
        }
    }

    RowLayout
    {
        id: topRow
        anchors.top: parent.top
        anchors.left: parent.left
        width: parent.width
        height: (14*root.mm)
        spacing: 0
        property real buttonHeight: (12*root.mm)

        onButtonHeightChanged: informationIndicator.marginTop = informationIndicator2.marginTop = buttonHeight

        Button
        {
            id: buttonMenu
            height: parent.height
            anchors.left: parent.left
            anchors.top: parent.top

            style: ButtonStyle
            {
                background: Rectangle
                {
                    implicitWidth: topRow.height
                    implicitHeight: topRow.height
                    color: "transparent"

                    Image
                    {
                        anchors.horizontalCenter: parent.horizontalCenter;
                        anchors.verticalCenter: parent.verticalCenter;
                        source: "./resources/components/primaryFlightDisplay/display.png"
                        width: topRow.buttonHeight
                        height: topRow.buttonHeight
                        sourceSize.height: topRow.buttonHeight
                        sourceSize.width: topRow.buttonHeight
                    }
                }
            }
            onClicked:
            {
                popupContextVisible = true
            }
        }

        Button
        {
            id: buttonSettings
            height: parent.height
            anchors.left: buttonMenu.right
            anchors.top: parent.top

            style: ButtonStyle
            {
                background: Rectangle
                {
                    implicitWidth: topRow.height
                    implicitHeight: topRow.height
                    color: "transparent"

                    Image
                    {
                        anchors.horizontalCenter: parent.horizontalCenter;
                        anchors.verticalCenter: parent.verticalCenter;
                        source: "./resources/components/primaryFlightDisplay/settings.png"
                        width: topRow.buttonHeight
                        height: topRow.buttonHeight
                        sourceSize.height: topRow.buttonHeight
                        sourceSize.width: topRow.buttonHeight
                    }
                }
            }
            onClicked: root.popupVisible = true
        }

        Button
        {
            id: buttonRecord
            height: parent.height
            anchors.left : buttonSettings.right
            anchors.leftMargin: (5*root.mm)
            anchors.top: parent.top

            style: ButtonStyle
            {
                background: Rectangle
                {
                    implicitWidth: topRow.height
                    implicitHeight: topRow.height
                    color: "transparent"

                    Image
                    {
                        anchors.horizontalCenter: parent.horizontalCenter;
                        anchors.verticalCenter: parent.verticalCenter;
                        source: container.recording ? "./resources/components/primaryFlightDisplay/recording.png" : "./resources/components/primaryFlightDisplay/record.png"
                        width: topRow.buttonHeight
                        height: topRow.buttonHeight
                        sourceSize.height: topRow.buttonHeight
                        sourceSize.width: topRow.buttonHeight
                    }
                }
            }
            onClicked:
            {
                container.recording = !container.recording
            }
        }

        Button
        {
            id: buttonTakePicture
            height: parent.height
            anchors.left: buttonRecord.right
            anchors.top: parent.top
            anchors.leftMargin: 10

            style: ButtonStyle
            {
                background: Rectangle
                {
                    implicitWidth: topRow.height
                    implicitHeight: topRow.height
                    color: "transparent"

                    Image
                    {
                        anchors.horizontalCenter: parent.horizontalCenter;
                        anchors.verticalCenter: parent.verticalCenter;
                        source: buttonTakePicture.pressed ? "./resources/components/primaryFlightDisplay/taking_picture.png" : "./resources/components/primaryFlightDisplay/take_picture.png"
                        width: topRow.buttonHeight
                        height: topRow.buttonHeight
                        sourceSize.height: topRow.buttonHeight
                        sourceSize.width: topRow.buttonHeight
                    }
                }
            }
            onPressedChanged:
            {
                container.takePicture = buttonTakePicture.pressed;
            }
        }

        Button
        {
            id: buttonZoomIn
            height: parent.height
            anchors.left: buttonTakePicture.right
            anchors.top: parent.top
            anchors.leftMargin: 10

            style: ButtonStyle
            {
                background: Rectangle
                {
                    implicitWidth: topRow.height
                    implicitHeight: topRow.height
                    color: "transparent"

                    Image
                    {
                        anchors.horizontalCenter: parent.horizontalCenter;
                        anchors.verticalCenter: parent.verticalCenter;
                        source: buttonZoomIn.pressed ? "./resources/components/primaryFlightDisplay/zooming_in.png" : "./resources/components/primaryFlightDisplay/zoomin.png"
                        width: topRow.buttonHeight
                        height: topRow.buttonHeight
                        sourceSize.height: topRow.buttonHeight
                        sourceSize.width: topRow.buttonHeight
                    }
                }
            }
            onPressedChanged:
            {
                container.zoomingIn = buttonZoomIn.pressed;
            }
        }

        Button
        {
            id: buttonZoomOut
            height: parent.height
            anchors.left: buttonZoomIn.right
            anchors.top: parent.top
            anchors.leftMargin: 10

            style: ButtonStyle
            {
                background: Rectangle
                {
                    implicitWidth: topRow.height
                    implicitHeight: topRow.height
                    color: "transparent"

                    Image
                    {
                        anchors.horizontalCenter: parent.horizontalCenter;
                        anchors.verticalCenter: parent.verticalCenter;
                        source: buttonZoomOut.pressed ? "./resources/components/primaryFlightDisplay/zooming_out.png" : "./resources/components/primaryFlightDisplay/zoomout.png"
                        width: topRow.buttonHeight
                        height: topRow.buttonHeight
                        sourceSize.height: topRow.buttonHeight
                        sourceSize.width: topRow.buttonHeight
                    }
                }
            }
            onPressedChanged:
            {
                container.zoomingOut = buttonZoomOut.pressed;
            }
        }

        Button
        {
            id: buttonSwapImages
            height: parent.height
            anchors.left: buttonZoomOut.right
            anchors.top: parent.top

            style: ButtonStyle
            {
                background: Rectangle
                {
                    implicitWidth: topRow.height
                    implicitHeight: topRow.height
                    color: "transparent"

                    Image
                    {
                        anchors.horizontalCenter: parent.horizontalCenter;
                        anchors.verticalCenter: parent.verticalCenter;
                        source: "./resources/components/primaryFlightDisplay/swap.png"
                        width: topRow.buttonHeight
                        height: topRow.buttonHeight
                        sourceSize.height: topRow.buttonHeight
                        sourceSize.width: topRow.buttonHeight
                    }
                }
            }
            onClicked:
            {
                checkSwapImages.checked = !checkSwapImages.checked
            }
        }

        Button
        {
            id: buttonFullScreen
            height: parent.height
            anchors.left: buttonSwapImages.right
            anchors.top: parent.top

            style: ButtonStyle
            {
                background: Rectangle
                {
                    implicitWidth: topRow.height
                    implicitHeight: topRow.height
                    color: "transparent"

                    Image
                    {
                        anchors.horizontalCenter: parent.horizontalCenter;
                        anchors.verticalCenter: parent.verticalCenter;
                        source: "./resources/components/primaryFlightDisplay/full-screen.png"
                        width: topRow.buttonHeight
                        height: topRow.buttonHeight
                        sourceSize.height: topRow.buttonHeight
                        sourceSize.width: topRow.buttonHeight
                    }
                }
            }
            onClicked:
            {
                container.fullScreenMode = !container.fullScreenMode
                root.enableFullScreen = container.fullScreenMode
            }
        }

        Button
        {
            id: buttonSettings2
            height: parent.height
            anchors.right: parent.right
            anchors.top: parent.top

            style: ButtonStyle
            {
                background: Rectangle
                {
                    implicitWidth: topRow.height
                    implicitHeight: topRow.height
                    color: "transparent"

                    Image
                    {
                        anchors.horizontalCenter: parent.horizontalCenter;
                        anchors.verticalCenter: parent.verticalCenter;
                        source: "./resources/components/primaryFlightDisplay/settings.png"
                        width: topRow.buttonHeight
                        height: topRow.buttonHeight
                        sourceSize.height: topRow.buttonHeight
                        sourceSize.width: topRow.buttonHeight
                    }
                }
            }
            onClicked: root.popupVisible2 = true
        }
    }

    MessageDialog
    {
        id: messageDialog
        icon : StandardIcon.Warning
        visible: root.showMessageBox
        title: ""
        text: root.messageBoxText
        onAccepted: { root.showMessageBox = false; }
    }
}

