#include "MpdController.h"
#include "core/MpdTypes.h"
#include <QDebug>
#include <mpd/player.h>

MpdController::MpdController(QObject *parent)
    : QObject(parent){
	    if (m_connection.connectToHost("127.0.0.1", 6600)){
		emit connectionChanged();
		updateStatus();

		connect(&m_pollTimer, &QTimer::timeout, this, &MpdController::updateStatus);
		m_pollTimer.start(500);
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

void MpdController::togglePlayPause(){
	m_connection.togglePause();
	updateStatus();
}

void MpdController::next(){
	m_connection.next();
	updateStatus();
}

void MpdController::previous(){
	m_connection.previous();
	updateStatus();
}

void MpdController::updateStatus(){
	if(!m_connection.isConnected()) return;

	MpdTypes::PlaybackState newState = m_connection.fetchPlaybackState();
	if (newState != m_playbackState){
		m_playbackState = newState;
		emit playbackStateChanged();
	}

	SongMetadata newSong = m_connection.fetchCurrentSong();
	if(newSong.title != m_currentSong.title || newSong.artist != m_currentSong.artist){
		m_currentSong = newSong;
		emit currentSongChanged();
	}
}
