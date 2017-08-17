TEMPLATE = app
TARGET = QtGStreamerHUDApp

QT += core network gui qml opengl quick svg xml testlib serialport
QTPLUGIN += qsvg QtQuick2Plugin

DEFINES += QTVIDEOSINK_NAME=qt5videosink
DEFINES += __STDC_LIMIT_MACROS
DEFINES += _CRT_SECURE_NO_WARNINGS

SOURCES += main.cpp \
    CCurrentState.cpp \
    GStreamerPlayer.cpp \
    HUDApplicaton.cpp \
    PrimaryFlightDisplayQML.cpp \
    QCurrentState.cpp \
    QtGstreamerHUD.cpp \
    UAS1.cc \
    UASManager1.cc \
    LinkManager1.cc \
    MAVLinkDecoder1.cc \
    MAVLinkProtocol1.cc \
    ArduPilotMegaMAV1.cc \
    PxQuadMAV1.cc \
    SlugsMAV1.cc \
    TCPLink1.cc \
    UDPLink1.cc \
    comm/serialconnection.cc \
    comm/AbsPositionOverview.cc \
    comm/RelPositionOverview.cc \
    comm/VehicleOverview.cc \
    comm/LinkInterface.cpp \
    QsLog/QsLog.cpp \
    QsLog/QsLogDest.cpp \
    QsLog/QsLogDestConsole.cpp \
    QsLog/QsLogDestFile.cpp \
    globalobject.cc \
    comm/UASObject.cc \
    QGC.cc \
    GAudioOutput.cc \
    ui/RadioCalibration/RadioCalibrationData.cc \
    uas/QGCUASParamManager.cc \
    audio/AlsaAudio.cc

RESOURCES += qml.qrc

INCLUDEPATH += c:/gstreamer/1.0/x86/include/gstreamer-1.0
INCLUDEPATH += c:/qt-gstreamer-1.2.0/src
INCLUDEPATH += c:/qt-gstreamer-1.2.0/elements/gstqtvideosink
INCLUDEPATH += "C:/Program Files/boost/boost_1_43_0"
INCLUDEPATH += $$PWD/libs/mavlink/include/mavlink/v1.0/ardupilotmega
INCLUDEPATH += $$PWD/apps/mavlinkgen/msinttypes
INCLUDEPATH += $$PWD/uas
INCLUDEPATH += $$PWD/comm
INCLUDEPATH += $$PWD/QsLog
INCLUDEPATH += $$PWD/ui
INCLUDEPATH += $$PWD
INCLUDEPATH += C:/gtk3/include/glib-2.0
INCLUDEPATH += C:/gtk3/lib/glib-2.0/include

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

HEADERS += \
    CCurrentState.h \
    GStreamerPlayer.h \
    HUDApplication.h \
    PrimaryFlightDisplayQML.h \
    ProtocolInterface.h \
    QCurrentState.h \
    QtGStreamerHUD.h \
    UAS1.h \
    UASManager1.h \
    LinkManager1.h \
    MAVLinkDecoder1.h \
    MAVLinkProtocol1.h \
    UASInterface1.h \
    ArduPilotMegaMAV1.h \
    PxQuadMAV1.h \
    SlugsMAV1.h \
    TCPLink1.h \
    UDPLink1.h \
    QsLog/QsLog.h \
    QsLog/QsLogDest.h \
    QsLog/QsLogDestConsole.h \
    QsLog/QsLogDestFile.h \
    QsLog/QsLogDisableForThisFile.h \
    QsLog/QsLogLevel.h \
    globalobject.h \
    comm/SerialLinkInterface.h \
    comm/serialconnection.h \
    comm/LinkInterface.h \
    comm/AbsPositionOverview.h \
    comm/RelPositionOverview.h \
    comm/VehicleOverview.h \
    comm/UASObject.h \
    QGC.h \
    GAudioOutput.h \
    ui/RadioCalibration/RadioCalibrationData.h \
    uas/QGCUASParamManager.h \
    comm/QGCMAVLink.h \
    configuration.h \
    QGCGeo.h \
    audio/AlsaAudio.h \
    MG.h

