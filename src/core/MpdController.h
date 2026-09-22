#pragma once

#include <QObject>
#include <QTimer>
#include <QtQml/qqmlregistration.h>

#include "MpdConnection.h"
#include "MpdTypes.h"

class MpdController : public QObject
{
    Q_OBJECT
    QML_ELEMENT

public:
    enum PlaybackState{
	Stopped = static_cast<int>(::PlaybackState::Stopped),
        Playing = static_cast<int>(::PlaybackState::Playing),
        Paused  = static_cast<int>(::PlaybackState::Paused)
    };
    Q_ENUM(PlaybackState)

    Q_PROPERTY(bool isConnected
	       READ isConnected
               NOTIFY connectionChanged)

    Q_PROPERTY(PlaybackState playbackState
               READ playbackState
               NOTIFY playbackStateChanged)

    Q_PROPERTY(SongMetadata currentSong
               READ currentSong
               NOTIFY currentSongChanged)
    
    Q_PROPERTY(int elapsedTime 
	       READ elapsedTime 
	       NOTIFY elapsedTimeChanged)

public:
    explicit MpdController(QObject *parent = nullptr);

    bool isConnected() const;
    PlaybackState playbackState() const;
    SongMetadata currentSong() const;
    int elapsedTime() const;

    Q_INVOKABLE void togglePlayPause();
    Q_INVOKABLE void next();
    Q_INVOKABLE void previous();
    Q_INVOKABLE void seek(int seconds);

signals:
    void connectionChanged();
    void playbackStateChanged(); 
    void currentSongChanged();
    void elapsedTimeChanged();

private slots:
	void updateStatus();

private:
    MpdConnection m_connection;
    PlaybackState m_playbackState = PlaybackState::Stopped;
    SongMetadata m_currentSong;
    int m_elapsedTime = 0;
    QTimer m_pollTimer;
};
