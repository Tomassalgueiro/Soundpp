#include <QGuiApplication>
#include <QQmlApplicationEngine>

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    // Load the QML module registered under URI "PlayerBackend"
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection
    );

    // Modern Qt 6 loads module entry points via the module URI
    engine.loadFromModule("PlayerBackend", "Main");

    return app.exec();
}