OTHER_FILES += \
    qml/components/DigitalDisplay.qml \
    qml/components/StatusDisplay.qml \
    qml/components/ModeDisplay.qml \
    qml/components/HeartbeatDisplay.qml \
    qml/PrimaryFlightDisplayQML.qml \
    qml/PrimaryFlightDisplayWithVideoQML.qml \
    qml/HudQML.qml \
    qml/Storage.js \
    qml/components/RollPitchIndicator.qml \
    qml/components/AltitudeIndicator.qml \
    qml/components/SpeedIndicator.qml \
    qml/components/CompassIndicator.qml \
    qml/components/PitchIndicator.qml \
    qml/components/StatusMessageIndicator.qml \
    qml/components/InformationOverlayIndicator.qml \
    QsLog/QsLog.pri \
    QsLog/QsLogChanges.txt \
    qml/resources/components/primaryFlightDisplay/reset.svg \
    qml/resources/components/primaryFlightDisplay/connect.svg \
    qml/resources/components/primaryFlightDisplay/disconnect.svg

OTHER_FILES += \
    qml/ApmToolBar.qml \
    qml/components/Button.qml \
    qml/components/TextButton.qml \
    qml/resources/apmplanner/toolbar/connect.png \
    qml/resources/apmplanner/toolbar/flightplanner.png \
    qml/resources/apmplanner/toolbar/helpwizard.png \
    qml/resources/apmplanner/toolbar/light_initialsetup_icon.png \
    qml/resources/apmplanner/toolbar/terminal.png \
    qml/resources/apmplanner/toolbar/simulation.png \
    qml/resources/apmplanner/toolbar/light_tuningconfig_icon.png \
    qml/resources/apmplanner/toolbar/flightdata.png \
    qml/resources/apmplanner/toolbar/disconnect.png \
    qml/resources/apmplanner/toolbar/donate.png \
    qml/resources/components/primaryFlightDisplay/pause.svg \
    qml/resources/components/primaryFlightDisplay/play.svg \
    qml/resources/components/primaryFlightDisplay/stop.svg

win32:CONFIG(release, debug|release): LIBS += -L$$PWD/../../../qt-gstreamer-1.2.0/build/src/QGst/release/ -lQt5GStreamer-1.0
else:win32:CONFIG(debug, debug|release): LIBS += -L$$PWD/../../../qt-gstreamer-1.2.0/build/src/QGst/debug/ -lQt5GStreamer-1.0

win32:CONFIG(release, debug|release): LIBS += -L$$PWD/../../../qt-gstreamer-1.2.0/build/src/QGst/release/ -lQt5GStreamerUi-1.0
else:win32:CONFIG(debug, debug|release): LIBS += -L$$PWD/../../../qt-gstreamer-1.2.0/build/src/QGst/debug/ -lQt5GStreamerUi-1.0

win32:CONFIG(release, debug|release): LIBS += -L$$PWD/../../../qt-gstreamer-1.2.0/build/src/QGst/release/ -lQt5GStreamerQuick-1.0
else:win32:CONFIG(debug, debug|release): LIBS += -L$$PWD/../../../qt-gstreamer-1.2.0/build/src/QGst/debug/ -lQt5GStreamerQuick-1.0

win32:CONFIG(release, debug|release): LIBS += -L$$PWD/../../../qt-gstreamer-1.2.0/build/src/QGst/release/ -lQt5GStreamerUtils-1.0
else:win32:CONFIG(debug, debug|release): LIBS += -L$$PWD/../../../qt-gstreamer-1.2.0/build/src/QGst/debug/ -lQt5GStreamerUtils-1.0

DEPENDPATH += $$PWD/../../../qt-gstreamer-1.2.0/build/src/QGst/Debug

win32:CONFIG(release, debug|release): LIBS += -L$$PWD/../../../qt-gstreamer-1.2.0/build/src/QGlib/release/ -lQt5GLib-2.0
else:win32:CONFIG(debug, debug|release): LIBS += -L$$PWD/../../../qt-gstreamer-1.2.0/build/src/QGlib/debug/ -lQt5GLib-2.0

DEPENDPATH += $$PWD/../../../qt-gstreamer-1.2.0/build/src/QGlib/Debug

win32:CONFIG(release, debug|release): LIBS += -L$$PWD/../../../qt-gstreamer-1.2.0/build/elements/gstqtvideosink/Release -lgstqt5videosink
else:win32:CONFIG(debug, debug|release): LIBS += -L$$PWD/../../../qt-gstreamer-1.2.0/build/elements/gstqtvideosink/Debug/ -lgstqt5videosink

LIBS += -LC:/gstreamer/1.0/x86/lib -lgstreamer-1.0
