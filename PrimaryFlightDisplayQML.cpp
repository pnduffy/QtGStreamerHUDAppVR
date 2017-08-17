/*===================================================================
APM_PLANNER Open Source Ground Control Station

(c) 2014 Bill Bonney <billbonney@communistech.com>

This file is part of the APM_PLANNER project

    APM_PLANNER is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    APM_PLANNER is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with APM_PLANNER. If not, see <http://www.gnu.org/licenses/>.

======================================================================*/
#include "PrimaryFlightDisplayQML.h"
#include <QVBoxLayout>
#include <QMessagebox>
#include <QtQml/QQmlContext>
#include <QtQuick/QQuickItem>
#include <QtQml/QQmlEngine>
#include <QGst/Init>
#include <QSettings>
#include <QApplication>
#include <RelPositionOverview.h>
#include <AbsPositionOverview.h>
#include <VehicleOverview.h>
#include "LinkManager1.h"
#include "UASManager1.h"
#include <QGst/Quick/VideoItem>
#include "HUDApplication.h"

#define ToRad(x) (x*0.01745329252)      // *pi/180
#define ToDeg(x) (x*57.2957795131)      // *180/pi

// Callback to update the custom plugin
void* update_node(void* surface,  void* node, qreal x, qreal y, qreal w, qreal h);

QDialog * PrimaryFlightDisplayQML::s_primaryFlightDisplayDialog = NULL;

PrimaryFlightDisplayQML::PrimaryFlightDisplayQML(QWidget *parent) :
    QWidget(parent),
    m_declarativeView(NULL),
    m_uasInterface(NULL),						 
    m_player(NULL),
    m_player2(NULL),	
	m_surface(NULL),
    m_surface2(NULL),
    m_viewcontainer(NULL),
    m_showToolAction(NULL),
    m_videoEnabled(true),
    m_topMostMode(false),
    m_enableGStreamer(true),
    m_uasConnected(false),
    m_setHome(false),
    m_sonyCamera(NULL),
    m_recording(false),
    m_zoomingIn(false),
    m_zoomingOut(false),
    m_close(false)
{
    m_currentState = new QCurrentState();
    m_declarativeView = new QQuickView();
    m_surface = new QGst::Quick::VideoSurface;
    m_surface2 = new QGst::Quick::VideoSurface;	
    m_player = new GStreamerPlayer(m_declarativeView);
    m_player->setVideoSink(m_surface->videoSink());
	m_player2 = new GStreamerPlayer(m_declarativeView);
    m_player2->setVideoSink(m_surface2->videoSink());

    m_declarativeView->setResizeMode(QQuickView::SizeRootObjectToView);
    m_declarativeView->engine()->addImportPath("./qml"); //For local or win32 builds
    m_declarativeView->engine()->addImportPath("./qml/quick2"); //For local or win32 builds

    m_declarativeView->rootContext()->setContextProperty(QLatin1String("videoSurface1"), m_surface);
    m_declarativeView->rootContext()->setContextProperty(QLatin1String("videoSurface2"), m_surface2);
    m_declarativeView->rootContext()->setContextProperty(QLatin1String("player"), m_player);
    m_declarativeView->rootContext()->setContextProperty(QLatin1String("player2"), m_player2);
    m_declarativeView->rootContext()->setContextProperty(QLatin1String("container"), this);
    m_declarativeView->rootContext()->setContextProperty(QLatin1String("currentState"), m_currentState);

    connect(m_player, SIGNAL(messageBox(QString)), this,
            SLOT(messageBox(QString)), Qt::UniqueConnection);

    connect(m_player2, SIGNAL(messageBox(QString)), this,
            SLOT(messageBox(QString)), Qt::UniqueConnection);
			
    // Default to video display until user selects
    InitializeDisplayWithVideo();

    // Connect with UAS
    connect(UASManager::instance(), SIGNAL(activeUASSet(UASInterface*)), this,
            SLOT(setActiveUAS(UASInterface*)), Qt::UniqueConnection);

    show();
}

