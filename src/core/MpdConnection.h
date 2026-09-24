#pragma once

#include <QString>
#include <QList>
#include <mpd/client.h>
#include <qstringview.h>
#include "MpdTypes.h"

class MpdConnection{
	public:
		MpdConnection();
		~MpdConnection();

		MpdConnection(const MpdConnection&) = delete;
		MpdConnection& operator=(const MpdConnection&) = delete;

		bool connectToHost(const QString& host, unsigned port);
		bool testConnection();
		bool isConnected() const;

		bool play();
		bool pause(bool enable);
		bool togglePause();
		bool next();
		bool previous();
		bool setRepeat(bool enable);
		bool appendQueue(const QList<QString>& songUris);

		PlaybackState fetchPlaybackState();
		SongMetadata fetchCurrentSong();

		unsigned fetchElapsedTime();
		bool seek(unsigned seconds);

		QList<FileSystemItem> listDirectory(const QString& path = "");
		bool playFile(const QString& uri);

		QByteArray fetchAlbumArt(const QString& uri);

		QList<QString> listSongsInDirectory(const QString& path);
		bool playQueue(const QList<QString>& songUris, int startIndex = 0);
		QList<SongMetadata> fetchUpNextSongs(int limit = 5);

		QPair<int, int> fetchQueueStatus();


	private:
		struct mpd_connection* m_conn = nullptr;
		bool checkError(const char* operation);

};
