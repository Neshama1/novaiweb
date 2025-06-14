import QtQuick
import QtQml
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import org.mauikit.controls as Maui

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
