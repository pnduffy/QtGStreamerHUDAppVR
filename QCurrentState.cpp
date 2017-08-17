#include "QCurrentState.h"

QCurrentState::QCurrentState(QObject *parent) : QObject(parent)
{
    m_roll= 0;
    m_pitch = 0;
    m_yaw = 0;
    m_groundspeed = 0;
    m_airspeed = 0;
    m_batteryVoltage = 0;
    m_batteryCurrent = 0;
    m_batteryRemaining = 0;
    m_altitude = 0;

    m_watts = 0;
    m_gpsstatus = 0;
    m_gpshdop = 0;
    m_satcount = 0;
    m_wp_dist = 0;
    m_ch3percent = 0;
    m_timeInAir = 0;
    m_DistToHome = 0;
    m_distTraveled = 0;
    m_AZToMAV = 0;

    m_lat = 0;
    m_lng = 0;
    m_uas = NULL;
    m_distUnit = "m";
    m_speedUnit = "m/s";
    m_CurPos = QPointF(0,0);
    m_LastPos = QPointF(0,0);

    m_armed = false;
    m_timeInAirTimer = new QTimer(this);
    connect(m_timeInAirTimer, SIGNAL(timeout()), this, SLOT(updateTimeInAir()));

}

QCurrentState::~QCurrentState()
{
    delete m_timeInAirTimer;
}

void QCurrentState::setUAS(UAS *uas)
{
    if (m_uas != NULL)
    {
        disconnect(m_uas,SIGNAL(valueChanged(const int, const QString&, const QString&, const QVariant &,const quint64)),
                this,SLOT(onValueChanged(const int, const QString&, const QString&, const QVariant &,const quint64)));
        disconnect(m_uas,SIGNAL(armed()),this,SLOT(onArmed()));
        disconnect(m_uas,SIGNAL(disarmed()),this,SLOT(onDisArmed()));
        disconnect(m_uas,SIGNAL(remoteControlChannelScaledChanged(int, float)),this,SLOT(onRemoteControlChannelScaledChanged(int, float)));
        disconnect(m_uas,SIGNAL(globalPositionChanged(UASInterface*, double, double, double, quint64 )),this,SLOT(onGlobalPositionChanged(UASInterface*, double, double, double, quint64 )));
    }

    m_uas = uas;
    if (m_uas != NULL)
    {
        connect(m_uas,SIGNAL(valueChanged(const int, const QString&, const QString&, const QVariant &,const quint64)),
                this,SLOT(onValueChanged(const int, const QString&, const QString&, const QVariant &,const quint64)));
        connect(m_uas,SIGNAL(armed()),this,SLOT(onArmed()));
        connect(m_uas,SIGNAL(disarmed()),this,SLOT(onDisarmed()));
        connect(m_uas,SIGNAL(remoteControlChannelScaledChanged(int, float)),this,SLOT(onRemoteControlChannelScaledChanged(int, float)));
        connect(m_uas,SIGNAL(globalPositionChanged(UASInterface*, double, double, double, quint64 )),this,SLOT(onGlobalPositionChanged(UASInterface*, double, double, double, quint64 )));
    }
}

void QCurrentState::onValueChanged(const int uasid, const QString &name, const QString &unit, const QVariant &value, const quint64 msecs)
{
    Q_UNUSED(uasid);
    Q_UNUSED(unit);
    Q_UNUSED(value);
    Q_UNUSED(msecs);

    if (m_uas != NULL)
    {
        if (name == "GPS HDOP") setGpshdop(value.toFloat());
        else if (name=="distToWaypoint") setWp_dist(value.toFloat());
    }
}

void QCurrentState::onArmed()
{
    setArmed(true);
    // Estimate time in air by arm state
    setTimeInAir(0);
    setDistToHome(0);
    setDistTraveled(0);
    m_timeInAirTimer->start(1000);
}

void QCurrentState::onDisarmed()
{
    setArmed(false);
    m_timeInAirTimer->stop();
}

void QCurrentState::onRemoteControlChannelScaledChanged(int channelId, float normalized)
{
    if (channelId == 1)
    {
        setCh3percent(normalized);
    }
}

void QCurrentState::updateTimeInAir()
{
    if (m_armed)
    {
        setTimeInAir(getTimeInAir()+1);
        if (!m_CurPos.isNull() && !m_LastPos.isNull()) setDistTraveled(m_distTraveled + GetDistanceBetweenPoints(m_CurPos,m_LastPos));
    }
}

void QCurrentState::onGlobalPositionChanged(UASInterface*, double lat, double lon, double alt, quint64 usec)
{
    Q_UNUSED(usec);
    Q_UNUSED(alt);

    m_CurPos.setX(lat);
    m_CurPos.setY(lon);
}

double QCurrentState::GetDistanceBetweenPoints(QPointF curPos, QPointF lastPos)
{
    double Lat = curPos.x()/1E7;
    double Lng = curPos.y()/1E7;
    double Lat2 = lastPos.x()/1E7;
    double Lng2 = lastPos.y()/1E7;

    double d = Lat * 0.017453292519943295;
    double num2 = Lng * 0.017453292519943295;
    double num3 = Lat2 * 0.017453292519943295;
    double num4 = Lng2 * 0.017453292519943295;
    double num5 = num4 - num2;
    double num6 = num3 - d;
    double num7 = pow(sin(num6 / 2.0), 2.0) + ((cos(d) * cos(num3)) * pow(sin(num5 / 2.0), 2.0));
    double num8 = 2.0 * atan2(sqrt(num7), sqrt(1.0 - num7));
    return (6371 * num8) * 1000.0; // M
}