PrimaryFlightDisplayQML::~PrimaryFlightDisplayQML()
{
    delete m_player;
    m_player = NULL;
	
	delete m_player2;
	m_player2=NULL;

    if (s_primaryFlightDisplayDialog != NULL)
    {
        s_primaryFlightDisplayDialog->close();
        s_primaryFlightDisplayDialog = NULL;
    }

    if (m_currentState != NULL)
    {
        delete m_currentState;
        m_currentState = NULL;
    }

    if (m_sonyCamera != NULL)
    {
        delete m_sonyCamera;
    }
}

void PrimaryFlightDisplayQML::setActiveUAS(UASInterface *uas)
{
    if (m_uasInterface) {
        disconnect(m_uasInterface,SIGNAL(textMessageReceived(int,int,int,QString)),
                this,SLOT(uasTextMessage(int,int,int,QString)));

        disconnect(m_uasInterface, SIGNAL(navModeChanged(int, int, QString)),
                   this, SLOT(updateNavMode(int, int, QString)));

    }
    m_uasInterface = dynamic_cast<UAS*>(uas);

    if (m_uasInterface) {
        connect(uas,SIGNAL(textMessageReceived(int,int,int,QString)),
                this,SLOT(uasTextMessage(int,int,int,QString)));
        connect(uas, SIGNAL(navModeChanged(int, int, QString)),
                this, SLOT(updateNavMode(int, int, QString)));

		m_currentState->setUAS(m_uasInterface);											   
        VehicleOverview *obj = LinkManager::instance()->getUasObject(uas->getUASID())->getVehicleOverview();
        RelPositionOverview *rel = LinkManager::instance()->getUasObject(uas->getUASID())->getRelPositionOverview();
        AbsPositionOverview *abs = LinkManager::instance()->getUasObject(uas->getUASID())->getAbsPositionOverview();
		if (m_declarativeView)
		{
			m_declarativeView->rootContext()->setContextProperty("vehicleoverview",obj);
			m_declarativeView->rootContext()->setContextProperty("relpositionoverview",rel);
			m_declarativeView->rootContext()->setContextProperty("abspositionoverview",abs);
			QMetaObject::invokeMethod(m_declarativeView->rootObject(),"activeUasSet");
		}										 
    }
}

void PrimaryFlightDisplayQML::uasTextMessage(int uasid, int componentid, int severity, QString text)
{
    Q_UNUSED(uasid);
    Q_UNUSED(componentid);
    if (severity >=0 && severity<255)
    {
        if (m_declarativeView)
        {
            QObject *root = m_declarativeView->rootObject();
            root->setProperty("statusMessage", text);
            root->setProperty("showStatusMessage", true);
            QTimer::singleShot(5000,this,SLOT(clearTextMessage()));
        }
    }
	qCritical() << text;				
}

void PrimaryFlightDisplayQML::clearTextMessage()
{
    if (m_declarativeView)
    {
        QObject *root = m_declarativeView->rootObject();
        root->setProperty("statusMessage", "");
        root->setProperty("showStatusMessage", false);
    }
}

void PrimaryFlightDisplayQML::updateNavMode(int uasid, int mode, const QString& text)
{
    Q_UNUSED(uasid);
    Q_UNUSED(mode);
	if (m_declarativeView)
	{
		QObject *root = m_declarativeView->rootObject();
		root->setProperty("navMode", text);
	}
}

void PrimaryFlightDisplayQML::applicationStateChanged(Qt::ApplicationState state)
{
    QString strState = "Unknown";
    switch (state)
    {
        case Qt::ApplicationState::ApplicationSuspended:
            strState = "Suspended";
            if (m_player) m_player->stop();
            break;
        case Qt::ApplicationState::ApplicationHidden:
            strState = "Hidden";
            if (m_player) m_player->stop();
            break;
        case Qt::ApplicationState::ApplicationInactive:
            strState = "Inactive";
            if (m_player) m_player->stop();
            break;
        case Qt::ApplicationState::ApplicationActive:
            strState = "Active";
            if (m_player) m_player->play();
            break;
    }

    qDebug() << "Application State Changed to " + strState;
}

// QtGStreamer and the Qt docking system don't play well, so when we dock/undock, we need to reload (TODO: fix this)
void PrimaryFlightDisplayQML::topLevelChanged(bool topLevel)
{
    if (m_videoEnabled && topLevel) InitializeDisplayWithVideo();
}

