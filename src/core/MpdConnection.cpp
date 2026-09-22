#include "MpdConnection.h"

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
