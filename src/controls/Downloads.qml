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
    id: rectDownloadsPage

    property string downloads: ""

    Settings
    {
        property alias downloads: rectDownloadsPage.downloads
    }

    scale: 0.80
    opacity: 0
    height: 120
    visible: popupDownloads.visible

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
        getDownloads()
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

    onDownloadsChanged: getDownloads()

    Maui.Page {
        id: pageDownloads

        anchors.fill: parent

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Item {
                width: pageDownloads.width
                height: pageDownloads.height
                Rectangle {
                    anchors.centerIn: parent
                    width: pageDownloads.width
                    height: pageDownloads.height
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
                popupDownloads.visible = false
            }
        }

        Maui.SectionGroup
        {
            id: optionsGroup

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 5

            template.label1.text: i18n("Downloads")
            template.label1.font.weight: Font.Normal
            template.label1.font.pixelSize: 20

            description: i18n("Manage Downloads")
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

            height: downloadsModel.count > 6 ? (60 * 6 + 40) : undefined

            onHeightChanged: {
                rectDownloadsPage.height = 120 + listBrowser.height
            }

            model: downloadsModelFiltered
        }

        DelegateModel {
            id: downloadsModelFiltered

            groups: [
                DelegateModelGroup {
                    id: filteredGroups
                    includeByDefault: true
                    name: "filteredItems"
                }
            ]

            filterOnGroup: "filteredItems"

            model: downloadsModel

            delegate: Maui.ListItemTemplate
            {
                id: listDownloads

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

                //imageSource: "https://upload.wikimedia.org/wikipedia/commons/8/8d/KDE_logo.svg"
                //iconSource: "folder"

                label1.text: "#" + (index + 1)
                label2.text: downloadsModel.downloads[index].downloadFileName
                label3.text: Number.parseFloat(100 * (downloadsModel.downloads[index].receivedBytes / downloadsModel.downloads[index].totalBytes)).toFixed(1) + " %"

                ToolButton
                {
                    flat: true
                    icon.name: downloadsModel.downloads[index].isPaused ? "media-playback-start" : "media-playback-pause"
                    onClicked: {
                        var download = downloadsModel.downloads[index];
                        download.isPaused ? download.resume() : download.pause()
                    }
                }
                ToolButton
                {
                    flat: true
                    icon.name: "media-playback-stop"
                    onClicked: {
                        var download = downloadsModel.downloads[index];
                        download.cancel()
                    }
                }
                ToolButton
                {
                    flat: true
                    icon.name: "archive-remove"
                    onClicked: {
                        var download = downloadsModel.downloads[index];
                        download.cancel()
                        removeFromDownloads(index)
                    }
                }
            }
        }
    }

    function removeFromDownloads(currentIndex)
    {
        // Array
        var downloads = downloadsModel.downloads
        downloads.splice(currentIndex, 1);
        downloadsModel.downloads = downloads

        // Model
        downloadsModel.remove(currentIndex)

        saveDownloads()
    }

    function saveDownloads()
    {
        var datamodel = []

        // Guardar favoritos en ~/.config/KDE/novaiweb.conf
        for (var i = 0; i < downloadsModel.count; ++i)
        {
            var download = downloadsModel.downloads[index]
            datamodel.push(download)
        }
        downloads = JSON.stringify(datamodel)
    }

    function getDownloads()
    {
        // Get Downloads

        if (downloadsModel.count == 0) {

            // Leer favoritos de ~/.config/KDE/novaiweb.conf

            var datamodel = JSON.parse(downloads)

            for (var i = 0; i < datamodel.length; ++i)
            {
                download = datamodel[i]

                // Add download to the end of elements (model, array)

                downloadsModel.append(download)
                downloadsModel.downloads.push(download)
            }
        }
    }

    function filterModel(query) {

        // Reset

        for (var i = 0; i < downloadsModel.count; i++) {
            downloadsModelFiltered.items.addGroups(i, 1, "filteredItems")
        }

        // Filter

        console.info("query: " + query)

        for (var i = 0; i < downloadsModel.count; i++) {
            downloadsModel.downloads[i].downloadFileName.toLowerCase().includes(query.toLowerCase()) == false ? downloadsModelFiltered.items.removeGroups(i, 1, "filteredItems") : undefined
        }
    }
}
