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

#ifndef PRIMARYFLIGHTDISPLAYQML_H
#define PRIMARYFLIGHTDISPLAYQML_H

#include "sony_capture/sony_remote_camera.h"
#include "UASInterface1.h"
#include "UAS1.h"			 
#include "QCurrentState.h"
#include "CCurrentState.h"
#include <QWidget>
#include <QDialog>
#include <QtQuick/QQuickView>
#include <QGst/Quick/VideoSurface>
#include "GStreamerPlayer.h"


class PrimaryFlightDisplayQML : public QWidget
{
    Q_OBJECT

public:
    explicit PrimaryFlightDisplayQML(QWidget *parent = 0);
    ~PrimaryFlightDisplayQML();

    static QDialog *s_primaryFlightDisplayDialog;

private slots:
    void setActiveUAS(UASInterface *uas);
    void uasTextMessage(int uasid, int componentid, int severity, QString text);
    void updateNavMode(int uasid, int mode, const QString& text);
    void topLevelChanged(bool topLevel);
    void dockLocationChanged(Qt::DockWidgetArea area);
    void enableVideo(bool enabled);
    void onTopMostModeChanged();
    void applicationStateChanged(Qt::ApplicationState state);
    void messageBox(QString text);
    void updateSize();
    void clearTextMessage();

signals:
    void fullScreenModeChanged();
    void videoEnabledChanged();
    void topMostModeChanged();
	void pipelineStringChanged();
    void pipelineStringChanged2();	
    void ipOrHostChanged();
    void uasConnectedChanged();
    void setHomeChanged();
    void swapColorMatrixChanged1();
    void swapColorMatrixChanged2();
    void recordingChanged();
    void splitImageChanged();
    void zoomingInChanged();
    void zoomingOutChanged();
    void cameraIpAddressChanged();
    void swapImagesChanged();

public:
    Q_PROPERTY(bool fullScreenMode READ isFullScreenMode WRITE setFullScreenMode NOTIFY fullScreenModeChanged)
    Q_PROPERTY(bool swapColorMatrix1 READ isSwapColorMatrix1 WRITE setSwapColorMatrix1 NOTIFY swapColorMatrixChanged1)
    Q_PROPERTY(bool swapColorMatrix2 READ isSwapColorMatrix2 WRITE setSwapColorMatrix2 NOTIFY swapColorMatrixChanged2)    
	Q_PROPERTY(bool recording READ isRecording WRITE setRecording NOTIFY recordingChanged)
    Q_PROPERTY(bool swapImages READ isSwapImages WRITE setSwapImages NOTIFY swapImagesChanged)
	Q_PROPERTY(bool zoomingIn READ isZoomingIn WRITE setZoomingIn NOTIFY zoomingInChanged)
    Q_PROPERTY(bool zoomingOut READ isZoomingOut WRITE setZoomingOut NOTIFY zoomingOutChanged)
    Q_PROPERTY(bool videoEnabled READ isVideoEnabled WRITE setVideoEnabled NOTIFY videoEnabledChanged)
    Q_PROPERTY(bool uasConnected READ isUasConnected WRITE setUasConnected NOTIFY uasConnectedChanged)
    Q_PROPERTY(bool setHome READ isSetHome WRITE resetHome NOTIFY setHomeChanged)
    Q_PROPERTY(bool splitImage READ isSplitImage WRITE setSplitImage NOTIFY splitImageChanged)

    void setFullScreenMode(bool value);
    bool isFullScreenMode() const;

    void setSwapColorMatrix1(bool value);
    bool isSwapColorMatrix1() const;

    void setSwapColorMatrix2(bool value);
    bool isSwapColorMatrix2() const;	

    void setSplitImage(bool value);
    bool isSplitImage() const;
	
    void setSwapImages(bool value);
    bool isSwapImages() const;

    void setRecording(bool value);
    bool isRecording() const;

    void setZoomingIn(bool value);
    bool isZoomingIn() const;

    void setZoomingOut(bool value);
    bool isZoomingOut() const;

    void setVideoEnabled(bool value);
    bool isVideoEnabled() const { return m_videoEnabled; }

    void setUasConnected(bool value);
    bool isUasConnected() const { return m_uasConnected; }

    void resetHome(bool value);
    bool isSetHome() const { return m_setHome; }

    Q_PROPERTY(bool topMostMode READ isTopMostMode WRITE setTopMostMode NOTIFY topMostModeChanged)
    void setTopMostMode(bool value);
    bool isTopMostMode() const { return s_primaryFlightDisplayDialog != NULL; }

    Q_PROPERTY(QString pipelineString READ getPipelineString WRITE setPipelineString NOTIFY pipelineStringChanged)
	void setPipelineString(QString pipelineString); 
	QString getPipelineString() const { return m_pipelineString; }

    Q_PROPERTY(QString pipelineString2 READ getPipelineString2 WRITE setPipelineString2 NOTIFY pipelineStringChanged2)
    void setPipelineString2(QString pipelineString);
    QString getPipelineString2() const { return m_pipelineString2; }
    Q_PROPERTY(QString ipOrHost READ getIpOrHost WRITE setIpOrHost NOTIFY ipOrHostChanged)
    void setIpOrHost(QString ipOrHost);
    QString getIpOrHost() const { return m_ipOrHost; }

    Q_PROPERTY(QString cameraIpAddress READ getCameraIpAddress WRITE setCameraIpAddress NOTIFY cameraIpAddressChanged)
    void setCameraIpAddress(QString ipAddress);
    QString getCameraIpAddress() const { return m_cameraIpAddress; }

    GStreamerPlayer * player() { return m_player; }
    GStreamerPlayer * player2() { return m_player2; }
	
    src::Sony_Remote_Camera_Interface* camera();

    void InitializeDisplayWithVideo();
    void ResetDisplay();
	void SetCurrentState(CCurrentState &theState); 
    void setShowToolAction(QAction *action) { m_showToolAction = action; }


    void hideEvent(QHideEvent *event);
	void closeEvent(QCloseEvent *event);
	
private:

	QQuickView* m_declarativeView;
    UAS *m_uasInterface;
    GStreamerPlayer *m_player;
    GStreamerPlayer *m_player2;	
    QWidget *m_viewcontainer;
    QString m_pipelineString;
    QString m_pipelineString2;	
    QString m_ipOrHost;
    QString m_cameraIpAddress;
    QAction *m_showToolAction;
	QGst::Quick::VideoSurface *m_surface;
    QGst::Quick::VideoSurface *m_surface2;
	QCurrentState *m_currentState;
    QMap<QString,int> m_connectionMap;
    src::Sony_Remote_Camera_Interface* m_sonyCamera;

    bool m_enableGStreamer;
    bool m_fullScreenMode;
    bool m_videoEnabled;
    bool m_uasConnected;
    bool m_topMostMode;
    bool m_setHome;
    bool m_swapColorMatrix1;
    bool m_swapColorMatrix2;	
    bool m_splitImage;
    bool m_recording;
    bool m_zoomingIn;
    bool m_zoomingOut;
    bool m_swapImages;
    bool m_close;
};

#endif // PRIMARYFLIGHTDISPLAYQML_H
