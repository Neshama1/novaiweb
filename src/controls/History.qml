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
    id: rectHistoryPage

    scale: 0.80
    opacity: 0
    height: 120
    visible: popupHistory.visible

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

    Component.onCompleted: {
        db.transaction(function(tx) {
            history = tx.executeSql('SELECT * FROM History');
        })
    }

    Maui.Page {
        id: pageHistory

        anchors.fill: parent

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Item {
                width: pageHistory.width
                height: pageHistory.height
                Rectangle {
                    anchors.centerIn: parent
                    width: pageHistory.width
                    height: pageHistory.height
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
                popupHistory.visible = false
            }
        }

        Maui.SectionGroup
        {
            id: optionsGroup

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 5

            template.label1.text: i18n("History")
            template.label1.font.weight: Font.Normal
            template.label1.font.pixelSize: 20

            description: i18n("Browse your history")
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

            height: history.rows.length > 6 ? (60 * 6 + 40) : undefined

            onHeightChanged: {
                rectHistoryPage.height = 120 + listBrowser.height
            }

            model: history.rows.length

            delegate: Maui.ListItemTemplate
            {
                id: listHistory

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

                label1.text: history.rows.item(index).title
                label2.text: history.rows.item(index).url
                iconSource: Qt.resolvedUrl(history.rows.item(index).iconUrl)
                iconSizeHint: Maui.Style.iconSizes.medium

                ToolButton
                {
                    flat: true
                    icon.name: "tab-new"
                    onClicked: {
                        console.info("currentTime: " + Qt.formatDateTime(new Date(), "yyyyMMdd-hhmmss.zzz"))
                        console.info("Fecha:" + history.rows.item(index).dateTime)
                        console.info("Open " + history.rows.item(index).url + " from History")
                        stackView.globalTabView.addTab(stackView.globalBrowserComponent, {"url": history.rows.item(index).url}, false);
                        stackView.pop()
                    }
                }
                ToolButton
                {
                    flat: true
                    icon.name: "bookmark-remove"
                    onClicked: {
                        var title = history.rows.item(index).title
                        var url = history.rows.item(index).url
                        var iconUrl = history.rows.item(index).iconUrl
                        var dateTime = history.rows.item(index).dateTime
                        deleteFromdB(title, url, iconUrl, dateTime)
                    }
                }
            }
        }
    }

    function filterModel(query)
    {
        // Buscar en título y url
        query = '%' + query + '%'
        var queryDB = 'SELECT * FROM History WHERE title LIKE \"' + query  + '\" OR url LIKE \"' + query + '\" ORDER BY dateTime DESC'

        // Ejecutar búsqueda
        db.transaction(function(tx) {
            history = tx.executeSql(queryDB.toString())
        })
    }
}
