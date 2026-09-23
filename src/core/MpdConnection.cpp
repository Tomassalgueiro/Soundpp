#include "MpdConnection.h"
#include <mpd/response.h>
#include <mpd/status.h>
#include <mpd/entity.h>
#include <mpd/song.h>
#include <QDebug>
#include <qstringview.h>

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

PlaybackState MpdConnection::fetchPlaybackState(){
	if (!m_conn) return PlaybackState::Stopped;

	struct mpd_status* status = mpd_run_status(m_conn);
	if (!status){
		checkError("fetching status");
		return PlaybackState::Stopped;
	}

	enum mpd_state state = mpd_status_get_state(status);
	switch(state){
		case MPD_STATE_PLAY: return PlaybackState::Playing;
		case MPD_STATE_PAUSE: return PlaybackState::Paused;
		default:	     return PlaybackState::Stopped; 
	}
}

SongMetadata MpdConnection::fetchCurrentSong(){
	SongMetadata meta;

	if(!m_conn) return meta;

	struct mpd_song* song = mpd_run_current_song(m_conn);

	if (song == nullptr){
		return meta;
	}

	const char* title = mpd_song_get_tag(song, MPD_TAG_TITLE, 0);
	const char* artist = mpd_song_get_tag(song, MPD_TAG_ARTIST, 0);
	const char* album = mpd_song_get_tag(song, MPD_TAG_ALBUM, 0);

	meta.title = title ? QString::fromUtf8(title) : QStringLiteral("Uknown Title");
	meta.artist = artist ? QString::fromUtf8(artist) : QStringLiteral("Uknown Artist");
	meta.album = album ? QString::fromUtf8(album) : QStringLiteral("Uknown Album");
	meta.duration = mpd_song_get_duration(song);
	meta.uri = QString::fromUtf8(mpd_song_get_uri(song));

	mpd_song_free(song);
	return meta;
}

unsigned MpdConnection::fetchElapsedTime(){
	if(!m_conn) return 0;
	 
	struct mpd_status* status = mpd_run_status(m_conn);
	if(!status){
		checkError("fetching status for elapsed time");
		return 0;
	}

	unsigned elapsed = mpd_status_get_elapsed_time(status);
	mpd_status_free(status);

	return elapsed;
}

bool MpdConnection::seek(unsigned seconds){
	if(!m_conn) return false;

	if(!mpd_run_seek_current(m_conn, seconds, false)){
		return checkError("seeking");
	}
	return true;
}

QList<FileSystemItem> MpdConnection::listDirectory(const QString &path){
	QList<FileSystemItem> items;
	if (!m_conn) return items;	

	if(!mpd_send_list_meta(m_conn, path.toUtf8().constData())){
		checkError("listing directory");
		return items;
	}
	
	struct mpd_entity* entity;

	while((entity = mpd_recv_entity(m_conn)) != nullptr){
		enum mpd_entity_type type = mpd_entity_get_type(entity);

		if (type == MPD_ENTITY_TYPE_DIRECTORY) {
		    const struct mpd_directory* dir = mpd_entity_get_directory(entity);
		    QString dirPath = QString::fromUtf8(mpd_directory_get_path(dir));
		    
		    // Extract the simple folder name from the full path
		    QString folderName = dirPath.section('/', -1);

		    FileSystemItem item;
		    item.name = folderName;
		    item.path = dirPath;
		    item.isDirectory = true;
		    items.append(item);
		} else if (type == MPD_ENTITY_TYPE_SONG) {
		    const struct mpd_song* song = mpd_entity_get_song(entity);
		    QString uri = QString::fromUtf8(mpd_song_get_uri(song));
		    
		    const char* titleTag = mpd_song_get_tag(song, MPD_TAG_TITLE, 0);
		    QString displayName = titleTag ? QString::fromUtf8(titleTag) : uri.section('/', -1);

		    FileSystemItem item;
		    item.name = displayName;
		    item.path = uri;
		    item.isDirectory = false;
		    items.append(item);
		}

		mpd_entity_free(entity);
	}

	mpd_response_finish(m_conn);
	checkError("finishing directory list");
	
	return items;
}

bool MpdConnection::playFile(const QString& uri) {
    if (!m_conn) return false;

    if (!mpd_run_clear(m_conn)) {
        return checkError("clearing queue");
    }

    if (!mpd_run_add(m_conn, uri.toUtf8().constData())) {
        return checkError("adding track to queue");
    }

    if (!mpd_run_play_pos(m_conn, 0)) {
        return checkError("playing track");
    }

    return true;
}

QByteArray MpdConnection::fetchAlbumArt(const QString& uri) {
    QByteArray imageBytes;
    if (!m_conn || uri.isEmpty()) return imageBytes;

    char chunk[8192];
    unsigned offset = 0;

    while (true) {
        int bytesRead = mpd_run_readpicture(
            m_conn,
            uri.toUtf8().constData(),
            offset,
            chunk,
            sizeof(chunk)
        );

        if (bytesRead < 0) {
            checkError("reading picture");
            break;
        }

        if (bytesRead == 0) {
            break;
        }

        imageBytes.append(chunk, bytesRead);
        offset += static_cast<unsigned>(bytesRead);
    }

    return imageBytes;
}
