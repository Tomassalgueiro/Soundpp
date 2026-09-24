#pragma once

#include <algorithm>
#include <random>

#include <QObject>
#include <QTimer>
#include <QtQml/qqmlregistration.h>
#include <qtmetamacros.h>

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

    enum QueueMode {
	    ModeDefault,
	    ModeShuffleFolder,
	    ModeShuffleSelectedFolders
    };
    Q_ENUM(QueueMode)

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

    Q_PROPERTY(QList<FileSystemItem> currentFiles
	       READ currentFiles 
	       NOTIFY currentFilesChanged)

    Q_PROPERTY(QString currentPath 
	       READ currentPath 
	       NOTIFY currentPathChanged)

    Q_PROPERTY(QString coverArtUrl
	       READ coverArtUrl
	       NOTIFY coverArtUrlChanged)

    Q_PROPERTY(QueueMode queueMode 
	       READ queueMode 
	       WRITE setQueueMode 
	       NOTIFY queueModeChanged)

    Q_PROPERTY(QStringList selectedFolders 
	       READ selectedFolders 
	       NOTIFY selectedFoldersChanged)

public:
    explicit MpdController(QObject *parent = nullptr);

    bool isConnected() const;
    PlaybackState playbackState() const;
    SongMetadata currentSong() const;
    int elapsedTime() const;
    QList<FileSystemItem> currentFiles() const;
    QString currentPath() const;
    QString coverArtUrl() const;
    QueueMode queueMode() const;
    void setQueueMode(QueueMode mode);
    QStringList selectedFolders() const;


    Q_INVOKABLE void togglePlayPause();
    Q_INVOKABLE void next();
    Q_INVOKABLE void previous();
    Q_INVOKABLE void seek(int seconds);
    Q_INVOKABLE void openFolder(const QString& path);
    Q_INVOKABLE void goUp();
    Q_INVOKABLE void playItem(const QString& uri);
    Q_INVOKABLE void toggleSelectFolder(const QString& folderPath);
    Q_INVOKABLE void clearSelectedFolders();
    Q_INVOKABLE bool isFolderSelected(const QString& folderPath) const;
    Q_INVOKABLE void playFolderQueue(const QString& folderPath, const QString& startUri = "");
    Q_INVOKABLE void playCustomQueue();

signals:
    void connectionChanged();
    void playbackStateChanged(); 
    void currentSongChanged();
    void elapsedTimeChanged();
    void currentFilesChanged();
    void currentPathChanged();
    void coverArtUrlChanged();
    void queueModeChanged();
    void selectedFoldersChanged();

private slots:
	void updateStatus();
	void updateCoverArt(const QString& uri);

private:
    MpdConnection m_connection;
    PlaybackState m_playbackState = PlaybackState::Stopped;
    SongMetadata m_currentSong;
    int m_elapsedTime = 0;
    QTimer m_pollTimer;
    QList<FileSystemItem> m_currentFiles;
    QString m_currentPath = "";
    QString m_coverArtUrl;
    QueueMode m_queueMode = ModeDefault;
    QStringList m_selectedFolders;
};
