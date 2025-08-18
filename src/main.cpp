// INCLUDE (BASIC SET)

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QCommandLineParser>
#include <QFileInfo>
#include <QIcon>

#include <KAboutData>
#include <KLocalizedString>

// INCLUDE

#include <MauiKit4/Core/mauiapp.h>
#include <MauiKit4/FileBrowsing/fmstatic.h>
#include <MauiKit4/FileBrowsing/moduleinfo.h>
#include <MauiMan4/thememanager.h>
#include <MauiMan4/mauimanutils.h>

#include "../novaiweb_version.h"

#define NOVAIWEB_URI "org.kde.novaiweb"

// MAIN FUNCTION

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    // APP

#ifdef Q_OS_ANDROID
    QGuiApplication app(argc, argv);
    if (!MAUIAndroid::checkRunTimePermissions({"android.permission.WRITE_EXTERNAL_STORAGE"}))
        return -1;
#else
    QGuiApplication app(argc, argv);
#endif

    app.setOrganizationName("KDE");
    app.setWindowIcon(QIcon(":/assets/logo.svg"));
    QGuiApplication::setDesktopFileName(QStringLiteral("project"));
    KLocalizedString::setApplicationDomain("novaiweb");

    // SETS THE VALUE OF THE ENVIRONMENT VARIABLES

    // qputenv("ENVIRONMENT_VARIABLE", "1");

    // ABOUT DIALOG

    KAboutData about(QStringLiteral("novaiweb"),
                     QStringLiteral("Nova iWeb"),
                     NOVAIWEB_VERSION_STRING,
                     i18n("Browser for KDE based on MauiKit."),
                     KAboutLicense::LGPL_V3,
                     APP_COPYRIGHT_NOTICE,
                     QString(GIT_BRANCH) + "/" + QString(GIT_COMMIT_HASH));

    about.addAuthor(QStringLiteral("Miguel Beltrán"), i18n("Developer"), QStringLiteral("novaflowos@gmail.com"));
    about.setHomepage("https://www.novaflowos.com");
    about.setProductName("novaiweb");
    about.setBugAddress("https://github.com/Neshama1/novaiweb/issues");
    about.setOrganizationDomain(NOVAIWEB_URI);
    about.setProgramLogo(app.windowIcon());

    const auto FBData = MauiKitFileBrowsing::aboutData();
    about.addComponent(FBData.name(), MauiKitFileBrowsing::buildVersion(), FBData.version(), FBData.webAddress());

    KAboutData::setApplicationData(about);
    MauiApp::instance()->setIconName("qrc:/assets/logo.svg");

    // COMMAND LINE

    QCommandLineParser parser;

    about.setupCommandLine(&parser);
    parser.process(app);
    about.processCommandLine(&parser);

    const QStringList args = parser.positionalArguments();
    QPair<QString, QList<QUrl>> arguments;

    // arguments.first
    // args.isEmpty()

    // QQMLAPPLICATIONENGINE

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/org/kde/novaiweb/main.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url, &arguments](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);

    // C++ BACKENDS

    // TIPOS

    qmlRegisterType<MauiMan::ThemeManager>("org.kde.novaiweb", 1, 0, "ThemeManager");

    // LOAD MAIN.QML

    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));
    //engine.loadFromModule("org.kde.novaiweb", "Main");
    engine.load(url);

    // EXEC APP

    return app.exec();
}
