#include "MpdController.h"
#include "core/MpdTypes.h"
#include <QDebug>
#include <mpd/player.h>
#include <QStandardPaths>
#include <QDir>
#include <QFile>
#include <QDateTime>

MpdController::MpdController(QObject *parent)
    : QObject(parent){
	    if (m_connection.connectToHost("127.0.0.1", 6600)){
		emit connectionChanged();
		updateStatus();
		openFolder("");
		m_connection.setRepeat(true);

		connect(&m_pollTimer, &QTimer::timeout, this, &MpdController::updateStatus);
		m_pollTimer.start(500);
	    }
}

bool MpdController::isConnected() const
{
    return m_connection.isConnected();
}

MpdController::PlaybackState MpdController::playbackState() const
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

	MpdController::PlaybackState newState = static_cast<PlaybackState>(m_connection.fetchPlaybackState());
	if (newState != m_playbackState){
		m_playbackState = newState;
		emit playbackStateChanged();
	}

	SongMetadata newSong = m_connection.fetchCurrentSong();
	if(newSong.title != m_currentSong.title || newSong.artist != m_currentSong.artist || newSong.uri != m_currentSong.uri){
		m_currentSong = newSong;
		emit currentSongChanged();
		updateCoverArt(m_currentSong.uri);
	}

	int newElapsed = static_cast<int>(m_connection.fetchElapsedTime());
	if (newElapsed != m_elapsedTime){
		m_elapsedTime = newElapsed;
		emit elapsedTimeChanged();

	}

	QList<SongMetadata> nextSongs = m_connection.fetchUpNextSongs(5);
	if (m_upNextSongs.size() != nextSongs.size() || (!nextSongs.isEmpty() && !m_upNextSongs.isEmpty() && nextSongs[0].uri != m_upNextSongs[0].uri)) {
		m_upNextSongs = nextSongs;
		emit upNextSongsChanged();
    }
}

int MpdController::elapsedTime() const {
	return m_elapsedTime;
}

void MpdController::seek(int seconds) {

	m_connection.seek(static_cast<unsigned>(seconds));
	m_elapsedTime = seconds;
	emit elapsedTimeChanged();	
}

QList<FileSystemItem> MpdController::currentFiles() const {
    return m_currentFiles;
}

QString MpdController::currentPath() const {
    return m_currentPath;
}

void MpdController::openFolder(const QString& path) {
    m_currentPath = path;
    m_currentFiles = m_connection.listDirectory(path);
    emit currentPathChanged();
    emit currentFilesChanged();
}

void MpdController::goUp() {
    if (m_currentPath.isEmpty()) return;

    int lastSlash = m_currentPath.lastIndexOf('/');
    if (lastSlash == -1) {
        openFolder(""); 
    } else {
        openFolder(m_currentPath.left(lastSlash));
    }
}

void MpdController::playItem(const QString& uri) {
    m_connection.playFile(uri);
    updateStatus();
}

QString MpdController::coverArtUrl() const {
	return m_coverArtUrl;
}

void MpdController::updateCoverArt(const QString &uri){
if (uri.isEmpty()) {
        m_coverArtUrl = "";
        emit coverArtUrlChanged();
        return;
    }

    QByteArray imgData = m_connection.fetchAlbumArt(uri);
    if (imgData.isEmpty()) {
        m_coverArtUrl = "";
        emit coverArtUrlChanged();
        return;
    }

    QString cacheDir = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
    QDir().mkpath(cacheDir);
    QString filePath = cacheDir + "/cover.jpg";

    QFile file(filePath);
    if (file.open(QIODevice::WriteOnly)) {
        file.write(imgData);
        file.close();
        
        m_coverArtUrl = "file://" + filePath + "?t=" + QString::number(QDateTime::currentMSecsSinceEpoch());
    } else {
        m_coverArtUrl = "";
    }

    emit coverArtUrlChanged();
}

void MpdController::setQueueMode(QueueMode mode) {
    if (m_queueMode != mode) {
        m_queueMode = mode;
        emit queueModeChanged();
    }
}

void MpdController::toggleSelectFolder(const QString& folderPath) {
    if (m_selectedFolders.contains(folderPath)) {
        m_selectedFolders.removeAll(folderPath);
    } else {
        m_selectedFolders.append(folderPath);
    }
    emit selectedFoldersChanged();
}

void MpdController::clearSelectedFolders() {
    m_selectedFolders.clear();
    emit selectedFoldersChanged();
}

bool MpdController::isFolderSelected(const QString& folderPath) const {
    return m_selectedFolders.contains(folderPath);
}

MpdController::QueueMode MpdController::queueMode() const {
    return m_queueMode;
}

QStringList MpdController::selectedFolders() const {
    return m_selectedFolders;
}

QList<SongMetadata> MpdController::upNextSongs() const {
	return m_upNextSongs;
}

void MpdController::playFolderQueue(const QString& folderPath, const QString& startUri) {
    QList<QString> songs = m_connection.listSongsInDirectory(folderPath);
    if (songs.isEmpty()) return;

    m_lastHandledSongPos = -1;

    if (m_queueMode == ModeShuffleFolder) {
        m_activeShufflePool = songs;

        std::random_device rd;
        std::mt19937 g(rd());
        std::shuffle(songs.begin(), songs.end(), g);

        if (!startUri.isEmpty()) {
            int idx = songs.indexOf(startUri);
            if (idx != -1) {
                songs.swapItemsAt(0, idx);
            }
        }
    } else {
        m_activeShufflePool.clear();
    }

    int startIndex = 0;
    if (m_queueMode == ModeDefault && !startUri.isEmpty()) {
        int idx = songs.indexOf(startUri);
        if (idx != -1) startIndex = idx;
    }

    m_connection.playQueue(songs, startIndex);
    updateStatus();
}

void MpdController::playCustomQueue() {
    if (m_selectedFolders.isEmpty()) return;

    QList<QString> allSongs;
    for (const QString& folder : m_selectedFolders) {
        allSongs.append(m_connection.listSongsInDirectory(folder));
    }

    if (allSongs.isEmpty()) return;

    m_activeShufflePool = allSongs; 
    m_lastHandledSongPos = -1;

    std::random_device rd;
    std::mt19937 g(rd());
    std::shuffle(allSongs.begin(), allSongs.end(), g);

    m_connection.playQueue(allSongs, 0);
    updateStatus();
}
