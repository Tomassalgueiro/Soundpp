#pragma once

#include <QObject>
#include <QString>
#include <QtQml/qqmlregistration.h>
#include <qtmetamacros.h>

enum class PlaybackState {
    Stopped,
    Playing,
    Paused
};

struct FileSystemItem {
	Q_GADGET
	QML_VALUE_TYPE(fileSystemItem)
	Q_PROPERTY(QString name MEMBER name)
	Q_PROPERTY(QString path MEMBER path)
	Q_PROPERTY(bool isDirectory MEMBER isDirectory)

	public:
		QString name;
		QString path;
		bool isDirectory = false;
};

// stores the song metadata
struct SongMetadata {
	Q_GADGET
	Q_PROPERTY(QString artist MEMBER artist);
	Q_PROPERTY(QString title MEMBER title);
	Q_PROPERTY(QString album MEMBER album);
	Q_PROPERTY(int duration MEMBER duration);
	Q_PROPERTY(QString uri MEMBER uri);
	
	public:
		QString artist;
		QString title;
		QString album;
		int duration = 0; // duration in secs
		QString uri;
};
