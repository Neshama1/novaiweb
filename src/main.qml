import QtCore
import QtQml
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.LocalStorage
import QtWebEngine
import org.mauikit.controls as Maui
import org.mauikit.filebrowsing as FB
import org.kde.novaiweb 1.0

Maui.ApplicationWindow
{
    id: root

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

    // STYLE

    Maui.Style.styleType: themeManager.styleType
    Maui.Style.accentColor: themeManager.accentColor
    Maui.Style.defaultSpacing: themeManager.spacingSize
    Maui.Style.defaultPadding: themeManager.paddingSize
    Maui.Style.contentMargins: themeManager.marginSize
    Maui.Style.radiusV: themeManager.borderRadius

    // MODELS

    ListModel { id: bookmarksModel }
    ListModel {
        id: downloadsModel
        property var downloads: []
    }

    // PROPERTIES

    property var db
    property var history
    property bool nDialog: false
    property WebEngineView currentBrowser
	property int styleType: Maui.Style.Auto

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
        property bool showScrollBars : true
        property bool spatialNavigationEnabled : false
        property bool touchIconsEnabled : false

        property bool webGLEnabled : true
        property bool webRTCPublicInterfacesOnly : false
//      property string downloadsPath :
        property bool restoreSession : true
        property bool switchToTab : false
        property double zoomFactor: 1.0

        property bool autoSave : false

        property bool findCaseSensitively: false

		property alias styleType: root.styleType
    }

    SettingsDialog {
        id: settingsDialog
    }

    // FILE DIALOG

    FB.FileDialog {
        id: flDialog
    }

    // DEFAULT WIDTH AND HEIGHT

    width: Screen.desktopAvailableWidth - Screen.desktopAvailableWidth * 36 / 100
    height: Screen.desktopAvailableHeight - Screen.desktopAvailableHeight * 13 / 100

	// VISIBILITY

	visibility: Window.Windowed

    // THEME MANAGER

    ThemeManager {
        id: themeManager
    }

	// WHEN STARTING APP

    Component.onCompleted: {

        // Theme

        Maui.Style.styleType = styleType === Maui.Style.Auto ? themeManager.styleType : styleType
        Maui.Style.windowControlsTheme = themeManager.windowControlsTheme
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
            background.opacity: 0
            property var globalTabView
            property var globalBrowserComponent
        }

        Component.onCompleted: {
            opendB()
            stackView.push("controls/StandardPage.qml")
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
        var nComponent = Qt.createComponent("controls/NewWindow.qml")

        console.info("dialog: ", newDialog)
        console.info("url: ", urls)

        if (newDialog)
        {
            nWindow = nComponent.createObject(root, {"nUrl": urls, "nDialog": true, "visibleBar": false, "visibleToolBar": false})
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
            history = tx.executeSql('SELECT * FROM History ORDER BY dateTime DESC');
        })
    }

    function addTodB(title, url, iconUrl, dateTime)
    {
        db.transaction(function(tx) {

            // Add to history
            history = tx.executeSql('INSERT INTO History VALUES (?, ?, ?, ?)', [ title, url, iconUrl, dateTime ]);

            // Show all added greetings
            history = tx.executeSql('SELECT * FROM History ORDER BY dateTime DESC');
        })
    }

    function deleteFromdB(title, url, iconUrl, dateTime)
    {
        db.transaction(function(tx) {

            // Delete from history
            history = tx.executeSql('DELETE FROM History WHERE title IS \"' + title  + '\" AND url IS \"' + url  + '\" AND iconUrl IS \"' + iconUrl  + '\" AND dateTime IS \"' + dateTime  + '\"');

            // Show all added greetings
            history = tx.executeSql('SELECT * FROM History ORDER BY dateTime DESC');
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

    function saveDownloads() {

        var datamodel = []

        // Guardar descargas en ~/.config/KDE/novaiweb.conf
        for (var i = 0; i < downloadsModel.count; i++)
        {
            var download = downloadsModel.downloads[i]
            datamodel.push(download)
        }

        //downloads = JSON.stringify(datamodel)
    }
}
