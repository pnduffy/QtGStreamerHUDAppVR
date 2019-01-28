/*===================================================================
APM_PLANNER Open Source Ground Control Station

(c) 2014 Patrick Duffy

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

#ifndef HUDAPPLICATION_H
#define HUDAPPLICATION_H

#include <QApplication>
#include <QMainWindow>
#include <opencv2/dnn.hpp>
#include <delegates/basedelegate.h>


class HUDApplication: public QApplication
{
	Q_OBJECT

public:
    HUDApplication(int &argc, char **argv);
	void sendCloseSignal() { emit close(); }
    virtual bool event(QEvent *event);

signals:
	bool close();

private:
    std::vector<cv::Rect> postprocess(cv::Mat& frame, const std::vector<cv::Mat>& outs, cv::dnn::Net& net, float confThreshold, QList<int>& classIdList);
    void drawPred(float conf, int classId, int left, int top, int right, int bottom, cv::Mat& frame);

    cv::dnn::Net objectDetectorNet;
    QMap<GstVideoSink*, BufferFormat> sinkFormatMap;

    QList<int> outdoorList;
    QList<int> indoorList;

    bool isOutdoors;

    static QStringList classNames;

};

class MainWindow : public QMainWindow {

    Q_OBJECT;

public:
	MainWindow(QWidget *parent = 0, Qt::WindowFlags flags = 0) : QMainWindow(parent, flags) {}

protected:
     void closeEvent(QCloseEvent *pEvent);
};

extern QMainWindow *theMainWindow;

#endif