void PrimaryFlightDisplayQML::dockLocationChanged(Qt::DockWidgetArea)
{
    if (m_videoEnabled) InitializeDisplayWithVideo();
}

void PrimaryFlightDisplayQML::InitializeDisplayWithVideo()
{
    QString qml = "./qml/PrimaryFlightDisplayWithVideoQML.qml";
    QFileInfo fileInfo(qml);
    QUrl url = QUrl::fromLocalFile(fileInfo.canonicalFilePath());

    if (!QFile::exists(qml))
    {
        QMessageBox::information(0,"Error", "" + qml + " not found. Please reinstall the application and try again");
        exit(-1);
    }

    m_declarativeView->setFlags(Qt::FramelessWindowHint);
    m_declarativeView->setSource(url);

    QVBoxLayout* layout = new QVBoxLayout();
    m_viewcontainer = QWidget::createWindowContainer(m_declarativeView);

    layout->addWidget(m_viewcontainer);
    layout->setMargin(0);
    setLayout(layout);
    setActiveUAS(UASManager::instance()->getActiveUAS());

    m_player->play();
    m_player2->play();
}

void PrimaryFlightDisplayQML::enableVideo(bool enabled)
{
    if (enabled) 
	{
		m_player->play();
		m_player2->play();
	}
    else 
	{
		m_player->stop();
		m_player2->stop();
	}
}

void PrimaryFlightDisplayQML::setTopMostMode(bool value) {

    m_topMostMode = value;

    if (!value && s_primaryFlightDisplayDialog != NULL) {

        if (m_showToolAction)
        {
            m_showToolAction->setChecked(false);
            m_showToolAction->trigger();
        }

        emit topMostModeChanged();
    }

    if (value && s_primaryFlightDisplayDialog == NULL) {

        // Hide dock version from user
        if (m_showToolAction)
        {
            m_showToolAction->setChecked(true);
            m_showToolAction->trigger();
        }

        // Create top most dialog
        s_primaryFlightDisplayDialog = new QDialog(NULL, Qt::CustomizeWindowHint | Qt::WindowTitleHint | Qt::WindowMinMaxButtonsHint | Qt::WindowStaysOnTopHint);
        s_primaryFlightDisplayDialog->resize(640,480);
        PrimaryFlightDisplayQML *child = new PrimaryFlightDisplayQML();
        child->setShowToolAction(m_showToolAction);
        s_primaryFlightDisplayDialog->setModal(false);
        s_primaryFlightDisplayDialog->setAttribute(Qt::WA_DeleteOnClose);
        s_primaryFlightDisplayDialog->setWindowTitle(tr("Primary Flight Display"));

        s_primaryFlightDisplayDialog->setLayoutDirection (Qt::LeftToRight);
        QBoxLayout *mainDialogLayout = new QBoxLayout(QBoxLayout::LeftToRight);
        mainDialogLayout->addWidget(child);
        mainDialogLayout->setMargin (0);

        s_primaryFlightDisplayDialog->setLayout(mainDialogLayout);
        mainDialogLayout->update();
        mainDialogLayout->activate();

        s_primaryFlightDisplayDialog->setObjectName(child->objectName());
        s_primaryFlightDisplayDialog->setMinimumHeight(320);
        s_primaryFlightDisplayDialog->setMinimumWidth(240);

        s_primaryFlightDisplayDialog->show();

        connect(child, SIGNAL(topMostModeChanged()), this, SLOT(onTopMostModeChanged()));

        child->show();

        emit topMostModeChanged();
    }
}

void PrimaryFlightDisplayQML::setPipelineString(QString pipelineString) 
{ 
	m_pipelineString = pipelineString; emit pipelineStringChanged(); 
    if (m_player) m_player->setPipelineString(m_pipelineString);
}

void PrimaryFlightDisplayQML::setPipelineString2(QString pipelineString) 
{ 
	m_pipelineString2 = pipelineString; emit pipelineStringChanged2(); 
    if (m_player) m_player2->setPipelineString(m_pipelineString2);
}

void PrimaryFlightDisplayQML::setCameraIpAddress(QString ipAddress)
{
    m_cameraIpAddress = ipAddress; emit cameraIpAddressChanged();
}

