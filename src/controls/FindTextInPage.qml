import QtQuick
import QtQml
import QtQml.Models
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import Qt5Compat.GraphicalEffects
import QtWebEngine
import org.mauikit.controls as Maui

Maui.ShadowedRectangle {
    id: rectFind

    Maui.Theme.inherit: false
    Maui.Theme.colorSet: Maui.Theme.View

    scale: 0.80
    opacity: 0
    height: 200
    visible: popupFind.visible

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

    border.width: 0
    border.color: Qt.lighter("#dadada",1.08)
    shadow.size: 15
    shadow.color: Maui.ColorUtils.brightnessForColor(Maui.Theme.backgroundColor) == Maui.ColorUtils.Light ? Qt.darker("#dadada",1.1) : "#2c2c2c"
    shadow.xOffset: -1
    shadow.yOffset: 0
    radius: 6

    z: 1

    color: Maui.Theme.backgroundColor

    Component.onCompleted: {
        console.info("entra 2")
    }

    Maui.Page {
        id: findInPage
        anchors.fill: parent

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Item {
                width: findInPage.width
                height: findInPage.height
                Rectangle {
                    anchors.centerIn: parent
                    width: findInPage.width
                    height: findInPage.height
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

            onAccepted: {
                var flags = appSettings.findCaseSensitively ? WebEngineView.FindCaseSensitively : WebEngineView.FindFlags
                stackView.globalTabView.tabAt(stackView.globalTabView.currentIndex).webView.findText(searchInPage.text, flags)
            }

            //onCleared:

            actions: [
                Action
                {
                    icon.name: "go-up"
                    onTriggered: {
                        var flags = appSettings.findCaseSensitively ? WebEngineView.FindCaseSensitively : WebEngineView.FindFlags
                        stackView.globalTabView.tabAt(stackView.globalTabView.currentIndex).webView.findText(searchInPage.text, WebEngineView.FindBackward | flags)
                    }
                },
                Action
                {
                    icon.name: "go-down"
                    onTriggered: {
                        var flags = appSettings.findCaseSensitively ? WebEngineView.FindCaseSensitively : WebEngineView.FindFlags
                        stackView.globalTabView.tabAt(stackView.globalTabView.currentIndex).webView.findText(searchInPage.text, flags)
                    }
                }
            ]
        }

        headBar.farRightContent: Maui.CloseButton {
            flat: true
            onClicked: {
                popupFind.visible = false
            }
        }

        Maui.SectionGroup
        {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 5
            height: 50

            template.label1.text: i18n("Options")
            template.label1.font.weight: Font.Normal
            template.label1.font.pixelSize: 20

            description: i18n("Configure the behaviour")

            Maui.FlexSectionItem {
                template.label1.text: i18n("Case sensitively")
                template.label1.font.weight: Font.Normal

                label2.text: i18n("Defines wether uppercase and lowercase letters ar treated as distinct")

                Switch {
                    checkable: true
                    checked: appSettings.findCaseSensitively ? true : false
                    onToggled: {
                        visualPosition == 0 ? appSettings.findCaseSensitively = false : appSettings.findCaseSensitively = true
                    }
                }
            }
        }
    }
}
