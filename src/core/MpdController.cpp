#include "MpdController.h"
#include "core/MpdTypes.h"
#include <QDebug>

MpdController::MpdController(QObject *parent)
    : QObject(parent){
	    if (m_connection.connectToHost("127.0.0.1", 6600)){
		m_connection.testConnection();
		emit connectionChanged();
	    }
}

bool MpdController::isConnected() const
{
    return m_connection.isConnected();
}

MpdTypes::PlaybackState MpdController::playbackState() const
{
    return m_playbackState;
}

SongMetadata MpdController::currentSong() const
{
    return m_currentSong;
}

bool MpdConnection::play(){

}

bool MpdConnection::pause(bool enable){

}

bool MpdConnection::togglePause(){

}

bool MpdConnection::next(){

}

bool MpdConnection::previous(){

}