void PrimaryFlightDisplayQML::messageBox(QString text)
{
    QObject *root = m_declarativeView->rootObject();
    root->setProperty("messageBoxText", text);
    root->setProperty("showMessageBox", true);
    qCritical() << text;
}

void PrimaryFlightDisplayQML::setIpOrHost(QString ipOrHost)
{
    m_ipOrHost = ipOrHost; emit ipOrHostChanged();
}

void PrimaryFlightDisplayQML::ResetDisplay()
{
    // Removes the current engine and widgets
    if (m_player)
    {
        m_player->stop();
		m_player2->stop();
        delete m_player;
		delete m_player2;
        m_player = NULL;
		m_player2 = NULL;
    }

    if (m_declarativeView)
    {
        m_declarativeView->hide();
        m_declarativeView->close();
        m_declarativeView->rootContext()->setContextProperty(QLatin1String("videoSurface1"), 0);
        m_declarativeView->rootContext()->setContextProperty(QLatin1String("videoSurface2"), 0);
        m_declarativeView->engine()->clearComponentCache();
        m_declarativeView->setParent(NULL);
        m_declarativeView = NULL;
    }

	if (m_surface)
	{
		delete m_surface;
		m_surface = NULL;
	}

	if (m_surface2)
	{
        delete m_surface2;
		m_surface2 = NULL;
	}

    if (m_viewcontainer)
    {
        layout()->removeWidget(m_viewcontainer);
        m_viewcontainer->close();
        m_viewcontainer = NULL;
        delete layout();
    }
}

void PrimaryFlightDisplayQML::setVideoEnabled(bool value) {
    this->m_videoEnabled = value;
    this->enableVideo(value);
    emit videoEnabledChanged();
}

void PrimaryFlightDisplayQML::setUasConnected(bool value) {

    LinkManager *pLinkMgr = LinkManager::instance();

    int iLinkId = -1;
    if (m_connectionMap.contains(m_ipOrHost))
    {
        iLinkId = m_connectionMap.value(m_ipOrHost);
    }

    if (iLinkId >= 0)
    {
        if (value) value = pLinkMgr->connectLink(iLinkId);
        else  pLinkMgr->disconnectLink(iLinkId);
        this->m_uasConnected = value;
        emit uasConnectedChanged();
        return;
    }

    // Not in list, add new
    QStringList split = m_ipOrHost.split(":");
    QString token;
    QString ipOrHost;

    int iToken = 0;
    int iBaudRate = 0;
    int iPort = 0;

    bool isSerialPort = false;
    bool isTCP = false;
    bool isUDP = false;

    QString text;

    Q_FOREACH(token, split)
    {
        switch (iToken)
        {

        case 0:
            if (token.startsWith("COM"))
            {
                isSerialPort = true;
                ipOrHost = token;
                iToken++;
                break;
            }
            if (token.startsWith("TCP"))
            {
                isTCP = true;
                iToken++;
                break;
            }
            if (token.startsWith("UDP"))
            {
                isUDP = true;
                iToken++;
                break;
            }

            // Error if got here, invalid string
            text = "Invalid connect string '" + m_ipOrHost + "', missing COM,TCP,UDP";
            this->messageBox(text);
            value = false;
            this->m_uasConnected = value;
            emit uasConnectedChanged();
            return;


        case 1:
            if (isSerialPort)
            {
                iBaudRate = token.toInt();
                iToken++;
                break;
            }
            if (isTCP)
            {
                ipOrHost = token;
                iToken++;
                break;
            }
            if (isUDP)
            {
                iPort = token.toInt();
                iToken++;
                break;
            }
            break;

        case 2:
            if (isTCP)
            {
                iPort = token.toInt();
                iToken++;
                break;
            }
            break;
        }
    }

    if (isSerialPort)
    {
        iLinkId = pLinkMgr->addSerialConnection(ipOrHost, iBaudRate);
        m_connectionMap.insert(m_ipOrHost, iLinkId);
    }
    else if (isTCP)
    {
        QHostAddress addr(ipOrHost);
        iLinkId = pLinkMgr->addTcpConnection(addr, iPort, false);
        m_connectionMap.insert(m_ipOrHost, iLinkId);
    }
    else if (isUDP)
    {
        iLinkId = pLinkMgr->addUdpConnection(QHostAddress::Any, iPort);
        m_connectionMap.insert(m_ipOrHost, iLinkId);
    }

    if (!pLinkMgr->connectLink(iLinkId))
    {
        text = "Cannot open connection '" + m_ipOrHost + "'!";
        this->messageBox(text);
        value = false;
    }

    this->m_uasConnected = value;
    emit uasConnectedChanged();
}

