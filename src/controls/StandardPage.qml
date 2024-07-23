import QtQuick 2.15
import QtQml 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import org.mauikit.controls 1.3 as Maui
import Qt.labs.settings 1.0
import QtWebEngine 1.10

Maui.Page {
    id: standardPage

    headBar.visible: false
    background.opacity: 0.95

    Component.onCompleted: {
        currentBrowser = tabView.currentItem.webView
        stackView.globalTabView = tabView
        stackView.globalBrowserComponent = browserComponent
    }

    Maui.TabView
    {
        id: tabView
        anchors.fill: parent

        background.opacity: 0

        tabBar.background: null
        tabBar.height: 50
        tabBar.showNewTabButton: true
        tabBar.visible: false

        onNewTabClicked: tabView.addTab(browserComponent, {"url": appSettings.homePage}, false);
        onCloseTabClicked: tabView.closeTab(index)

        onCurrentIndexChanged: updateBookMarkIcon(Qt.resolvedUrl(stackView.globalTabView.tabAt(currentIndex).webView.url))

        altTabBar: Maui.Handy.isMobile

        Component.onCompleted: {
            tabView.addTab(browserComponent, {"url": appSettings.homePage}, false);
        }
    }

    Component
    {
        id: browserComponent

        WebView {}
    }

    function updateBookmarkIcon(urlTocheck)
    {
        for (var i = 0; i < bookmarksModel.count; i++)
        {
            Qt.resolvedUrl(bookmarksModel.get(i).url) == urlToCheck ? stackView.globalTabView.tabAt(currentIndex).webView.isInBookmarks = false : undefined
        }
    }
}
