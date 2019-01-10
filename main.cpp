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
    int retCode = InitHUDApp(argc,argv, false);
    ExitHUDApp();
    return retCode;
}