void PrimaryFlightDisplayQML::resetHome(bool value)
{
    if (value && this->m_uasInterface != NULL)
    {
        this->m_setHome = true;
        emit setHomeChanged();
        AbsPositionOverview *abs = LinkManager::instance()->getUasObject(this->m_uasInterface->getUASID())->getAbsPositionOverview();
        abs->setLatHome(0);
        this->m_setHome = false;
        emit setHomeChanged();
    }
}

void PrimaryFlightDisplayQML::setFullScreenMode(bool value) {
    this->m_fullScreenMode = value;
    QWidget *p = dynamic_cast<QWidget*>(this->parent());
    if (!value &&  p->isFullScreen()) {
        p->showNormal();
        emit fullScreenModeChanged();
    }

    if (value && !p->isFullScreen()) {
        p->showFullScreen();
        emit fullScreenModeChanged();
    }
}

bool PrimaryFlightDisplayQML::isFullScreenMode() const {
    QWidget *p = dynamic_cast<QWidget*>(this->parent());
    return p->isFullScreen();
}

void PrimaryFlightDisplayQML::setSwapColorMatrix1(bool value) {
    this->m_swapColorMatrix1 = value;
    this->m_player->setSwapColorMatrix(value);
    emit swapColorMatrixChanged1();
}

bool PrimaryFlightDisplayQML::isSwapColorMatrix1() const {
    return this->m_player->getSwapColorMatrix();
}

void PrimaryFlightDisplayQML::setSwapColorMatrix2(bool value) {
    this->m_swapColorMatrix2 = value;
    this->m_player2->setSwapColorMatrix(value);
    emit swapColorMatrixChanged2();
}

bool PrimaryFlightDisplayQML::isSwapColorMatrix2() const {
    return this->m_player2->getSwapColorMatrix();
}

void PrimaryFlightDisplayQML::setRecording(bool value) {

    src::Sony_Remote_Camera_Interface* camera = this->camera();
    if (camera != NULL)
    {
        try
        {
            if (camera->Set_Shoot_Mode(src::Camera_State::MOVIE) == src::SC_NO_ERROR)
            {
                camera->Set_Recording(value);
            }
            this->m_recording = value;
        }
        catch(...)
        {}
    }

    emit recordingChanged();
}

bool PrimaryFlightDisplayQML::isRecording() const {
    return this->m_recording;
}

void PrimaryFlightDisplayQML::setZoomingIn(bool value) {

    src::Sony_Remote_Camera_Interface* camera = this->camera();
    if (camera != NULL)
    {
        try
        {
            camera->Zoom(true, value);
            this->m_zoomingIn = value;
        }
        catch(...)
        {}
    }

    emit zoomingInChanged();
}

bool PrimaryFlightDisplayQML::isZoomingIn() const {
    return this->m_zoomingIn;
}

void PrimaryFlightDisplayQML::setZoomingOut(bool value) {

    src::Sony_Remote_Camera_Interface* camera = this->camera();
    if (camera != NULL)
    {
        try
        {
            camera->Zoom(false, value);
            this->m_zoomingOut = value;
        }
        catch(...)
        {}
    }

    emit zoomingOutChanged();
}

bool PrimaryFlightDisplayQML::isZoomingOut() const {
    return this->m_zoomingOut;
}

void PrimaryFlightDisplayQML::onTopMostModeChanged()
{
    // Will delete itself
    if (s_primaryFlightDisplayDialog)
    {
        s_primaryFlightDisplayDialog->close();
        s_primaryFlightDisplayDialog = NULL;
        m_topMostMode = false;
    }

    emit topMostModeChanged();
}

void PrimaryFlightDisplayQML::hideEvent(QHideEvent *event)
{
    QWidget::hideEvent(event);
}

