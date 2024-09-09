import QtQuick 2.15
import QtQml 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import org.mauikit.controls 1.3 as Maui
import Qt.labs.settings 1.0
import QtWebEngine 1.10
import QtQuick.LocalStorage 2.15
import QtGraphicalEffects 1.15

Maui.ApplicationWindow
{
    id: root

    visible: true

    onClosing: destroy()

    // PROPERTIES

    property var db
    property var history
    property bool nDialog: false
    property WebEngineView currentBrowse
    property url nUrl
    property bool visibleTabBar: true
    property bool visibleToolBar: true

    visibility: Window.Normal

    // TRANSLUCENCY

    Loader
    {
        active: Maui.Handy.isLinux
        asynchronous: true
        sourceComponent: Maui.WindowBlur
        {
            view: root
            geometry: Qt.rect(root.x, root.y, root.width, root.height)
            enabled: true
        }
    }

    // MODELS

    ListModel { id: bookmarksModel }
    ListModel {
        id: downloadsModel
        property var downloads: []
    }

    // SETTINGS

    Settings
    {
        id: appSettings
        category: "Browser"

        property url homePage: "https://www.google.com"
        property url searchEnginePage: "https://www.google.com/search?q="
        property color backgroundColor : root.Maui.Theme.backgroundColor

        property bool accelerated2dCanvasEnabled : true
        property bool allowGeolocationOnInsecureOrigins : false
        property bool allowRunningInsecureContent : false
        property bool allowWindowActivationFromJavaScript : false
        property bool autoLoadIconsForPage : true
        property bool autoLoadImages : true
        property string defaultTextEncoding : ""
        property bool dnsPrefetchEnabled : false
        property bool errorPageEnabled : true
        property bool focusOnNavigationEnabled : false
        property bool fullscreenSupportEnabled : false
        property bool hyperlinkAuditingEnabled : false
        property bool javascriptCanAccessClipboard : true
        property bool javascriptCanOpenWindows : true
        property bool javascriptCanPaste : true
        property bool javascriptEnabled : true
        property bool linksIncludedInFocusChain : true
        property bool localContentCanAccessFileUrls : true
        property bool localContentCanAccessRemoteUrls : false
        property bool localStorageEnabled : true
        property bool pdfViewerEnabled : true
        property bool playbackRequiresUserGesture : true
        property bool pluginsEnabled : false
        property bool printElementBackgrounds : true
        property bool screenCaptureEnabled : true
        property bool showScrollBars : false
        property bool spatialNavigationEnabled : false
        property bool touchIconsEnabled : false

        property bool webGLEnabled : true
        property bool webRTCPublicInterfacesOnly : false
//      property string downloadsPath :
        property bool restoreSession : true
        property bool switchToTab : false
        property double zoomFactor

        property bool autoSave : false

        property bool findCaseSensitively: false
    }

    SettingsDialog {
        id: settingsDialog
    }

    // PROFILE: DOWNLOADS AND COOKIES

    WebEngineProfile {
        id: downloadProfile

        offTheRecord: false
        persistentCookiesPolicy: WebEngineProfile.ForcePersistentCookies
        storageName: "default"
        cachePath: persistentStoragePath + "/cache"

        onDownloadRequested: {
            addDownload(download)
            saveDownloads()
            download.accept()
            stackView.globalTabView.tabAt(stackView.globalTabView.currentIndex).loading.visible = false
        }

        onDownloadFinished: {
            download.accept()
            console.info(download.receivedBytes)
        }
    }

    // WHEN STARTING APP

    Component.onCompleted: {
    }

    // MAIN PAGE

    Maui.Page {
        anchors.fill: parent
        headBar.visible: false

        background.opacity: 0

        StackView {
            id: stackView
            anchors.fill: parent
            clip: true
            property var globalTabView
            property var globalBrowserComponent
        }

        Component.onCompleted: {
            opendB()
            stackView.push("qrc:/StandardPage.qml")
        }
    }

    // FIND IN PAGE POPUP

    Maui.ShadowedRectangle {
        id: popupFind

        anchors.right: parent.right
        anchors.top: parent.top

        anchors.rightMargin: 35
        anchors.topMargin: 75

        width: 400
        height: 200

        visible: false
        color: "transparent"
        z: 1

        FindTextInPage {
            id: findPage

            width: parent.width
        }
    }

    // BOOKMARKS POPUP

    Maui.ShadowedRectangle {
        id: popupBookmarks

        anchors.right: parent.right
        anchors.top: parent.top

        anchors.rightMargin: 35
        anchors.topMargin: 75

        width: 400
        height: 120

        visible: false
        color: "transparent"
        z: 1

        Bookmarks {
            id: bookmarksPage

            width: parent.width
        }
    }

    // HISTORY POPUP

    Maui.ShadowedRectangle {
        id: popupHistory

        anchors.right: parent.right
        anchors.top: parent.top

        anchors.rightMargin: 35
        anchors.topMargin: 75

        width: 400
        height: 120

        visible: false
        color: "transparent"
        z: 1

        History {
            id: historyPage

            width: parent.width
        }
    }

    // DOWNLOADS POPUP

    Maui.ShadowedRectangle {
        id: popupDownloads

        anchors.right: parent.right
        anchors.top: parent.top

        anchors.rightMargin: 35
        anchors.topMargin: 75

        width: 400
        height: 120

        visible: false
        color: "transparent"
        z: 1

        Downloads {
            id: downloadsPage

            width: parent.width
        }
    }

    // FUNCTIONS

    function newWindow(urls,newDialog)
    {
        var nComponent = Qt.createComponent("NewWindow.qml")

        console.info("dialog: ", newDialog)
        console.info("url: ", urls)

        if (newDialog)
        {
            nWindow = nComponent.createObject(root, {"nUrl": urls, "nDialog": true, "visibleTabBar": false, "visibleToolBar": false})
        }
        else
        {
            nWindow = nComponent.createObject(root, {"nUrl": urls[0], "nDialog": false, "visibleTabBar": true, "visibleToolBar": true})
        }

        nWindow.show()
    }

    function opendB()
    {
        // Open
        db = LocalStorage.openDatabaseSync("NovaiWebDB", "", "The Nova iWeb QML SQL", 1000000);

        db.transaction(function(tx) {

            // Create the database if it doesn't already exist
            tx.executeSql('CREATE TABLE IF NOT EXISTS History(title TEXT, url TEXT, iconUrl TEXT, dateTime TEXT)');

            // Show all added greetings
            history = tx.executeSql('SELECT * FROM History');
        })
    }

    function addTodB(title, url, iconUrl, dateTime)
    {
        db.transaction(function(tx) {

            // Add to history
            history = tx.executeSql('INSERT INTO History VALUES (?, ?, ?, ?)', [ title, url, iconUrl, dateTime ]);

            // Show all added greetings
            history = tx.executeSql('SELECT * FROM History');
        })
    }

    function addDownload(download) {

        // Add download to the end of elements (model, array)
        downloadsModel.append(download)
        downloadsModel.downloads.push(download)

        // Add download to the beginning of elements (model, array)
        // downloadsModel.insert(0,download)
        // downloadsModel.downloads.unshift(download)

        console.info("Add to downloads: " + downloadsModel.downloads[0].downloadFileName)
        console.info("URL: " + downloadsModel.downloads[0].url)
    }
}
