#pragma once

#include <QObject>
#include <QtQml/qqmlregistration.h>

#include "MpdConnection.h"
#include "MpdTypes.h"

class MpdController : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(bool isConnected
	       READ isConnected
               NOTIFY connectionChanged)

    Q_PROPERTY(MpdTypes::PlaybackState playbackState
               READ playbackState
               NOTIFY playbackStateChanged)

    Q_PROPERTY(SongMetadata currentSong
               READ currentSong
               NOTIFY currentSongChanged)

public:
    explicit MpdController(QObject *parent = nullptr);

    bool isConnected() const;
    MpdTypes::PlaybackState playbackState() const;
    SongMetadata currentSong() const;

    Q_INVOKABLE void togglePlayPause();
    Q_INVOKABLE void next();
    Q_INVOKABLE void previous();

signals:
    void connectionChanged();
    void playbackStateChanged();
    void currentSongChanged();

private:
    MpdConnection m_connection;
    MpdTypes::PlaybackState m_playbackState = MpdTypes::PlaybackState::Stopped;
    SongMetadata m_currentSong;
};
