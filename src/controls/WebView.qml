import QtQuick 2.15
import QtQml 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12
import org.mauikit.controls 1.3 as Maui
import Qt.labs.settings 1.0
import QtWebEngine 1.10
import QtGraphicalEffects 1.15
import QtQuick.Window 2.15

Maui.Page
{
    id: control

    property alias url : _webView.url
    property alias webView : _webView
    property alias loading : progress
    readonly property string title : _webView.title.length ? _webView.title : "Nova iWeb"
    readonly property string iconName: _webView.icon

    property string bookmarks: ""
    property string downloads: ""
    property bool otherNavigationType: false

    Maui.TabViewInfo.tabTitle: title
    Maui.TabViewInfo.tabToolTipText: _webView.url
    Maui.Theme.inherit: false
    Maui.Theme.colorSet: Maui.Theme.Window

    background.opacity: 0
    headBar.background: null
    headBar.visible: nDialog ? visibleToolBar : true
    headBar.preferredHeight: 42

    showCSDControls: false

    // ANIMATIONS

    scale: 0.80
    opacity: 0

    Behavior on scale {
        NumberAnimation {
            duration: 800
            easing.type: Easing.OutExpo
        }
    }

    Behavior on opacity {
        NumberAnimation { duration: 800 }
    }

    Behavior on height {
        NumberAnimation {
            duration: 1000
            easing.type: Easing.OutExpo
        }
    }

    // WHEN STARTING APP

    Component.onCompleted: {
        scale = 1
        opacity = 1
    }

    // SETTINGS

    Settings {
        property alias bookmarks: control.bookmarks
        property var downloads: control.downloads
    }

    // HEADBAR

    headBar.farLeftContent: Rectangle {

        Layout.leftMargin: 10
        Layout.rightMargin: 10
        Layout.preferredWidth: parent.height
        Maui.Theme.inherit: false
        Maui.Theme.colorSet: Maui.Theme.View

        radius: width
        color: Maui.Theme.backgroundColor
        border.width: 3
        border.color: Qt.darker(Maui.Theme.backgroundColor,1.1)

        opacity: 0.40
        scale: 1.3

        Label {
            id: lbApp
            anchors.centerIn: parent
            anchors.margins: 5
            text: "iWeb"
            font.weight: Font.Bold
            font.pixelSize: 8
            opacity: 0.90

            Maui.ProgressIndicator
            {
                id: progressLbApp
                anchors.fill: parent
                visible: true
                opacity: 0
            }
        }
    }

    headBar.leftContent: [
        ToolButton
        {
            visible: false
            icon.name: "tab-new-background"
            flat: true
            onClicked: {
            }
        },

        Maui.Badge
        {
            id: badge
            Maui.Theme.inherit: false
            Maui.Theme.colorSet: Maui.Theme.View
            opacity: 0.80
            color: Maui.Theme.backgroundColor
            text: tabView.count
            onClicked: popupTabs.open()
        },

        ToolButton
        {
            icon.name: "draw-arrow-back"
            flat: true
            onClicked: _webView.canGoBack ? _webView.goBack() : undefined
        },

        ToolButton
        {
            icon.name: "draw-arrow-forward"
            flat: true
            onClicked: _webView.canGoForward ? _webView.goForward() : undefined
        }
    ]

    headBar.middleContent: Maui.SearchField
    {
        id: searchField

        Layout.maximumWidth: 350
        Layout.preferredHeight: parent.height - 6
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

        Maui.Theme.inherit: false
        Maui.Theme.colorSet: Maui.Theme.View

        font.weight: Font.ExtraLight

        onAccepted: openUrl(text)

//      onCleared:

        actions: [
            Action
            {
                icon.name: "go-home"
                onTriggered:
                {
                    webView.url = appSettings.homePage
                }
            },
            Action
            {
                icon.name: _webView.isInBookmarks ? "bookmarks-bookmarked" : "bookmarks"
                onTriggered: _webView.isInBookmarks ? removeFromFavorites() : addToFavorites()
            }
        ]

        Maui.ProgressIndicator
        {
            id: progress
            width: parent.width
            anchors.bottom: parent.bottom
            visible: false
        }
    }

    headBar.rightContent: [

        ToolButton
        {
            visible: downloadsModel.count > 0 ? true : false
            icon.name: "download"
            flat: true
            onClicked: popupDownloads.visible =! popupDownloads.visible
        },

        Maui.ToolButtonMenu
        {
            icon.name: "overflow-menu"
            MenuItem
            {
                text: i18n("New Tab")
                icon.name: "list-add"
                onTriggered: tabView.addTab(browserComponent, {"url": appSettings.homePage}, false);
            }

            /*
            MenuItem
            {
                text: i18n("Incognito Tab")
                icon.name: "actor"
            }
            */

            MenuSeparator {}

            Maui.MenuItemActionRow
            {
                Action
                {
                    icon.name: "zoom-out"
                    onTriggered:
                    {
                        appSettings.zoomFactor = Math.max(appSettings.zoomFactor-0.25, 0.25)
                    }
                }

                Action
                {
                    icon.name: "zoom-in"
                    onTriggered:
                    {
                        appSettings.zoomFactor = Math.min(appSettings.zoomFactor+0.25, 5.0)
                    }
                }

                Action
                {
                    icon.name: "zoom-fit-page"
                    onTriggered:
                    {
                        appSettings.zoomFactor = 1.0
                    }
                }
            }

            MenuSeparator {}

            MenuItem
            {
                text: i18n("Bookmarks")
                icon.name: "bookmarks"
                onTriggered: openBookmarks()
            }

            MenuItem
            {
                text: i18n("History")
                icon.name: "deep-history"
                onTriggered: openHistory()

            }

            MenuItem
            {
                text: i18n("Downloads")
                icon.name: "folder-downloads"
                onTriggered: openDownloads()

            }

            MenuSeparator {}

            MenuItem
            {
                text: i18n("Find In Page")
                icon.name: "edit-find"
                //checked: _browserView.searchFieldVisible
                onTriggered: {
                    console.info("entra 1")
                    popupFind.visible = true
                }
            }

            MenuSeparator {}

            MenuItem
            {
                text: i18n("Settings")
                icon.name: "settings-configure"
                onTriggered: settingsDialog.open()
            }

            MenuItem
            {
                text: i18n("About")
                icon.name: "documentinfo"
                onTriggered: root.about()
            }

        },

        ToolButton
        {
            icon.name: "view-refresh"
            flat: true
            onClicked: {
                stackView.globalTabView.tabAt(stackView.globalTabView.currentIndex).webView.reload()
            }
        }
    ]

    headBar.farRightContent: Maui.CloseButton {
        //icon.name: "view-refresh"
        flat: true
        onClicked: {
            root.close()
        }
    }

    // CONTEXTUAL MENU

    ContextualMenu
    {
        id: contextualMenu
        webView: _webView
    }

    // DIALOG POPUP (NEW VIEW IN DIALOG)

    Maui.ShadowedRectangle {
        id: newViewInDialog

        visible: false

        anchors.fill: parent
        anchors.margins: 100

        Maui.Theme.inherit: false
        Maui.Theme.colorSet: Maui.Theme.View

        border.width: 0
        border.color: Qt.lighter("#dadada",1.08)
        shadow.size: 15
        shadow.color: Maui.ColorUtils.brightnessForColor(Maui.Theme.backgroundColor) == Maui.ColorUtils.Light ? Qt.darker("#dadada",1.1) : "#2c2c2c"
        shadow.xOffset: -1
        shadow.yOffset: 0
        radius: 6

        color: Maui.Theme.backgroundColor

        clip: false

        z: 1

        // NEW VIEW IN DIALOG

        Maui.Page {
            id: pageNewViewInDialog
            anchors.fill: parent

            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Item {
                    width: pageNewViewInDialog.width
                    height: pageNewViewInDialog.height
                    Rectangle {
                        anchors.centerIn: parent
                        width: pageNewViewInDialog.width
                        height: pageNewViewInDialog.height
                        radius: 6
                    }
                }
            }

            headBar.preferredHeight: 45

            headBar.farRightContent: [
                ToolButton
                {
                    icon.name: "view-refresh"
                    flat: true
                    onClicked: {
                        webViewDialog.reload()
                    }
                },
                Maui.CloseButton {
                    flat: true
                    onClicked: {
                        newViewInDialog.visible = false
                    }
                }
            ]

            // WEB VIEW FOR A NEW DIALOG

            WebEngineView
            {
                id: webViewDialog

                anchors.fill: parent

                opacity: 0.90
                profile: downloadProfile
                zoomFactor: appSettings.zoomFactor
                backgroundColor: Maui.Theme.backgroundColor
                clip: true

                // SLOTS FOR NEW DIALOG

                onContextMenuRequested: {
                    request.accepted = true // Make sure QtWebEngine doesn't show its own context menu.
                    contextualMenu.request = request
                    contextualMenu.show()
                }

                onLoadingChanged: {
                    console.info("status: " + loadRequest.status)
                    if (loadRequest.status == WebEngineView.LoadSucceededStatus)
                    {
                        progress.visible = false
                        var dateString = new Date().toLocaleDateString(Qt.locale("es_ES"))
                        var timeString = new Date().toLocaleTimeString(Qt.locale("es_ES"))
                        var dateTime = dateString + " " + timeString
                        addTodB(webView.title, webView.url, webView.icon, dateTime)
                    }
                    else
                    {
                        progress.visible = navigationType == 6 ? false : true
                    }
                }

                //onUrlChanged: {
                //    searchField.text = url
                //    _webView.isInBookmarks = checkBookmark(url)
                //}

                onFeaturePermissionRequested: {
                    grantFeaturePermission(securityOrigin, feature, true)
                }

                onFullScreenRequested: {
                    request.accept()
                    if (root.visibility == Window.FullScreen)
                    {
                        tabView.tabBar.visible = true
                        control.headBar.visible = true
                        rectWebView.anchors.margins = 10
                        root.visibility = Window.Windowed
                    }
                    else
                    {
                        tabView.tabBar.visible = false
                        control.headBar.visible = false
                        rectWebView.anchors.margins = 0
                        root.visibility = Window.FullScreen
                    }
                }

                onIconChanged:
                {
                    console.log("ICON CHANGED", icon)
                    if (icon)
                    {
                        //Fiery.History.updateIcon(url, icon)
                    }
                }

                onLinkHovered:
                {
                    console.log("LINK HOVERED", url)
                }

                onFindTextFinished:
                {
                    // findInPageResultIndex = result.activeMatch;
                    // findInPageResultCount = result.numberOfMatches;
                }

                onFileDialogRequested:
                {
                    console.log("FILE DIALOG REQUESTED", request.mode, FileDialogRequest.FileModeSave)
                }

                onNewViewRequested:
                {
                    if (!request.userInitiated)
                        return;

                    request.destination == WebEngineView.NewViewInTab ? tabView.addTab(browserComponent, {"url": request.requestedUrl}, false) : undefined
                    request.destination == WebEngineView.NewViewInWindow ? newWindow(request.requestedUrl,false) : undefined
                    request.destination == WebEngineView.NewViewInDialog ? newWindow(request.requestedUrl,true) : undefined

                    //request.destination == WebEngineView.NewViewInWindow ? tabView.addTab(browserComponent, {"url": request.requestedUrl}, false) : undefined
                    //request.destination == WebEngineView.NewViewInDialog ? tabView.addTab(browserComponent, {"url": request.requestedUrl}, false) : undefined
                }

                onNavigationRequested:
                {
                    console.log("Navigation requested",  request.navigationType)
                    request.action = WebEngineNavigationRequest.AcceptRequest
                    navigationType = request.navigationType
                }

                // SETTINGS FOR NEW DIALOG

                settings.accelerated2dCanvasEnabled : appSettings.accelerated2dCanvasEnabled
                settings.allowGeolocationOnInsecureOrigins : appSettings.allowGeolocationOnInsecureOrigins
                settings.allowRunningInsecureContent : appSettings.allowRunningInsecureContent
                settings.allowWindowActivationFromJavaScript : appSettings.allowWindowActivationFromJavaScript
                settings.autoLoadImages : appSettings.autoLoadImages
                settings.defaultTextEncoding : appSettings.defaultTextEncoding
                settings.dnsPrefetchEnabled : appSettings.dnsPrefetchEnabled
                settings.errorPageEnabled : appSettings.errorPageEnabled
                settings.focusOnNavigationEnabled : appSettings.focusOnNavigationEnabled
    //          settings.fullscreensupportEnabled : appSettings.fullscreenSupportEnabled
                settings.hyperlinkAuditingEnabled : appSettings.hyperlinkAuditingEnabled
                settings.javascriptCanAccessClipboard : appSettings.javascriptCanAccessClipboard
                settings.javascriptCanOpenWindows : appSettings.javascriptCanOpenWindows
                settings.javascriptCanPaste : appSettings.javascriptCanPaste
                settings.javascriptEnabled : appSettings.javascriptEnabled
                settings.linksIncludedInFocusChain : appSettings.linksIncludedInFocusChain
                settings.localContentCanAccessFileUrls : appSettings.localContentCanAccessFileUrls
                settings.localContentCanAccessRemoteUrls : appSettings.localContentCanAccessRemoteUrls
                settings.localStorageEnabled : appSettings.localStorageEnabled
                settings.pdfViewerEnabled : appSettings.pdfViewerEnabled
                settings.playbackRequiresUserGesture : appSettings.playbackRequiresUserGesture
                settings.pluginsEnabled : appSettings.pluginsEnabled
                settings.printElementBackgrounds : appSettings.printElementBackgrounds
                settings.screenCaptureEnabled : appSettings.screenCaptureEnabled
                settings.showScrollBars : appSettings.showScrollBars
                settings.spatialNavigationEnabled : appSettings.spatialNavigationEnabled
                settings.webGLEnabled : appSettings.webGLEnabled
                settings.webRTCPublicInterfacesOnly : appSettings.webRTCPublicInterfacesOnly

                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Item {
                        width: webViewDialog.width
                        height: webViewDialog.height
                        Rectangle {
                            anchors.centerIn: parent
                            width: webViewDialog.width
                            height: webViewDialog.height
                            radius: 5
                        }
                    }
                }
            }
        }
    }

    // TABS POPUP

    Maui.PopupPage
    {
        id: popupTabs

        hint: 1

        title: i18n("Tabs")

        width: 545

        Maui.ListBrowser {
            id: list

            anchors.fill: parent
            anchors.margins: 10

            horizontalScrollBarPolicy: ScrollBar.AlwaysOff
            verticalScrollBarPolicy: ScrollBar.AlwaysOff

            spacing: 10

            model: tabView.count

            delegate: Rectangle {
                color: "transparent"
                width: ListView.view.width
                height: 50
                Maui.SwipeBrowserDelegate
                {
                    anchors.fill: parent

                    label1.text: tabView.tabAt(index).webView.title
                    label2.text: tabView.tabAt(index).webView.url
                    iconSource: tabView.tabAt(index).webView.icon

                    iconSizeHint: Maui.Style.iconSizes.medium

                    quickActions: [
                        Action
                        {
                            icon.name: "view-close-symbolic"
                            onTriggered: tabView.count > 1 ? tabView.closeTab(index) : undefined
                        }
                    ]

                    onClicked: {
                        tabView.setCurrentIndex(index)

                        stackView.globalTabView.tabAt(index).webView.scale = 0.80
                        stackView.globalTabView.tabAt(index).webView.opacity = 0

                        stackView.globalTabView.tabAt(index).webView.scale = 1
                        stackView.globalTabView.tabAt(index).webView.opacity = 1
                    }
                }
            }
        }
    }

    // PAGE (WEB VIEW)

    Maui.ShadowedRectangle {

        id: rectWebView

        anchors.fill: parent
        anchors.leftMargin: 7
        anchors.rightMargin: 7
        anchors.topMargin: 0
        anchors.bottomMargin: 0

        Maui.Theme.inherit: false
        Maui.Theme.colorSet: Maui.Theme.Window

        radius: 4
        color: Maui.Theme.backgroundColor
        shadow.size: 30
        shadow.xOffset: 0
        shadow.yOffset: 0
        shadow.color: Maui.ColorUtils.brightnessForColor(Maui.Theme.backgroundColor) == Maui.ColorUtils.Light ? "#dadada" : "#2c2c2c"
        clip: false

        // WEB VIEW

        WebEngineView
        {
            id: _webView

            anchors.fill: parent

            property bool isInBookmarks

            x: -hbar.position * width
            y: -vbar.position * height
            opacity: 0.90
            profile: downloadProfile
            zoomFactor: appSettings.zoomFactor
            backgroundColor: Maui.Theme.backgroundColor
            clip: true

            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Item {
                    width: _webView.width
                    height: _webView.height
                    Rectangle {
                        anchors.centerIn: parent
                        width: _webView.width
                        height: _webView.height
                        radius: rectWebView.radius
                    }
                }
            }

            // SETTINGS

            settings.accelerated2dCanvasEnabled : appSettings.accelerated2dCanvasEnabled
            settings.allowGeolocationOnInsecureOrigins : appSettings.allowGeolocationOnInsecureOrigins
            settings.allowRunningInsecureContent : appSettings.allowRunningInsecureContent
            settings.allowWindowActivationFromJavaScript : appSettings.allowWindowActivationFromJavaScript
            settings.autoLoadImages : appSettings.autoLoadImages
            settings.defaultTextEncoding : appSettings.defaultTextEncoding
            settings.dnsPrefetchEnabled : appSettings.dnsPrefetchEnabled
            settings.errorPageEnabled : appSettings.errorPageEnabled
            settings.focusOnNavigationEnabled : appSettings.focusOnNavigationEnabled
//          settings.fullscreensupportEnabled : appSettings.fullscreenSupportEnabled
            settings.hyperlinkAuditingEnabled : appSettings.hyperlinkAuditingEnabled
            settings.javascriptCanAccessClipboard : appSettings.javascriptCanAccessClipboard
            settings.javascriptCanOpenWindows : appSettings.javascriptCanOpenWindows
            settings.javascriptCanPaste : appSettings.javascriptCanPaste
            settings.javascriptEnabled : appSettings.javascriptEnabled
            settings.linksIncludedInFocusChain : appSettings.linksIncludedInFocusChain
            settings.localContentCanAccessFileUrls : appSettings.localContentCanAccessFileUrls
            settings.localContentCanAccessRemoteUrls : appSettings.localContentCanAccessRemoteUrls
            settings.localStorageEnabled : appSettings.localStorageEnabled
            settings.pdfViewerEnabled : appSettings.pdfViewerEnabled
            settings.playbackRequiresUserGesture : appSettings.playbackRequiresUserGesture
            settings.pluginsEnabled : appSettings.pluginsEnabled
            settings.printElementBackgrounds : appSettings.printElementBackgrounds
            settings.screenCaptureEnabled : appSettings.screenCaptureEnabled
            settings.showScrollBars : appSettings.showScrollBars
            settings.spatialNavigationEnabled : appSettings.spatialNavigationEnabled
            settings.webGLEnabled : appSettings.webGLEnabled
            settings.webRTCPublicInterfacesOnly : appSettings.webRTCPublicInterfacesOnly

            // SLOTS

            onContextMenuRequested: {
                request.accepted = true // Make sure QtWebEngine doesn't show its own context menu.
                contextualMenu.request = request
                contextualMenu.show()
            }

            onLoadingChanged: {
                if (loadRequest.status == WebEngineView.LoadSucceededStatus)
                {
                    progress.visible = false
                    addTodB(webView.title, webView.url, webView.icon, Qt.formatDateTime(new Date(), "yyyyMMdd-hhmmss.zzz"))
                }
                else
                {
                    progress.visible = control.otherNavigationType ? false : true
                }
            }

            onUrlChanged: {
                searchField.text = url
                _webView.isInBookmarks = checkBookmark(url)
            }

            onFeaturePermissionRequested: {
                grantFeaturePermission(securityOrigin, feature, true)
            }

            onFullScreenRequested: {
                request.accept()
                if (root.visibility == Window.FullScreen)
                {
                    control.headBar.visible = true
                    rectWebView.anchors.leftMargin = 7
                    rectWebView.anchors.rightMargin = 7
                    rectWebView.anchors.topMargin = 0
                    rectWebView.anchors.bottomMargin = 0
                    rectWebView.radius = 5
                    root.visibility = Window.Windowed
                }
                else
                {
                    control.headBar.visible = false
                    rectWebView.anchors.leftMargin = 0
                    rectWebView.anchors.rightMargin = 0
                    rectWebView.anchors.topMargin = 0
                    rectWebView.anchors.bottomMargin = 0
                    rectWebView.radius = 0
                    root.visibility = Window.FullScreen
                }
            }

            onIconChanged: {
                console.log("ICON CHANGED", icon)
                if (icon)
                {
                    //Fiery.History.updateIcon(url, icon)
                }
            }

            onLinkHovered:
            {
                console.log("LINK HOVERED", url)
            }

            onFindTextFinished: {
            }

            onFileDialogRequested:
            {
                console.log("FILE DIALOG REQUESTED", request.mode, FileDialogRequest.FileModeSave)
            }

            onNewViewRequested:
            {
                if(!request.userInitiated)
                    return;

                request.destination == WebEngineView.NewViewInTab ? tabView.addTab(browserComponent, {"url": request.requestedUrl}, false) : undefined
                request.destination == WebEngineView.NewViewInWindow ? newWindow(request.requestedUrl,false) : undefined
                request.destination == WebEngineView.NewViewInDialog ? openDialog(request.requestedUrl) : undefined

                //request.destination == WebEngineView.NewViewInWindow ? tabView.addTab(browserComponent, {"url": request.requestedUrl}, false) : undefined
                //request.destination == WebEngineView.NewViewInDialog ? tabView.addTab(browserComponent, {"url": request.requestedUrl}, false) : undefined
            }

            onNavigationRequested:
            {
                control.otherNavigationType = request.navigationType == 6 ? true : (request.navigationType == 4 ? undefined : false)
                request.action = WebEngineNavigationRequest.AcceptRequest
            }
        }

        // SCROLLBARS

        ScrollBar {
            id: vbar
            hoverEnabled: true
            active: hovered || pressed
            orientation: Qt.Vertical
            width: 5
            size: rectWebView.height / _webView.contentsSize.height
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 5
            policy: ScrollBar.AsNeeded
            visible: false
        }

        ScrollBar {
            id: hbar
            hoverEnabled: true
            active: hovered || pressed
            orientation: Qt.Horizontal
            height: 5
            size: rectWebView.width / _webView.contentsSize.width
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 5
            policy: ScrollBar.AsNeeded
            visible: false
        }
    }

    // FUNCTIONS

    function openUrl(path)
    {
        if(validURL(path))
        {
            path.includes("https://") ? undefined : path = "https://" + path
            _webView.url = path
        }
        else
        {
            _webView.url = appSettings.searchEnginePage + path
        }
    }

    function validURL(str)
    {
        var pattern = new RegExp('^(https?:\\/\\/)?'+ // protocol
                                '((([a-z\\d]([a-z\\d-]*[a-z\\d])*)\\.)+[a-z]{2,}|'+ // domain name
                                '((\\d{1,3}\\.){3}\\d{1,3}))'+ // OR ip (v4) address
                                '(\\:\\d+)?(\\/[-a-z\\d%_.~+]*)*'+ // port and path
                                '(\\?[;&a-z\\d%_.~+=-]*)?'+ // query string
                                '(\\#[-a-z\\d_]*)?$','i'); // fragment locator
        return !!pattern.test(str);
    }

    function openBookmarks()
    {
        popupBookmarks.visible = true
    }

    function openHistory()
    {
        popupHistory.visible = true
    }

    function openDownloads()
    {
        popupDownloads.visible = true
    }

    function checkBookmark(url)
    {
        var match = false
        for (var i = 0; i < bookmarksModel.count; i++)
        {
            url == bookmarksModel.get(i).url ? match = true : undefined
        }
        return match
    }

    function addToFavorites()
    {
        bookmarksModel.append({"title": webView.title, "url": Qt.resolvedUrl(webView.url), "iconUrl": Qt.resolvedUrl(webView.icon)})
        saveFavorites()
        _webView.isInBookmarks = checkBookmark(bookmarksModel.get(bookmarksModel.index).url)

        console.info("Add to favorites: " + bookmarksModel.get(0).title)
        console.info("URL: " + bookmarksModel.get(0).url)

        var newUrl = bookmarksModel.get(0).url
    }

    function removeFromFavorites()
    {
        var urlToRemove = webView.url

        for (var i = 0; i < bookmarksModel.count; i++)
        {
            Qt.resolvedUrl(urlToRemove) == Qt.resolvedUrl(bookmarksModel.get(i).url) ? bookmarksModel.remove(i) : undefined
        }

        webView.isInBookmarks = false
        saveFavorites()
    }

    function checkIndexInBookmarks(url)
    {
        for (var i = 0; i < bookmarksModel.count; i++)
        {
            Qt.resolvedUrl(stackView.globalTabView.tabAt(i).webView.url) == urlToRemove ? stackView.globalTabView.tabAt(i).webView.isInBookmarks = false : undefined
        }
    }

    function saveFavorites()
    {
        var datamodel = []

        // Guardar favoritos en ~/.config/KDE/novaiweb.conf
        for (var i = 0; i < bookmarksModel.count; ++i)
        {
            datamodel.push(bookmarksModel.get(i))
        }
        bookmarks = JSON.stringify(datamodel)
    }

    function saveDownloads()
    {
        var datamodel = []

        // Guardar descargas en ~/.config/KDE/novaiweb.conf
        for (var i = 0; i < downloadsModel.count; ++i)
        {
            var download = downloadsModel.downloads[i]
            //var download = downloadsModel.get(i)
            datamodel.push(download)
        }
        //downloads = JSON.stringify(datamodel)
    }

    function openDialog(urlDialog)
    {
        newViewInDialog.visible = true
        webViewDialog.url = urlDialog
    }
}
