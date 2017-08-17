#include "QtGStreamerHUD.h"
#include "gstqtvideosinkplugin.h"
#include <QLoggingCategory>
#include <QGst/Init>
#include <QGst/Quick/VideoSurface>
#include <QGst/Quick/VideoItem>
#include <gst/gst.h>
#include <QThread>
#include <gstqtquick2videosink.h>

// Since Qt QML scene rendering is on a rendering thread and not the UI thread, use a 'direct' call instead of the glib 'signal/slot'
// The UI thread blocks during the 'update-node' call, so it's safe to make this direct call on the rendering thread
gpointer gst_qt_quick2_video_sink_update_node(GstQtQuick2VideoSink *self, gpointer node, qreal x, qreal y, qreal w, qreal h);

void* update_node(void* surface,  void* node, qreal x, qreal y, qreal w, qreal h)
{
    return gst_qt_quick2_video_sink_update_node((GstQtQuick2VideoSink*)surface, (gpointer)node, x, y, w, h);
}

int main(int argc, char *argv[])
{
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

    int retCode = InitHUDApp(argc,argv, false);
    ExitHUDApp();
    return retCode;
}
