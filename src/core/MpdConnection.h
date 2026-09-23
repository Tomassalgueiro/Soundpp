#pragma once

#include <QString>
#include <QList>
#include <mpd/client.h>
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

		PlaybackState fetchPlaybackState();
		SongMetadata fetchCurrentSong();

		unsigned fetchElapsedTime();
		bool seek(unsigned seconds);

		QList<FileSystemItem> listDirectory(const QString& path = "");
		bool playFile(const QString& uri);

	private:
		struct mpd_connection* m_conn = nullptr;
		bool checkError(const char* operation);

};
