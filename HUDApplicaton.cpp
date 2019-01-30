#include "HUDApplication.h"
#include "opencv2/opencv.hpp"
#include <opencv2/objdetect/objdetect.hpp>
#include <QMap>
#include <QFileInfo>

using namespace cv;

QStringList HUDApplication::classNames = QStringList() << "background" << "aeroplane" << "bicycle" << "bird" << "boat" <<
    "bottle" << "bus" << "car" << "cat"<< "chair" << "cow" << "diningtable" <<
    "dog" << "horse" << "motorbike" << "person" << "pottedplant" << "sheep" <<
    "sofa" << "train" << "tvmonitor";

HUDApplication::HUDApplication(int &argc, char **argv) : QApplication(argc,argv)
{
    QString path = QCoreApplication::applicationFilePath();
    QFileInfo info(path);
    QString proto = info.absolutePath();
    proto += "/MobileNetSSD_deploy.prototxt.txt";
    QString caffe = info.absolutePath();
    caffe += "/MobileNetSSD_deploy.caffemodel";
    objectDetectorNet = dnn::readNetFromCaffe(proto.toStdString(),caffe.toStdString());
    objectDetectorNet.setPreferableTarget(dnn::DNN_TARGET_OPENCL);

    outdoorList << 1 << 2 << 3 << 4 << 6 << 7 << 8 << 10 << 12 << 13 << 14 << 15 << 17 << 19;
    indoorList << 5 << 9 << 11 << 16 << 18 << 20;

    isOutdoors = true;
}

bool HUDApplication::event(QEvent *event)
{
    switch((int) event->type())
    {
        case BaseDelegate::BufferEventType:
        {
            BaseDelegate::BufferEvent2 *bufEvent = dynamic_cast<BaseDelegate::BufferEvent2*>(event);
            Q_ASSERT(bufEvent);

            // TODO: test
            //bufEvent->eventWait.wakeAll();
            //return true;

            if (sinkFormatMap.contains(bufEvent->sink))
            {
                GstMapInfo info;
                gst_buffer_map(bufEvent->buffer, &info, GST_MAP_READ);
                BufferFormat fmt = sinkFormatMap[bufEvent->sink];
                QString fmtName(fmt.videoInfo().finfo->name);
                Mat frame;
                if (fmtName=="I420")
                {
                    Mat picI420 = cv::Mat(fmt.frameSize().height() * 3 / 2, fmt.frameSize().width(), CV_8UC1, (char*)info.data);
                    cv::cvtColor(picI420, frame, cv::COLOR_YUV2BGR_I420);
                }
                else if (fmtName=="BGR")
                {
                    frame = Mat(Size(fmt.frameSize().width(), fmt.frameSize().height()), CV_8UC3, (char*)info.data);
                }
                else if (fmtName=="v308")
                {
                    Mat pic308 = Mat(Size(fmt.frameSize().width(), fmt.frameSize().height()), CV_8UC3, (char*)info.data);
                    cv::cvtColor(pic308, frame, cv::COLOR_YUV2BGR);
                }

                Mat resized;
                Mat blob;
                cv::resize(frame,resized,Size(300,300));
                blob = cv::dnn::blobFromImage(resized, 0.007843, Size(300,300), cv::Scalar(127.5));
                objectDetectorNet.setInput(blob);
                std::vector<cv::Mat> outputBlobs;
                std::vector<String> outputNames;
                outputNames.push_back("detection_out");
                objectDetectorNet.forward(outputBlobs,outputNames);

                std::vector<Rect> results = postprocess(frame,outputBlobs,objectDetectorNet,0.3f, isOutdoors ? outdoorList:indoorList);

                if (fmtName=="I420")
                {
                    Mat picI420;
                    cv::cvtColor(frame, picI420, COLOR_BGR2YUV_I420);
                    memcpy(info.data,picI420.data,picI420.total());
                }
                else if (fmtName=="v308")
                {
                    Mat pic308;
                    cv::cvtColor(frame, pic308, COLOR_BGR2YUV);
                    memcpy(info.data,pic308.data,pic308.total()*3);
                }

                gst_buffer_unmap(bufEvent->buffer, &info);

            }

            bufEvent->eventWait.wakeAll();

            return true;
        }
        break;

        case BaseDelegate::BufferFormatEventType:
        {
            BaseDelegate::BufferFormatEvent2 *bufFmtEvent = dynamic_cast<BaseDelegate::BufferFormatEvent2*>(event);
            Q_ASSERT(bufFmtEvent);

            sinkFormatMap[bufFmtEvent->sink]=bufFmtEvent->format;

            bufFmtEvent->eventWait.wakeAll();

            return true;
        }
        break;
    }

    return QApplication::event(event);
}

