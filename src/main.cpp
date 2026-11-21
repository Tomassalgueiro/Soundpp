#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QSocketNotifier>

#include <csignal>
#include <sys/socket.h>
#include <unistd.h>

namespace {

// Self-pipe: the signal handler only writes a byte; the Qt event loop reads it
// and quits normally, so aboutToQuit fires (and MPD gets paused) on SIGTERM/SIGINT.
int g_signalFd[2] = {-1, -1};

void handleQuitSignal(int)
{
    char byte = 1;
    [[maybe_unused]] auto n = ::write(g_signalFd[0], &byte, sizeof(byte));
}

void installQuitSignalHandlers(QCoreApplication& app)
{
    if (::socketpair(AF_UNIX, SOCK_STREAM | SOCK_CLOEXEC, 0, g_signalFd) != 0) {
        qWarning("Failed to create signal socketpair; SIGTERM/SIGINT will not pause MPD");
        return;
    }

    auto* notifier = new QSocketNotifier(g_signalFd[1], QSocketNotifier::Read, &app);
    QObject::connect(notifier, &QSocketNotifier::activated, &app, [notifier]() {
        notifier->setEnabled(false);
        char byte;
        [[maybe_unused]] auto n = ::read(g_signalFd[1], &byte, sizeof(byte));
        QCoreApplication::quit();
    });

    struct sigaction sa = {};
    sa.sa_handler = handleQuitSignal;
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = SA_RESTART;
    sigaction(SIGTERM, &sa, nullptr);
    sigaction(SIGINT, &sa, nullptr);
    sigaction(SIGHUP, &sa, nullptr);
}

} // namespace

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);
    installQuitSignalHandlers(app);

    QQmlApplicationEngine engine;

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection
    );

    engine.loadFromModule("PlayerBackend", "Main");

    return app.exec();
}