void PrimaryFlightDisplayQML::closeEvent(QCloseEvent *event)
{
    if (!m_close)
    {
        m_close = true;
        event->setAccepted(false);
        m_player->setStopped(true);
        m_player2->setStopped(true);
        QTimer::singleShot(1500,this->parent(),SLOT(close()));
        return;
    }

    ResetDisplay();
    QWidget::closeEvent(event);
}

void PrimaryFlightDisplayQML::SetCurrentState(CCurrentState &theState)
{
	// This method will update the bound state variables in the QML
	m_currentState->setRoll(theState.getRoll());
	m_currentState->setPitch(theState.getPitch());
	m_currentState->setYaw(theState.getYaw());
	m_currentState->setGroundspeed(theState.getGroundspeed());
	m_currentState->setAirspeed(theState.getAirspeed());
	m_currentState->setBatteryVoltage(theState.getBatteryVoltage());
	m_currentState->setBatteryCurrent(theState.getBatteryCurrent());
	m_currentState->setBatteryRemaining(theState.getBatteryRemaining());
	m_currentState->setAltitude(theState.getAltitude());

	m_currentState->setWatts(theState.getWatts());
	m_currentState->setGpsstatus(theState.getGpsStatus());
	m_currentState->setGpshdop(theState.getGpsHdop());
	m_currentState->setSatcount(theState.getSatCount());
	m_currentState->setWp_dist(theState.getWpDist());
	m_currentState->setCh3percent(theState.getCh3Percent());
	m_currentState->setTimeInAir(theState.getTimeInAir());
	m_currentState->setDistToHome(theState.getDistToHome());
	m_currentState->setDistTraveled(theState.getDistTravled());
	m_currentState->setAZToMAV(theState.getAzToMav());
	
	m_currentState->setLat(theState.getLat());
	m_currentState->setLng(theState.getLng());

	m_currentState->setArmed(theState.getArmed());

	m_currentState->setDistUnit(QString::fromWCharArray(theState.getDistUnit()));
	m_currentState->setSpeedUnit(QString::fromWCharArray(theState.getSpeedUnit()));
	m_currentState->setMessage(QString::fromWCharArray(theState.getMessage()));
	m_currentState->setFlightMode(QString::fromWCharArray(theState.getFlightMode()));

}

bool PrimaryFlightDisplayQML::isSplitImage() const {
    return this->m_player->getSplitImage();
}

void PrimaryFlightDisplayQML::setSplitImage(bool value) {

    m_splitImage = value;
    m_player->setSplitImage(value);
    m_player2->setSplitImage(value);

    QSize size = theMainWindow->size();
    size += QSize(0,1);
    theMainWindow->resize(size);
    QTimer::singleShot(10,this,SLOT(updateSize()));

    qDebug() << "Image split mode " << (value ? "on" : "off");
    emit splitImageChanged();
}

void PrimaryFlightDisplayQML::updateSize()
{
    QSize size = theMainWindow->size();
    size += QSize(0,-1);
    theMainWindow->resize(size);
}

bool PrimaryFlightDisplayQML::isSwapImages() const {
    return m_swapImages;
																																										   
}

void PrimaryFlightDisplayQML::setSwapImages(bool value) {
    this->m_swapImages = value;
    emit swapImagesChanged();
    setSplitImage(this->m_splitImage);
}

src::Sony_Remote_Camera_Interface* PrimaryFlightDisplayQML::camera()
{
    if (m_sonyCamera == NULL)
    {
        if (!m_cameraIpAddress.isEmpty())
        {
            QStringList adapterAndIp = m_cameraIpAddress.remove("\n").split(":");
            if (adapterAndIp.count() == 2)
            {
                QString adapterIpAddress = adapterAndIp.at(0);
                QString cameraIpAddress = adapterAndIp.at(1);

                QString liveViewURL = QString("http://%1:60152/liveview.JPG?%211234%21http%2dget%3a%2a%3aimage%2fjpeg%3a%2a%21%21%21%21%21").arg(cameraIpAddress);
                QString cameraServiceURL = QString("http://%1:10000/sony").arg(cameraIpAddress);
                m_sonyCamera = src::GetSonyRemoteCamera(adapterIpAddress.toStdString().c_str(), cameraServiceURL.toStdString().c_str(), liveViewURL.toStdString().c_str());
            }
       }
    }

    return m_sonyCamera;
}




