#pragma once

#include <QObject>
#include <QString>
#include <qobject.h>
#include <qtmetamacros.h>

class MpdTypes{
	Q_GADGET
	// stores the state of the mpd player
	public:
		enum class PlaybackState { 
			Stopped,
			Playing,
			Paused 
		};
	Q_ENUM(PlaybackState)

};

// stores the song metadata
struct SongMetadata {
	Q_GADGET
	Q_PROPERTY(QString artist MEMBER artist);
	Q_PROPERTY(QString title MEMBER title);
	Q_PROPERTY(QString album MEMBER album);
	Q_PROPERTY(int duration MEMBER duration);
	
	public:
		QString artist;
		QString title;
		QString album;
		int duration = 0; // duration in secs
};
