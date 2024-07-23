import QtQuick 2.15
import QtQml 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import org.mauikit.controls 1.3 as Maui
import Qt.labs.settings 1.0
import QtGraphicalEffects 1.15
import QtQml.Models 2.15

Maui.ShadowedRectangle {
    id: rectBookmarksPage

    property string bookmarks: ""

    Settings
    {
        property alias bookmarks: rectBookmarksPage.bookmarks
    }

    scale: 0.80
    opacity: 0
    height: 120
    visible: popupBookmarks.visible

    onVisibleChanged: {
        if (visible)
        {
            scale = 1
            opacity = 1
        }
        else
        {
            scale = 0.90
            opacity = 0
        }
    }

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

    Component.onCompleted: {
        getBookmarks()
    }

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

    onBookmarksChanged: getBookmarks()

    Maui.Page {
        id: pageBookmarks

        anchors.fill: parent

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Item {
                width: pageBookmarks.width
                height: pageBookmarks.height
                Rectangle {
                    anchors.centerIn: parent
                    width: pageBookmarks.width
                    height: pageBookmarks.height
                    radius: 6
                }
            }
        }

        headBar.preferredHeight: 45

        headBar.leftContent: Maui.SearchField
        {
            id: searchInPage

            Layout.maximumWidth: 350
            Layout.preferredHeight: parent.height - 4
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

            Maui.Theme.inherit: false
            Maui.Theme.colorSet: Maui.Theme.View

            font.weight: Font.ExtraLight

            onAccepted: filterModel(text)

    //      onCleared:

            actions: [
            ]

            Maui.ProgressIndicator
            {
                id: progress
                width: parent.width
                anchors.bottom: parent.bottom
                visible: false
            }
        }

        headBar.farRightContent: Maui.CloseButton {
            flat: true
            onClicked: {
                popupBookmarks.visible = false
            }
        }

        Maui.SectionGroup
        {
            id: optionsGroup

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 5

            template.label1.text: i18n("Bookmarks")
            template.label1.font.weight: Font.Normal
            template.label1.font.pixelSize: 20

            description: i18n("Manage Bookmarks")
        }

        Maui.ListBrowser {
            id: listBrowser

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: optionsGroup.bottom
            anchors.margins: 5

            horizontalScrollBarPolicy: ScrollBar.AsNeeded
            verticalScrollBarPolicy: ScrollBar.AsNeeded

            spacing: 5
            clip: true

            height: bookmarksModel.count > 6 ? (60 * 6 + 40) : undefined

            onHeightChanged: {
                rectBookmarksPage.height = 120 + listBrowser.height
            }

            model: bookmarksModelFiltered
        }

        DelegateModel {
            id: bookmarksModelFiltered

            groups: [
                DelegateModelGroup {
                    id: filteredGroups
                    includeByDefault: true
                    name: "filteredItems"
                }
            ]

            filterOnGroup: "filteredItems"

            model: bookmarksModel

            delegate: Maui.ListItemTemplate
            {
                id: listBookmarks

                Layout.margins: 10

                Maui.Theme.inherit: false
                Maui.Theme.colorSet: Maui.Theme.Window

                Behavior on scale {
                    NumberAnimation {
                        duration: 1000
                        easing.type: Easing.OutExpo
                    }
                }

                Behavior on opacity {
                    NumberAnimation { duration: 1000 }
                }

                scale: 0.80
                opacity: 0

                Component.onCompleted: {
                    scale = 1
                    opacity = 1
                }

                width: ListView.view.width
                height: 60

                label1.text: bookmarksModel.get(index).title
                label2.text: Qt.resolvedUrl(bookmarksModel.get(index).url)
                iconSource: Qt.resolvedUrl(bookmarksModel.get(index).iconUrl)
                iconSizeHint: Maui.Style.iconSizes.medium

                ToolButton
                {
                    flat: true
                    icon.name: "tab-new"
                    onClicked: {
                        console.info("Open " + url + " from Bookmarks")
                        stackView.globalTabView.addTab(stackView.globalBrowserComponent, {"url": url}, false);
                        stackView.pop()
                    }
                }
                ToolButton
                {
                    flat: true
                    icon.name: "bookmark-remove"
                    onClicked: {
                        removeFromBookmarks(index)
                    }
                }
            }
        }
    }

    function removeFromBookmarks(currentIndex)
    {
        var urlToRemove = Qt.resolvedUrl(bookmarksModel.get(currentIndex).url)
        bookmarksModel.remove(currentIndex)
        saveBookmarks()

        for (var i = 0; i < stackView.globalTabView.count; i++)
        {
            Qt.resolvedUrl(stackView.globalTabView.tabAt(i).webView.url).toString() == urlToRemove.toString() ? stackView.globalTabView.tabAt(i).webView.isInBookmarks = false : undefined
        }
    }

    function saveBookmarks()
    {
        var datamodel = []

        // Guardar favoritos en ~/.config/KDE/novaiweb.conf
        for (var i = 0; i < bookmarksModel.count; ++i)
        {
            datamodel.push(bookmarksModel.get(i))
        }
        bookmarks = JSON.stringify(datamodel)
    }

    function getBookmarks()
    {
        // Reset Bookmarks model

        bookmarksModel.clear()

        // Get Bookmarks

        if (bookmarksModel.count == 0) {

            // Leer favoritos de ~/.config/KDE/novaiweb.conf

            var datamodel = JSON.parse(bookmarks)
            for (var i = 0; i < datamodel.length; ++i)
            {
                bookmarksModel.append(datamodel[i])
                //bookmarksModel.setData(bookmarksModel.index(i,0), datamodel[i], "title")
                //bookmarksModel.setData(bookmarksModel.index(i,1), datamodel[i], "url")
                //bookmarksModel.setData(bookmarksModel.index(i,2), datamodel[i], "iconUrl")
            }
        }
    }

    function filterModel(query) {

        // Reset

        for (var i = 0; i < bookmarksModel.count; i++) {
            bookmarksModelFiltered.items.addGroups(i, 1, "filteredItems")
        }

        // Filter

        for (var i = 0; i < bookmarksModel.count; i++) {
            bookmarksModel.get(i).title.toLowerCase().includes(query.toLowerCase()) == false && Qt.resolvedUrl(bookmarksModel.get(i).url).toLowerCase().includes(query.toLowerCase()) == false ? bookmarksModelFiltered.items.removeGroups(i, 1, "filteredItems") : undefined
        }
    }
}
