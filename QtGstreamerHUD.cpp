// QtGstreamerHUD.cpp : Defines the exported functions for the DLL application.
//

#include <QApplication>
#include <QMainWindow>
#include "QtGStreamerHUD.h"
#include "PrimaryFlightDisplayQML.h"
#include "HUDApplication.h"
#include "UASManager1.h"
#include "LinkManager1.h"
#include <QGst/Init>
#include <QMessageBox>
#include <gst/gst.h>
#include "gstqtvideosinkplugin.h"

HUDApplication *theApp = NULL;
QMainWindow *theMainWindow = NULL;
PrimaryFlightDisplayQML *thePfd = NULL;

void MainWindow::closeEvent(QCloseEvent *pEvent)
{
    if (thePfd != NULL) thePfd->closeEvent(pEvent);
}

int InitHUDApp(int argc, char *argv[], bool disableClose)
{
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    theApp = new HUDApplication(argc, argv);
    QFont font = theApp->font();
    font.setPixelSize(12);
    theApp->setFont(font);

    QString gstreamerLibPath = QCoreApplication::applicationDirPath() + "/lib/gstreamer-1.0";
    qputenv("GST_PLUGIN_PATH",gstreamerLibPath.toLocal8Bit());

    QString path = qgetenv("PATH");
    QString gstreamerBinPath = QCoreApplication::applicationDirPath() + "/bin";
    QString newPath = gstreamerBinPath + ";" + path;
    qputenv("PATH",newPath.toLocal8Bit());

    InitQGst();

    // Register plugin static to avoid having to put pluing in gstreamer directory tree
    gboolean success = gst_plugin_register_static (GST_VERSION_MAJOR,
                                GST_VERSION_MINOR ,
                                "qt5videosink",
                                "A video sink that can draw on any Qt surface",
                                &plugin_init,
                                "1.2.0",
                                "LGPL",
                                "libgstqt5videosink.so",
                                "QtGStreamer",
                                "http://gstreamer.freedesktop.org");

    if (!success)
    {
        qCritical() << "Could not register qt5videosink plugin with GStreamer!";
    }

	theMainWindow = new MainWindow(NULL, disableClose ? Qt::CustomizeWindowHint | Qt::WindowTitleHint | Qt::WindowMinMaxButtonsHint : 0);

	thePfd = new PrimaryFlightDisplayQML();

	QObject::connect(theApp, SIGNAL(close()), thePfd, SLOT(close()));

	theMainWindow->setCentralWidget(thePfd);
	theMainWindow->setMinimumSize(640,480);
	theMainWindow->show();

    qDebug() << "Start Link Manager";
    LinkManager::instance();

    qDebug() << "Start UAS Manager";
    UASManager::instance();

    int exitCode =  theApp->exec();
	
	QGst::cleanup();

    delete theApp;
	theApp = NULL;

	return exitCode;
}

void InitQGst()
{
	QGst::init(NULL, NULL);
}

void ExitHUDApp()
{
	if (theApp)
	{
		theApp->sendCloseSignal();
		Sleep(100);
		theApp->quit();
	}
}

void SetCurrentState(CCurrentState &theState)
{
	if (thePfd)
	{
		thePfd->SetCurrentState(theState);
	}
}