std::vector<Rect> HUDApplication::postprocess(Mat& frame, const std::vector<Mat>& outs, cv::dnn::Net& net, float confThreshold, QList<int>& classIdList)
{
    static std::vector<int> outLayers = net.getUnconnectedOutLayers();
    static std::string outLayerType = net.getLayer(outLayers[0])->type;

    std::vector<int> classIds;
    std::vector<float> confidences;
    std::vector<Rect> boxes;
    std::vector<Rect> results;

    if (net.getLayer(0)->outputNameToIndex("im_info") != -1)  // Faster-RCNN or R-FCN
    {
        // Network produces output blob with a shape 1x1xNx7 where N is a number of
        // detections and an every detection is a vector of values
        // [batchId, classId, confidence, left, top, right, bottom]
        CV_Assert(outs.size() == 1);
        float* data = (float*)outs[0].data;
        for (size_t i = 0; i < outs[0].total(); i += 7)
        {
            int classId = (int)data[i + 1];
            if (classIdList.contains(classId))
            {
                float confidence = data[i + 2];
                if (confidence > confThreshold)
                {
                    int left = (int)data[i + 3];
                    int top = (int)data[i + 4];
                    int right = (int)data[i + 5];
                    int bottom = (int)data[i + 6];
                    int width = right - left + 1;
                    int height = bottom - top + 1;
                    classIds.push_back(classId);
                    boxes.push_back(Rect(left, top, width, height));
                    confidences.push_back(confidence);
                }
            }
        }
    }
    else if (outLayerType == "DetectionOutput")
    {
        // Network produces output blob with a shape 1x1xNx7 where N is a number of
        // detections and an every detection is a vector of values
        // [batchId, classId, confidence, left, top, right, bottom]
        CV_Assert(outs.size() == 1);
        float* data = (float*)outs[0].data;
        for (size_t i = 0; i < outs[0].total(); i += 7)
        {
            int classId = (int)data[i + 1];
            if (classIdList.contains(classId))
            {
                float confidence = data[i + 2];
                if (confidence > confThreshold)
                {
                    int left = (int)(data[i + 3] * frame.cols);
                    int top = (int)(data[i + 4] * frame.rows);
                    int right = (int)(data[i + 5] * frame.cols);
                    int bottom = (int)(data[i + 6] * frame.rows);
                    int width = right - left + 1;
                    int height = bottom - top + 1;
                    classIds.push_back(classId);
                    boxes.push_back(Rect(left, top, width, height));
                    confidences.push_back(confidence);
                }
            }
        }
    }
    else if (outLayerType == "Region")
    {
        for (size_t i = 0; i < outs.size(); ++i)
        {
            // Network produces output blob with a shape NxC where N is a number of
            // detected objects and C is a number of classes + 4 where the first 4
            // numbers are [center_x, center_y, width, height]
            float* data = (float*)outs[i].data;
            for (int j = 0; j < outs[i].rows; ++j, data += outs[i].cols)
            {
                Mat scores = outs[i].row(j).colRange(5, outs[i].cols);
                Point classIdPoint;
                double confidence;
                minMaxLoc(scores, 0, &confidence, 0, &classIdPoint);
                if (classIdList.contains(classIdPoint.x))
                {
                    if (confidence > confThreshold)
                    {
                        int centerX = (int)(data[0] * frame.cols);
                        int centerY = (int)(data[1] * frame.rows);
                        int width = (int)(data[2] * frame.cols);
                        int height = (int)(data[3] * frame.rows);
                        int left = centerX - width / 2;
                        int top = centerY - height / 2;

                        classIds.push_back(classIdPoint.x);
                        confidences.push_back((float)confidence);
                        boxes.push_back(Rect(left, top, width, height));
                    }
                }
            }
        }
    }
    else
        CV_Error(Error::StsNotImplemented, "Unknown output layer type: " + outLayerType);

    std::vector<int> indices;
    dnn::NMSBoxes(boxes, confidences, confThreshold, 0.4f, indices);
    for (size_t i = 0; i < indices.size(); ++i)
    {
        unsigned idx = (unsigned)indices[i];
        Rect box = boxes[idx];
        QRect frameRect(0,0,frame.cols,frame.rows);
        QRect constBox = frameRect.intersected(QRect(box.x,box.y,box.width,box.height));
        results.push_back(Rect(constBox.x(),constBox.y(),constBox.width(),constBox.height()));
        drawPred(confidences[idx], classIds[idx], constBox.x(), constBox.y(),
                 constBox.x() + constBox.width(), constBox.y() + constBox.height(), frame);
    }

    return results;
}

void HUDApplication::drawPred(float conf, int classId, int left, int top, int right, int bottom, Mat& frame)
{
    rectangle(frame, Point(left, top), Point(right, bottom), Scalar(0, 255, 0),3);

    QString className = classNames[classId];
    std::string label = format("%s, %.2f",className.toStdString().c_str(), conf);

    int baseLine;
    Size labelSize = getTextSize(label, FONT_HERSHEY_SIMPLEX, 0.5, 1, &baseLine);

    top = max(top, labelSize.height);
    rectangle(frame, Point(left, top - labelSize.height),
              Point(left + labelSize.width, top + baseLine), Scalar::all(255), FILLED);
    putText(frame, label, Point(left, top), FONT_HERSHEY_SIMPLEX, 0.5, Scalar(),2);
}
