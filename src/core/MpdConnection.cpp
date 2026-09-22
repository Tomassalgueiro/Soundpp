#include "MpdConnection.h"
#include <mpd/status.h>
#include <mpd/song.h>
#include <QDebug>

MpdConnection::MpdConnection() = default;

MpdConnection::~MpdConnection(){
    if (m_conn != nullptr) {
        mpd_connection_free(m_conn);
        m_conn = nullptr;
    }
}

bool MpdConnection::connectToHost(const QString& host, unsigned port){
    // If we're already connected, clean up the old connection first.
    if (m_conn != nullptr) {
        mpd_connection_free(m_conn);
        m_conn = nullptr;
    }

    m_conn = mpd_connection_new(host.toUtf8().constData(), port, 30000); // 30000 ms timeout

    if (m_conn == nullptr) {
        qWarning() << "Failed to create MPD connection";
        return false;
    }

    if (!checkError("connecting to MPD")) {
        mpd_connection_free(m_conn);
        m_conn = nullptr;
        return false;
    }

    qDebug() << "Connected to MPD at" << host << "port" << port;
    return true;
}

bool MpdConnection::testConnection(){
    if (m_conn == nullptr) {
        qWarning() << "Cannot ping MPD: not connected";
        return false;
    }

    const unsigned* version = mpd_connection_get_server_version(m_conn);
    if (!checkError("getting server version")){
	    return false;
    }

    if (version == nullptr) {
        qWarning() << "MPD server version is unavaiilable";
        return false;
    }

    qDebug() << "MPD protocol version" <<  version[0] << "." << version[1] << "." << version[2];
    return true;
}

bool MpdConnection::isConnected() const{
    return m_conn != nullptr;
}

bool MpdConnection::checkError(const char* operation){

    enum mpd_error error = mpd_connection_get_error(m_conn);

    if (error != MPD_ERROR_SUCCESS) {
        const char* message = mpd_connection_get_error_message(m_conn);

        qWarning() << "MPD error during" << operation << ":" << (message ? message : "Unknown error");

        return false;
    }

    return true;
}

bool MpdConnection::play(){
	if(!m_conn) return false;
	if (!mpd_run_play(m_conn)){
		return checkError("playing");
	}
	return true;
}

bool MpdConnection::pause(bool enable){
	if(!m_conn) return false;
	if (!mpd_run_pause(m_conn, enable)){
		return checkError("pausing");
	}
	return true;
}

bool MpdConnection::togglePause(){
	if (!m_conn) return false;

	struct mpd_status* status = mpd_run_status(m_conn);
	if (!status){
		return checkError("fetching status for toggle");
	}

	enum mpd_state state = mpd_status_get_state(status);

	if (state == MPD_STATE_PLAY){
		return pause(true);

	} else {
		return pause(false);
	}

}

bool MpdConnection::next(){
	if(!m_conn) return false;
	if (!mpd_run_next(m_conn)){
		return checkError("skipping to next song");
	}
	return true;
}

bool MpdConnection::previous(){
	if(!m_conn) return false;
	if (!mpd_run_previous(m_conn)){
		return checkError("skipping to previous song");
	}
	return true;
}

MpdTypes::PlaybackState MpdConnection::fetchPlaybackState(){
	if (!m_conn) return MpdTypes::PlaybackState::Stopped;

	struct mpd_status* status = mpd_run_status(m_conn);
	if (!status){
		checkError("fetching status");
		return MpdTypes::PlaybackState::Stopped;
	}

	enum mpd_state state = mpd_status_get_state(status);

	switch(state){
		case MPD_STATE_PLAY: return MpdTypes::PlaybackState::Playing;
		case MPD_STATE_PAUSE: return MpdTypes::PlaybackState::Paused;
		default:	     return MpdTypes::PlaybackState::Stopped; 
	}
}

SongMetadata MpdConnection::fetchCurrentSong(){
	SongMetadata meta;

	if(!m_conn) return meta;

	struct mpd_song* song = mpd_run_current_song(m_conn);

	const char* title = mpd_song_get_tag(song, MPD_TAG_TITLE, 0);
	const char* artist = mpd_song_get_tag(song, MPD_TAG_ARTIST, 0);
	const char* album = mpd_song_get_tag(song, MPD_TAG_ALBUM, 0);

	meta.title = title ? QString::fromUtf8(title) : QStringLiteral("Uknown Title");
	meta.artist = artist ? QString::fromUtf8(artist) : QStringLiteral("Uknown Artist");
	meta.album = album ? QString::fromUtf8(album) : QStringLiteral("Uknown Album");

	mpd_song_free(song);
	return meta;
}
