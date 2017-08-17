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

Item {
    id: root
    property real airSpeed: 0
    property real groundSpeed: 0
    property real batVoltage: 0
    property real batCurrent: 0
    property real batPercent: 0
    property real watts: 0
    property real gpshdop: 0
    property real satcount: 0
    property real wp_dist: 0
    property real ch3percent: 0
    property int timeInAir: 0
    property int tiaMinutes: timeInAir/60
    property int tiaSeconds: timeInAir%60
    property real distToHome: 0
    property real distTraveled: 0
    property real lat: 0
    property real lng: 0
    property bool armed: false
    property string distUnit: ""
    property string speedUnit: ""
    property string message: ""
    property string navMode: ""
    property string gpsstatus: ""
    property color color: "white"
    property color colorOutline: "black"
    property real fontPointSize

    property bool enableAirSpeed: true
    property bool enableGroundSpeed: true
    property bool enableBatVoltage: true
    property bool enableBatCurrent: true
    property bool enableBatPercent: true
    property bool enableWatts: true
    property bool enableGpshdop: true
    property bool enableSatcount: true
    property bool enableWp_dist: true
    property bool enableCh3percent: false
    property bool enableTimeInAir: true
    property bool enableDistToHome: true
    property bool enableDistTraveled: true
    property bool enableLat: true
    property bool enableLng: true
    property bool enableArmed: true
    property bool enableNavMode: true
    property bool enableGpsstatus: true
    property real marginTop: 0
    property real paddingLeft: 0
    property real paddingRight: 0
    property real topLeftBottom: colTopLeft.y+colTopLeft.height
    property real bottomLeftTop: colBottomLeft.y
    property real topRightBottom: colTopRight.y+colTopRight.height
    property real bottomRightTop: colBottomRight.y

    Column {
        id: colTopLeft
        anchors {left: parent.left; top: parent.top; topMargin: marginTop+20; leftMargin: paddingLeft }


        Text {
            visible: enableGpsstatus
            color: root.color
            font.pointSize: fontPointSize
            styleColor: root.colorOutline
            style: Text.Outline
            text: "GPS: " + gpsstatus
        }
        Text {
            visible: enableGpshdop
            color: root.color
            font.pointSize: fontPointSize
            styleColor: root.colorOutline
            style: Text.Outline
            text: "HDOP: " + Math.round(gpshdop*10)/10
        }
        Text {
            visible: enableSatcount
            color: root.color
            font.pointSize: fontPointSize
            styleColor: root.colorOutline
            style: Text.Outline
            text: "SATS: " + satcount
        }
        Text {
            visible: enableLat
            color: root.color
            font.pointSize: fontPointSize
            styleColor: root.colorOutline
            style: Text.Outline
            text: "LAT: " + lat
        }
        Text {
            visible: enableLng
            color: root.color
            font.pointSize: fontPointSize
            styleColor: root.colorOutline
            style: Text.Outline
            text: "LNG: " + lng
        }
    }

    Column{
        id: colBottomLeft
        anchors {left: parent.left; bottom: parent.bottom; leftMargin: paddingLeft; bottomMargin: marginTop+20 }
        Text {
            visible: enableNavMode
            color: root.color
            font.pointSize: fontPointSize
            styleColor: root.colorOutline
            style: Text.Outline
            text: "FM: " + navMode
        }
        Text {
            visible: enableTimeInAir
            color: root.color
            font.pointSize: fontPointSize
            styleColor: root.colorOutline
            style: Text.Outline
            text: "TIA: " + tiaMinutes + ":" + tiaSeconds
        }
        Text {
            visible: enableAirSpeed
            color: root.color
            font.pointSize: fontPointSize
            styleColor: root.colorOutline
            style: Text.Outline
            text: "AS: " + airSpeed.toFixed(1) + speedUnit
        }
        Text {
            visible: enableGroundSpeed
            color: root.color
            font.pointSize: fontPointSize
            styleColor: root.colorOutline
            style: Text.Outline
            text: "GS: " + groundSpeed.toFixed(1) + speedUnit
        }
        Text {
            visible: enableCh3percent
            color: root.color
            font.pointSize: fontPointSize
            styleColor: root.colorOutline
            style: Text.Outline
            text: "CH3%: " + ch3percent
        }
    }

    Column {
        id: colTopRight
        anchors { right: parent.right; top: parent.top; topMargin: marginTop+20; rightMargin: paddingRight }
        Text {
            visible: enableArmed
            color: armed ? "green" : "red" //root.color
            font.pointSize: fontPointSize
            styleColor: root.colorOutline
            style: Text.Outline
            text: armed ? "ARM" : "D-ARM"
        }
        Text {
            visible: enableDistToHome
            color: root.color
            font.pointSize: fontPointSize
            styleColor: root.colorOutline
            style: Text.Outline
            text: "D2H: " + distToHome + distUnit
        }
        Text {
            visible: enableDistTraveled
            color: root.color
            font.pointSize: fontPointSize
            styleColor: root.colorOutline
            style: Text.Outline
            text: "DT: " + distTraveled + distUnit
        }
        Text {
            visible: enableWp_dist
            color: root.color
            font.pointSize: fontPointSize
            styleColor: root.colorOutline
            style: Text.Outline
            text: "WPD: " + wp_dist + distUnit
        }
    }

    Column {
        id: colBottomRight
        anchors {right: parent.right; bottom: parent.bottom; rightMargin: paddingRight; bottomMargin: marginTop+20 }
        Text {
            visible: enableBatVoltage
            color: root.color
            font.pointSize: fontPointSize
            styleColor: root.colorOutline
            style: Text.Outline
            text: "V: " + batVoltage.toFixed(1)
        }
        Text {
            visible: enableBatCurrent
            color: root.color
            font.pointSize: fontPointSize
            styleColor: root.colorOutline
            style: Text.Outline
            text: "I: " + batCurrent.toFixed(1)
        }
        Text {
            visible: enableBatPercent
            color: root.color
            font.pointSize: fontPointSize
            styleColor: root.colorOutline
            style: Text.Outline
            text: "%: " + batPercent.toFixed(1)
        }
        Text {
            visible: enableWatts
            color: root.color
            font.pointSize: fontPointSize
            styleColor: root.colorOutline
            style: Text.Outline
            text: "W: " + watts.toFixed(1)
        }
    }
}
